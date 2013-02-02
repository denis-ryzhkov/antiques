program Qr;

uses
  Forms,
  QrMain in 'QrMain.pas' {MainF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Qr';
  Application.CreateForm(TMainF, MainF);
  Application.Run;
end.
