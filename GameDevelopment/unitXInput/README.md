# unitXInput.pas #
  
## Introduction ##

An XInput interface for handling XBox gamepads.

Currently supports gamepad devices only (limitation of the XInput libraries) using XInput1_3.dll (tested) and XInput1_4.dll (untested - No Windows 8 test platform available).  Battery level monitoring/warning events are untested due to a lack of wireless controllers.

Built with Delphi XE7, operates on Win32 and Win64.  Provides mechanism to allow inclusion when built for other platforms (i.e. interface object definition is available, but interface object is nil and libraries are loaded dynamically), but will require some additional work to remove dependence on WinAPI.Windows.FillMemory.

Built based on the XInput1_3.dll documentation available as at 19th December 2014.  XInput1_4.dll provides an additional routine that is not supported at this time.

## Usage Instructions ##

You must have XInput1_3.dll or XInput1_4.dll installed.  This unit does not work with versions prior to this.

To establish the availability of XInput, use the XInputAvailable function.  On being called, it will attempt to create the XInput object and initialise the library.  On platforms other than windows, it returns false.

If XInputAvailable returns true, the XInput global variable will be assigned an instance of TXInputInterface.

During the initialisation process, the interface queries the four possible controllers and establishes various parameters that are available using the following properties:-

- **XInput.controllerConnected[index]** - True if there is a controller connected on this index
- **XInput.controllerCapabilities[index]** - Returns TXInputCapabilities for the controller
- **XInput.controllerState[index]** - Returns the last received TXInputState for the controller
- **XInput.controllerBattery[index]** - Returns True if the controller has a battery (i.e. is not wired)
- **XInput.controllerBatteryState[index]** - Returns XInputBatteryLevelxx values corresponding to battery state
- **XInput.controllerSoundOutputGUID[index]** - Returns the GUID of the DirectSound output device attached to the controller
- **XInput.controllerSoundInputGUID[index]** - Returns the GUID of the DirectSound input device attached to the controller

Once initialised you can use the low level API routines that simply make the relevant calls to the XInput library.  These routines are:-

- **function llGetState(userIndex:uint32;state:PXInputState):uint32;**
- **function llSetState(userIndex:uint32;vibration:PXInputVibration):uint32;**
- **function llGetCapabilities(userIndex:uint32;flags:uint32;capabilities:PXInputCapabilities):uint32;**
- **procedure llEnable(enable:boolean);**
- **function llGetDSoundAudioDeviceGuids(userIndex:uint32;soundOutputGUID:PGUID;soundInputGUID:PGUID):uint32;**
- **function llGetBatteryInformation(userIndex:uint32;devType:byte;batteryInformation:PXInputBatteryInformation):uint32;**
- **function llGetKeystroke(userIndex:uint32;reserved:uint32;keystroke:PXInputKeystroke):uint32;**

Alternatively you can use the high level API.  To do so, simply call XInput.refresh periodically.  This will scan for state changes and will also (at a much slower rate) scan for hardware connections and battery level changes.

You can then access the information using the properties above, or use the events described below (NOTE - All events are fired in the context of the thread that calls 'refresh'):-

- **onControllerConnect : procedure(sender:TObject;userIndex:uint32) of object;** - This event is fired when a controller appears after the first initialisation. It simply returns the index of the controller that was connected (0-3).
- **onControllerDisconnect : procedure(sender:TObject;userIndex:uint32) of object;** - This event is fired when a controller disappears.  It simply returns the index of the controller that was disconnected (0-3).
- **onControllerStateChange : procedure(sender:TObject;userIndex:uint32;newState:TXInputState) of object;** - This event is called during refresh to signal a change in the controllers state. The handler receives the index of the controller (0-3) and the new state.
- **onControllerButtonDown : procedure(sender:TObject;userIndex:uint32;button:word) of object;** - This event is called during refresh to signal that a button has gone down.  The handler receives the index of the controller (0-3) and a bitmap of XInputGamepadxx values representing the buttons that went down.
- **onControllerButtonUp : procedure(sender:TObject;userIndex:uint32;button:word) of object;** - This event is called during refresh to signal that a button has gone up. The handler receives the index of the controller (0-3) and a bitmap of XInputGamepadxx values representing the buttons that went up.
- **onControllerButtonPress : procedure(sender:TObject;userIndex:uint32;button:word) of object;** - This event is essentially the same as onControllerButtonUp and is triggered at the same point.  It is provided to allow developers to have a simple button press event or to monitor for extended operation of the switch as may occur when triggering a special in-game ability.
- **onControllerBatteryWarning : procedure(sender:TObject;userIndex:uint32;newState:byte) of object;** - This event is fired when the battery monitor detects the battery has just entered the XInputBatteryLevelEmpty or XInputBatteryLevelLow states.

The events onControllerStateChange, onControllerButtonDown, onControllerButtonUp and onControllerButtonPress occur after the new state has been stored.  This order can be changed by setting XInput.fireEventsBeforeStoringState to true.  In this mode, the events fire before the state is stored in the buffer that is used by XInput.controllerState.

Along with the events, there are also a number of helper routines as outlined below:-

- **procedure thumbFromState(index:byte;whichThumb:TXInputThumb;state:TXInputState;var x,y:double;useDeadZones:boolean=true);** - This routine allows you to extract thumb stick position data from a TXInputState object.  The routine is used internally, and factors in the deadzone settings for the stick (see below for deadzones and thresholds).  Simply pass in the index of the controller (required to read deadzone settings), which thumb stick you are interested in (xithumbLeft or xithumbRight) and the state record.  The routine will return scaled value for the X and Y position.  The values are scaled to -1 to +1 (corresponding to left/down and right/up respectively).
- **function isButtonPressed(index:byte;button:word):boolean;** - Simple helper to check the current state for a button press.  Pass in the controller index, an XInputGamepadxx value and the function will return true or false accordingly.
- **function isTriggerPressed(index:byte;whichTrigger:TXInputTrigger):boolean;** - Simple helper to treat the analogue shoulder buttons as triggers.  Pass in the controller index and which trigger you are interested in (xitLeft or xitRight) and the function will return true or false depending on whether the button is pressed beyond the trigger threshold.
- **procedure leftThumb(index:byte;var x,y:double;useDeadZones:boolean=true);** - Simple helper to get the current left thumb stick position for the controller specified by index.  See 'thumbFromState' for information about scaling.
- **procedure rightThumb(index:byte;var x,y:double;useDeadZones:boolean=true);** - Simple helper to get the current right thumb stick position for the controller specified by index.  See 'thumbFromState' for information about scaling.
- **function trigger(index:byte;whichTrigger:TXInputTrigger):byte;** - Read the current position of the analog shoulder buttons.  Pass in the controller index and which trigger (xitLeft or xitRight) and the function will return 0 for not depressed to 255 for depressed fully.
- **function leftJoystick(index:byte):TXInputDirection;** - Read the left thumb stick as a joystick.  Specify the controller index. Returns an TXInputDirection value corresponding to the position.
- **function rightJoystick(index:byte):TXInputDirection;** - Read the right thumb stick as a joystick. See 'leftJoystick' for more information.
- **procedure vibrate(index:byte;lowSpeed,highSpeed:uint16);** - Set the status of the vibration motors within the specified controller. Each controller has two motors.  The low frequency left hand motor and the high frequency right hand motor.  To control vibration set the low frequency motor speed (lowSpeed) and high frequency motor speed (highSpeed) to a value in the range 0 (off) to 65535 (full speed).  Low speed values may result in correct operation as the motor may be unable to turn due to the load placed on it by the weights used to create the vibration effect.

You can use events or simply call 'refresh' and then use these routines to establish the state of things, or of course, a mixture of the two.

Once you have called 'xinputAvailable' there is no need to clean up as this is done in the finalization of the unit.  If you wish to handle it yourself, simply free xInput and set it to NIL (if you fail to do this, you will get an Access Violation on shutdown).

**NOTE:-** None of the routines perform input validation, so you should read up a little on XInput.  The one exception to this is the index field used to select which controller you are operating on.  An exception (Exception class) will be raised.

## Deadzones and thresholds ##

As mentioned above, for less tricky operation of the thumb sticks, a deadzone should be employed (as advised in the XInput documentation).  This interface allows you to configure the deadzone for each stick on each controller.

Defaults are provided and these appear to work quite well.

If you elect not to use deadzones, simply pass in false for the 'useDeadZones' parameters.  By default the interface uses deadzones to desensitise the thumb sticks slightly.  It should be noted that if movement in one direction falls outside the deadzone, then the deadzone will not be used at all in any direction.

The deadzone values should be positive integers in the range 0 to 32767.  Any value whose magnitude is larger than the specified deadzone value will considered valid.  For everything else, 0 will be returned.

So for example, if the deadzone is set to 2048.  Values in the range -2047 to 2047 will be considered dead and will be ignored.  Anything less than or equal to -2048 or greater than or equal to 2048 will be considered valid.  Check out the routine 'factorInDeadzone' if you wish to see the checks in code.

The same logic is applied when treating analog shoulder buttons as triggers.  The button must pass a certain threshold before it is considered as 'pressed'.  Like deadzones, a default is provided which appears to work quite well.

The deadzones and thresholds are available through the following properties:-

- controllerGamepadLeftThumbDeadzone[index:byte]:word
- controllerGamepadRightThumbDeadzone[index:byte]:word
- controllerGamepadTriggerThreshold[index:byte]:byte

## Final Notes## 
On Windows, this interface can only handle gamepad devices.  Thus it only looks for those.  This is a limitation of the XInput library that is documented in official Microsoft documentation.

To enable use on other platforms (so you don't have to worry about lots of conditional code blocks) you can simply check the XInput variable after calling XInputAvailable.  If it is NIL, then XInput isn't available either because it is not supported on the platform or because the library has failed to initialise.
 
## Version History ##

    Date        Version Author                 Description
    ----------- ------- ---------------------- ----------------------------------------------------------
    19-Dec-2014 1.0      C L Warne             Original release
                                               Support for gamepad devices under XInput1_3.dll (tested)
                                                and XInput1_4.dll (untested)
                                               Battery level eventing not tested due to a lack of wireless
                                                controllers
    ----------- ------- ---------------------- ----------------------------------------------------------
