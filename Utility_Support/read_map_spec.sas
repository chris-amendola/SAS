/*! 
 *       Reads a mapping spec file and generates a dataset for use by generation macros.
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2017 
 */
/**  
  * @param map_spec_file Required. No Default. Fully specified path and filename for maping specification.
  *  
  */
%macro read_map_spec(_map_spec_file);
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
    %put read_map_spec: Usage exception: &_desc;
    %put read_map_spec: Job terminating.;
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
  %check_argument( parm=_map_spec_file                      
                  ,isa=FILE                   
                  ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Mapping Specifications File: %trim(&_map_spec_file) cannot be found.  );
    /* 
     * Drop the work.metadata datseta
     */
    proc sql;
      %if %sysfunc(exist(work.map_spec)) %then DROP TABLE work.map_spec;;

    /**
      * Main process begins
      */
    data work.map_spec;
        attrib name         length=$50
               length       length=$8
               format       length=$32
               map_source   length=$1500
               transform    length=$1500 
               description  length=$1024
        ;       
        infile "&_map_spec_file" 
               dlm='|' 
               dsd 
               lrecl=4096 
               truncover   
               firstobs=1 
               termstr=LF;
               
        input name
              length
              format 
              map_source
              transform
              description
              ;
        /* Added a comment line feature to schema read */ 
        if substr(name,1,1) ^= '#' then do;      
          order_number+1;
          output;
        end; 
    run;

    proc sort data=work.map_spec;
      by order_number;
    run;

  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen; 
          
%mend read_map_spec;    
