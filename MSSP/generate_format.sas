/*! 
 *       Generates SAS format statement(s) for use in datastep to read raw data.
 * 
 *        @author     Chris Amendola
 *       
 *        @created    July 5th 20017
 */
/**  
  * @param attrib_dataset Required. Fully specified SAS dataset name for the dataset 
  *                       produced from the read of the incoming datas' schema file.  
  *  
  */
%macro generate_format(attrib_dataset=work.metadata);

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
    %put generate_format: Usage exception: &_desc;
    %put generate_format: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception;
  
  /** 
	* Local Macro variables
	*/
  %local _for_itid
		 _sort_key
         _record_count
         _format_statement
		 _name_val
		 _format_val
         ;
    
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
    
  %let _format_statement=1;
  /*
   * Parse each row of metadata
   */
  %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
    
    %let _name_val=%get_val(name);
    %let _format_val=%get_val(format); 
    /*
     * Assemble format statement line by line
     */
	%if not %isblank(_format_val) %then %do;
	  %if %cmpres(&_format_statement)=1 %then %do;
	    format 
	    %let _format_statement=0;
	  %end;
     
      %let return=%cmpres(&_name_val) &_format_val;
      
	  &return

    %end;

  %end;

  %let _for_i=%sysfunc(close(&_for_itid));
  %trim(;)/* Ends the format statement */
  %put ;;

%mend generate_format; 
