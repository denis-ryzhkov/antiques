uses crt;
var h,d:word;
    e:integer;
begin
 if paramcount=2 then
  begin
   val(paramstr(1),h,e);
   if e=0 then
    val(paramstr(2),d,e);
   if e=0 then
    begin
     sound(h);
     delay(d);
     nosound;
    end;
  end;
end.