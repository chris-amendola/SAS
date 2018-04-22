/*! 
 *  Evalues a macro variable value for its' compatibility for use in a specific context, evaluates if the value would be
 * of a 'type'.
 *  Functional Type macro returns a 1 if the type check is a match and 0 if it is not a match.
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2015
 */
/**  
  * @param _valid_type Required. Context or 'type' to evaluate the value for its compatibility.
  *   Valid types:<br>
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
  * @param _argument   Required. Macro variable to be evaluated.
  *
  * @return 1 if true, 0 if false 
  */
%macro is_a( _valid_type
            ,_argument);   

     %local _return;
     %let _return=1;/* 'TRUE' */
     
     %macro exception(_desc);
   	   
       %put ****************************************;
   	   %put ;
       %put IS_A: Usage exception: &_desc;
       %put IS_A: Job terminating.;
       %put ;
       %put ****************************************;
        
       %abort cancel;
        
     %mend exception;
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
             %if not %sysfunc(exist(&_value)) %then 
               %let _return=0;
         %end;	
         
         /* Type Var has special format VAR~{dataset}*/
         %else %if %upcase(%substr(&_type,1,3)) = VAR %then %do;
         	
             /*Split off filname*/
             %let _variable_dataset=%substr(&_type,5);
             
             /*Variable name construction valid*/
             %if not %sysfunc(nvalid(%quote(&_value),V7)) %then 
               %let _return=0;
                                  
             /*Is the comparator dataset in existence*/
             %else %if not %sysfunc(exist(&_variable_dataset)) %then 
               %let _return=0;
             
             /* Does the variable exist on the dataset*/
             %else %do;
                 %let _dsid = %sysfunc(open(&_variable_dataset,i));
                 %if not &_dsid %then 
                   %let _return=0;
                 %else %if not %sysfunc(varnum(&_dsid,&_value)) %then 
                   %let _return=0;
             %end;     
                                                  
         %end;
         %else %if %quote(&_type) = PATH 
                or %quote(&_type) = FILE %then %do;
         	
         	   %if not %sysfunc(fileexist(&_value)) %then 
         	     %let _return=0;
         	
         %end;       
         %else %if %quote(&_type) = INT %then %do;
         	
            %if %sysfunc(verify(&_value,-0123456789))>0 
                or %sysfunc(countc(&_value,'-')) > 1
                or %sysfunc(find(&_value,-))>1 %then 
              %let _return=0;
                  
         %end;
         %else %if %quote(&_type) = DEC %then %do;
         	
            %if %sysfunc(verify(&_value,-0123456789.))>0
                or %sysfunc(countc(&_value,'.')) ^= 1 
                or %sysfunc(countc(&_value,'-')) > 1
                or %sysfunc(find(&_value,-))>1 %then  
              %let _return=0;        	
                
         %end;
         %else %if %quote(&_type) = LIBREF %then %do;
         	
             %if  %quote(%sysfunc(pathname(&_value, L))) = %str( ) %then  
               %let _return=0;
               	
         %end;
         %else %if %quote(&_type) = VALID_VAR %then %do;
		         /*Variable name construction valid*/
             %if not %sysfunc(nvalid(%quote(&_value),V7)) %then
                 %let _return=0;

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
                  %let _return=0;            	
         %end;
         %else %if %quote(&_type) = CHAR %then %do;
             /**
               * Logical Place Holder
               */	
         %end;
         %else %do;
         	
             %exception(("&_type" not a valid Type. Valid Types: &_valid_argument_types));
         	
         %end;    	   
     	   
     	 %trim(&_return)
     	 
     %mend type_check;
     
     %type_check( _value=&_argument
                 ,_type=&_valid_type)
     
%mend is_a;  
/* Demo code */

%macro demo();

  %let numeric_var=5;
  %let text_var=fg;

  %if %is_a(int,&numeric_var) %then %put %trim(&numeric_var) is an integer.;
  %else %put %trim(&numeric_var) is NOT an integer.;

  %if %is_a(int,text_var) %then %put %trim(&text_var) is an integer.;
  %else %put %trim(&text_var) is NOT an integer.;
  
  %if %is_a(char,text_var) %then %put %trim(&text_var) is text.;
  %else %put %trim(&text_var) is NOT text.;


%mend demo;

