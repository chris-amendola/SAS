/* Bring in necessary Support Modules */
options sasautos=(sasautos
                 '\\nasgw8315pn\imp\SAS_Dev_Workspace\camendol\SASApps\Macros\Prod'
                 '!sasfolder\sasmacro'
                 'Y:\Users\camendol\SAS_ETL_dev\support_lib'
                 'Y:\Users\camendol\SAS_ETL_dev\user_lib'
                 );
/*
 * Unit Test Tools
 */
%include "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testlib\unittest.sas";
   
/**
  * Macro under testing
  */
%include "Y:\Users\camendol\SAS_ETL_dev\user_lib\infer_schema.sas";

libname testlib "Y:\Users\camendol\SAS_ETL_dev\testing\unit\testdata";

%infer_schema( scan_obs=10000
              ,delm=PIPE
              ,schema_out=Y:/Users/camendol/SAS_ETL_dev/config/test_schema2.dlm
              ,data_file=Y:\Users\camendol\SAS_ETL_dev\data\incoming\professionaldetail.txt);

%read_schema(Y:/Users/camendol/SAS_ETL_dev/config/test_schema2.dlm)

proc sql noprint;
  select "'"||strip(name)||"'" into :_var_list separated by "," from work.metadata;
quit;

/* Check if metadata file was created */
%let _for_itid=%sysfunc(open(work.metadata));

/* Verify sort order is by order_number */
%let _sort_key=%sysfunc(attrc(&_for_itid,sortedby));

data _null_;
  set work.metadata;
  /* Demonstrate metadata exists */
  exist=&_for_itid;
  %assert( (exist>0)
          ,message=Metadata created)

  /* Test  sort order is by order_number */
  sort_order="&_sort_key";
  %assert( (sort_order='order_number')
          ,message= Sort order by order_number)

  /* Test no variables added */
  %assert( (name in (&_var_list))
           ,message=No un-expected vars in metadata)

  /* Test if all variables found. */
  test_list="&_var_list";
  pass_list="'ClaimID','ClaimLine','BeginDOS','EndDOS','PointerDx1','PointerDx1Desc','PointerDx2','PointerDx2Desc','PointerDx3','Pointe
rDx3Desc','PointerDx4','PointerDx4Desc','POS','Px','PXDesc','Units','LineAmtPaid','SrvcProvID','SrvcProvTaxonomy','SrvcProvTaxonDesc
'";
  %assert( (test_list=pass_list)
          ,message=All expected vars found)
  
  /* Check attributes for incoming var ClaimID */
  %assert( (length='$10'),(name='ClaimID'),message=Correct length for var ClaimID )
  %assert( (format='$10.'),(name='ClaimID'),message=Correct format for var ClaimID )
  %assert( (type=.),(name='ClaimID'),message=Correct type for var ClaimID )
  %assert( (label='') ,(name='ClaimID') ,message=Correct label for var ClaimID)
  
  /* Check attributes for incoming var ClaimLine */
  %assert( (length='8'),(name='ClaimLine'),message=Correct length for var ClaimLine )
  %assert( (format='BEST12.'),(name='ClaimLine'),message=Correct format for var ClaimLine )
  %assert( (type=.),(name='ClaimLine'),message=Correct type for var ClaimLine )
  %assert( (label='') ,(name='ClaimLine') ,message=Correct label for var ClaimLine)
  
  /* Check attributes for incoming var BeginDOS */
  %assert( (length='8'),(name='BeginDOS'),message=Correct length for var BeginDOS )
  %assert( (format='YYMMDD10.'),(name='BeginDOS'),message=Correct format for var BeginDOS )
  %assert( (type=.),(name='BeginDOS'),message=Correct type for var BeginDOS )
  %assert( (label='') ,(name='BeginDOS') ,message=Correct label for var BeginDOS)
  
  /* Check attributes for incoming var EndDOS */
  %assert( (length='8'),(name='EndDOS'),message=Correct length for var EndDOS )
  %assert( (format='YYMMDD10.'),(name='EndDOS'),message=Correct format for var EndDOS )
  %assert( (type=.),(name='EndDOS'),message=Correct type for var EndDOS )
  %assert( (label='') ,(name='EndDOS') ,message=Correct label for var EndDOS)
  
  /* Check attributes for incoming var PointerDx1 */
  %assert( (length='$5'),(name='PointerDx1'),message=Correct length for var PointerDx1 )
  %assert( (format='$5.'),(name='PointerDx1'),message=Correct format for var PointerDx1 )
  %assert( (type=.),(name='PointerDx1'),message=Correct type for var PointerDx1 )
  %assert( (label='') ,(name='PointerDx1') ,message=Correct label for var PointerDx1)
  
  /* Check attributes for incoming var PointerDx1Desc */
  %assert( (length='$35'),(name='PointerDx1Desc'),message=Correct length for var PointerDx1Desc )
  %assert( (format='$35.'),(name='PointerDx1Desc'),message=Correct format for var PointerDx1Desc )
  %assert( (type=.),(name='PointerDx1Desc'),message=Correct type for var PointerDx1Desc )
  %assert( (label='') ,(name='PointerDx1Desc') ,message=Correct label for var PointerDx1Desc)
  
  /* Check attributes for incoming var PointerDx2 */
  %assert( (length='$5'),(name='PointerDx2'),message=Correct length for var PointerDx2 )
  %assert( (format='$5.'),(name='PointerDx2'),message=Correct format for var PointerDx2 )
  %assert( (type=.),(name='PointerDx2'),message=Correct type for var PointerDx2 )
  %assert( (label='') ,(name='PointerDx2') ,message=Correct label for var PointerDx2)
  
  /* Check attributes for incoming var PointerDx2Desc */
  %assert( (length='$35'),(name='PointerDx2Desc'),message=Correct length for var PointerDx2Desc )
  %assert( (format='$35.'),(name='PointerDx2Desc'),message=Correct format for var PointerDx2Desc )
  %assert( (type=.),(name='PointerDx2Desc'),message=Correct type for var PointerDx2Desc )
  %assert( (label='') ,(name='PointerDx2Desc') ,message=Correct label for var PointerDx2Desc)
  
  /* Check attributes for incoming var PointerDx3 */
  %assert( (length='$5'),(name='PointerDx3'),message=Correct length for var PointerDx3 )
  %assert( (format='$5.'),(name='PointerDx3'),message=Correct format for var PointerDx3 )
  %assert( (type=.),(name='PointerDx3'),message=Correct type for var PointerDx3 )
  %assert( (label='') ,(name='PointerDx3') ,message=Correct label for var PointerDx3)
  
  /* Check attributes for incoming var PointerDx3Desc */
  %assert( (length='$35'),(name='PointerDx3Desc'),message=Correct length for var PointerDx3Desc )
  %assert( (format='$35.'),(name='PointerDx3Desc'),message=Correct format for var PointerDx3Desc )
  %assert( (type=.),(name='PointerDx3Desc'),message=Correct type for var PointerDx3Desc )
  %assert( (label='') ,(name='PointerDx3Desc') ,message=Correct label for var PointerDx3Desc)
  
  /* Check attributes for incoming var PointerDx4 */
  %assert( (length='$5'),(name='PointerDx4'),message=Correct length for var PointerDx4 )
  %assert( (format='$5.'),(name='PointerDx4'),message=Correct format for var PointerDx4 )
  %assert( (type=.),(name='PointerDx4'),message=Correct type for var PointerDx4 )
  %assert( (label='') ,(name='PointerDx4') ,message=Correct label for var PointerDx4)
  
  /* Check attributes for incoming var PointerDx4Desc */
  %assert( (length='$35'),(name='PointerDx4Desc'),message=Correct length for var PointerDx4Desc )
  %assert( (format='$35.'),(name='PointerDx4Desc'),message=Correct format for var PointerDx4Desc )
  %assert( (type=.),(name='PointerDx4Desc'),message=Correct type for var PointerDx4Desc )
  %assert( (label='') ,(name='PointerDx4Desc') ,message=Correct label for var PointerDx4Desc)
  
  /* Check attributes for incoming var POS */
  %assert( (length='8'),(name='POS'),message=Correct length for var POS )
  %assert( (format='BEST12.'),(name='POS'),message=Correct format for var POS )
  %assert( (type=.),(name='POS'),message=Correct type for var POS )
  %assert( (label='') ,(name='POS') ,message=Correct label for var POS)
  
  /* Check attributes for incoming var Px */
  %assert( (length='$5'),(name='Px'),message=Correct length for var Px )
  %assert( (format='$5.'),(name='Px'),message=Correct format for var Px )
  %assert( (type=.),(name='Px'),message=Correct type for var Px )
  %assert( (label='') ,(name='Px') ,message=Correct label for var Px)
  
  /* Check attributes for incoming var PXDesc */
  %assert( (length='$35'),(name='PXDesc'),message=Correct length for var PXDesc )
  %assert( (format='$35.'),(name='PXDesc'),message=Correct format for var PXDesc )
  %assert( (type=.),(name='PXDesc'),message=Correct type for var PXDesc )
  %assert( (label='') ,(name='PXDesc') ,message=Correct label for var PXDesc)
  
  /* Check attributes for incoming var Units */
  %assert( (length='8'),(name='Units'),message=Correct length for var Units )
  %assert( (format='BEST12.'),(name='Units'),message=Correct format for var Units )
  %assert( (type=.),(name='Units'),message=Correct type for var Units )
  %assert( (label='') ,(name='Units') ,message=Correct label for var Units)
  
  /* Check attributes for incoming var LineAmtPaid */
  %assert( (length='8'),(name='LineAmtPaid'),message=Correct length for var LineAmtPaid )
  %assert( (format='BEST12.'),(name='LineAmtPaid'),message=Correct format for var LineAmtPaid )
  %assert( (type=.),(name='LineAmtPaid'),message=Correct type for var LineAmtPaid )
  %assert( (label='') ,(name='LineAmtPaid') ,message=Correct label for var LineAmtPaid)
  
  /* Check attributes for incoming var SrvcProvID */
  %assert( (length='$10'),(name='SrvcProvID'),message=Correct length for var SrvcProvID )
  %assert( (format='$10.'),(name='SrvcProvID'),message=Correct format for var SrvcProvID )
  %assert( (type=.),(name='SrvcProvID'),message=Correct type for var SrvcProvID )
  %assert( (label='') ,(name='SrvcProvID') ,message=Correct label for var SrvcProvID)
  
  /* Check attributes for incoming var SrvcProvTaxonomy */
  %assert( (length='$10'),(name='SrvcProvTaxonomy'),message=Correct length for var SrvcProvTaxonomy )
  %assert( (format='$10.'),(name='SrvcProvTaxonomy'),message=Correct format for var SrvcProvTaxonomy )
  %assert( (type=.),(name='SrvcProvTaxonomy'),message=Correct type for var SrvcProvTaxonomy )
  %assert( (label='') ,(name='SrvcProvTaxonomy') ,message=Correct label for var SrvcProvTaxonomy)
  
  /* Check attributes for incoming var SrvcProvTaxonDesc */
  %assert( (length='$97'),(name='SrvcProvTaxonDesc'),message=Correct length for var SrvcProvTaxonDesc )
  %assert( (format='$97.'),(name='SrvcProvTaxonDesc'),message=Correct format for var SrvcProvTaxonDesc )
  %assert( (type=.),(name='SrvcProvTaxonDesc'),message=Correct type for var SrvcProvTaxonDesc )
  %assert( (label='') ,(name='SrvcProvTaxonDesc') ,message=Correct label for var SrvcProvTaxonDesc)
  
  
run;

%reports(locate=Y:\Users\camendol\SAS_ETL_dev\testing\unit\reports\
         ,test_scenario=infer_schema Testing
         ,report_label=infer_schema.html);
