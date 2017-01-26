/*! 
 *       {One-Line description of module/program}
 *       {Multiple lines and paragraphs may follow} 
 *       {HTML tags can help format these paragraphs}
 * 
 *        @author     First 
 *        @author     to nth 
 *       
 *         @created    Just created date 
 */
/**  
  * @param _parm1 Description of parameter. Required or Optional? Acceptable values  
  * @param _parm2
  *  
  */
%macro {mac_name}();
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
    %put {mac_name}: Usage exception: &_desc;
    %put {mac_name}: Job terminating.;
    %put ;
    %put ****************************************;
    %put Usage Description:;
    %put ;	                                                   
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ; 
    %put  * @param ;
    %put ;
        
    /* Reset options */
    options &_notes 
            lineSize=&_linesize 
            &_mprint 
            &_mlogic 
            &_symbolgen;
        
     %abort cancel;
        
  %mend exception;
  /** 
	  * Local Macro variables
	  */
  %local 
    ;
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
	  */
  %check_argument( parm=                      
                  ,isa=                   
                  ,required=);

  %check_argument( parm=
                  ,isa=
                  ,required=);

  %check_argument( parm=
                   ,isa=                     
                   ,required=);

	%check_argument( parm=
                  ,isa=                 
                  ,required=
                  ,valid_values=);
	/** 
	  * Stop process on bad argument
	  */
    %if &_argument_check_code = 0 %then %do;  
        %put Bad argument(s) found in {mac_name}-invocation.;      
        %put Ending Now.;
        %abort cancel;
    %end;
	/**
	  * Main process begins
	  */



  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen;  

%mend {mac_name};	
	