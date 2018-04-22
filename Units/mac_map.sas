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
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\mac_map.sas";
/** 
  * Local Macro Methods 
  */
%macro simple_test(_variable);

    %put VARIABLE: &_variable;
    &_variable="&_variable";

%mend simple_test;
/**
  * Spme delimited lists of values on which to apply 
  * macro functions
  */
%let some_list=This is a list;
%let special_separator_list=Just|another|list;
%let comma_list=Just,another,list;

data null;

    /**
      * Initialize some dataset vars
      */
    This='    ';
    is='  ';
    a=' ';
    list='    ';
    Just='    ';
    another='       ';
    /** 
      * Feed list to function
      * Generates some dataset variables
      */
    %mac_map(simple_test,to_list=some_list);

    %assert((This='This')
            ,message=List check: This);
    %assert((is='is')
            ,message=List check: is);
    %assert((a='a')
            ,message=List check: a);
    %assert((list='list')
            ,message=List check: list);  
    This='    ';
    is='  ';
    a=' ';
    list='    ';
    Just='    ';
    another='       ';
    /**
      * Non-default separator
      */
     
    %mac_map(simple_test,to_list=special_separator_list,sep=|);
    %assert((Just='Just')
            ,message=Pipe Separated List check: Just);
    %assert((another='another')
            ,message=Pipe Separated List check: another);
    %assert((list='list')
            ,message=Pipe Separated List check: list);
    This='    ';
    is='  ';
    a=' ';
    list='    ';
    Just='    ';
    another='       ';        
    /**
      * Comma separator
      */        
    %mac_map(simple_test,to_list=comma_list,sep=%str(,));
    %assert((Just='Just')
            ,message=Comma Separated List check: Just);
    %assert((another='another')
            ,message=Comma Separated List check: another);
    %assert((list='list')
            ,message=Comma Separated List check: list);
run;

%reports( locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
          ,test_scenario=mac_map Testing
         ,report_label=mac_map.html); 
