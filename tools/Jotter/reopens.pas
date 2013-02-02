unit reopens;

interface
uses windows, sysutils, classes, stdCtrls, iniFiles;

type
 tReopen=
  class
   Fic:integer;
   list,sslist:tStringList;
   inif:tIniFile;
   procedure setic(newic:integer);
   procedure addfn(filename:string);
   procedure writess(filename:string;memo:tCustomMemo);
   function readss(filename:string):integer;
   constructor Create(inifile:tIniFile);
   destructor Destroy;override;
   property ic:integer read Fic write setic;
  end;

implementation

const
 reopen_='Reopen';
 ic_='ItemsCount';
 item_='Item';
 ss_='SelStart';

function tReopen.readss(filename:string):integer;
var i,fni:integer;
begin
 fni:=-1;
 for i:=1 to ic do
  if list.Strings[i-1]=filename then
   fni:=i;

 if fni=-1 then
  result:=0
 else
  result:=strtoint(sslist.Strings[fni-1]);
end;

procedure tReopen.writess(filename:string;memo:tCustomMemo);
var i,fni:integer;
begin
 fni:=-1;
 for i:=1 to ic do
  if list.Strings[i-1]=filename then
   fni:=i;

 if fni<>-1 then
  sslist.Strings[fni-1]:=inttostr(memo.selstart);
end;

procedure tReopen.addfn(filename:string);
var i,oldi:integer;
begin
 oldi:=-1;
 for i:=1 to ic do
  if list.Strings[i-1]=filename then
   oldi:=i;

 if oldi=-1 then
  begin
   list.Insert(0,filename);
   sslist.Insert(0,'0');
  end
 else
  begin
   list.Move(oldi-1,0);
   sslist.Move(oldi-1,0);
  end;

 if list.Count>ic then
  list.Delete(ic);
 if sslist.Count>ic then
  sslist.Delete(ic);
end;

procedure tReopen.setic(newic:integer);
var i:integer;
begin
 if newic>ic then
  for i:=1 to newic-ic do
   begin
    list.Add('');
    sslist.Add('0');
   end
 else
  for i:=ic-newic downto 1 do
   begin
    list.Delete(i-1);
    sslist.Delete(i-1);
   end;
 fic:=newic;
end;

constructor tReopen.Create(inifile:tIniFile);
var i:integer;
begin
 inherited create;
 inif:=inifile;
 list:=tStringList.Create;
 sslist:=tStringList.Create;
 Fic:=inif.ReadInteger(reopen_,ic_,17);
 for i:=1 to ic do
  list.add(inif.ReadString(reopen_,item_+inttostr(i),''));
 for i:=1 to ic do
  sslist.add(inif.ReadString(ss_,item_+inttostr(i),'0'));
end;

destructor tReopen.Destroy;
var i:integer;
begin
 inif.EraseSection(reopen_);
 inif.EraseSection(ss_);
 inif.WriteInteger(reopen_,ic_,ic);
 for i:=1 to ic do
  inif.WriteString(reopen_,item_+inttostr(i),list.Strings[i-1]);
 for i:=1 to ic do
  inif.WriteString(ss_,item_+inttostr(i),sslist.Strings[i-1]);
 list.Free;
 sslist.Free;
 inherited destroy;
end;

end.
