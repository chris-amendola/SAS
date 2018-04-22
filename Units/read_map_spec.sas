/* Bring in necessary Support Modules */
options sasautos=(sasautos
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
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\read_map_spec.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";
/**
  * Generate test schema.
  */
filename outfile 'Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_mapx.dlm' 
         encoding="utf-8";   

data _null_; 
   /*name length format map_source transform description*/ 
   file outfile;                                                                                                     
   put "#Comment Line 1";
   put "test_numeric|8||test_num_src|test_numeric=test_numeric+1;|description numeric|";
   put "test_char|$20|$20.|test_chr_src|test_char=substr(test_char,1,5);|description character|";
   put "#Comment Line 2";
   put "test_raw_chr|$21|$21.|'''This is a raw setting'''||Raw value setting character|";
   put "test_raw_num|8||5||Raw value setting numeric|";
   put "test_null_char|$20|$20.|||Null Value Character|";
   put "test_null_num|8||||Null value Numeric|";
run;

/* Get rid of existing metadata */
proc sql noprint;
  drop table work.map_spec;

%read_map_spec(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_mapx.dlm)

proc sql noprint;
  select "'"||strip(name)||"'" into :_var_list separated by "," from work.map_spec;
quit;

%put &_var_list;

/* Check if metadata file was created */
%let _for_itid=%sysfunc(open(work.map_spec));
data _null_;
  set work.map_spec;
/* Demonstrate metadata exists */
  exist=&_for_itid;
  %assert( (exist>0)
          ,message=Metadata created)

  /* Test no variables added */
  %assert( (name in (&_var_list))
           ,message=No un-expected vars in metadata)

  /* Test if all variables found. */
  test_list="&_var_list";
  pass_list="'test_numeric','test_char','test_raw_chr','test_raw_num','test_null_char','test_null_num'";
  %assert( (test_list=pass_list)
          ,message=All expected vars found)
  
  /* Check attributes for incoming vars*/ 
  /* Units for each variable
  %assert( (length='')
          ,(name='')
          ,message=Correct length for var )
  %assert( (format='')
          ,(name='')
          ,message=Correct format for var )
  %assert( (map_source='')
          ,(name='')
          ,message=Correct map_source for var )
  %assert( (tranform='')
          ,(name='')
          ,message=Correct transform for var )
  %assert( (description='')
          ,(name='')
          ,message=Correct description for var )
  */
  %assert( (length='8')
          ,(name='test_numeric')
          ,message=Correct length for vartest_numeric )
  %assert( (format='')
          ,(name='test_numeric')
          ,message=Correct format for vartest_numeric )
  %assert( (map_source='test_num_src')
          ,(name='test_numeric')
          ,message=Correct map_source for vartest_numeric )
  %assert( (tranform='') 
          ,(name='test_numeric') 
          ,message=Correct transform for var test_numeric)
  %assert( (description='description numeric')
          ,(name='test_numeric') 
          ,message=Correct description for var test_numeric )
  %assert( (length='$20')
          ,(name='test_char')
          ,message=Correct length for vartest_char )
  %assert( (format='$20.')
          ,(name='test_char')
          ,message=Correct format for vartest_char )
  %assert( (map_source='test_chr_src')
          ,(name='test_char')
          ,message=Correct map_source for vartest_char )
  %assert( (tranform='') 
          ,(name='test_char') 
          ,message=Correct transform for var test_char)
  %assert( (description='description character')
          ,(name='test_char') 
          ,message=Correct description for var test_char )
  %assert( (length='$21')
          ,(name='test_raw_chr')
          ,message=Correct length for vartest_raw_chr )
  %assert( (format='$21.')
          ,(name='test_raw_chr')
          ,message=Correct format for vartest_raw_chr )
  %assert( (map_source='''This is a raw setting''')
          ,(name='test_raw_chr')
          ,message=Correct map_source for vartest_raw_chr )
  %assert( (tranform='') 
          ,(name='test_raw_chr') 
          ,message=Correct transform for var test_raw_chr)
  %assert( (description='Raw value setting character')
          ,(name='test_raw_chr') 
          ,message=Correct description for var test_raw_chr )
  %assert( (length='8')
          ,(name='test_raw_num')
          ,message=Correct length for vartest_raw_num )
  %assert( (format='')
          ,(name='test_raw_num')
          ,message=Correct format for vartest_raw_num )
  %assert( (map_source='5')
          ,(name='test_raw_num')
          ,message=Correct map_source for vartest_raw_num )
  %assert( (tranform='') 
          ,(name='test_raw_num') 
          ,message=Correct transform for var test_raw_num)
  %assert( (description='Raw value setting numeric')
          ,(name='test_raw_num') 
          ,message=Correct description for var test_raw_num )
  %assert( (length='$20')
          ,(name='test_null_char')
          ,message=Correct length for vartest_null_char )
  %assert( (format='$20.')
          ,(name='test_null_char')
          ,message=Correct format for vartest_null_char )
  %assert( (map_source='')
          ,(name='test_null_char')
          ,message=Correct map_source for vartest_null_char )
  %assert( (tranform='') 
          ,(name='test_null_char') 
          ,message=Correct transform for var test_null_char)
  %assert( (description='Null Value Character')
          ,(name='test_null_char') 
          ,message=Correct description for var test_null_char )
  %assert( (length='8')
          ,(name='test_null_num')
          ,message=Correct length for vartest_null_num )
  %assert( (format='')
          ,(name='test_null_num')
          ,message=Correct format for vartest_null_num )
  %assert( (map_source='')
          ,(name='test_null_num')
          ,message=Correct map_source for vartest_null_num )
  %assert( (tranform='') 
          ,(name='test_null_num') 
          ,message=Correct transform for var test_null_num)
  %assert( (description='Null value Numeric')
          ,(name='test_null_num') 
          ,message=Correct description for var test_null_num )
run;


%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports
         ,test_scenario=read_map_spec Testing
         ,report_label=read_map_spec.html);