%macro require_vars(_chk_var_list_);                   
 
  %macro check_macro_var_exists(_macvar_);
    %if (not %symexist(&_macvar_.)) %then %do;
      %put Required Macro Variable &_macvar_. not found in any working scope.;
      %put ABORT CANCEL.;
      %abort cancel;
    %end;
  %mend check_macro_var_exists;
  
  %mac_map(check_macro_var_exists,to_list=_chk_var_list_);
  
%mend require_vars;