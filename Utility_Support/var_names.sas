/*!
*
*       Function-like macro which returns a space delimited list of fieldnames from the named dataset
*            <p>Can be called inside a datastep
*            <p>Abends SAS session if non-existant dataset is named			  
*
*       @author  Chris Amendola
*       @created  04-2015
*
*/

/**
*@param  -dataset  Fully specified dataset name (Positional) default:                 	    			
*/

%macro var_names(dataset,_type=);
    
    %local _itid
	       _num_vars
		   _fetch_return
		   _col
		   _var
		   _return
		   _var_list_
		   ;

    %if %length(&dataset) < 3 %then %do;
	    %put No dataset provided!!!;
		%abort abend;
	%end;
	
	%let _itid=%sysfunc(open(&dataset));
	
	%if &_itid=0 %then %do;
	    %put ERROR: Can not open dataset &dataset;
	    %put ABORT ABEND!!!;
		%abort abend;
	%end;
	
	%if not( %upcase(&_type.) = C 
	        or %upcase(&_type.) =N
	        or &_type=%str())  %then %do;
	  %put ERROR: Parameter _type error - Valid settings: N n C c or blank.!;
	  %put ABORT ABEND!!!;
	  %abort abend;
	%end;
	
	%let _fetch_return=%sysfunc(fetch(&_itid,NOSET));
	%let _num_vars=%sysfunc(attrn(&_itid,NVARS));
	%let _col=%eval(&_col+1);
	%do %while(&_col <= &_num_vars);
	    
	    %let _fmt=%sysfunc(varfmt(&_itid,&_col));
	    %let _vtype=%sysfunc(vartype(&_itid,&_col));
	    
	    %if ( &_type. ^= %str( ) 
	         and %upcase(&_type.)=&_vtype.)
	        or (&_type.=%str())      
	        %then %do;
	      /*Find Dates???*/  
	      %let _var=%sysfunc(varname(&_itid,&_col));
		  %if %length(&_var_list_) > 0 %then %let _var_list_=&_var_list_ &_var;
		  %else %let _var_list_=&_var;
		%end;  
		
		%let _col=%eval(&_col+1);
	    
	%end;
	
	%let _return=%sysfunc(close(&_itid));
	
	&_var_list_
	
%mend var_names;

/* Basic testing - 
libname _src_ "/home/chris.amendola/library/Healthcare/data/";
%let _var_list=%var_names(_src_.claims2,_type=C);
%put &_var_list;
*/