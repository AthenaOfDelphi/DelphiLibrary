program SingletonTest;

uses
  Vcl.Forms,
  formSingletonTestbed in 'formSingletonTestbed.pas' {frmSingletonTestbed};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSingletonTestbed, frmSingletonTestbed);
  Application.Run;
end.
