unit FsTunTag;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

const
       sCTf='Compnent.fsw';
       sEOT='.';
       snewc='Новый компонент';
       rsFindXY='FindLeftTop';
       rsFindSs='FindSs';
       rsReplSs='ReplSs';

type
  TFsTunTagF = class(TForm)
    LBox: TListBox;
    UpSB: TSpeedButton;
    DownSB: TSpeedButton;
    AddSB: TSpeedButton;
    DelSB: TSpeedButton;
    EdSB: TSpeedButton;
    EdPan: TPanel;
    OkSB: TSpeedButton;
    CancelSB: TSpeedButton;
    NameEd: TEdit;
    TxtM: TMemo;
    OfsEd: TEdit;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    EnrichSB: TSpeedButton;
    DDCountScB: TScrollBar;
    DDCountL: TLabel;
    EnrichOD: TOpenDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DownSBClick(Sender: TObject);
    procedure UpSBClick(Sender: TObject);
    procedure DelSBClick(Sender: TObject);
    procedure AddSBClick(Sender: TObject);
    procedure updlbox;
    procedure OkSBClick(Sender: TObject);
    procedure CancelSBClick(Sender: TObject);
    procedure EdSBClick(Sender: TObject);
    procedure editit;
    procedure DDCountScBChange(Sender: TObject);
    procedure EnrichSBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  ttag=
      record
       text,ttl:string;
       ofs:word;
      end;
  ttaglist=array[1..255] of ttag;
var
  FsTunTagF: TFsTunTagF;
  ttleft,tttop:word;
  alltags,allntags,ddcount:word;
  f:textfile;
  ctag,nctag:ttaglist;
  buftag:ttag;
  added:boolean;
  natdir:string;


  procedure readtags(var ctag:ttaglist;var alltags:word;dir:string);
  procedure cleartag(tagN:word);

implementation

{$R *.DFM}


procedure readtags(var ctag:ttaglist;var alltags:word;dir:string);
var s:string;
    a:word;
    ch:char;
begin
 alltags:=0;
 assignfile(f,dir+'\'+sCTf);
 reset(f);
 while not eof(f) do
  begin
   inc(alltags);
   readln(f,s);
   ctag[alltags].ttl:=s;
   readln(f,s);
   ctag[alltags].ofs:=strtoint(s);
   ctag[alltags].text:='';
   repeat
    readln(f,s);
    if s<>sEOT then ctag[alltags].text:=ctag[alltags].text+#13#10+s;
   until s=sEOT;
   for a:=1 to length(ctag[alltags].text) do
    begin
     ch:=ctag[alltags].text[a];
     if (ch<>#10) and (ch<>#13) then break;
    end;
   ctag[alltags].text:=copy(ctag[alltags].text,a,length(ctag[alltags].text)-a+1);
  end;
 closefile(f);
end;

procedure TFsTunTagF.FormClose(Sender: TObject; var Action: TCloseAction);
var s:string;
    a:word;
begin
 ttleft:=left;
 tttop:=top;
 assignfile(f,natdir+'\'+sCTf);
 rewrite(f);
 for a:=1 to alltags do
  begin
   writeln(f,ctag[a].ttl);
   s:=inttostr(ctag[a].ofs);
   writeln(f,s);
   writeln(f,ctag[a].text);
   writeln(f,sEOT);
  end;
 closefile(f);
end;

procedure TFsTunTagF.FormShow(Sender: TObject);
begin
 left:=ttleft;
 top:=tttop;
 updlbox;
 ddcountscb.position:=ddcount;
 added:=false;
end;

procedure TFsTunTagF.DownSBClick(Sender: TObject);
var i:word;
begin
 i:=lbox.ItemIndex;
 if i>lbox.Items.Count-2 then exit;
 lbox.Items.Move(i,i+1);
 lbox.ItemIndex:=i+1;
 buftag:=ctag[i+1];
 ctag[i+1]:=ctag[i+2];
 ctag[i+2]:=buftag;
end;

procedure TFsTunTagF.UpSBClick(Sender: TObject);
var i:word;
begin
 i:=lbox.ItemIndex;
 if i<1 then exit;
 lbox.Items.Move(i,i-1);
 lbox.ItemIndex:=i-1;
 buftag:=ctag[i+1];
 ctag[i+1]:=ctag[i];
 ctag[i]:=buftag;
end;

procedure TFsTunTagF.DelSBClick(Sender: TObject);
var i,a:word;
begin
 if alltags=0 then exit;
 i:=lbox.itemindex;
 if messagedlg('Вы уверены, что хотите удалить компонент "'+lbox.Items.Strings[i]+'" ?',mtConfirmation,[mbYes,mbNo],0)<>mrYes then exit;
 lbox.Items.Delete(i);
 for a:=i+1 to alltags-1 do
  ctag[a]:=ctag[a+1];
 dec(alltags);
 cleartag(alltags+1);
end;

procedure TFsTunTagF.updlbox;
var a:word;
begin
 lbox.Items.Clear;
 for a:=1 to alltags do
  lbox.Items.Add(ctag[a].ttl);
end;

procedure TFsTunTagF.AddSBClick(Sender: TObject);
begin
 edpan.Visible:=true;
 added:=true;
 inc(alltags);
 lbox.Items.Add(snewc);
 ctag[alltags].ttl:=snewc;
 lbox.ItemIndex:=alltags-1;
 editit;
end;

procedure TFsTunTagF.OkSBClick(Sender: TObject);
var i:word;
begin
 edpan.Visible:=false;
 i:=lbox.ItemIndex+1;
 ctag[i].ttl:=nameed.Text;
 ctag[i].ofs:=strtoint(ofsEd.Text);
 ctag[i].text:=txtm.Lines.Text;
 lbox.Items.Strings[i-1]:=ctag[i].ttl;
end;

procedure TFsTunTagF.CancelSBClick(Sender: TObject);
begin
 edpan.Visible:=false;
 if not added then exit;
 added:=false;
 cleartag(alltags);
 lbox.Items.Delete(alltags-1);
 dec(alltags);
 lbox.ItemIndex:=0;
end;

procedure TFsTunTagF.EdSBClick(Sender: TObject);
begin
 edpan.Visible:=true;
 editit;
end;

procedure TFsTunTagF.editit;
var i:word;
begin
 i:=lbox.ItemIndex+1;
 nameed.Text:=ctag[i].ttl;
 ofsEd.Text:=inttostr(ctag[i].ofs);
 txtm.Lines.Text:=ctag[i].text;
end;

procedure cleartag(tagN:word);
begin
 with ctag[tagN] do
  begin
   text:='';
   ttl:='';
   ofs:=0;
  end;
end;


procedure TFsTunTagF.DDCountScBChange(Sender: TObject);
begin
 ddcountl.Caption:='Высота списка : '+inttostr(ddcountscb.position);
 ddcount:=ddcountscb.position;
end;

procedure TFsTunTagF.EnrichSBClick(Sender: TObject);
var a,b:word;
    badd:boolean;
    cn:tcloseaction;
    dir:string;
begin
 if not enrichod.Execute then exit;
 dir:=extractfilepath(enrichod.filename);
 readtags(nctag,allntags,copy(dir,0,length(dir)-1));
 if allntags=0 then exit;
 for a:=1 to allntags do
  begin
   badd:=true;
   if alltags<>0 then for b:=1 to alltags do
    if (nctag[a].ttl=ctag[b].ttl) and
        (nctag[a].ofs=ctag[b].ofs) and
        (nctag[a].text=ctag[b].text) then badd:=false;
   if badd then
    begin
     inc(alltags);
     ctag[alltags]:=nctag[a];
    end;
  end;
 cn:=caNone;
 FormClose(Self,cn);
 readtags(ctag,alltags,natdir);
 updlbox;
end;

procedure TFsTunTagF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=27 then
  if edpan.Visible then cancelsb.click else close;
end;

end.
