object frmXInputTestbedMain: TfrmXInputTestbedMain
  Left = 0
  Top = 0
  Caption = 'Testbed for unitXInput.pas'
  ClientHeight = 462
  ClientWidth = 584
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object mmoLog: TMemo
    Left = 0
    Top = 0
    Width = 584
    Height = 339
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object pnlControlContainer: TPanel
    Left = 0
    Top = 339
    Width = 584
    Height = 123
    Align = alBottom
    TabOrder = 1
    object grpInit: TGroupBox
      Left = 8
      Top = 8
      Width = 94
      Height = 105
      Caption = 'Initialisation'
      TabOrder = 0
      object cmdInit: TButton
        Left = 8
        Top = 20
        Width = 75
        Height = 25
        Caption = 'Initialise'
        TabOrder = 0
        OnClick = cmdInitClick
      end
    end
    object grpVibration: TGroupBox
      Left = 110
      Top = 8
      Width = 464
      Height = 105
      Caption = 'Vibration'
      TabOrder = 1
      object lblController: TLabel
        Left = 353
        Top = 18
        Width = 47
        Height = 13
        Caption = 'Controller'
      end
      object lblHigh: TLabel
        Left = 9
        Top = 55
        Width = 73
        Height = 13
        Caption = 'High frequency'
      end
      object lblLow: TLabel
        Left = 9
        Top = 20
        Width = 71
        Height = 13
        Caption = 'Low frequency'
      end
      object cmdVibrate: TButton
        Left = 353
        Top = 64
        Width = 98
        Height = 25
        Caption = 'Click to vibrate'
        TabOrder = 0
        OnMouseDown = cmdVibrateMouseDown
        OnMouseUp = cmdVibrateMouseUp
      end
      object cboControllerIndex: TComboBox
        Left = 353
        Top = 37
        Width = 98
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = '0'
        Items.Strings = (
          '0'
          '1'
          '2'
          '3')
      end
      object barHigh: TTrackBar
        Left = 88
        Top = 55
        Width = 262
        Height = 34
        Max = 65535
        Frequency = 4096
        TabOrder = 2
      end
      object barLow: TTrackBar
        Left = 88
        Top = 20
        Width = 262
        Height = 29
        Max = 65535
        Frequency = 4096
        TabOrder = 3
      end
    end
  end
  object tmrScan: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrScanTimer
    Left = 168
    Top = 104
  end
end
