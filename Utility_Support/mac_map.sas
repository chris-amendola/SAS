/*!
*
*        Maps elements from a list into a sas macro which takes a
*         single parm)
*		      <p>Can be called inside a datastep
*			  <p>Abends SAS session on bad parameter setting
*
*    @author  Chris Amendola
*    @created    04-2015
*/
/**
* @param  list    Name of macro var with sep/delimited list of elements to map into function/sub-routine
* @param  sub_rtn Macro function or sub-routine which uses dataset values(Positional)  
* @param  sep     List separator/delimiter default is a single space
*/                
%macro mac_map( sub_rtn
	           ,to_list=
	           ,sep=);

     %local ermsg 
           for_num 
           _element
		   _sep
		   _res_list
		   ;		

    %let _res_list = &&&to_list.;
    
    %let ermsg=;
	
	%if %length(&sep) eq 1 %then %let _sep=%str(&sep); 
	%else %let _sep=%nrstr( );
    /**
	 * Simple validation of parms, i.e. are they populated at all?
	 */
    %if %length(&_res_list) < 1 %then %let ermsg=No elements list provided!!!;
    %if %length(&sub_rtn) < 1 %then %let ermsg=No Sub-Routine to map!!!;
    /** 
	 *On error stop full program
	 */
    %if %length(&ermsg) > 1 %then %do;
        %put ERROR-> &ermsg;
		%put Usage dolist(sub-routine or function , elements list);
	    %put ABORT!!!;
		%abort cancel;
    %end;
    /**
	 * Scan through the list and apply each element
	 */
    %let for_num=1;
    %let _element=%scan(%quote(&_res_list),&for_num,%str(&_sep));
   
    %do %while(%length(&_element) > 0);
		%&sub_rtn(&_element)
        %let for_num=%eval(&for_num+1);
		%let _element=%scan(%quote(&_res_list),&for_num,%str(&_sep));
    %end;
    
%mend mac_map;
