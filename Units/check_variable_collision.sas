options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 );
/*!
 *  Unit test package for macro: .
 *
 *     @author   Sue and Chris
 *     @created 
 */ 
/**
  * Unit Test Tools
  */
   %include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";
   
/**
  * Macro under testing
  */
  %include "\\nasgw8315pn\dev\SAS_Dev_Workspace\SueS\trunk\SASApps\Macros\Prod\Check_Variable_Collision.sas";

  libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";
/**
  * Generate testing datasets.
  */
/* Currently only auto-test pass */
  data testlib.coll_test1;
    key1=1; 
    key2=1; 
    key3=1; 
    var1=1; 
    var2=2;
    output;
  run;
  data testlib.coll_test2;
    key1=1; 
    key2=1; 
    var1=1; 
    var2=2; 
    var3=1;
    output;
  run;
         
  data _null_;
    %assert( (0=1)
             , message=UNIT TESTS FAILED TO COMPLETE-CHECK LOG!!!);
  run;      
   
   /* This acts as a 'scrub' of the last report generated */
  %reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
           ,test_scenario=check_variable_collision Testing
           ,report_label=check_variable_collision.html);
   %include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";        

  %let sysrcc=0;
  %check_variable_collision( testlib.coll_test1
                            ,testlib.coll_test2
                            ,key_list=key1 key2
                            ,ignore_list=var1 var2);
                            
  %let simple_pass=&sysrcc.;
  
  data _null_;
  	
    %assert( (symget('simple_pass')=0)
             ,message=Simple Check Pass);      
             
  run;           

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=check_variable_collision Testing
         ,report_label=check_variable_collision.html);
