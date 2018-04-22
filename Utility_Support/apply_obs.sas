/*!
 *
 *       Applies observations from a dataset to a macro, passing variable values to the macro parameters matching 
 *       the dataset variable name. Specific columns to be used from dataset can be specified.
 *           <p>Can be called inside a datastep
 *    		<p>Abends when called with bad parameters 
 *
 *      @author  Chris Amendola
 *      @created 01-2015
 *
 */
/**
  *    @param  to_macro      Macro function or sub-routine which uses dataset values(Positional) default:
  *    @param  from_dataset  SAS dataset with fields to be passed as macro parameters to sub-routine(Positional) default: 
  *    @param  use_cols      Specifies a list of columns to use from the dataset. default: Blank - uses all columns             
  */
	
%macro apply_obs(from_dataset,to_macro,use_cols=);

    %macro isblank(param);
      %sysevalf(%superq(&param)=,boolean)
    %mend isblank;
    
	%local _ermsg            /* Error message */
	       _curr_col         /* Current column in dataset */
	       _pair_list        /* Parameter argument pairs for macro call */
		   _driver_ds        /* Handle for driver dataset */
		   _curr_arg         /* Current macro argument */
		   _curr_parm        /* Current macro parameter */
		   _num_vars         /* Number of variables/columns in driver dataset */
		   _in_num           /* use_cols 'in-list' ennumerator */
		   _element          /* The use_cols current element being checked */
		   _add_pair         /* Adds parm-argument pair to macro call construct */
    ;
	
	%let _ermsg=;
    /**
	 * Simple validation of parms, i.e. are they populated at all? 
	 */
    %if %isblank(from_dataset) or %isblank(to_macro) 
      %then %let _ermsg=Missing argument!!!;      
    /**
	 * On error stop
	 */
    %if not %isblank(_ermsg) %then %do; 
        %put ERROR-> &_ermsg;
		%put Usage apply_obs(from dataset, to macro);
		%abort cancel;
    %end;
   
    /* Open the source dataset */
	%let _driver_ds=%sysfunc(open(&from_dataset));
	
	%if &_driver_ds=0 %then %do;
	    %put ERROR: Cant open dataset &from_dataset; 
		%abort cancel;
	%end;	
	/*
	 * Flag/boolean that indicates to add parm_argument to macro call construct.
	 */
	%let _add_pair=1;	
	/* 
	 * Set variable looping value
	 */
	%let _num_vars=%sysfunc(attrn(&_driver_ds,NVARS));
	/* 
	 * Step through the obs of the dataset.
	 */	
    %do %while(%sysfunc(fetch(&_driver_ds,NOSET))>=0);
       /* 
        * Loop through fields/columns for each obs
        */
        %let _curr_col=1;
		%do %while(&_curr_col LE &_num_vars);
		    /* Parse columns/fields to parmeters and arguments */
		    %let _curr_parm=%sysfunc(varname(&_driver_ds,&_curr_col)); /*Initialized*/
		    
		    %if not %isblank(use_cols) %then %do;
		      /* Don't add parm-argument pair to macro contruct unless found on _use_cols*/
		      %let _add_pair=0;
		      /**
	            * Scan through the use_cols elements to find a match to current col/parm;
	            */
              %let _in_num=1;
              %let _element=%scan(%quote(&_res_list),&in_num,%str( ));
   
              %do %while(%length(&_element) > 0);
		        %if &_element=&_curr_parm %then %let _add_pair=1;
                %let in_num=%eval(&in_num+1);
		        %let _element=%scan(%quote(&_res_list),&in_num,%str( ));
              %end;
		    %end;
		    
		    %if &_add_pair=1 %then %do;
		      /*
		       * Look-up argument for parm when required. 
		       */
    	      %if %sysfunc(vartype(&_driver_ds,&_curr_col))=C %then %do; 
		          /*character variable handling*/
    	          %let _curr_arg=%qsysfunc(getvarc(&_driver_ds,&_curr_col));
    	        
      	          %if %sysfunc(prxmatch("[^\w\s.]+",&_curr_arg)) 
      	            %then %let &_curr_parm=%qtrim(&_curr_arg);
      	          %else %let &_curr_parm=%trim(&_curr_arg);
      	        
    	      %end;    
    	      %else %do; 
				/* numeric variable handling*/
    	        %let &_curr_parm=%sysfunc(getvarn(&_driver_ds,&_curr_col));
    	      %end;
    	    
    	      /* Build parameter-argument pairs */
			  %if not %isblank(_pair_list) 
			    %then %let _pair_list=&_pair_list ,&_curr_parm=&_curr_arg;
			  %else %let _pair_list=&_curr_parm=&_curr_arg;
			  /* Next column/field */
			  %let _curr_col=%eval(&_curr_col+1);
			%end;
    	%end;
    	
        %&to_macro(&_pair_list)
        %let _pair_list=;		
	%end;	
	
	%let _for_i=%sysfunc(close(&_driver_ds));
	
%mend apply_obs;