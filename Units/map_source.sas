ptions sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 );
/*
 * Unit Test Tools
 */
%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\map_source.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

%read_map_spec(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_mapx.dlm)

data work._TEST_(drop=test_num_src test_chr_src);
  /*%generate_attrib_ded();*/
  test_num_src=5;
  test_chr_src="XXXXX";
  %map_source();
  %assert( (test_numeric=5)
          ,message=Test Mapped Numeric value is 5)
  %assert ( (test_char='XXXXX')
           ,message=Test Mapped Character value is 'XXXXX')
  %assert( (test_raw_chr='This is a raw setting')
          ,message=Raw character value is 'This is a raw setting')
  %assert( (test_raw_num=5)
          ,message=Raw numeric value is 5)
  %assert( (test_null_chr="")
          ,message=Null character value check)
  %assert( (test_null_num=.)
          ,message=Null numeric value check)
run;

/*
%assert( (assertion)
        ,(when)
        ,message=)
*/
%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports
         ,test_scenario=map_source Testing
         ,report_label=map_source.html);
