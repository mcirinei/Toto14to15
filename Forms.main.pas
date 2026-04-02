unit Forms.main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, XiPanel, RzShellDialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Mask, RzEdit, RzLabel,
  JvExMask, JvToolEdit, RzButton, RzRadChk, RzBorder, RzPanel, StopWatch,
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
    pnlFileColo: TRzPanel;
    pnlHeadPronColonnare: TXiPanel;
    Panel2: TPanel;
    edtFileColo: TJvFilenameEdit;
    btnEsegui: TButton;
    StatusBar1: TStatusBar;
    RzPanel1: TRzPanel;
    XiPanel1: TXiPanel;
    Panel1: TPanel;
    ComboBox2: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure edtFileColoChange(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure btnEseguiClick(Sender: TObject);

  private
  public
    { Public declarations }
  protected
  end;

var
  main: TMain;

implementation

{$R *.dfm}

uses IOUtils, ShellAPi, Units.TString, datamodules.main, System.DateUtils;


procedure TMain.btnEseguiClick(Sender: TObject);
var
  index: Integer;
begin
  // verifica che il file da convertire sia presente
  if FileExists(dmmain.NomeFileSCH) then
  else
    raise Exception.Create('Devi indicare un file colonnare da convertire valido');

  // verifica che le posizioni siano tutte correttamente inserite
  if ComboBox2.itemindex in [0..15] then
    else
      raise Exception.Create('15mo pronostico non valido: imposta uno dei pronostici possibili per la partita');

  // e poi esegue la conversione
  if dmmain.ConvertiFileSCH(dmmain.NomeFileSCH, ComboBox2.itemindex) then
  // aggiorna status
  StatusBar1.Panels[0].text := 'Creato file in Documenti\HappySoft "' + System.IOUtils.TPath.GetFileNameWithoutExtension
    (dmmain.NomeFileSCH) + '_QUINIELA.TXT", con ' + dmmain.NumColonne.ToString + ' colonne !';
end;


procedure TMain.ComboBox1Change(Sender: TObject);
begin
  dmmain.FRisultato15 := TComboBox(Sender).ItemIndex+1;
end;


procedure TMain.edtFileColoChange(Sender: TObject);
begin
  dmmain.NomeFileSCH := edtFileColo.FileName;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  //inizializzo alla dir documenti
  edtFileColo.InitialDir := TPath.GetDocumentsPath+'\HappySoft\TotoPC\Sistemi\Totocalcio\Condizionati_Ridotti';
end;

end.
