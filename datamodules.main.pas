unit datamodules.main;

interface

uses
  System.SysUtils, System.Classes, DM_HSApplication, IdComponent, Vcl.ExtCtrls, IdMessage, IdMessageClient, IdSMTPBase, IdSMTP, IdExplicitTLSClientServerBase, IdFTP,
  IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdUDPBase, IdUDPClient, IdSNTP,
  RzShellDialogs, Vcl.Dialogs, RzGrids, IdCTypes, IdSSLOpenSSLHeaders;



const
  // totocalcio svedese: partite, intestazione dei file e limiti
  cNumPartiteSvezia = 13;
  cIntestazioneSvezia = ''; // default dell'INI: vuoto = nessuna riga di intestazione (es. Stryktipset)
  cMaxColonneSvezia = 20000; // default dell'INI
  cMaxRigheESvezia = 2200; // default dell'INI
  cMaxRigheMSvezia = 950; // default dell'INI

type
  TDatiOpzioniApp = record
    PrefissoFileGen, PrefissoFileComuni, PathGen: string;
    // limiti delle righe di ciascun file E ed M, modificabili a mano nell'INI
    MaxRigheESvezia, MaxRigheMSvezia: integer;
    // massimo di colonne (corone) da giocare in tutto, modificabile a mano nell'INI
    MaxColonneSvezia: integer;
    // nome del gioco da scrivere come prima riga dei file E ed M (vuoto = nessuna intestazione)
    IntestazioneSvezia: string;
  end;

  TColSCH = packed array [1 .. 3] of Word;

  TdmMain = class(THSApplication)
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure CaricaLimitiSvezia;
    procedure ScriviFileSvezia(const aNomeFile: string; aRighe: TStringList);
    { Private declarations }
  public
    DatiOpzioniApp: TDatiOpzioniApp;

    NumColonne: integer;
    NomeFileSCH: string;

    // esito dell'ultima conversione per la Svezia
    NumRigheE, NumRigheM: integer;
    NumColonneSvezia: Int64;

    procedure CaricaConfigurazione; override;
    procedure SalvaConfigurazione; override;
    function ConvertiFileSCH(NomeFileSCH: string; Pron15: integer): boolean;
    function ConvertiFileSCHSvezia(const NomeFileSCH: string): boolean;
    function NomeFileIniSvezia: string;

  end;

var
  dmMain: TdmMain;

// numero seguito dalla parola al singolare o al plurale (1 riga, 2 righe)
function Plurale(aNumero: integer; const aSingolare, aPlurale: string): string;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}


uses System.IniFiles, System.IOUtils;



function Plurale(aNumero: integer; const aSingolare, aPlurale: string): string;
begin
  if aNumero = 1 then
    result := '1 ' + aSingolare
  else
    result := aNumero.ToString + ' ' + aPlurale;
end;



function TdmMain.ConvertiFileSCH(NomeFileSCH: string; Pron15: integer): boolean;
var
  index1, index2: integer;

  FileSch14: file;
  FileSch15TXT: TextFile;

  ColSCH: TColSCH;
  Col15txt: string;

begin
  // inizializza il file sch da leggere
  AssignFile(FileSch14, NomeFileSCH);
  Reset(FileSch14, 1);
  try
    // ed il file da scrivere
    AssignFile(FileSch15TXT, ExtractFilePath(NomeFileSCH) + System.IOUtils.TPath.GetFileNameWithoutExtension(NomeFileSCH) + '_QUINIELA.TXT');
    Rewrite(FileSch15TXT);
    try
      // converte le colonne una ad una in txt
      NumColonne := 0;
      repeat

        BlockRead(FileSch14, ColSCH, Sizeof(ColSCH));

        Col15txt := '';
        // prima copia pari pari i 14 segni sul file 15txt
        for index1 := 0 to 13 do
        begin
          for index2 := 1 to 3 do
            if (ColSCH[index2] and (1 shl index1) <> 0) then
            begin
              case index2 of
                1: Col15txt := Col15txt + '1,';
                2: Col15txt := Col15txt + 'X,';
                3: Col15txt := Col15txt + '2,';
              end;
              break;
            end;
        end;
        // poi aggiunge il risultato 15
        case Pron15 of
          0: Col15txt := Col15txt + '0,0';
          1: Col15txt := Col15txt + '0,1';
          2: Col15txt := Col15txt + '0,2';
          3: Col15txt := Col15txt + '0,M';
          4: Col15txt := Col15txt + '1,0';
          5: Col15txt := Col15txt + '1,1';
          6: Col15txt := Col15txt + '1,2';
          7: Col15txt := Col15txt + '1,M';
          8: Col15txt := Col15txt + '2,0';
          9 : Col15txt := Col15txt + '2,1';
          10: Col15txt := Col15txt + '2,2';
          11: Col15txt := Col15txt + '2,M';
          12: Col15txt := Col15txt + 'M,0';
          13: Col15txt := Col15txt + 'M,1';
          14: Col15txt := Col15txt + 'M,2';
          15: Col15txt := Col15txt + 'M,M';
        end;

        // infine salva la colonna sul nuovo file 2022
        Writeln(FileSch15TXT, Col15txt);
        Inc(NumColonne);

      until FilePos(FileSch14) = (FileSize(FileSch14) - 6);
    finally
      CloseFile(FileSch15TXT);
    end;
  finally
    CloseFile(FileSch14);
  end;

  //se tutto ok allora conferma esito positivo
  ShowMessage('Il file ' + System.IOUtils.TPath.GetFileNameWithoutExtension(NomeFileSCH) + '_QUINIELA.TXT,'#13#10+
  'con '+numcolonne.ToString +' colonne, è stato creato con successo');
  Result := TRUE;
end;



function TdmMain.ConvertiFileSCHSvezia(const NomeFileSCH: string): boolean;
const
  cSegni: array [1 .. 3] of char = ('1', 'X', '2');
var
  LPartita, LSegno, LNumColonnaSCH, LComb: integer;
  LGruppo, LRiga, LFileE, LFileM, LErrori, LCancellati, LEsito, LNotaIni: string;

  FileSch14: file;
  ColSCH: TColSCH;

  LRigheE, LRigheM: TStringList;

begin
  NumRigheE := 0;
  NumRigheM := 0;
  NumColonneSvezia := 0;

  // i due file di testo hanno il nome dello sch originale piu' -E / -M
  LFileE := ExtractFilePath(NomeFileSCH) + System.IOUtils.TPath.GetFileNameWithoutExtension(NomeFileSCH) + '-E.txt';
  LFileM := ExtractFilePath(NomeFileSCH) + System.IOUtils.TPath.GetFileNameWithoutExtension(NomeFileSCH) + '-M.txt';

  LRigheE := TStringList.Create;
  LRigheM := TStringList.Create;
  try
    // 1) legge le colonne sch e le traduce in righe E (colonne singole) ed M (sistemini)
    AssignFile(FileSch14, NomeFileSCH);
    Reset(FileSch14, 1);
    try
      LNumColonnaSCH := 0;
      repeat

        BlockRead(FileSch14, ColSCH, Sizeof(ColSCH));
        Inc(LNumColonnaSCH);

        LRiga := '';
        LComb := 1;
        // solo le prime 13 partite (bit 0..12), la 14ma nel totocalcio svedese non c'e'
        for LPartita := 0 to cNumPartiteSvezia - 1 do
        begin
          // raccoglie tutti i segni della partita, sempre nell'ordine 1 X 2
          LGruppo := '';
          for LSegno := 1 to 3 do
            if (ColSCH[LSegno] and (1 shl LPartita) <> 0) then
              LGruppo := LGruppo + cSegni[LSegno];
          if LGruppo = '' then
            raise Exception.CreateFmt('La colonna %d del file SCH non ha nessun segno sulla partita %d: conversione annullata',
              [LNumColonnaSCH, LPartita + 1]);
          LComb := LComb * Length(LGruppo);
          LRiga := LRiga + ',' + LGruppo;
        end;

        // conta sempre righe e colonne, cosi' il messaggio sui limiti riporta i totali veri
        if LComb = 1 then
          Inc(NumRigheE)
        else
          Inc(NumRigheM);
        NumColonneSvezia := NumColonneSvezia + LComb;

        // ma tiene in memoria le righe solo finche' il massimo di colonne non e' superato
        if NumColonneSvezia <= DatiOpzioniApp.MaxColonneSvezia then
        begin
          if LComb = 1 then
            LRigheE.Add('E' + LRiga)
          else
            LRigheM.Add('M' + LComb.ToString + LRiga);
        end;

      until FilePos(FileSch14) = (FileSize(FileSch14) - 6);
    finally
      CloseFile(FileSch14);
    end;

    // 2) controlla i limiti: se anche uno solo non e' rispettato non scrive nessun file
    LErrori := '';
    LNotaIni := '';
    if NumColonneSvezia > DatiOpzioniApp.MaxColonneSvezia then
      LErrori := LErrori + '- colonne totali da giocare: ' + FormatFloat('#,##0', NumColonneSvezia) +
        ' (massimo ' + FormatFloat('#,##0', DatiOpzioniApp.MaxColonneSvezia) + ')' + sLineBreak;
    // limiti delle righe di ciascun file (default: quelli del gioco di gruppo di Svenska Spel)
    if NumRigheE > DatiOpzioniApp.MaxRigheESvezia then
      LErrori := LErrori + '- righe del file E: ' + FormatFloat('#,##0', NumRigheE) +
        ' (massimo ' + FormatFloat('#,##0', DatiOpzioniApp.MaxRigheESvezia) + ')' + sLineBreak;
    if NumRigheM > DatiOpzioniApp.MaxRigheMSvezia then
      LErrori := LErrori + '- righe del file M: ' + FormatFloat('#,##0', NumRigheM) +
        ' (massimo ' + FormatFloat('#,##0', DatiOpzioniApp.MaxRigheMSvezia) + ')' + sLineBreak;
    // tutti i limiti si modificano a mano nell'INI
    if LErrori <> '' then
      LNotaIni := sLineBreak + 'I limiti si modificano nel file:' + sLineBreak + NomeFileIniSvezia;
    if LErrori <> '' then
      raise Exception.Create('Il file non può essere convertito per la Svezia:' + sLineBreak + sLineBreak + LErrori + LNotaIni);

    // 3) scrive i file; quello che non serve viene tolto, se rimasto da una conversione precedente
    LCancellati := '';
    if NumRigheE > 0 then
      ScriviFileSvezia(LFileE, LRigheE)
    else if FileExists(LFileE) and System.SysUtils.DeleteFile(LFileE) then
      LCancellati := LCancellati + sLineBreak + 'Cancellato il vecchio file ' + ExtractFileName(LFileE);
    if NumRigheM > 0 then
      ScriviFileSvezia(LFileM, LRigheM)
    else if FileExists(LFileM) and System.SysUtils.DeleteFile(LFileM) then
      LCancellati := LCancellati + sLineBreak + 'Cancellato il vecchio file ' + ExtractFileName(LFileM);
  finally
    LRigheE.Free;
    LRigheM.Free;
  end;

  //se tutto ok allora conferma esito positivo
  LEsito := '';
  if NumRigheE > 0 then
    LEsito := LEsito + 'Il file ' + ExtractFileName(LFileE) + ', con ' + Plurale(NumRigheE, 'colonna singola', 'colonne singole') + ', è stato creato con successo' + sLineBreak;
  if NumRigheM > 0 then
    LEsito := LEsito + 'Il file ' + ExtractFileName(LFileM) + ', con ' + Plurale(NumRigheM, 'sistemino', 'sistemini') + ', è stato creato con successo' + sLineBreak;
  ShowMessage(LEsito + 'Colonne totali da giocare: ' + NumColonneSvezia.ToString + LCancellati);
  Result := TRUE;
end;



procedure TdmMain.ScriviFileSvezia(const aNomeFile: string; aRighe: TStringList);
begin
  // prima riga con il nome del gioco, se prevista
  if DatiOpzioniApp.IntestazioneSvezia <> '' then
    aRighe.Insert(0, DatiOpzioniApp.IntestazioneSvezia);
  // testo semplice, senza BOM, righe terminate da CR+LF
  aRighe.WriteBOM := FALSE;
  aRighe.SaveToFile(aNomeFile, TEncoding.ASCII);
end;



function TdmMain.NomeFileIniSvezia: string;
begin
  // INI dei limiti Svezia nella cartella del programma, per modificarlo a mano facilmente
  result := ExtractFilePath(ParamStr(0)) + AppName + '.ini';
end;



procedure TdmMain.CaricaLimitiSvezia;
var
  IniFile: TIniFile;
begin
  // limiti e nome del gioco per i file della Svezia, dall'INI nella cartella del programma
  DatiOpzioniApp.MaxRigheESvezia := cMaxRigheESvezia;
  DatiOpzioniApp.MaxRigheMSvezia := cMaxRigheMSvezia;
  DatiOpzioniApp.MaxColonneSvezia := cMaxColonneSvezia;
  DatiOpzioniApp.IntestazioneSvezia := cIntestazioneSvezia;
  try
    IniFile := TIniFile.Create(NomeFileIniSvezia);
    try
      DatiOpzioniApp.MaxRigheESvezia := IniFile.ReadInteger('Svezia', 'MaxRigheE', cMaxRigheESvezia);
      DatiOpzioniApp.MaxRigheMSvezia := IniFile.ReadInteger('Svezia', 'MaxRigheM', cMaxRigheMSvezia);
      DatiOpzioniApp.MaxColonneSvezia := IniFile.ReadInteger('Svezia', 'MaxColonne', cMaxColonneSvezia);
      DatiOpzioniApp.IntestazioneSvezia := Trim(IniFile.ReadString('Svezia', 'NomeGioco', cIntestazioneSvezia));

      // se le chiavi mancano le scrive con i default, cosi' il file e' pronto da modificare a mano
      try
        if not IniFile.ValueExists('Svezia', 'MaxRigheE') then
          IniFile.WriteInteger('Svezia', 'MaxRigheE', cMaxRigheESvezia);
        if not IniFile.ValueExists('Svezia', 'MaxRigheM') then
          IniFile.WriteInteger('Svezia', 'MaxRigheM', cMaxRigheMSvezia);
        if not IniFile.ValueExists('Svezia', 'MaxColonne') then
          IniFile.WriteInteger('Svezia', 'MaxColonne', cMaxColonneSvezia);
        if not IniFile.ValueExists('Svezia', 'NomeGioco') then
          IniFile.WriteString('Svezia', 'NomeGioco', cIntestazioneSvezia);
      except
        on E: Exception do
          HappyLog(tlWarn, 'Impossibile scrivere i limiti Svezia di default in ' + NomeFileIniSvezia + ': ' + E.Message, NIL);
      end;
    finally
      IniFile.Free;
    end;
  except
    on E: Exception do
        HappyLog(tlWarn, 'Errore leggendo i limiti Svezia da ' + NomeFileIniSvezia + ': ' + E.Message, NIL);
  end;

  // valori non validi: si torna ai default
  if DatiOpzioniApp.MaxRigheESvezia <= 0 then
  begin
    HappyLog(tlWarn, 'MaxRigheE non valido nel file .ini, uso il default ' + IntToStr(cMaxRigheESvezia), NIL);
    DatiOpzioniApp.MaxRigheESvezia := cMaxRigheESvezia;
  end;
  if DatiOpzioniApp.MaxRigheMSvezia <= 0 then
  begin
    HappyLog(tlWarn, 'MaxRigheM non valido nel file .ini, uso il default ' + IntToStr(cMaxRigheMSvezia), NIL);
    DatiOpzioniApp.MaxRigheMSvezia := cMaxRigheMSvezia;
  end;
  if DatiOpzioniApp.MaxColonneSvezia <= 0 then
  begin
    HappyLog(tlWarn, 'MaxColonne non valido nel file .ini, uso il default ' + IntToStr(cMaxColonneSvezia), NIL);
    DatiOpzioniApp.MaxColonneSvezia := cMaxColonneSvezia;
  end;
end;



procedure TdmMain.CaricaConfigurazione;
var
  IniFile: TIniFile;
begin
  inherited;
  IniFile := TIniFile.Create(DataPath + AppName + '.ini');
  try
    try
      DatiOpzioniApp.PathGen := IniFile.ReadString('Main', 'PathGen', 'c:\');
      HappyLog(tlinfo, 'Caricata la configurazione dal file .ini', NIL);
    except
      on E: Exception do
          HappyLog(tlWarn, 'Errore caricando la configurazione dal file .ini', NIL);
    end;
  finally
      IniFile.Free;
  end;

  // limiti dei file per la Svezia, dall'INI nella cartella del programma
  CaricaLimitiSvezia;
end;



procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  inherited;

  // imposta nome e copyright
  AppName := 'Toto14ToText';
  RigaCopyright := ' - (c) 2024-2026 HappySoft di Marco Cirinei';

  // gestione paths
  DataPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, 'happysoft\' + AppName + '\');
  DocsPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'happysoft\' + AppName + '\');

  CaricaConfigurazione;
end;



procedure TdmMain.SalvaConfigurazione;
var
  IniFile: TIniFile;
begin
  inherited;
  IniFile := TIniFile.Create(DataPath + AppName + '.ini');
  try
    try
        IniFile.WriteString('Main', 'PathGen', DatiOpzioniApp.PathGen);
    except
      on E: Exception do
          HappyLog(tlWarn, 'Errore salvando la configurazione sul file .ini: ', NIL);
    end;
  finally
      IniFile.Free;
  end;
  {$IFDEF Debug}
  HappyLog(tlinfo, 'Salvata la configurazione sul file .ini', NIL);
  {$ENDIF Debug}
end;

end.
