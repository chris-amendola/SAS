%*-----------------------------------------------------------------------------
*  Program ID     : isblank.sas
*  Source Program : SAS Global Forum 2009 Paper 022-2009
*  Description    : Function-style macro to check if a macro parameter is blank  
*
*  Date           : 11NOV2009
*  Developer      : Srimathy Manivannan (Biogen Idec, ext 31674)
*  Programmer     : Srimathy Manivannan (Biogen Idec, ext 31674)
*
*  Input parameters: 
*                 param: Macro parameter value
*  Output parameters:
*                 boolean: 1 if blank, 0 if valid
*
*  Sample Call    : %isblank(param)
*
*  Note           : For use in all standard macro parameter checking modules
*
*  Platform       : HP-UX
*  SAS Version    : 9.2
*
*  Modifications  : 
*
--------------------------------------------------------------------------------;

%macro isblank(param);
  %sysevalf(%superq(&param)=,boolean)
%mend isblank;