/*! 
 *       Datawarehouse module. Generates MED PHM and ELG 'standard' Datasets, from raw CCLF file sets.
 *
 *       CCLF File     |       File Description                      |  Sourced File Type    
 *         CCLF1       |   Part A Claims Header File                 |      MED - PARTA
 *         CCLF2       |   Part A Claims Revenue Center Detail File  |      MED - PARTA
 *         CCLF3       |   Part A Procedure Code File                |      MED - PARTA
 *         CCLF4       |   Part A Diagnosis Code File                |      MED - PARTA
 *         CCLF5       |   Part B Physicians File                    |      MED - PHYS
 *         CCLF6       |   Part B DME File                           |      MED - DME
 *         CCLF7       |   Part D File                               |      PHM
 *         CCLF8       |   Beneficiary Demographics File             |      ELG
 *
 *        @author     C. Amendola et al
 *       
 *        @created    August 2017
 *        @return     &lib_pref._raw.&lib_pref._&plan._ELGCMS_PD&cycle.
 *                    &lib_pref._raw.&lib_pref._&plan._MEDCMS_PD&cycle.
 *                    &lib_pref._raw.&lib_pref._&plan._PHMCMS_PD&cycle.
 */
 
/**  
  * @param mssp_num           ACO ID number for the source. REQUIRED.                                                                                           
  * @param lib_pref           Libname prefix for process. The three char symbol for the client. REQUIRED.                                                           
  * @param plan               The char symbol for the client. REQUIRED.                                                         
  * @param client_title_short Short text label or description of the client. REQUIRED.                                                           
  * @param cycle              Current run cycle 'PDYYYYMMDD'. REQUIRED.                                                                     
  * @param beg_yrmo           Data period beginning Year and Month. REQUIRED.                                                          
  * @param raw_fold           Raw incoming data system path. REQUIRED.                                                           
  * @param rpt_only           Run in report only mode -  Y,y,N,n.                                                           
  * @param keep_work          Force the drop of named WORK lib datasets - help with disk space management - Y,y,N,n.                                                            
  * @param cclf1_file         Full path, wildcards allowed, to the cclf1 files                                                                   
  * @param cclf1_schema       Full path to the cclf1 config schema                                                                
  * @param cclf1_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_EFCTV_DT0.                                                                                             
  * @param cclf2_file         Full path, wildcards allowed, to the cclf2 files                                                             
  * @param cclf2_schema       Full path to the cclf2 config schema                                                           
  * @param cclf2_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_LINE_FROM_DT0 CLM_LINE_THRU_DT0 CLM_LINE_INSTNL_REV_CTR_DT0.
  * @param cclf3_file         Full path, wildcards allowed, to the cclf3 files                                                             
  * @param cclf3_schema       Full path to the cclf3 config schema                                                            
  * @param cclf3_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:PRCDR_PRFRM_DT0                                                
  * @param cclf4_file         Full path, wildcards allowed, to the cclf4 files                                                            
  * @param cclf4_schema       Full path to the cclf4 config schema                                                            
  * @param cclf4_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates.                                                         
  * @param cclf5_file         Full path, wildcards allowed, to the cclf5 files                                                               
  * @param cclf5_schema       Full path to the cclf5 config schema                                                            
  * @param cclf5_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_EFCTV_DT0                                                                                                   
  * @param cclf6_file         Full path, wildcards allowed, to the cclf6 files                                                            
  * @param cclf6_schema       Full path to the cclf6 config schema                                                           
  * @param cclf6_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_EFCTV_DT0                                                  
  * @param cclf7_file         Full path, wildcards allowed, to the cclf7 files                                                             
  * @param cclf7_schema       Full path to the cclf7 config schema                                                           
  * @param cclf7_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_EFCTV_DT0                                                  
  * @param cclf8_file         Full path, wildcards allowed, to the cclf8 files                                                            
  * @param cclf8_schema       Full path to the cclf8 config schema                                                            
  * @param cclf8_cln_dates    Space delimited list of incoming char variables that need transformation before becoming cast as dates.                                                            
  * -- If the historical data for an aco goes back to another layout/version of the cclf file format we need to account for that legacy layout.
  * @param cclf1a_file        Full path, wildcards allowed, to the alternative cclf1 files                                                             
  * @param cclf1a_schema      Full path to the alternative cclf1 config schema                                                            
  * @param cclf1a_cln_dates   Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_EFCTV_DT0      
  * @param cclf5a_file        Full path, wildcards allowed, to the alternate cclf5 files                                                           
  * @param cclf5a_schema      Full path to the alternative cclf5 config schema                                                           
  * @param cclf5a_cln_dates   Space delimited list of incoming char variables that need transformation before becoming cast as dates. DEFAULT:CLM_EFCTV_DT0 
  * --
  * @param elig_ded           Full path to eligibility source-to-target map and transforms for ELG file.  REQUIRED.                                                           
  * @param med_ded            Full path to eligibility source-to-target map and transforms for MED file.  REQUIRED.                                                           
  * @param pharm_ded          Full path to eligibility source-to-target map and transforms for PHM file.  REQUIRED.                                                           
  * @param clm_type           Final MED file identifier - note source identifier in last three positions. REQUIRED. DEFAULT:MEDCMS                                                                
  * @param phm_type           Final PHM file identifier - note source identifier in last three positions. REQUIRED. DEFAULT:PHMCMS                                                                
  * @param elg_type           Final ELG file identifier - note source identifier in last three positions. REQUIRED. DEFAULT:ELGCMS,                                                                
  * @param cms_id_key         CMS id key variable for data preparation. 'bene_hic_num' or bene_mbi_id.    REQUIRED. DEFAULT:bene_hic_num
  */

%macro input_cms_prep( mssp_num=,
                       lib_pref=,
                       plan=,
                       client_title_short=,
                       cycle=,
                       beg_yrmo=,
                       raw_fold=,
                       rpt_only=,
                       keep_work=,
                       cclf1_file=,
                       cclf1_schema=,
                       cclf1_cln_dates=CLM_EFCTV_DT0,
                       cclf1a_file=,
                       cclf1a_schema=,
                       cclf1a_cln_dates=CLM_EFCTV_DT0,
                       cclf2_file=,
                       cclf2_schema=,
                       cclf2_cln_dates=CLM_LINE_FROM_DT0 CLM_LINE_THRU_DT0 CLM_LINE_INSTNL_REV_CTR_DT0,
                       cclf3_file=,
                       cclf3_schema=,
                       cclf3_cln_dates=PRCDR_PRFRM_DT0,
                       cclf4_file=,
                       cclf4_schema=,
                       cclf4_cln_dates=,
                       cclf5_file=,
                       cclf5_schema=,
                       cclf5_cln_dates=CLM_EFCTV_DT0,
                       cclf5a_file=,
                       cclf5a_schema=,
                       cclf5a_cln_dates=CLM_EFCTV_DT0,
                       cclf6_file=,
                       cclf6_schema=,
                       cclf6_cln_dates=CLM_EFCTV_DT0,
                       cclf7_file=,
                       cclf7_schema=,
                       cclf7_cln_dates=CLM_EFCTV_DT0,
                       cclf8_file=,
                       cclf8_schema=,
                       cclf8_cln_dates=,
                       elig_ded=,
                       med_ded=,
                       pharm_ded=,
                       clm_type=MEDCMS,
                       phm_type=PHMCMS,
                       elg_type=ELGCMS,
                       cms_id_key=bene_hic_num,       
                       _crf_num=2);
                     
   /**
    * Internal Exception Handler.<br>
    * Inserts usage description into log when exception occurs.<br>
    * Cancels the job.
    *
    * @param _desc REQUIRED Exception message
    */  	                           
  %macro exception(_desc);
   	   
    %put ****************************************;
   	%put ;
    %put input_cms_prep: Usage exception: &_desc;
    %put input_cms_prep: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception;                    
                      
  /** 
    * Validate parameter arguments
    * Stop process on bad argument
    */
  %check_argument( parm= mssp_num                                
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );                                                  

  %check_argument( parm= lib_pref                                
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );         

  %check_argument( parm= plan                                    
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= client_title_short                      
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cycle                                   
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= beg_yrmo                                
                  ,isa=CHAR /* INT?*/
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= raw_fold                                
                  ,isa=PATH
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= rpt_only                                
                  ,isa=CHAR
                  ,required=YES
                  ,valid_values= YES yes Yes Y y No no NO N n); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= keep_work                               
                  ,isa=CHAR
                  ,required=YES
                  ,valid_values= YES yes Yes Y y No no NO N n); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= cclf1_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= cclf1_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= cclf1_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then   
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. ); 

  %check_argument( parm= cclf2_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );      

  %check_argument( parm= cclf2_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf2_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf3_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf3_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf3_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf4_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf4_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf4_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf5_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf5_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf5_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf6_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );       

  %check_argument( parm= cclf6_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf6_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf7_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf7_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf7_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf8_file                              
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf8_schema                            
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf8_cln_dates                         
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf1a_file                             
                  ,isa=CHAR
                  ,required=NO); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf1a_schema                           
                  ,isa=FILE
                  ,required=NO); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf1a_cln_dates                        
                  ,isa=CHAR
                  ,required=NO); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf5a_file                             
                  ,isa=CHAR
                  ,required=NO);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );     

  %check_argument( parm= cclf5a_schema                           
                  ,isa=FILE
                  ,required=NO); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cclf5a_cln_dates                        
                  ,isa=CHAR
                  ,required=NO); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );                   

  %check_argument( parm= elig_ded                                
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= med_ded                                 
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= pharm_ded                               
                  ,isa=FILE
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= clm_type                                
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= phm_type                                
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= elg_type                                
                  ,isa=CHAR
                  ,required=YES); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );

  %check_argument( parm= cms_id_key                              
                  ,isa=CHAR
                  ,required=YES
                  ,valid_values=bene_mbi_id BENE_MBI_ID BENE_HIC_NUM bene_hic_num); 
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in input_cms_prep-invocation. Ending Now. );
  
  /**
   * Each ACO gets its' own raw subdirectory to work in 
   */
  %local _raw_lib 
         _crt_ret;
         
  %let _raw_lib=&mssp_num.;
  
  /**
   *  Check for existence of ACOs' directory 
   */
  %if %sysfunc(exist(&raw_fold.\&mssp_num.)) %then %do;  
  %end;
  /**
   * Create directory if it does not exist. 
   */
  %else %do;
    %put ATTEMPTING TO CREATE SUB-DIRECTORY: &mssp_num. under &raw_fold.;
    %let _crt_ret=%sysfunc(dcreate(&mssp_num.,&raw_fold.)); 
  %end;

  
  %put OPENING LIBNAME &mssp_num. LOCATED: &raw_fold.\&mssp_num.;      
  /**
   * ACO Raw source data (CCLFs +).
   */
  libname &mssp_num. "&raw_fold.\&mssp_num.";
  /* Make sure create went well. */
  %if &syslibrc ^= 0 %then %do;
    %put FAILED TO CREATE LIBNAME &mssp_num. AT &raw_fold.\&mssp_num.;
    %put ENDING PROCESS NOW;
    %abort cancel;
  %end;  
  
  /*** Ingest ***/ 
  /*** MED Files ***/
  /*** Part A ***/
 
  title1 "INPUT_CMS_PREP - PD&cycle.";
  title2 "&client_title_short.";

  %let global_view_setting=NO;
  
  %if not %isblank(cclf1_file) %then %do;
    /**
     * Read in Raw CCLF1 - Part A Claims Header File
     */
    %read_raw_cclf( infile=&cclf1_file
                   ,to_dataset=&_raw_lib..part_a_hdr_cms1
                   ,schema=&cclf1_schema
                   ,clean_dates=&cclf1_cln_dates
                   ,as_view=&global_view_setting
                   ,crf_num=&_crf_num.)
  %end; 
  %if not %isblank(cclf1a_file) %then %do;
    /**
     * Read in Alternate Raw CCLF1 - Part A Claims Header File
     */
    %read_raw_cclf( infile=&cclf1a_file
                   ,to_dataset=&_raw_lib..part_a_hdr_cms2
                   ,schema=&cclf1a_schema
                   ,clean_dates=&cclf1a_cln_dates
                   ,as_view=&global_view_setting
                   ,crf_num=&_crf_num.)
  %end;
  /* Concatenate different format header files. *//* TODO: proc datasets append||rename*/
  data &_raw_lib..part_a_hdr_cms;
    set %if not %isblank(cclf1_file) %then &_raw_lib..part_a_hdr_cms1;
        %if not %isblank(cclf1a_file) %then &_raw_lib..part_a_hdr_cms2;
        ;
  run;

  /**
   * Read in Raw CCLF2 - Part A Claims Revenue Center Detail File
   */
  %read_raw_cclf( infile=&cclf2_file
                 ,to_dataset=&_raw_lib..part_a_rev_dtl_cms
                 ,schema=&cclf2_schema
                 ,clean_dates=&cclf2_cln_dates
                 ,as_view=&global_view_setting
                 ,crf_num=&_crf_num.)

  /**
   * Read in Raw CCLF3 - Part A Procedure Code File
   */
  %read_raw_cclf( infile=&cclf3_file
                 ,to_dataset=&_raw_lib..part_a_proc_dtl_cms
                 ,schema=&cclf3_schema
                 ,clean_dates=&cclf3_cln_dates
                 ,as_view=&global_view_setting
                 ,crf_num=&_crf_num.)
  
  /**
   * Read in Raw CCLF4 - Part A Diagnosis Code File 
   */
  %read_raw_cclf( infile=&cclf4_file
                 ,to_dataset=&_raw_lib..part_a_diag_dtl_cms
                 ,schema=&cclf4_schema
                 ,clean_dates=&cclf4_cln_dates
                 ,as_view=&global_view_setting
                 ,crf_num=&_crf_num.)
  
  %if not %isblank(cclf5_file) %then %do;
    /**
     * Read in Raw CCLF5 - Part B Physicians File
     */
    %read_raw_cclf( infile=&cclf5_file
                   ,to_dataset=&_raw_lib..part_b_physician_cms1
                   ,schema=&cclf5_schema
                   ,clean_dates=&cclf5_cln_dates
                   ,as_view=&global_view_setting
                   ,crf_num=&_crf_num.)
  %end;
  %if not %isblank(cclf5a_file) %then %do;
    /**
     * Read in Alternate Raw CCLF5 - Part B Physicians File
     */
    %read_raw_cclf( infile=&cclf5a_file
                   ,to_dataset=&_raw_lib..part_b_physician_cms2
                   ,schema=&cclf5a_schema
                   ,clean_dates=&cclf5a_cln_dates
                   ,as_view=&global_view_setting
                   ,crf_num=&_crf_num.)
  %end;                 
  /* TODO: proc datasets append||rename*/
  data &_raw_lib..part_b_physician_cms;
    set %if not %isblank(cclf5_file) %then &_raw_lib..part_b_physician_cms1;
        %if not %isblank(cclf5a_file) %then &_raw_lib..part_b_physician_cms2;
        ;
  run; 
 
  /**
   * Read in Raw CCLF6 - Part B DME File
   */
  %read_raw_cclf( infile=&cclf6_file
                 ,to_dataset=&_raw_lib..part_b_dme_cms
                 ,schema=&cclf6_schema
                 ,clean_dates=&cclf6_cln_dates
                 ,as_view=&global_view_setting
                 ,crf_num=&_crf_num.)
  
  /**
   * Read in Raw CCLF7 - Part D File
   */
  %read_raw_cclf( infile=&cclf7_file
                 ,to_dataset=&_raw_lib..partd_phm_cms
                 ,schema=&cclf7_schema
                 ,clean_dates=&cclf7_cln_dates
                 ,as_view=&global_view_setting
                 ,crf_num=&_crf_num.)
                               
  /**
   * Read in Raw CCLF8 - Beneficiary Demographics File 
   */ 
  %read_raw_cclf( infile=&cclf8_file
                 ,to_dataset=&_raw_lib..bene_demo_cms
                 ,schema=&cclf8_schema
                 ,clean_dates=&cclf8_cln_dates
                 ,as_view=&global_view_setting
                 ,crf_num=&_crf_num.)
  
  /**** Report on CCLF Reads ****/
  %let _crt_ret=%sysfunc(dcreate(html,&out_fold.));
  %let _crt_ret=%sysfunc(dcreate(&mssp_num.,&out_fold.\html));
  %let _crt_ret=%sysfunc(dcreate(files,&out_fold.\html\&mssp_num.)); 
  
  ods _all_ close; 

  ods html body="&out_fold.html\&mssp_num.\files\ALL_CCLFs.html"
         gpath="&out_fold.html\&mssp_num.\files\"
     contents="&out_fold.html\&mssp_num.\files\CCLF-contents.html" 
        frame="&out_fold.html\&mssp_num.\ALL_CCLFs.html" 
         style=SasWeb
         newfile=output;
  /**
   * Profile CCLF1
   */       
  %raw_profile( data_source=&_raw_lib..part_a_hdr_cms
               ,sub_title=CCLF1 - Part A Claims Header File
               ,min_max_dates=CLM_FROM_DT CLM_THRU_DT);
  /**
   * Profile CCLF2
   */         
  %raw_profile( data_source=&_raw_lib..part_a_rev_dtl_cms
               ,sub_title=CCLF2 - Part A Claims Revenue Center Detail File
               ,min_max_dates=CLM_FROM_DT CLM_THRU_DT);
  /**
   * Profile CCLF3
   */              
  %raw_profile( data_source=&_raw_lib..part_a_proc_dtl_cms
               ,sub_title=CCLF3 - Part A Procedure Code File
               ,min_max_dates=CLM_FROM_DT CLM_THRU_DT);
  /**
   * Profile CCLF4
   */           
  %raw_profile( data_source=&_raw_lib..part_a_diag_dtl_cms
               ,sub_title=CCLF4 - Part A Diagnosis Code File
               ,min_max_dates=CLM_FROM_DT CLM_THRU_DT);
  /**
   * Profile CCLF5
   */               
  %raw_profile( data_source=&_raw_lib..part_b_physician_cms
               ,sub_title=CCLF5 - Part B Physicians File
               ,min_max_dates=CLM_FROM_DT CLM_THRU_DT);    
  /**
   * Profile CCLF6
   */          
  %raw_profile( data_source=&_raw_lib..part_b_dme_cms
               ,sub_title=CCLF6 - Part B DME File
               ,min_max_dates=CLM_FROM_DT CLM_THRU_DT); 
  /**
   * Profile CCLF7
   */               
  %raw_profile(data_source=&_raw_lib..partd_phm_cms
               ,sub_title=CCLF7 - Part D Pharmacy File
               ,min_max_dates=CLM_EFCTV_DT CLM_LINE_FROM_DT);                                    
  /**
   * Profile CCLF8
   */         
  %raw_profile(data_source=&_raw_lib..bene_demo_cms
               ,sub_title=CCLF8 - Beneficiaries Demographics File
               );       
         
  ods html close;       
  /********(Re)Model**************************************************************/
  /** Detail files may be updated by month and require deduping.
    * The record in the latest month's data should 'trump' any details from previous months.           
    */
  
  %put -----;
  %put Resolving Diagnosis and Procedure detail file updates across monthly file;
  %put -----;
  /**
   * Resolving Diagnosis detail file updates across monthly file
   */
  %resolve_detail_updates( detail_data=&_raw_lib..part_a_diag_dtl_cms
                          ,out_data=&_raw_lib..part_a_diag_dtl_cms_updt)
  /**
   * Resolving Procedure detail file updates across monthly file
   */
  %resolve_detail_updates( detail_data=&_raw_lib..part_a_proc_dtl_cms
                          ,out_data=&_raw_lib..part_a_proc_dtl_cms_updt)
 
   
  %put -----;
  %put Resolving Diagnosis and Procedure detail files into claim summary roll-up;
  %put -----; 
  /**
   * Transpose Diag records to columns - 'flatten' the details.
   */
  %transpose_details( detail_data=&_raw_lib..part_a_diag_dtl_cms_updt
                     ,out_data=&_raw_lib..part_a_diag_dtl_cms_flat
                       ,prefix=DGNS_CD
                     ,trans_var=DGNS_CD)
  /**
   * Transpose Proc records to columns - 'flatten' the details.
   */
  %transpose_details( detail_data=&_raw_lib..part_a_proc_dtl_cms_updt
                     ,out_data=&_raw_lib..part_a_proc_dtl_cms_flat
                       ,prefix=PRCDR_CD
                     ,trans_var=PRCDR_CD)

  /* Merge flattened diag and proc detail records. */
  data work.proc_diag_merge;

    merge &_raw_lib..part_a_proc_dtl_cms_flat(in=_PROC
                                           drop=_NAME_)
          &_raw_lib..part_a_diag_dtl_cms_flat(in=_DIAG
                                           drop=_NAME_);
    by CUR_CLM_UNIQ_ID;

    if _PROC or _DIAG;
    /* Over-defensive?*/
    if lag(CUR_CLM_UNIQ_ID) = CUR_CLM_UNIQ_ID then 
      put "EXCEPTION: Multiple values for CUR_CLM_UNIQ_ID detected!!!";

  run;

  /* POA get first diag from detail file */
  proc sql noprint;
    create table work.first_poa as
      select cur_clm_uniq_id
            ,clm_val_sqnc_num
            ,clm_poa_ind
      from &_raw_lib..part_a_diag_dtl_cms_updt
      having clm_val_sqnc_num = min(clm_val_sqnc_num);

  /* Merge first POA onto detail merge file. */
  data work.proc_diag_merge_POA;
    merge work.proc_diag_merge(in=_IN_DETAILS)
          work.first_poa(drop=clm_val_sqnc_num);
    by CUR_CLM_UNIQ_ID;
    if _IN_DETAILS;
  run;

  /* Merge revenue detail and icd diag & proc detail */
  proc sort data=&_raw_lib..part_a_rev_dtl_cms;
    by cur_clm_uniq_id;
  run;
  
  data work.dets_rev_merge;
    merge &_raw_lib..part_a_rev_dtl_cms(in=_rev drop=clm_from_dt clm_thru_dt /*These vars collide with columns in CCLF */)
          work.proc_diag_merge_POA(in=_other);
    by CUR_CLM_UNIQ_ID;
    if _rev and _other;
  run;

  /* Merge Header information on to proc/rev detail */
  proc sort data=&_raw_lib..part_a_hdr_cms;
    by cur_clm_uniq_id;
  run;
  
  data work.part_a_complete;
    merge work.dets_rev_merge(in=_rev)
          &_raw_lib..part_a_hdr_cms(in=_head);

    by CUR_CLM_UNIQ_ID;
    
    /*length rbflag $2 
           bill_type pos $3 
           serv_prv_spec1_orig $15;*/

    if _head;

    /* Assign room and board flag. */
    if 100 <= input(PROD_REV_CTR_CD,15.) <= 219 then rbflag = 'RB'; 
    
  run; 

  /* Rectify payment values */
  /* -Compute sum of revenue line dollar values
   * -Compare header paid dollar amount to rev-line summary
   * -If Header value = sum value then Payment Total=Rev line value
   * -If header value not equal sum value then
   * -- set payment total=0
   * -- if last line for claim id, then assign header value to payment total - preference to RB record
   */

  /* Sum of revenue line dollars */
  proc sql noprint;
    create table work.rev_line_sum_of_cost as
      select cur_clm_uniq_id
            ,sum(clm_line_cvrd_pd_amt) as rev_line_sum
      from part_a_complete
      group by cur_clm_uniq_id
      order by cur_clm_uniq_id;

  /* This sort pushes the room and board records to the bottom of the record 'stack' */
  /* If there's a room and board code in the claims rev lines it ends up at the bottom. */
  /* Last record for a claim will be a room and board, if one exists for the claim. */
  proc sort data=work.part_a_complete;
    by CUR_CLM_UNIQ_ID 
       rbflag 
       clm_from_dt 
       clm_thru_dt;
  run;
  /* Merge rev line summary to claim data for comparision. */
  data &_raw_lib..part_a_complete_cost;

    merge work.part_a_complete 
          work.rev_line_sum_of_cost;

    by cur_clm_uniq_id;
    /* Revenue Line details have to be reversed. */
    if clm_adjsmt_type_cd='1' then do;
      rev_line_sum=0-rev_line_sum;
      clm_line_cvrd_pd_amt=0-clm_line_cvrd_pd_amt;
    end;
    /*If Header value = sum value then Payment Total=Rev line value */
    if rev_line_sum = clm_pmt_amt then payment_total = clm_line_cvrd_pd_amt;
    /* Otherwise */
    else do;
      payment_total = 0;
      /* Unless last claim, preferably an R&B Line */
      if last.cur_clm_uniq_id then payment_total = clm_pmt_amt;
    end;

  run;

  /* Transform */
/**** MEDCMS ****/
%let _keep_list=;
%read_map_spec(&med_ded);

proc sql noprint ;
  select name 
    into :_keep_list separated by ' ' 
  from work.map_spec;

/*&lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle.*/
data &lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle.(keep=&_keep_list); 

 %generate_attrib_ded();    

  set &_raw_lib..part_a_complete_cost ( in=_PARTA 
                                 )
      &_raw_lib..part_b_dme_cms (in=_DME)
      &_raw_lib..part_b_physician_cms ( in=_PARTB 
                           );

  /*Standard DED input fields*/ 
  %map_raw2ded();
  /*Logic-based Assignments*/
  %ded_assignment_logic();
    
  /*MSSP-specific Assignments*/
  *Set missing date fields;
  if CLM_FROM_DT = . then CLM_FROM_DT = from_dt;
  if CLM_THRU_DT = . then CLM_THRU_DT = to_dt;

run;

/**** PHMCMS ****/
%read_map_spec(&pharm_ded);

proc sql noprint;
  select name 
    into :_keep_list separated by ' ' 
  from work.map_spec;

data &lib_pref._raw.&lib_pref._&plan._&phm_type._PD&cycle.(keep=&_keep_list); 


 %generate_attrib_ded();    

  set &_raw_lib..partd_phm_cms;

  /*Standard DED input fields*/ 
  %map_raw2ded();
  /*Logic-based Assignments*/
  %ded_assignment_logic();

run;

/**** ELIG ****/
/********************Get earliest serv-date information required for assigning ELG eff_dt****************************/
/* Bring relevant service record together */
/* Find earliest date of any medical service each member */
proc sql noprint;
  create table work.min_med_dates as
    select member_orig      
          ,min(from_dt) as min_med_date
    from &lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle.
    group by member_orig
    order by member_orig
  ; 
/* Find earliest date of any pharmacy claim for each member */
  create table work.min_phm_dates as
    select member_orig      
          ,min(serv_dt) as min_phm_date
    from &lib_pref._raw.&lib_pref._&plan._&phm_type._PD&cycle.
    group by member_orig
    order by member_orig
  ; 
  
data work.min_dates
    /view=work.min_dates;
  merge work.min_med_dates(in=_MED)
        work.min_phm_dates(in=_PHM);
  by member_orig; 
  /* Use earlier pharm date if member has med serv, but ignore pharm if member does not have med(pharm-only) */
  /* 'Round' date to first of month */
  if _MED then min_serv_date=intnx('month',min_med_date,0,"BEGINNING");
  if _MED and _PHM and min_phm_date<min_med_date then min_serv_date=intnx('month',min_phm_date,0,"BEGINNING"); 

  phm='-';
  if _PHM then phm='Y';
  else phm='N'; 
  /* Less than ideal creation of key-variable for later merge, but avoids a warning message */
  length &cms_id_key. $11;
  &cms_id_key.=member_orig;

run;

/* Get a single member record per source file */
/* Assuming there's not a meaningful difference between records - for our solution */
proc sort data=&_raw_lib..bene_demo_cms
           out=&_raw_lib..scrubbed_bene_demo
           nodupkey;
  by &cms_id_key.
     source_file_month;
run;
/* Locate file of previously encountered member ids for intial run */
/* or create a new one. */
%put CHECK FOR "Known Patients" ID DATASET...;
%if %sysfunc(exist(&lib_pref.MAPSP.&mssp_num._known_patients)) %then %do;
  %put FOUND.;
  data work.&mssp_num._known_patients;
      set &lib_pref.MAPSP.&mssp_num._known_patients;
  run;
%end;
%else %do;
  %put Checking for prior eligibility dataset from which to construct "known patients" dataset...;
  %if %sysfunc(exist(&lib_pref.basep.&plan._cur_&elg_type._span)) %then %do;
    %put Constructing "known patients" dataset from prior spans data.;
    /*Sort prior cycle data to keep one record per member */
    proc sort data=&lib_pref.basep.&plan._cur_&elg_type._span
                nodupkey 
                     out=__tmp__ (keep=member);
      by member;
    run;
    data &lib_pref._MAPS.&mssp_num._known_patients
            work.&mssp_num._known_patients; 
         attrib &cms_id_key.      length=$11
             source_file_month length=$7
      ;   
      set __tmp__;
      &cms_id_key.=member;
      drop member;
    run;
  %end; 
  %else %do;
    %put No prior data found.;  
    data work.&mssp_num._known_patients;
      attrib &cms_id_key.      length=$11
             source_file_month length=$7
      ;
      &cms_id_key.="";
      source_file_month="";
      stop;
    run;
  %end;      
%end;

%read_map_spec(&elig_ded);
data &lib_pref._raw.&lib_pref._&plan._&elg_type._PD&cycle.;
  %generate_attrib_ded();
  /* Load up a hash table with prior information, use a hash to add to this as we go*/
  if _n_=1 then do;
    declare hash first_source(dataset: "work.&mssp_num._known_patients");
      first_source.definekey("&cms_id_key.");
      first_source.definedata("&cms_id_key.",'source_file_month');
      first_source.definedone();
  end;

  format file_date 
         min_serv_date 
         infered_start 
         infered_end 
         age_in_dt 
         contract_date yymmdd10.;
         
  merge &_raw_lib..scrubbed_bene_demo(in=_BENE)
        work.min_dates( in=_serv )
        end=_DONE;

  by &cms_id_key.;

  if _BENE;

  /* From Members presence in file we can infer 'eligibility' for a given time frame */
  /* Get the date timestamp from the filename */
  file_date=input("20"||substr(source_file_month,2),yymmdd8.);
  /* For most cases this implied time frame is the month prior to the file name timestamp */
  infered_start=intnx('MONTH',file_date,-1,'BEGINNING');
  infered_end=intnx('MONTH',file_date,-1,'END');

  /* We have a CMS 'oddball' submission that doesn't follow nameing conventions - set it's infered_dates manually */
  if source_file_month = 'D160916' then do;
    /*7/1/2016*/
    infered_start='01JUL16'd;
    /*7/31/2016*/
    infered_end='31JUL16'd;         
  end;

  /* Start evaluation of new or previously encountered member and determine 'anchor date' */
  if first.&cms_id_key. then do;
    /* if not in hash add to hash with source_file tag */
    found_member=first_source.find();
    /* First time to see member if found member > 0*/
    if found_member>0 then do;
      /* Add to hash 'list' of found members*/
      first_source.add();
      /* Default implied start date to 'contract date' */

      contract_date=input("&beg_yrmo.01",yymmdd8.);
      /* Start 'Age-in' determination */
      age = yrdif(BENE_DOB, today(), 'AGE');
      if age >= 65 then do;
        /* 65 Years equals 780 months - note 'magic' numbers in intnx  */
        if day(BENE_DOB) = 1 then age_in_dt = intnx('month',BENE_DOB,779,"beginning"); 
        else age_in_dt = intnx('month',BENE_DOB,780,"beginning");
      end;
    
      /*Final implied start date - use earlier of age-in or min service and use if after contract date */
      infered_start=max(contract_date,min(age_in_dt,min_serv_date));      
    end;
  end;

  /* Deal with death dates */
  /* Assuming that death date is present consistently in bene_demos after death */
  if bene_death_dt then do;
    /*'Round' to end of month */
    bene_death_dt=intnx('MONTH',bene_death_dt,0,'END');
    /* If death date is before start date drop record */
    if bene_death_dt<=infered_start then delete;
    else if bene_death_dt<infered_end then infered_end=bene_death_dt;
  end;

  /*Standard DED input fields*/ 
  %map_raw2ded();
  /*Logic-based Assignments*/
  %ded_assignment_logic();

  if _DONE then do;
    drop out_code; 
    out_code=first_source.output(dataset: "&lib_pref._MAPS.&mssp_num._known_patients"); 
  end;
run;

/******* PREPed FILE REPORING **/
%cms_prep_profile( data= &lib_pref._raw.&lib_pref._&plan._&elg_type._PD&cycle.
                     ,set_source_file=raw_source_file
                     ,min_max_vars=eff_dt end_dt
                     ,trend_vars=
                     ,ignore_vars=
                     ,some_label_var=&elg_type.
                     ,var_map=&elig_ded.);   
                          
%cms_prep_profile( data= &lib_pref._raw.&lib_pref._&plan._&phm_type._PD&cycle.
                     ,set_source_file="&lib_pref._raw.&lib_pref._&plan._&phm_type._PD&cycle..sas7bdat"
                     ,min_max_vars=serv_dt pay_dt
                     ,trend_vars=serv_dt pay_dt
                     ,ignore_vars=clm_head
                     ,some_label_var=&phm_type.
                     ,var_map=&pharm_ded.);
          
%cms_prep_profile( data= &lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle.
                     ,set_source_file="&lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle..sas7bdat"
                     ,min_max_vars=serv_dt pay_dt
                     ,trend_vars=serv_dt pay_dt
                     ,ignore_vars=clm_head
                     ,some_label_var=&clm_type.
                     ,var_map=&med_ded.);   
/**
 * Scrub Localize work datasets
 */                                                 
%scrub_datasets( lib=&_raw_lib
                ,ds_list=part_a_hdr_cms1
                         part_a_hdr_cms2
                         part_a_hdr_cms
                         part_a_rev_dtl_cms
                         part_a_proc_dtl_cms
                         part_b_physician_cms1
                         part_b_physician_cms2
                         part_b_physician_cms
                         part_b_dme_cms
                         partd_phm_cms
                         bene_demo_cms
                         part_a_complete_cost
                         part_a_diag_dtl_cms_updt
                         )

%mend input_cms_prep;





