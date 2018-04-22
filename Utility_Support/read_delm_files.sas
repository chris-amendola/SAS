/*! 
 *       Reads raw delimited data specifically.
 *       Reads a schema file, which defines the properties of the incoming
 *       datafile to 'ingest' it into SAS format.
 * 
 *        @author     C Amendola
 *       
 *         @created    August 2017
 */
/**  
  * @param src_dir            Source directory for list of files to be ingested. Required.
  * @param files              Space delimited list of file names to be read-in. required.
  * @param to_dataset         Working dataset to be created from infile. Required.
  * @param schema             Fully specified path to simple delimited file defining the incoming data schema. Required
  * @param delm               Column delimiter. Required. Default: |
  * @param header_rows        Number of rows at head of file to skip reading. Optional
  * @param as_view            Produce output datset as a veiw - time saving device. DEFAULT: NO.
  *  
  */
%macro read_delm_files( src_dir=
                           ,files=
                           ,to_dataset=
                           ,schema=
                           ,delm=
                           ,header_rows=
                           ,as_view=NO
                           ,show_lines=0);
                           
  /*Local methods*/
  /**
    * Internal Exception Handler.<br>
    * Inserts usage description into log when exception occurs.<br>
    * Cancels the job.
    *
    * @param _desc REQUIRED Exception message
    */                                 
  %macro exception(_desc);
          
    %put ****************************************;
       %put ;
    %put read_delm_files: Usage exception: &_desc;
    %put read_delm_files: Job terminating.;
    %put ;
    %put ****************************************;
    %put ;
        
    %abort cancel;
        
  %mend exception;                         
                           
  /** 
    * Validate parameter arguments
    * Stop process on bad argument
    */
  %check_argument( parm=to_dataset                      
                   ,isa=VALID_DATA                   
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm_files-invocation. Ending Now. );
 
  %check_argument( parm=files
                   ,isa=CHAR
                   ,required=YES);
  %if &_argument_check_code = 0 %then 
    %exception( Bad argument(s) found in read_delm_files-invocation. Ending Now. );                                                   
                       
  /* Drop output file - overwrite */
  %if %sysfunc(exist(&to_dataset)) %then %do;
    proc sql noprint;
        drop table %trim(&to_dataset);
    quit;    
  %end;                     
                       
  /* Local Macro to run in loop */
  %macro read_loop(_file);
    
    %read_delm(   infile=&src_dir.\&_file
                 ,to_dataset=work.__tmp__
                 ,schema=&schema
                 ,delm=&delm
                 ,header_rows=&header_rows
                 ,as_view=&as_view
                 ,show_lines=&show_lines);
                 
    /* If output file doesn't exist, initialize it with temp file. */ 
    %if (not %sysfunc(exist(&to_dataset))) %then %do;
      data &to_dataset;
          set work.__tmp__;
      run;
    %end;
    %else %do;
      proc datasets;
          append base=&to_dataset
                 data=work.__tmp__;
      run;
    %end;            
      
  %mend read_loop; 
      
  /* Act on the file list */    
  %mac_map(read_loop,to_list=files)           
                         
%mend read_delm_files;