program Fretsaw;

uses
  Forms,
  FsMain in 'FsMain.pas' {FsMainF},
  FsHlp in 'FsHlp.pas' {FsHlpF},
  FsTunTag in 'Fstuntag.pas' {FsTunTagF},
  Parafind in 'Parafind.pas' {ParaFindF};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Fretsaw';
  Application.CreateForm(TFsMainF, FsMainF);
  Application.Run;
end.
