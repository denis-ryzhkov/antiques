unit Parafind;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

const maxrememb=16;

type
  tParaFindRec=
   record
    sFind,sRepl:string;
    bOk,bRepl,bCaseSens,bSpec,bWhole,bOneCase:boolean;
    ssFind,ssRepl:tstringlist;
    winleft,wintop:word;
   end;

  TParaFindF = class(TForm)
    FindSt: TStaticText;
    ReplChB: TCheckBox;
    CaseSensChB: TCheckBox;
    SpecChB: TCheckBox;
    WholeChB: TCheckBox;
    OneCaseChB: TCheckBox;
    FindCB: TComboBox;
    ReplCB: TComboBox;
    PFPanel: TPanel;
    OkSB: TSpeedButton;
    CancelSB: TSpeedButton;
    BackChB: TCheckBox;
    ForvChB: TCheckBox;
    procedure OkSBClick(Sender: TObject);
    procedure CancelSBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ReplChBClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ParaFindF: TParaFindF;
  IORec:tParaFindRec;
implementation

{$R *.DFM}
procedure TParaFindF.OkSBClick(Sender: TObject);
begin
 iorec.bOk:=true;
 close;
end;

procedure TParaFindF.CancelSBClick(Sender: TObject);
begin
 close;
end;

procedure TParaFindF.FormClose(Sender: TObject; var Action: TCloseAction);
var a:word;
    now:boolean;
begin
 with IORec do
  begin
   ssFind.assign(findcb.items);
   ssRepl.assign(Replcb.items);
   sFind:=findcb.text;
   sRepl:=replcb.text;

   if bok then
    begin
     now:=true;
     if ssfind.Count<>0 then
      for a:=0 to ssfind.count-1 do
       if ssfind.Strings[a]=sfind then now:=false;
     if now then
      begin
       if ssfind.Count=maxrememb then ssfind.Delete(maxrememb-1);
       ssfind.Add(sFind);
       ssfind.Move(ssfind.Count-1,0);
      end;

     now:=true;
     if ssRepl.Count<>0 then
      for a:=0 to ssRepl.count-1 do
       if ssRepl.Strings[a]=sRepl then now:=false;
     if now then
      begin
       if ssRepl.Count=maxrememb then ssRepl.Delete(maxrememb-1);
       ssRepl.Add(sRepl);
       ssRepl.Move(ssRepl.Count-1,0);
      end;
    end;
   bRepl:=ReplChB.checked;
   bCaseSens:=CaseSensChB.checked;
   bSpec:=SpecChB.checked;
   bWhole:=WholeChB.checked;
   bOneCase:=OneCaseChB.checked;
   winleft:=left;
   wintop:=top;
  end;
end;

procedure TParaFindF.FormShow(Sender: TObject);
begin
 with IORec do
  begin
   findcb.items.assign(ssFind);
   Replcb.items.assign(ssRepl);
   findcb.text:=sFind;
   replcb.text:=sRepl;
   bOk:=false;
   ReplChB.checked:=bRepl;
   CaseSensChB.checked:=bCaseSens;
   SpecChB.checked:=bSpec;
   WholeChB.checked:=bWhole;
   OneCaseChB.checked:=bOneCase;
   left:=winleft;
   top:=wintop;
  end;
  ReplChBClick(Self);
  activecontrol:=findcb;
end;

procedure TParaFindF.ReplChBClick(Sender: TObject);
begin
 if replchb.Checked then activecontrol:=replcb;
 onecasechb.Enabled:=replchb.Checked;
 if not replchb.Checked then onecasechb.Checked:=true;
end;

procedure TParaFindF.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=13 then OkSBClick(Self);
 if key=27 then CancelSBClick(Self);
 key:=0;
end;

end.
