unit Forms.main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, XiPanel, JvToolEdit, RzPanel;

type
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
    pnlTipoConversione: TRzPanel;
    pnlHeadTipoConversione: TXiPanel;
    pnlTipoConversioneCombo: TPanel;
    cmbTipoConversione: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure edtFileColoChange(Sender: TObject);
    procedure btnEseguiClick(Sender: TObject);
    procedure cmbTipoConversioneChange(Sender: TObject);

  private
    procedure AggiornaModalita;
  public
    { Public declarations }
  protected
  end;

var
  main: TMain;

implementation

{$R *.dfm}

uses IOUtils, datamodules.main;

const
  // voci della combo del tipo di conversione
  cConversioneQuiniela = 0;
  cConversioneSvezia = 1;


procedure TMain.AggiornaModalita;
var
  LSvezia: boolean;
begin
  LSvezia := cmbTipoConversione.ItemIndex = cConversioneSvezia;

  // il pronostico del 15mo serve solo alla Quiniela
  RzPanel1.Enabled := not LSvezia;
  ComboBox2.Enabled := not LSvezia;

  if LSvezia then
  begin
    pnlHeadPronColonnare.Caption := 'FILE COLONNARE TOTOCALCIO (SCH) DA CONVERTIRE PER SVEZIA (TXT)';
    btnEsegui.Caption := 'Esegui conversione per Svezia';
  end
  else
  begin
    pnlHeadPronColonnare.Caption := 'FILE COLONNARE TOTOCALCIO 14  (SCH) DA CONVERTIRE A 15 (TXT)';
    btnEsegui.Caption := 'Esegui conversione per Quiniela ';
  end;

  StatusBar1.Panels[0].Text := 'IN ATTESA DI ESEGUIRE CONVERSIONE...';
end;


procedure TMain.btnEseguiClick(Sender: TObject);
var
  LNome, LFiles: string;
begin
  // verifica che il file da convertire sia presente
  if FileExists(dmmain.NomeFileSCH) then
  else
    raise Exception.Create('Devi indicare un file colonnare da convertire valido');

  // conversione per il totocalcio svedese: file E (colonne singole) ed M (sistemini)
  if cmbTipoConversione.ItemIndex = cConversioneSvezia then
  begin
    if dmmain.ConvertiFileSCHSvezia(dmmain.NomeFileSCH) then
    begin
      LNome := System.IOUtils.TPath.GetFileNameWithoutExtension(dmmain.NomeFileSCH);
      LFiles := '';
      if dmmain.NumRigheE > 0 then
        LFiles := '"' + LNome + '-E.txt" (' + Plurale(dmmain.NumRigheE, 'riga', 'righe') + ')';
      if dmmain.NumRigheM > 0 then
      begin
        if LFiles <> '' then
          LFiles := LFiles + ' e ';
        LFiles := LFiles + '"' + LNome + '-M.txt" (' + Plurale(dmmain.NumRigheM, 'riga', 'righe') + ')';
      end;
      StatusBar1.Panels[0].Text := 'Creato ' + LFiles + ', ' + Plurale(integer(dmmain.NumColonneSvezia), 'colonna', 'colonne') + ' in tutto !';
    end;
    exit;
  end;

  // verifica che le posizioni siano tutte correttamente inserite
  if ComboBox2.itemindex in [0..15] then
    else
      raise Exception.Create('15mo pronostico non valido: imposta uno dei pronostici possibili per la partita');

  // e poi esegue la conversione
  if dmmain.ConvertiFileSCH(dmmain.NomeFileSCH, ComboBox2.itemindex) then
  // aggiorna status
  StatusBar1.Panels[0].text := 'Creato file "' + System.IOUtils.TPath.GetFileNameWithoutExtension
    (dmmain.NomeFileSCH) + '_QUINIELA.TXT" nella cartella del file SCH, con ' + dmmain.NumColonne.ToString + ' colonne !';
end;


procedure TMain.cmbTipoConversioneChange(Sender: TObject);
begin
  AggiornaModalita;
end;


procedure TMain.edtFileColoChange(Sender: TObject);
begin
  dmmain.NomeFileSCH := edtFileColo.FileName;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  //inizializzo alla dir documenti
  edtFileColo.InitialDir := TPath.GetDocumentsPath+'\HappySoft\TotoPC\Sistemi\Totocalcio\Condizionati_Ridotti';

  // allinea pannelli e bottone al tipo di conversione scelto
  AggiornaModalita;
end;

end.
