/*!
 *  Unit test package for check_argument macro.
 *
 *     @author Chris Amendola
 *     @created May 15 2016
 */
 /**
  * Environment Intialization
  */
 
  %let CHRPROGRAM = macros;
  %let CHRPROTOCOL = dev_env; 
  %let CHRANALTYPE  = code;
  
  %include "/biostats/setup.sas"; 

/**
  * Unit Test Tools
  */
   %include "/biostats/macros/stddev/unittest/prog/unittest.sas";
   
/**
  * Macro under testing
  */
  %include "/biostats/macros/dev_env/code/dev/******.sas";
/**
  * Test Setup macros
  */


/**
  * Testing libname
  */
libname testdata "/biostats/macros/dev_env/code/qc/qcdata";

/**
  * Valid Datasets
  */

/** 
  * Testing File
  */
filename outfile                                                                                   


%reports(locate=/SASGRID/u02/www/macro_unit_tests/
         ,test_scenario=******
         ,report_label=******.html);



  
  

