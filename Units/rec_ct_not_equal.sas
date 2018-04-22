/* Bring in necessary Support Modules */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\isblank.sas";
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\check_argument.sas";
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\mac_map.sas";
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\obs.sas";
/*
 * Unit Test Tools
 */
%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\user_lib\rec_ct_not_equal.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

/* 10 Obs Dataset */
data work.obs10a;
  do i = 1 to 10;
    x=1;
    output;
  end;
run;

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

data work._view_results;

  attrib test_val length=$200;

  test_val="%rec_ct_not_equal(work.obs10a,work.obs10b)";
  %let _message_text=%rec_ct_not_equal(work.obs10a,work.obs10b);
  %assert( (length(test_val)<2)
          ,message=NO RETURN CODE);

  if length(test_val)>1 then put test_val;

  test_val="%rec_ct_not_equal(work.obs10a,work.obs5)";
  %let _message_text=%rec_ct_not_equal(work.obs10a,work.obs5);
  %assert( (length(test_val)>1)
          ,message=&_message_text);

  if length(test_val)>1 then put test_val;

run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=rec_ct_not_equal Testing
         ,report_label=rec_ct_not_equal.html);

