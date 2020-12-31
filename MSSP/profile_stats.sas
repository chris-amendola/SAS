%macro profile_stats( data=
                     ,ignore_vars=
                     ,high_card_vars=
                     ,out_lib=
                     ,month_sum_by=
                     ,by_month_vars=
                     ,id_var=
                      );
                     
  /* Create/Initialize a variable stats register */
  %stat_register( _stat_table=&out_lib..stats_register
                  ,init=Y)

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

  proc contents data=&data. 
                out=&out_lib..ds_contents
                noprint;
  run;

  /* Generate variable lists for dataset to be profiled */                  
  %let _char_vars=%var_names(&data., _type=C);
  %let _num_vars=%var_names(&data., _type=N);
  %let _all_vars=%var_names(&data.);

  %put DATASET: &data.; 
  %put --ALL VARIABLES:;
  %put ------> &_all_vars; 
  %put ;
  %put --NUMERIC VARS:;
  %put ------> &_num_vars; 
  %put ;
  %put --CHARACTER VARS:;
  %put ------> &_char_vars; 
  %put ;
 
  %if not %isblank(ignore_vars) %then %do;
    %put IGNORE VARIABLES LIST POPULATED.;
    %put -- VARS: &ignore_vars;
    %put ;

    %put RESOLVING VARIABLES LISTS FOR IGNORED VARIABLES...;
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
    %put DONE.;
    %put ;
    %put RESOLVED VARIABLE LISTS; 
    %put --ALL VARIABLES:;
    %put ------> &_all_vars; 
    %put ;
    %put --NUMERIC VARS:;
    %put ------> &_num_vars; 
    %put ;
    %put --CHARACTER VARS:;
    %put ------> &_char_vars; 
    %put ;

  %end;

  %if not %isblank(high_card_vars) %then %do;
    %put HIGH CARDINALITY VARIABLES LIST POPULATED.;
    %put -- VARS: &high_card_vars;
    %put ;
    %put RESOLVING VARIABLES LISTS FOR HIGH CARDINALITY VARIABLES...;
    /* Some vars may require their own proc freq*/
    /* These vars though force longer runs time*/
    %code_map( high_card_vars
              ,hc_var
              ,%nrstr(%let _char_vars=%sysfunc(prxchange(s/\b&hc_var.\b//, -1, &_char_vars.));));
    %code_map( high_card_vars
              ,hc_var
              ,%nrstr(%let _num_vars=%sysfunc(prxchange(s/\b&hc_var.\b//, -1, &_num_vars.));));
    %code_map( high_card_vars
              ,hc_var
              ,%nrstr(%let _all_vars=%sysfunc(prxchange(s/\b&hc_var.\b//, -1, &_all_vars.));));

    %put DONE.;
    %put ;
    %put RESOLVED VARIABLE LISTS; 
    %put --ALL VARIABLES:;
    %put ------> &_all_vars; 
    %put ;
    %put --NUMERIC VARS:;
    %put ------> &_num_vars; 
    %put ;
    %put --CHARACTER VARS:;
    %put ------> &_char_vars; 
    %put ;
  %end;

  /* Begin Variable Aggregates */
  /* Character/categoricals */
  %macro high_card_freq(_var);
     
    proc freq data=&data.(keep=&_var) noprint;
      table &_var 
        /missing out=&out_lib..&_var._fq;
    run;      
          
  %mend high_card_freq; 
    
  %if not %isblank(high_card_vars) %then %do;
    %mac_map( high_card_freq
             ,to_list=high_card_vars);
  %end; 

  %if not %isblank(_char_vars) %then %do;
    proc freq data=&data. noprint;
      %mac_map( date_fmt
               ,to_list=_char_vars);
      %code_map( _char_vars
                ,_varx
                ,%nrstr( %if not %isblank(_varx) %then %do;
                           table &_varx 
                             /missing out=&out_lib..&_varx._fq;
                         %end;  
                        ))
    run;
    /* Register stats */
    %PUT LOOKEHERE!!!!;
    %put &_char_vars.;
    %code_map( _char_vars
               ,_varx
               ,%nrstr( %put ## VAR: &_varx; 
                        %put ## &out_lib..&_varx._fq;
                        %if not %isblank(_varx) %then %do;                            
                           %stat_register( _stat_table=&out_lib..stats_register
                                          ,_var=&_varx
                                          ,_dset=&out_lib..&_varx._fq
                                          ,_type=CHARACTER);
                         %end;))
  %end;
  /*Numerics/Continuous */
  /**
   * Numeric Variable Output Summarization
   */
  %macro create_outputs(_var);
        
    %if not %isblank(_var) %then %do;
        
      output out=&out_lib..&_var._stat(DROP=_TYPE_ 
                                           _FREQ_) 
               n(&_var.)=Count 
               mean(&_var.)=Mean 
               std(&_var.)=StdDev 
               min(&_var.)=Mininum 
               max(&_var.)=Maximum 
               sum(&_var.)=Sum / autolabel;
    %end;
            
  %mend create_outputs;

  %if not %isblank(_num_vars) %then %do;
    proc freq data=&data. noprint;
      %mac_map( date_fmt
               ,to_list=_num_vars)
      %code_map( _num_vars
                ,_var
                ,%nrstr( %if not %isblank(_var) %then %do; 
                           table &_var 
                             /missing out=&out_lib..&_var._fq;
                         %end;))
    run;

    /* Register Stats */
    proc summary data=&data.;
      %mac_map( date_fmt
               ,to_list=_all_vars)
      var &_num_vars.;
      %mac_map( create_outputs
               ,to_list=_num_vars)
    run;
  %end;

%mend profile_stats;
