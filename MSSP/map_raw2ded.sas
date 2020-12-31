/*! 
 *       Executes the initial mapping of raw incoming variables to DED standard names. 
 * 
 *        @author     C Amendola
 *       
 *        @created    August 2017 
 */
/**  
  * @param attrib_dataset Required. Default: work.map_spec. Names the mapping specification dataset to be employed.
  *  
  */
%macro map_raw2ded(attrib_dataset=work.map_spec);

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
    %put map_raw2ded: Usage exception: &_desc;
    %put map_raw2ded: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception;
  
  /** 
	* Local Macro variables
	*/
  %local _for_itid
		 _sort_key
         _var_list
         _record_count;
      
  /** 
	* Validate parameter arguments
    * Avoiding check_argument due to "in datastep" call of macro
	*/
  %if %isblank(attrib_dataset) %then %do;
    %exception(No Attributes Dataset specified - default was overwritten?)
  %end; 
  
  %if not %sysfunc(exist(&attrib_dataset)) %then %do;
    %exception(Attributes Dataset specified does not exist.)
  %end;
  /*
   * Main process begins
   */
	/*
	 * Open dataset
	 */
  %let _for_itid=%sysfunc(open(&attrib_dataset));
	%if &_for_itid=0 %then %do;
	  %exception(Can not open dataset &attrib_dataset!)
  %end;
	%else %put Note: &attrib_dataset Opened for reading.;
   
  %let _sort_key=%sysfunc(attrc(&_for_itid,sortedby));

  %if &_sort_key NE order_number %then %do;
    %exception(&attrib_dataset not sorted by variable order number.)
  %end;

  /* Local method to get variable value from current obs */
  /* Has to be defined after source dataset is opened */
  %macro get_val(_var);

	  %local _col_num 
             _type
             _return;

      %let _col_num=%sysfunc(varnum(&_for_itid,&_var));
      %let _type=%sysfunc(vartype(&_for_itid,&_col_num));
      
      %if &_type=C %then %do;
	    %let _return=%qsysfunc(getvarc(&_for_itid,&_col_num));
        %if %sysfunc(prxmatch("[^\w\s.]+",&_return)) 
          %then %let _return=%qtrim(&_return);
	  %end;
      %if &_type=N %then %do;
	    %let _return=%sysfunc(getvarn(&_for_itid,&_col_num));
        %let _return=%trim(&_return);
	  %end;
      
	  &_return

	%mend get_val;  
    
	%let _record_count=1;
	%let _at_pos=1;
	/*
	 * Parse each row of metadata
	 */
    %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
	  /*
	   * Character type fields
	   */
	%let _name_val=%get_val(name);
    %let _length_val=%get_val(length); 
    %let _format_val=%get_val(format);
    %let _source_val=%get_val(map_source);
     
    /*
     * Produce assignment mappings.
	 */

    %let _record_count=%eval(&_record_count+1);
    /* Should this abort the job?*/
	%if %isblank(_source_val) %then %do;
      %if %substr(&_length_val,1,1) = %str($) %then %do;	    
		%put No Mapping Value assigned for %trim(&_name_val) -> Assigning default for type CHAR, '';
		%let _source_val='';
	  %end;
	  %else %do;	    
		%put No Mapping Value assigned for %trim(&_name_val) -> Assigning default for type NUM, .;
		%let _source_val=.;
	  %end;
    %end;
	%else %put %trim(&_name_val) -> %trim(&_source_val);

    %let return=%cmpres(&_name_val)%nrstr(=)%trim(&_source_val);
 
	%trim(&return);
    %put MAP: &return;

  %end;

  %let _for_i=%sysfunc(close(&_for_itid));
  %trim(;)/* Ends the attrib statement */
  %put ;;

%mend map_raw2ded;
