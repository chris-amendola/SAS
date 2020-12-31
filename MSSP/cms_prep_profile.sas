/* Future directions: Perhaps drop the frames based solution SAS provides and make the individual variable reports stand alone html files.
 Then generate the missing values report with links for the variable names that spawn the distrubution. 
 Also have a variable summary report TYPE, LABEL,CARDINALITY(FOR CHARS), simple descritives for numerics
 Graph when cardinaliy ~12 or less - table otherwise.
 BY MED PHM ELG, or by report type at top level?
 Be able to function without a var map*/
 
%macro cms_prep_profile( data= &lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle.
                              ,set_source_file="&lib_pref._raw.&lib_pref._&plan._&clm_type._PD&cycle..sas7bdat"
                              ,min_max_vars=
                              ,trend_vars=
                              ,ignore_vars=
                              ,some_label_var=
                              ,var_map=);
                         
   
    /*TODO: Check for required variables in outer scope. */
    
    %put BEGIN PREP PROFILE.;                      
                          
    %local _char_vars_pre
           _char_vars
           _num_vars_pre
           _num_vars
           _all_vars_pre
           _all_vars
           _drops;
               
    /* Initialize any title statements */
    title ; title2 ; title3 ; title4 ;   
    
  /* Generate variable lists for dataset to be profiled */                  
    %let _char_vars=%var_names(&data., _type=C);
    %let _num_vars=%var_names(&data., _type=N);
    %let _all_vars=%var_names(&data.);

   %if not %isblank(ignore_vars) %then %do;
    /* There may be variables which we want to ignore */
    %code_map(ignore_vars,ignore_var,%nrstr(%let _char_vars=%sysfunc(prxchange(s/\b&ignore_var.\b//, -1, &_char_vars.));));
    %code_map(ignore_vars,ignore_var,%nrstr(%let _num_vars=%sysfunc(prxchange(s/\b&ignore_var.\b//, -1, &_num_vars.));));
    %code_map(ignore_vars,ignore_var,%nrstr(%let _all_vars=%sysfunc(prxchange(s/\b&ignore_var.\b//, -1, &_all_vars.));));
   %end; 
  
  /* Formats to charcaterize missing and non-missing valiues */        
  proc format;
      value _nmissprint low-high="Non-missing" .="Missing";
      value $_cmissprint " "="Missing" other="Non-missing";
  run;                                            
  /**
   * Record, Member and Date summarization.
   */
  %macro get_min_max(_var);
    
    ,min(&_var.) as min_&_var.
      ,max(&_var.) as max_&_var.
            
  %mend get_min_max; 
  
  %macro put_min_max_var(_var);
    
    min_&_var. max_&_var.
    
  %mend put_min_max_var;    
  
  %macro sql_member_records_monthly(_var);
    
    create table work.&_var._mon as
      select &_var. format=monyy.,
             count(member_orig) as records,
             count(distinct member_orig) as members 
        from &data.
        group by &_var.
        order by &_var.
    ;
    
  %mend sql_member_records_monthly;  
  
  proc sql;
    create table work.raw_sum as
      select &set_source_file. as raw_file,
        count(member_orig) as records,
        count(distinct member_orig) as members
        %if %length(&min_max_vars)>1 %then %mac_map( get_min_max
                                                     ,to_list=min_max_vars); 
      from &data. 
      group by raw_file
      order by raw_file;
     ;
    %if %length(&trend_vars)>1 %then %mac_map( sql_member_records_monthly
                                              ,to_list=trend_vars); 
      
  quit;  
  /**
     * Variable Profiles Summarization
     */               
    %macro create_tables(_var);

    table &_var /missing out=work.&_var._fq;
   
  %mend create_tables;
  /* Variable Frequency Tables */
  /* One proc freq with multiple tables is faster than multiple proc freqs */
  proc freq data=&data. noprint;
    %mac_map(create_tables,to_list=_all_vars)
  run; 
  /** 
   * Stack the _fq tables for char and numeric variables 
   */
  %macro set_ds(_var); 
    
    work.&_var._fq ( rename=(&_var.=value)
                     in=_&_var._)
  
  %mend;

  %macro variable_names(_var);
    
    if _&_var._ then variable="&_var.";
  
  %mend;

  data work.chars;
    attrib variable length=$29
           value    length=$500;
    set %mac_map(set_ds,to_list=_char_vars) 
      ;
    %mac_map(variable_names,to_list=_char_vars)
    miss_cat=put(value,$_cmissprint.);
  run; 
 
  data work.nums;
    attrib variable length=$29
           value    length=8;
    set %mac_map(set_ds,to_list=_num_vars) 
      ;
    %mac_map(variable_names,to_list=_num_vars)
    miss_cat=put(value,_nmissprint.);
  run; 

  /** 
   * Missing Variables Analysis 
   */
  data work.miss_report;
    set work.chars(keep=variable miss_cat count percent)
        work.nums(keep=variable miss_cat count percent);
    if miss_cat="Missing";
  run;
  /**
   * Top 50 reporting 
   */ 
  options noquotelenmax; 
  %macro top_50(_var); 
    
    %local _map_source
           _transform;       

    proc sql noprint;
        select tranwrd(map_source,'"',"'") 
              ,tranwrd(transform,'"',"'") 
           into :_map_source, :_transform 
           from work.map_spec 
           where name="&_var.";
    quit;      

    %put VAR: &_var.;
    %put SOURCE: &_map_source.;
    %put XFORM: &_transform.;
 
    proc sort data=work.&_var._fq (rename=(&_var.=value))
               out=work._tmp_srt_;
      by descending count;
    run;

    ods proclabel="&_var. - Top 50 Values"; 
    title "&_var. - Top 50 Values";
    title2 "Source Mapping: &_map_source.";
    title3 "Transfomation: &_transform.";
    proc print data=work._tmp_srt_ (obs=50) 
                   noobs; 
        var value count percent;              
    run; 
    title2 ;
    title3 ;
    
  %mend;    
  /* By Month Trend Reporting */
  %macro month_trend(_var);
    
    ods proclabel "Records by &_var.";
    title3 "Final Input File";
    title4 "Records by &_var.";
    proc sgplot data=work.&_var._mon;
        vbar &_var. / response=records; 
    run; 
    ods proclabel "Unique Members by &_var.";
    title3 "Final Input File";
    title4 "Members by &_var.";
      proc sgplot data=work.&_var._mon;
          vbar &_var. / response=members;   
      run;
      
  %mend month_trend;
  /**
   * Include Variable maping info into the reporting
   */  
  %read_map_spec(&var_map.);/*Work.map_spec*/ 
  /** 
   * RTF output on the variable mappings
   */
  ods listing close; 
  ods rtf file="&out_fold.\html\&mssp_num.\field_mapping_&some_label_var..rtf";
  title "&some_label_var. Input Prep Raw to input mapping";
  proc print data=work.map_spec
             noobs;
    var name map_source transform;  
  run;
  title ;
  ods rtf close;
  /**
     * Report Generation
     */
    ods tagsets.tableeditor  file="&out_fold.\html\&mssp_num.\files\INPUT_&some_label_var..html"
                         gpath="&out_fold.\html\&mssp_num.\files\"
                         contents="&out_fold.\html\&mssp_num.\files\INPUT_&some_label_var.-contents.html"
                         frame="&out_fold.\html\&mssp_num.\INPUT_&some_label_var..html"
                         style=Analysis
     options(sort="yes" 
             sort_arrow_color="green" 
             describe="yes" 
             data_type="String,Number,Number,Number,Number,Number,Number" 
             autofilter="yes"
             autofilter_width="7em"
             /*autofilter_table="1"*/
             col_color_odd="light grey"
             col_color_even="beige");
            
     ods graphics / width=800px 
                    height=600px 
                    imagename="&some_label_var._prep" 
                    imagefmt=gif 
                    imagemap;       
             
     %if %length(&min_max_vars.)>1 %then %do;
      ods proclabel "-Min-Max Dates By Source File";
      proc print data=work.raw_sum noobs;
        var raw_file 
          %mac_map(put_min_max_var,to_list=min_max_vars);
          format %mac_map(put_min_max_var,to_list=min_max_vars) yymmdd10.;
      run;
    %end;         
    %if %length(&trend_vars.)>1 %then %do;
    
      %mac_map(month_trend,to_list=trend_vars)  ;
    
    %end;
           
    ods proclabel "MIssing Values Analysis";   
    title "MIssing Values Analysis-All Vars";          
    proc print data=work.miss_report noobs;
      var variable count percent;
    run;

    %mac_map(top_50,to_list=_all_vars)/* Get vars in alpha order */           
        
  ods tagsets.tableeditor close; 
 
 
%mend cms_prep_profile;
