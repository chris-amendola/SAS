%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
/**
  * Macro under testing
  */
%include "\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\isblank.sas";

%let _intialized=VALUE;
%let _null=;


data _null_;
  %assert( (not(%isblank(_intialized)))
           ,message= Intialized macro variable is not blank.)
  %assert( (%isblank(_null)),
          ,message=Un-intialized macro variable is blank.)
run;

%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
          ,test_scenario=isblank Testing
         ,report_label=isblank.html); 
