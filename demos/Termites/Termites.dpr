program Termites;

uses
  Forms,
  TermiteM in 'TermiteM.pas' {TermiteMF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Termites';
  Application.CreateForm(TTermiteMF, TermiteMF);
  Application.Run;
end.
