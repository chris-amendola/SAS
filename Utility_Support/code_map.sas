/*!
*
*        Maps elements from a list into a sas code
*		     <p>Can be called inside a datastep - if _code allows.
*			  <p>Abends SAS session on bad parameter setting
*
*    @author  Chris Amendola
*    @created    07-2016
*/
/**
* @param  _list    Name of macro var with space delimited list of elements to map into code. Positional. Required.
* @param  _code    SAS code to be list mapped. Positional. Required.
* @param  _itr     Macro variable name for list value to be applied in code. Positional. Required.
*/                
%macro code_map(_list,_itr,_code); 
  /* Force an abend here? */
  %if %sysevalf(%superq(_code)=,boolean) 
    %then %put MISSING ONE OR MORE REQUIRED ARGUMENTS!!!;
    
  %local _local i ;
       
  /* Does passed code contain macro operations? */     
  %if %eval( %index(&_code,%nrstr(%if))
            +%index(&_code,%nrstr(%do))) %then %do;
      
    /* Construct a macro */  
    %unquote(%nrstr(%macro) _local_code( ); &_code. %nrstr(%mend _local_code;))
    
    %let _local=%nrstr(%_local_code)( );
    
  %end; 
  %else %let _local=&_code.;
  
  %do i=1 %to %sysfunc(countw(&&&_list.));
  
    %let &_itr.=%scan(%quote(&&&_list.),&i,%str( ));
  
    %unquote(&_local.)
    
  %end;
  
%mend code_map;