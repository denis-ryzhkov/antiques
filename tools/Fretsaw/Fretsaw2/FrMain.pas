unit FrMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ToolWin, ExtCtrls, ImgList, Menus, shellapi, Clipbrd,
  creoFile, ActnList, CheckLst;

type
  TFrMainF = class(TForm)
    statBar: TStatusBar;
    msplit: TSplitter;
    imList: TImageList;
    pan1: TPanel;
    tabC: TTabControl;
    openDlg: TOpenDialog;
    toolPan: TPanel;
    scbox: TScrollBox;
    ToolBar: TToolBar;
    NewTB: TToolButton;
    openTB: TToolButton;
    CloseTB: TToolButton;
    saveTB: TToolButton;
    wrapTB: TToolButton;
    pm: TPopupMenu;
    undo1: TMenuItem;
    cut1: TMenuItem;
    copy1: TMenuItem;
    paste1: TMenuItem;
    all1: TMenuItem;
    del1: TMenuItem;
    m1: TMenuItem;
    m2: TMenuItem;
    pmIL: TImageList;
    riched: TRichEdit;
    saveAsTB: TToolButton;
    saveDlg: TSaveDialog;
    rpan: TPanel;
    Tree: TTreeView;
    tipmemo: TMemo;
    rSplit: TSplitter;
    saveAllTB: TToolButton;
    viewTB: TToolButton;
    al: TActionList;
    openA: TAction;
    newA: TAction;
    saveA: TAction;
    saveAsA: TAction;
    saveAllA: TAction;
    closeA: TAction;
    wrapA: TAction;
    exitA: TAction;
    viewA: TAction;
    exitTB: TToolButton;
    insColTB: TToolButton;
    insColA: TAction;
    colDlg: TColorDialog;
    helpA: TAction;
    findTB: TToolButton;
    findA: TAction;
    ctrlBar: TControlBar;
    findP: TPanel;
    findCLB: TCheckListBox;
    replCB: TComboBox;
    findCB: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure tabCChange(Sender: TObject);
    procedure all1Click(Sender: TObject);
    procedure pmPopup(Sender: TObject);
    procedure undo1Click(Sender: TObject);
    procedure cut1Click(Sender: TObject);
    procedure copy1Click(Sender: TObject);
    procedure paste1Click(Sender: TObject);
    procedure del1Click(Sender: TObject);
    procedure richedSelectionChange(Sender: TObject);
    procedure richedChange(Sender: TObject);
    procedure rSplitMoved(Sender: TObject);
    procedure tabCChanging(Sender: TObject; var AllowChange: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure newAExecute(Sender: TObject);
    procedure openAExecute(Sender: TObject);
    procedure saveAExecute(Sender: TObject);
    procedure saveAsAExecute(Sender: TObject);
    procedure saveAllAExecute(Sender: TObject);
    procedure closeAExecute(Sender: TObject);
    procedure wrapAExecute(Sender: TObject);
    procedure exitAExecute(Sender: TObject);
    procedure viewAExecute(Sender: TObject);
    procedure insColAExecute(Sender: TObject);
    procedure helpAExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure findPMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure findAExecute(Sender: TObject);
    procedure ctrlBarBandDrag(Sender: TObject; Control: TControl;
      var Drag: Boolean);
    procedure ctrlBarDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


 tDoq=
  record
   fn:string;
   mdf:boolean;
   ss,sl:cardinal;
  end;

const maxdoqs=255;
      sNameless='Nameless';
      tipMemoText='F1 - показать/скрыть справку'#13#10#13#10#13#10#13#10#13#10#13#10#13#10'Fretsaw 2.0. Creosoft (c) 1999.'#13#10;



var
  FrMainF: TFrMainF;
  doqs:array[1..maxdoqs] of tDoq;
  tff:string;
  maxDoqI,curDoqI:byte;
  hlppart:real;
  fv,docanclose:boolean;
  dy:word;

implementation

{$R *.DFM}

function tfn(i:byte):string;
begin
 tfn:=tff+'Frtsw'+inttostr(i)+'.$$$';
end;

procedure preSave;
begin
 if maxDoqI>0 then
  with frmainf do
   begin
    riched.Lines.SaveToFile(tfn(tabc.tabindex+1));
    doqs[tabc.tabindex+1].ss:=riched.SelStart;
    doqs[tabc.tabindex+1].sl:=riched.SelLength;
   end;
end;

procedure enblDoqBtns(yes:boolean);
begin
 with frmainf do
  begin
   saveA.Enabled:=yes;
   saveasA.Enabled:=yes;
   saveallA.Enabled:=yes;
   closeA.Enabled:=yes;
   wrapA.Enabled:=yes;
   viewA.Enabled:=yes;
   insColA.Enabled:=yes;
   findA.Enabled:=yes;
   tabC.Visible:=yes;
   if not yes then
    begin
     statbar.Panels[1].text:='';
     statbar.Panels[2].text:='';
    end
   else
    ActiveControl:=frmainf.RichEd;
  end;
end;

procedure viewDoq;
var mdfbaq:boolean;
begin
 if maxdoqi>0 then
  with frmainf do
   begin
    tabC.TabIndex:=curDoqI-1;
    mdfbaq:=doqs[curDoqI].mdf;
    riched.Lines.LoadFromFile(tfn(curdoqI));
    riched.selstart:=doqs[curDoqI].ss;
    riched.sellength:=doqs[curDoqI].sl;
    doqs[curDoqI].mdf:=mdfbaq;
    if doqs[curDoqI].mdf then
     statBar.Panels[1].text:='Изм'
    else
     statBar.Panels[1].text:='';
   end;
 enblDoqBtns((maxdoqi>0));
end;

function bareFn(fn:string):string;
var bfn:string;
begin
 bfn:=extractfilename(fn);
 bfn:=copy(bfn,1,length(bfn)-length(extractfileext(fn)));
 bareFn:=bfn;
end;

procedure AddDoq(filename:string);
begin
 preSave;
 inc(maxDoqI);
 curDoqI:=maxDoqI;
 with doqs[curDoqI] do
  begin
   if filename='' then
    begin
     fn:=sNameless;
     frMainF.tabC.Tabs.Add(sNameless);
     frMainF.RichEd.Lines.Clear;
     ss:=25;
     sl:=8;
     frMainF.riched.Lines.add('<html>'#13#10'<head>'#13#10'<title>'#13#10+sNameless+#13#10'</title>'#13#10'</head>'#13#10'<body>'#13#10#13#10'</body>'#13#10'</html>');
    end
   else
    begin
     fn:=filename;
     ss:=0;
     sl:=0;
     frMainF.tabC.Tabs.Add(bareFn(fn));
     frmainf.riched.Lines.LoadFromFile(fn);
     mdf:=false;
    end;

   frmainf.riched.Lines.SaveToFile(tfn(curDoqI))
  end;
 viewDoq;
end;

procedure TFrMainF.FormCreate(Sender: TObject);
begin
 tff:=tempPathStr;
 maxDoqI:=0;
 enblDoqBtns(false);
 tipmemo.Lines.Text:=tipMemoText;
 rSplitMoved(self);
 hlppart:=0.5;
end;

procedure TFrMainF.tabCChange(Sender: TObject);
begin
 curDoqI:=tabc.TabIndex+1;
 viewDoq;
end;

procedure TFrMainF.all1Click(Sender: TObject);
begin
 riched.SelectAll;
end;

procedure TFrMainF.pmPopup(Sender: TObject);
var en:boolean;
begin
 en:=(riched.SelLength>0);
 copy1.Enabled:=en;
 cut1.Enabled:=en;
 del1.Enabled:=en;
 paste1.Enabled:=clipboard.HasFormat(cf_text);
 undo1.Enabled:=riched.CanUndo;
end;

procedure TFrMainF.undo1Click(Sender: TObject);
begin
 riched.Undo;
end;

procedure TFrMainF.cut1Click(Sender: TObject);
begin
 riched.CutToClipboard;
end;

procedure TFrMainF.copy1Click(Sender: TObject);
begin
 riched.CopyToClipboard;
end;

procedure TFrMainF.paste1Click(Sender: TObject);
begin
 riched.PasteFromClipboard;
end;

procedure TFrMainF.del1Click(Sender: TObject);
begin
 riched.SelText:='';
end;

procedure TFrMainF.richedSelectionChange(Sender: TObject);
begin
 statbar.Panels.Items[2].Text:=inttostr(riched.caretpos.y)+' : '+inttostr(riched.caretpos.x);
end;

procedure saveDoq(doqI:word;fn:string);
begin
 frmainf.riched.Lines.SaveToFile(fn);
 doqs[doqI].fn:=fn;
 frMainF.tabC.Tabs.Strings[doqI-1]:=bareFn(fn);
 doqs[curDoqI].mdf:=false;
 frmainf.statBar.Panels[1].text:='';
end;

procedure TFrMainF.richedChange(Sender: TObject);
begin
 if not doqs[curDoqI].mdf then
  begin
   doqs[curDoqI].mdf:=true;
   frmainf.statBar.Panels[1].text:='Изм'
  end;
end;

procedure TFrMainF.rSplitMoved(Sender: TObject);
begin
 if tipmemo.Height<5 then
  tipmemo.ScrollBars:=ssNone
 else
  tipmemo.ScrollBars:=ssVertical
end;


procedure TFrMainF.tabCChanging(Sender: TObject; var AllowChange: Boolean);
begin
 presave;
end;

procedure TFrMainF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var lastdoq,i:word;
begin
 clipboard.Clear;
 docanclose:=true;
 i:=maxDoqI+1;
 lastdoq:=curdoqi;
 while (i>1) and docanclose do
  begin
   dec(i);
   presave;
   curdoqi:=i;
   viewDoq;
   closeAExecute(self);
  end;
 if not docanclose then
  begin
   presave;
   curdoqi:=lastdoq;
   viewdoq;
  end;
 canclose:=docanclose;
end;

procedure TFrMainF.newAExecute(Sender: TObject);
begin
 AddDoq('');
end;

procedure TFrMainF.openAExecute(Sender: TObject);
begin
 if openDlg.Execute then
  addDoq(openDlg.filename);
end;

procedure TFrMainF.saveAExecute(Sender: TObject);
begin
 if doqs[curDoqI].fn=sNameless then
  if saveDlg.Execute then
   saveDoq(curDoqI,saveDlg.filename)
  else
 else
  saveDoq(curDoqI,doqs[curDoqI].fn);
end;

procedure TFrMainF.saveAsAExecute(Sender: TObject);
begin
 if saveDlg.Execute then
  saveDoq(curDoqI,saveDlg.filename)
end;

procedure TFrMainF.saveAllAExecute(Sender: TObject);
var lastdoq,i:word;
begin
 lastdoq:=curdoqi;
 for i:=1 to maxdoqi do
  begin
   presave;
   curdoqi:=i;
   viewdoq;
   saveAExecute(self);
  end;
 presave;
 curdoqi:=lastdoq;
 viewdoq;
end;

procedure TFrMainF.closeAExecute(Sender: TObject);
var rc,i:word;
begin
 if doqs[curDoqI].mdf then
  begin
   rc:=messagedlg('Изменения в файле '+doqs[curDoqI].fn+'не сохранены. Сохранить?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
   if rc=mrYes then
    saveAExecute(self)
   else
    if rc<>mrNo then
     begin
      docanclose:=false;
      exit
     end
  end;
 tabc.Tabs.Delete(curDoqi-1);
 for i:=curdoqi to (maxdoqi-1) do
  begin
   doqs[i]:=doqs[i+1];
   deletefile(tfn(i));
   renamefile(tfn(i+1),tfn(i))
  end;
 deletefile(tfn(maxdoqi));
 dec(maxdoqi);
 if (maxdoqi=0) or (curdoqi>1) then
  dec(curdoqi);
 viewdoq;
end;

procedure TFrMainF.wrapAExecute(Sender: TObject);
var b:boolean;
begin
 b:=riched.WordWrap;
 if b then
  begin
   riched.WordWrap:=false;
   riched.ScrollBars:=ssBoth
  end
 else
  begin
   riched.WordWrap:=true;
   riched.ScrollBars:=ssVertical
  end
end;

procedure TFrMainF.exitAExecute(Sender: TObject);
begin
 close;
end;

procedure TFrMainF.viewAExecute(Sender: TObject);
var fn:string;
begin
 saveAExecute(self);
 fn:=doqs[curdoqi].fn;
 if not doqs[curdoqi].mdf then
  shellexecute(handle,'open',@fn[1],'','',sw_show);
end;

procedure TFrMainF.insColAExecute(Sender: TObject);
var cs,bs:string;
begin
 if colDlg.Execute then
  begin
   cs:=inttohex(coldlg.Color,6);
   bs:=cs[1]+cs[2];
   cs[1]:=cs[5];
   cs[2]:=cs[6];
   cs[5]:=bs[1];
   cs[6]:=bs[2];
   riched.SelText:='#'+cs;
  end;
end;

procedure TFrMainF.helpAExecute(Sender: TObject);
var i:word;
begin
 if tipmemo.Height=1 then
  begin
   for i:=1 to round(rpan.Height*hlppart) do
    if (i mod 10)=0 then
     tipmemo.Height:=i;
   tipmemo.Height:=round(rpan.Height*hlppart);
   activecontrol:=tipmemo;
  end
 else
  begin
   hlppart:=tipmemo.Height/rpan.Height;
   for i:= tipmemo.Height downto 1 do
    if (i mod 10)=0 then
     tipmemo.Height:=i;
   tipmemo.Height:=1;
   if tabc.Visible then
    activecontrol:=riched
   else
    activecontrol:=toolbar;
  end;
 rSplitMoved(self);
end;

procedure TFrMainF.FormResize(Sender: TObject);
begin
 if tipmemo.Height>rpan.Height-5 then
  tipmemo.Height:=rpan.Height-5;

 if scbox.Width<toolbar.Width then
  toolpan.Height:=54
 else
  toolpan.Height:=40;
end;

procedure TFrMainF.findPMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 dy:=y;
end;

procedure TFrMainF.findAExecute(Sender: TObject);
begin
 findP.show;
end;

procedure TFrMainF.ctrlBarBandDrag(Sender: TObject; Control: TControl;
  var Drag: Boolean);
begin
 drag:=true
end;

procedure TFrMainF.ctrlBarDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
 accept:=true
end;

end.
