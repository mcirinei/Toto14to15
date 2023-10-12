object Main: TMain
  Tag = 1
  Left = 0
  Top = 0
  Caption = 
    'Toto14Magic 1.0 - (c) 2022 HappySoft  Srl - Tutti i diritti rise' +
    'rvati'
  ClientHeight = 476
  ClientWidth = 771
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlConcorso: TXiPanel
    Left = 8
    Top = 8
    Width = 238
    Height = 30
    ColorFace = clWhite
    ColorGrad = 10805759
    ColorLight = 36821
    ColorDark = 27035
    ColorScheme = csDesert
    FillDirection = fdVertical
    TabOrder = 0
    UseDockManager = True
  end
  object grdSchedina: TRzStringGrid
    Left = 8
    Top = 43
    Width = 238
    Height = 408
    ColCount = 2
    RowCount = 21
    TabOrder = 1
    ColWidths = (
      30
      200)
    RowHeights = (
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18)
  end
  object grdPosizioni: TRzStringGrid
    Left = 530
    Top = 110
    Width = 46
    Height = 101
    ColCount = 2
    DefaultColWidth = 20
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs]
    TabOrder = 2
    OnSetEditText = grdPosizioniSetEditText
    RowHeights = (
      18
      18
      18
      18
      18)
  end
  object pnlFileColo: TRzPanel
    Left = 361
    Top = 7
    Width = 400
    Height = 59
    TabOrder = 3
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
      Caption = 'FILE COLONNARE DA IMPORTARE'
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
        TextHint = 'Scegli qui il file colonnare da filtrare'
        Align = alClient
        Filter = 'File colonnari (*.sch)|*.sch'
        DialogTitle = 'Scegli il file da filtrare'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = ''
        OnChange = edtFileColoChange
        ExplicitHeight = 21
      end
    end
  end
  object XiPanel2: TXiPanel
    Left = 364
    Top = 81
    Width = 397
    Height = 28
    ColorFace = clWhite
    ColorGrad = 10805759
    ColorLight = 36821
    ColorDark = 27035
    ColorScheme = csDesert
    FillDirection = fdVertical
    Caption = 'POSIZIONI DI DESTINAZIONE DELLE PARTITE DALLA 9 ALLA 13'
    TabOrder = 4
    UseDockManager = True
  end
  object btnEsegui: TButton
    Left = 620
    Top = 415
    Width = 143
    Height = 36
    Caption = 'Esegui conversione'
    TabOrder = 5
    OnClick = btnEseguiClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 457
    Width = 771
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'IN ATTESA DI ESEGUIRE CONVERSIONE...'
        Width = 50
      end>
  end
  object grdBVS: TRzStringGrid
    Left = 253
    Top = 42
    Width = 88
    Height = 409
    ColCount = 3
    DefaultColWidth = 26
    FixedCols = 0
    RowCount = 21
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs]
    TabOrder = 7
    RowHeights = (
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18)
  end
  object XiPanel1: TXiPanel
    Left = 252
    Top = 8
    Width = 89
    Height = 30
    ColorFace = clWhite
    ColorGrad = 10805759
    ColorLight = 36821
    ColorDark = 27035
    ColorScheme = csDesert
    FillDirection = fdVertical
    Caption = 'DISTRIB. SEGNI'
    TabOrder = 8
    UseDockManager = True
  end
  object ComboBox1: TComboBox
    Left = 361
    Top = 422
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 9
    Text = 'Formula Il 13'
    OnChange = ComboBox1Change
    Items.Strings = (
      'Formula Il 13'
      'Formula 11')
  end
end
