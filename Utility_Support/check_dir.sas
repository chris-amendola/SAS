/*!    
*
*       Checks for the existance of a specified directory and returns either a log message or YES/NO value
*         <p>-Functional style macro eg %let _test_dir=%check_dir(/path/path/path)
*		  <p>-Can be called inside or outside of a datastep
*
*      @author  Chris Amendola
*      @created  March 23rd 2015
*
*/
/**
*
* @param   _dir	 Directory path to check(Positional)default:
* @param  report Format of returned value(Keyword)default:MESSAGE
*
* @return  Text value either YES/NO or a log message
*
*/
%macro check_dir( _dir
                 ,report=MESSAGE);
    %local return;
	%let return=;
	
    %if ((%upcase(&report) ne MESSAGE) and (%upcase(&report) ne CODE)) %then %do;
	    %put WRONG SPECIFICATION --> return -> MESSAGE or CODE;
		%abort abend;
    %end;	
    %else %do;    
        %put Checking for &_dir....;	
        %let rc = %sysfunc(filename(_fileref,&_dir)) ; 
        %if %sysfunc(fexist(&_fileref)) %then %do;
		    %if &report eq MESSAGE %then %let return=---->Directory: &_dir Exists;
		    %else %let return=TRUE;
        %end;		
        %else %do;
            %if &report eq MESSAGE %then %let return=----> Directory: &_dir Does not Exist!!!;
            %else %let return=FALSE;		
        %end;
	%end;

    &return	
	
%mend check_dir;