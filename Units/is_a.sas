%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
/**
  * Macro under testing
  */
%macro is_a();%mend;
%include "\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\is_a.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";
data _null_;
    /* INT */
    %assert((%is_a(INT,5)=1)
            ,message=5 is type integer);
    %assert((%is_a(INT,z)^=1)
            ,message=z is not type integer);        
    /* DATA */
    %assert((%is_a(DATA,testlib.parmtest)=1)
            ,message=Valid Dataset-testlib.parmtest);
    %assert((%is_a(DATA,work.junk)^=1)
            ,message=Undefined Dataset-work.junk);                     
    /* VAR */ 
    %assert((%is_a(VAR~testlib.parmtest,test_var)=1)
            ,message=Var test_var on parmtest);
    %assert((%is_a(VAR~testlib.parmtest,junk)^=1)
            ,message=Var junk not on parmtest); 
    /* VALID_VAR */
    %assert((%is_a(VALID_VAR,fred)=1)
            ,message=Fred is a valid variable name);
    %assert((%is_a(VALID_VAR,###)^=1)
            ,message=### is not a valid variable name);       
    /* PATH */
    %assert((%is_a(PATH,Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\)=1)
            ,message=Valid Path-Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\);
    %assert((%is_a(PATH,/junk/junk)^=1)
            ,message=Invalid Path-/junk/junk);          
    /* FILE */
    %assert((%is_a(FILE,Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\simple_file.txt)=1)
            ,message=Real file-Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\simple_file.txt);
    %assert((%is_a(FILE,Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\junk.txt)^=1)
            ,message=Not a real file-Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata\junk.txt);           
    /* DEC */
    %assert((%is_a(DEC,5.1)=1)
            ,message=5.1 is type decimal);
    %assert((%is_a(DEC,5)^=1)
            ,message=5 is not type decimal);   
    /* LIBREF */
    %assert((%is_a(LIBREF,testlib)=1)
            ,message=testlib is real library);
    %assert((%is_a(LIBREF,junk)^=1)
            ,message=junk is not a real libref);
    
run;

%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
          ,test_scenario=is_a Testing
         ,report_label=is_a.html); 
