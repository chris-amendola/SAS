/*! 
 *       Generates the attribution statement for a ded mapping specification.
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2017
 *
 */
/**  
  * @param attrib_dataset Required. Default: work.map_spec Mapping specification dataset to be read.
  *  
  */
%macro generate_attrib(attrib_dataset=work.metadata);

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
    %put generate_attrib: Usage exception: &_desc;
    %put generate_attrib: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception;
  
  /** 
    * Local Macro variables
    */
  %local _notes
         _mprint
         _symbolgen
         _mlogic
         _linesize
         _for_itid
         _sort_key
         _v_name_col
         _name_val
         _v_format_col
         _format_val
         _v_length_col
         _length_val;
    
  /**
    * Capture Current SAS options 
    */
  %let _notes = %sysfunc(getoption(notes));
  %let _mprint = %sysfunc(getoption(mprint));
  %let _symbolgen = %sysfunc(getoption(symbolgen));
  %let _mlogic = %sysfunc(getoption(mlogic));
  %let _linesize = %sysfunc(getoption(linesize));  
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
    
  %let _record_count=1;
    
    /*
     * Parse each row of metadata
     */
    %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
      /*
       * Get Column positions for:
       *   variable name
       *   format 
       *   length 
       *   label
       */
      %let _v_name_col=%sysfunc(varnum(&_for_itid,name));
      %let _v_format_col=%sysfunc(varnum(&_for_itid,format));
      %let _v_length_col=%sysfunc(varnum(&_for_itid,length));  
      %let _v_label_col=%sysfunc(varnum(&_for_itid,label));
      /*
       * Character type fields
       */
      %let _name_val=%qsysfunc(getvarc(&_for_itid,&_v_name_col));
      %if %sysfunc(prxmatch("[^\w\s.]+",&_name_val)) 
        %then %let _name_val=%qtrim(&_name_val);
        
      %let _length_val=%qsysfunc(getvarc(&_for_itid,&_v_length_col));
      %if %sysfunc(prxmatch("[^\w\s.]+",&_length_val)) 
        %then %let _length_val=%qtrim(&_length_val);

      %let _format_val=%qsysfunc(getvarc(&_for_itid,&_v_format_col));
      %if %sysfunc(prxmatch("[^\w\s.]+",&_format_val)) 
        %then %let _format_val=%qtrim(&_format_val);    

      %let _label_val=%qsysfunc(getvarc(&_for_itid,&_v_label_col));
      %if %sysfunc(prxmatch("[^\w\s.]+",&_label_val)) 
        %then %let _label_val=%qtrim(&_label_val); 
      /*
       * Assemble input statement line by line
       */
      %if %cmpres(&_record_count)=1 %then %do;
        attrib 
      %end;

      %let _record_count=%eval(&_record_count+1);

     %if %substr(&_name_val,1,1)=%nrquote(~) %then %do;
       %let _name_val=%substr(&_name_val,2);
     %end;  
    
      %let return=%cmpres(&_name_val) length%nrstr(=)&_length_val;
      %if not %isblank(_format_val) %then %let return =&return format%nrstr(=)&_format_val;
      %if not %isblank(_label_val) %then %let return= &return label%nrstr(=) "%sysfunc(strip(&_label_val.))";
      %*put ATTRIB: &return;  
      %trim(&return)
    
    %end;

    %let _for_i=%sysfunc(close(&_for_itid));
    %trim(;)/* Ends the attrib statement */
    %put ;;

%mend generate_attrib;
