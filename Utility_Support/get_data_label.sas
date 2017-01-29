%macro get_data_label(_dset);
   
    %local dsid  
	       set_label
		   rc;

    %let dsid = %sysfunc(open(&_dset));
    %if &dsid = 0 %then %put %sysfunc(sysmsg());
    %let set_label = %sysfunc(attrc(&dsid,label));
    %let rc = %sysfunc(close(&dsid));
    %if &rc ne 0 %then %put %sysfunc(sysmsg());
    
	&set_label

%mend get_data_label;
			