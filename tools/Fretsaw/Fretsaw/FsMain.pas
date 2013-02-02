unit FsMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ToolWin, ImgList, Registry, PrgMnDlg, ShellApi, FsHlp,
  Menus, ExtCtrls, Buttons, fstuntag, Parafind, Dialogs, ExtDlgs;

const sFS='Fretsaw';
      rsPresets='Presets';
      rsXY='LeftTop';
      rsWH='WidthHeight';
      rsHlpXY='HlpLeftTop';
      rsTunTagXY='TunTagLeftTop';
      rsOpFiles='OpFiles';
      rsDDCount='DDCount';
      rsCurDoq='CurDoq';
      sPar='Paradeigma';
      sSW='Software\';
      rsPar=sSW+sPar;
      rsFS=rsPar+'\'+sFS;
      rsMWC='Microsoft\Windows\CurrentVersion\';
      sUn='Uninst';
      sFSExe=sFS+'.exe';
      sUnExe=sFsExe+' -u';
      rsUninst=sSW+rsMWC+sUn+'all\'+sFS;
      rsVersion='Version';
      rsVerN='1.0';
      rsDisplName='DisplayName';
      rsUninstStr=sUn+'allString';
      suic='Suicide.bat';
      sBreak='|';
      sNameless='Nameless';
type
  TFsMainF = class(TForm)
    CIL: TImageList;
    SCMenu: TMainMenu;
    NewI: TMenuItem;
    OpenI: TMenuItem;
    SaveI: TMenuItem;
    SaveAsI: TMenuItem;
    CloseI: TMenuItem;
    ViewI: TMenuItem;
    FindI: TMenuItem;
    HlpI: TMenuItem;
    ExitI: TMenuItem;
    Shape1: TShape;
    TC: TTabControl;
    Memo: TMemo;
    od: TOpenDialog;
    sd: TSaveDialog;
    stb: TStatusBar;
    sbox: TScrollBox;
    CTB: TToolBar;
    NewTB: TToolButton;
    OpenTB: TToolButton;
    SaveTB: TToolButton;
    SaveAsTB: TToolButton;
    CloseTB: TToolButton;
    ViewTB: TToolButton;
    FindTB: TToolButton;
    HlpTB: TToolButton;
    ExitTB: TToolButton;
    tagcb: TComboBox;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    N61: TMenuItem;
    N71: TMenuItem;
    N81: TMenuItem;
    N91: TMenuItem;
    N01: TMenuItem;
    WrapTB: TToolButton;
    WrapI: TMenuItem;
    InsFNameTb: TToolButton;
    InsFNmeI: TMenuItem;
    InsFNameDlg: TOpenDialog;
    SelAllI: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure OpenTBClick(Sender: TObject);
    procedure SaveTBClick(Sender: TObject);
    procedure SaveAsTBClick(Sender: TObject);
    procedure CloseTBClick(Sender: TObject);
    procedure ViewTBClick(Sender: TObject);
    procedure FindTBClick(Sender: TObject);
    procedure HlpTBClick(Sender: TObject);
    procedure ExitTBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NewTBClick(Sender: TObject);
    procedure TakeIt;
    procedure CheckIt;
    procedure TCChange(Sender: TObject);
    procedure presave;
    procedure saveit;
    procedure openit;
    procedure updttl;
    procedure updfn;
    procedure updtagcb;
    procedure updwrap;
    procedure enbl(yes:boolean);
    procedure mdf(yes:boolean);
    procedure MemoChange(Sender: TObject);
    procedure sboxResize(Sender: TObject);
    procedure tagcbChange(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N01Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure WrapTBClick(Sender: TObject);
    procedure InsFNameTbClick(Sender: TObject);
    procedure SelAllIClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  tdoq=
       record
        fn,ttl,text:string;
        ss,sl:dword;
        mf:boolean;
       end;
var
  FsMainF: TFsMainF;
  f,tf:textfile;
  start,halting,bwrap:boolean;
  r:tregistry;
  natDir,sOpF,selbuf:string;
  cd,curdoq,alldoqs,lt,wh,hlt,tlt,plt:dword;
  doq:array[1..255] of tdoq;
  bufs:array[0..9] of string;
implementation

{$R *.DFM}

procedure TFsMainF.FormShow(Sender: TObject);
begin
 if not start then exit;
 start:=false;
 left:=loword(lt);
 top:=hiword(lt);
 width:=loword(wh);
 height:=hiword(wh);
end;

procedure TFsMainF.OpenTBClick(Sender: TObject);
begin
 if not od.Execute then exit;
 if alldoqs<>0 then presave;
 inc(alldoqs);
 curdoq:=alldoqs;
 doq[curdoq].fn:=od.FileName;
 doq[curdoq].ss:=0;
 doq[curdoq].sl:=0;
 openit;
end;

procedure TFsMainF.SaveTBClick(Sender: TObject);
begin
 if doq[curdoq].fn='' then SaveAsTBClick(self) else
 saveit;
end;

procedure TFsMainF.SaveAsTBClick(Sender: TObject);
begin
 if doq[curdoq].fn='' then
 sd.FileName:=doq[curdoq].ttl
  else sd.FileName:=doq[curdoq].fn;
 if not sd.Execute then exit;
 doq[curdoq].fn:=sd.FileName;
 saveit;
end;

procedure TFsMainF.CloseTBClick(Sender: TObject);
var a:word;
begin
 if doq[curdoq].mf then
  if messagedlg('Сохранить документ?',mtConfirmation,[mbYes,mbNo],0)=mrYes then SaveTBClick(self);
 for a:=curdoq to alldoqs-1 do doq[a]:=doq[a+1];
 dec(alldoqs);
 with doq[alldoqs+1] do
  begin
   fn:='';
   ttl:='';
   ss:=0;
   sl:=0;
   text:='';
   mf:=false;
  end;
 checkit;
 tc.Tabs.Delete(curdoq-1);
 if curdoq<>1 then dec(curdoq);
 takeit;
end;

procedure TFsMainF.ViewTBClick(Sender: TObject);
begin
 if (doq[curdoq].mf) or (doq[curdoq].fn='') then SaveTBClick(self);
 if doq[curdoq].fn<>'' then
  shellexecute(handle,'open',@doq[curdoq].fn[1],#0,#0,sw_show);
end;

procedure TFsMainF.FindTBClick(Sender: TObject);
var a,b,i,sfl:dword;
    txt,sf,sf1:string;
begin
 parafindf.ShowModal;
 if not iorec.bOk then exit;
 sf:=iorec.sFind;
 if sf='' then exit;
 txt:=memo.lines.text;
 sfl:=length(sf);
 if memo.sellength=0 then
  begin
   a:=1;
   b:=length(txt);
  end else
  begin
   a:=memo.selstart;
   b:=memo.selstart+memo.sellength;
  end;
 if not iorec.bCaseSens then sf:=ansilowercase(sf);

 for i:=a to b do
  begin
   sf1:=copy(txt,i,sfl);
   if (sf1=sf) or (not iorec.bCaseSens and (sf=ansilowercase(sf1))) then
    begin
     memo.SelStart:=i-1;
     memo.SelLength:=sfl;
     if iorec.bRepl then
      begin
       memo.SelText:=iorec.sRepl;
       txt:=memo.lines.text;
      end;


     if iorec.bOneCase then break;
    end;

  end;


 {remain bSpec,bWhole}




end;

procedure TFsMainF.HlpTBClick(Sender: TObject);
begin
 Fshlpf.Show;
end;

procedure TFsMainF.ExitTBClick(Sender: TObject);
begin
 fsmainf.Close;
end;

procedure TFsMainF.FormCreate(Sender: TObject);
var fs,rs,ps:string;
    b:byte;
var a,l:word;
begin
 halting:=false;
 if (paramcount=1) and (paramstr(1)='-u') then
  begin
   if messageDlg('Вы действительно хотите стерть Fretsaw 1.0 ?!',mtConfirmation,[mbYes,mbNo],0)=mrYes then
    begin
     {registry cleanup}
     r:=tregistry.Create;
     r.LazyWrite:=false;
     r.RootKey:=hkey_local_machine;
     if r.KeyExists(rsPar) then
      begin
       if r.KeyExists(rsFS) then
        begin
         r.OpenKey(rsFS,false);
         if r.ValueExists(rsVersion) then r.DeleteValue(rsVersion);
         if r.ValueExists(rsXy) then r.DeleteValue(rsXy);
         if r.ValueExists(rsWH) then r.DeleteValue(rsWH);
         if r.ValueExists(rsHlpXy) then r.DeleteValue(rsHlpXy);
         if r.ValueExists(rsTunTagXy) then r.DeleteValue(rsTunTagXy);
         if r.ValueExists(rsFindXy) then r.DeleteValue(rsFindXy);
         if r.ValueExists(rsOpFiles) then r.DeleteValue(rsOpFiles);
         if r.ValueExists(rsFindSs) then r.DeleteValue(rsFindSs);
         if r.ValueExists(rsReplSs) then r.DeleteValue(rsReplSs);
         if r.ValueExists(rsPresets) then r.DeleteValue(rsPresets);
         if r.ValueExists(rsDDCount) then r.DeleteValue(rsDDCount);
         if r.ValueExists(rsCurDoq) then r.DeleteValue(rsCurDoq);
         r.CloseKey;
         r.DeleteKey(rsFS);
        end;
       r.OpenKey(rsPar,false);
       if not r.HasSubKeys then
        begin
         r.CloseKey;
         r.DeleteKey(rsPar)
        end else r.CloseKey;
      end;
      if r.KeyExists(rsUninst) then
       begin
        r.OpenKey(rsUninst,false);
        if r.ValueExists(rsDisplName) then r.DeleteValue(rsDisplName);
        if r.ValueExists(rsUninstStr) then r.DeleteValue(rsUninstStr);
        r.CloseKey;
        r.DeleteKey(rsUninst);
       end;
     r.Free;

     {progGroup cleanup}
     if progGroupExist(sPar+' '+sFS) then
      RemoveProgGroup(sPar+' '+sFS,[sFS]);

     {file cleanup}
     assignfile(tf,suic);
     rewrite(tf);
     writeln(tf,'@echo off');
     writeln(tf,'echo FS Uninstall is finalizing via Suicide batch file. Please wait.');
     writeln(tf,':loop');
     writeln(tf,'del fretsaw.exe');
     writeln(tf,'if exist fretsaw.exe goto loop');
     writeln(tf,'deltree /y ..\Fretsaw');
     closefile(tf);
     shellexecute(handle,'open','command','/c '+suic,'',sw_showminimized);
    end;
   application.ShowMainForm:=false;
   halting:=true;
   application.Terminate;
   exit;
  end;
 r:=tregistry.Create;
 r.RootKey:=HKey_Local_Machine;
 r.OpenKey(rsFS,true);
 if r.ValueExists(rsXY) then lt:=r.ReadInteger(rsXY) else lt:=makelong(70,2);
 if r.ValueExists(rsWH) then wh:=r.ReadInteger(rsWH) else wh:=makelong(670,570);
 if r.ValueExists(rsHlpXY) then hlt:=r.ReadInteger(rsHlpXY) else hlt:=makelong(280,140);
 if r.ValueExists(rsTunTagXY) then tlt:=r.ReadInteger(rsTunTagXY) else tlt:=makelong(290,240);
 if r.ValueExists(rsFindXY) then plt:=r.ReadInteger(rsFindXY) else plt:=makelong(270,150);
 if r.ValueExists(rsOpFiles) then sOpF:=r.ReadString(rsOpFiles) else sOpF:='';
 if r.ValueExists(rsFindss) then fs:=r.ReadString(rsfindss) else fs:='';
 if r.ValueExists(rsReplss) then rs:=r.ReadString(rsreplss) else rs:='';
 if r.ValueExists(rsPresets) then ps:=r.ReadString(rsPresets) else ps:=#0;
 if r.ValueExists(rsDDCount) then tagcb.DropDownCount:=r.ReadInteger(rsDDCount) else tagcb.DropDownCount:=9;
 if r.ValueExists(rsCurDoq) then cd:=r.ReadInteger(rsCurDoq) else cd:=1;
 r.CloseKey;
 r.Free;

 getdir(0,natDir);
 fstuntag.natdir:=natdir;
 readtags(ctag,alltags,natdir);
 updtagcb;

 hlpleft:=loword(hlt);
 hlptop:=hiword(hlt);

 ttleft:=loword(tlt);
 tttop:=hiword(tlt);

 iorec.winleft:=loword(plt);
 iorec.wintop:=hiword(plt);

 fshlpf:=tfshlpf.Create(application);
 fstuntagf:=tfstuntagf.Create(application);
 parafindf:=tparafindf.Create(application);

 iorec.ssFind:=tstringlist.Create;
 iorec.ssRepl:=tstringlist.Create;
 iorec.ssFind.Text:=fs;
 iorec.ssRepl.Text:=rs;

 bwrap:=false;
 iorec.bOk:=false;
 iorec.bRepl:=false;
 iorec.bCaseSens:=false;
 iorec.bSpec:=false;
 iorec.bWhole:=false;
 iorec.bOneCase:=false;

 if ps='' then b:=0 else b:=byte(ps[1]);
 if b>63 then begin bWrap:=true;dec(b,64) end;
 if b>31 then begin iorec.bOneCase:=true;dec(b,32) end;
 if b>15 then begin iorec.bOk:=true;dec(b,16) end;
 if b>7  then begin iorec.bRepl:=true;dec(b,8)  end;
 if b>3  then begin iorec.bCaseSens:=true;dec(b,4)  end;
 if b>1  then begin iorec.bSpec:=true;dec(b,2)  end;
 if b=1  then       iorec.bWhole:=true;


 alldoqs:=0;
 updwrap;
 tagcb.ItemIndex:=0;
 start:=true;

 a:=0;
 if sopf<>'' then
  begin
   l:=length(sopf);
   while a<l do
    begin
     inc(a);
     inc(alldoqs);

     b:=0;
     while (a+b<l) and (sopf[a+b]<>sBreak) do inc(b);
     doq[alldoqs].fn:=copy(sopf,a,b);
     a:=a+b+1;

     b:=0;
     while (a+b<l) and (sopf[a+b]<>sBreak) do inc(b);
     doq[alldoqs].ss:=strtoint(copy(sopf,a,b));
     a:=a+b+1;

     b:=0;
     while (a+b<l) and (sopf[a+b]<>sBreak) do inc(b);
     doq[alldoqs].sl:=strtoint(copy(sopf,a,b));
     a:=a+b;

     if not fileexists(doq[alldoqs].fn) then
      begin
       cleartag(alldoqs);
       dec(alldoqs);
      end;
    end;
  end;

 if alldoqs>0 then
  for a:=1 to alldoqs do
   begin
    curdoq:=a;
    openit;
   end;
 if alldoqs>0 then
  begin
   curdoq:=cd;
   takeit;
  end else
  begin
   curdoq:=1;
   checkit;
  end;
 ddcount:=tagcb.DropDownCount;
end;

procedure TFsMainF.FormDestroy(Sender: TObject);
var b:byte;
begin
 b:=0;
 if iorec.bWhole then inc(b,1);
 if iorec.bSpec then inc(b,2);
 if iorec.bCaseSens then inc(b,4);
 if iorec.bRepl then inc(b,8);
 if iorec.bOk then inc(b,16);
 if iorec.bOneCase then inc(b,32);
 if bWrap then inc(b,64);

 if halting then exit;
 r:=tregistry.Create;
 r.RootKey:=HKey_Local_Machine;
 r.OpenKey(rsFS,true);
 r.WriteInteger(rsXY,makelong(left,top));
 r.WriteInteger(rsWH,makelong(width,height));
 r.WriteInteger(rsHlpXY,makelong(Hlpleft,Hlptop));
 r.WriteInteger(rsTunTagXY,makelong(TTleft,TTtop));
 r.WriteInteger(rsFindXY,makelong(iorec.winleft,iorec.wintop));
 r.WriteString(rsOpFiles,sOpF);
 r.WriteString(rsFindss,iorec.ssFind.Text);
 r.WriteString(rsReplss,iorec.ssRepl.Text);
 r.WriteString(rsPresets,char(b));
 r.WriteString(rsVersion,rsVern);
 r.WriteInteger(rsDDCount,tagcb.DropDownCount);
 r.WriteInteger(rsCurDoq,cd);
 r.CloseKey;
 r.OpenKey(rsUninst,true);
 r.WriteString(rsDisplName,sPar+' '+sFS);
 r.WriteString(rsUninstStr,natdir+'\'+sUnExe);
 r.CloseKey;
 r.Free;

 iorec.ssFind.Free;
 iorec.ssRepl.Free;

 if not progGroupExist(sPar+' '+sFS) then
  RegisterProgGroup(sPar+' '+sFS,[sFS],[natdir+'\'+sFSExe]);
end;

procedure TFsMainF.NewTBClick(Sender: TObject);
begin
 if alldoqs<>0 then presave;
 inc(alldoqs);
 curdoq:=alldoqs;
 doq[curdoq].fn:='';
 doq[curdoq].ttl:=sNameless;
 doq[curdoq].ss:=23;
 doq[curdoq].sl:=8;
 doq[curdoq].text:=
 '<html>'#13#10+
 '<head>'#13#10+
 '<title>'+sNameless+'</title>'#13#10+
 '</head>'#13#10+
 '<body>'#13#10+
 ''#13#10+
 '</body>'#13#10+
 '</html>';
 tc.Tabs.Add(doq[curdoq].ttl);
 checkit;
 takeit;
 updfn;
 mdf(false);
end;

procedure TFsMainF.TakeIt;
var m:boolean;
begin
 tc.TabIndex:=curdoq-1;
 if alldoqs=0 then exit;
 m:=doq[curdoq].mf;
 memo.lines.Text:=doq[curdoq].text;
 memo.SelStart:=doq[curdoq].ss;
 memo.SelLength:=doq[curdoq].sl;
 doq[curdoq].mf:=m;
 mdf(m);
end;

procedure TFsMainF.CheckIt;
begin
 if alldoqs=0 then
  begin
   tc.Visible:=false;
   enbl(false);
   stb.Panels[0].text:='';
   stb.Panels[1].text:='';
  end else
  begin
   enbl(true);
   tc.Visible:=true;
   memo.Align:=alClient;
   activecontrol:=memo;
  end;
end;

procedure TFsMainF.Presave;
begin
 doq[curdoq].text:=memo.Lines.Text;
 doq[curdoq].ss:=memo.SelStart;
 doq[curdoq].sl:=memo.SelLength;
end;

procedure TFsMainF.Saveit;
begin
 memo.Lines.SaveToFile(doq[curdoq].fn);
 updfn;
 mdf(false);
end;

procedure TFsMainF.updfn;
begin
 stb.panels[1].text:=doq[curdoq].fn;
end;

procedure TFsMainF.updtagcb;
var a:word;
begin
 tagcb.Items.Clear;
 tagcb.Items.Add('<Компонент>');
 tagcb.Items.Add('<Настройка>');
 for a:=1 to alltags do
  tagcb.Items.Add(ctag[a].ttl);
end;

procedure TFsMainF.TCChange(Sender: TObject);
var m:boolean;
begin
 presave;
 curdoq:=tc.TabIndex+1;
 m:=doq[curdoq].mf;
 takeit;
 updfn;
 doq[curdoq].mf:=m;
 mdf(m);
end;

procedure TFsMainF.updttl;
var a,aa,b,c:word;
    s,rs,rs1:string;
begin
 s:=memo.lines.text;
 for a:=0 to length(s) do
  if ansilowercase(copy(s,a,7))='<title>' then
   begin
    for b:=a+7 to length(s) do
     if (ansilowercase(copy(s,b,8))='</title>')then
      begin
       if a=0 then aa:=1 else aa:=a;
       rs:=copy(s,aa+7,b-aa-7);
       rs1:='';
       for c:=1 to length(rs) do
        begin
         if (rs[c]<>#13) and (rs[c]<>#10) then rs1:=rs1+rs[c];
        end;
       break;
      end;
    break;
   end;
 rs:=extractfilename(doq[curdoq].fn);
 if rs1='' then
  if rs<>'' then
   rs1:=rs
  else rs1:=sNameless;
 if tc.Tabs.Strings[curdoq-1]<>rs1 then tc.Tabs.Strings[curdoq-1]:=rs1;
 doq[curdoq].ttl:=rs1;
end;

procedure TFsMainF.MemoChange(Sender: TObject);
begin
 mdf(true);
 updttl;
end;

procedure TFsMainF.mdf(yes:boolean);
begin
 doq[curdoq].mf:=yes;
 if yes then stb.Panels[0].text:='Изм' else
             stb.Panels[0].text:='';
end;

procedure TFsMainF.enbl(yes:boolean);
begin
 savetb.Enabled:=yes;
 saveastb.Enabled:=yes;
 closetb.Enabled:=yes;
 viewtb.Enabled:=yes;
 findtb.Enabled:=yes;
 wraptb.Enabled:=yes;
 tagcb.Enabled:=yes;
end;

procedure TFsMainF.sboxResize(Sender: TObject);
begin
 sbox.HorzScrollBar.Visible:=(sbox.Width<662);
 if sbox.Width<662 then sbox.Height:=52 else sbox.Height:=40;
end;

procedure TFsMainF.tagcbChange(Sender: TObject);
begin
 if tagcb.itemindex=0 then exit;
 if tagcb.itemindex<>1 then
  begin
   if memo.SelLength<>0 then selbuf:=memo.seltext else selbuf:='';
   memo.SelText:=ctag[tagcb.itemindex-1].text;
   memo.SelStart:=memo.SelStart-ctag[tagcb.itemindex-1].ofs;
   if selbuf<>'' then memo.SelText:=selbuf;
  end else
  begin
   fstuntagf.ShowModal;
   readtags(ctag,alltags,natdir);
   updtagcb;
   tagcb.DropDownCount:=ddcount;
  end;
 activecontrol:=memo;
 tagcb.ItemIndex:=0;
end;

procedure TFsMainF.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (word('0')<=key) and (key<=word('9')) and (ssCtrl in Shift) then bufs[strtoint(char(key))]:=memo.SelText;
end;

procedure TFsMainF.N01Click(Sender: TObject);
begin
 memo.SelText:=bufs[(sender as tmenuitem).tag];
end;

procedure TFsMainF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var a:word;
begin
 if doq[curdoq].fn<>'' then cd:=curdoq else cd:=1;
 if alldoqs=0 then cd:=1;
 sopf:='';
 if alldoqs<>0 then
  begin
   presave;
   for a:=1 to alldoqs do
    if doq[a].fn<>'' then sopf:=sopf+doq[a].fn+sbreak+inttostr(doq[a].ss)+sbreak+inttostr(doq[a].sl)+sbreak;
   for a:=alldoqs downto 1 do
    begin
     presave;
     curdoq:=a;
     takeit;
     CloseTBClick(Self);
    end;
  end else
  canclose:=true;
end;

procedure TFsMainF.updwrap;
begin
 if bwrap then
  memo.ScrollBars:=ssVertical else
  memo.ScrollBars:=ssBoth;
 memo.WordWrap:=bwrap;
end;

procedure TFsMainF.openit;
var ts,s1:string;
begin
 doq[curdoq].ttl:='';
 ts:='';
 assignfile(f,doq[curdoq].fn);
 reset(f);
 while not eof(f) do
  begin
   if ts<>'' then ts:=ts+#13#10;
   readln(f,s1);
   ts:=ts+s1;
  end;
 closefile(f);
 doq[curdoq].text:=ts;
 tc.Tabs.Add(doq[curdoq].ttl);
 checkit;
 takeit;
 updttl;
 updfn;
 mdf(false);
end;

procedure TFsMainF.FormResize(Sender: TObject);
begin
 if width>670 then tagcb.Width:=width-450 else
                   tagcb.Width:=220;
end;

procedure TFsMainF.WrapTBClick(Sender: TObject);
begin
 bwrap:=not bwrap;
 updwrap;
 activecontrol:=memo;
end;

procedure TFsMainF.InsFNameTbClick(Sender: TObject);
begin
 if not InsFNameDlg.Execute then exit;
 memo.SelText:=InsFNameDlg.FileName;
end;

procedure TFsMainF.SelAllIClick(Sender: TObject);
begin
 memo.SelectAll;
end;

end.
