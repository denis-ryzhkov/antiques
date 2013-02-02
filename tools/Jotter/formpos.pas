unit formpos;

interface
uses windows,sysUtils,forms,inifiles;

procedure writeFormPos(form:tForm;inif:tIniFile);
procedure readFormPos(form:tForm;inif:tIniFile);

implementation

const
 l_='Left';
 t_='Top';
 w_='Width';
 h_='Height';
 max_='Maximized';

procedure writeFormPos(form:tForm;inif:tIniFile);
var formn:string;
begin
 formn:=form.Name;
 if (form.BorderStyle=bsSizeable) or
    (form.BorderStyle=bsSizeToolWin) then
  begin
   if form.windowState<>wsMaximized then
     begin
      inif.WriteInteger(formn,l_,form.left);
      inif.WriteInteger(formn,t_,form.top);
      inif.WriteInteger(formn,w_,form.width);
      inif.WriteInteger(formn,h_,form.height);
     end;
   inif.WriteBool(formn,max_,form.windowState=wsMaximized);
  end
 else
  begin
   inif.WriteInteger(formn,l_,form.left);
   inif.WriteInteger(formn,t_,form.top);
  end;
end;

procedure readFormPos(form:tForm;inif:tIniFile);
var formn:string;
begin
 formn:=form.Name;
 form.left:=inif.ReadInteger(formn,l_,form.left);
 form.top:=inif.ReadInteger(formn,t_,form.top);
 form.width:=inif.ReadInteger(formn,w_,form.width);
 form.height:=inif.ReadInteger(formn,h_,form.height);
 if inif.ReadBool(formn,max_,false) then
  form.windowstate:=wsMaximized;
end;

end.
