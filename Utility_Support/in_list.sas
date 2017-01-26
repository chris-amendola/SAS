  %macro main;
  %include "/biostats/macros/dolist.sas";
  %macro in_list(_mac_var,_val_list);

      %local _after_first_element
             _return
      ;
      %let _after_first_element=0;
      %let _return=0;

      %macro expression(_var);

        %if &_mac_var = &_var %then %let _return=1;

      %mend expression;
      
	  %dolist(expression,list=&_val_list,sep=|)
    
	  %left(&_return)

  %mend in_list;
  
  options mprint;
  %let test_val=%in_list(fred,bill|john|bob|fred);
  %put TEST_VAL: &test_val;
  %put INLINE: %in_list(fred,bill|john|bob|fred);
  
  %if (%in_list(fred,bill|john|bob|fred)) %then %put DONE!;
  %else %put MORE WORK :(!!!;

 %mend main;
 %main;