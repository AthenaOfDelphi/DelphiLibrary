unit formXInputTestbedMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, unitXInput, Vcl.ExtCtrls,
  Vcl.ComCtrls, Math;

type
  TfrmXInputTestbedMain = class(TForm)
    mmoLog: TMemo;
    tmrScan: TTimer;
    pnlControlContainer: TPanel;
    grpInit: TGroupBox;
    grpVibration: TGroupBox;
    cmdInit: TButton;
    cmdVibrate: TButton;
    lblController: TLabel;
    lblHigh: TLabel;
    lblLow: TLabel;
    cboControllerIndex: TComboBox;
    barHigh: TTrackBar;
    barLow: TTrackBar;
    procedure cmdInitClick(Sender: TObject);
    procedure tmrScanTimer(Sender: TObject);
    procedure cmdVibrateMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmdVibrateMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure handleStateChange(sender:TObject;userIndex:uint32;newState:TXInputState);
    procedure handleButtonDown(sender:TObject;userIndex:uint32;buttons:word);
    procedure handleButtonUp(sender:TObject;userIndex:uint32;buttons:word);
    procedure handleButtonPress(sender:TObject;userIndex:uint32;buttons:word);
    procedure handleConnect(sender:TObject;userIndex:uint32);
    procedure handleDisconnect(sender:TObject;userIndex:uint32);
  end;

var
  frmXInputTestbedMain: TfrmXInputTestbedMain;

implementation

{$R *.dfm}

procedure TfrmXInputTestbedMain.handleStateChange(sender:TObject;userIndex:uint32;newState:TXInputState);
begin
  mmoLog.lines.add(format(
    'Idx %d - Packet %d - Buttons %d, LX %d, LY %d, RX %d, RY %d, LT %d, RT %d,  LJOY %d, RJOY %d',
    [
      userIndex,
      newState.stPacketNumber,
      newState.stGamepad.gpButtons,
      newState.stGamepad.gpThumbLX,
      newState.stGamepad.gpThumbLY,
      newState.stGamepad.gpThumbRX,
      newState.stGamepad.gpThumbRY,
      newState.stGamepad.gpLeftTrigger,
      newState.stGamepad.gpRightTrigger,
      integer(xinput.leftJoystick(userIndex)),
      integer(xinput.rightJoystick(userIndex))
    ]
  ));
end;

procedure TfrmXInputTestbedMain.cmdVibrateMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xinput.vibrate(cboControllerIndex.itemIndex,barLow.Position,barHigh.position);
end;

procedure TfrmXInputTestbedMain.cmdVibrateMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xinput.vibrate(cboControllerIndex.itemIndex,0,0);
end;

procedure TfrmXInputTestbedMain.handleConnect(sender:TObject;userIndex:uint32);
begin
  mmoLog.lines.add(format('Controller %d connected',[userIndex]));
end;

procedure TfrmXInputTestbedMain.handleDisconnect(sender:TObject;userIndex:uint32);
begin
  mmoLog.lines.add(format('Controller %d disconnected',[userIndex]));
end;

procedure TfrmXInputTestbedMain.handleButtonDown(sender:TObject;userIndex:uint32;buttons:word);
begin
  mmoLog.lines.add(format('Button Down - Idx %d - Buttons %d',[userIndex,buttons]));
end;

procedure TfrmXInputTestbedMain.handleButtonUp(sender:TObject;userIndex:uint32;buttons:word);
begin
  mmoLog.lines.add(format('Button Up - Idx %d - Buttons %d',[userIndex,buttons]));
end;

procedure TfrmXInputTestbedMain.handleButtonPress(sender:TObject;userIndex:uint32;buttons:word);
begin
  mmoLog.lines.add(format('Button Press - Idx %d - Buttons %d',[userIndex,buttons]));
end;

procedure TfrmXInputTestbedMain.tmrScanTimer(Sender: TObject);
begin
  xinput.refresh;
end;

procedure TfrmXInputTestbedMain.cmdInitClick(Sender: TObject);
begin
  if (xinputAvailable) then
  begin
    mmoLog.lines.add('XInput available');

    xinput.onControllerStateChange:=handleStateChange;
    xinput.onControllerConnect:=handleConnect;
    xinput.onControllerDisconnect:=handleDisconnect;
    xinput.onControllerButtonDown:=handleButtonDown;
    xinput.onControllerButtonUp:=handleButtonUp;
    xinput.onControllerButtonPress:=handleButtonPress;

    tmrScan.enabled:=true;
  end
  else
  begin
    mmoLog.lines.add('XInput not available');
  end;
end;

end.
