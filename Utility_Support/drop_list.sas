/*!
*
*    Drops a value from a macro variable list of values
*		      <p>Can be called inside a datastep
*
*    @author  Chris Amendola
*    @created    05-2015
*/
/**
* @param  _value     Value to drop from macro variable list. Required.
* @param  _from_list Name of macro variable list. Required.  
*/               
%macro drop_list( _value, 
                  _from_list
                 ,delm=);
                
  %local _return;              
  %let _return=;                
                
  %macro expression(_var);
  
    %if &_var. ^= &_value. %then %let _return=&_return. &_var.; 
  
  %mend expression;
  
  %mac_map(expression,to_list=&_from_list)
  
  %trim(&_return);
                
%mend drop_list;
