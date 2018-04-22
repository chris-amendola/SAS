%macro infer_schema( scan_obs=500
                    ,delm=PIPE
                    ,schema_out=
                    ,data_file=
                    ,header=Y);

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
    %put infer_schema: Usage exception: &_desc;
    %put infer_schema: Job terminating.;
    %put ;
    %put ****************************************;
    %put ;
            
     %abort cancel;
        
  %mend exception;

  /** 
    * Validate parameter arguments
    * Stop process on bad argument
    */
  %check_argument( parm=scan_obs                      
                   ,isa=INT                
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_delm_prep-invocation. Ending Now. ); 

  %check_argument( parm=delm                      
                   ,isa=CHAR                   
                   ,required=YES
                   /* Add valid vars list */);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_delm_prep-invocation. Ending Now. );

  %check_argument( parm=raw_file                      
                   ,isa=FILE                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_delm_prep-invocation. Ending Now. );

  %check_argument( parm=schema_out                      
                   ,isa=CHAR                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_delm_prep-invocation. Ending Now. );

  %check_argument( parm=data_file                      
                   ,isa=CHAR                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_delm_prep-invocation. Ending Now. );

  %check_argument( parm=HEADER                      
                   ,isa=CHAR                   
                   ,required=YES
                   ,valid_values=Y N y n YES NO Yes No);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_delm_prep-invocation. Ending Now. );
  
  /* Local Macro Vars */ 
  %local _work_path
         _delm;
  
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

  /* Missing value analysis format */ 
  proc format ;
    value _nmiss 
      low-high="Non-missing";
    value $_cmiss 
      " "="Blank" 
      other="Non-missing";
  run;

  filename src "&data_file";
  
  /* Find the work libname directory to write scartch files */
  %let _work_path =%sysfunc(pathname(work)); 
  
  data _null_;
    attrib _line_ length=$32000;
    infile src lrecl=32000 
             obs=&scan_obs; 
    input; 
    _line_ = _infile_;
    file "&_work_path/scratch_file.dat" linesize=32000;
    put _line_;
  run;
 
  proc import datafile="&_work_path/scratch_file.dat" 
              dbms=dlm
              out=work.test_data
              replace;
              guessingrows=&scan_obs;
              delimiter=%trim(&_delm);
              %if %upcase(&header=Y)
                  or %upcase(&header=YES)
                %then getnames=yes;
              %else getnames=no;
              ;
 
  proc datasets nolist;    
    contents data=work.test_data 
              out=work.raw_conts noprint;
  run;
  
  data work.raw_conts;
    attrib type_str length=$15 label="Variable Type";
  
   set work.raw_conts;
  
    if type=1 then type_str='Numeric';
    else if type=2 then type_str='Character';
    else type_str="ERROR!!!";
    
  run;

  proc sort data=work.raw_conts;
    by varnum;
  run;
  title "Infered Table Attributes (scan obs=&scan_obs)";
  title2 "%trim(&data_file)"; 
  proc print data=work.raw_conts noobs label;
    var name type_str format length label;
  run;

  /* Schema file creation */
  data _null_;
    attrib line length=$5000.;
    set work.raw_conts; 
    file "&schema_out";

    if _n_=1 then do;
      line="#Variable Name Informat Incoming Length Format Label Transform ";
      put line;
    end;

    line=strip(name)||"|"||compress(strip(informat))||strip(informl)||".|"||strip(length)||"|"||strip(format)||strip(formatl)||".|"||strip(label)||"||"; 
  
    put line;

  run;  
  
  /* Missing Value Report */
  proc sql noprint;
    select name into :_vars_list separated by ' '
    from work.raw_conts;
  quit;

  data work.__tmp__;
    set work.TEST_DATA;
    _Case_=_n_;
  run;

  proc transpose data=work.__tmp__ 
                  out=WORK.Stacked(drop=_Label_ 
                                   rename=(col1=_Variable_)) 
                 name=_Level_;
    var &_vars_list;
    by _Case_;
  run;
  
  data WORK.Stacked;
    attrib _Level_ label="Infered Variable";
    set work.Stacked;
  run;

  proc sort data=work.stacked;
    by _Level_;
  run;

  proc delete data=WORK.__tmp__;
  run;

  title "Missing Value Analysis of Infered Data (scan obs=&scan_obs)";
  /* Missing Value Report */
  /*--Set output size--*/
  ods graphics / reset imagemap;

  /*--SGPLOT proc statement--*/
  proc sgplot data=WORK.STACKED;
  format _Variable_ $_cmiss.;
    /*--Bar chart settings--*/
    vbar _Level_ 
      /group=_Variable_ 
       groupdisplay=Cluster 
       name='Bar';

    /*--Response Axis--*/
    yaxis grid;
  run;

  ods graphics / reset;

  /* 15 Observation sample print of infered data */
  proc print data=work.test_data (obs=15) noobs;
  run;
%mend infer_schema;