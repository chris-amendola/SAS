/*!
  *  Function for returning all files in a specified directory
  *  -Can be invoked inside a datastep
  * @created June 2016
  * @author Chris Amendola  
  *
  */
/**
  *
  * @param _read_dir Required. Positional. OS valid directory path.
  *
  */
%macro files_in(_read_dir);

  %if not %sysfunc(fileexist(&_read_dir)) %then %do;
    %put EXCEPTION:;
    %put ---Path: %_read_dir does not exist.;
    %put Terminating Process!;
    %abort cancel; 
  %end;

  %local directory_handle
         return_filename
         directory
         file_counter
         final_list
         _src
         rc;

  %let final_list=;
    
  %let _src=source;
  %let return_filename=%sysfunc(filename(_src,&_read_dir));
  
  %if &return_filename^=0 %then %do;
    %put EXCEPTION: Cannot create filehandle for &_read_dir as specified!;
    %abort cancel;
  %end;
  
  %let directory=%sysfunc(dopen(source));
  
	%if &directory<1 %then %do;
  	%put EXCEPTION: Directory &_read_dir cannot be read as specified!;
    %abort cancel;
  %end;
  
	%do file_counter=1 %to %sysfunc(dnum(&directory));
	  %let final_list=&final_list. %sysfunc(dread(&directory,&file_counter));
	%end;

  %let rc=%sysfunc(dclose(&directory));

  /** Return value*/
  &final_list

%mend files_in;
