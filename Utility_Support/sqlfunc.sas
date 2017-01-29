%macro sqlfunc;
	
    %let sqlselect=%sysfunc(dequote(&sqlselect));
    %let sqlresults = ;
    proc sql noprint;
        create view _TempView_ as &sqlselect;
        select * into: sqlresults separated by " " 
            from _TempView_;
        drop view _TempView_;
    quit;
    %let sqlresults=&sqlresults;
    
%mend sqlfunc; 