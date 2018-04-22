/*! generate_input Unit Tests */
options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 );
/*!
 *  Unit test package for generate_input
 *
 *     @author Chris Amendola
 *     @created July 7th 2017
 */ 
/**
  * Unit Test Tools
  */
%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\generate_format.sas";

%read_schema(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema.dlm)

%macro encapsulate_it();
  %let _test=%generate_format();
  %put &_test;
  data _null_;
  test_string="&_test";

  %assert( (test_string='format           DOB YYMMDD10.                                  EffectiveDt yymmdd10.                                  TermDt 
YYMMDD10.                          ;;')
           ,message=Format statement matches expected)
run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=generate_format Testing
         ,report_label=generate_format.html);

%mend encapsulate_it;
%encapsulate_it();
