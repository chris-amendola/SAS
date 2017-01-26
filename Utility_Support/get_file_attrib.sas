/*!
  *  Function for returning file attributes.
  *  -Attribute names and return values are OS-specific.
  *  -Can be invoked inside a datastep.
  *
  * @created June 2016
  * @author Chris Amendola  
  *
  */
/**
  *
  * @param _attrib Required. Positional. OS specific attribute name
  * @param for_file Required. Named. Fully specified path and file name.
  *
  */

%macro get_file_attrib(_attrib, for_file=);

  %local return_filename
         return_file
         _src
         close_code
         _return;       

  %let _src=fsource;

  %let return_filename=%sysfunc(filename(_src,&for_file));
  
  %if &return_filename^=0 %then %do;
    %put EXCEPTION: Cannot create filehandle for &for_file as specified!;
    %abort cancel;
  %end;

  %let return_file=%sysfunc(fopen(fsource,i));
  %if &return_file<1 %then %do;
  	%put EXCEPTION: File &for_file cannot be opened as specified!;
    %abort cancel;
  %end;
 
  %let _return=%sysfunc(finfo(&return_file, &_attrib));

  %let close_code=%sysfunc(fclose(&return_file));
 
  /** Return Value */
  &_return
 
%mend get_file_attrib;