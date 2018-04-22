%include "Y:\Users\camendol\MSSP_DEV\units\testlib\unittest.sas";
options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 );
/*!
 *  Unit test package for resolve_detail_updates macro.
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
  %include "Y:\Users\camendol\SAS_ETL_dev\support_lib\resolve_detail_updates.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

%resolve_detail_updates( detail_data=testlib.DIAG_DTL_TEST
                        ,out_data=work.to_test
                        );

proc sort data=work.to_test;
  by cur_clm_uniq_id
     clm_val_sqnc_num;
run;
/**
  * Make sure the pre-manipulated data is 'bad'
  */
data _null_;
  set testlib.DIAG_DTL_TEST;

  by cur_clm_uniq_id
     clm_val_sqnc_num;

  last_claim_line=lag(clm_val_sqnc_num);
  last_claim_id=lag(cur_clm_uniq_id);

  %assert( (last_claim_id ^= cur_clm_uniq_id)
          ,(last_claim_id = clm_val_sqnc_num)
          ,message=Duplicate keys detected.)

run;

/**
  * Is the manipulated data 'clean'?
  */
data _null_;
  set work.to_test;

  by cur_clm_uniq_id
     clm_val_sqnc_num;

  last_claim_line=lag(clm_val_sqnc_num);
  last_claim_id=lag(cur_clm_uniq_id);

  %assert( (last_claim_id ^= clm_val_sqnc_num)
		  ,(last_claim_id = cur_clm_uniq_id)
          ,message=No Duplicate keys detected.)

run;

%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports
          ,test_scenario=resolve_detail_updates Testing
         ,report_label=resolve_detail_updates.html); 
