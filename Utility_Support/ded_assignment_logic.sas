/*! 
 *       Parses the transformations in a mapping specification and excutes them.
 * 
 *        @author    C Amendola
 *         @created    August 2017 
 */
/**  
  * @param attrib_dataset Required. Default:work.map_spec Specifies the mapping specificiation dataset to read from.
  *  
  */
%macro ded_assignment_logic(attrib_dataset=work.map_spec);

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
    %put ded_assignment_logic: Usage exception: &_desc;
    %put ded_assignment_logic: Job terminating.;
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
         _xform_val;
      
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
    
	/*
	 * Parse each row of metadata
	 */
    %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
	  /*
	   * Character type fields
	   */
    
    %let _xform_val=%get_val(transform);
     
    /*
     * Generate tranfomations.
	*/
    %let return=&_xform_val;
    %if not %isblank(_xform_val) %then %put TRANSFORM: %trim(&return);
	%trim(&return);
    
  %end;

  %let _for_i=%sysfunc(close(&_for_itid));
  %trim(;)/* Ends the attrib statement */
  %put ;;

%mend ded_assignment_logic;
