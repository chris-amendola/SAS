/*! 
 *       Reads raw positional data specifically for CMS CCLF.
 *       Reads a schema file, which defines the properties of the incoming
 *       datafile to 'ingest' it into SAS format.
 * 
 *        @author     C Amendola
 *       
 *         @created    July 2017
 */
/**  
  * @param infile             Raw incoming data file(s) - may use wildcards. Required.
  * @param to_dataset         Working dataset to be created from infile. Required.
  * @param schema             Fully specified path to simple delimited file defining the incoming data schema. Required
  * @param clean_dates        Any dates that need MSSP specific date clean. Optional.
  * @param as_view            Produce output datset as a veiw - time saving device. DEFAULT: NO.
  *  
  */
%macro read_raw_cclf( infile=
                     ,to_dataset=
                     ,schema=
                     ,clean_dates=
                     ,as_view=NO
                     ,show_lines=0
                     ,crf_num=2);
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
    %put read_raw_cclf: Usage exception: &_desc;
    %put read_raw_cclf: Job terminating.;
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
    * Local 'method' to fix tildes in raw data 
	*/
  %macro tilde_fix();
    /*Remove tildes (~) from character fields*/
	array fix(*) _CHARACTER_;
	do i=1 to dim(fix);
	  if fix(i) = '~' then fix(i)='';
	end;
	drop i;
  %mend tilde_fix;

  /** 
    * Local 'method' to clean out-of range dates
    * Takes raw variables - ending in DT0 - and generates clean variables with 0 striped off 
	*/
  %macro clean_date(_raw_date_variable);
    %local _output_variable;
	
    /* Chop '0' off the end of the raw date variable*/
    %let _output_variable=%substr(&_raw_date_variable,1,%eval(%length(&_raw_date_variable)-1));

	format &_output_variable yymmdd10.;
    if &_raw_date_variable = '1000-01-01' then &_output_variable = .;
    else &_output_variable = input(&_raw_date_variable, yymmdd10.);
  %mend clean_date;

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

  %check_argument( parm=clean_dates
                   ,isa=CHAR                     
                   ,required=NO);
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

  %put LOOKHERE!!;

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
	       recfm=f 
	       filename=long_file 
	       lrecl=&_lrecl
           missover;
 
	/* Use schema to build an input statement */
	%generate_input();
	/* Fix character variables with tildes */
    %tilde_fix();	
	/* Format variables based on schema data */
    %generate_format();

	/* Apply clean-up format to 'dirty' dates*/
	%if not %isblank(clean_dates) %then
      %mac_map(clean_date,to_list=clean_dates);

	%generate_transforms();

    /*Capture source file name, month and type, plus client's MSSP number*/
    length raw_source_file_long $400 raw_source_file $75;
    raw_source_file_long = long_file;
	raw_source_file=scan(long_file,-1,'\');
    drop long_file;

    length source_file_month $7 mssp_num $5 source_file_type $2;
    source_file_month = scan(raw_source_file,5,'.');
    source_file_type = substr(scan(raw_source_file,4,'.'),2,2);
    mssp_num = scan(raw_source_file,2,'.');

	/* Drop a sample of incoming raw lines into the log. */
    %if &show_lines>0 %then %do;
	  if _n_ <= &show_lines then do;
	    line=_infile_;
        put "SAMPLE LINE: " _n_;
	    put line;
	    drop line;
	  end;
    %end;
  run;

  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen; 

%mend read_raw_cclf;
