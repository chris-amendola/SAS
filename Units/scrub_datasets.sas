options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 );
/*!
 *  Unit test package for read_delm_files macro.
 *
 *     @author Chris Amendola
 *     @created Jan 17 2018
 */ 
/**
  * Unit Test Tools
  */
%include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\scrub_datasets.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

/* Create some datasets to drop*/
data testlib.junk1;
	x=1;
	output;
run;
data testlib.junk2;
	x=1;
	output;
run;

options mprint;
/* Run the scrubber */
  %scrub_datasets( lib=testlib
	                ,ds_list= junk1 junk2)
/* Are the datasets gone? */

data _null_;
	%assert( (not exist('testlib.junk1'))
            ,message=File testlib.junk1 deleted.)
	%assert( (not exist('testlib.junk2'))
            ,message=File testlib.junk2 deleted.)
run;

/*
%assert( (assertion)
        ,(when)
        ,message=)
*/

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=scrub_datasets Testing
         ,report_label=scrub_datasets.html);