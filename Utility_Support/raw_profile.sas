/*!
  *
  *    Basic Post-Import profile reporting for CCLF data-files
  * 
  *  @author Chris Amendola
  *  @created July 2017
  *
  */
/**
  *
  * @param  data_source Required. Fully specified path and filename for cclf imported file.
  * @param  sub_title Required. CCLF Specific Title for profile output.
  * @param  id_key Indicates which id key to use 'HICN' or 'MBI' Required. Defaults to 'BENE_HIC_NUM'. 
  * @param  min_max_dates Space-delimited list of date vars to get min and max values for. Optional. Defaults CLM_FROM_DT CLM_THRU_DT
  *
  */
%macro raw_profile( data_source=
                   ,sub_title=
                   ,id_key=BENE_HIC_NUM
                   ,min_max_dates=);
                   
  /*Local method for exception handling */
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
    %put raw_profile: Usage exception: &_desc;
    %put raw_profile: Job terminating.;
    %put ;
    %put ****************************************;
     
    %abort cancel;
        
  %mend exception;
  
  %macro get_min_max(_var);
  	
  	,min(&_var.) as min_&_var.
	  ,max(&_var.) as max_&_var.
	      	
  %mend get_min_max;	
  
  %macro put_min_max_var(_var);
  	
  	min_&_var. max_&_var.
  	
  %mend put_min_max_var; 	
  /** 
	* Local Macro variables
	*/
  %local _sum_dataset;
  %let _sum_dataset=&data_source._sum;

  %check_argument( parm=data_source                      
                   ,isa=DATA                   
                   ,required=YES);
  %check_argument( parm=sub_title
                   ,isa=CHAR
                   ,required=YES);

  title1 "INPUT_CMS_PREP - PD&cycle.";
  title2 "&client_title_short.";

  proc sql noprint;
    create table &_sum_dataset as
      select raw_source_file,
        count(&id_key.) as records,
        count(distinct &id_key.) as members
        %if %length(&min_max_dates)>1 %then %mac_map(get_min_max,to_list=min_max_dates);  
      from &data_source 
      group by raw_source_file
      order by raw_source_file;
    quit;

  
  title3 'MEDCMS Raw File(s) - Detail';
  title4 "&sub_title";

  ods graphics /width=800px height=600px imagename='cclf' imagefmt=gif imagemap;
  
  ods proclabel "&sub_title.-Record Counts By Source File";
  proc sgplot data=&_sum_dataset;
	  vbar raw_source_file / response=records;	
  run; 

  ods proclabel "&sub_title.-Member Counts By Source File";
  proc sgplot data=&_sum_dataset;	
	  vbar raw_source_file / response=members;
  run;  
  
  %if %length(&min_max_dates)>1 %then %do;
    ods proclabel "&sub_title.-Min-Max Dates By Source File";
    proc print data=&_sum_dataset noobs;
      var raw_source_file 
          %mac_map(put_min_max_var,to_list=min_max_dates);
      format %mac_map(put_min_max_var,to_list=min_max_dates) yymmdd10.;
    run;
  %end;
  
  title1;
	title2;
	title3;
  title4;

%mend raw_profile;
