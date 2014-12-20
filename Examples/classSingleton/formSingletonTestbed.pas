unit formSingletonTestbed;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, classSingleton, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TSingleton1 = class(TSingleton)
  protected
    fData     : integer;

    procedure createVars; override;
    procedure destroyVars; override;
  public
    property data:integer read fData write fData;
  end;

  TSingleton2 = class(TSingleton)
  protected
    fData     : string;

    procedure createVars; override;
    procedure destroyVars; override;
  public
    property data:string read fData write fData;
  end;

  TfrmSingletonTestbed = class(TForm)
    pnlControlContainer: TPanel;
    cmdTest: TButton;
    mmoLog: TMemo;
    procedure cmdTestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSingletonTestbed: TfrmSingletonTestbed;

implementation

{$R *.dfm}

{ TSingleton1 }

procedure TSingleton1.createVars;
begin
  fData:=0;
end;

procedure TSingleton1.destroyVars;
begin
  // Do nothing
end;

{ TSingleton2 }

procedure TSingleton2.createVars;
begin
  fData:='';
end;

procedure TSingleton2.destroyVars;
begin
  // Do nothing
end;

procedure TfrmSingletonTestbed.cmdTestClick(Sender: TObject);
var
  a1  : TSingleton1;
  a2  : TSingleton1;
  b1  : TSingleton2;
  b2  : TSingleton2;
begin
  singletonStoreToStrings(mmoLog.lines);

  a1:=TSingleton1.create;
  a1.data:=255;

  singletonStoreToStrings(mmoLog.lines);
  mmoLog.lines.add('A1 = $'+intToHex(nativeInt(a1),8));


  b1:=TSingleton2.create;
  b1.data:='Hello world';

  singletonStoreToStrings(mmoLog.lines);
  mmoLog.lines.add('B1 = $'+intToHex(nativeInt(b1),8));

  a2:=TSingleton1.create;
  b2:=TSingleton2.create;

  singletonStoreToStrings(mmoLog.lines);
  mmoLog.lines.add('A2 = $'+intToHex(nativeInt(a2),8));
  mmoLog.lines.add('B2 = $'+intToHex(nativeInt(b2),8));

  showMessage('A2.data = '+intToStr(a2.data)+' B2.data = '+b2.data);

  a1.free;
  singletonStoreToStrings(mmoLog.lines);

  b1.free;
  singletonStoreToStrings(mmoLog.lines);

  a2.free;
  b2.free;
  singletonStoreToStrings(mmoLog.lines);
end;

end.
