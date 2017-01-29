/*!
 *
 * Creates a named dataset structure defintion table.
 * Also interpolates Oracle types for each field in
 * source table.
 *
 * Defintion table fields: name: Field name
 *                         type: Numeric(1) or character(2) 
 *				         length: Field length 
 *                        label: Field Text Descriptor 
 *	   				     format: SAS format for field 
 *					    formatl: Format length 
 *						 varnum: SAS varable number (field order)
 *             Oracle_Attribute: SAS type and format converted to Oracle Type
 *
 * @author Chris Amendola
 * @created May 25th 2015
 *
 */
 /**
   *
   *  @param table_name Positional Required Name of the table for the extracted definition
   *  @param set_from    Required Table from which to extract a definition
   *
   */   
%macro table_definition( table_name
                        ,set_from=);   

	/**
      * Date formats recognized
      */	  
    %let _date_format_list= "DATE"
	                       ,"DDMMYY"
						   ,"DATETIME"
						   ,"MMDDYY"
						   ,"YYMMDD";    
	
    /**
	  * TODO: Check for existance of table to extract definition
	  * TODO: Check for existance of the definiton table - prevent overwrite
	  */
	proc contents data=&set_from 
	               out=work.raw_table_def
				   noprint;
	run;
	
	data &table_name;
	    attrib oracle_attribute length = $35;
	    set work.raw_table_def(keep=name 
		                            type 
									length 
									label 
									format 
									formatl
									varnum);
		/**
          * Force standard format
          */		  
		name=upcase(name);
        format=upcase(format);	
		
		/** Create Oracle Type Attributes */							
		/** Numeric */
        if type = 1 then do;
		    /** Date */
		    if format in (&_date_format_list) then do;
			    oracle_attribute="DATE";
			end;
			/** Default */
			else do;
			    oracle_attribute="FLOAT(20)";
			end;
			/** Should we have a money type */
        end;
		/** Character */
        if type=2 then do;
		    oracle_attribute=compress("VARCHAR2("!!length!!")");
        end;		
    run;

%mend table_definition;
