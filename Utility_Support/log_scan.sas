OPTIONS DEV=ACTIVEX;
/* Enable use of Excel Tagsets*/
libname  tpl_lib "Y:\Users\camendol\SAS_ETL_dev\support_lib\";
ods path(prepend) tpl_lib.templat(update);
%include "Y:\Users\camendol\SAS_ETL_dev\support_lib\editor.tpl";
options sasautos=(SASAUTOS, "Y:\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod");
/*
 * Define a macro that generates datastep logic for each 'NOTE:' test-phrase category pair.
 */
  %macro note_logic(_note_pair);

    %local _test_pattern
           _category;

    %let _test_pattern=%scan(&_note_pair,1,%str(|));
    %let _category=%scan(&_note_pair,-1,%str(|)); 

    /** REGEX Solution*/
      /** "wildcards" are possible in match phrases this way*/
      /* Compile regex statements one time per datastep, instead of once per observation*/
    if _n_=1 then do;
      &_category=prxparse("/&_test_pattern/");
      retain &_category;
      put "&_category -> &_test_pattern";
    end;
    has_match=prxmatch(&_category,upcase(message_line));
    if has_match then issue_type="&_category";

    /** index function solution
        -less flexible
        -drop code for production 
    if index(log_message,"&_test_pattern") 
      then issue_type="&_category";
    */

  %mend note_logic; 
 
/* 
 * Following variable allows for separation of code from metadata
 *  -Packed list of '!'-separated pairs of search phrase|category 
 *  -This could be a table and constructed via prod sql select into
 */
  %let _note_logic_pairs= MERGE STATEMENT HAS MORE THAN ONE|MERGE_REPEATS 
                         !VARIABLE .* IS UNINITIALIZED.|UNINITIALIZED_VAR 
                         !MISSING VALUES WERE GENERATED|MISS_VARS_GEN 
                         !INVALID ARGUMENT TO FUNCTION|BAD_ARGUMENT_FUNCTION 
                         !AT LEAST ONE W.D FORMAT WAS TOO|WD_FORMAT_SMALL 
                         !CHARACTER VALUES HAVE BEEN CONVERTED TO NUMERIC|CHAR_TO_NUM 
                         !INVALID NUMERIC DATA|INVALID_NUMERIC_DATA 
                         !DIVISION BY ZERO|DIV_ZERO 
                         !SAS WENT TO A NEW LINE WHEN INPUT STATEMENT|INPUT_NEW_LINE 
                         !DATA STEP STOPPED DUE TO LOOPING|LOOP_END 
                         !INVALID SECOND ARGUMENT TO FUNCTION|BAD_ARGUMENT_FUNCTION 
                         !MATHEMATICAL OPERATIONS COULD NOT BE PERFORMED|MATH_NOT_PERFORMED 
                         !LIBRARY .* DOES NOT EXIST|FAILED_LIBRARY   
                         !STATEMENT NOT EXECUTED DUE TO NOEXEC OPTION|NOEXEC 
                         !NUMERIC VALUES HAVE BEEN CONVERTED|NUM_TO_CHAR 
                         !ERROR\:|ERROR
                         !WARNING\:|WARNING
  ;

%let _infile_=M:\Data_Warehouse\MHC\Control\PD20170930\logs\*.log;
/*Y:\SAS_Dev_Workspace\camendol\SASApps\Ihcis_wh\Palmetto_test\invoke_DW_PALMETTO_test.log;
L:\Data_Warehouse\Palmetto_test\control\PD20170331\logs\*.log;*/ 
/*
 * Apply Categorization engine to the raw NOTE: data
 */
  data work.categorized_messages(keep=src_file
                                      line_num
                                      message_line
                                      issue_type
                                      log
                                      show_flag);

    attrib issue_type   label="Message Categorization" length=$25
           src_file     label="Source Log"             length=$2000
           log_file                                    length=$2000
           message_line label="Log Line"               length=$400
           log          label="Log File"               length=$150
           show_flag    label= "Type Count" length=8; 

    infile "&_infile_" 
           filename=log_file 
           length=len
           truncover 
           ;
       
    input message_line $varying2000. len;

    show_flag=1;
    line_num+1;
    issue_type="TBD";
    src_file=log_file;
    log=scan(src_file,-1,'\');

    if lag(src_file) ^= src_file then line_num=1;

    /* Find problematic NOTE messages and categorize them */
    %mac_map(note_logic,to_list=_note_logic_pairs,sep=%str(!));

    if issue_type^="TBD" then output;

  run;
%macro hold_off();
  proc sgpanel data=work.categorized_messages;
    title 'Log Message Report';
    panelby log 
      /layout=panel 
       novarname 
       noborder 
       colheaderpos=bottom;
    vbar issue_type 
      /response=show_flag 
       stat=freq 
       /*dataskin=gloss*/ 
       datalabel;
    colaxis display=(nolabel);
    rowaxis grid;
  run;

  proc freq data=work.categorized_messages noprint;
    tables log*issue_type
      /out=work.summary;
  run;
  proc print data=work.summary noobs;
    by log;
  run;

  proc print data=work.categorized_messages noobs; 
    by log;
    var issue_type 
        line_num 
        message_line; 
  run; 
%mend hold_off;

ods tagsets.tableeditor file="Y:\Users\camendol\SAS_ETL_dev\support_lib\log_report.html" 
options( button_text = "SAStoExcel" 
         pivotrow="log" 
         pivotcol="issue_type" 
         pivotdata="show_flag" 
         pivotdata_fmt="#,###" 
         pivotcharts="yes" 
         chart_type="cylindercolclustered" 
         chart_title="Log Analyzer" 
         chart_yaxes_title="Frequency" 
         chart_xaxes_title="Source Log" 
         chart_legend="bottom" 
         chart_datalabels="value" 
         chart_style="42" 
         gridline="no" 
         chart_yaxes_maxscale='5' 
         chart_yaxes_minscale='0' );

proc print data=work.categorized_messages noobs; 
  var log message_line issue_type show_flag line_num; 
run; 

ods tagsets.tableeditor close;



   
