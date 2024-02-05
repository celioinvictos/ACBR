object frmConsulta: TfrmConsulta
  Left = 0
  Top = 0
  Width = 1006
  Height = 851
  AutoScroll = True
  Caption = 'frmConsulta'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btConsultar: TButton
    Left = 0
    Top = 25
    Width = 990
    Height = 25
    Align = alTop
    Caption = 'CONSULTAR'
    TabOrder = 0
    OnClick = btConsultarClick
    ExplicitLeft = -8
    ExplicitTop = 64
  end
  object mHTML: TMemo
    Left = 0
    Top = 796
    Width = 990
    Height = 16
    Align = alBottom
    Lines.Strings = (
      'mHTML')
    TabOrder = 1
    Visible = False
  end
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 50
    Width = 990
    Height = 558
    Align = alClient
    TabOrder = 2
    OnExecuteScript = EdgeBrowser1ExecuteScript
    ExplicitHeight = 514
  end
  object btExtrairDados: TButton
    Left = 0
    Top = 608
    Width = 990
    Height = 25
    Align = alBottom
    Caption = 'EXTRAIR DADOS'
    TabOrder = 3
    OnClick = btExtrairDadosClick
    ExplicitTop = 698
  end
  object mExtracao: TMemo
    Left = 0
    Top = 633
    Width = 990
    Height = 163
    Align = alBottom
    TabOrder = 4
    ExplicitTop = 597
  end
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 990
    Height = 25
    Align = alTop
    Caption = 'pnTop'
    TabOrder = 5
    ExplicitTop = 25
    object lblCNPJ: TLabel
      Left = 1
      Top = 1
      Width = 52
      Height = 23
      Align = alLeft
      Caption = 'CNPJ'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edCNPJ: TEdit
      Left = 53
      Top = 1
      Width = 936
      Height = 23
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Text = '83.614.651/0001-07'
      ExplicitLeft = 29
      ExplicitWidth = 960
      ExplicitHeight = 27
    end
  end
end
