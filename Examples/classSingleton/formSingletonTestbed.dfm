object frmSingletonTestbed: TfrmSingletonTestbed
  Left = 0
  Top = 0
  Caption = 'Singleton Testbed'
  ClientHeight = 443
  ClientWidth = 625
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlControlContainer: TPanel
    Left = 0
    Top = 0
    Width = 625
    Height = 41
    Align = alTop
    TabOrder = 0
    object cmdTest: TButton
      Left = 8
      Top = 9
      Width = 121
      Height = 25
      Caption = 'Test'
      TabOrder = 0
      OnClick = cmdTestClick
    end
  end
  object mmoLog: TMemo
    Left = 0
    Top = 41
    Width = 625
    Height = 402
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
end
