/*! 
 *       Simple wrapper to ease testing if macro variable is un-initialized.
 * 
 *        @author     C Amendola 
 *       
 *         @created    August 2017 
 */
/**  
  * @param param Required. No Default. Macro variable to be checked.
  *  
  */
%macro isblank(param);
  %sysevalf(%superq(&param)=,boolean)
%mend isblank;
