%macro ii_std_provider_pcp(  med_services_data=
                            ,provider_data=work.provider_key
							,prv_key=prov_id
                            ,final_assignments_data=work.final_assignments
                            ,_tos_src=work.imap_tos
                            ,_tos_key=tos_i_5
                            ,_tos_vars=tos_i_5 PCP_SERV ENC_TOS ENC_TOP
                            ,_tos_proc_src=work.imap_tos_proc
                            ,_tos_proc_key=MAP_CODE
                            ,_tos_proc_vars=PROFTOS
                            ,_pcpsrvcat_src=&lib_pref._maps.imap_pcpserv_cat
                            ,_pcpsrvcat_key=PROCCODE
                            ,_pcpsrvcat_vars=PCCEM PCC
                            ,_cli_spec=&lib_pref._maps.spec
                            ,_cli_spec_key=value
                            ,_cli_spec_vars=ih_spec4_xwk);

   /**
    * Internal Exception Handler.<br>
    * Inserts usage description into log when exception occurs.<br>
    * Cancels the job.
    *
    * @param _desc REQUIRED Exception message
    */                                 
  %macro exception(_desc);
          
    %put ****************************************;
    %put ;
    %put ii_std_provider_pcp: Usage exception: &_desc;
    %put ii_std_provider_pcp: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception; 

  /*Data Assemblage*/
  /* Sorts required for merged data - not hashed datasets */
  proc sort data=&med_services_data.;
    by &prv_key;
  run;
  proc sort data=&provider_data.;
     by &prv_key;
  run;

  options mprint;

  /*Load various look-ups/joins into hash tables*/
  data work._source_data_(drop=tos_found 
                               pcp_found 
                               spec_found 
                               tos_proc_found);

    /* This will make sure the correct attributes are maintained from source data */
    if 0 then set &_tos_src.(keep=&_tos_vars.);
	if 0 then set &_pcpsrvcat_src.(keep=&_pcpsrvcat_vars.);
	if 0 then set &_tos_proc_src.(keep=&_tos_proc_key. &_tos_proc_vars.);
	if 0 then set &_cli_spec.(keep=&_cli_spec_vars.);

    merge &med_services_data.
          &provider_data.;

	by &prv_key.;

	/*Create Key Matches on set datset*/
    &_pcpsrvcat_key.=proc_code;
    &_tos_proc_key.=proc_code;
	if proc_code='' then &_tos_proc_key.=revenue;
	&_cli_spec_key.=serv_prv_spec1;

   if _n_=1 then do;

	  declare hash tos(dataset: "&_tos_src.");
          tos.definekey("&_tos_key.");
          tos.definedata(%sysfunc(prxchange(s/\s/","/,-1, "%trim(&_tos_vars)")));
          tos.definedone();

	  declare hash pcpserv_cat(dataset: "&_pcpsrvcat_src.");
          PCPSERV_CAT.definekey("&_pcpsrvcat_key");
          PCPSERV_CAT.definedata(%sysfunc(prxchange(s/\s/","/,-1, "%trim(&_pcpsrvcat_vars)")));
          PCPSERV_CAT.definedone();

      declare hash tos_proc(dataset: "&_tos_proc_src.");
          tos_proc.definekey("&_tos_proc_key.");
          tos_proc.definedata(%sysfunc(prxchange(s/\s/","/,-1, "%trim(&_tos_proc_vars)")));
          tos_proc.definedone();

	  declare hash cli_spec(dataset: "&_cli_spec.");
          cli_spec.definekey("&_cli_spec_key.");
          cli_spec.definedata(%sysfunc(prxchange(s/\s/","/,-1, "%trim(&_cli_spec_vars)")));
          cli_spec.definedone();
 
	end;
    
	pcp_found=pcpserv_cat.find();    /* 'found' is zero when the key value exists in the hash. */
	tos_proc_found=tos_proc.find();
	spec_found=cli_spec.find();

	tos_i_5=proftos;

	tos_found=tos.find();

	/*if _n_>1000000 then stop;*/

    if     (   PCCEM='1' 
            or PCC='1' 
            or PCP_SERV='1') 
       AND (ih_spec4_xwk in ('200','201','203','210','220','221') or pc_ind in ('Y'));

  run;

proc sql;
    /* Derivation of encounter 'fraction' */
    create table work.encounter_final as
	select source.*
          ,case
            when encounter.encounter_frac1 is not null
              then encounter.encounter_frac1 
            when encounter.encounter_frac2 is not null
			  then encounter.encounter_frac2
			else 0
			end as encounter
	  from
    work._source_data_ as source 
    left join 
    (
      select .5/sum( case 
	                   when (    pseudo_flg not in ('Y','1') 
                             AND ENC_TOP='2' 
                             AND ENC_TOS in ('24','29','31','47','49','143','144')
                             )
				         then 1
				       else 0
				     end) as encounter_frac1
		    ,1/sum( case 
	                  when (     pseudo_flg not in ('Y','1') 
                            /*AND (ENC_TOP='2')*/ 
                            AND ENC_TOS not in ('24','29','31','47','49','143','144')
                           )
				        then 1
				      else 0
				    end) as encounter_frac2
	        ,member
            ,serv_dt
            ,enc_tos
	    from work._source_data_
	    group by member
                ,serv_dt
                ,enc_tos
        having encounter_frac1>0 
           or  encounter_frac2>0
    ) as encounter
    on     encounter.member = source.member
      and encounter.serv_dt = source.serv_dt
	  and encounter.enc_tos = source.enc_tos
;
quit;

proc sql;
create view work.member_prov_sum as
select member
      ,prov_id
	  ,sum(case 
         when PCCEM='1'
		   then encounter
		 else 0
	   end) as enc1_sum
      ,sum(case 
         when PCCEM='1' or PCC='1'
		   then encounter
		 else 0
	   end) as enc2_sum
	  ,sum(case 
         when PCCEM='1' or PCC='1' or PCP_SERV='1'
		   then encounter
		 else 0
	   end) as enc3_sum
       ,sum(case 
         when PCCEM='1'
		   then amt_all
		 else 0
	   end) as amt1_sum
      ,sum(case 
         when PCCEM='1' or PCC='1'
		   then amt_all
		 else 0
	   end) as amt2_sum
	  ,sum(case 
         when PCCEM='1' or PCC='1' or PCP_SERV='1'
		   then amt_all
		 else 0
	   end) as amt3_sum
      ,sum(encounter) as encx_sum
	  ,sum(amt_all) as allx_sum
  from work.encounter_final
  where member is not null
  group by member
          ,prov_id
  having encx_sum >0
      or allx_sum >0 
  order by member
          ,enc2_sum desc
          ,enc1_sum desc
          ,amt2_sum desc
          ,amt1_sum desc
          ,enc3_sum desc
          ,amt3_sum desc
          ,prov_id;

quit;
data &final_assignments_data.;
  set work.member_prov_sum(rename=(prov_id=attributed_provider));
  by member;
  if first.member then output;
run;

%mend ii_std_provider_pcp; 

