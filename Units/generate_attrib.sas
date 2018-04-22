/*! generate_input Unit Tests */
options sasautos=(sasautos             
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
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
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\generate_attrib.sas";

%read_schema(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema.dlm)

/*
 * Call macro under testing
 */
options mprint;
data work._TEST_;
  %generate_attrib()
run;
/* Test the attrib statement through contents of the created dataset */
proc contents data=work._TEST_
               out=work._CONTS_
			   noprint;
run;
data _null_;
  %assert( (type=2)
          ,(name='test_char')
          ,message=Correct type for vartest_char )
  %assert( (length=20)
          ,(name='test_char')
          ,message=Correct length for vartest_char )
  %assert( (format='$')
          ,(name='test_char')
          ,message=Correct format for vartest_char )
  %assert( (formatl=20) 
          ,(name='test_char') 
          ,message=Correct formatl for var test_char)
  %assert( (type=2)
          ,(name='test_null_char')
          ,message=Correct type for vartest_null_char )
  %assert( (length=20)
          ,(name='test_null_char')
          ,message=Correct length for vartest_null_char )
  %assert( (format='$')
          ,(name='test_null_char')
          ,message=Correct format for vartest_null_char )
  %assert( (formatl=20) 
          ,(name='test_null_char') 
          ,message=Correct formatl for var test_null_char)
  %assert( (type=1)
          ,(name='test_null_num')
         ,message=Correct type for vartest_null_num )
  %assert( (length=8)
          ,(name='test_null_num')
          ,message=Correct length for vartest_null_num )
  %assert( (format='')
          ,(name='test_null_num')
          ,message=Correct format for vartest_null_num )
  %assert( (formatl=0) 
          ,(name='test_null_num') 
          ,message=Correct formatl for var test_null_num)
  %assert( (type=1)
          ,(name='test_numeric')
          ,message=Correct type for vartest_numeric )
  %assert( (length=8)
          ,(name='test_numeric')
          ,message=Correct length for vartest_numeric )
  %assert( (format='')
          ,(name='test_numeric')
          ,message=Correct format for vartest_numeric )
  %assert( (formatl=0) 
          ,(name='test_numeric') 
          ,message=Correct formatl for var test_numeric)
  %assert( (type=2)
          ,(name='test_raw_chr')
          ,message=Correct type for vartest_raw_chr )
  %assert( (length=20)
          ,(name='test_raw_chr')
          ,message=Correct length for vartest_raw_chr )
  %assert( (format='$')
          ,(name='test_raw_chr')
          ,message=Correct format for vartest_raw_chr )
  %assert( (formatl=20) 
          ,(name='test_raw_chr') 
          ,message=Correct formatl for var test_raw_chr)
  %assert( (type=1)
          ,(name='test_raw_num')
          ,message=Correct type for vartest_raw_num )
  %assert( (length=8)
          ,(name='test_raw_num')
          ,message=Correct length for vartest_raw_num )
  %assert( (format='')
          ,(name='test_raw_num')
          ,message=Correct format for vartest_raw_num )
  %assert( (formatl=0) 
          ,(name='test_raw_num') 
          ,message=Correct formatl for var test_raw_num)

run;

/*
%assert( (assertion)
        ,(when)
        ,message=)
*/
%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=generate_attrib Testing
         ,report_label=generate_attrib.html);
