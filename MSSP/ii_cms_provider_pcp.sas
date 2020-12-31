/*! 
 *       Extrapolates a PCP assignment for a beneficiary based on an interpreation of the
 *       CMS method for assigning a Medicare Beneficiary to an ACO.
 *     
 *       This module creates a user-specified dataset that maps a PCP 'assignment' to a member-id
 *       based on a user specified input dataset.
 *
 *       Assumes incoming dataset is filtered for date range and qualified providers.
 *
 *        @author     C. Amendola 
 *       
 *        @created    August 2018
 *        @return     final_assignments_data
 */
 
/**                                                                  
  * @param med_services_data   Medicare services data from which PCP attribution will be extrapolated. REQUIRED.
  * @param serv_date           Medicare Services data variable. REQUIRED. DEFAULT:from_dt
  * @param part_b_alw          Medicare Part B sourced services allowed variable. REQUIRED. DEFAULT:amt_all
  * @param part_a_pay          Medicare Part A sources services paid variable. REQUIRED. DEFAULT:cust_payment_total
  * @param part_a_prov         Part A services provider variable. REQUIRED. DEFAULT:CUST_ATTEND_PRV
  * @param part_b_prov         Part B services provider variable. REQUIRED. DEFAULT:serv_prv
  * @param spec_var            Specialty Code Variable. REQUIRED. DEFAULT:serv_prv_spec1_orig
  * @param clm_type_var        Service source variable ('Part A','Part B' etc). REQUIRED. DEFAULT:clm_source
  * @param rev_var             Revenue Code Variable. REQUIRED. DEFAULT:revenue
  * @param bill_type_1         Bill Type Position 1 variable. REQUIRED. DEFAULT:CUST_BILL_TYPE_1
  * @param bill_type_2         Bill Type Position 2 variable. REQUIRED. DEFAULT:CUST_BILL_TYPE_2
  * @param final_assignments_data    User-Specified dataset mapping member to assigned PCP. REQUIRED. DEFAULT:work.final_assignments
  */
%macro ii_cms_provider_pcp(  med_services_data=
                            ,serv_date=from_dt
                            ,part_b_alw=amt_all
                            ,part_a_pay=cust_payment_total
                            ,part_a_prov=CUST_ATTEND_PRV
                            ,part_b_prov=serv_prv
                            ,spec_var=serv_prv_spec1_orig
                            ,clm_type_var=clm_source
                            ,rev_var=revenue
                            ,bill_type_1=CUST_BILL_TYPE_1
                            ,bill_type_2=CUST_BILL_TYPE_2
                            ,final_assignments_data=work.final_assignments);

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
    %put ii_cms_provider_pcp: Usage exception: &_desc;
    %put ii_cms_provider_pcp: Job terminating.;
    %put ;
    %put ****************************************;
        
    %abort cancel;
        
  %mend exception;                    
                      
  /** 
    * Validate parameter arguments
    * Stop process on bad argument
    */
  %check_argument( parm=med_services_data                      
                   ,isa=DATA       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=serv_date                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

   %check_argument( parm=part_b_alw                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=part_a_pay                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=part_a_prov                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=part_b_prov                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=spec_var                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=clm_type_var                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=revenue                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=bill_type_1                      
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=bill_type_2                     
                   ,isa=VAR~&med_services_data.       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

  %check_argument( parm=final_assignments_data                      
                   ,isa=CHAR       
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in ii_cms_provider_pcp-invocation. Ending Now. );

options mprint;

  %macro apply_specialty_taxonomy(_spec_var);

    if strip(PRIMARY_TAXONOMY) in ('208D00000X') then CLM_PRVDR_SPCLTY_CD = '01';
    if strip(PRIMARY_TAXONOMY) in ('208600000X','2086H0002X','2086S0120X','2086S0122X','2086S0105X','2086S0102X') then CLM_PRVDR_SPCLTY_CD = '02';
    if strip(PRIMARY_TAXONOMY) in ('2086X0206X','2086S0127X','2086S0129X','208G00000X','204F00000X','208C00000X','207T00000X') then CLM_PRVDR_SPCLTY_CD = '02';
    if strip(PRIMARY_TAXONOMY) in ('204E00000X','207X00000X','207XS0114X','207XX0004X','207XS0106X','207XS0117X','207XX0801X') then CLM_PRVDR_SPCLTY_CD = '02';
    if strip(PRIMARY_TAXONOMY) in ('207XP3100X','207XX0005X','208200000X','2082S0099X','2082S0105X') then CLM_PRVDR_SPCLTY_CD = '02';
    if strip(PRIMARY_TAXONOMY) in ('207K00000X','207KA0200X','207KI0005X') then CLM_PRVDR_SPCLTY_CD = '03';
    if strip(PRIMARY_TAXONOMY) in ('207Y00000X','207YS0123X','207YX0602X','207YX0905X','207YX0901X') then CLM_PRVDR_SPCLTY_CD = '04';
    if strip(PRIMARY_TAXONOMY) in ('207YP0228X','207YX0007X','207YS0012X') then CLM_PRVDR_SPCLTY_CD = '04';
    if strip(PRIMARY_TAXONOMY) in ('207L00000X') then CLM_PRVDR_SPCLTY_CD = '05';
    if strip(PRIMARY_TAXONOMY) in ('207LA0401X','207LC0200X','207LH0002X','207LP2900X','207LP3000X') then CLM_PRVDR_SPCLTY_CD = '05';
    if strip(PRIMARY_TAXONOMY) in ('207RC0000X') then CLM_PRVDR_SPCLTY_CD = '06';
    if strip(PRIMARY_TAXONOMY) in ('207N00000X','207NI0002X','207ND0101X','207ND0900X','207NP0225X','207NS0135X') then CLM_PRVDR_SPCLTY_CD = '07';
    if strip(PRIMARY_TAXONOMY) in ('207Q00000X','207QA0401X','207QA0000X','207QA0505X','207QB0002X','207QG0300X','207QH0002X','207QS0010X','207QS1201X') then CLM_PRVDR_SPCLTY_CD = '08';
    if strip(PRIMARY_TAXONOMY) in ('208VP0014X') then CLM_PRVDR_SPCLTY_CD = '09';
    if strip(PRIMARY_TAXONOMY) in ('207RG0100X') then CLM_PRVDR_SPCLTY_CD = '10';
    if strip(PRIMARY_TAXONOMY) in ('207R00000X','207RA0401X','207RA0000X','207RA0201X','207RB0002X','207RC0000X','207RI0001X') then CLM_PRVDR_SPCLTY_CD = '11';
    if strip(PRIMARY_TAXONOMY) in ('207RC0001X','207RC0200X','207RE0101X','207RG0100X','207RG0300X','207RH0000X','207RH0003X') then CLM_PRVDR_SPCLTY_CD = '11'; 
    if strip(PRIMARY_TAXONOMY) in ('207RI0008X','207RH0002X','207RI0200X','207RI0011X','207RM1200X','207RX0202X') then CLM_PRVDR_SPCLTY_CD = '11';
    if strip(PRIMARY_TAXONOMY) in ('207RN0300X','207RP1001X','207RR0500X','207RS0012X','207RS0010X','207RT0003X') then CLM_PRVDR_SPCLTY_CD = '11';
    if strip(PRIMARY_TAXONOMY) in ('204D00000X','204C00000X') then CLM_PRVDR_SPCLTY_CD = '12';
    if strip(PRIMARY_TAXONOMY) in ('2084N0400X','2084N0402X') then CLM_PRVDR_SPCLTY_CD = '13';
    if strip(PRIMARY_TAXONOMY) in ('207T00000X') then CLM_PRVDR_SPCLTY_CD = '14';
    if strip(PRIMARY_TAXONOMY) in ('207V00000X','207VB0002X','207VC0200X','207VX0201X','207VG0400X','207VH0002X') then CLM_PRVDR_SPCLTY_CD = '16';
    if strip(PRIMARY_TAXONOMY) in ('207VM0101X','207VX0000X','207VE0102X') then CLM_PRVDR_SPCLTY_CD = '16';
    if strip(PRIMARY_TAXONOMY) in ('207W00000X') then CLM_PRVDR_SPCLTY_CD = '18';
    if strip(PRIMARY_TAXONOMY) in ('1223S0112X') then CLM_PRVDR_SPCLTY_CD = '19';
    if strip(PRIMARY_TAXONOMY) in ('207X00000X','207XS0114X','207XX0004X','207XS0106X','207XS0117X','207XX0801X','207XP3100X','207XX0005X') then CLM_PRVDR_SPCLTY_CD = '20';
    if strip(PRIMARY_TAXONOMY) in ('207ZP0101X','207ZP0102X','207ZB0001X','207ZP0104X','207ZC0006X','207ZP0105X','207ZC0500X','207ZD0900X') then CLM_PRVDR_SPCLTY_CD = '22';
    if strip(PRIMARY_TAXONOMY) in ('207ZF0201X','207ZH0000X','207ZI0100X','207ZM0300X','207ZP0007X','207ZN0500X','207ZP0213X') then CLM_PRVDR_SPCLTY_CD = '22';
    if strip(PRIMARY_TAXONOMY) in ('208200000X','2082S0099X','2082S0105X') then CLM_PRVDR_SPCLTY_CD = '24';
    if strip(PRIMARY_TAXONOMY) in ('208100000X','2081H0002X','2081N0008X','2081P2900X','2081P0010X','2081P0004X','2081S0010X') then CLM_PRVDR_SPCLTY_CD = '25';
    if strip(PRIMARY_TAXONOMY) in ('2084P0800X') then CLM_PRVDR_SPCLTY_CD = '26';
    if strip(PRIMARY_TAXONOMY) in ('208C00000X') then CLM_PRVDR_SPCLTY_CD = '28';
    if strip(PRIMARY_TAXONOMY) in ('207RP1001X') then CLM_PRVDR_SPCLTY_CD = '29';
    if strip(PRIMARY_TAXONOMY) in ('2085R0202X') then CLM_PRVDR_SPCLTY_CD = '30';
    if strip(PRIMARY_TAXONOMY) in ('367H00000X') then CLM_PRVDR_SPCLTY_CD = '32';
    if strip(PRIMARY_TAXONOMY) in ('208G00000X') then CLM_PRVDR_SPCLTY_CD = '33';
    if strip(PRIMARY_TAXONOMY) in ('208800000X','2088P0231X') then CLM_PRVDR_SPCLTY_CD = '34';
    if strip(PRIMARY_TAXONOMY) in ('111N00000X','111NI0013X','111NI0900X','111NN0400X','111NN1001X','111NX0100X') then CLM_PRVDR_SPCLTY_CD = '35';
    if strip(PRIMARY_TAXONOMY) in ('111NX0800X','111NP0017X','111NR0200X','111NR0400X','111NS0005X','111NT0100X') then CLM_PRVDR_SPCLTY_CD = '35';
    if strip(PRIMARY_TAXONOMY) in ('207U00000X','207UN0903X','207UN0901X','207UN0902X') then CLM_PRVDR_SPCLTY_CD = '36';
    if strip(PRIMARY_TAXONOMY) in ('208000000X','2080A0000X','2080I0007X','2080P0006X','2080H0002X','2080T0002X','2080N0001X') then CLM_PRVDR_SPCLTY_CD = '37';
    if strip(PRIMARY_TAXONOMY) in ('2080P0008X','2080P0201X','2080P0202X','2080P0203X','2080P0204X','2080P0205X','2080P0206X') then CLM_PRVDR_SPCLTY_CD = '37';
    if strip(PRIMARY_TAXONOMY) in ('2080P0207X','2080P0208X','2080P0210X','2080P0214X','2080P0216X','2080T0004X','2080S0012X','2080S0010X') then CLM_PRVDR_SPCLTY_CD = '37';
    if strip(PRIMARY_TAXONOMY) in ('207RG0300X','207QG0300X') then CLM_PRVDR_SPCLTY_CD = '38';
    if strip(PRIMARY_TAXONOMY) in ('207RN0300X') then CLM_PRVDR_SPCLTY_CD = '39';
    if strip(PRIMARY_TAXONOMY) in ('2086S0105X','2082S0105X') then CLM_PRVDR_SPCLTY_CD = '40';
    if strip(PRIMARY_TAXONOMY) in ('152W00000X','152WC0802X') then CLM_PRVDR_SPCLTY_CD = '41';
    if strip(PRIMARY_TAXONOMY) in ('152WL0500X','152WX0102X','152WP0200X','152WS0006X','152WV0400X') then CLM_PRVDR_SPCLTY_CD = '41';
    if strip(PRIMARY_TAXONOMY) in ('367A00000X') then CLM_PRVDR_SPCLTY_CD = '42';
    if strip(PRIMARY_TAXONOMY) in ('367500000X') then CLM_PRVDR_SPCLTY_CD = '43';
    if strip(PRIMARY_TAXONOMY) in ('207RI0200X') then CLM_PRVDR_SPCLTY_CD = '44';
    if strip(PRIMARY_TAXONOMY) in ('261QR0206X','261QR0207X') then CLM_PRVDR_SPCLTY_CD = '45';
    if strip(PRIMARY_TAXONOMY) in ('207RE0101X') then CLM_PRVDR_SPCLTY_CD = '46';
    if strip(PRIMARY_TAXONOMY) in ('293D00000X') then CLM_PRVDR_SPCLTY_CD = '47';
    if strip(PRIMARY_TAXONOMY) in ('213E00000X','213ES0103X','213ES0131X','213EG0000X','213EP1101X','213EP0504X','213ER0200X','213ES0000X') then CLM_PRVDR_SPCLTY_CD = '48';
    if strip(PRIMARY_TAXONOMY) in ('261QA1903X') then CLM_PRVDR_SPCLTY_CD = '49';
    if strip(PRIMARY_TAXONOMY) in ('363L00000X','363LA2100X','363LA2200X','363LC1500X','363LC0200X','363LF0000X') then CLM_PRVDR_SPCLTY_CD = '50';
    if strip(PRIMARY_TAXONOMY) in ('363LG0600X','363LN0000X','363LN0005X','363LX0001X','363LX0106X','363LP0200X','363LP0222X','363LP1700X','363LP2300X','363LP0808X','363LS0200X','363LW0102X') then CLM_PRVDR_SPCLTY_CD = '50';
    if strip(PRIMARY_TAXONOMY) in ('335E00000X') then CLM_PRVDR_SPCLTY_CD = '51';
    if strip(PRIMARY_TAXONOMY) in ('335E00000X') then CLM_PRVDR_SPCLTY_CD = '52';
    if strip(PRIMARY_TAXONOMY) in ('335E00000X') then CLM_PRVDR_SPCLTY_CD = '53';
    if strip(PRIMARY_TAXONOMY) in ('332B00000X') then CLM_PRVDR_SPCLTY_CD = '54';
    if strip(PRIMARY_TAXONOMY) in ('222Z00000X') then CLM_PRVDR_SPCLTY_CD = '55';
    if strip(PRIMARY_TAXONOMY) in ('224P00000X') then CLM_PRVDR_SPCLTY_CD = '56';   
    if strip(PRIMARY_TAXONOMY) in ('222Z00000X','224P00000X') then CLM_PRVDR_SPCLTY_CD = '57';
    if strip(PRIMARY_TAXONOMY) in ('332B00000X','333600000X') then CLM_PRVDR_SPCLTY_CD = '58';
    if strip(PRIMARY_TAXONOMY) in ('3336C0002X','3336C0003X','3336C0004X','3336H0001X','3336I0012X','3336L0003X','3336M0002X','3336M0003X','3336N0007X','3336S0011X') then CLM_PRVDR_SPCLTY_CD = '58';
    if strip(PRIMARY_TAXONOMY) in ('341600000X','3416A0800X','3416L0300X','3416S0300X') then CLM_PRVDR_SPCLTY_CD = '59';
    if strip(PRIMARY_TAXONOMY) in ('251K00000X') then CLM_PRVDR_SPCLTY_CD = '60';
    if strip(PRIMARY_TAXONOMY) in ('251V00000X') then CLM_PRVDR_SPCLTY_CD = '61';
    if strip(PRIMARY_TAXONOMY) in ('103T00000X','103TA0400X','103TA0700X','103TC0700X','103TC2200X','103TB0200X','103TC1900X','103TE1000X','103TE1100X','103TF0000X','103TF0200X','103TP2701X') then CLM_PRVDR_SPCLTY_CD = '62';
    if strip(PRIMARY_TAXONOMY) in ('103TH0004X','103TH0100X','103TM1700X','103TM1800X','103TP0016X','103TP0814X','103TP2700X','103TR0400X','103TS0200X','103TW0100X') then CLM_PRVDR_SPCLTY_CD = '62';
    if strip(PRIMARY_TAXONOMY) in ('335V00000X') then CLM_PRVDR_SPCLTY_CD = '63';
    if strip(PRIMARY_TAXONOMY) in ('231H00000X','231HA2400X') then CLM_PRVDR_SPCLTY_CD = '64';
    if strip(PRIMARY_TAXONOMY) in ('225100000X','2251C2600X','2251E1300X','2251E1200X','2251G0304X','2251H1200X','2251H1300X','2251N0400X','2251X0800X') then CLM_PRVDR_SPCLTY_CD = '65';
    if strip(PRIMARY_TAXONOMY) in ('2251P0200X','2251S0007X') then CLM_PRVDR_SPCLTY_CD = '65';
    if strip(PRIMARY_TAXONOMY) in ('207RR0500X') then CLM_PRVDR_SPCLTY_CD = '66';
    if strip(PRIMARY_TAXONOMY) in ('225X00000X','225XR0403X','225XE0001X','225XE1200X','225XF0002X','225XG0600X','225XH1200X','225XH1300X','225XL0004X','225XM0800X','225XN1300X','225XP0200X','225XP0019X') then CLM_PRVDR_SPCLTY_CD = '67';
    if strip(PRIMARY_TAXONOMY) in ('103TC0700X') then CLM_PRVDR_SPCLTY_CD = '68';
    if strip(PRIMARY_TAXONOMY) in ('291U00000X') then CLM_PRVDR_SPCLTY_CD = '69';
    if strip(PRIMARY_TAXONOMY) in ('261QM1300X') then CLM_PRVDR_SPCLTY_CD = '70';
    if strip(PRIMARY_TAXONOMY) in ('193200000X','193400000X') then CLM_PRVDR_SPCLTY_CD = '70';
    if strip(PRIMARY_TAXONOMY) in ('133V00000X','133VN1006X','133VN1004X','133VN1005X') then CLM_PRVDR_SPCLTY_CD = '71';
    if strip(PRIMARY_TAXONOMY) in ('208VP0000X') then CLM_PRVDR_SPCLTY_CD = '72';
    if strip(PRIMARY_TAXONOMY) in ('261QR0200X') then CLM_PRVDR_SPCLTY_CD = '74';
    if strip(PRIMARY_TAXONOMY) in ('247200000X') then CLM_PRVDR_SPCLTY_CD = '75';
    if strip(PRIMARY_TAXONOMY) in ('2086S0129X') then CLM_PRVDR_SPCLTY_CD = '76';
    if strip(PRIMARY_TAXONOMY) in ('2086S0129X') then CLM_PRVDR_SPCLTY_CD = '77';
    if strip(PRIMARY_TAXONOMY) in ('208G00000X') then CLM_PRVDR_SPCLTY_CD = '78';
    if strip(PRIMARY_TAXONOMY) in ('207L00000X','207QA0401X','207RA0401X','2084A0401X') then CLM_PRVDR_SPCLTY_CD = '79';
    if strip(PRIMARY_TAXONOMY) in ('1041C0700X') then CLM_PRVDR_SPCLTY_CD = '80';
    if strip(PRIMARY_TAXONOMY) in ('207RC0200X') then CLM_PRVDR_SPCLTY_CD = '81';
    if strip(PRIMARY_TAXONOMY) in ('207RH0000X') then CLM_PRVDR_SPCLTY_CD = '82';
    if strip(PRIMARY_TAXONOMY) in ('207RH0003X') then CLM_PRVDR_SPCLTY_CD = '83';
    if strip(PRIMARY_TAXONOMY) in ('2083A0100X') then CLM_PRVDR_SPCLTY_CD = '84';
    if strip(PRIMARY_TAXONOMY) in ('2083T0002X','2083X0100X','2083P0500X','2083P0901X','2083S0010X','2083P0011X') then CLM_PRVDR_SPCLTY_CD = '84';
    if strip(PRIMARY_TAXONOMY) in ('204E00000X') then CLM_PRVDR_SPCLTY_CD = '85';
    if strip(PRIMARY_TAXONOMY) in ('2084A0401X','2084P0802X','2084B0002X','2084P0804X','2084N0600X','2084D0003X') then CLM_PRVDR_SPCLTY_CD = '86';
    if strip(PRIMARY_TAXONOMY) in ('2084F0202X','2084P0805X','2084H0002X','2084P0005X','2084N0400X','2084N0402X','2084N0008X') then CLM_PRVDR_SPCLTY_CD = '86';
    if strip(PRIMARY_TAXONOMY) in ('2084P2900X','2084P0800X','2084P0015X','2084S0012X','2084S0010X','2084V0102X') then CLM_PRVDR_SPCLTY_CD = '86';
    if strip(PRIMARY_TAXONOMY) in ('364S00000X','364SA2100X','364SA2200X','364SC2300X','364SC1501X','364SC0200X') then CLM_PRVDR_SPCLTY_CD = '89';
    if strip(PRIMARY_TAXONOMY) in ('364SE0003X','364SE1400X','364SF0001X','364SG0600X','364SH1100X','364SH0200X') then CLM_PRVDR_SPCLTY_CD = '89';
    if strip(PRIMARY_TAXONOMY) in ('364SI0800X','364SL0600X','364SM0705X','364SN0000X','364SN0800X','364SX0106X','364SX0200X') then CLM_PRVDR_SPCLTY_CD = '89';
    if strip(PRIMARY_TAXONOMY) in ('364SX0204X','364SP0200X','364SP1700X','364SP2800X','364SP0808X','364SP0809X','364SP0807X') then CLM_PRVDR_SPCLTY_CD = '89';
    if strip(PRIMARY_TAXONOMY) in ('364SP0810X','364SP0811X','364SP0812X') then CLM_PRVDR_SPCLTY_CD = '89';
    if strip(PRIMARY_TAXONOMY) in ('364SP0813X','364SR0400X','364SS0200X','364ST0500X','364SW0102X') then CLM_PRVDR_SPCLTY_CD = '89';
    if strip(PRIMARY_TAXONOMY) in ('207RX0202X') then CLM_PRVDR_SPCLTY_CD = '90';
    if strip(PRIMARY_TAXONOMY) in ('2086X0206X') then CLM_PRVDR_SPCLTY_CD = '91';
    if strip(PRIMARY_TAXONOMY) in ('2085R0001X') then CLM_PRVDR_SPCLTY_CD = '92';
    if strip(PRIMARY_TAXONOMY) in ('207P00000X','207PE0004X','207PH0002X','207PT0002X','207PP0204X','207PS0010X','207PE0005X') then CLM_PRVDR_SPCLTY_CD = '93';
    if strip(PRIMARY_TAXONOMY) in ('2085R0204X') then CLM_PRVDR_SPCLTY_CD = '94';
    if strip(PRIMARY_TAXONOMY) in ('156FX1800X') then CLM_PRVDR_SPCLTY_CD = '96';
    if strip(PRIMARY_TAXONOMY) in ('363A00000X','363AM0700X') then CLM_PRVDR_SPCLTY_CD = '97';
    if strip(PRIMARY_TAXONOMY) in ('363AS0400X') then CLM_PRVDR_SPCLTY_CD = '97';
    if strip(PRIMARY_TAXONOMY) in ('207VX0201X') then CLM_PRVDR_SPCLTY_CD = '98';
    if strip(PRIMARY_TAXONOMY) in ('208D00000X') then CLM_PRVDR_SPCLTY_CD = '99';
    if CLM_PRVDR_SPCLTY_CD = '' then CLM_PRVDR_SPCLTY_CD = '87';

    &_spec_var.=CLM_PRVDR_SPCLTY_CD;

  %mend apply_specialty_taxonomy;

  proc format;
    value $cms_spec_mssp
      '01' = 'PC'
      '02' = '--'
      '03' = '--'
      '04' = '--'
      '05' = '--'
      '06' = 'SP'
      '07' = '--'
      '08' = 'PC'
      '09' = '--'
      '10' = '--'
      '11' = 'PC'
      '12' = 'SP'
      '13' = 'SP'
      '14' = '--'
      '15' = '--'
      '16' = 'SP'
      '17' = '--'
      '18' = '--'
      '19' = '--'
      '20' = '--'
      '21' = '--'
      '22' = '--'
      '23' = 'SP'
      '24' = '--'
      '25' = 'SP'
      '26' = 'SP'
      '27' = 'SP'
      '28' = '--'
      '29' = 'SP'
      '30' = '--'
      '31' = '--'
      '32' = '--'
      '33' = '--'
      '34' = '--'
      '35' = '--'
      '36' = '--'
      '37' = 'PC'
      '38' = 'PC'
      '39' = 'SP'
      '40' = '--'
      '41' = '--'
      '42' = '--'
      '43' = '--'
      '44' = '--'
      '45' = '--'
      '46' = 'SP'
      '47' = '--'
      '48' = '--'
      '49' = '--'
      '50' = 'NP'
      '59' = '--'
      '60' = '--'
      '63' = '--'
      '64' = '--'
      '65' = '--'
      '66' = '--'
      '67' = '--'
      '68' = '--'
      '69' = '--'
      '70' = 'SP'
      '71' = '--'
      '72' = '--'
      '73' = '--'
      '75' = '--'
      '76' = '--'
      '77' = '--'
      '78' = '--'
      '79' = 'SP'
      '80' = '--'
      '81' = '--'
      '82' = 'SP'
      '83' = 'SP'
      '84' = 'SP'
      '85' = '--'
      '86' = 'SP'
      '87' = '--'
      '88' = '--'
      '89' = 'NP'
      '90' = 'SP'
      '91' = '--'
      '92' = '--'
      '93' = '--'
      '94' = '--'
      '97' = 'NP'
      '98' = 'SP'
      '99' = '--'
     Other = '??';

    value $cms_proc_mssp
      '99201' - '99205' = 'PCS'
      '99211' - '99215' = 'PCS'
      '99304' - '99310' = 'PCS-POS'
      '99315' - '99316' = 'PCS-POS'
      '99318' - '99318' = 'PCS-POS'
      '99324' - '99328' = 'PCS'
      '99334' - '99337' = 'PCS'
      '99339' - '99345' = 'PCS'
      '99347' - '99350' = 'PCS'
      '99490' - '99490' = 'PCS'
      '99495' - '99496' = 'PCS'
      'G0402' - 'G0402' = 'PCS'
      'G0438' - 'G0438' = 'PCS'
      'G0439' - 'G0439' = 'PCS'
      '0521' - '0525' = 'RHC-PCS'
      Other ='';
  run;

  /* Service data categorization engine */
  data work.categorized_claims(keep=member attributed_provider QUALIFYING_SERVICE 
                                    &clm_type_var. &bill_type_1. &bill_type_2. 
                                    SOURCE_cat spec_cat care_cat &part_b_alw. 
                                    primary_taxonomy &spec_var. &serv_date.);

    set &med_services_data;

    attributed_provider=&part_b_prov.;

    /* Majority of services to be considered are PART B */
    source_cat='PARTB';
 
    /* Find Part B Claims that are submitted on Part A forms - CAH, RHC, FQHC */
    if &clm_type_var.='PART A' then do;
   
      /* By default PART A services aren't considered in PCP logic */
      source_cat='DROP';

      /* Check for the "special case" Part B services in the Part A data */ 
      if &bill_type_1.="7" 
        and &bill_type_2.="1"
        then do;
        SOURCE_CAT="RHC";
      end;
    
      if &BILL_TYPE_1. = '8' 
        and &BILL_TYPE_2. = '5'  
        and substr(&rev_var.,1,3) in ('096','097','098')
        then do;
          SOURCE_CAT='CAH';
        end;
    
      if &bill_type_1.="7" 
        and &bill_type_2.="7"
        then do;
          SOURCE_CAT="FQH";
        end;

      /* Ignore NON RHC/CAH/FQHC Part A Lines */
      if source_cat='DROP' then delete;

      /* For those service lines remaining */
      attributed_provider=&part_a_prov.;

      &part_b_alw.=&part_a_pay. * 1.25 ;

      PRIMARY_TAXONOMY = put(strip(&part_a_prov.),$spec_nps.);
      %apply_specialty_taxonomy(&spec_var.);
    
    end;/* PART A selections */
    /* NO DME sourced services are part of PCP attribution */ 
    else if &clm_type_var.='DME' then delete;

    /* Determine ACO Provider Professionals from Specialty Code*/
    spec_cat=put(&spec_var.,$cms_spec_mssp.);
    /* Part A sourced services only consider Physcians */
    if source_cat in ('RHC','CAH', 'FQH') then 
      if spec_cat not in ('SP','PC') then 
        spec_cat='--';

    /* Determine Primary Care Service from procedure code*/
    care_cat=put(proc_code,$cms_proc_mssp.);
    /* Also have to check certain rev codes for RHC services to determine Primary Care Services */
    if SOURCE_CAT in ('RHC')  then do;
      if revenue in ( '0521','0522','0524','0525') then
        care_cat=put(revenue,$cms_proc_mssp.);
    end;
 
    /* Check PCS Primary Care Services against POS 31 */
    /* "Reset" care cat based on this finding */
    if care_cat='PCS-POS' then do;
      if POS='31' then care_cat='';
      else care_cat='PCS';
    end;
    
    /* Flag Qualifying services with ACO Professional Label */
    QUALIFYING_SERVICE ='-';
    if (    spec_cat in ('SP','PC','NP') 
        and care_cat='PCS') 
      or 
       (    SOURCE_cat in ('RHC')
        and care_cat='RHC-PCS') then 

      QUALIFYING_SERVICE = '+';

  run;
  
  proc sql;/* Step 1 Assignment */
  
    /* Member-Provider services that qualify*/
    create table work.qualified_prof_providers_bene as
      select distinct member
                     ,attributed_provider
                     ,QUALIFYING_SERVICE
        from work.categorized_claims
        where QUALIFYING_SERVICE ='+'
          and (  (    spec_cat in ('NP','PC')
                  and care_cat in ('PCS')
                  )
                or care_cat= ('RHC-PCS'))
        ;

    /* PC services for the qualifying providers */
    create table work.bene_prof_provider_summ as
      select cat_clms.member
            ,cat_clms.attributed_provider
            ,sum(cat_clms.amt_all) as sum_srvs
           ,max(cat_clms.&serv_date.) as last_srv
        from work.categorized_claims cat_clms 
          right join
             work.qualified_prof_providers_bene qal 
          on cat_clms.member=qal.member 
            and cat_clms.attributed_provider = qal.attributed_provider  
        where cat_clms.care_cat in ('PCS','RHC-PCS')       
        group by cat_clms.member
                ,cat_clms.attributed_provider
        order by cat_clms.member
                ,sum_srvs desc;
    
    /* First pass to get max allowed*/
    /* Need to protect against hidden rounding issues */
    create table work.pre_bene_prof_provider_assigned as    
      select *,
             round(max(sum_srvs),.01) as max_money,
             case
               when sum_srvs>0 
                 and round(sum_srvs,.01)=round(max(sum_srvs),.01)
               then '*'
               else ' '
             end
             as check_pcp
        from work.bene_prof_provider_summ
        group by member
                ;
    /*Second pass to break ties*/
    /*Deliberately avoided nested query solution as harder to test*/
    create table work.bene_prof_provider_assigned as    
      select * 
        from work.pre_bene_prof_provider_assigned
        where check_pcp='*'
        group by member
        having last_srv=max(last_srv) 
          and attributed_provider=min(attributed_provider) /* Extra-tie breaker */
      ;

  quit;

  proc sql;/* Step 2 Assignment */
    /* Step 2 */
    create table work.qualified_spec_providers_bene as
      select distinct member
                     ,attributed_provider
                     ,QUALIFYING_SERVICE
        from work.categorized_claims
        where care_cat in ('PCS','RHC-PCS')
          and QUALIFYING_SERVICE ='+'
          and spec_cat in ('SP')
          and member not in 
                      (select member 
                         from work.bene_prof_provider_assigned 
                         where check_pcp='*')
        ;

    /* All services for the qualifying providers */
    create table work.bene_spec_provider_summ as
    select cat_clms.member
          ,cat_clms.attributed_provider
          ,sum(cat_clms.amt_all) as sum_srvs
          ,max(cat_clms.&serv_date.) as last_srv
      from work.categorized_claims cat_clms 
             right join
           work.qualified_spec_providers_bene qal 
           on cat_clms.member=qal.member 
             and cat_clms.attributed_provider = qal.attributed_provider
      where cat_clms.care_cat in ('PCS','RHC-PCS')       
      group by cat_clms.member
              ,cat_clms.attributed_provider
      order by cat_clms.member
              ,sum_srvs desc;
    
     create table work.pre_bene_spec_provider_assigned as    
       select *,
              round(max(sum_srvs),.01) as max_money,
              case
                when sum_srvs>0 
                 and round(sum_srvs,.01)=round(max(sum_srvs),.01)
                then '*'
              else ' '
              end
              as check_pcp
         from work.bene_spec_provider_summ
         group by member
        ;
    /*Second pass to break ties*/
    /*Deliberately avoided nested query solution as harder to test*/
    create table work.bene_spec_provider_assigned as    
      select * 
        from work.pre_bene_spec_provider_assigned
        where check_pcp='*'
        group by member
        having last_srv=max(last_srv)
          and attributed_provider=min(attributed_provider) /* Extra-tie breaker */;

  quit;
  /* Combine Profession Assignments and Specialist Assignments */
  proc sql;
    create table &final_assignments_data. as
      select * from bene_prof_provider_assigned
        where check_pcp='*'
        union
      select * from bene_spec_provider_assigned
        where check_pcp='*'
    ;
  quit;

%mend ii_cms_provider_pcp;
