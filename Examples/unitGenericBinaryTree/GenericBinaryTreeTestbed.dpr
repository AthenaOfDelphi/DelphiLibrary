program GenericBinaryTreeTestbed;

uses
  Forms,
  formBTreeTestbedMain in 'formBTreeTestbedMain.pas' {frmBTreeTestbedMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmBTreeTestbedMain, frmBTreeTestbedMain);
  Application.Run;
end.
