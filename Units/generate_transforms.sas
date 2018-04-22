/*! generate_input Unit Tests */
options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 );
/*!
 *  Unit test package for generate_transforms
 *
 *     @author Chris Amendola
 *     @created July 8th 2017
 */ 
/**
  * Unit Test Tools
  */
%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\generate_transforms.sas";

%read_schema(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema.dlm)

%macro encapsulate_it();
  %let _test=%generate_transforms();
  %put -&_test.-;
  data _null_;
    test_string="&_test";
  
    %assert( (strip(test_string)='x=1;       length income 8;income=put(income_txt,8.);       y=2;   ;;')
            ,message=Generated transforms matche expected)
  run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=generate_transforms Testing
         ,report_label=generate_transforms.html);

%mend encapsulate_it;
%encapsulate_it();
