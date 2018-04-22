/*! 
 *       Resolves claim update records in CCLF detail files.
 *       - Uses the most current data submissions record as the 'final answer'
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2017
 */
/**  
  * @param detail_data Required. No default.  Names detail dataset to have updates resolved.
  * @param out_data    Required. No default.  Names resulting resolved dataset.
  * @param detail_var  Required. Default: clm_val_sqnc_num. Unique key that determines final update record.
  *  
  */
%macro resolve_detail_updates( detail_data=
                              ,out_data=
                              ,detail_var=clm_val_sqnc_num);

  /**
	* Local 'methods'
	*/
  %macro exception(_desc);
   	   
    %put ****************************************;
   	%put ;
    %put resolve_detail_updates: Usage exception: &_desc;
    %put resolve_detail_updates: Job terminating.;
    %put ;
    %put ****************************************;
    %put ;
        
    %abort cancel;
        
  %mend exception;


  %check_argument( parm=detail_data                      
                   ,isa=DATA                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( detail_data: %trim(&detail_data) is not valid.);

  %check_argument( parm=out_data                      
                   ,isa=VALID_DATA                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( out_data: %trim(&out_data) is not a valid dataset name );
  
  %check_argument( parm=detail_var                     
                   ,isa=VAR~&detail_data                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception(trans_var: %trim(&detail_var) is not a variable found in %trim(&detail_data).  );

  /* Preliminary sort, so that latest record can be 'skimmed' out of data */
  proc sort data=&detail_data
             out=work.details_key_sorted;
    by cur_clm_uniq_id 
       &detail_var
       source_file_month;/* Ends up with later month at bottom of the sorted record set */
  run; 

  /* Last record in series is the final answer */
  data &out_data;
    set work.details_key_sorted;
    by cur_clm_uniq_id 
       &detail_var
       ;
    if last.&detail_var then output;/* Most current record is last. */
  run;
%mend resolve_detail_updates;
