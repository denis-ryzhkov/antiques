program Jotter;

uses
  Forms,
  main in 'main.pas' {mainForm},
  formpos in 'formpos.pas',
  memoUtil in 'memoUtil.pas',
  qwerty in 'qwerty.pas',
  reopens in 'reopens.pas',
  subbufs in 'subbufs.pas',
  find in 'find.pas' {FindForm},
  ftbinds in 'ftbinds.pas',
  multundo in 'multundo.pas',
  fhandlers in 'fhandlers.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Jotter';
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TFindForm, FindForm);
  Application.Run;
end.
