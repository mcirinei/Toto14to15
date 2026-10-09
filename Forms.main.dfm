object Main: TMain
  Tag = 1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 
    'Toto14ToText 1.1 - (c) 2024-2026 HappySoft di Marco Cirinei - Tut' +
    'ti i diritti riservati'
  ClientHeight = 305
  ClientWidth = 545
  Color = clMaroon
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object pnlTipoConversione: TRzPanel
    Left = 72
    Top = 15
    Width = 400
    Height = 59
    Color = 16578030
    TabOrder = 0
    object pnlHeadTipoConversione: TXiPanel
      Left = 2
      Top = 2
      Width = 396
      Height = 28
      ColorFace = clWhite
      ColorGrad = 10805759
      ColorLight = 36821
      ColorDark = 27035
      ColorScheme = csDesert
      FillDirection = fdVertical
      Align = alTop
      Caption = 'TIPO DI CONVERSIONE'
      TabOrder = 0
      UseDockManager = True
    end
    object pnlTipoConversioneCombo: TPanel
      Left = 2
      Top = 30
      Width = 396
      Height = 27
      Align = alClient
      TabOrder = 1
      object cmbTipoConversione: TComboBox
        Left = 126
        Top = 3
        Width = 145
        Height = 21
        Hint = 'Scegli qui per quale gioco convertire il file colonnare'
        Style = csDropDownList
        ItemIndex = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = 'Conversione Quiniela'
        OnChange = cmbTipoConversioneChange
        Items.Strings = (
          'Conversione Quiniela'
          'Conversione Svezia')
      end
    end
  end
  object pnlFileColo: TRzPanel
    Left = 72
    Top = 82
    Width = 400
    Height = 59
    Color = 16578030
    TabOrder = 1
    object pnlHeadPronColonnare: TXiPanel
      Left = 2
      Top = 2
      Width = 396
      Height = 28
      ColorFace = clWhite
      ColorGrad = 10805759
      ColorLight = 36821
      ColorDark = 27035
      ColorScheme = csDesert
      FillDirection = fdVertical
      Align = alTop
      Caption = 'FILE COLONNARE TOTOCALCIO 14  (SCH) DA CONVERTIRE A 15 (TXT)'
      TabOrder = 0
      UseDockManager = True
    end
    object Panel2: TPanel
      Left = 2
      Top = 30
      Width = 396
      Height = 27
      Align = alClient
      TabOrder = 1
      object edtFileColo: TJvFilenameEdit
        Left = 1
        Top = 1
        Width = 394
        Height = 25
        Hint = 'Scegli qui il file colonnare da convertire...'
        TextHint = 'Scegli qui il file colonnare da convertire...'
        Align = alClient
        DefaultExt = 'SCH'
        Flat = True
        ParentFlat = False
        Filter = 'File colonnari (*.sch)|*.sch'
        DialogTitle = 'Scegli il file da filtrare'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = ''
        OnChange = edtFileColoChange
        ExplicitHeight = 19
      end
    end
  end
  object btnEsegui: TButton
    Left = 188
    Top = 226
    Width = 169
    Height = 36
    Caption = 'Esegui conversione per Quiniela '
    TabOrder = 3
    OnClick = btnEseguiClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 286
    Width = 545
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'IN ATTESA DI ESEGUIRE CONVERSIONE...'
        Width = 50
      end>
  end
  object RzPanel1: TRzPanel
    Left = 72
    Top = 149
    Width = 400
    Height = 59
    Color = 16578030
    TabOrder = 2
    object XiPanel1: TXiPanel
      Left = 2
      Top = 2
      Width = 396
      Height = 28
      ColorFace = clWhite
      ColorGrad = 10805759
      ColorLight = 36821
      ColorDark = 27035
      ColorScheme = csDesert
      FillDirection = fdVertical
      Align = alTop
      Caption = 'PRONOSTICO 15MO RISULTATO'
      TabOrder = 0
      UseDockManager = True
    end
    object Panel1: TPanel
      Left = 2
      Top = 30
      Width = 396
      Height = 27
      Align = alClient
      TabOrder = 1
      object ComboBox2: TComboBox
        Left = 126
        Top = 3
        Width = 145
        Height = 21
        Hint = 'Scegli qui il pronostico della 15ma partita'
        Style = csDropDownList
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Items.Strings = (
          '0 - 0'
          '0 - 1'
          '0 - 2'
          '0 - M'
          '1 - 0'
          '1 - 1'
          '1 - 2'
          '1 - M'
          '2 - 0'
          '2 - 1'
          '2 - 2'
          '2 - M'
          'M - 0'
          'M - 1'
          'M - 2'
          'M - M')
      end
    end
  end
end
