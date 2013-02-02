unit memoUtil;

interface
uses windows, sysUtils, StdCtrls, Dialogs, Forms, ComCtrls, Controls;

procedure delCurLine(memo:tCustomMemo);
procedure moveSelLeft(memo:tCustomMemo);
procedure moveSelRight(memo:tCustomMemo);
procedure tabAsPrevLine(memo:tCustomMemo);
procedure findReplText(memo:tRichEdit;findtext,
 repltext:string;casesens,wholeonly,doreplace:boolean;var findOfs:integer);
implementation

procedure delCurLine(memo:tCustomMemo);
begin
 if memo.Lines.Count>0 then
  memo.Lines.Delete(memo.CaretPos.y);
end;

procedure moveSelLeft(memo:tCustomMemo);
var s:string;
    i,ss,sl:integer;
begin
 memo.Lines.BeginUpdate;
 ss:=memo.selstart;
 sl:=memo.SelLength;
 s:=memo.SelText;
 i:=0;
 delete(s,1,1);
 dec(sl);
 while i<length(s) do
  begin
   if s[i]=#13 then
    begin
     if s[i+2]=#13 then
      delete(s,i+2,2)
     else
      delete(s,i+2,1);
     dec(sl);
    end;
   inc(i);
  end;
 memo.SelText:=s;
 memo.SelStart:=ss;
 memo.SelLength:=sl;
 memo.Lines.EndUpdate;
end;

procedure moveSelRight(memo:tCustomMemo);
var s:string;
    i,ss,sl:integer;
begin
 memo.Lines.BeginUpdate;
 ss:=memo.selstart;
 sl:=memo.SelLength;
 s:=memo.SelText;
 i:=0;
 insert(' ',s,1);
 inc(sl);
 while i<length(s) do
  begin
   if (s[i]=#13) and (i<>length(s)-1) then
    begin
     insert(' ',s,i+2);
     inc(sl);
    end;
   inc(i);
  end;
 memo.SelText:=s;
 memo.SelStart:=ss;
 memo.SelLength:=sl;
 memo.Lines.EndUpdate;
end;

procedure tabAsPrevLine(memo:tCustomMemo);

 function blanks(s:string):string;
 var i:integer;
     nbfound:boolean;
 begin
  if (length(s)=0) or (s=#13#10) then
   result:='!'
  else
   begin
    i:=1;
    result:='';
    nbfound:=false;
    while (not nbfound) and (i<=length(s)) do
     begin
      if (s[i]=' ') or (s[i]=#9) then
       result:=result+s[i]
      else
       nbfound:=true;
      inc(i);
     end;

    if not nbfound then
     result:='!';
   end;
 end;

var prevstr,bs:string;
    y:integer;
begin
 if memo.CaretPos.y=0 then
  memo.SelText:=#9
 else
  begin
   y:=memo.caretPos.y-1;
   prevstr:=memo.Lines.Strings[y];
   while (blanks(prevstr)='!') and (y>0) do
    begin
     dec(y);
     prevstr:=memo.Lines.Strings[y];
    end;

   bs:=blanks(prevstr);
   if bs='!' then
    memo.SelText:=#9
   else
    begin
     memo.SelText:=bs;
    end;
  end;
end;

procedure findReplText(memo:tRichEdit;findtext,
 repltext:string;casesens,wholeonly,doreplace:boolean;var findOfs:integer);
var fs:integer;
    mr:tModalResult;
    st:tSearchTypes;
    all:boolean;

procedure dofind;
begin
 fs:=memo.FindText(findtext,memo.selstart+findOfs,
  length(memo.text)-memo.selstart,st);
 mr:=mrYes;
 if fs=-1 then
  showmessage('Поиск закончен.')
 else
  begin
   findOfs:=1;
   memo.SelStart:=fs;
   memo.SelLength:=length(findText);
   if doreplace then
    begin
      if not all then
       mr:=MessageDlg('Заменить "'+memo.SelText+
        '" на "'+replText+'"?',mtConfirmation,
        [mbYes,mbNo,mbAll,mbCancel],0);
      case mr of
       mrYes: memo.SelText:=replText;
       mrNo: memo.SelStart:=memo.SelStart+1;
       mrAll: begin
               all:=true;
               memo.SelText:=replText;
              end;
       mrCancel: findOfs:=0;
      end;
      if mr<>mrCancel then
       dofind;
    end;
  end;
end;

begin
 if casesens then
  include(st,stMatchCase);
 if wholeonly then
  include(st,stWholeWord);
 all:=false;
 dofind;
end;


end.
