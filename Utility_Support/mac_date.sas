%macro mac_date(dts=,macvars=,global=Y,format=mmddyy10,quotem=N);

       /*---------------------------------------------------*/
       /* Purpose of macro:                                 */
       /*                                                   */
       /* To create and populate macro variables with       */
       /* values corresponding to formatted dates.          */
       /*                                                   */
       /* The macro can be used for a variety of purposes   */
       /* including, but not limited to,                    */
       /*                                                   */
       /* 1) creating date literals in the native format of */
       /*    an RDBMS                                       */
       /*                                                   */
       /* 2) creating formatted dates for report titles.    */
       /*                                                   */
       /* Definition of macro variables:                    */
       /*                                                   */
       /* DTS      -                                        */
       /*                                                   */
       /* The list of dates to be formatted.                */
       /*                                                   */
       /* The values must be of the form YYMMDD or CCYYMMDD */
       /* and must be separated by at least one space.      */
       /*                                                   */
       /* The special DD value of 99 will cause the macro   */
       /* to replace the DD with the last day of the given  */
       /* month.                                            */
       /*                                                   */
       /* There is no default value.                        */
       /*                                                   */
       /* MACVARS  -                                        */
       /*                                                   */
       /* The list of macro variables to be populated.      */
       /*                                                   */
       /* The values must be valid macro variable names and */
       /* must be seperated by at least one space.          */
       /*                                                   */
       /* There is no default value.                        */
       /*                                                   */
       /* GLOBAL   -                                        */
       /*                                                   */
       /* Determines the reference environment for the      */
       /* macro variables. A value of Y will cause the      */
       /* macro variables to be placed in the Global        */
       /* reference environment, otherwise the macro        */
       /* variables will be placed in the reference         */
       /* environment defined by SAS. If Y is not specified */
       /* the macro variables should be created within the  */
       /* calling environment before invoking the macro.    */
       /*                                                   */
       /* The default value is Y.                           */
       /*                                                   */
       /* FORMAT   -                                        */
       /*                                                   */
       /* The format to be used in populating the macro     */
       /* variables. An ending period (.) is optional.      */
       /*                                                   */
       /* The special value ORADATE1 can be used to format  */
       /* dates as DD-MON-YY.                               */
       /*                                                   */
       /* The default value is mmddyy10..                   */
       /*                                                   */
       /* QUOTEM   -                                        */
       /*                                                   */
       /* Determines whether the macro surrounds the target */
       /* variables with single quotes('...')               */
       /*                                                   */
       /* The default value is N.                           */
       /*                                                   */
       /*---------------------------------------------------*/

%let global=%upcase(&global);
%let format=%upcase(&format);
%let quotem=%upcase(&quotem);

%if %index(&format,.)=0
    %then %let format=&format..;

%local dt_len year month day;
%local i;

%let i=1;
%local dt&i mv&i;
%let dt&i=%scan(&dts,&i,%str( ));
%let mv&i=%scan(&macvars,&i,%str( ));

data _null_;

     length text $200;

%do %while (&&dt&i ne %str() and &&mv&i ne %str());

%if &global=Y
    %then %str(%global &&mv&i;);

    %let dt_len=%length(&&dt&i);
    %let year=%substr(&&dt&i,1,&dt_len-4);
    %let month=%substr(&&dt&i,&dt_len-4+1,2);
    %let day=%substr(&&dt&i,&dt_len-2+1,2);

%if &day=99
    %then %str(date=intnx('month',mdy(&month,1,&year),1)-1;);
    %else %str(date=mdy(&month,&day,&year););

%if &format=ORADATE1.
    %then %do;
          text=left(put(date,date7.));
          text=substr(text,1,2)||'-'||
               substr(text,3,3)||'-'||
               substr(text,6,2);
          %end;
    %else %do;
          text=left(put(date,&format));
          %end;

%if &quotem=Y
    %then %str(call symput("&&mv&i","'"||trim(text)||"'"););
    %else %str(call symput("&&mv&i",trim(text)););

%let i=%eval(&i+1);
%local dt&i mv&i;
%let dt&i=%scan(&dts,&i,%str( ));
%let mv&i=%scan(&macvars,&i,%str( ));

%end;

run;

%put *** Results from mac_date execution - Begin ***;
%put;

%local j;
%do j=1 %to &i-1;
%put Returned Value &j (passed value:&&dt&j,macro variable:&&mv&j) = &&&&&&mv&j;
%end;

%put;
%put *** Results from mac_date execution - End   ***;

%mend mac_date;
