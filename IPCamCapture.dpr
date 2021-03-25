program IPCamCapture;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {MainForm},
  uFunction in 'uFunction.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
