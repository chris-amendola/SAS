/******************************************************************;
*       MACRO: VAREXIST.SAS                                       ;
*      AUTHOR: Tim Tian                                           ;
*DATE CREATED: 24NOV2008                                          ;
*     PURPOSE: Check if the variable exists                       ;
*                                                                 ;
* Description: This macro will return 0 if the variable doses not ;
*              exist in a given dataset, else will be 1.          ;
*                                                                 ;
*  Parameters:                                                    ; 
*             indsn: dataset name the variable is checked         ;
*             invar: variable name you want to check              ;
*                                                                 ;
* Sample call:if %varexist(indsn=crtdir.ds, invar=dsdecod) then do; 
*                   .........                                     ;
*             end;                                                ;
*                                                                 ;
*Modification:                                                    ;
******************************************************************;*/

%macro varexist(indsn=,invar=, version=1.0);
   %put =========================================================================================;
   %put <> Biogen Idec System Macro VAREXIST Version &version:;
   %put <> Check if the variable exists in a given dataset.;
   %put =========================================================================================;
  %if &version=1.0 %then %do;
  /*----------------------------------------------------------;
   * Declare local macro variables that only use in this macro;
   *----------------------------------------------------------;*/
    %local dsid ok num rc parmerr;  
    %let parmerr=0;
    %let er=er;
    %let ror=ror;
  /*------- check if INDSN is input or exist, if not, then end the macro ----*/
     %if &indsn = %str( ) %then %do;
         %put &er&ror: NO INPUT VALUE FOR <INDSN>, PLEASE INPUT DATASET NAME YOU WANT TO CHECK.;
         %let parmerr=1;
     %end;  
     %else %do;
         %if %sysfunc(exist(&indsn))=0 %then  %do;
             %put &er&ror: DATASET <&indsn> DOES NOT EXIST.;
			 %let parmerr=1;
		 %end;
     %end;
 
  /*------- check if INVAR is input, if not, then end the macro ----*/
     %if &invar = %str( ) %then %do;
         %put &er&ror: NO INPUT VALUE FOR <INVAR>, PLEASE INPUT VARIABLE NAME YOU WANT TO CHECK.;
         %let parmerr=1;
     %end;
  /*------- normal termination of the currently executing macro if PARMERR=1 ----*/
     %if (&parmerr) %then %return;

     %let dsid=%sysfunc(open(&indsn,i));
     %let ok=1;   
     %let num = %sysfunc(varnum(&dsid,&invar));
	 %if &num=0 %then %let ok=0;  
     %let rc = %sysfunc(close(&dsid));

     &ok
	%end;  /* of version loop */
     
%mend varexist;


