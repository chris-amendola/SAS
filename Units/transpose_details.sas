options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 );
/*!
 *  Unit test package for transpose_details macro.
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
  %include "Y:\Users\camendol\SAS_ETL_dev\support_lib\transpose_details.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

%transpose_details( detail_data=testlib.tranpose_test_data
                   ,out_data=work.to_test
                   ,trans_var=DGNS_CD
				   ,prefix=DGNS_CD
                   );
proc contents data=work.to_test    
               out=work.structure
               noprint;
run;

proc sql noprint;
  select name into :_varlist separated by " "
    from work.structure 
	where prxmatch("/^DGNS/",name)
	order by name;

data _null_;
  set work.to_test;
  if _n_=1 then do;
    xpose_vars="&_VARLIST";
	%assert( (xpose_vars='DGNS_CD1 DGNS_CD2 DGNS_CD3 DGNS_CD4 DGNS_CD5')
             ,message= Finds all tranposed detail variables. )
  end;
 
  prev_claim_id=lag(cur_clm_uniq_id);
  %assert( (prev_claim_id^=cur_clm_uniq_id)
          ,message=Only one row per claim id.)

  %assert( (dgns_cd1^="")
           ,message=First tranposed detail var is populated.)
  
run;


%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports
          ,test_scenario=transpose_details Testing
          ,report_label=transpose_details.html); 
