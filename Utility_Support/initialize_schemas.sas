/*! 
 *       Scans files(delimited-ascii) in a named directory and reports which files share a common 
 *       record layout(list of variables) and produces a best guess schema file for 
 *       each common layout. 
 * 
 *        @author     C Amendola
 *       
 *        @created    August 2017
 */
/**  
  * @param contributor  Contibutor/Client Name. Required.
  * @param source_path  Path to raw data files. Required.
  * @param out_path     Location to output infered schemas. Required.
  * @param _delm        Data file delimiter. Required. Defaults: PIPE
  * @param filter_spec  Valid regex(perl) to specify filter files scanned. Required.
  * @param header_row   Indicates that theres a header row - field list present in data files. Required.
  *  
  */
%macro initialize_schemas( contributor=
                          ,source_path=
                          ,out_path=\
                          ,_delm=PIPE
                          ,filter_spec=.*\.txt
                          ,header_row=Y);
             
  /*Local methods*/
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
    %put initialize_schema: Usage exception: &_desc;
    %put initialize_schema: Job terminating.;
    %put ;
    %put ****************************************;
    %put ;
            
     %abort cancel;
        
  %mend exception; 
  
  %check_argument( parm=contributor                     
                   ,isa=CHAR                
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in initialize_schema-invocation. Ending Now. ); 
    
  %check_argument( parm=source_path                     
                   ,isa=PATH                
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in initialize_schema-invocation. Ending Now. ); 
    
  %check_argument( parm=out_path                   
                   ,isa=PATH                
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in initialize_schema-invocation. Ending Now. ); 
    
  %check_argument( parm=_delm                     
                   ,isa=CHAR                
                   ,required=YES
                   );
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in initialize_schema-invocation. Ending Now. ); 
    
  %check_argument( parm=filter_spec                     
                   ,isa=CHAR                
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in initialize_schema-invocation. Ending Now. ); 
    
  %check_argument( parm=header_row                     
                   ,isa=CHAR
                   ,valid_values=YES Y Yes NO N No               
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in initialize_schema-invocation. Ending Now. );           
  
  libname outdata "%sysfunc(pathname(work))"; 

  data outdata.file_vars;
    
    attrib source length=$500
           var_list length=$10000;
  run;

  /* House-keeping */
  proc datasets library=outdata;
    delete raw_vars;
  quit;
  run;

  %get_filenames( &source_path.
                 ,filter_regex=&filter_spec);
                 
  %if %obs(work.file_list) = 0 
    %then %exception(No files found as specified. Please check path settings and filter expression.) ;               

  proc sql noprint;
    select memname 
      into :base_list separated by ' ' 
      from work.file_list; 

  /* Create routine to loop through */
  %macro schema_scan(_var);
  
    %local _var_list; 

    %macro new_rec(_var,_var_list); 

      source="&_var";
      var_list="&_var_list";
      output;     

    %mend new_rec;

    %infer_schema( data_file=&source_path&_var
                  ,delm=&_delm 
                  ,schema_out=/*&out_path.\&_var..sch */ %sysfunc(pathname(work))\&_var..sch
                  ,header= &header_row);

    %read_schema( /*&out_path.\&_var..sch*/  %sysfunc(pathname(work))\&_var..sch);

    data work.metadata_src;
      attrib source   length=$2500;
      set work.metadata;
      source="&source_path&_var";   
    run;

    proc sql noprint;
      select name 
        into :_var_list separated by ' ' 
      from work.metadata;

    data outdata.file_vars;
      attrib source   length=$2500
             var_list length=$8000;

      %if %sysfunc(exist(outdata.file_vars)) %then %do;
        set outdata.file_vars end=_DONE;
        output;
        if _DONE then do;
          %new_rec(&_var,&_var_list);;
        end;
      %end;
      %else %new_rec(&_var,&_var_list);;   
    run;

    %if (not %sysfunc(exist(outdata.raw_vars))) %then %do;
      data outdata.raw_vars;
        set work.metadata_src;
      run;
    %end;
    %else %do;
      proc datasets;
        append base=outdata.raw_vars
               data=work.metadata_src;
      run;
    %end;     

  %mend schema_scan;

  /* Iterate through files to determine schemas */
  %mac_map(schema_scan,to_list=base_list);  

  proc sql;
    create table _schema_heads_ as 
      select distinct var_list 
      from outdata.file_vars;

    create table _var_length_maxs_ as 
      select distinct name, informat, inc_len, format, length 
      from outdata.raw_vars 
      group by name having inc_len=max(inc_len);   
  quit;

  data work.schema_key(keep=var_list schema_file);

    attrib line     length=$2000
           sch_name length=$2000;

    /* Dynamically set attributes for the hash table vars*/ 
    if 0 then set outdata.raw_vars(keep= name 
                                         informat 
                                         inc_len 
                                         format 
                                         length);

    set _schema_heads_(where=(var_list^="")); 

    /* Declare hash at first record - does not change */
    if _n_=1 then do;
      declare hash var_data(dataset: '_var_length_maxs_');
        var_data.definekey('name');
        var_data.definedata('name', 'informat', 'inc_len', 'format', 'length');
        var_data.definedone();
    end;

    schema_file="&contributor._schema_"||put(_n_,z2.);
    sch_name="&out_path\&contributor._schema_"||put(_n_,z2.);
    
    /* Step through variable list and look up best guess for attributes */
    
    ctr=1;
    file out_sch filevar=sch_name;
      put "#Variable_Name Informat Incoming_Length Format Label Transform";
    do while(scan(var_list,ctr," ") ne "");
      name=scan(var_list,ctr," ");

      find_rc=var_data.find();

      if find_rc=0 then do;
        /* CAA TODO: Look at trying to find 'hints' in the variable names as to the type
         * eg *_NDC_* indicates possible NDC values 
         * Start by adding conditionals and then move to tabular approach.
         */
        if prxmatch('/_DT|_DATE/',name) then do;
          informat="anydtdte.";
          inc_len="8";
          format="yymmdd10.";
        end;
        line=strip(name)||"|"||strip(informat)||"|"||strip(inc_len)||"|"||strip(format)||"|||";
        put line;
      end;
      ctr+1;
    end; 
  run;

  proc sql;
    create table work.schema_key_report as 
      select var_data.source, 
             var_data.var_list,  
             key.schema_file
      from outdata.file_vars var_data
           inner join work.schema_key key on (var_data.var_list = key.var_list);
  quit;

  /* Report Sub-routine */
  %macro _report( var_list=
                  ,schema_file=);

    data __tmp__;
      set work.schema_key_report(where=(var_list="%trim(&var_list.)"));
    run;

    title1 "&contributor.";
    title2 "SCHEMA_FILE: &schema_file. ";
      title3 "Delimiter: &_delm";
    ods proclabel "&schema_file.";
    proc print data=__tmp__ label noobs contents="Shared by Files";
      var source;
      label source="&source_path";
    run;
    
    %read_schema(&out_path.\&schema_file.);

    %local _title_link;
    %let _title_link=<a href='&out_path.\&schema_file.'>SOURCE SCHEMA: &out_path.\&schema_file.</a>; 
    ods proclabel "Infered Schema Attributes";
    title "&_title_link";
    title2 "Delimiter: &_delm";
    proc print data=work.metadata label contents="List";     
        var name 
            informat 
            inc_len 
            format 
            label 
            transform;
        label name='Field Name' 
              informat='Incoming Format' 
              inc_len='Length' 
              format='Variable Format' 
              label='Field Label' 
              transform='Transform';    
    run;

  %mend _report;

  %put BEGIN FINAL SUMMARY REPORT....;
  ods listing close;
  ods html body="&out_path\htmlsrc\&contributor._schema_report.html"
     contents="&out_path\htmlsrc\&contributor._schema_report-contents.htm"
        frame="&out_path\&contributor._schema_report-frame.htm"
         /*page="&out_path\htmlsrc\&contributor._schema_report-page.htm"*/
         style=SasWeb
         newfile=output;
    %apply_obs(work.schema_key,_report);
  ods html close;                         
  ods listing;
  %put FINAL SUMMARY REPORT COMPLETE.;
  
%mend initialize_schemas;

