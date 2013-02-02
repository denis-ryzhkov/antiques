unit PQLeg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TPQLegF = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Panel2: TPanel;
    Image2: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Bevel1: TBevel;
    Button1: TButton;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PQLegF: TPQLegF;

implementation

{$R *.DFM}

procedure TPQLegF.Button1Click(Sender: TObject);
begin
 pqlegf.Close;
end;

end.
