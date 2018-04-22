/*! 
 *       Reads raw delimited data specifically.
 *       Reads a schema file, which defines the properties of the incoming
 *       datafile to 'ingest' it into SAS format.
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2017
 */
/**  
  * @param infile             Raw incoming data file(s) - may use wildcards. Required.
  * @param to_dataset         Working dataset to be created from infile. Required.
  * @param schema             Fully specified path to simple delimited file defining the incoming data schema. Required
  * @param delm               Column delimiter. Required. Default: |
  * @param header_rows        Number of rows at head of file to skip reading. Optional
  * @param as_view            Produce output datset as a veiw - time saving device. DEFAULT: NO.
  *  
  */
%macro read_delm( infile=
                 ,to_dataset=
                 ,schema=
                 ,delm=
                 ,header_rows=
                 ,as_view=NO
                 ,show_lines=0);
                 
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
    %put read_delm: Usage exception: &_desc;
    %put read_delm: Job terminating.;
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
         _linesize
         _delm;

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
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );
 
  %check_argument( parm=to_dataset
                   ,isa=VALID_DATA
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );

  %check_argument( parm=schema
                   ,isa=FILE                     
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );

  %check_argument( parm=delm
                   ,isa=CHAR                     
                   ,required=NO);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );

  %check_argument( parm=as_view
                  ,isa=CHAR
                  ,required=YES
                  ,valid_values=Y N y n YES NO Yes No yes no);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );

  %check_argument( parm=show_lines
                  ,isa=INT
                  ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );

  %check_argument( parm=header_rows
                  ,isa=INT
                  ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm-invocation. Ending Now. );
    
  /* Handle special case delimiters */
  %if %upcase(%str(&delm)) = SPACE %then  
    %let _delm = " ";
  %else %if %upcase(%str(&delm)) = TAB %then 
    %let _delm ='09'X;
  %else %if %upcase(%str(&delm)) = TILDE %then 
    %let _delm = "~";
  %else %if %upcase(%str(&delm)) = PIPE %then 
      %let _delm ="|";  
  %else %if %upcase(%str(&delm)) = COMMA %then
      %let _delm=",";    
  %else %let _delm="&delm";

  /** Read incoming file metadata */
  %read_schema(&schema);
  /* Drop possible pre-existing view or table */
  /* Currently drops a warning because only table or view exists*/
  proc sql;
  %if %sysfunc(exist(&to_dataset)) %then drop table &to_dataset;;
  %if %sysfunc(exist(&to_dataset)) %then drop view &to_dataset;;
  quit;

  data &to_dataset
  %if %upcase(%substr(&as_view,1,1))^=N %then /view=&to_dataset;;  
    %generate_attrib();
    length long_file $500
           source_file $500; 
    infile "&infile"
           lrecl=32767 
           filename=long_file 
           %if not %isblank(header_rows) %then firstobs=%eval(&header_rows+1);       
           dlm=&_delm
           missover
           dsd 
           ;
 
    /* Use schema to build an input statement */
    %generate_input(delm=&_delm);
 
    /* Data Manipulatons */
    %generate_transforms();

    source_file=long_file;
    /* Drop a sample of incoming raw lines into the log. */
    %if &show_lines>0 %then %do;
      if _n_ <= &show_lines then do;
        line=_infile_;
        put "SAMPLE LINE: " _n_;
        put line;
        put "Vars: ";
        put _all_;
      end;
    %end;
  run;

  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen; 

%mend read_delm;
/*
options append=(sasautos="Y:\Users\camendol\SAS_ETL_dev\support_lib");
%put %sysfunc(getoption(sasautos));
options mprint;
%read_delm( infile=Y:\Users\camendol\SAS_ETL_dev\data\incoming\professionaldetail.txt
           ,to_dataset=work.test
           ,schema=Y:/Users/camendol/SAS_ETL_dev/config/test_schema.dlm
           ,delm=|
           ,header_rows=1)
option nomprint;
*/
