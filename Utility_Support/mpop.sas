%************************************************************;
%***; 
%*** Title:         mpop.sas                                 ;
%***; 
%*** Type: utility macro                                     ; 
%***; 
%*** Func/Desc:  "Pops" the lead element from a delimited    ;
%***             list (in a macro var) into a named macro    ;
%***             variable. (Element is removed.)             ;
%***;
%*** Input:   Macro parameters vname, list and delm.         ;  
%***; 
%*** Output:  Variable "vname" and "list" minus lead element ;
%***; 
%*** Usage: %pop( mname = {valid macro variable name}        ;
%***             ,mlist = {name of macro variable containing  ;
%***                      delimited list}                    ;
%***             ,mdlm = {single character delimiter})       ; 
%***;    
%***********************************************************;
%***                                                     ***;
%*** Author: Christopher Amendola                        ***;
%***                                                     ***;
%*** Date: 09/17/2002                                    ***;
%***                                                     ***; 
%*** Modifications:                                      ***;
%***                                                     ***;
%***      xx/xx/xxxx      XXXXXXXXXXXXXXXXXXXXXXXXXXX    ***;
%***                                                     ***; 
%***                                                     ***; 
%***********************************************************; 

/************************************************************************/

%macro mpop( mname =       /* Variable to contain the "popped" element */
            ,mlist =       /* Name of the delimited list */
            ,mdlm =        /* Delimiter */
            );

/***********************************************************************/

  %global &mname;
  %*** Set default delimiter is none is passed. ***;
  %if %length(&mdlm) = 0 %then %let mdlm = !;  

  %*** Find the first delimiter. ***;
    %*** No delimiter indicates single element list. ***;
    %let ablank = %index(&&&mlist,&mdlm);
   
    %if &ablank = 0 %then %do;
        %let &mname = &&&mlist;
        %let &mlist =;
    %end;
   %*** Set variable and remove lead element. ***;
    %if &ablank ne 0 %then %do;    
        %let mvalue = %substr(&&&mlist,1,%eval(&ablank - 1));
        %let &mlist = %substr(&&&mlist,%eval(&ablank + 1));
        %let &mlist = %left(&&&mlist);
        %let &mname = &mvalue;
    %end;    


/*********/    
%mend mpop;
/*********/
