program DabMaker;

uses
  Forms,
  DMMain in 'DMMain.pas' {DMMainF};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDMMainF, DMMainF);
  Application.Run;
end.
