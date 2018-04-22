/* Bring in necessary Support Modules */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\isblank.sas";
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\check_argument.sas";
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\mac_map.sas";
/*
 * Unit Test Tools
 */
%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\get_filenames.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

%get_filenames(L:\Data_Warehouse\Palmetto_test\control\PD20170331\logs,filter_regex=MAP)

/*
%assert( (assertion)
        ,(when)
        ,message=)
*/

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=get_filenames Testing
         ,report_label=get_filenames.html);
