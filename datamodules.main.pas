unit datamodules.main;

interface

uses
  System.SysUtils, System.Classes, DM_HSApplication, IdComponent, Vcl.ExtCtrls, IdMessage, IdMessageClient, IdSMTPBase, IdSMTP, IdExplicitTLSClientServerBase, IdFTP,
  IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdUDPBase, IdUDPClient, IdSNTP,
  RzShellDialogs, Vcl.Dialogs, RzGrids;



const
  FIDMaskFileSCH_Tot = 14;

type
  TDatiOpzioniApp = record
    PrefissoFileGen, PrefissoFileComuni, PathGen: string;
  end;

  TPosizioni = array [9 .. 13] of integer;

  TColSCH = packed array [1 .. 3] of Word;
  TColSCH2022 = packed array [1 .. 3] of Integer;


  TdmMain = class(THSApplication)
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure AggiornaAnalisi(aColoSCH: TColSCH2022);

    { Private declarations }
  public
    DatiOpzioniApp: TDatiOpzioniApp;

    Posizioni: TPosizioni;

    DatiAnalisi: array [1..20, 1..3] of integer;
    numColSviluppo, NumSchedine: integer;

    NomeFileSCH: string;

    procedure CaricaConfigurazione; override;
    procedure SalvaConfigurazione; override;

    procedure ConvertiFileSCH(nomefileSCH: string);


  end;

var
  dmMain: TdmMain;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}


uses System.IniFiles, System.IOUtils;



procedure Tdmmain.AggiornaAnalisi(aColoSCH: TColSCH2022);
var
  index: integer;
begin
  for index := 0 to 19 do begin
    if (aColoSCH[1] and (1 shl index))>0 then Inc(DatiAnalisi[index+1,1]);
    if (aColoSCH[2] and (1 shl index))>0 then Inc(DatiAnalisi[index+1,2]);
    if (aColoSCH[3] and (1 shl index))>0 then Inc(DatiAnalisi[index+1,3]);
  end;
end;


procedure TdmMain.ConvertiFileSCH(nomefileSCH: string);
var
  index, indexSeg: integer;
  LPos: integer;
  LFooter: Word;

  FileSch14, FileSch2022: file;
  ColSCH: TCOlSch;
  ColSCH2022: TCOlSch2022;

begin
  // inizializza il file sch da leggere
  AssignFile(FileSch14, nomefileSCH);
  Reset(FileSch14, 1);
  //ed il file da scrivere
  AssignFile(FileSch2022, ExtractFilePath(nomefileSCH)+System.IOUtils.TPath.GetFileNameWithoutExtension(nomefileSCH)+'_2022.sch');
  Rewrite(FileSch2022, 1);
  //resetta i dati analisi
  FillChar(DatiAnalisi, Sizeof(DatiAnalisi), 0);
  NumSchedine := 0;

  //converte le colonne una ad una
  repeat
      BlockRead(Filesch14, ColSCH, Sizeof(ColSch));
      //copia pari pari i primi 8 segni
      for indexSeg := 1 to 3 do
        ColSCH2022[indexSeg] := ColSCH[indexSeg] and 255;
      //e assegna gli altri 5 in base alla tabella delle posizioni
      for index := 9 to 13 do begin
        LPos := Posizioni[index];
        for indexSeg := 1 to 3 do
          if ColSCH[indexSeg] and (1 shl (index-1))<>0 then
            ColSCH2022[indexSeg] := ColSCH2022[indexSeg] or (1 shl (LPos-1))
      end;
      //infine salva la colonna sul nuovo file 2022
      BlockWrite(FileSch2022, ColSCH2022, Sizeof(ColSCH2022));
      //e aggiorna la analisi dei segni
      AggiornaAnalisi(ColSCH2022);
      Inc(NumSchedine);
  until FilePos(FileSCH14)=(FileSize(FileSch14)-6);

  //e copia il footer sul nuovo file 2022
  BlockRead(Filesch14, numColSviluppo, Sizeof(numColSviluppo));
  BlockWrite(FileSch2022, numColSviluppo, 4);
  BlockRead(Filesch14, LFooter, Sizeof(LFooter));
  BlockWrite(FileSch2022, LFooter, 2);
  // poi chiude infine i due files
  CloseFile(Filesch14);
  CloseFile(FileSch2022);
end;




procedure TdmMain.CaricaConfigurazione;
var
  IniFile: TIniFile;
  iLine: integer;
  tmpStr: string;
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
end;




procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  inherited;

  // imposta nome e copyright
  AppName := 'Toto14Magic';
  RigaCopyright := ' - (c) 2022 HappySoft (r) Srl';

  //azzera le posizioni
  FillChar(Posizioni, Sizeof(Posizioni), 0);

  // gestione paths
  DataPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, 'happysoft\' + AppName + '\');
  DocsPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'happysoft\' + AppName + '\');

  CaricaConfigurazione;
end;





procedure TdmMain.SalvaConfigurazione;
var
  IniFile: TIniFile;
  index: integer;
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
