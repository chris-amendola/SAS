/*! 
 *       Reads a simple file schema specification - a description of an
 *       incoming files attributes.
 * 
 *        @author     Chris Amendola
 *       
 *        @created    July 4th 2017 
 */
/**  
  * @param _schema_file Required. Fully specified path/file-name to schema file to be read. 
  */
%macro read_schema(_schema_file);
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
    %put read_schema: Usage exception: &_desc;
    %put read_schema: Job terminating.;
    %put ;
    %put ****************************************;
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
    _notes 
    _mprint 
    _symbolgen 
    _mlogic 
    _linesize;    
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
  %check_argument( parm=_schema_file                      
                  ,isa=FILE                   
                  ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_schema-invocation. Ending Now. );
  /* 
     * Drop the work.metadata datseta
     */
    proc sql;
      %if %sysfunc(exist(work.metadata)) %then DROP TABLE work.metadata;;  

    /**
      * Main process begins
      */
    data work.metadata;
        attrib name         length=$50
               informat     length=$32
               inc_len      length=8
               format       length=$32
               label        length=$1024
               order_number length=8
               transform    length=$1500
               length       length=$15
        ;       
        infile "&_schema_file" 
               dlm='|' 
               dsd 
               lrecl=4096 
               truncover   
               firstobs=1 
               termstr=LF;
               
        input name
              informat 
              inc_len 
              format 
              label
              transform
              ;
        if prxmatch('/^\$/',informat) then length=prxchange('s/\.||char//',-1,informat);
        else length="8";
        /* Added a comment line feature to schema read */ 
        if substr(name,1,1) ^= '#' then do;      
          order_number+1;
          
          put _all_;
          output;
          
        end; 
    run;

    proc sort data=work.metadata;
      by order_number;
    run;

  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen; 
          
%mend read_schema;  
