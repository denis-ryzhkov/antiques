program Gabber;

uses
  Forms,
  GMain in 'GMain.pas' {GMainF},
  GAEd in 'GAEd.pas' {GAEdF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Gabber';
  Application.CreateForm(TGMainF, GMainF);
  Application.CreateForm(TGAEdF, GAEdF);
  Application.Run;
end.
