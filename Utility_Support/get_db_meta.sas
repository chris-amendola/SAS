/**
  *
  * <p> Accesses the Phoenix System Db to acquire Domain dataset structure metadata.
  *
  * <p> Requires the following global macro vars to be set: chrProgram, chrProtocol, chrAnaltype.
  *
  *
  * @author  Chris Amendola
  * @created December 2017
  *
  *
  * @param domain_name        eSpec Dataset definition - Required
  * @param meta_data          specification of attribute metadata dataset - defaults to work.domain_espec 
  * @param espec_keep_cols    List of espec columns to be returned - will return all vars if left blank
  *
  */ 

%macro get_domain_espec( domain_name  =
					    ,meta_data = work.domain_espec
					    ,espec_keep_cols= 
                        );

     /*Local methods*/
     /**
       * Internal Exception Handler.<br>
       * Inserts usage description into log when exception occurs.<br>
       * Cancels the job.
       *
       * @param _desc REQUIRED Exception message
       */  	                           
     %macro exception(_desc);
   	   
   	    %put ****************************************;
   	    %put ;
        %put GET_DOMAIN_ESPEC: Usage exception: &_desc;
        %put GET_DOMAIN_ESPEC: Job terminating.;
        %put ;
        %put ****************************************;
        %put ;
        
        /* Reset options */
        options &_notes 
                lineSize=&_linesize 
                &_mprint 
                &_mlogic 
                &_symbolgen;
        
        %abort cancel;
        
     %mend exception;
	 /** 
	   * Local Macro variables
	   */
     %local _notes
            _mprint
            _symbolgen
            _mlogic
            _linesize
		    _study_id
			_dset
			_dsid
			_nobs
		    program_count
		    study_count
		    project_count
		    dataset_count
     ;
    /**
	  * Capture Current SAS options 
	  */
    %let _notes = %sysfunc(getoption(notes));
    %let _mprint = %sysfunc(getoption(mprint));
    %let _symbolgen = %sysfunc(getoption(symbolgen));
    %let _mlogic = %sysfunc(getoption(mlogic));
    %let _linesize = %sysfunc(getoption(linesize));  
     /** 
	   * Are global study vars created and set?
	   */
     %if %symglobl(chrProgram) ne 1 %then 
         %exception((Macro Variable chrProgram does not exist!));

     %if %symglobl(chrProtocol) ne 1 %then 
	     %exception((Macro Variable chrProtocol does not exist!));

     %if %symglobl(chrAnaltype) ne 1 %then 
         %exception((Macro Variable chrAnaltype does not exist!));

	   %if %isblank(chrProgram) %then 
         %exception((Macro Variable chrProgram is blank!));

     %if %isblank(chrProtocol) %then 
	     %exception((Macro Variable chrProtocol is blank!));

     %if %isblank(chrAnaltype) %then 
         %exception((Macro Variable chrAnaltype is blank!));
    /** 
	  * Create libname to MYSQL metadata
	  */
    libname phoenix MYSQL SERVER=&mysqlserver 
                     USER=&mysqluser 
                 PASSWORD=&mysqlpass 
                 DATABASE='define2_betax' 
               MYSQL_PORT=&mysqlport 
               DBMAX_TEXT=8000;
	/**
      * Verify the chrProgram, chrProtocol and chrAnaltype
	  * variable settings.
	  */
    proc sql noprint;
        /** Does the Product Exist? */
        select count(*)
            into: program_count 
            from phoenix.variablelist
		    where strip(upcase(biib_product)) = strip(upcase("&chrProgram"))
        ;
	    /** Does the study Exist? */
        select count(*)
            into: study_count 
            from phoenix.variablelist
		    where strip(upcase(biib_product)) = strip(upcase("&chrProgram"))
		      and strip(upcase(biib_study)) = strip(upcase("&chrProtocol"))
        ;
	     /* 
		  * Does the Project Exist? 
		  * A study_id indicates it does.
		  */
        select unique study_id
            into: _study_id 
            from phoenix.variablelist
		    where strip(upcase(biib_product)) = strip(upcase("&chrProgram"))
		      and strip(upcase(biib_study)) = strip(upcase("&chrProtocol"))
              and strip(upcase(biib_project)) = strip(upcase("&chrAnaltype"))
        ;
	    /*
		 * Does table Exist? 
		 * Look for it in valuelist and virtual_variable_item.
		 */
        select count (dataset_name)
            into: _value_table_ref_count 
            from phoenix.valuelist
		    where study_id = &_study_id
			  and strip(upcase(dataset_name)) = strip(upcase("&domain_name"))
        ;
		select count(dataset_target)
		  into: _virtual_table_ref_count
		  from phoenix.virtual_variable_item
		  where study_id=&_study_id
		    and strip(upcase(dataset_target)) = strip(upcase("&domain_name"))
		;
    quit;

    %if &program_count < 1 %then
	    %exception((chrProgram: &chrProgram not found in eSpec!));    
    %if &study_count < 1 %then
	    %exception((chrProtocol: &chrProtocol not found in eSpec!));
    %if %isblank(_study_id) %then
	    %exception((chrAnaltype: &chrAnaltype not found in eSpec!));
    %if &_value_table_ref_count<1 and &_virtual_table_ref_count<1 %then
	    %exception((Dataset: &domain not found in eSpec!));
    /** 
	  * Validate parameter arguments
	  */
    %check_argument( parm=domain_name                      
                    ,isa=CHAR                    
                    ,required=Y);

    %check_argument( parm=meta_data
                    ,isa=VALID_DATA
                    ,required=Y);
	
    %check_argument( parm=espec_keep_cols
	                ,isa=VALID_VAR
					,required=N);	
									
	/** 
	  * Stop process on bad argument
	  */
    %if &_argument_check_code = 0 %then %do;  
        %put Bad argument(s) found in GET_DOMAIN_ESPEC-invocation.;      
        %put Ending Now.;
        %abort cancel;
    %end;
	/**
	  * Main process begins
	  */
	/* Get dataset label from dataset table*/

    /* Select 'native' dataset variables */
    data work.native_dataset_vars;
        set phoenix.variablelist(rename=(dataset_name=dataset_target)
                                    where=( study_id=&_study_id 
                                           and dataset_target="&domain_name")
                                 )
	    ;
        /* In the case of 100% linked variable datasetss there will be zero-obs in
	     * native_dataset_vars. Need to know that to 'optimize' the final attributes
	     * assembly - obs count is required*/
		call symput('_nobs',_n_);
        if upcase(data_type) in ("TEXT","DATETIME") then
		sas_type=2;
		else sas_type=1; 
    run;
	%put LOOKHERE: &_nobs;

    /* Find 'virtual' variables links if they exist */
    data work.dataset_virtual_vars(keep=study_id dataset_target dataset_source name order_number);
        set phoenix.virtual_variable_item(where=(study_id=&_study_id 
                                                 and dataset_target="&domain_name"
                                                 and rev_number=1));
    run;
    
    /* Acquire virtual variable attribs from variable list - key: study_id, dataset_source*/
    data &meta_data(drop=find_rc def_rc
	                  %if (not %isblank(espec_keep_cols)) %then keep=&espec_keep_cols.;);

	  attrib order_number length=8;
	    
        if _N_=1 then do;
            declare Hash vvars(dataset: 'work.dataset_virtual_vars');              
                def_rc = vvars.DefineKey('study_id','dataset_source','name'); 
                def_rc = vvars.DefineData('name','order_number');    
                def_rc = vvars.DefineDone(); 	    
	    end;
	    
        /* Output "native" dataset attributes */

		/* If there are no native vars then skip this step
		 * The second do until bombs if this one reads a zero-obs
		 * dataset - SAS idiosyncracy*/
        %if not(%isblank(_nobs))  %then %do;
	      do until(_DONE_NATIVE);
	        set work.native_dataset_vars
              end=_DONE_NATIVE;
			/* Legacy scrub for work-around in Phoenix*/
			if upcase(name)="DUMMY" then delete;
	        output;
          end;
        %end;
	    /* Select virtual variable attributes from the variablelist dataset */
	    do until(_DONE_VIRTUAL);
	        set phoenix.variablelist(rename=(dataset_name=dataset_source /* Hash Match Variable*/ 
                                             order_number=vlist_order_num)
                                       /*When no obs in native dataset don't drop ds-label*/    
                                       %if not(%isblank(_nobs)) %then drop=dataset_label;) 
			   end=_DONE_VIRTUAL
               ;
			
		    find_rc=vvars.find();
            if upcase(data_type) in ("TEXT","DATETIME") then
		        sas_type=2;
		    else sas_type=1;
		    if find_rc =0 then
            output;
		end;
    run;
	
%mend get_domain_espec;
