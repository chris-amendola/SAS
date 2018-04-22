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
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\generate_input.sas";

%read_schema(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema.dlm)

%macro encapsulate_it();
  %let _test=%generate_input();
  %put &_test;
  data _null_;
  test_string="&_test";

  %assert( (test_string='input    @1 Age $8.    @9 DOB yymmdd10.    @19 EffectiveDt YYMMDD10.    @29 income_txt $char6.    @35 MemberID $8.    @43 Plan $18. 
   @61 Sex $1.    @62 TermDt yymmdd10.    @72 ZipCode $5.   ;;')
           ,message=Input statement matches expected)
run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports
         ,test_scenario=generate_input Testing
         ,report_label=generate_input.html);

%mend encapsulate_it;
%encapsulate_it();
