options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 );
/*!
 *  Unit test package for check_argument macro.
 *
 *     @author Chris Amendola
 *     @created May 15 2016
 */ 
/**
  * Unit Test Tools
  */
   %include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";
   
/**
  * Macro under testing
  */
  %include "Y:\Users\camendol\SAS_ETL_dev\support_lib\check_argument.sas";
/**
  * Test Setup macros
  */
%macro defined_outside( nested_parm1=present
                       ,nested_parm2=);

        %check_argument( parm=nested_parm1
                        ,isa=CHAR
                        ,required=Y
                        )
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Nested Outside Macro Call - Check PASS when required parm is set);
        call symput("_argument_check_code","1");
        run;  
    
        %check_argument( parm=nested_parm2
                        ,isa=CHAR
                        ,required=Y
                        )
        data _null_;
        %assert((&_argument_check_code=0)
                ,message=Nested Outside Macro Call - Check FAILs when required parm is null);
        call symput("_argument_check_code","1");
        run; 
               
        %check_argument( parm=nested_parm1
                        ,isa=CHAR
                        ,required=N)
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Nested Outside Macro Call - Check PASS when non-required parm is set);
        call symput("_argument_check_code","1");
        run;  

        %check_argument( parm=nested_parm2
                        ,isa=CHAR
                        ,required=N)
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Nested Outside Macro Call - Check PASS when non-required parm is nul);
        call symput("_argument_check_code","1");
        run;  

%mend defined_outside;
%macro self_test1( missing=
                    ,present=zvalue avalue
                    ,test_data=testdata.parmtest
                    ,test_data2=testdata.garbage
                    ,test_data3=testdata.---
                    ,test_data4=parmtest
                    ,test_data5=---
					          ,test_view=testdata.simple_view
				          	,test_view2=testdata.yyyyyy
                    ,test_data_list_good=testdata.parmtest testdata.parmtest2
                    ,test_data_list_bad=testdata.parmtest testdata.garbage 
                    ,test_file=Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\simple_file.txt
                    ,test_file2=Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\garbage.txt
                    ,test_path=Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\
                    ,test_path2=Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\garbage
                    ,var_okay=test_var
                    ,var_invalid=---
                    ,var_vw_okay=test_var
                    ,var_vw_invalid=---
                    ,var_miss=bad_junk
                    ,libref_okay=testdata
                    ,libref_bad=garbage
                    ,int_good=84
                    ,int_bad_alpha=66s666
                    ,dec_good=45.45
                    ,dec_bad1=4646.6776.999
                    ,dec_bad2=34a.00
                    ,neg_int=-55
                    ,neg_int_bad=5-5
                    ,neg_dec=-3.324
                    ,neg_dec_bad=-3.-24
                    ,delm_list=a|b|c
                    );

    %macro defined_inside( nested_parm2=present
                          ,nested_parm1=);

        %check_argument( parm=nested_parm2
                        ,isa=CHAR
                        ,required=Y
                        )
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Nested Inside Macro Call - Check PASS when required parm is set);
        call symput("_argument_check_code","1");
        run;  
    
        %check_argument( parm=nested_parm1
                        ,isa=CHAR
                        ,required=Y
                        )
        data _null_;
        %assert((&_argument_check_code=0)
                ,message=Nested Inside Macro Call - Check FAILs when required parm is null);
        call symput("_argument_check_code","1");
        run; 
               
        %check_argument( parm=nested_parm2
                        ,isa=CHAR
                        ,required=N)
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Nested Inside Macro Call - Check PASS when non-required parm is set);
        call symput("_argument_check_code","1");
        run;  

        %check_argument( parm=nested_parm1
                        ,isa=CHAR
                        ,required=N)
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Nested Inside Macro Call - Check PASS when non-required parm is nul);
        call symput("_argument_check_code","1");
        run;   

    %mend defined_inside;
         
        %check_argument( parm=missing
                        ,isa=CHAR
                        ,required=Y
                        )
        data _null_;
        %assert((&_argument_check_code=0)
                ,message=Check FAILs when argument for required parm is null);
        call symput("_argument_check_code","1");
        run;     
               
        %check_argument( parm=missing
                        ,isa=CHAR
                        ,required=N)
        data _null_;
        %assert((&_argument_check_code=1)
                ,message=Check PASS when argument for not-required parm is null);
        call symput("_argument_check_code","1");
        run;        
        
        %check_argument( parm=present
                        ,isa=CHAR
                        ,required=N)  
                        
        data _null_;             
        %assert((&_argument_check_code=1)
                ,message=Check PASS when argument for not-required parm is populated);
        call symput("_argument_check_code","1");
        run;
              
        %check_argument( parm=present
                        ,isa=CHAR
                        ,required=Y)  
                        
        data _null_;             
        %assert((&_argument_check_code=1)
                ,message=Check PASS when argument for required parm is populated); 
        call symput("_argument_check_code","1"); 
        run;         
 
        %check_argument( parm=test_data
                        ,isa=DATA
                        ,required=Y)
         
        data _null_;                        
        %assert((&_argument_check_code=1)
                ,message=Check PASS when type DATASET-dataset exists);
        call symput("_argument_check_code","1");
        run;
                
        %check_argument( parm=test_data2
                        ,isa=DATA
                        ,required=Y)
        data _null_;                        
        %assert((&_argument_check_code=0)
                ,message=Check FAILs when type DATASET dataset does not exist);
        call symput("_argument_check_code","1");
        run;       
      
        %check_argument( parm=test_view
                        ,isa=DATA
                        ,required=Y)
         
        data _null_;                        
        %assert((&_argument_check_code=1)
                ,message=Check PASS when type DATASET-view exists);
        call symput("_argument_check_code","1");
        run;
                
        %check_argument( parm=test_data2
                        ,isa=DATA
                        ,required=Y)
        data _null_;                        
        %assert((&_argument_check_code=0)
                ,message=Check FAILs when type DATASET view does not exist);
        call symput("_argument_check_code","1");
        run;       

        %check_argument( parm=test_file
                        ,isa=FILE
                        ,required=Y)
         
        data _null_;                        
        %assert((&_argument_check_code=1)
                ,message=Check PASS when type FILE-file exists);
        call symput("_argument_check_code","1");
        run;
                
        %check_argument( parm=test_file2
                        ,isa=FILE
                        ,required=Y)
        data _null_;                        
        %assert((&_argument_check_code=0)
                ,message=Check FAILs when type FILE file does not exist);
        call symput("_argument_check_code","1");
        run; 
         
        %check_argument( parm=test_path
                        ,isa=PATH
                        ,required=Y)
         
        data _null_;                        
        %assert((&_argument_check_code=1)
                ,message=Check PASS when type PATH-path exists);
        call symput("_argument_check_code","1");
        run;
                
        %check_argument( parm=test_path2
                        ,isa=PATH
                        ,required=Y)
        data _null_;                        
        %assert((&_argument_check_code=0)
                ,message=Check FAILs when type PATH path does not exist);
        call symput("_argument_check_code","1");
        run; 
        
        %check_argument( parm=var_okay
                        ,isa=VAR~&test_data
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type VAR check PASS when variable is on dataset);
            call symput("_argument_check_code","1");
        run;
             
        %check_argument( parm=var_invalid
                        ,isa=VAR~&test_data
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VAR check FAIL when variable not vaildly constructed);
            call symput("_argument_check_code","1");
        run;        
        
        %check_argument( parm=var_okay
                        ,isa=VAR~testdata.garbage
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VAR check FAIL when dataset does not exist);
            call symput("_argument_check_code","1");
        run;       
      
        %check_argument( parm=var_miss
                       ,isa=VAR~&test_data
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VAR check FAIL when variable does NOT appear on dataset);
            call symput("_argument_check_code","1");
        run;

        %check_argument( parm=var_vw_okay
                        ,isa=VAR~&test_view
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type VAR check PASS when variable is on dataset-view);
            call symput("_argument_check_code","1");
        run;
             
        %check_argument( parm=var_vw_invalid
                        ,isa=VAR~&test_view
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VAR check FAIL when variable not vaildly constructed-view);
            call symput("_argument_check_code","1");
        run;        
        
        %check_argument( parm=var_vw_okay
                        ,isa=VAR~&test_view2
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VAR check FAIL when dataset-view does not exist);
            call symput("_argument_check_code","1");
        run;       
      
        %check_argument( parm=var_miss
                       ,isa=VAR~&test_view2
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VAR check FAIL when variable does NOT appear on dataset-view);
            call symput("_argument_check_code","1");
        run;

        %check_argument( parm=libref_okay
                        ,isa=LIBREF
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type LIBREF check PASS when libref exists);
            call symput("_argument_check_code","1");
        run; 
        %check_argument( parm=libref_bad
                        ,isa=LIBREF
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type LIBREF check FAIL when libref does not exist); 
             call symput("_argument_check_code","1");
        run;
        
        %check_argument( parm=int_good
                        ,isa=INT
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type INT check PASS when argument is an integer); 
            call symput("_argument_check_code","1");
        run;
        
        %check_argument( parm=int_bad_alpha
                        ,isa=INT
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type INT check FAIL when argument is '66s666');
            call symput("_argument_check_code","1"); 
        run;           
        
        %check_argument( parm=dec_good
                        ,isa=INT
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type INT check FAIL when argument is a decimal);
            call symput("_argument_check_code","1"); 
        run;          
               
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type DEC check PASS when argument is a decimal); 
            call symput("_argument_check_code","1");
        run;             
          
        %check_argument( parm=dec_bad1
                        ,isa=DEC
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type DEC check FAIL when argument has multiple '.' );
            call symput("_argument_check_code","1"); 
        run;    
           
        %check_argument( parm=dec_bad2
                        ,isa=DEC
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type DEC check FAIL when argument has alpha chars );
            call symput("_argument_check_code","1"); 
        run;   
        
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y
                        ,numeric_min=22)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type DEC minimum check PASS when argument is greater than minimum);
             call symput("_argument_check_code","1"); 
        run;
        
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y
                        ,numeric_min=100)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type DEC minimum check FAIL when argument is less than minimum);
            call symput("_argument_check_code","1"); 
        run;
               
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y
                        ,numeric_max=100)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type DEC maximum check PASS when argument is less than maximum); 
            call symput("_argument_check_code","1");
        run;
        
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y
                        ,numeric_max=22)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type DEC maximum check FAIL when argument is greater than maximum); 
            call symput("_argument_check_code","1");
        run;  
        
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y
                        ,numeric_min=22
                        ,numeric_max=100)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type DEC min-max check PASS when argument is between min and max); 
            call symput("_argument_check_code","1"); 
        run;             
        
        %check_argument( parm=dec_good
                        ,isa=DEC
                        ,required=Y
                        ,numeric_min=100
                        ,numeric_max=22)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type DEC min-max check FAIL when argument is NOT between min and max);
            call symput("_argument_check_code","1"); 
        run;    
        
      %check_argument( parm=var_okay
                        ,isa=VALID_VAR
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type VALID_VAR check PASS when variable name is valid);
            call symput("_argument_check_code","1");
        run;
             
        %check_argument( parm=var_invalid
                        ,isa=VALID_VAR
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VALID_VAR check FAIL when variable name(&var_invalid) is not validly formed);
             call symput("_argument_check_code","1");
        run;               
       
       %check_argument( parm=var_okay
                        ,isa=VALID_VAR
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type VALID_VAR check PASS when variable name is valid);
            call symput("_argument_check_code","1");
        run;
             
        %check_argument( parm=var_invalid
                        ,isa=VALID_VAR
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VALID_VAR check FAIL when variable name is not validly formed);
             call symput("_argument_check_code","1");
        run;               
 
      %check_argument( parm=test_data
                        ,isa=VALID_DATA
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type VALID_DATA PASS when dataset name validly formed);
            call symput("_argument_check_code","1"); 
        run;    
                        
      %check_argument( parm=test_data3
                        ,isa=VALID_DATA
                        ,required=Y)
                        
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VALID_DATA FAIL when dataset name not validly formed);
            call symput("_argument_check_code","1"); 
        run;    

       %check_argument( parm=test_data4
                        ,isa=VALID_DATA
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type VALID_DATA PASS when (work) dataset name validly formed);
            call symput("_argument_check_code","1");  
        run;    
                        
      %check_argument( parm=test_data5
                        ,isa=VALID_DATA
                        ,required=Y)
                        
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type VALID_DATA FAIL when (work) dataset name not validly formed);
            call symput("_argument_check_code","1"); 
        run;    
      
      %check_argument( parm=present
                        ,isa=CHAR
                        ,required=Y
                        ,valid_values=zvalue bvalue cvalue)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Check FAIL when argument not in valid values list); 
            call symput("_argument_check_code","1");
        run; 
        
        %check_argument( parm=missing
                        ,isa=VALID_DATA
                        ,required=N
                        )
 
      data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Check PASS when non-required argument of type VALID_DATA is null);
            call symput("_argument_check_code","1"); 
        run; 
        
        %check_argument( parm=neg_dec
                        ,isa=DEC
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type DEC check PASS when argument is negative );
            call symput("_argument_check_code","1"); 
        run;    
        
        %check_argument( parm=neg_dec_bad
                        ,isa=DEC
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type DEC check FAIL when '-' is mis-placed); 
            call symput("_argument_check_code","1");
        run;       
        
        %check_argument( parm=neg_int
                        ,isa=INT
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=Type INT check PASS when argument is negative ); 
        run; 
        
        %check_argument( parm=neg_int_bad
                        ,isa=INT
                        ,required=Y)
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=Type INT check FAIL when '-' is mis-placed);
            call symput("_argument_check_code","1"); 
        run; 

        %check_argument( parm=test_data_list_good
                        ,isa=DATA
                        ,required=Y
                        ,valid_values=testdata.parmtest testdata.parmtest2)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=PASS when DATA on valid values list does exist); 
            call symput("_argument_check_code","1");
        run; 

        %check_argument( parm=test_data_list_good
                        ,isa=DATA
                        ,required=Y
                        ,valid_values=testdata.parmtest2 )
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=FAIL when existing DATA not on valid values list );
            call symput("_argument_check_code","1"); 
        run; 
 
        %check_argument( parm=test_data_list_bad
                        ,isa=DATA
                        ,required=Y
                        ,valid_values=testdata.parmtest2 testdata.garbage )
        data _null_;
            %assert((&_argument_check_code=0)
                    ,message=FAIL when non-existing DATA on valid values list );
            call symput("_argument_check_code","1"); 
        run; 

        %check_argument( parm=delm_list
                        ,isa=CHAR
                        ,required=Y
                        ,valid_values=a b c
                        ,list_sep=|)
        data _null_;
            %assert((&_argument_check_code=1)
                    ,message=PASS when argument list has special delimiter );
            call symput("_argument_check_code","1"); 
        run; 

        %defined_outside();

        %defined_inside();

%mend self_test1;                        
            
options notes mprint;

/**
  * Testing libname
  */
libname testdata "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

/**
  * Valid Datasets
  */
data testdata.parmtest;
    test_var="FRED";
run;
data testdata.parmtest2;
    test_var="BARNEY";
run;
data testdata.simple_view
  /view=testdata.simple_view;
    set testdata.parmtest;
run;

/** 
  * Testing File
  */
filename outfile 'Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\simple_file.txt' encoding="utf-8";                                                                                             

data _null_;                                                                    
   file outfile;                                                                                                     
   put "Simple File for unit tests.";                                                                                                           
run;

%self_test1();  

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=check_argument Testing
         ,report_label=check_argument.html);



  
  

