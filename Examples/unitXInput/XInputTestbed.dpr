program XInputTestbed;

uses
  Vcl.Forms,
  formXInputTestbedMain in 'formXInputTestbedMain.pas' {frmXInputTestbedMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmXInputTestbedMain, frmXInputTestbedMain);
  Application.Run;
end.
