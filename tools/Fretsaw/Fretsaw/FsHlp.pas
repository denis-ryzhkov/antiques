unit FsHlp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Menus;

type
  TFsHlpF = class(TForm)
    pgc: TPageControl;
    tipTs: TTabSheet;
    LegTs: TTabSheet;
    tipmemo: TMemo;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Memo1: TMemo;
    Memo2: TMemo;
    nulpm: TPopupMenu;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FsHlpF: TFsHlpF;
  hlpleft,hlptop:word;

implementation

{$R *.DFM}

procedure TFsHlpF.FormShow(Sender: TObject);
begin
 left:=hlpleft;
 top:=hlptop;
end;

procedure TFsHlpF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 hlpleft:=left;
 hlptop:=top;
end;

procedure TFsHlpF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=27 then close;
end;

procedure TFsHlpF.Memo1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 activecontrol:=pgc;
end;

end.
