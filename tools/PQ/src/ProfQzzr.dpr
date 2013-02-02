program ProfQzzr;

uses
  Forms,
  PQMain in 'PQMain.pas' {PQMainF},
  PQLeg in 'PQLeg.pas' {PQLegF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Profession Quizzer';
  Application.CreateForm(TPQMainF, PQMainF);
  Application.Run;
end.
