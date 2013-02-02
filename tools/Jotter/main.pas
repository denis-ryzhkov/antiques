unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, formpos, iniFiles, StdCtrls, Menus,
  memoUtil, qwerty, subbufs, ExtCtrls, shellApi, fhandlers,
  reopens, ComCtrls, find, registry, ftbinds{, multundo};

type
  TmainForm = class(TForm)
    memo: TRichEdit;
    pm: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N30: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    N28: TMenuItem;
    N35: TMenuItem;
    N29: TMenuItem;
    N32: TMenuItem;
    openDlg: TOpenDialog;
    pulse: TTimer;
    saveDlg: TSaveDialog;
    lb: TListBox;
    N7: TMenuItem;
    N25: TMenuItem;
    tabtim: TTimer;
    Jotterctxt1: TMenuItem;
    N20: TMenuItem;
    N26: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N2Click(Sender: TObject);
    procedure memoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N30Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure N22Click(Sender: TObject);
    procedure N23Click(Sender: TObject);
    procedure N28Click(Sender: TObject);
    procedure N35Click(Sender: TObject);
    procedure N29Click(Sender: TObject);
    procedure pulseTimer(Sender: TObject);
    procedure memoChange(Sender: TObject);
    procedure lbExit(Sender: TObject);
    procedure lbKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbDblClick(Sender: TObject);
    procedure N25Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure memoKeyPress(Sender: TObject; var Key: Char);
    procedure tabtimTimer(Sender: TObject);
    procedure N32Click(Sender: TObject);
    procedure Jotterctxt1Click(Sender: TObject);
    procedure N26Click(Sender: TObject);
  private

  public
    { Public declarations }
  end;

const
 jr_='Jotter';
 tunes_='Tunes';
 wrap_='Wrap';
 dos_='DOSCodepage';
 tab_='TabAsPrevLine';
 path_='Path';
 lastfn_='LastFileName';
 nf_='NewFile.';
 helptext_=
#9#9'       Jotter 2.2'#13#10+
#9#9'Creosoft (c) 2000'#13#10#13#10+
'-> F10 или правая кнопка мыши вызовут меню.'#13#10+
'-> "Ctrl+Shift+n" копирует выделенный текст'#13#10+
'   в n-ю строку суббуфера, "Ctrl+n" вставляет'#13#10+
'   текст из n-ой строки суббуфера (n=0..9).';

var
  mainForm: TmainForm;
  started,mdf,canChangeMdf,ovwr:boolean;
  inif:tIniFile;
  natfld,fn,fpath,sfn,lastfn:string;
  subbuf:tSubBuf;
  reopen:tReopen;
  oldx,oldy,findOfs:integer;
//  mu:tMultUndo;
  fh:tFHandler;

implementation

{$R *.DFM}

procedure setlb(source:tpersistent);
begin
 with mainForm do
  begin
   lb.Items.Assign(source);
   lb.Show;
   memo.Repaint;//fixes richedit gluck
   lb.SetFocus;
   if lb.Items.Count>1 then
    begin
     lb.ItemIndex:=1;
     lb.ItemIndex:=0;
    end;
  end;
end;

procedure jrFileOpen(filename:string);
var sl:tstringlist;
    s:string;
begin
 if fn<>'' then
  reopen.writess(fn,mainForm.memo);
 fn:=filename;
 if fn<>'' then
  begin
   mainform.openDlg.FileName:=fn;
   lastfn:=fn;
   fpath:=extractfilepath(fn);
   sfn:=extractfilename(fn);
   reopen.addfn(fn);
   canChangeMdf:=false;
   if not mainForm.N35.Checked then
    mainForm.memo.Lines.LoadFromFile(fn)
   else
    begin
     sl:=tStringList.Create;
     sl.LoadFromFile(fn);
     s:=sl.Text;
     sl.free;
     if s<>'' then
      oemtochar(pchar(s),pchar(s));
     mainForm.memo.Text:=s;
    end;
   mainForm.memo.SelStart:=reopen.readss(fn);
   mdf:=false;
   oldx:=-1;
  end;
end;

procedure jrFileSave;
var sl:tstringlist;
    s:string;
begin
 lastfn:=fn;
 fpath:=extractfilepath(fn);
 sfn:=extractfilename(fn);
 if not mainForm.N35.Checked then
  mainForm.memo.Lines.SaveToFile(fn)
 else
  begin
   s:=mainForm.memo.Text;
   if s<>'' then
    chartooem(pchar(s),pchar(s));
   sl:=tStringList.Create;
   sl.Text:=s;
   sl.SaveToFile(fn);
   sl.free;
  end;
 reopen.addfn(fn);
 mdf:=false;
 oldx:=-1;
end;

procedure updTtl;
var s:string;
begin
 if fn<>'' then
  s:=sfn+' - ';
 s:=s+jr_;
 application.Title:=s;
 s:=s+' [ '+inttostr(oldy)+':'+inttostr(oldx);
 if mdf then
  s:=s+' *';
 if ovwr then
  s:=s+' #';
 if mainForm.n35.Checked then
  s:=s+' DOS'
 else
  s:=s+' Win';
 s:=s+' ]';
 mainForm.caption:=s;
end;

procedure TmainForm.FormShow(Sender: TObject);
begin
 if not started then
  begin
   started:=true;
   natfld:=extractfilepath(paramstr(0));
   inif:=tIniFile.Create(natfld+jr_+'.ini');
   subBuf:=tSubBuf.Create(inif);
   reopen:=tReopen.Create(inif);
//   mu:=tMultUndo.Create(memo);
   fh:=tFHandler.Create(inif);
   readFormPos(mainForm,inif);
   readFormPos(findForm,inif);
   findForm.readTunes(inif);
   n28.Checked:=not inif.ReadBool(tunes_,wrap_,true);
   n28Click(self);
   n35.Checked:=inif.ReadBool(tunes_,dos_,false);
   n7.Checked:=inif.ReadBool(tunes_,tab_,true);
   fpath:=inif.ReadString(tunes_,path_,natfld);
   lastfn:=inif.ReadString(tunes_,lastfn_,'');
   oldx:=-1;
   oldy:=-1;
   mdf:=true;

   if (paramcount>0) and (fileexists(paramstr(1))) then
    jrFileOpen(paramstr(1))

   else if (lastfn<>'') and (fileexists(lastfn)) then
    jrFileOpen(lastfn);
  end;
end;

procedure TmainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 if fn<>'' then
  reopen.writess(fn,memo);
 inif.WriteBool(tunes_,wrap_,n28.Checked);
 inif.WriteBool(tunes_,dos_,n35.Checked);
 inif.WriteBool(tunes_,tab_,n7.Checked);
 inif.WriteString(tunes_,path_,fpath);
 inif.WriteString(tunes_,lastfn_,lastfn);
 writeFormPos(mainForm,inif);
 writeFormPos(findForm,inif);
 findForm.writeTunes(inif);
 subBuf.Free;
 reopen.Free;
// mu.free;
 fh.free;
 inif.Free;
end;

procedure TmainForm.N2Click(Sender: TObject);
begin
 close;
end;

procedure TmainForm.memoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case key of
  vk_F10:
   pm.Popup(left+15,top+30);

  48..57:
   subBuf.KeyPressed(key,shift,memo);

  vk_Tab:
   if n7.Checked then
    tabAsPrevLine(memo);

  vk_Return:
   if n7.Checked then
    tabtim.enabled:=true;

  vk_Insert:
   if not ((ssShift in shift) or (ssCtrl in shift) or (ssAlt in shift)) then
    begin
     ovwr:=not ovwr;
     oldx:=-1;
    end;
 end;
end;

procedure TmainForm.N4Click(Sender: TObject);
begin
// mu.undo;
 memo.Undo;
end;

procedure TmainForm.N5Click(Sender: TObject);
begin
// mu.add;
 memo.CutToClipboard;
end;

procedure TmainForm.N6Click(Sender: TObject);
begin
 memo.CopyToClipboard;
end;

procedure TmainForm.N8Click(Sender: TObject);
begin
// mu.add;
 memo.SelText:='';
end;

procedure TmainForm.N9Click(Sender: TObject);
begin
 delCurLine(memo);
end;

procedure TmainForm.N10Click(Sender: TObject);
begin
 memo.PasteFromClipboard;
end;

procedure TmainForm.N11Click(Sender: TObject);
begin
 memo.SelectAll;
end;

procedure TmainForm.N12Click(Sender: TObject);
begin
 moveSelLeft(memo);
end;

procedure TmainForm.N13Click(Sender: TObject);
begin
 moveSelRight(memo);
end;

procedure TmainForm.N30Click(Sender: TObject);
begin
 memo.SelText:=qwertyConvert(memo.SelText);
end;

procedure TmainForm.N14Click(Sender: TObject);
var ext:string;
begin
 if fn<>'' then
  reopen.writess(fn,memo);
 fn:='';
 lastfn:='';
 sfn:='';
 memo.Lines.Clear;
 mdf:=true;
 oldx:=-1;
 ext:='';
 if inputquery('Тип шаблона','',ext) and (ext<>'') then
  if fileexists(natfld+nf_+ext) then
   memo.Lines.LoadFromFile(natfld+nf_+ext)
  else
   if messagedlg('Шаблон "'+ext+'" не существует. Создать?',
    mtConfirmation,[mbYes,mbNo],0)=mrYes then
     begin
      fn:=natfld+nf_+ext;
      jrFileSave;
     end;
end;

procedure TmainForm.N15Click(Sender: TObject);
begin
 openDlg.InitialDir:=fpath;
 if openDlg.Execute then
  jrFileOpen(openDlg.FileName);
end;

procedure TmainForm.N16Click(Sender: TObject);
begin
 setlb(reopen.list);
end;

procedure TmainForm.N17Click(Sender: TObject);
begin
 if fn='' then
  N18Click(self)
 else
  jrFileSave;
end;

procedure TmainForm.N18Click(Sender: TObject);
begin
 if saveDlg.Execute then
  begin
   fn:=saveDlg.Filename;
   jrFileSave;
  end;
end;

procedure TmainForm.N19Click(Sender: TObject);
begin
 if messagedlg('Распечатать текст?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
  memo.Print(jr_+' - '+sfn);
end;

procedure TmainForm.N20Click(Sender: TObject);
begin
 if fn<>'' then
  fh.handle(fn)
 else
  N18Click(self);
end;

procedure TmainForm.N22Click(Sender: TObject);
begin
 if findForm.ShowModal=1 then
  begin
   findOfs:=0;
   N23Click(self);
  end;
end;

procedure TmainForm.N23Click(Sender: TObject);
begin
 with findForm do
 findReplText(memo,findCB.Text,replCB.Text,CaseChB.Checked,
  WholeChB.Checked,ReplChB.Checked,findOfs);
end;

procedure TmainForm.N28Click(Sender: TObject);
begin
 n28.Checked:=not n28.Checked;
 memo.WordWrap:=n28.Checked;
 if n28.Checked then
  memo.ScrollBars:=ssVertical
 else
  memo.ScrollBars:=ssBoth;
end;

procedure TmainForm.N35Click(Sender: TObject);
begin
 oldx:=-1;
 if fn<>'' then
  begin
   jrFileSave;
   n35.Checked:=not n35.Checked;
   jrFileOpen(fn);
  end
 else
  n35.Checked:=not n35.Checked; 
end;

procedure TmainForm.N29Click(Sender: TObject);
var ic:string;
begin
 ic:=inttostr(reopen.ic);
 if inputquery('Макс. переоткрываемых файлов','',ic) then
  reopen.ic:=strtoint(ic);
end;

procedure TmainForm.pulseTimer(Sender: TObject);
begin
 if (oldx<>memo.CaretPos.x) or (oldy<>memo.CaretPos.y) then
  begin
   oldx:=memo.CaretPos.x;
   oldy:=memo.CaretPos.y;
   updTtl;
  end;
end;

procedure TmainForm.memoChange(Sender: TObject);
begin
 if canChangeMdf then
  begin
   mdf:=true;
   oldx:=-1;
  end;
 canChangeMdf:=true;
end;

procedure TmainForm.lbExit(Sender: TObject);
begin
 lb.Hide;
end;

procedure TmainForm.lbKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var s:string;
begin
 case key of
  vk_Escape:
   memo.SetFocus;

  vk_Return:
   begin
    s:=lb.Items.Strings[lb.ItemIndex];
    if fileexists(s) then
     jrFileOpen(s)
    else
     showmessage('Файл '+s+' не существует.');
    memo.SetFocus;
   end;
 end;
end;

procedure TmainForm.lbDblClick(Sender: TObject);
var key:word;
begin
 key:=vk_Return;
 lbKeyDown(self,key,[]);
end;

procedure TmainForm.N25Click(Sender: TObject);
begin
 memo.selstart:=strtoint(inputbox(
  'Перейти на символ номер','Всего символов: '+
  inttostr(length(memo.Lines.Text)-2),inttostr(memo.selstart)));
end;

procedure TmainForm.N7Click(Sender: TObject);
begin
 n7.Checked:=not n7.Checked;
end;

procedure TmainForm.memoKeyPress(Sender: TObject; var Key: Char);
begin
 if n7.Checked and (key=#9) then
  key:=#0;
end;

procedure TmainForm.tabtimTimer(Sender: TObject);
begin
 tabtim.Enabled:=false;
 tabAsPrevLine(memo);
end;

procedure TmainForm.N32Click(Sender: TObject);
begin
 showmessage(helptext_);
end;

procedure TmainForm.Jotterctxt1Click(Sender: TObject);
begin
 ftbindDlg(jr_,'Creosoft','txt','textfile',natfld+jr_+'.exe',natfld+jr_+'.exe,0');
end;

procedure TmainForm.N26Click(Sender: TObject);
begin
 fh.handlewith(fn);
end;

end.
