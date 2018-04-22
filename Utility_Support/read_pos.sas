/*! 
 *       Reads raw positional.
 *       Reads a schema file, which defines the properties of the incoming
 *       datafile to 'ingest' it into SAS format.
 * 
 *        @author     C Amendola
 *       
 *         @created    September 2017
 */
/**  
  * @param infile             Raw incoming data file(s) - may use wildcards. Required.
  * @param to_dataset         Working dataset to be created from infile. Required.
  * @param schema             Fully specified path to simple delimited file defining the incoming data schema. Required
  * @param as_view            Produce output datset as a veiw - time saving device. DEFAULT: NO.
  *  
  */
%macro read_pos( infile=
                ,to_dataset=
                ,schema=
                ,as_view=NO
                ,show_lines=0
                ,crf_num=2
                ,_recfm=f);
                
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
    %put read_pos: Usage exception: &_desc;
    %put read_pos: Job terminating.;
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

  %local _lrecl
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
    * Stop process on bad argument
    */
  %check_argument( parm=infile                      
                   ,isa=CHAR                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_schema-invocation. Ending Now. );
 
  %check_argument( parm=to_dataset
                   ,isa=VALID_DATA
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_schema-invocation. Ending Now. );

  %check_argument( parm=schema
                   ,isa=FILE                     
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_schema-invocation. Ending Now. );

  %check_argument( parm=as_view
                  ,isa=CHAR
                  ,required=YES
                  ,valid_values=Y N y n YES NO Yes No yes no);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_schema-invocation. Ending Now. );

  %check_argument( parm=show_lines
                  ,isa=INT
                  ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_schema-invocation. Ending Now. );

  /* Read incoming file metadata */
  %read_schema(&schema);

  proc sql noprint;
    /* Compute lrecl from schema info*/
    select (sum(inc_len)+&crf_num) 
      into :_lrecl
      from work.metadata;
    /* Drop possible pre-existing view or table */
    /* Currently drops a warning because only table or view exists*/
    %if %sysfunc(exist(&to_dataset)) %then drop table &to_dataset;;
    %if %sysfunc(exist(&to_dataset,"VIEW")) %then drop view &to_dataset;;

  data &to_dataset
  %if %upcase(%substr(&as_view,1,1))^=N %then /view=&to_dataset;;           
    length long_file $400;        
      infile "&infile"
           recfm=&_recfm 
           filename=long_file 
           lrecl=&_lrecl
         truncover;
 
    /* Use schema to build an input statement */
    %generate_input();
        
    /* Format variables based on schema data */
  %generate_format();

    %generate_transforms();

    source_file=long_file;
    /* Drop a sample of incoming raw lines into the log. */
    %if &show_lines>0 %then %do;
      if _n_ <= &show_lines then do;
        line=_infile_;
        put "*******************************************************************************************";
        put "SAMPLE LINE: " _n_;
        put "OBSERVATION: " _all_;
      end;
    %end;
  run;

  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen; 

%mend read_pos;
