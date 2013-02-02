unit GAEd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TGAEdF = class(TForm)
    Memo: TMemo;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GAEdF: TGAEdF;

implementation

{$R *.DFM}

procedure TGAEdF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_Escape then
  close;
end;

end.
