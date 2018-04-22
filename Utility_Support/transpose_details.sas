/*! 
 *       Macro facade for tranposition of facility claims, part A, details files - 
 *     reduces details to single record for claim id.
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2017 
 */
/**  
  * @param detail_data Required.  Names detail dataset to be 'flattened'
  * @param out_data    Required.  Names resulting 'wide' dataset.
  * @param trans_var   Required.  Detail dataset field to be tranposed - typically diag or proc vars
  * @param prefix      Required.  Prefix to add to new tranposed columns.
  * @param key_var     Required.  Default: CLM_VAL_SQNC_NUM. Tranposition key, typically unique claim identifier.
  *  
  */
%macro transpose_details( detail_data=
                         ,out_data=
                         ,trans_var=
						 ,prefix=
                         ,key_var=CLM_VAL_SQNC_NUM);
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
    %put transpose_details: Usage exception: &_desc;
    %put transpose_details: Job terminating.;
    %put ;
    %put ****************************************;
        
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

  %check_argument( parm=trans_var                     
                   ,isa=VAR~&detail_data                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception(trans_var: %trim(&trans_var) is not a variable found in %trim(&detail_data).  );

  %check_argument( parm=prefix                      
                   ,isa=CHAR                  
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( prefix: %trim(&prefix) is not a valid string. );

  %check_argument( parm=key_var                    
                   ,isa=VAR~&detail_data                  
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception(key_var: %trim(&key_var) is not a variable found in %trim(&detail_data). );
  /**
	* Resolved detail files should already be sorted, so this proc sort is defensive 
    **/
  proc sort data = &detail_data
  	         out = work._tmpsrt_;
    by CUR_CLM_UNIQ_ID 
       &key_var;
  run;

  proc transpose data=work._tmpsrt_
                  out=&out_data
                 prefix=&prefix;
    by cur_clm_uniq_id;
    var &trans_var;
  run;

%mend transpose_details;
