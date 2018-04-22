options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 );
/*!
 *  Unit test package for map_mac macro.
 *
 *     @author Chris Amendola
 *     @created Aug 15 2016
 */ 
/**
  * Unit Test Tools
  */
   %include "\\NASGW8315PN\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod\unittest.sas";
   
/**
  * Usage Examples for mac_map
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\code_map.sas";
/** 
  * Local Macro Methods 
  */
/**
  * Spme delimited lists of values on which to apply 
  * macro functions
  */
%let some_list=This is a list;

%code_map(some_list ,_x , %nrstr(data work.&_x.; z=1; output; run;))


%macro test();
  %global test;	
	%let test=%code_map(some_list ,_x , %nrstr(&_x.) );
	%put &test;

%mend test;
%test();


data null;

    /**
      * Initialize some dataset vars
      */
    This='    ';
    is='  ';
    a=' ';
    list='    ';
   
    perfect=%code_map(some_list ,_x , %nrstr(%put &_x.; %if &_x.=a %then 'PERFECT';) );
    /**  
      * Feed list to function
      * Generates some dataset variables
      */
    /* In datastep test */  
    %code_map(some_list,_x,%nrstr(&_x.="&_x.";));

    %assert((This='This')
            ,message=In datastep test List check: This);
    %assert((is='is')
            ,message=In datastep test List check: is);
    %assert((a='a')
            ,message=In datastep test List check: a);
    %assert((list='list')
            ,message=In datastep test List check: list);
            
    %assert((perfect='PERFECT')
            ,message= Macro code into datastep variable: PERFECT);   
            
    %assert( (exist('work.This'))
            ,message= Proc/Dataset Boundary Test: work.This) 
     
    %assert( (exist('work.is'))
            ,message= Proc/Dataset Boundary Test: work.is)
            	
    %assert( (exist('work.a'))
            ,message= Proc/Dataset Boundary Test: work.a)        	        	             
                    
    %assert( (exist('work.list'))
            ,message= Proc/Dataset Boundary Test: work.list) 
            	
    test="&test";        	
    %assert( ( test='This        is        a        list')  
            ,message= Macro variable set inside a macro environemnt)     	          
run;
%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
          ,test_scenario=code_map Testing
         ,report_label=code_map.html); 
