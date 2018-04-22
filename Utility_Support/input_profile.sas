options sasautos=(sasautos
                  'Y:\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                  'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                  'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 ) ;
                              
/* Enable use of Tableeditor Tagsets*/
  libname  tpl_lib "Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\CMS_DEV\config\mssp\support\";
  ods path(prepend) tpl_lib.templat(update);
  %include "Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\CMS_DEV\config\mssp\support\editor.tpl";

%macro input_profile( data=
                     ,ignore_vars=
                     ,out_fold=
                     ,mssp_num=
                     ,some_label_var=
                     ,map_spec=
                     ,date_vars=/* Vars that are dates - force a graph not a table */);
   
   /* TODO: Add required macro modules
            Check_args code
            Exception Macro Mod
            'by month' graphs (normalized ranges?) 
             -uniq_mem_id by_mon_vars mon_grpv_ars
            */
    /**
     * Include Variable maping info into the reporting if a map_spec exists 
     */  
    %if not %isblank(map_spec) %then %do;
      %read_map_spec(&map_spec.);/*Work.map_spec*/
    %end;  
    /* Initialize any title statements */
    title;
    title2;
    title3;
    title4;

    /* Generate varibale lists for dataset to be profiled */                  
    %let _char_vars_pre=%var_names(&data., _type=C);
    %let _num_vars_pre=%var_names(&data., _type=N);
    %let _all_vars_pre=%var_names(&data.);

    /* There may be variables which we want to ignore */
    %let _drops=%sysfunc(prxchange(s/\|/\s/, -1, &ignore_vars.));
    %let _char_vars=%sysfunc(prxchange(s/&ignore_vars.//, -1, &_char_vars_pre.));
    %let _num_vars=%sysfunc(prxchange(s/&ignore_vars.//, -1, &_num_vars_pre.));
    %let _all_vars=%sysfunc(prxchange(s/&ignore_vars.//, -1, &_all_vars_pre.));

    /* Formats to charcaterize missing and non-missing valiues */
    proc format;
        value _nmissprint low-high="Non-missing" .="Missing";
        value $_cmissprint " "="Missing" other="Non-missing";
    run;

    /**
     * Numeric Variable Output Summarization
     */
    %macro create_outputs(_var);
        
        output out=work.&_var._stat(DROP=_TYPE_ _FREQ_) n(&_var.)=Count 
            mean(&_var.)=Mean std(&_var.)=StdDev min(&_var.)=Mininum max(&_var.)=Maximum 
            sum(&_var.)=Sum / autolabel;
            
    %mend create_outputs;

    /* Character Variable Frequency Tables */
    /* One proc freq with multiple tables is faster than multiple proc freqs */
    proc freq data=&data. noprint;
        %code_map(_all_vars,_var,%nrstr(table &_var /missing out=work.&_var._fq;))
    run;

    /* Numeric Variable Frequency Tables */
    /* One proc summary with multiple ouputs is faster than multiple proc freqs */
    proc summary data=&data.;
        var   &_num_vars.;
        %mac_map(create_outputs, to_list=_num_vars)
    run;

    /* Basic reports */
    %macro char_variable_report(_var);

        proc print data=work.&_var._fq (obs=50) noobs;
        run;

    %mend char_variable_report;

    %macro num_variable_report(_var);

        proc print data=work.&_var._stat (obs=50) noobs;
        run;

    %mend num_variable_report;

    /**
     * Stack the _fq tables for char and numeric variables
     */
    %macro set_ds(_var);
    	
    	work.&_var._fq ( rename=(&_var.=value)
                     in=_&_var._)
    	
    %mend set_ds; 
     
    %macro variable_names(_var);
        
        if _&_var._ then variable="&_var.";
        
    %mend variable_names;

    data work.chars;
        attrib variable length=$29 value length=$500;
        set %mac_map(set_ds, to_list=_char_vars);
        %mac_map(variable_names, to_list=_char_vars) 
        
        miss_cat=put(value, $_cmissprint.);
    run;

    data work.nums;
        attrib variable length=$29 value length=8;
        set %mac_map(set_ds, to_list=_num_vars);
        %mac_map(variable_names, to_list=_num_vars) 
        miss_cat=put(value, _nmissprint.);
    run;

    data work.frqs_combined;
        attrib html_link length=$500;
        set work.chars(keep=variable miss_cat count percent in=_CHAR) 
            work.nums(keep=variable miss_cat count percent in=_NUM);
        var_cat="---";

        if _CHAR then
            var_cat="CHR";

        if _NUM then
            var_cat="NUM";
            
        html_link="<a href="!!"&out_fold.\html\&mssp_num.\files\"!!strip(variable)!!"_&some_label_var..html"!!' target="_blank">'!!strip(variable)!!'</a>';
            
    run;

    /* Secondary 'all_vars_list' so that we can sort and be based on final table */
    proc sql;
        select distinct(variable) 
               into :_all_vars_list separated by " " 
          from work.frqs_combined order by variable;
    quit;

    %macro variable_report(_var);
        
        
        %put ----VARIABLE REPORT: &_var.;

        data work._src_xform_;
        	attrib map_source label='Source Variable or Value'
        	       transform length=$350
        	          line    label="Variable Transformations" length=$100;
        	set work.map_spec(where=(name="&_var."));
        	if length(compress(transform)>2) then
            do until(line=' ');
              count+1;
              line = scan(transform, count,';')!!';';
              output;
              if count>10 then do;
            	  put "WARNING: More than 10 transformation lines detected. Stopping transform parsing.";
            	  line="EXCEEDED MAX DISPLAY LENGTH";
            	  stop;
              end;
            end;
          else output;  
        run;  
        
        /* Create an html file for each variable report*/
        ods tagsets.tableeditor 
            file="&out_fold./html/&mssp_num./files/&_var._&some_label_var..html" 
            gpath="&out_fold./html/&mssp_num./files/" 
            style=Analysis options( sort="yes" 
                                    sort_arrow_color="green" 
                                    describe="yes" 
                                    data_type="String,Number,Number,Number,Number,Number,Number" 
                                    autofilter="yes" 
                                    autofilter_width="7em" 
                                    autofilter_table="3" 
                                    col_color_odd="light grey" 
                                    col_color_even="beige");
                                    
        ods graphics 
            / width=800px 
              height=600px 
              imagename="&some_label_var._&_var." 
              imagefmt=gif imagemap;
                   
        title "Variable Profile Report:";
        title2 "&_var.";
        proc print data=work._src_xform_(obs=1) noobs label;
        	var map_source;
        run;
        title; 
        title2;
        proc print data=work._src_xform_ noobs label;
        	var line;
        run;
        
        /* All vars have a freq */  
        /* 100% Missing vars case */
        %if %obs(work.&_var._fq)=z /* Blocking branch at this point*/ %then %do;
          ods tagsets.tableeditor                          
            options(panelcols='2');
          data work.__temp__;
            &_var.="No Values";
            output;
          run;
          title2 "-- 100% Missing--";
          proc print data=work.__temp__ noobs;
          run;

        %end;
        /* If number of levels <7 add an vbar graph */            
        %else %if    %obs(work.&_var._fq)>1
                  and %obs(work.&_var._fq) <=6 %then %do;
            ods tagsets.tableeditor                          
              options(panelcols='2');                 
            %put ----VBAR;     
            proc sgplot data=work.&_var._fq;
                vbar &_var. 
                    / response=count datalabel;
            run;

        %end;
        /* If number of levels <13 add an vbar graph */
        %else %if %obs(work.&_var._fq) >6
                  and %obs(work.&_var._fq)<=12 %then %do;
            ods tagsets.tableeditor                          
            options(panelcols='2');
            %put ---- HBAR;
            proc sgplot data=work.&_var._fq;
                hbar &_var. 
                    / response=count datalabel;
            run;

        %end;
        
        %put ----PRINT TABLE;
        proc print data=work.&_var._fq (obs=50) noobs;
        run;
       
        /* If there's a stat file for the var ad that to report */
        %if %sysfunc(exist(work.&_var._stat)) %then %do; 
            ods tagsets.tableeditor                          
               options(panelcols='3');
            /* Boxplot or histo? */  
            proc sgplot data=work.&_var._fq;
        	    vbox &_var. /freq=count;
             run;   
            proc sgplot data=work.&_var_fq;
            	histogram &_var. /freq=count;
            	density &_var. /freq=count;
            run;	
            	                       
            title3 "Descriptives for &_var.";
            title4 ;
            proc print data=work.&_var._stat noobs;
            run;

        %end;
               
        ods tagsets.tableeditor close;
        title4 ;
        
    %mend variable_report;

    %mac_map(variable_report, to_list=_all_vars_list);

    %put BEGIN SUMMARY REPORTS,;

    ods tagsets.tableeditor 
            file="&out_fold.\html\&mssp_num.\files\&some_label_var..html" 
            gpath="&out_fold./html/&mssp_num./files/" 
            contents="&out_fold.\html\&mssp_num.\files\&some_label_var.-contents.html"
                         frame="&out_fold.\html\&mssp_num.\&some_label_var..html"
            style=Analysis options( sort="yes" 
                                    sort_arrow_color="green" 
                                    describe="yes" 
                                    data_type="String,Number,Number,Number,Number,Number,Number" 
                                    /*autofilter="yes" 
                                    autofilter_width="7em" */
                                    /*autofilter_table="1"*/ 
                                    col_color_odd="light grey" 
                                    col_color_even="beige");
    /* Create a framed html that use tables to support drill down to the variable info */
    /* Missing Values Report */
    data work.missing_report(keep=html_link count percent);
        
        attrib html_link length=$500;
        
        set work.frqs_combined;

        if miss_cat="Missing";
            
    run;
    
    ods proclabel "&data. Contents";
    proc contents data=&data.;
    run;
    	
    ods proclabel "Missing Values Summary";
    title "Missing Value Report";
    proc print noobs;
        var html_link count percent;
    run;

    proc sql;
        create table work.var_summ as 
            select  html_link
                   ,var_cat
                   ,sum(percent) as non_missing_percent 
            from work.frqs_combined 
            where miss_cat="Non-missing" 
            group by html_link
                     ,var_cat 
            order by html_link;
    quit;
    
    ods proclabel "Variable Descriptives Summary";
    title "Variable Descriptives";
    proc print noobs;
    run;

    ods html close;

%mend input_profile;

  libname src "M:\Data_Warehouse\CMS_DEV\PD20180101\base";

  %input_profile( data=src.cms_cur_medpcm_2017_m11
                 ,ignore_vars= 
                 ,out_fold=Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\CMS_DEV\temp_test
                 ,mssp_num=5555
                 ,some_label_var=TEST
                 ,map_spec=Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\CMS_DEV\config\mssp\A3016\med_ded.map);
