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

%macro var_names(dataset);

    %local _itid
	       _num_vars
		   _fetch_return
		   _col
		   _var
		   _return
		   _var_list
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
	%let _fetch_return=%sysfunc(fetch(&_itid,NOSET));
	%let _num_vars=%sysfunc(attrn(&_itid,NVARS));
	%let _col=%eval(&_col+1);
	%do %while(&_col <= &_num_vars);
	    %let _var=%sysfunc(varname(&_itid,&_col));	
		%if %length(&_var_list) > 0 %then %let _var_list=&_var_list &_var;
		%else %let _var_list=&_var;
		%let _col=%eval(&_col+1);
	%end;
	%let _return=%sysfunc(close(&_itid));
	
	&_var_list
	
%mend var_names;