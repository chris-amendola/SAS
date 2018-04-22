options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 );
/*!
 *  Unit test package for macro: .
 *
 *     @author 
 *     @created 
 */ 
/**
  * Unit Test Tools
  */
   %include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\{_mod_}.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

%assert( (assertion)
        ,(when)
        ,message=)

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario={_mod_} Testing
         ,report_label={_mod_}.html);
