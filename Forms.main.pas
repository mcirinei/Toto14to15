unit Forms.main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, XiPanel, RzShellDialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Mask, RzEdit, RzLabel,
  JvExMask,
  JvToolEdit, RzButton, RzRadChk, RzBorder, RzPanel, StopWatch,
  RzBckgnd, RzLstBox, Vcl.ComCtrls, RzTabs, Vcl.Grids, RzGrids;

const
  MaxCol = 250000;

type
  TColonnaNTP = packed record
    Len: byte;
    Col: array [1 .. 3] of cardinal;
    Col2: word;
  end;

  TNomeSquadra = string[12];
  TPartiteTotocalcio = packed array [1 .. 14, 1 .. 2] of TNomeSquadra;
  TPicchettoTotocalcio = packed array [1 .. 14, 1 .. 3] of byte;
  TColVincTotocalcio = packed array [1 .. 14] of byte;
  PDatiConcTotocalcio = ^TDatiConcTotocalcio;
  TPartiteTotocalcio2022 = packed array [1 .. 20, 1 .. 2] of TNomeSquadra;
  TPicchettoTotocalcio2022 = packed array [1 .. 20, 1 .. 3] of byte;

  TDatiConcTotocalcio = packed record
    Stagione: word;
    NumConcorso: word;
    Data: string[10];
    Montepremi: real48;
    Quota1: real48;
    Quota2: real48;
    Quota3: real48;
    Quota4: real48;
    PartiteOld: TPartiteTotocalcio;
    PercTecnicheOld: TPicchettoTotocalcio;
    PercGIocateOld: TPicchettoTotocalcio;
    Partite2022: TPartiteTotocalcio2022;
    PercTecniche2022: TPicchettoTotocalcio2022;
  end;

  TMain = class(TForm)
    pnlConcorso: TXiPanel;
    grdSchedina: TRzStringGrid;
    grdPosizioni: TRzStringGrid;
    pnlFileColo: TRzPanel;
    pnlHeadPronColonnare: TXiPanel;
    Panel2: TPanel;
    edtFileColo: TJvFilenameEdit;
    XiPanel2: TXiPanel;
    btnEsegui: TButton;
    StatusBar1: TStatusBar;
    grdBVS: TRzStringGrid;
    XiPanel1: TXiPanel;
    procedure FormShow(Sender: TObject);
    procedure grdPosizioniSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure edtFileColoChange(Sender: TObject);
    procedure btnEseguiClick(Sender: TObject);

  private
    NumColOK: Integer;
    procedure DoCaricaSchedina;
    procedure AggiornaUIAnalisi;
  public
    { Public declarations }
  protected
  end;

var
  main: TMain;

implementation

{$R *.dfm}

uses IOUtils, ShellAPi, BufferedFileStream, Units.TString, datamodules.main, System.DateUtils;

procedure TMain.AggiornaUIAnalisi;
var
  index: Integer;
begin
  for index := 1 to 20 do
  begin
    grdBVS.Cells[0, index] := dmmain.DatiAnalisi[index, 1].ToString;
    grdBVS.Cells[1, index] := dmmain.DatiAnalisi[index, 2].ToString;
    grdBVS.Cells[2, index] := dmmain.DatiAnalisi[index, 3].ToString;
  end;
end;

procedure TMain.btnEseguiClick(Sender: TObject);
var
  index: Integer;
begin
  // verifica che il file da convertire sia presente
  if FileExists(dmmain.NomeFileSCH) then
  else
    raise Exception.Create('Devi indicare un file colonnare da convertire valido');

  // verifica che le posizioni siano tutte correttamente inserite
  for index := 9 to 13 do
    if dmmain.Posizioni[index] in [9 .. 20] then
    else
      raise Exception.Create('Posizione non valida per la partita ' + index.ToString);
  // e poi esegue la conversione
  dmmain.ConvertiFileSCH(dmmain.NomeFileSCH);
  // e aggiorna la analisi colonne genrste
  AggiornaUIAnalisi;
  // aggiorna status
  StatusBar1.Panels[0].text := 'Creato il file ' + ExtractFilePath(dmmain.NomeFileSCH) + System.IOUtils.TPath.GetFileNameWithoutExtension
    (dmmain.NomeFileSCH) + '_2022.SCH, ' + dmmain.NumSchedine.ToString + ' schedine, ' + dmmain.numColSviluppo.ToString + ' colonne';
end;

procedure TMain.DoCaricaSchedina;
var
  F: file;
  fname: string;
  DatiConcTotocalcio: TDatiConcTotocalcio;
  index: Integer;
begin
  fname := dmmain.dataDir + '\happysoft\totopc\archivi\totocalc' + Yearof(today).ToString + '.set';
  if FileExists(fname) then
  begin
    AssignFile(F, fname);
    try
      Reset(F, 1);
      while not eof(F) do
        BlockRead(F, DatiConcTotocalcio, sizeof(TDatiConcTotocalcio));
    finally
      CloseFile(F);
    end;
    // popola a video la griglia della schedina
    for index := 1 to 20 do
    begin
      grdSchedina.Cells[0, index] := index.ToString;
      grdSchedina.Cells[1, index] := DatiConcTotocalcio.Partite2022[index, 1] + ' - ' + DatiConcTotocalcio.Partite2022[index, 2];
    end;
    // e poi l'intestazione
    pnlConcorso.Caption := 'CONCORSO NR. ' + DatiConcTotocalcio.NumConcorso.ToString + ' DEL ' + DatiConcTotocalcio.Data;
  end;
  // griglia posizioni
  for index := 0 to 4 do
    grdPosizioni.Cells[0, index] := (index + 9).ToString;

end;

procedure TMain.edtFileColoChange(Sender: TObject);
begin
  dmmain.NomeFileSCH := edtFileColo.FileName;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  //
  DoCaricaSchedina;

  //
  grdBVS.Cells[0, 0] := '1 %';
  grdBVS.Cells[1, 0] := 'X %';
  grdBVS.Cells[2, 0] := '2 %';
end;

procedure TMain.grdPosizioniSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
begin
  // verifico che il valore sia corretto
  if (Value >= '0') and (Value <= '9') then
  else if (trim(Value) <> '') then
    raise Exception.Create('Inserito valore numerico non valido');

  // aggiorno lo stato della applicazione e salvo il sistema
  dmmain.Posizioni[ARow + 9] := StrToIntDef(Value, 0);
end;

end.
