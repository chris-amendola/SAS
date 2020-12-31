%macro trans_control(vars=_character_,arr_name=trans);

array &arr_name(*) &vars;
do __trans_i__=1 to dim(&arr_name);
   &arr_name(__trans_i__)=translate(&arr_name(__trans_i__),repeat(' ',31),collate(0,31));
end;
drop __trans_i__;

%mend trans_control;
