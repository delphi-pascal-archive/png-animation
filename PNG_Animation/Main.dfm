object MainForm: TMainForm
  Left = 198
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Hidden !'
  ClientHeight = 329
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alTop
    OnMouseUp = ImgMouseUp
  end
  object ButtonPanel: TPanel
    Left = 0
    Top = 240
    Width = 320
    Height = 89
    Align = alClient
    TabOrder = 0
    object SpeedLbl: TLabel
      Left = 8
      Top = 8
      Width = 40
      Height = 13
      Caption = 'Vitesse :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object CreditsLbl: TLabel
      Left = 88
      Top = 56
      Width = 135
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Caption = 'Hidden, par Bacterius !'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object SpeedBar: TTrackBar
      Left = 50
      Top = 5
      Width = 267
      Height = 22
      Max = 25
      Orientation = trHorizontal
      Frequency = 1
      Position = 1
      SelEnd = 0
      SelStart = 0
      TabOrder = 0
      TickMarks = tmBottomRight
      TickStyle = tsNone
      OnChange = SpeedBarChange
    end
    object QuitBtn: TButton
      Left = 228
      Top = 56
      Width = 83
      Height = 25
      Caption = 'Quitter'
      TabOrder = 1
      OnClick = QuitBtnClick
    end
    object PauseBtn: TButton
      Left = 8
      Top = 56
      Width = 75
      Height = 25
      Caption = 'Pause'
      TabOrder = 2
      OnClick = PauseBtnClick
    end
    object DoubleCrossBox: TCheckBox
      Left = 8
      Top = 32
      Width = 94
      Height = 17
      Caption = 'Double-crossing'
      TabOrder = 3
      OnClick = DoubleCrossBoxClick
    end
  end
end
