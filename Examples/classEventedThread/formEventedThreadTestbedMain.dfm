object frmEventedThreadTestbedMain: TfrmEventedThreadTestbedMain
  Left = 0
  Top = 0
  Caption = 'Evented Thread Testbed'
  ClientHeight = 493
  ClientWidth = 747
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object mmoLog: TMemo
    Left = 0
    Top = 0
    Width = 747
    Height = 453
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    ExplicitHeight = 424
  end
  object pnlControlContainer: TPanel
    Left = 0
    Top = 453
    Width = 747
    Height = 40
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 424
    DesignSize = (
      747
      40)
    object cmdUnpause: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Unpause'
      TabOrder = 0
      OnClick = cmdUnpauseClick
    end
    object cmdPause: TButton
      Left = 89
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Pause'
      TabOrder = 1
      OnClick = cmdPauseClick
    end
    object cmdUnpauseSingle: TButton
      Left = 376
      Top = 6
      Width = 363
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 
        'Single Cycle (Runs 10 seconds after last run/start or when you c' +
        'lick this)'
      TabOrder = 2
      OnClick = cmdUnpauseSingleClick
    end
  end
end
