/*!
  *
  *  Provide a single utility-function to evaluate and verify macro argument properties.
  *  Evaluates parameter arguments in currently defined macro scope - the local scope of macro check_argument
  *  is called from.
  *  Creates a user-named global macro variable that indicates a "pass-fail" for the argument check.
  *
  *  @author Chris Amendola
  *  @created May 2016
  *
  */
/**
  *
  * @param parm           Parameter name to be checked. If left unpopulated at invocation, <br> 
  * @param isa            Object type of the parameter. Valid types:<br>
  *
  *    +CHAR: Default type for macro variables <br>
  *    +DATA: Existing/input SAS Datset <br>
  *    +VALID_DATA: To be created/output dataset <br>
  *    +VAR~{dataset}: Existing/input Dataset variable - to be found on {dataset} <br>
  *    +VALID_VAR: To be created/output dataset variable <br>
  *    +PATH: Existing/input path <br>
  *    +FILE: Existing/input file <br>
  *    +INT: Integer <br>
  *    +DEC: Decimal <br>
  *    +LIBREF: SAS Library reference<br>--- 
  *                       
  * @param required       Is parameter required to have an argument?<br>--
  * @param numeric_min    Lower bound to check for a numeric argument<br>
  * @param numeric_max    Upper bound to check for a numeric argument<br>
  * @param valid_values   Space delimited list of accpetable values for CHAR type parameters<br>
  * @param fail_var       Names a macro variable in the global space, the argument check return code.<br>--- 
  * @param list_sep       Optional list argument delimiter
  *
  * @required mac_map(module) isblank(module)
  *
  * @return &fail_var 1=Pass 0=Fail
  *
  */
%macro check_argument( parm          =                     
                      ,isa           = CHAR           
                      ,required      = N           
                      ,numeric_min   =            
                      ,numeric_max   =            
                      ,valid_values  =
                      ,fail_var      = _argument_check_code
					  ,list_sep      = %nrstr( )
                      ,verbose       = N                                
                     );

     /*Local methods*/
     /**
       * Internal Exception Handler for argument checker.<br>
       * Inserts usage description into log when exception occurs.<br>
       * Abends the job.
       *
       *    @author 
       *    @created 
       *
       * @param _desc REQUIRED Exception message
       */  	                           
     %macro check_exception(_desc);
   	   
   	    %put ****************************************;
   	    %put ;
        %put CHECK_ARGUMENT Usage exception: &_desc;
        %put CHECK_ARGUMENT: Job terminating.;
        %put ;
        %put ****************************************;
        %put Usage Description:;
        %put ;	                                                   
        %put  * @param parm           REQUIRED: Parameter name to be checked ;
        %put  * @param isa            Object type of the parameter. Valid types:;
        %put  * ;
        %put  *      +CHAR: Default type for macro variables;
        %put  *      +DATA: Existing/input SAS Datset ;
        %put  *      +VALID_DATA: To be created/output dataset ;
        %put  *      +VAR~{dataset}: Existing/input Dataset variable - to be found on {dataset} ;
        %put  *      +VALID_VAR: To be created/output dataset variable ;
        %put  *      +PATH: Existing/input path ;
        %put  *      +FILE: Existing/input file ;
        %put  *  	 +INT: Integer ;
        %put  *  	 +DEC: Decimal ;
        %put  *  	 +LIBREF: SAS Library reference;
        %put  *    ;                   
        %put  * @param required       Is parameter required to have an argument?;
        %put  * @param numeric_min    Lower bound to check for a numeric argument;
        %put  * @param numeric_max    Upper bound to check for a numeric argument;
        %put  * @param valid_values   Space delimited list of accpetable values for CHAR type parameters;
        %put  * @param fail_var       Names a macro variable in the global space, the argument check return code.; 
        %put  * @param list_sep       Optional list argument delimiter;
        %put  * ;
        %put  * @return &fail_var 1=Pass 0=Fail;
        %put ;
        
        /* Reset options */
        options &_notes 
                lineSize=&_linesize 
                &_mprint 
                &_mlogic 
                &_symbolgen;
        
        %abort cancel;
        
     %mend check_exception;

     /**
       * Argument Fails method. <br>
       * Delivers fail condition message to log <br>
       * and sets &fail_var to zero, aka 'FAIL'
       *
       *    @author 
       *    @created 
       *
       * @param fail_message Failure condition message
       */
     %macro the_check_failed(fail_message);
     	 
         %put Argument Check Failed!;
     	 %put %upcase(&_for_macro): &fail_message;
     	 %put ;
         %let &fail_var = 0;
     	
     %mend the_check_failed;
     /**
       * Evaluate a string for use in an object type context <br>
       * Example: Is "temp" a valid dataset? <br>
       * Example: Is 27 an integer? <br>
       *
       *    @author 
       *    @created 
       *
       * @param _value String to be evaluated as a given "type"
       * @param _type Type to evalue string 
       */
     %macro type_check( _value=
     	               ,_type=);
     	                 
         %local _valid_argument_types;	  
     	   /** Valid argument types - list based */
         %let _valid_argument_types = CHAR, DATA, VALID_DATA, VAR, VALID_VAR, PATH, FILE, INT, DEC, LIBREF;
    	                                     
         %let _type = %upcase(&_type);
                                             
         %if %quote(&_type) = DATA %then %do;
         	
             %if not (%sysfunc(exist(&_value)) or %sysfunc(exist(&_value,VIEW)))  %then
                 %the_check_failed((Parameter &parm: Input dataset (&_value) does not exist.));
             
         %end;	
         /* Type Var has special format VAR~{dataset}*/
         %else %if %upcase(%substr(&_type,1,3)) = VAR %then %do;
         	
             /*Split off filname*/
             %let _variable_dataset=%substr(&_type,5);
             
             /*Variable name construction valid*/
             %if not %sysfunc(nvalid(%quote(&_value),V7)) %then
                 %the_check_failed((Parameter &parm: "&_value" is not a valid SAS variable name.));
                 
             /*Is the comparator dataset in existence*/
             %else %if not %sysfunc(exist(&_variable_dataset))  %then
                 %the_check_failed((Parameter &parm: Dataset &_variable_dataset does not exist.));
                 
             /* Does the variable exist on the dataset*/
             %else %do;
                 %let _dsid = %sysfunc(open(&_variable_dataset,i));
                 %if not &_dsid %then
                     %the_check_failed((Parameter &parm: Dataset-> &_variable_dataset failed to open!));
                 %else %if not %sysfunc(varnum(&_dsid,&_value)) %then
                     %the_check_failed(Parameter &parm: The variable (&_value) does not exist in the dataset (&_variable_dataset).);
                 %let _clean = %sysfunc(close(&_dsid.)); 
             %end;     
                                                  
         %end;
         %else %if %quote(&_type) = PATH 
                or %quote(&_type) = FILE %then %do;
         	
         	   %if not %sysfunc(fileexist(&_value)) %then
         	       %the_check_failed((Parameter &parm: Input file or path (&_value) does not exist.));
         	
         %end;       
         %else %if %quote(&_type) = INT %then %do;
         	
            %if %sysfunc(verify(&_value,-0123456789))>0 
                or %sysfunc(countc(&_value,'-')) > 1
                or %sysfunc(find(&_value,-))>1 %then
                  %the_check_failed(Parameter &parm: The value (&_value) is not a valid integer.);
                  
         %end;
         %else %if %quote(&_type) = DEC %then %do;
         	
            %if %sysfunc(verify(&_value,-0123456789.))>0
                or %sysfunc(countc(&_value,'.')) ^= 1 
                or %sysfunc(countc(&_value,'-')) > 1
                or %sysfunc(find(&_value,-))>1 %then
                %the_check_failed(Parameter &parm: The value (&_value) is not a valid decimal.);        	
                
         %end;
         %else %if %quote(&_type) = LIBREF %then %do;
         	
             %if  %quote(%sysfunc(pathname(&_value, L))) = %str( ) %then		 
                 %the_check_failed(Parameter &parm: The libref specified (&_value) does not exist.);
               	
         %end;
         %else %if %quote(&_type) = VALID_VAR %then %do;
		         /*Variable name construction valid*/
             %if not %sysfunc(nvalid(%quote(&_value),V7)) %then
                 %the_check_failed((Parameter &parm: "&_value" is not a valid SAS variable name.));

         %end;
         %else %if %quote(&_type) = VALID_DATA %then %do;
         	   
             %if %index(&_value,%nrstr(.))>0 %then %do;
                 %let _check_libname=%scan(&_value.,1,%nrstr(.));
                 %let _check_dataset=%scan(&_value.,-1,%nrstr(.));
             %end;
         	   %else %do;
         	       %let _check_libname=work;
                 %let _check_dataset=&_value;
         	   %end;

             %if %sysfunc(mvalid(%quote(&_check_libname), %quote(&_check_dataset), data, EXTEND))=0 %then
                 %the_check_failed((Parameter &parm: "&_value" is not a valid dataset name.));             
	
         %end;
         %else %if %quote(&_type) = VALID_FILE %then %do;
             
             %exception((TYPE VALID_FILE has been deprecated.));
             
         %end;
         %else %if %quote(&_type) = CHAR %then %do;
             /**
               * Logical Place Holder
               */	
         %end;
         %else %do;
         	
             %check_exception(("&isa" not a valid Type. Valid Types: &_valid_argument_types));
         	
         %end;    	   
     	   
     %mend type_check;

    /*Start main body of module*/
    /* Case Control Arguments */
    %let isa = %upcase(&isa);
    %let required= %upcase(&required);
    %let valid_values = &valid_values;
    %let verbose = %upcase(&verbose);
   
    %local _notes
           _mprint
           _symbolgen
           _mlogic
           _linesize
           _variable_check_dataset
           _calling_macro_found
           _variable_dataset
		   _for_num
		   _element
		   _check_libname
		   _check_dataset
           _for_macro;

    /* Capture Current SAS options */
    %let _notes = %sysfunc(getoption(notes));
    %let _mprint = %sysfunc(getoption(mprint));
    %let _symbolgen = %sysfunc(getoption(symbolgen));
    %let _mlogic = %sysfunc(getoption(mlogic));
    %let _linesize = %sysfunc(getoption(linesize));  
     /*
      * Initialize Failure Variable if it doesn't exist
      */                          
    %if %symglobl(&fail_var) ne 1 %then %do;
        %if %upcase(&verbose) = Y %then %do;
	        %put ****************************************;
   	        %put ;
            %put CHECK_ARGUMENT Creating Global Macro Variable &fail_var!;
            %put ;
            %put ****************************************;
		%end;
        /**
          * Generates a global macro variable
          * which is active for the entire 
          * job/session.
          */ 
        %global &fail_var;
		                                                 
    %end;
    /**
      * Failure Variable starts set to one/TRUE - "Fail"=0
      */ 
	%let &fail_var = 1;
       
    %if &verbose = N %then %do;
        options nonotes 
                nomprint 
                nosymbolgen 
                nomlogic 
                linesize=132;
    %end;
    %else %put VERBOSE MODE ON.;
                          	 
    /* check_argument settings check */ 		
    /* parm cannot be null */
	%if %isblank(parm) %then
        %check_exception((parm cannot be missing, please specify a value.));
      
    /* Source Macro Valid*/
    %let _for_macro=%sysmexecname(%sysmexecdepth-1);
    
    %let _calling_macro_found=0;  
    proc sql noprint;
        select count(*) into: _calling_macro_found 
    	    from sashelp.vmacro    
    	    where upcase(scope) = "%upcase(&_for_macro)"
    	;
    quit;
    
    %if &_calling_macro_found < 1 %then 
        %check_exception((Calling macro: &_for_macro does not exist, please check setting.));
    
    /* Start Argument Evaluation */
    /* Resolve argument */
    data _null_;
        length macro_value $32767;
        retain macro_value ' ';
      
        if eof then call symput('_argument_list', trim(macro_value));
      
        set sashelp.vmacro(    where=(upcase(scope) = "%upcase(&_for_macro)" 
                                    and upcase(name) = "%upcase(&parm)")) 
            end=eof;
        substr(macro_value, offset + 1,200) = value;
    run;
    
    /* Required parm(argument_list) is not null */
    %if     &required = Y 
	    and %quote(&_argument_list) = %str( ) %then
        %the_check_failed((Macro Parameter &parm is required but no value was passed.));

	/**
	  * Captures the main activities of the module into a
	  * "method" that can be list evaluated or "looped" for a list
	  * of argument values.
	  *
      *    @author 
      *    @created 
      *
      * @param _argument A single element from an argument list 
      */
	%macro parse_argument_list(_argument);
        /* Argument is assigned type */
        %if %quote(&_argument) ^= %str( ) 
            %then %type_check( _value=&_argument
     	                      ,_type=&isa);
     	          
        /* Numeric type in range */
        /* Notice that type has already been validated */
        %if %quote(&isa) = INT 
           or %quote(&isa) = DEC %then %do;
       	
		    %if not(%isblank(numeric_min)) %then %do;
                %if %sysfunc(inputn(&numeric_min,best12.)) = . %then
                    %check_exception((numeric_min: "&numeric_min" is not a valid numeric value.)) ;
                %if %sysevalf(&_argument < &numeric_min) %then
                    %the_check_failed(Parameter &parm: The value (&_argument) is less than the minimum value (&numeric_min).);
                 
            %end;
            %if not(%isblank(numeric_max)) %then %do;
                %if %sysfunc(inputn(&numeric_max,best12.)) = . %then
                    %check_exception((numeric_max: "&numeric_max" is not a valid numeric value.)) ;
                %if %sysevalf(&_argument > &numeric_max) %then
                    %the_check_failed(Parameter &parm: The value (&_argument) is greater than the maximum value (&numeric_max).);    
            %end; 	
        %end;
    
        /* Fails if argument(char) not on valid values list */
        %if %length(&valid_values)>1 %then %do;
            /* Fails unless argument on list*/
            %let _found_on_list=0;

		    %let _for_num=1;
            %let _element=%scan(&valid_values.,&_for_num,%nrstr( ));
            %do %while(%length(&_element) > 0);
		        %if &_element = &_argument %then %let _found_on_list=1;
                %let _for_num=%eval(&_for_num+1);
		        %let _element=%scan(&valid_values.,&_for_num,%nrstr( ));
            %end;

            %if &_found_on_list = 0 %then
		        %the_check_failed(Parameter &parm: "&_argument" not in list-> &valid_values.);

        %end;
    %mend parse_argument_list; 

	%if %quote(&_argument_list) ^= %str( ) %then
        %mac_map(parse_argument_list,to_list=_argument_list,sep=&list_sep);

    /* Reset options */
    options &_notes 
            lineSize=&_linesize 
            &_mprint 
            &_mlogic 
            &_symbolgen;   
   
%mend check_argument;
