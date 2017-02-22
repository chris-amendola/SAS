%macro axis_scale( _max_data_value=          /*Maximum axis data value - empirically determined*/
                  ,_return_interval_var=     /*Name of macro_variable that will return the interval value*/
                  ,_return_scale_var=        /*Name of macro_variable that will return scale value*/
                  ,_function_var=ceil        /*Name of SAS function use to determine scale value (tested values are ceil and floor)*/
                 );
                     
     
        data _null_;
            put "&_return_interval_var AXIS SCALE COMPUTATION:";
            base_unit=&_max_data_value/10;
     
            base_grade=floor(log10(base_unit));
     
            pre_scale_unit=base_unit/(10**base_grade);
            
            scale_factor=10;
     
            /*May need to flesh out this scale*/
            if pre_scale_unit<sqrt(2) then scale_factor=1;
            else if pre_scale_unit<sqrt(10) then scale_factor=2;
            else if pre_scale_unit<sqrt(50) then scale_factor=5;
     
            interval=10**base_grade*scale_factor;
            
            scale=&_function_var(&_max_data_value/interval)*interval;
            put 'Interval: ' interval;
			put 'Scale: ' scale;
            call symput("&_return_interval_var",interval);
            call symput("&_return_scale_var",scale);
     
        run;
%mend axis_scale;