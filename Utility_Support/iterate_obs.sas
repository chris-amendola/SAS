/*!
*
*       Iterates through observations from a dataset and creates macro vars from each field 
*       to be used by a named sub-routine
*           <p>Can be called inside a datastep
*    		<p>Abends SAS session when called with bad parameters 
*
*      @author  Chris Amendola
*      @created 0-2015
*
*/
/**
*    @param  sub_rtn  Macro function or sub-routine which uses dataset values(Positional) default:
*    @param  dataset  SAS dataset with fields to be passed as macro parameters to sub-routine(Positional) default:              
*/
	
%macro iterate_obs(sub_rtn,dataset);

	%local ermsg
	       _for_col
	       _var_list
		   _for_in_dataset
		   _for_itid 
		   _for_val 
		   _for_var
		   _num_vars
    ;
	
	%let ermsg=;
    /**
	 * Simple validation of parms, i.e. are they populated at all?
	 */
    %if %length(&dataset) < 3 %then %let ermsg=No dataset provided!!!;
    %if %length(&sub_rtn) < 1 %then %let ermsg=No Sub-Routine for iteration!!!;
    /**
	 * On error stop full program
	 */
    %if %length(&ermsg) > 1 %then %do;
        %put ERROR-> &ermsg;
		%put Usage iterate_obs(sub-routine or function , dataset);
	    %put ABORT ABEND!!!;
		%abort abend;
    %end;
   
	%let _for_itid=%sysfunc(open(&dataset));
	%if &_for_itid=0 %then %do;
	    %put ERROR: Cant open dataset &dataset;
	    %put ABORT ABEND!!!; 
		%abort abend;
	%end;
	%let _num_vars=%sysfunc(attrn(&_for_itid,NVARS));
    %do %while(%sysfunc(fetch(&_for_itid,NOSET))>=0);
        %let _for_col=1;
		%do %while(&_for_col LE &_num_vars);
		    %let _for_var=%sysfunc(varname(&_for_itid,&_for_col));/*Initialized*/
    	    %if %sysfunc(vartype(&_for_itid,&_for_col))=C %then %do; 
		        /**
				 * character variable
				 */
    	        %let _for_val=%qsysfunc(getvarc(&_for_itid,&_for_col));
      	        %if %sysfunc(prxmatch("[^\w\s.]+",&_for_val)) %then %let &_for_var=%qtrim(&_for_val);
      	        %else %let &_for_var=%trim(&_for_val);
    	    %end;
    	    %else %do; 
				/**
				 * numeric variable
				*/
    	        %let &_for_var=%sysfunc(getvarn(&_for_itid,&_for_col));
    	    %end;
			%if %length(&_var_list) > 0 %then %let _var_list=&_var_list ,&_for_var=&_for_val;
			%else %let _var_list=&_for_var=&_for_val;
			%let _for_col=%eval(&_for_col+1);
    	%end;
        %&sub_rtn(&_var_list)
        %let _var_list=;		
	%end;	
	%let _for_i=%sysfunc(close(&_for_itid));
%mend iterate_obs;
/************************************************************************/