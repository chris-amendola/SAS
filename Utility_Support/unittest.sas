/*!
  *        Assertion Macro Function Package (SAS V9 or Greater)
  *        Allows for Test-Driven Development
  *
  *    <p>    Provides the assert macro definintion, described in detail below, and 
  *    creates a global macro variable "assertions_mode" and sets it to "ON".
  *    This macro variable makes assertion testing active, and will result in
  *    assertion related messages appearing in the run log.
  *    <p>    This macro variable can be manually set to "OFF" in the main body of 
  *    code and will lead to the assertions not being tested.
  *
  *    <p>    Generally when testing and debugging code one would want 
  *    assertions_mode set to "ON", and then in production runs, would want 
  *    assertions_mode set to "OFF".
  *
  *    <p>    Assertions are used for "pre-emtive" debugging strategy, and not 
  *    as part of a defensive coding approach, eg, checking user inputs for 
  *    validity, or incoming data for accepted ranges/values. Assertions 
  *    provide no conditional control of program flow, nor do they influence program
  *    operation (no abends). 
  *    
  *    <p>    Some schools of thought (Test Driven Development) actually advocate writing 
  *    assertions prior to writing code that actually needs to be tested. In this approach 
  *    one first codes "tests" that will fail before writing the code that will make the
  *    "tests" pass.
  *
  *    <p>    For handling log messages some kind of script or utility
  *    to scan the SAS run log after program completion could be used to provide
  *    a summary report of assertion test results.
  *    <p>    In a Linux/Unix environment this could be as simple as:
  *       
  *    <p>    grep ^\#ASSERTION {log_file_name.log}
  *
  *    <p>    A SAS macro for reporting("reports"), can additionally be called at the end
  *       of a job, which will produce a summary report of all assertions tested during the 
  *       the job run. The report will be found in the same directory as that assigned
  *       for holding the SAS run-log. The report file name is "assertion_results.html".
  *    
  *
  *       <p><p>You can suppress this documentation in the log by setting option 
  *       nomprint prior to %including this library.
  */
/**
  * Find the log path for reporting.
  */
%macro find_log_for_run();
     %local __log_path_file
	        __log_path_scan
            __full_length
            __scan_length
            __remaining_length
			;
     %let __log_path_file=%sysfunc(getoption(log));
	 %if %length(&__log_path_file)>1 %then %do;
	     %let __log_path_scan=%scan(&__log_path_file,-1,/);
	     %let __full_length=%length(&__log_path_file);
	     %let __scan_length=%length(&__log_path_scan);
	     %let __remaining_length=%eval(&__full_length-&__scan_length);
	     %let __final_path=%substr(&__log_path_file,1,&__remaining_length);
     %end; 
 %mend find_log_for_run;
 %find_log_for_run();
/**
  * Add Functions Table into options
  */
options cmplib=work.a&SYSJOBID;
/*
 * Generate the assertion results dataset function
 */
proc fcmp outlib = work.a&SYSJOBID..functions;
        function result_init(_assertion_dataset $, _job_description $,_assert_id $, _message $,_assert_when $, _status $);
            rc = run_macro('assertion_data', _assertion_dataset, _job_description ,_assert_id, _message,_assert_when, _status);
            return(rc);
        endsub;
        function result_updt(_assertion_dataset $, _assert_id $, _status $);
            rc = run_macro('assertion_data_update', _assertion_dataset, _assert_id, _status);
            return(rc);
        endsub;
run;
/**
  *
  *        Returns the string "label" for a specified dataset.
  *		      <p>Can be called inside a datastep  
  *
  *    @author  Chris Amendola
  *    @created    04-2015
  *
  * @param  _dset   Fully specified (libname.dataset) SAS dataset   default:
  * @return Text of the Dataset label
  *
  */                
%macro get_data_label(_dset);
   
    %local dsid  
	       set_label
		   rc;

    %let dsid = %sysfunc(open(&_dset));
    %if &dsid = 0 %then %put %sysfunc(sysmsg());
    %let set_label = %sysfunc(attrc(&dsid,label));
    %let rc = %sysfunc(close(&dsid));
    %if &rc ne 0 %then %put %sysfunc(sysmsg());
    
	&set_label

%mend get_data_label;				
/**
  *  HTML Report Template for Assertion Results
  *
  *        @author Chris Amendola	
  *        @created 10-2015  
  *
  * @param table Name of assertion table
  */ 
%macro html_section_a(table,_title1);
	options nomprint;
   
	  %local _scenario;
		%let _scenario= %get_data_label(&table);
		%let time_stamp=%sysfunc(time(),timeampm.); 
		%let date_stamp=%sysfunc(date(),worddate.); 	
		
		ods proclabel "Scenario -> %trim(&_scenario) ";
		title "&_title1";
		title2 "%eval(&__assertion_increment-&__assertion_fail_count) out of &__assertion_increment Tests Passed ";
		title3 "Last Run: ";
		title4 "&date_stamp - &time_stamp";
		title5 "By: &SYSUSERID";
	  title6 "&_scenario:";
        proc report data=&table nowd;
            column assert_id 
			       assert_when
			       message
				   status;
            define assert_id / width=100 display;
            define assert_when / width=100 display;
            define message / width=100 display;
            define status / width=20 display;
            compute status;
                if upcase(status) eq "FAIL" then call define(_col_,"style","style={background=red}");
		        else if upcase(status) eq "WARN" then call define(_col_,"style","style={background=orange}");
		        else call define(_col_,"style","style={background=green}");
            endcomp;
			where length(assert_id)>1;
        run;			
	
%mend html_section_a;
/**
  *	HTML Report Generator
  *
  *        @author Chris Amendola	
  *        @created 10-2015
  */
%macro reports(locate=&__final_path.,test_scenario=&SYSPROCESSNAME.,report_label=assertion_results.html);	 
    options nomprint;
    %if %symglobl(assertions_mode) = 1 %then %do; 	
    	%if %upcase(&assertions_mode) eq ON %then %do;
    
    	    ods html path =  "&locate" (url=none)
	                 body = "&report_label"
                     style = styles.sansPrinter; 
		
	        %html_section_a(work.assertion_results,&test_scenario)
			
            ods html close;
			proc sql noprint;
			    drop table work.a&SYSJOBID;
			quit;
        %end;
    %end;
    
%mend reports;
/** 
  *         Generates an event message in the log if the assertion fails.
  *         User can optionally add detail to the log message.
  *         Only excecutes assertion evaluation if global macro variable 
  *         "assertions_mode" exists and is set to "ON"
  *
  *        @author Chris Amendola	
  *        @created 10-2015
  *
  * @param     assertion       Conditional to evaluate
  * @param     message         Optional Report Message
  * @param     when            Optional "extra" condition for assertions, must be true to test assertion
  */
%macro assert( assertion
              ,when
    	      ,message=
              );
    /**
      * Want to check for increment variable in global namespace
      */
    %local  __mprint_setting
            _assert_var
            _when_message
            ;
            
    %if %length(&when) gt 1 %then %let _when_message=WHEN &when THEN;
    %else %let _when_message=;
    /**
      * Capture current mprint settings to reset on way out
      */	  
    %let __mprint_setting=%sysfunc(getoption(Mprint));
	  
	options nomprint;
	
    %if %symglobl(assertions_mode) = 1 %then %do; 	
    	%if %upcase(&assertions_mode) eq ON %then %do;
    		%if %length( %str(&assertion) ) lt 1 %then %do;
	            %put ###WARNING: No assertion statement to evaluate- &message.!!;
            %end;	
	        %else %do;
	        	%let __assertion_increment=%eval(&__assertion_increment+1);
	        	%let _assert_var=_assertion_&__assertion_increment;
            
	        	retain &_assert_var "----";
	        	
	        	if &_assert_var eq "----" then do;
	            	&_assert_var = "INIT";
	            	x=result_init( "work.assertion_results"
                                  ,"Job/Session Assertion Report" 
                                  ,"&_assert_var"
                                  ,"&message" 
                                  ,"&_when_message &assertion" 
                                  ,"PASS" ) ;
                end;   
                
	            if &_assert_var ne "FAIL" then do;
	            	%if %length(&when) gt 1 %then if (&when) then;
	            	if &assertion then &_assert_var = "PASS";
					else do;	
					    /**
					      * Assertion Failure counter to report some kind of overall pass/fail count
					      */
					    call symput("__assertion_fail_count",(symget("__assertion_fail_count")+1));
					    &_assert_var="FAIL";
	            	    put "***";
	            	    put "#Assertion: %superq(_when_message) %superq(assertion) {&message} FAILED!!!!";
	             	    put "***";
	             	    put "Fail Record: " _all_;
	             	    x=result_updt("work.assertion_results", "&_assert_var", "FAIL");
	             	    drop x;
					end;	
	            end;
	            drop &_assert_var;
            %end;
        %end;
    %end;			   	
	
	options &__mprint_setting;
	
%mend assert;
/** 
  *    Initializes the assertion test results dataset.   
  *
  *        @author Chris Amendola	
  *        @created 
  *
  * @param     
  * @param     
  * @param     
  */
%macro assertion_data;
	
	options nomprint;
	
	%let _assertion_dataset= %sysfunc(dequote(&_assertion_dataset));   
	
	data &_assertion_dataset(label= &_job_description
	                         keep=assert_id 
	                              assert_when
	                              message
		         	              status 
						         );
	    attrib       assert_id   length=$100 
                     assert_when length=$2000
                     message     length=$2000
                     status      length=$15
		     	  
               ;
		%if %sysfunc(exist(&_assertion_dataset)) %then %do;   
            modify &_assertion_dataset;               
	        assert_id=&_assert_id;
	        assert_when=&_assert_when;
	        message=&_message;
	        status=&_status;
			output;
			stop;
        %end;
    run;
	
%mend assertion_data;
/** 
  *    Adds test results outcomes data to assertions result dataset
  *
  *        @author Chris Amendola	
  *        @created 
  *
  * @param     
  * @param     
  * @param     
  */
%macro assertion_data_update;
	
	options nomprint;
	
	%let _assertion_dataset= %sysfunc(dequote(&_assertion_dataset));   
	
	data &_assertion_dataset;
		%if %sysfunc(exist(&_assertion_dataset)) %then %do;   
            modify &_assertion_dataset(where=(assert_id=&_assert_id));                   
	            status=&_status;
        %end;
    run;
%mend assertion_data_update;

/** 
  * Assertion Facility Macro-variables inserted into global namespace
  */
%global assertions_mode
        __assertion_increment
        __assertion_fail_count;       
/**
  * Testing completed
  */
    /**
      * Intializing for rest of session
      */
     %let assertions_mode=ON;
     %let __assertion_increment=0;
     %let __assertion_fail_count=0;
    data _null_;
	   if exist("work.assertion_results") then
	       call execute("proc sql; drop table work.assertion_results; quit;");
	run;
    data _null_;
        x=result_init("work.assertion_results","Job/Session Assertion Report" ,"" ,"" ,"" ,"" ); 
    run; 
    
