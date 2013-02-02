program VLab1;

uses
  Forms,
  Vlab1Mn in 'Vlab1Mn.pas' {VLab1MnF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'VLab1';
  Application.CreateForm(TVLab1MnF, VLab1MnF);
  Application.Run;
end.
