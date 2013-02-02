program Fretsaw;

uses
  Forms,
  FrMain in 'FrMain.pas' {FrMainF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Fretsaw 2';
  Application.CreateForm(TFrMainF, FrMainF);
  Application.Run;
end.
