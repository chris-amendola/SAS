options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 );
/*!
 *  Unit test package for check_argument macro.
 *
 *     @author Chris Amendola
 *     @created May 15 2016
 */ 
/**
  * Unit Test Tools
  */
   %include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";
   
/**
  * Macro under testing
  */
  %include "Y:\Users\camendol\SAS_ETL_dev\support_lib\obs.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

/* 10 Obs Dataset */
data work.obs10b;
  do i=1 to 10;
    x=i;
    output;
  end;
run;

/* 5 obs Dataset */
data work.obs5;
  do i = 1 to 5;
    x=1;
    output;
  end;
run;

data _null_;
  %assert( (%obs(work.obs10b)=10)
          ,message=OBS Count=10)
  %assert( (not(%obs(work.obs5)=10))
          ,message=OBS Count not equal 10)
  %assert ( (%obs(work.obs5)^=10)
          ,message=OBS Count not equal 10)
run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=obs Testing
         ,report_label=obs.html);
