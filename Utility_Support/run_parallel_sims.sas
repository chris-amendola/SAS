/*! 
 *      Submits 'blocks" of individual data simulations to run at one time on the SASGRID server, 
 *      to improve the "clock-times" when large numbers of iteration are required.
 *      <p> A user-written simulation macro, in a standard format, is run by %run_parallel, sending 
 *       logs and outputs to user specified directories.
 *      The simulation program is saved as a stand-alone macro-file, that will be named in the call 
 *      of the %run_parallel macro.
 *      The user also supplies arguments for the total number of iterations to be run, as well as 
 *      the number of iterations to be submitted to the server at one time.
 *      %run_parallel_sims is called in a SAS-script, with specific argument settiings for a given project.
 *
 *        @author     Chris Amendola 
 *        @author     Dan Boisvert
 *       
 *         @created   November 2016 
 */
/**  
  * @param  simulation_prog      {Required} Full path and program name.
  * @param  number_simulations   {Required} Total number of simulations to run. 
  * @param  simulations_block    {Required} Number of simulations running at one time 
  * @param  log_dir              {Required} Path to write individual iterations' logs 
  * @param  output_dir           {Required} Path to write individual iterations' .lst files
  * @param  nolist               {Optional} Default=NO. Turns off list creation when set to Yes 
  *  
  */
%macro run_parallel_sims( simulation_prog=    
                         ,number_simulations= 
                         ,simulations_block=  
                         ,log_dir=            
                         ,output_dir=  
                         ,nolist=NO);
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
    %put run_parallel_sims: Usage exception: &_desc;
    %put run_parallel_sims: Job terminating.;
    %put ;
    %put ****************************************;                                                   
    %put ;
        
    /* Reset options */
    options &_notes 
            lineSize=&_linesize 
            &_mprint 
            &_mlogic 
            &_symbolgen;
        
     %abort cancel;
        
  %mend exception;
  /**
	  * Capture Current SAS options 
	  */
  %let _notes = %sysfunc(getoption(notes));
  %let _mprint = %sysfunc(getoption(mprint));
  %let _symbolgen = %sysfunc(getoption(symbolgen));
  %let _mlogic = %sysfunc(getoption(mlogic));
  %let _linesize = %sysfunc(getoption(linesize));  

  /** 
	  * Validate parameter arguments
	  */
  %check_argument( parm= simulation_prog                     
                  ,isa= FILE                  
                  ,required=YES);

  %check_argument( parm= number_simulations
                  ,isa=INT
                  ,numeric_min=1
                  ,required=YES);

  %check_argument( parm= simulations_block
                   ,isa=INT
                   ,numeric_min=1  
                   ,numeric_max=40 
                   ,required=YES);

  %check_argument( parm= log_dir
                  ,isa=PATH                 
                  ,required=YES
                  );
                 
  %check_argument( parm= output_dir
                  ,isa=PATH                
                  ,required=YES
                  );      

  %check_argument( parm= nolist
                  ,isa=CHAR
                  ,required=YES
                  ,valid_values=NO No no n N Yes YES Y yes) 
                                                
	/** 
	  * Stop process on bad argument
	  */
    %if &_argument_check_code = 0 %then %do;  
        %put Bad argument(s) found in run_parallel_sims-invocation.;      
        %put Ending Now.;
        %abort cancel;
    %end;
  /* 
   * Is block number higher that total mumber?
   */ 
  %if &simulations_block > &number_simulations 
    %then %exception(Number of simulations per block is higher than total number of simulations - perhaps the values have been switched?)    
	/**
	  * Main process begins
	  */
	 /** 
	  * Local Macro variables
	  */
   %local _done;
   %let _done=0; 
   /* 
   * Going to run the total number of simulations in blocks - for example
   * 100 iterations in blocks of 20 at a time
   */
  /* Intialize counters for first block of iterations*/
  %let block_start=1;
  %let block_end=&simulations_block;

  %do %while(not(&_done));
    /* Check conditions for next block of iterations */
    %if &block_end>&number_simulations %then %do;
        %let block_end=&number_simulations;
        %let _done=1;
	  %end;

    /* Send a block of simulation runs to the server */
    %put ***;
    %put Submitting iterations &block_start to &block_end to server;
	  %put ***;

    %do loop=&block_start %to &block_end;

      /* Enable one specific iteration to run by-itself on server */
      %let rc=%sysfunc( GRDSVC_ENABLE(grids&loop
                       ,server=SASAppGRID)); 

      options autosignon;

     /* Send macrovar 'loop' to the server for the iteration about to run */
     %syslput loop=&loop /REMOTE=grids&loop;
	   /* Send macrovar 'simulation_prog' to the server for the iteration about to run */
     %syslput simulation_prog=&simulation_prog /REMOTE=grids&loop;
	   /* Send log_dir to to iteration to be run */
	   %syslput log_dir=&log_dir /REMOTE=grids&loop;
	   /* Send output_dir to iteration to be run */
	   %syslput output_dir=&output_dir /REMOTE=grids&loop;
	   /* Send nolist to iteration to be run */
	   %syslput nolist=&nolist /REMOTE=grids&loop;

	   /* Tell server what follows is what you want to run for the iteration */
     rsubmit grids&loop WAIT=NO;

     /* Create a separate log for each iteration */
	   %put ***;
     %put *** Sending current iteration log to &log_dir.simnum&loop..log; 
	   %put ***;
     proc printto log="&log_dir.simnum&loop..log" new;
     run;
     /* Generate Separate .lst file for each iteration - if not turned off*/
     %if &nolist=NO %then %do;
       %put ***;
       %put *** Sending current iteration lst to &output_dir.simnum&loop..log; 
	   %put ***;
	   proc printto print="&output_dir.simnum&loop..lst" new;
       run;
     %end;
	   /* One output directory for datasets generated for each iteration */
	   libname output "&output_dir";
	   
	   /*****************************/
	   /* Simulation code %INCLUDED */
	   /*****************************/
     %include "&simulation_prog";

     /* Clear the location for SAS log */
     proc printto;
     run;

	   /* Tell server the iteration has been submitted */
       endrsubmit; 

   %end; /* Loop to run a block of simulations */

   /* Tell server the iterations run in this block are done */
   %do loop=&block_start. %to &block_end.;

       /* Tell server your are done with iteration when it runs */ 
       signoff grids&loop;

    %end;
    /*
	   * The following code calculates the next block of simulations to run
	   */
    %let block_start=%eval(&block_start+&simulations_block);
	%let block_end=%eval(&block_end+&simulations_block);
	
	  
  %end;
   
  /* Reset options */
  options &_notes 
          lineSize=&_linesize 
          &_mprint 
          &_mlogic 
          &_symbolgen;  

%mend run_parallel_sims;
