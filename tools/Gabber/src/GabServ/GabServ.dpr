program GabServ;

uses
  Forms,
  GSMain in 'GSMain.pas' {GSMainF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'GabServ';
  Application.CreateForm(TGSMainF, GSMainF);
  Application.Run;
end.
