unit subbufs;

interface
uses windows, sysutils, classes, stdCtrls, iniFiles;

type
 tSubBuf=
  class
   list:tStringList;
   inif:tIniFile;
   constructor Create(inifile:tIniFile);
   procedure keyPressed(key:word;shift:tShiftState;memo:tCustomMemo);
   destructor Destroy;override;
  end;

implementation

const
 subbuf_='SubBuffer';
 item_='Item';

constructor tSubBuf.Create(inifile:tIniFile);
var i:integer;
begin
 inherited create;
 inif:=inifile;
 list:=tStringList.Create;
 for i:=1 to 10 do
  list.add(inif.ReadString(subBuf_,item_+inttostr(i),''));
end;

procedure tSubBuf.KeyPressed(key:word;shift:tShiftState;memo:tCustomMemo);
var n:integer;
begin
 n:=key-49;
 if n=-1 then
  n:=9;
 if ssCtrl in shift then
  if ssShift in shift then
    list.Strings[n]:=memo.SelText
   else
    memo.SelText:=list.Strings[n];
end;

destructor tSubBuf.Destroy;
var i:integer;
begin
 inif.EraseSection(subBuf_);
 for i:=1 to 10 do
  inif.WriteString(subBuf_,item_+inttostr(i),list.Strings[i-1]);
 list.Free;
 inherited destroy;
end;

end.
