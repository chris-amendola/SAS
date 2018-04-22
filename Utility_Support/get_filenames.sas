%macro get_filenames( _location
                     ,metadata=work.file_list
                     ,filter_regex=); 

  filename _dir_ "%bquote(&_location.)";

  data &metadata.(keep=memname);
    handle=dopen( '_dir_' );
    if handle > 0 then do;
      count=dnum(handle);
      do i=1 to count;
        memname=dread(handle,i);
		%if not %isblank(filter_regex) %then %do;
		   if prxmatch("/&filter_regex/",memname) then 
		%end;
        output &metadata;
      end;
    end;
    rc=dclose(handle);
  run;

  filename _dir_ clear;

%mend get_filenames;
