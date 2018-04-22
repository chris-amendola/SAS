/*! read_raw_cclf Unit Tests */
options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 );
/*!
 *  Unit test package for read_raw_cclf.
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
  %include "Y:\Users\camendol\SAS_ETL_dev\user_lib\read_pos.sas";

/**
  * Test Call.
  */
options mprint;  
%read_pos( infile=Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\raw_pos_data.txt
          ,to_dataset=work.test_data
          ,schema=Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema2.dlm);

/* Check if dataset file was created */
%let _for_itid=%sysfunc(open(work.test_data));

proc contents data=work.test_data
               out=work._test_conts_
              noprint;
run;
proc sql ;
  select "'"||strip(name)||"'" into :_var_list separated by "," from work._test_conts_;
quit;

data _null_;
  attrib test_list length=$1000;
  set work._test_conts_;

  /* Demonstrate output dataset exists */
  exist=&_for_itid;
  %assert( (exist>0)
          ,message=Dataset created.)

  /* Test no variables added */
  %assert( (name in ('Age','DOB','EffectiveDt','MemberID','Plan','Sex','TermDt','ZipCode','check_DT0','income','income_txt','source_file','tilde_check'))
           ,message=No un-expected vars in metadata)

  /* Test if all variables found. */
  test_list="&_var_list";
  pass_list="'Age','DOB','EffectiveDt','MemberID','Plan','Sex','TermDt','ZipCode','check_DT0','income','income_txt','source_file','tilde_check'";
  %assert( (test_list=pass_list)
          ,message=All expected vars found)
  
  /* Check attributes for incoming var Age */;
  %assert( (length=2),(name='Age'),message=Correct length for var Age )
  %assert( (format=''),(name='Age'),message=Correct format for var Age )
  %assert( (type=2),(name='Age'),message=Correct type for var Age )
  %assert( (label='') ,(name='Age') ,message=Correct label for var Age)
  %assert( (formatl='0'),(name='Age') ,message=Correct format length for var Age )
  /* Check attributes for incoming var DOB */;
  %assert( (length=8),(name='DOB'),message=Correct length for var DOB )
  %assert( (format='YYMMDD'),(name='DOB'),message=Correct format for var DOB )
  %assert( (type=1),(name='DOB'),message=Correct type for var DOB )
  %assert( (label='') ,(name='DOB') ,message=Correct label for var DOB)
  %assert( (formatl='10'),(name='DOB') ,message=Correct format length for var DOB )
  /* Check attributes for incoming var EffectiveDt */;
  %assert( (length=8),(name='EffectiveDt'),message=Correct length for var EffectiveDt )
  %assert( (format='YYMMDD'),(name='EffectiveDt'),message=Correct format for var EffectiveDt )
  %assert( (type=1),(name='EffectiveDt'),message=Correct type for var EffectiveDt )
  %assert( (label='') ,(name='EffectiveDt') ,message=Correct label for var EffectiveDt)
  %assert( (formatl='10'),(name='EffectiveDt') ,message=Correct format length for var EffectiveDt )
  /* Check attributes for incoming var MemberID */;
  %assert( (length=8),(name='MemberID'),message=Correct length for var MemberID )
  %assert( (format=''),(name='MemberID'),message=Correct format for var MemberID )
  %assert( (type=2),(name='MemberID'),message=Correct type for var MemberID )
  %assert( (label='') ,(name='MemberID') ,message=Correct label for var MemberID)
  %assert( (formatl='0'),(name='MemberID') ,message=Correct format length for var MemberID )
  /* Check attributes for incoming var Plan */;
  %assert( (length=18),(name='Plan'),message=Correct length for var Plan )
  %assert( (format=''),(name='Plan'),message=Correct format for var Plan )
  %assert( (type=2),(name='Plan'),message=Correct type for var Plan )
  %assert( (label='') ,(name='Plan') ,message=Correct label for var Plan)
  %assert( (formatl='0'),(name='Plan') ,message=Correct format length for var Plan )
  /* Check attributes for incoming var Sex */; 
  %assert( (length=1),(name='Sex'),message=Correct length for var Sex )
  %assert( (format=''),(name='Sex'),message=Correct format for var Sex )
  %assert( (type=2),(name='Sex'),message=Correct type for var Sex )
  %assert( (label='') ,(name='Sex') ,message=Correct label for var Sex)
  %assert( (formatl='0'),(name='Sex') ,message=Correct format length for var Sex )
  /* Check attributes for incoming var TermDt */;
  %assert( (length=8),(name='TermDt'),message=Correct length for var TermDt )
  %assert( (format='YYMMDD'),(name='TermDt'),message=Correct format for var TermDt )
  %assert( (type=1),(name='TermDt'),message=Correct type for var TermDt )
  %assert( (label='') ,(name='TermDt') ,message=Correct label for var TermDt)
  %assert( (formatl='10'),(name='TermDt') ,message=Correct format length for var TermDt )
  /* Check attributes for incoming var ZipCode */;
  %assert( (length=5),(name='ZipCode'),message=Correct length for var ZipCode )
  %assert( (format=''),(name='ZipCode'),message=Correct format for var ZipCode )
  %assert( (type=2),(name='ZipCode'),message=Correct type for var ZipCode )
  %assert( (label='') ,(name='ZipCode') ,message=Correct label for var ZipCode)
  %assert( (formatl='0'),(name='ZipCode') ,message=Correct format length for var ZipCode )
  /* Check attributes for incoming var check_DT */;
  %assert( (length=8),(name='check_DT'),message=Correct length for var check_DT )
  %assert( (format='YYMMDD'),(name='check_DT'),message=Correct format for var check_DT )
  %assert( (type=1),(name='check_DT'),message=Correct type for var check_DT )
  %assert( (label='') ,(name='check_DT') ,message=Correct label for var check_DT)
  %assert( (formatl='10'),(name='check_DT') ,message=Correct format length for var check_DT )
  /* Check attributes for incoming var check_DT0 */;
  %assert( (length=10),(name='check_DT0'),message=Correct length for var check_DT0 )
  %assert( (format=''),(name='check_DT0'),message=Correct format for var check_DT0 )
  %assert( (type=2),(name='check_DT0'),message=Correct type for var check_DT0 )
  %assert( (label='') ,(name='check_DT0') ,message=Correct label for var check_DT0)
  %assert( (formatl='0'),(name='check_DT0') ,message=Correct format length for var check_DT0 )
  /* Check attributes for incoming var income */;
  %assert( (length=8),(name='income'),message=Correct length for var income )
  %assert( (format=''),(name='income'),message=Correct format for var income )
  %assert( (type=1),(name='income'),message=Correct type for var income )
  %assert( (label='') ,(name='income') ,message=Correct label for var income)
  %assert( (formatl='0'),(name='income') ,message=Correct format length for var income )
  /* Check attributes for incoming var income_txt */;
  %assert( (length=6),(name='income_txt'),message=Correct length for var income_txt )
  %assert( (format=''),(name='income_txt'),message=Correct format for var income_txt )
  %assert( (type=2),(name='income_txt'),message=Correct type for var income_txt )
  %assert( (label='') ,(name='income_txt') ,message=Correct label for var income_txt)
  %assert( (formatl='0'),(name='income_txt') ,message=Correct format length for var income_txt )
  /* Check attributes for incoming var mssp_num */;
  %assert( (length=5),(name='mssp_num'),message=Correct length for var mssp_num )
  %assert( (format=''),(name='mssp_num'),message=Correct format for var mssp_num )
  %assert( (type=2),(name='mssp_num'),message=Correct type for var mssp_num )
  %assert( (label='') ,(name='mssp_num') ,message=Correct label for var mssp_num)
  %assert( (formatl='0'),(name='mssp_num') ,message=Correct format length for var mssp_num )
  /* Check attributes for incoming var raw_source_file */;
  %assert( (length=75),(name='raw_source_file'),message=Correct length for var raw_source_file )
  %assert( (format=''),(name='raw_source_file'),message=Correct format for var raw_source_file )
  %assert( (type=2),(name='raw_source_file'),message=Correct type for var raw_source_file )
  %assert( (label='') ,(name='raw_source_file') ,message=Correct label for var raw_source_file)
  %assert( (formatl='0'),(name='raw_source_file') ,message=Correct format length for var raw_source_file )
  /* Check attributes for incoming var raw_source_file_long */;
  %assert( (length=400),(name='raw_source_file_long'),message=Correct length for var raw_source_file_long )
  %assert( (format=''),(name='raw_source_file_long'),message=Correct format for var raw_source_file_long )
  %assert( (type=2),(name='raw_source_file_long'),message=Correct type for var raw_source_file_long )
  %assert( (label='') ,(name='raw_source_file_long') ,message=Correct label for var raw_source_file_long)
  %assert( (formatl='0'),(name='raw_source_file_long') ,message=Correct format length for var raw_source_file_long )
  /* Check attributes for incoming var source_file_month */;
  %assert( (length=7),(name='source_file_month'),message=Correct length for var source_file_month )
  %assert( (format=''),(name='source_file_month'),message=Correct format for var source_file_month )
  %assert( (type=2),(name='source_file_month'),message=Correct type for var source_file_month )
  %assert( (label='') ,(name='source_file_month') ,message=Correct label for var source_file_month)
  %assert( (formatl='0'),(name='source_file_month') ,message=Correct format length for var source_file_month )
  /* Check attributes for incoming var source_file_type */;
  %assert( (length=5),(name='source_file_type'),message=Correct length for var source_file_type )
  %assert( (format=''),(name='source_file_type'),message=Correct format for var source_file_type )
  %assert( (type=2),(name='source_file_type'),message=Correct type for var source_file_type )
  %assert( (label='') ,(name='source_file_type') ,message=Correct label for var source_file_type)
  %assert( (formatl='0'),(name='source_file_type') ,message=Correct format length for var source_file_type )
  /* Check attributes for incoming var tilde_check */;
  %assert( (length=1),(name='tilde_check'),message=Correct length for var tilde_check )
  %assert( (format=''),(name='tilde_check'),message=Correct format for var tilde_check )
  %assert( (type=2),(name='tilde_check'),message=Correct type for var tilde_check )
  %assert( (label='') ,(name='tilde_check') ,message=Correct label for var tilde_check)
  %assert( (formatl='0'),(name='tilde_check') ,message=Correct format length for var tilde_check )
run;

%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports
         ,test_scenario=read_pos Testing
         ,report_label=read_pos.html);
