/*! read_raw_cclf Unit Tests */
options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'               
                 );
/*!
 *  Unit test package for read_schema.
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
  %include "Y:\Users\camendol\SAS_ETL_dev\support_lib\read_schema.sas";
/**
  * Generate test schema.
  */
filename outfile 'Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema.dlm' 
         encoding="utf-8";                                                                                             

data _null_;                                                                    
   file outfile;                                                                                                     
   put "# Layout Variable Name , Informat , incoming length , format , variable label, transform";
   put "Age|$8.|8||||";
   put "DOB|yymmdd10.|10|YYMMDD10.||x=1;|";
   put "EffectiveDt|YYMMDD10.|10|yymmdd10.|||";
   put "income_txt|$char6.|6|||length income 8;income=put(income_txt,8.);|";
   put "MemberID|$8.|8||||";
   put "Plan|$18.|18||||";
   put "Sex|$1.|1|||||";
   put "TermDt|yymmdd10.|10|YYMMDD10.|||";
   put 'ZipCode|$5.|5|||y=2;|';
run;
  
/* Get rid of existing metadata */
proc sql noprint;
  drop table work.metadata;

%read_schema(Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\test_schema.dlm)

proc sql noprint;
  select "'"||strip(name)||"'" into :_var_list separated by "," from work.metadata;
quit;

/* Check if metadata file was created */
%let _for_itid=%sysfunc(open(work.metadata));

/* Verify sort order is by order_number */
%let _sort_key=%sysfunc(attrc(&_for_itid,sortedby));

data _null_;
  set work.metadata;
  /* Demonstrate metadata exists */
  exist=&_for_itid;
  %assert( (exist>0)
          ,message=Metadata created)

  /* Test  sort order is by order_number */
  sort_order="&_sort_key";
  %assert( (sort_order='order_number')
          ,message= Sort order by order_number)

  /* Test no variables added */
  %assert( (name in (&_var_list))
           ,message=No un-expected vars in metadata)

  /* Test if all variables found. */
  test_list="&_var_list";
  pass_list="'Age','DOB','EffectiveDt','income_txt','MemberID','Plan','Sex','TermDt','ZipCode'";
  %assert( (test_list=pass_list)
          ,message=All expected vars found)
  
  /* Check attributes for incoming var Age*/ 
  %assert( (informat='$8.')
          ,(name='Age')
          ,message=Correct informat for var Age)
  %assert( (inc_len='8')
          ,(name='Age')
          ,message=Correct incoming length for var Age)
  /* Check attributes for incoming var DOB*/ 
  %assert( (informat='yymmdd10.')
          ,(name='DOB')
          ,message=Correct informat for var DOB)
  %assert( (inc_len='10')
          ,(name='DOB')
          ,message=Correct incoming length for var DOB)
  /* Check attributes for incoming var EffectiveDt*/   
  %assert( (informat='YYMMDD10.')
          ,(name='EffectiveDt')
          ,message=Correct informat for var EffectiveDt)
  %assert( (inc_len='10')
          ,(name='EffectiveDt')
          ,message=Correct incoming length for var EffectiveDt)
  /* Check attributes for incoming var Income*/ 
  %assert( (informat='17.2')
          ,(name='Income')
          ,message=Correct informat for var Income)
  %assert( (inc_len='17')
          ,(name='Income')
          ,message=Correct incoming length for var Income)
  /* Check attributes for incoming var MemberID*/ 
  %assert( (informat='$8.')
          ,(name='MemberID')
          ,message=Correct informat for var MemberID)
  %assert( (inc_len='8')
          ,(name='MemberID')
          ,message=Correct incoming length for var MemberID)
  /* Check attributes for incoming var Plan*/ 
  %assert( (informat='$18.')
          ,(name='Plan')
          ,message=Correct informat for var Plan)
  %assert( (inc_len='18')
          ,(name='Plan')
          ,message=Correct incoming length for var Plan)
  /* Check attributes for incoming var Sex*/ 
  %assert( (informat='$1.')
          ,(name='Sex')
          ,message=Correct informat for var Sex)
  %assert( (inc_len='1')
          ,(name='Sex')
          ,message=Correct incoming length for var Sex)
  /* Check attributes for incoming var TermDt*/ 
  %assert( (informat='yymmdd10.')
          ,(name='TermDt')
          ,message=Correct informat for var TermDt)
  %assert( (inc_len='10')
          ,(name='TermDt')
          ,message=Correct incoming length for var TermDt)
  /* Check attributes for incoming var ZipCode*/ 
  %assert( (informat='$5.')
          ,(name='ZipCode')
          ,message=Correct informat for var ZipCode)
  %assert( (inc_len='5')
           ,(name='ZipCode')
           ,message=Correct incoming length for var ZipCode)
  /* Check Order Number for each var */
  %assert( (order_number='1')
          ,(name='Age')
          ,message=Correct order_number for var Age)
  %assert( (order_number='2')
          ,(name='DOB')
          ,message=Correct order_number for var DOB)
  %assert( (order_number='3')
          ,(name='EffectiveDt')
          ,message=Correct order_number for var EffectiveDt)
  %assert( (order_number='4')
          ,(name='Income')
          ,message=Correct order_number for var Income)
  %assert( (order_number='5')
          ,(name='MemberID')
          ,message=Correct order_number for var MemberID)
  %assert( (order_number='6')
          ,(name='Plan')
          ,message=Correct order_number for var Plan)
  %assert( (order_number='7')
          ,(name='Sex')
          ,message=Correct order_number for var Sex)
  %assert( (order_number='8')
          ,(name='TermDt')
          ,message=Correct order_number for var TermDt)
  %assert( (order_number='9')
          ,(name='ZipCode')
          ,message=Correct order_number for var ZipCode)
run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=read_schema Testing
         ,report_label=read_schema.html);
