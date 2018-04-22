/*******************************************************************************************;
Program:      parse_name.sas                                                               
Description:  parse a name variable in 'Last Name, First Name Middle Initial' format    
              into 3 separate fields: _first_name _mid_init_name _last_name                      

Macro Parameters:                                                                       
                                                                                        
     name_var:  name variable to parse                                       
                Format:   Last Name, First Name Middle Initial                                                
                Example:  Skywalker, Luke A    

Example use:

     data new_member_data;

          set member_data (keep=member mem_name dob);

          %parse_name(name_var=mem_name);

          length member_first_name member_mi member_last_name;

          member_first_name = _first_name;
          member_mi         = _mid_init_name;
          member_last_name  = _last_name;

     run;

*****************************************************************************************
Updates                                                                                 

05/20/2005 (lb):                                                                        
  -  initial development.

******************************************************************************************/

%macro parse_name(name_var=);

   length _first_name $20 _mid_init_name $1 _last_name $20 rest_of_name $100 last_chunk $100;
   drop rest_of_name last_chunk;

   /* last name ends at comma and can include spaces for suffix or hyphens */
   _last_name=scan(&name_var.,1,',');

   /* pull off last name so can use space as delimiter for remainder */
   rest_of_name=left(substr(&name_var.,(index(&name_var.,',')+1)));

   /* see if there is more than 1 chunk of text in rest_of_name.            */
   /* if the last piece is a length of 1 then call it middle initial        */
   /* and then the remaing text becomes first name.                         */
   /* otherwise if the last chunk of text is longer than 1 character then   */ 
   /* use all of rest_of_name as first name                                 */
   if scan(rest_of_name,2,' ') ne ' ' 
       then last_chunk=scan(reverse(rest_of_name),1);
   if length(last_chunk)=1 and last_chunk ne ' '
      then do;
           _mid_init_name=last_chunk;
           _first_name=reverse(scan(reverse(rest_of_name),2));
           end;
      else _first_name=rest_of_name;

%mend parse_name;

