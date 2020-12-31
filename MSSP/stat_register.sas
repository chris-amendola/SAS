%macro stat_register(_stat_table=
                        ,_var=
                        ,_dset=
                        ,_type=
                        ,init=NO);

  /* Formats to charcaterize missing and non-missing valiues */
  proc format;
    value _nmissprint 
      low-high="Non-missing" .="Missing";
    value $_cmissprint 
      " "="Missing" other="Non-missing";
  run;

  %if %substr(%upcase(&init),1,1) = Y %then %do;                     
    /*Clear Intialize stats/metrics tracker table*/
    proc sql;
      create table &_stat_table
      ( variable      character(50),
        stat_dset     character(50),
        type          character(15), 
        miss_percent  numeric,
        unique_vals   numeric ) ;
    quit; 

  %end;
  %else %do;

    proc sql noprint;
      /* Missing Percent */
      select sum(percent) 
        into :_miss_pct
        from &_dset.
        %if %substr(%upcase(&_type),1,1)=C %then
          where put(&_var., $_cmissprint.)='Missing';
        %else where put(&_var., _nmissprint.)='Missing';
        ;
          
      insert into &_stat_table
        set variable="&_var",
            stat_dset="&_dset",
            type="&_type",
            miss_percent=&_miss_pct,
            unique_vals=%obs(&_dset.);

    quit;
  %end;
%mend stat_register;