unit unitXInput;

(*

  Delphi XInput Handler
  Copyright (C) 2014 Christina Louise Warne (aka AthenaOfDelphi)

  http://athena.outer-reaches.com

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

  This unit is part of my Delphi Library (GameDevelopment section) available at:-
    https://github.com/AthenaOfDelphi/DelphiLibrary

*)

interface

Uses
  {$IFDEF MSWINDOWS}
  WinAPI.Windows,
  {$ENDIF}
  System.Types,
  SysUtils;

const
  ERROR_DEVICE_NOT_CONNECTED = 1167;

//------------------------------------------------------------------------------
// XINPUT_KEYSTROKE Structure

type
  TXInputKeystroke = record
    ksVirtualKey        : word;       // Virtual keycode of the button, stick, key - See VK_xxx codes
    ksUnicode           : Widechar;   // Unused - Value will be 0
    ksFlags             : word;       // Flags - See XInputKeystrokexxx
    ksUserIndex         : byte;       // Index of signed-in gamer associated with the device - 0-3
    ksHidCode           : byte;       // HID code corresponding to the input - No corresponding HID code, field will be 0
  end;
  PXInputKeystroke = ^TXInputKeystroke;

const
  XInputKeystrokeKeyDown          = $0001;
  XInputKeystrokeKeyUp            = $0002;
  XInputKeystrokeRepeat           = $0004;

  // Additional codes for virtual keys
  VK_PAD_A                        = $5800;
  VK_PAD_B                        = $5801;
  VK_PAD_X                        = $5802;
  VK_PAD_Y                        = $5803;
  VK_PAD_RSHOULDER                = $5804;
  VK_PAD_LSHOULDER                = $5805;
  VK_PAD_LTRIGGER                 = $5806;
  VK_PAD_RTRIGGER                 = $5807;
  VK_PAD_DPAD_UP                  = $5810;
  VK_PAD_DPAD_DOWN                = $5811;
  VK_PAD_DPAD_LEFT                = $5812;
  VK_PAD_DPAD_RIGHT               = $5813;
  VK_PAD_START                    = $5814;
  VK_PAD_BACK                     = $5815;
  VK_PAD_LTHUMB_PRESS             = $5816;
  VK_PAD_RTHUMB_PRESS             = $5817;
  VK_PAD_LTHUMB_UP                = $5820;
  VK_PAD_LTHUMB_DOWN              = $5821;
  VK_PAD_LTHUMB_RIGHT             = $5822;
  VK_PAD_LTHUMB_LEFT              = $5823;
  VK_PAD_LTHUMB_UPLEFT            = $5824;
  VK_PAD_LTHUMB_UPRIGHT           = $5825;
  VK_PAD_LTHUMB_DOWNRIGHT         = $5826;
  VK_PAD_LTHUMB_DOWNLEFT          = $5827;
  VK_PAD_RTHUMB_UP                = $5830;
  VK_PAD_RTHUMB_DOWN              = $5831;
  VK_PAD_RTHUMB_RIGHT             = $5832;
  VK_PAD_RTHUMB_LEFT              = $5833;
  VK_PAD_RTHUMB_UPLEFT            = $5834;
  VK_PAD_RTHUMB_UPRIGHT           = $5835;
  VK_PAD_RTHUMB_DOWNRIGHT         = $5836;
  VK_PAD_RTHUMB_DOWNLEFT          = $5837;

//------------------------------------------------------------------------------
// XINPUT_GAMEPAD

type
  TXInputGamepad = record
    gpButtons           : word;   // See XInputGamepadxxx
    gpLeftTrigger       : byte;   // Left trigger analog (0-255)
    gpRightTrigger      : byte;   // Right trigger analog (0-255)
    gpThumbLX           : int16;  // Left thumb stick - x axis - -32768 to 32767
    gpThumbLY           : int16;  // Left thumb stick - y axis - -32768 to 32767
    gpThumbRX           : int16;  // Right thumb stick - x axis - -32768 to 32767
    gpThumbRY           : int16;  // Right thumb stick - y axis - -32768 to 32767
  end;
  PXInputGamepad = ^TXInputGamepad;

const
  XInputGamePadDPadUp             = $0001;
  XInputGamePadDPadDown           = $0002;
  XInputGamePadDPadLeft           = $0004;
  XInputGamePadDPadRight          = $0008;
  XInputGamePadStart              = $0010;
  XInputGamePadBack               = $0020;
  XInputGamePadLeftThumb          = $0040;
  XInputGamePadRightThumb         = $0080;
  XInputGamePadLeftShoulder       = $0100;
  XInputGamePadRightShoulder      = $0200;
  XInputGamePadA                  = $1000;
  XInputGamePadB                  = $2000;
  XInputGamePadX                  = $4000;
  XInputGamePadY                  = $8000;

//------------------------------------------------------------------------------
// XINPUT_VIBRATION

type
  TXInputVibration = record
    vibLeftMotorSpeed         : word; // Low frequency rumble - Speed 0 (0%) to 65536 (100%)
    vibRightMotorSpeed        : word; // High frequency rumble - Speed 0 (0%) to 65535 (100%)
  end;
  PXInputVibration = ^TXInputVibration;

//------------------------------------------------------------------------------
// XINPUT_CAPABILITIES Structure

type
  TXInputCapabilities = record
    capType           : byte;
    capSubType        : byte;
    capFlags          : word;
    capGamePad        : TXInputGamepad;
    capVibration      : TXInputVibration;
  end;
  PXInputCapabilities = ^TXInputCapabilities;

const
  XInputDeviceTypeGamepad               = $01; // Used with XInputGetCapabilities - Flag field

  XInputDeviceSubTypeGamepad            = $01;
  XInputDeviceSubTypeWheel              = $02;
  XInputDeviceSubTypeArcadeStick        = $03;
  XInputDeviceSubTypeFlightStick        = $04;
  XInputDeviceSubTypeDancePad           = $05;
  XInputDeviceSubTypeGuitar             = $06;
  XInputDeviceSubTypeDrumKit            = $08;

  XInputCapsVoiceSupported              = $0004;

(*
    Features of the controller.
    Value	Description
    XINPUT_CAPS_VOICE_SUPPORTED	Device has an integrated voice device.
    XINPUT_CAPS_FFB_SUPPORTED	Device supports force feedback functionality. Note that these force-feedback features beyond rumble are not currently supported through XINPUT on Windows.
    XINPUT_CAPS_WIRELESS	Device is wireless.
    XINPUT_CAPS_PMD_SUPPORTED	Device supports plug-in modules. Note that plug-in modules like the text input device (TID) are not supported currently through XINPUT on Windows.
    XINPUT_CAPS_NO_NAVIGATION	Device lacks menu navigation buttons (START, BACK, DPAD).

    XInputDeviceSubTypeGamepad
    Includes Left and Right Sticks, Left and Right Triggers, Directional Pad, and all standard buttons (A, B, X, Y, START, BACK, LB, RB, LSB, RSB).

    XInputDeviceSubTypeWheel
    Left Stick X reports the wheel rotation, Right Trigger is the acceleration pedal, and Left Trigger is the brake pedal. Includes Directional Pad and most standard buttons (A, B, X, Y, START, BACK, LB, RB). LSB and RSB are optional.

    XInputDeviceSubTypeArcadeStick
    Includes a Digital Stick that reports as a DPAD (up, down, left, right), and most standard buttons (A, B, X, Y, START, BACK). The Left and Right Triggers are implemented as digital buttons and report either 0 or 0xFF. LB, LSB, RB, and RSB are optional.

    XInputDeviceSubTypeFlightStick
    Includes a pitch and roll stick that reports as the Left Stick, a POV Hat which reports as the Right Stick, a rudder (handle twist or rocker) that reports as Left Trigger, and a throttle control as the Right Trigger. Includes support for a primary weapon (A), secondary weapon (B), and other standard buttons (X, Y, START, BACK). LB, LSB, RB, and RSB are optional.

    XInputDeviceSubTypeDancePad
    Includes the Directional Pad and standard buttons (A, B, X, Y) on the pad, plus BACK and START.

    XInputDeviceSubTypeGuitar
    XINPUT_DEVSUBTYPE_GUITAR_ALTERNATE XINPUT_DEVSUBTYPE_GUITAR_BASS

    The strum bar maps to DPAD (up and down), and the frets are assigned to A (green), B (red), Y (yellow), X (blue), and LB (orange). Right Stick Y is associated with a vertical orientation sensor; Right Stick X is the whammy bar. Includes support for BACK, START, DPAD (left, right). Left Trigger (pickup selector), Right Trigger, RB, LSB (fret modifier), RSB are optional.

    Guitar Bass is identical to Guitar, with the distinct subtype to simplify setup.

    Guitar Alt supports a larger range of movement for the vertical orientation sensor.

    XInputDeviceSubTypeDrumKit
    The drum pads are assigned to buttons: A for green (Floor Tom), B for red (Snare Drum), X for blue (Low Tom), Y for yellow (High Tom), and LB for the pedal (Bass Drum). Includes Directional-Pad, BACK, and START. RB, LSB, and RSB are optional.

    XINPUT_DEVSUBTYPE_ARCADE_PAD
    Includes Directional Pad and most standard buttons (A, B, X, Y, START, BACK, LB, RB). The Left and Right Triggers are implemented as digital buttons and report either 0 or 0xFF. Left Stick, Right Stick, LSB, and RSB are optional.

    Note  The legacy version of XINPUT on Windows Vista (XInput 9.1.0) will always return a fixed subtype of XINPUT_DEVSUBTYPE_GAMEPAD regardless of attached device.
*)

//------------------------------------------------------------------------------
// XINPUT_BATTERY_INFORMATION

type
  TXInputBatteryInformation = record
    biBatteryType         : byte; //
    biBatteryLevel        : byte;
  end;
  PXInputBatteryInformation = ^TXInputBatteryInformation;

const
  XInputBatteryDeviceTypeGamepad          = $0000;
  XInputBatteryDeviceTypeHeadset          = $0001;

  XInputBatteryTypeDisconnected           = $00;
  XInputBatteryTypeWired                  = $01;
  XInputBatteryTypeAlkaline               = $02;
  XInputBatteryTypeNiMH                   = $03;
  XInputBatteryTypeUnknown                = $ff;

  XInputBatteryLevelEmpty                 = $00;
  XInputBatteryLevelLow                   = $01;
  XInputBatteryLevelMedium                = $02;
  XInputBatteryLevelFull                  = $03;

//------------------------------------------------------------------------------
// XINPUT_STATE

type
  TXInputState = record
    stPacketNumber        : uint32;
    stGamepad             : TXInputGamepad;
  end;
  PXInputState = ^TXInputState;

//------------------------------------------------------------------------------
// Function prototypes

type
  TXInputGetState = function(userIndex:uint32;state:PXInputState):uint32; stdcall;
  TXInputSetState = function(userIndex:uint32;vibration:PXInputVibration):uint32; stdcall;
  TXInputGetCapabilities = function(userIndex:uint32;flags:uint32;capabilities:PXInputCapabilities):uint32; stdcall;
  TXInputEnable = procedure(enable:boolean); stdcall;
  TXInputGetDSoundAudioDeviceGuids = function(userIndex:uint32;soundOutputGUID:PGUID;soundInputGUID:PGUID):uint32; stdcall;
  TXInputGetBatteryInformation = function(userIndex:uint32;devType:byte;batteryInformation:PXInputBatteryInformation):uint32; stdcall;
  TXInputGetKeystroke = function(userIndex:uint32;reserved:uint32;keystroke:PXInputKeystroke):uint32; stdcall;

const
  XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE        = 7849;
  XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE       = 8689;
  XINPUT_GAMEPAD_TRIGGER_THRESHOLD          = 30;
  XINPUT_DEVICE_SCAN_PERIOD                 = 100;
  XINPUT_MAX_USERS                          = 4;
  XINPUT_MAX_USER_INDEX                     = XINPUT_MAX_USERS-1;
  XINPUT_THUMB_SCALER                       = 32768;
  XINPUT_MAX_BUTTON_INDEX                   = 13;

  XINPUT_BUTTONS : array[0..XINPUT_MAX_BUTTON_INDEX] of word = (
    XInputGamePadDPadUp,
    XInputGamePadDPadDown,
    XInputGamePadDPadLeft,
    XInputGamePadDPadRight,
    XInputGamePadStart,
    XInputGamePadBack,
    XInputGamePadLeftThumb,
    XInputGamePadRightThumb,
    XInputGamePadLeftShoulder,
    XInputGamePadRightShoulder,
    XInputGamePadA,
    XInputGamePadB,
    XInputGamePadX,
    XInputGamePadY
  );

type
  TXInputConnectEvent               = procedure(sender:TObject;userIndex:uint32) of object;
  TXInputStateChangeEvent           = procedure(sender:TObject;userIndex:uint32;newState:TXInputState) of object;
  TXInputBatteryWarningEvent        = procedure(sender:TObject;userIndex:uint32;newState:byte) of object;
  TXInputButtonEvent                = procedure(sender:TObject;userIndex:uint32;button:word) of object;
  TXInputTrigger                    = (xitLeft,xitRight);
  TXInputThumb                      = (xithumbLeft,xithumbRight);
  TXInputControllerConnected        = array[0..XINPUT_MAX_USER_INDEX] of boolean;
  TXInputControllerGUID             = array[0..XINPUT_MAX_USER_INDEX] of TGUID;
  TXInputControllerState            = array[0..XINPUT_MAX_USER_INDEX] of TXInputState;
  TXInputControllerDeadzone         = array[0..XINPUT_MAX_USER_INDEX] of word;
  TXInputControllerThreshold        = array[0..XINPUT_MAX_USER_INDEX] of byte;
  TXInputControllerCapabilities     = array[0..XINPUT_MAX_USER_INDEX] of TXInputCapabilities;
  TXInputControllerBatteryState     = array[0..XINPUT_MAX_USER_INDEX] of byte;
  TXInputDirection                  = (xidNone,xidRight,xidUpRight,xidUp,xidUpLeft,xidLeft,xidDownLeft,xidDown,xidDownRight);

type
  TXInputInterface = class(TObject)
  private
  protected
    fXInputHandle                   : THandle;
    fInitialised                    : boolean;
    fDeviceScanCount                : integer;
    fFireEventsBeforeStoringState   : boolean;

    fXIGetState                     : TXInputGetState;
    fXISetState                     : TXInputSetState;
    fXIEnable                       : TXInputEnable;
    fXIGetCapabilities              : TXInputGetCapabilities;
    fXIGetDSoundAudioDeviceGUIDS    : TXInputGetDSoundAudioDeviceGUIDS;
    fXIGetBatteryInformation        : TXInputGetBatteryInformation;
    fXIGetKeystroke                 : TXInputGetKeystroke;

    fControllerLeftThumbDeadzone    : TXInputControllerDeadZone;
    fControllerRightThumbDeadzone   : TXInputControllerDeadZone;
    fControllerTriggerThreshold     : TXInputControllerThreshold;

    fControllerConnected            : TXInputControllerConnected;
    fControllerCapabilities         : TXInputControllerCapabilities;
    fControllerSoundOutputGUID      : TXInputControllerGUID;
    fControllerSoundInputGUID       : TXInputControllerGUID;
    fControllerState                : TXInputControllerState;
    fControllerBattery              : TXInputControllerConnected;
    fControllerBatteryState         : TXInputControllerBatteryState;

    fOnControllerConnect            : TXInputConnectEvent;
    fOnControllerDisconnect         : TXInputConnectEvent;
    fOnControllerStateChange        : TXInputStateChangeEvent;
    fOnControllerButtonDown         : TXInputButtonEvent;
    fOnControllerButtonUp           : TXInputButtonEvent;
    fOnControllerButtonPress        : TXInputButtonEvent;
    fOnControllerBatteryWarning     : TXInputBatteryWarningEvent;

    function getControllerConnected(index:byte):boolean;
    function getControllerSoundOutputGUID(index:byte):TGUID;
    function getControllerSoundInputGUID(index:byte):TGUID;
    function getControllerState(index:byte):TXInputState;
    function getControllerCapabilities(index:byte):TXInputCapabilities;
    function getControllerBattery(index:byte):boolean;
    function getControllerBatteryState(index:byte):byte;

    function getControllerGamepadLeftThumbDeadzone(index:byte):word;
    procedure setControllerGamepadLeftThumbDeadzone(index:byte;value:word);
    function getControllerGamepadRightThumbDeadzone(index:byte):word;
    procedure setControllerGamepadRightThumbDeadzone(index:byte;value:word);
    function getControllerGamepadTriggerThreshold(index:byte):byte;
    procedure setControllerGamepadTriggerTHreshold(index:byte;value:byte);

    procedure initialiseVariables;

    procedure scanForDevices;
    procedure scanForState;

    procedure checkIndex(index:byte;methodName:string);
    procedure checkInitialised(methodName:string);

    function deviceDisconnected(index:byte;lastResult:integer):boolean;
    function decodeDirection(x,y:double):TXInputDirection;
    function factorInDeadZone(src:int16;deadZoneValue:int16;var useDeadZone:boolean):double;
  public
    constructor create;
    destructor Destroy; override;

    //------------------------------------------------------------------------------

    function initialise:boolean;
    procedure deinitialise;

    //------------------------------------------------------------------------------
    // Low level API
    //------------------------------------------------------------------------------

    function llGetState(userIndex:uint32;state:PXInputState):uint32;
    function llSetState(userIndex:uint32;vibration:PXInputVibration):uint32;
    Function llGetCapabilities(userIndex:uint32;flags:uint32;capabilities:PXInputCapabilities):uint32;
    procedure llEnable(enable:boolean);
    function llGetDSoundAudioDeviceGuids(userIndex:uint32;soundOutputGUID:PGUID;soundInputGUID:PGUID):uint32;
    function llGetBatteryInformation(userIndex:uint32;devType:byte;batteryInformation:PXInputBatteryInformation):uint32;
    function llGetKeystroke(userIndex:uint32;reserved:uint32;keystroke:PXInputKeystroke):uint32;

    //------------------------------------------------------------------------------
    // High level API
    //------------------------------------------------------------------------------

    procedure refresh; // Call this to update the states as required - Events are fired in the context of the calling thread

    //------------------------------------------------------------------------------

    procedure thumbFromState(index:byte;whichThumb:TXInputThumb;state:TXInputState;var x,y:double;useDeadZones:boolean=true);

    function isButtonPressed(index:byte;button:word):boolean;
    function isTriggerPressed(index:byte;whichTrigger:TXInputTrigger):boolean;

    procedure leftThumb(index:byte;var x,y:double;useDeadZones:boolean=true);
    procedure rightThumb(index:byte;var x,y:double;useDeadZones:boolean=true);

    function trigger(index:byte;whichTrigger:TXInputTrigger):byte;

    function leftJoystick(index:byte):TXInputDirection;
    function rightJoystick(index:byte):TXInputDirection;

    procedure vibrate(index:byte;lowSpeed,highSpeed:uint16);

    //------------------------------------------------------------------------------

    property controllerConnected[index:byte]:boolean read getControllerConnected;
    property controllerCapabilities[index:byte]:TXInputCapabilities read getControllerCapabilities;
    property controllerSoundOutputGUID[index:byte]:TGUID read getControllerSoundOutputGUID;
    property controllerSoundInputGUID[index:byte]:TGUID read getControllerSoundInputGUID;
    property controllerState[index:byte]:TXInputState read getControllerState;
    property controllerBattery[index:byte]:boolean read getControllerBattery;
    property controllerBatteryState[index:byte]:byte read getControllerBatteryState;

    property controllerGamepadLeftThumbDeadzone[index:byte]:word read getControllerGamepadLeftThumbDeadzone write setControllerGamepadLeftThumbDeadzone;
    property controllerGamepadRightThumbDeadzone[index:byte]:word read getControllerGamepadRightThumbDeadZone write setControllerGamepadRightThumbDeadZone;
    property controllerGamepadTriggerThreshold[index:byte]:byte read getControllerGamepadTriggerThreshold write setControllerGamepadTriggerThreshold;

    property fireEventsBeforeStoringState:boolean read fFireEventsBeforeStoringState write fFireEventsBeforeStoringState;

    //------------------------------------------------------------------------------

    property onControllerConnect:TXInputConnectEvent read fOnControllerConnect write fOnControllerConnect;
    property onControllerDisconnect:TXInputConnectEvent read fOnControllerDisconnect write fOnControllerDisconnect;
    property onControllerStateChange:TXInputStateChangeEvent read fOnControllerStateChange write fOnControllerStateChange;
    property onControllerButtonDown:TXInputButtonEvent read fOnControllerButtonDown write fOnControllerButtonDown;
    property onControllerButtonUp:TXInputButtonEvent read fOnControllerButtonUp write fOnControllerButtonUp;
    property onControllerButtonPress:TXinputButtonEvent read fOnControllerButtonPress write fOnControllerButtonPress;
    property onControllerBatteryWarning:TXInputBatteryWarningEvent read fOnControllerBatteryWarning write fOnControllerBatteryWarning;
  end;

var
  xinput : TXInputInterface;

function xinputAvailable:boolean;

implementation

//------------------------------------------------------------------------------

{ TXInputInterface }

//------------------------------------------------------------------------------
// Low level API - Direct access to the XInput API - Can be used externally

procedure TXInputInterface.llEnable(enable: boolean);
begin
  fXIEnable(enable);
end;

function TXInputInterface.llGetBatteryInformation(userIndex: uint32;
  devType: byte; batteryInformation: PXInputBatteryInformation): uint32;
begin
  result:=fXIGetBatteryInformation(userIndex,devType,batteryInformation);
end;

function TXInputInterface.llGetCapabilities(userIndex, flags: uint32;
  capabilities: PXInputCapabilities): uint32;
begin
  result:=fXIGetCapabilities(userIndex,flags,capabilities);
end;

function TXInputInterface.llGetDSoundAudioDeviceGuids(userIndex: uint32;
  soundOutputGUID, soundInputGUID: PGUID): uint32;
begin
  result:=fXIGetDSoundAudioDeviceGUIDS(userIndex,soundOutputGUID,soundInputGUID);
end;

function TXInputInterface.llGetKeystroke(userIndex, reserved: uint32;
  keystroke: PXInputKeystroke): uint32;
begin
  result:=fXIGetKeystroke(userIndex,reserved,keyStroke);
end;

function TXInputInterface.llGetState(userIndex: uint32;
  state: PXInputState): uint32;
begin
  result:=fXIGetState(userIndex,state);
end;

function TXInputInterface.llSetState(userIndex: uint32;
  vibration: PXInputVibration): uint32;
begin
  result:=fXISetState(userIndex,vibration);
end;

//------------------------------------------------------------------------------
// High level API

constructor TXInputInterface.create;
begin
  inherited;

  fXInputHandle:=0;
  fInitialised:=false;
  fDeviceScanCount:=XINPUT_DEVICE_SCAN_PERIOD;

  initialiseVariables;

  fOnControllerConnect:=nil;
  fOnControllerDisconnect:=nil;
  fOnControllerStateChange:=nil;
  fOnControllerButtonDown:=nil;
  fOnControllerButtonUp:=nil;
  fOnControllerButtonPress:=nil;

  fFireEventsBeforeStoringState:=false;
end;

procedure TXInputInterface.initialiseVariables;
var
  loop    : integer;
begin
  for loop:=0 to XINPUT_MAX_USER_INDEX do
  begin
    fControllerConnected[loop]:=false;
    fControllerSoundOutputGUID[loop]:=GUID_NULL;
    fCOntrollerSoundInputGUID[loop]:=GUID_NULL;
    fControllerLeftThumbDeadzone[loop]:=XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE;
    fControllerRightThumbDeadzone[loop]:=XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE;
    fControllerTriggerThreshold[loop]:=XINPUT_GAMEPAD_TRIGGER_THRESHOLD;

    FillMemory(@fControllerState[loop],sizeOf(TXInputState),0);
  end;
end;

procedure TXInputInterface.deinitialise;
begin
  if (fInitialised) then
  begin
    llEnable(false);

    freeLibrary(fXInputHandle);

    fInitialised:=false;
  end;
end;

destructor TXInputInterface.Destroy;
begin
  if (fInitialised) then
  begin
    deinitialise;
  end;

  inherited;
end;

function TXInputInterface.deviceDisconnected(index: byte;
  lastResult: integer): boolean;
begin
  result:=false;

  if (lastResult<>ERROR_SUCCESS) then
  begin
    if (lastResult=ERROR_DEVICE_NOT_CONNECTED) then
    begin
      fControllerConnected[index]:=false;

      if (assigned(fOnControllerDisconnect)) then
      begin
        fOnControllerDisconnect(self,index);
      end;

      result:=true;
    end;
  end;
end;

function TXInputInterface.getControllerBattery(index: byte): boolean;
begin
  checkIndex(index,'getControllerBattery');
  result:=fControllerBattery[index];
end;

function TXInputInterface.getControllerBatteryState(index: byte): byte;
begin
  checkIndex(index,'getControllerBatteryState');
  result:=fControllerBatteryState[index];
end;

function TXInputInterface.getControllerCapabilities(
  index: byte): TXInputCapabilities;
begin
  checkIndex(index,'getControllerCapabilites');
  result:=fControllerCapabilities[index];
end;

function TXInputInterface.getControllerConnected(index: byte): boolean;
begin
  checkIndex(index,'getControllerConnected');
  result:=fControllerConnected[index];
end;

function TXInputInterface.getControllerGamepadLeftThumbDeadzone(
  index: byte): word;
begin
  checkIndex(index,'getControllerGamepadLeftThumbDeadzone');
  result:=fControllerLeftThumbDeadzone[index];
end;

function TXInputInterface.getControllerGamepadRightThumbDeadzone(
  index: byte): word;
begin
  checkIndex(index,'getControllerGamepadRightThumbDeadzone');
  result:=fControllerRightThumbDeadzone[index];
end;

function TXInputInterface.getControllerGamepadTriggerThreshold(
  index: byte): byte;
begin
  checkIndex(index,'getControllerGamepadTriggerThreshold');
  result:=fControllerTriggerThreshold[index];
end;

function TXInputInterface.getControllerSoundInputGUID(index: byte): TGUID;
begin
  checkIndex(index,'getControllerSoundInputGUID');
  result:=fControllerSoundInputGUID[index];
end;

function TXInputInterface.getControllerSoundOutputGUID(index: byte): TGUID;
begin
  checKindex(index,'getControllerSoundOutputGUID');
  result:=fControllerSoundOutputGUID[index];
end;

function TXInputInterface.getControllerState(index: byte): TXInputState;
begin
  checkIndex(index,'getControllerState');
  result:=fControllerState[index];
end;

function TXInputInterface.initialise: boolean;
begin
  result:=false;

  fXInputHandle:=LoadLibrary('XInput1_4.dll');
  if (fXInputHandle=0) then
  begin
    fXInputHandle:=LoadLibrary('XInput1_3.dll');
  end;

  if (fXInputHandle<>0) then
  begin
    @fXIGetState:=GetProcAddress(fXInputHandle,'XInputGetState');
    @fXISetState:=getProcAddress(fXInputHandle,'XInputSetState');
    @fXIGetCapabilities:=getProcAddress(fXInputHandle,'XInputGetCapabilities');
    @fXIGetDSoundAudioDeviceGUIDS:=getProcAddress(fXInputHandle,'XInputGetDSoundAudioDeviceGuids');
    @fXIGetBatteryInformation:=getProcAddress(fXInputHandle,'XInputGetBatteryInformation');
    @fXIGetKeystroke:=getProcAddress(fXInputHandle,'XInputGetKeystroke');
    @fXIEnable:=getProcAddress(fXInputHandle,'XInputEnable');

    if (
      (@fXIGetState<>nil) and
      (@fXISetState<>nil) and
      (@fXIGetCapabilities<>nil) and
      (@fXIGetDSoundAudioDeviceGuids<>nil) and
      (@fXIGetBatteryInformation<>nil) and
      (@fXIGetKeystroke<>nil) and
      (@fXIEnable<>nil)
    ) then
    begin
      // We have initialised the library, so deal with the initialisation of the rest of the object
      llEnable(true);

      initialiseVariables;
      scanForDevices;
      scanForState;

      fInitialised:=true;
      result:=true;
    end;
  end;
end;

function TXInputInterface.isButtonPressed(index: byte; button: word): boolean;
begin
  checkIndex(index,'isButtonPressed');

  if (fControllerConnected[index]) then
  begin
    result:=((fControllerState[index].stGamepad.gpButtons and button)=button);
  end
  else
  begin
    result:=false;
  end;
end;

function TXInputInterface.isTriggerPressed(index: byte;
  whichTrigger: TXInputTrigger): boolean;
begin
  checkIndex(index,'isTriggerPressed');

  if (fControllerConnected[index]) then
  begin
    result:=(trigger(index,whichTrigger)>fControllerTriggerThreshold[index]);
  end
  else
  begin
    result:=false;
  end;
end;

const
  ONE16TH = (2*PI)/16;
  SIXTEENTHS : array[1..15] of double = (
    ONE16TH,
    ONE16TH*2,
    ONE16TH*3,
    PI/2,
    PI/2+ONE16TH,
    PI/2+ONE16TH*2,
    PI/2+ONE16TH*3,
    PI,
    PI+ONE16TH,
    PI+ONE16TH*2,
    PI+ONE16TH*3,
    PI+PI/2,
    PI+PI/2+ONE16TH,
    PI+PI/2+ONE16TH*2,
    PI+PI/2+ONE16TH*3
  );

function TXInputInterface.decodeDirection(x,y:double):TXInputDirection;
var
  at        : double;
  dirLoop   : TXInputDirection;
begin
  result:=xidNone;

  if (x<>0) or (y<>0) then
  begin
    if (x<>0) then
    begin
      at:=arcTan(y/x);
      if (x>0) then
      begin
        if (y<0) then
        begin
          at:=at+(2*pi);
        end;
      end
      else
      begin
        if (x<0) then
        begin
          at:=at+pi;
        end;
      end;
    end
    else
    begin
      at:=0;
    end;

    if (at<SIXTEENTHS[1]) or (at>SIXTEENTHS[15]) then
    begin
      result:=xidRight;
    end
    else
    begin
      for dirLoop:=xidUpRight to xidDownRight do
      begin
        if (at>SIXTEENTHS[1+(integer(dirLoop)-2)*2]) and (at<SIXTEENTHS[3+(integer(dirLoop)-2)*2]) then
        begin
          result:=dirLoop;
          break;
        end;
      end;
    end;
  end;
end;

function TXInputInterface.leftJoystick(index: byte): TXInputDirection;
var
  x,y   : double;
begin
  checkIndex(index,'leftJoystick');

  if (fControllerConnected[index]) then
  begin
    leftThumb(index,x,y);
    result:=decodeDirection(x,y);
  end
  else
  begin
    result:=xidNone;
  end;
end;

function TXInputInterface.factorInDeadZone(src:int16;deadZoneValue:int16;var useDeadZone:boolean):double;
begin
  if (abs(src)<deadZoneValue) and (useDeadZone) then
  begin
    result:=0;
  end
  else
  begin
    result:=src/XINPUT_THUMB_SCALER;
  end;
end;

procedure TXInputInterface.thumbFromState(index:byte;whichThumb:TXInputThumb;state:TXInputState;var x,y:double;useDeadZones:boolean=true);
var
  srcx      : int16;
  srcy      : int16;
  deadZone  : word;
begin
  if (whichThumb=xithumbLeft) then
  begin
    srcx:=state.stGamepad.gpThumbLX;
    srcY:=state.stGamepad.gpThumbLY;
    deadZone:=fControllerLeftThumbDeadzone[index];
  end
  else
  begin
    srcx:=state.stGamepad.gpThumbRX;
    srcY:=state.stGamepad.gpThumbRY;
    deadZone:=fControllerRightThumbDeadzone[index];
  end;

  if (abs(srcX)>=deadZone) or (abs(srcY)>=deadZone) then
  begin
    useDeadZones:=false;
  end;

  x:=factorInDeadZone(srcX,deadZone,useDeadZones);
  y:=factorInDeadZone(srcY,deadZone,useDeadZones);
end;

procedure TXInputInterface.leftThumb(index: byte; var x, y: double; useDeadZones: boolean);
begin
  checkIndex(index,'leftThumb');

  if (fControllerConnected[index]) then
  begin
    thumbFromState(index,xithumbLeft,fControllerState[index],x,y,useDeadZones);
  end
  else
  begin
    x:=0;
    y:=0;
  end;
end;

procedure TXInputInterface.refresh;
begin
  checkInitialised('refresh');

  dec(fDeviceScanCount);

  if (fDeviceScanCount<=0) then
  begin
    scanForDevices;
  end;

  scanForState;
end;

function TXInputInterface.rightJoystick(index: byte): TXInputDirection;
var
  x,y   : double;
begin
  checkIndex(index,'rightJoystick');

  if (fControllerConnected[index]) then
  begin
    rightThumb(index,x,y);
    result:=decodeDirection(x,y);
  end
  else
  begin
    result:=xidNone;
  end;
end;

procedure TXInputInterface.rightThumb(index: byte; var x, y: double;
  useDeadZones: boolean);
begin
  checkIndex(index,'rightThumb');

  if (fControllerConnected[index]) then
  begin
    thumbFromState(index,xithumbRight,fControllerState[index],x,y,useDeadZones);
  end
  else
  begin
    x:=0;
    y:=0;
  end;
end;

procedure TXInputInterface.scanForDevices;
var
  tempCap       : TXInputCapabilities;
  tempBat       : TXInputBatteryInformation;

  loop          : byte;
  result        : uint32;
begin
  fDeviceScanCount:=XINPUT_DEVICE_SCAN_PERIOD;

  for loop:=0 to XINPUT_MAX_USER_INDEX do
  begin
    if (not fControllerConnected[loop]) then
    begin
      fillMemory(@tempCap,sizeOf(TXInputCapabilities),0);

      if (llGetCapabilities(loop,XInputDeviceTypeGamepad,@tempCap)=ERROR_SUCCESS) then
      begin
        // Device connected
        fControllerCapabilities[loop]:=tempCap;

        if (assigned(fOnControllerConnect)) then
        begin
          fOnControllerConnect(self,loop);
        end;

        fControllerConnected[loop]:=true;
        fControllerState[loop].stPacketNumber:=0;

        fillMemory(@tempBat,sizeOf(TXInputBatteryInformation),0);

        if (llGetBatteryInformation(loop,XInputDeviceTypeGamepad,@tempBat)=ERROR_SUCCESS) then
        begin
          fControllerBattery[loop]:=(tempBat.biBatteryType in [XInputBatteryTypeAlkaline,XInputBatteryTypeNiMH]);
          fControllerBatteryState[loop]:=tempBat.biBatteryLevel;

          if (fControllerBatteryState[loop] in [XInputBatteryLevelEmpty,XInputBatteryLevelLow]) then
          begin
            if (assigned(fOnControllerBatteryWarning)) then
            begin
              fOnControllerBatteryWarning(self,loop,tempBat.biBatteryLevel);
            end;
          end;
        end
        else
        begin
          fControllerBattery[loop]:=false;
        end;
      end;
    end
    else
    begin
      if (fControllerBattery[loop]) then
      begin
        fillMemory(@tempBat,sizeOf(TXInputBatteryInformation),0);

        result:=llGetBatteryInformation(loop,XInputDeviceTypeGamepad,@tempBat);

        if (not deviceDisconnected(loop,result)) then
        begin
          if (
            (tempBat.biBatteryLevel in [XInputBatteryLevelEmpty,XInputBatteryLevelLow]) and
            (tempBat.biBatteryLevel<fControllerBatteryState[loop])
          ) then
          begin
            if (assigned(fOnControllerBatteryWarning)) then
            begin
              fOnControllerBatteryWarning(self,loop,tempBat.biBatteryLevel);
            end;
          end;

          fControllerBatteryState[loop]:=tempBat.biBatteryLevel;
        end;
      end;
    end;
  end;
end;

procedure TXInputInterface.checkIndex(index:byte;methodName:string);
begin
  checkInitialised(methodName);

  if (index>XINPUT_MAX_USER_INDEX) then
  begin
    raise exception.create('Index out of bounds in '+self.className+'.'+methodName+' ('+intToStr(index)+')');
  end;
end;


procedure TXInputInterface.checkInitialised(methodName: string);
begin
  if (not fInitialised) then
  begin
    raise exception.create('Not initialised in '+self.className+'.'+methodName);
  end;
end;

procedure TXInputInterface.scanForState;
var
  loop          : byte;
  tempState     : TXInputState;
  result        : uint32;
  buttonsUp     : integer;
  buttonsDown   : integer;
  buttonLoop    : integer;
  button        : word;
begin
  for loop:=0 to XINPUT_MAX_USER_INDEX do
  begin
    if (fControllerConnected[loop]) then
    begin
      fillMemory(@tempState,sizeOf(TXInputState),0);

      result:=llGetState(loop,@tempState);

      if not deviceDisconnected(loop,result) then
      begin
        if (tempState.stPacketNumber<>fControllerState[loop].stPacketNumber) then
        begin
          // Process changes
          buttonsUp:=0;
          buttonsDown:=0;

          if (fControllerState[loop].stGamepad.gpButtons<>tempState.stGamepad.gpButtons) then
          begin
            for buttonLoop:=0 to XINPUT_MAX_BUTTON_INDEX do
            begin
              button:=XINPUT_BUTTONS[buttonLoop];

              if ((fControllerState[loop].stGamepad.gpButtons and button)=0) then
              begin
                if ((tempState.stGamepad.gpButtons and button)=button) then
                begin
                  buttonsDown:=buttonsDown or button;
                end;
              end
              else
              begin
                if ((tempState.stGamepad.gpButtons and button)=0) then
                begin
                  buttonsUp:=buttonsUp or button;
                end;
              end;
            end;
          end;

          if (not fFireEventsBeforeStoringState) then
          begin
            fControllerState[loop]:=tempState;
          end;

          if (assigned(fOnControllerStateChange)) then
          begin
            fOnControllerStateChange(self,loop,tempState);
          end;

          if (buttonsDown<>0) and assigned(fOnControllerButtonDown) then
          begin
            fOnControllerButtonDown(self,loop,buttonsDown);
          end;

          if (buttonsUp<>0) then
          begin
            if assigned(fOnControllerButtonUp) then
            begin
              fOnControllerButtonUp(self,loop,buttonsUp);
            end;
            if assigned(fOnControllerButtonPress) then
            begin
              fOnControllerButtonPress(self,loop,buttonsUp);
            end;
          end;

          // Record the newly read state
          if (fFireEventsBeforeStoringState) then
          begin
            fControllerState[loop]:=tempState;
          end;
        end;
      end;
    end;
  end;
end;

procedure TXInputInterface.setControllerGamepadLeftThumbDeadzone(index: byte;
  value: word);
begin
  checkIndex(index,'setControllerGamepadLeftThumbDeadzone');
  fControllerLeftThumbDeadzone[index]:=value;
end;

procedure TXInputInterface.setControllerGamepadRightThumbDeadzone(index: byte;
  value: word);
begin
  checkIndex(index,'setControllerGamepadRightThumbDeadzone');
  fControllerRightThumbDeadzone[index]:=value;
end;

procedure TXInputInterface.setControllerGamepadTriggerTHreshold(index,
  value: byte);
begin
  checkIndex(index,'setControllerGamepadTriggerThreshold');
  fControllerTriggerThreshold[index]:=value;
end;

function TXInputInterface.trigger(index: byte; whichTrigger: TXInputTrigger): byte;
begin
  checkIndex(index,'trigger');

  if (fControllerConnected[index]) then
  begin
    if (whichTrigger=xitLeft) then
    begin
      result:=fControllerState[index].stGamepad.gpLeftTrigger;
    end
    else
    begin
      result:=fControllerState[index].stGamepad.gpRightTrigger;
    end;
  end
  else
  begin
    result:=0;
  end;
end;

procedure TXInputInterface.vibrate(index: byte; lowSpeed, highSpeed: uint16);
var
  vibe      : TXInputVibration;
  result    : uint32;
begin
  checkIndex(index,'vibrate');

  if (fControllerConnected[index]) then
  begin
    vibe.vibLeftMotorSpeed:=lowSpeed;
    vibe.vibRightMotorSpeed:=highSpeed;

    result:=llSetState(index,@vibe);

    deviceDisconnected(index,result);
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF MSWINDOWS}
function xinputAvailable:boolean;
begin
  result:=false;

  xinput:=TXInputInterface.create;
  try
    result:=xinput.initialise;
  finally
    if (not result) then
    begin
      xinput.free;
      xinput:=nil;
    end;
  end;
end;
{$ELSE}
function xinputAvailable:boolean;
begin
  result:=false;
end;
{$ENDIF}

initialization
  xinput:=nil;

finalization
  if (xInput<>nil) then
  begin
    try
      xInput.deinitialise;
    except
    end;

    xInput.free;

    xInput:=nil;
  end;

end.
