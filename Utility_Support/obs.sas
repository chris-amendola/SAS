/*!
 *       Returns the observation count for a data set. 
 */
/** 
*    @param _ds data set name
* 
*    @return Observation Count
*/
/*
 * Simple use:
 *
 *   %let _enroll_recs=%obs(work.enroll);
 */
%macro obs(_ds);

    %local _dsid 
           _num_obs 
           _rc;

    %let _num_obs =.;
    %let _dsid = %sysfunc(open(&_ds, i));

    %if &_dsid <= 0 %then %do;
        %put WARN_MESSAGE: data set &_ds could not be opened.  Unable to determine number of observations.;
    %end;
    %else %do;
        %let _num_obs = %sysfunc(attrn(&_dsid, nlobs));
        %let _rc = %sysfunc(close(&_dsid));
    %end;

    &_num_obs
  
%mend obs;
