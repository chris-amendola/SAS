/*options sasautos=(sasautos
                  'Y:\SAS_Dev_Workspace\camendol\trunk\SASApps\Macros\Prod'
                 ) ;
                              
/* Enable use of Tableeditor Tagsets*//*
  libname  tpl_lib "Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\CMS_DEV\config\mssp\support\";
  ods path(prepend) tpl_lib.templat(update);
  %include "Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\CMS_DEV\config\mssp\support\editor.tpl";*/

%macro input_profile( data=
                     ,ignore_vars=
                     ,high_card_vars=
                     ,out_fold=
                     ,report_dir=
                     ,report_label=
                     ,map_spec=
                     );
   
   /* TODO: Add required macro modules
            Check_args code
            Exception Macro Mod
            */
   
   %macro date_fmt(_var);
     /* Going to guess at a few vars formats*/
     %if    &_var.=serv_dt
         or &_var.=process_dt
             or &_var.=pay_dt
             or &_var.=from_dt
             or &_var.=to_dt
             or &_var.=eff_dt
         or &_var.=end_dt %then %do;
           
       format &_var. yymmdd10.;

     %end; 
         
    %mend date_fmt;  
               
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

    /* Generate variable lists for dataset to be profiled */                  
    %let _char_vars=%var_names(&data., _type=C);
    %let _num_vars=%var_names(&data., _type=N);
    %let _all_vars=%var_names(&data.);

   %if not %isblank(ignore_vars) %then %do;
    /* There may be variables which we want to ignore */
    %code_map( ignore_vars
              ,ignore_var
              ,%nrstr(%let _char_vars=%sysfunc(prxchange(s/\b&ignore_var.\b//, -1, &_char_vars.));));
    %code_map( ignore_vars
              ,ignore_var
              ,%nrstr(%let _num_vars=%sysfunc(prxchange(s/\b&ignore_var.\b//, -1, &_num_vars.));));
    %code_map( ignore_vars
              ,ignore_var
              ,%nrstr(%let _all_vars=%sysfunc(prxchange(s/\b&ignore_var.\b//, -1, &_all_vars.));));
   %end; 
   
   %if not %isblank(high_card_vars) %then %do;
    /* Some vars may require their own proc freq*/
    %code_map( high_card_vars
              ,hc_var
              ,%nrstr(%let _char_vars=%sysfunc(prxchange(s/\b&hc_var.\b//, -1, &_char_vars.));));
    %code_map( high_card_vars
              ,hc_var
              ,%nrstr(%let _num_vars=%sysfunc(prxchange(s/\b&hc_var.\b//, -1, &_num_vars.));));
    %code_map( high_card_vars
              ,hc_var
              ,%nrstr(%let _all_vars=%sysfunc(prxchange(s/\b&hc_var.\b//, -1, &_all_vars.));));
   %end;
   
   %put IGNORE: &ignore_vars;
   %put ---;
   %put HIGH CARDINALITY VARS: &high_card_vars;
   %put ---;
   %put CHAR: &_char_vars;
   %put ---;
   %put NUM: &_num_vars;
   %put ---;
   %put ALL: &_all_vars;
   %put ---;
   
   %macro cmprs_var(_var);
       
     %if %length(&_var)>12 %then  %do;
       %sysfunc(compress(&_var,AEIOUyaeiouy)) 
        %end;
        %else %do;
          &_var
        %end;
          
   %mend  cmprs_var;    
   
    /* Formats to charcaterize missing and non-missing valiues */
    proc format;
        value _nmissprint low-high="Non-missing" .="Missing";
        value $_cmissprint " "="Missing" other="Non-missing";
    run;
    
   /**
     * Numeric Variable Output Summarization
     */
    %macro create_outputs(_var);
        
      %if not %isblank(_var) %then %do;
        %let _data_name=%cmprs_var(&_var);
        
        output out=&lib_pref._summ.&report_label._&_data_name._stat(DROP=_TYPE_ _FREQ_) n(&_var.)=Count 
            mean(&_var.)=Mean std(&_var.)=StdDev min(&_var.)=Mininum max(&_var.)=Maximum 
            sum(&_var.)=Sum / autolabel;
      %end;
            
    %mend create_outputs;
   
    /* Variable Frequency Tables */
    /* One proc freq with multiple tables is faster than multiple proc freqs */
    /* BUt one proc freq may soak up too much memory */
    proc freq data=&data. noprint;
        %mac_map(date_fmt,to_list=_char_vars);
        %code_map( _char_vars,_varx, %nrstr(%if not %isblank(_varx) %then %do; %let _data_name=%cmprs_var(&_varx); table &_varx /missing out=&lib_pref._summ.&report_label._&_data_name._fq; %end;))
    run;
    /* So let's have a high_card vars loop */
    %macro high_card_freq(_var);
    	
    	%if not %isblank(_var) %then %do; 
    	  %let _data_name=%cmprs_var(&_var);
     
        proc freq data=&data. noprint;
          table &_var 
            /missing out=&lib_pref._summ.&report_label._&_data_name._fq;
        run;	
      
      %end;  
      	
    %mend high_card_freq; 
    
    %if not %isblank(high_card_vars) %then %do;
      %mac_map(high_card_freq,to_list=high_card_vars);
    %end; 
    
    proc freq data=&data. noprint;
        %mac_map(date_fmt,to_list=_num_vars)
        %code_map(_num_vars,_var,%nrstr(%let _data_name=%cmprs_var(&_var); table &_var /missing out=&lib_pref._summ.&report_label._&_data_name._fq;))
    run;

    /* Numeric Variable Frequency Tables */
    /* One proc summary with multiple ouputs is faster than multiple proc freqs */
    proc summary data=&data.;
          %mac_map(date_fmt,to_list=_all_vars)
        var   &_num_vars.;
        %mac_map(create_outputs, to_list=_num_vars)
    run;

    /* Basic reports */
    %macro char_variable_report(_var);

        %let _data_name=%cmprs_var(&_var);

        proc print data=&lib_pref._summ.&report_label._&_data_name._fq (obs=50) noobs;
        run;

    %mend char_variable_report;

    %macro num_variable_report(_var);
       
        %let _data_name=%cmprs_var(&_var);

        proc print data=&lib_pref._summ.&report_label._&_data_name._stat (obs=50) noobs;
        run;

    %mend num_variable_report;

    /**
     * Stack the _fq tables for char and numeric variables
     */
    %macro set_ds(_var);

        %let _data_name=%cmprs_var(&_var);
       
        &lib_pref._summ.&report_label._&_data_name._fq ( rename=(&_var.=value)
                      in=_&_var._)
        
    %mend set_ds; 
     
    %macro variable_names(_var);
        
      if _&_var._ then variable="&_var.";
        
    %mend variable_names;

    data &lib_pref._summ.&report_label._chars;
        attrib variable length=$29 value length=$500;
        set %mac_map(set_ds, to_list=_char_vars);
        %mac_map(variable_names, to_list=_char_vars) 
        
        miss_cat=put(value, $_cmissprint.);
    run;

    data &lib_pref._summ.&report_label._nums;
        attrib variable length=$29 value length=8;
        set %mac_map(set_ds, to_list=_num_vars);
        %mac_map(variable_names, to_list=_num_vars) 
        miss_cat=put(value, _nmissprint.);
    run;

    data &lib_pref._summ.&report_label.frqs_combined;
        attrib html_link length=$500;
        set &lib_pref._summ.&report_label._chars(keep=variable miss_cat count percent in=_CHAR) 
            &lib_pref._summ.&report_label._nums(keep=variable miss_cat count percent in=_NUM);
        var_cat="---";

        if _CHAR then
            var_cat="CHR";

        if _NUM then
            var_cat="NUM";
            
        html_link="<a href="!!"&out_fold.\html\&report_dir.\files\"!!strip(variable)!!"_&report_label..html"!!'>'!!strip(variable)!!'</a>';
        
    run;

    /* Secondary 'all_vars_list' so that we can sort and be based on final table */
    proc sql;
        select distinct(variable) 
               into :_all_vars_list separated by " " 
          from &lib_pref._summ.&report_label.frqs_combined
          order by variable;
    quit;

    %macro variable_report(_var);
      
        %let _data_name=%cmprs_var(&_var); 

        %put ----VARIABLE REPORT: &_var.;

        data work._src_xform_;
            attrib map_source label='Source Variable or Value'
                   transform length=$1500
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
            file="&out_fold./html/&report_dir./files/&_var._&report_label..html" 
            gpath="&out_fold./html/&report_dir./files/" 
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
            / width=600px 
              height=450px 
              imagename="&report_label._&_var." 
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
        %if %obs(&lib_pref._summ.&report_label._&_data_name._fq)=z /* Blocking branch at this point*/ %then %do;
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
        %else %if    %obs(&lib_pref._summ.&_data_name._fq)>1
                  and %obs(&lib_pref._summ.&_data_name._fq) <=6 %then %do;
            ods tagsets.tableeditor                          
              options(panelcols='2');                 
            %put ----VBAR;     
            proc sgplot data=&lib_pref._summ.&report_label._&_data_name._fq;
                vbar &_var. 
                    / response=count datalabel;
            run;

        %end;
        /* If number of levels <13 add an vbar graph */
        %else %if %obs(&lib_pref._summ.&report_label._&_data_name._fq) >6
                  and %obs(&lib_pref._summ.&report_label._&_data_name._fq)<=12 %then %do;
            ods tagsets.tableeditor                          
            options(panelcols='2');
            %put ---- HBAR;
            proc sgplot data=&lib_pref._summ.&report_label._&_data_name._fq;
                hbar &_var. 
                    / response=count datalabel;
            run;

        %end;
        
        %put ----PRINT TABLE;
        proc print data=&lib_pref._summ.&report_label._&_data_name._fq (obs=50) noobs;
        run;
       
        /* If there's a stat file for the var ad that to report */
        options mprint;
        %if %sysfunc( exist(&lib_pref._summ.&report_label._&_data_name._stat) )
            & %obs(&lib_pref._summ.&report_label._&_data_name._stat)>0 %then %do; 
            ods tagsets.tableeditor                          
               options(panelcols='2');
            /* Boxplot or histo? */  
            proc sgplot data=&lib_pref._summ.&report_label._&_data_name._fq;
                vbox &_var. /freq=count;
             run; 
            /*   
            proc sgplot data=&lib_pref._summ.&_data_name._fq;
                histogram &_var. /freq=count;
                density &_var. /freq=count;
            run;    
            */
                                       
            title3 "Descriptives for &_var.";
            title4 ;
            proc print data=&lib_pref._summ.&report_label._&_data_name._stat noobs;
            run;

        %end;
        options nomprint; 
               
        ods tagsets.tableeditor close;
        title4 ;        
        footnote10 "<a href=&out_fold.\html\&report_dir.\&report_label..html>Back to Summary Repor</a>";
        
    %mend variable_report;

    %mac_map(variable_report, to_list=_all_vars_list);

    %put BEGIN SUMMARY REPORTS,;

    ods tagsets.tableeditor 
            file="&out_fold.\html\&report_dir.\files\&report_label..html" 
            gpath="&out_fold./html/&report_dir./files/" 
            contents="&out_fold.\html\&report_dir.\files\&report_label.-contents.html"
                         frame="&out_fold.\html\&report_dir.\&report_label..html"
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
        
        set &lib_pref._summ.&report_label.frqs_combined;

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
            from &lib_pref._summ.&report_label.frqs_combined; 
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
/*
  libname cms_base "M:\Data_Warehouse\Ascension\PD20180228\base";

  %input_profile( data=cms_base.asn_cur_elgind_span
                 ,ignore_vars= 
                 ,out_fold=Y:\SAS_Dev_Workspace\camendol\trunk\SASApps\Ihcis_wh\CMS_DEV\profile_test
                 ,report_dir=5555
                 ,report_label=TEST
                 ,map_spec=Y:\SAS_Dev_Workspace\camendol\trunk\SASApps\Ihcis_wh\Ascension\config\cms\a1061_HICN\elg_ded.map);
*/
