/*! 
 *       Generates SAS statements intended to carry out simple variable transformations
 *       for use in datastep to read raw data.
 * 
 *        @author     Chris Amendola
 *       
 *        @created    July 6th 20017
 */
/**  
  * @param attrib_dataset Required. Fully specified SAS dataset name for the dataset 
  *                       produced from the read of the incoming datas' schema file.  
  *  
  */
%macro generate_transforms(attrib_dataset=work.metadata);

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
    %put generate_transforms: Usage exception: &_desc;
    %put generate_transforms: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception;
  
  /** 
	* Local Macro variables
	*/
  %local _for_itid
		 _sort_key
         _at_pos
         _record_count
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
    
	%let _format_statement=1;
	/*
	 * Parse each row of metadata
	 */
    %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
	  /*
	   * Get Column positions for:
	   *   variable name
	   *   informat 
       *   inc_len 
       *   format 
       *   label
       *
	   */
	%let _v_name_col=%sysfunc(varnum(&_for_itid,name));
    %let _v_label_col=%sysfunc(varnum(&_for_itid,label));
    %let _v_format_col=%sysfunc(varnum(&_for_itid,format));
    %let _v_length_col=%sysfunc(varnum(&_for_itid,inc_len));
    %let _v_informat_col=%sysfunc(varnum(&_for_itid,informat)); 
    %let _v_transform_col=%sysfunc(varnum(&_for_itid,transform)); 
	  /*
	   * Character type fields
	   */
	%let _name_val=%qsysfunc(getvarc(&_for_itid,&_v_name_col));
    %if %sysfunc(prxmatch("[^\w\s.]+",&_name_val)) 
      %then %let _name_val=%qtrim(&_name_val);
        
    %let _label_val=%qsysfunc(getvarc(&_for_itid,&_v_label_col));
    %if %sysfunc(prxmatch("[^\w\s.]+",&_label_val)) 
      %then %let _label_val=%qtrim(&_label_val);
    
    %let _format_val=%qsysfunc(getvarc(&_for_itid,&_v_format_col));
    %if %sysfunc(prxmatch("[^\w\s.]+",&_format_val)) 
      %then %let _format_val=%qtrim(&_format_val); 

    %let _informat_val=%qsysfunc(getvarc(&_for_itid,&_v_informat_col));
    %if %sysfunc(prxmatch("[^\w\s.]+",&_informat_val)) 
      %then %let _informat_val=%qtrim(&_informat_val);    

	%let _transform_val=%qsysfunc(getvarc(&_for_itid,&_v_transform_col));
    %if %sysfunc(prxmatch("[^\w\s.]+",&_transform_val)) 
      %then %let _informat_val=%qtrim(&_transform_val); 
     
    /*
	 * Numeric type fields
	 */
    %let _length_val=%sysfunc(getvarn(&_for_itid,&_v_length_col));
    %let _length_val=%trim(&_length_val);
    /*
     * Assemble Transformation statements
     */
	%if not %isblank(_transform_val) %then %do;
      %trim(&_transform_val)
    %end;
  %end;

  %let _for_i=%sysfunc(close(&_for_itid));
  %trim(;)/* Ends the format statement */
  %put ;;

%mend generate_transforms; 
