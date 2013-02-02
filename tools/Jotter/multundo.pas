unit multundo;

interface
uses Windows, SysUtils, Classes, stdCtrls;

type tMultUndo=
 class
  list,sslist:tStringList;
  cur:integer;
  memo:tCustomMemo;
  constructor Create(customMemo:tCustomMemo);
  procedure add;
  procedure undo;
  destructor Destroy;override;
 end;

implementation

constructor tMultUndo.Create(customMemo:tCustomMemo);
begin
 inherited Create;
 list:=tStringList.Create;
 sslist:=tStringList.Create;
 cur:=-1;
 memo:=customMemo;
end;

procedure tMultUndo.add;
var i:integer;
begin
 for i:=cur+1 to list.Count-1 do
  begin
   list.Delete(cur+1);
   sslist.Delete(cur+1);
  end;
 cur:=list.count;
 list.Add(memo.SelText);
 sslist.Add(inttostr(memo.SelStart));
end;

procedure tMultUndo.undo;
begin
 if cur>=0 then
  begin
   memo.SelStart:=strtoint(sslist.Strings[cur]);
   memo.SelText:=list.Strings[cur];
   dec(cur);
  end;
end;

destructor tMultUndo.Destroy;
begin
 list.free;
 sslist.free;
 inherited Destroy;
end;

end.
