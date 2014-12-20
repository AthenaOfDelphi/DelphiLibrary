object frmBTreeTestbedMain: TfrmBTreeTestbedMain
  Left = 0
  Top = 0
  Caption = 'Binary Tree Testbed'
  ClientHeight = 443
  ClientWidth = 592
  Color = clBtnFace
  Constraints.MinHeight = 477
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 421
    Height = 443
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object Panel1: TPanel
    Left = 421
    Top = 0
    Width = 171
    Height = 443
    Align = alRight
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 390
      Width = 71
      Height = 13
      Caption = 'String List Test'
    end
    object Label2: TLabel
      Left = 8
      Top = 240
      Width = 53
      Height = 13
      Caption = 'String Tree'
    end
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 61
      Height = 13
      Caption = 'Integer Tree'
    end
    object Button1: TButton
      Left = 89
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Create'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 89
      Top = 56
      Width = 75
      Height = 25
      Caption = 'Populate'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 89
      Top = 180
      Width = 75
      Height = 25
      Caption = 'Cleanup'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 89
      Top = 87
      Width = 75
      Height = 25
      Caption = 'Stats'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 89
      Top = 118
      Width = 75
      Height = 25
      Caption = 'Clear Stats'
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 89
      Top = 149
      Width = 75
      Height = 25
      Caption = 'Find Test'
      TabOrder = 5
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 8
      Top = 256
      Width = 75
      Height = 25
      Caption = 'Populate'
      TabOrder = 6
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 8
      Top = 287
      Width = 75
      Height = 25
      Caption = 'Find'
      TabOrder = 7
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 8
      Top = 352
      Width = 75
      Height = 25
      Caption = 'R+W'
      TabOrder = 8
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 89
      Top = 211
      Width = 75
      Height = 25
      Caption = 'R+W'
      TabOrder = 9
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 8
      Top = 318
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 10
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 8
      Top = 86
      Width = 75
      Height = 25
      Caption = 'Dump Tree'
      TabOrder = 11
      OnClick = Button12Click
    end
    object Button13: TButton
      Left = 8
      Top = 55
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 12
      OnClick = Button13Click
    end
    object Button14: TButton
      Left = 8
      Top = 117
      Width = 75
      Height = 25
      Caption = 'Check'
      TabOrder = 13
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 8
      Top = 148
      Width = 75
      Height = 25
      Caption = 'Balance'
      TabOrder = 14
      OnClick = Button15Click
    end
    object Button16: TButton
      Left = 8
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Unsafe Pop'
      TabOrder = 15
      OnClick = Button16Click
    end
    object Button17: TButton
      Left = 89
      Top = 256
      Width = 75
      Height = 25
      Caption = 'Stats'
      TabOrder = 16
      OnClick = Button17Click
    end
    object Button18: TButton
      Left = 89
      Top = 318
      Width = 75
      Height = 25
      Caption = 'Balance'
      TabOrder = 17
      OnClick = Button18Click
    end
    object Button19: TButton
      Left = 89
      Top = 287
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 18
      OnClick = Button19Click
    end
    object Button20: TButton
      Left = 8
      Top = 179
      Width = 75
      Height = 25
      Caption = 'Clear Tree'
      TabOrder = 19
      OnClick = Button20Click
    end
    object Button21: TButton
      Left = 8
      Top = 409
      Width = 75
      Height = 25
      Caption = '500k In List'
      TabOrder = 20
      OnClick = Button21Click
    end
  end
end
