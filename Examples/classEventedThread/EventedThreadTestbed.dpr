program EventedThreadTestbed;

uses
  Vcl.Forms,
  formEventedThreadTestbedMain in 'formEventedThreadTestbedMain.pas' {frmEventedThreadTestbedMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmEventedThreadTestbedMain, frmEventedThreadTestbedMain);
  Application.Run;
end.
