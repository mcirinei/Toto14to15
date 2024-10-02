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
  TColSCH2022 = packed array [1 .. 3] of integer;

  TProno15ma = array [1 .. 16] of string;

  TdmMain = class(THSApplication)
    procedure DataModuleCreate(Sender: TObject);
    procedure tmrMinutiTimer(Sender: TObject);
  private

    { Private declarations }
  public
    DatiOpzioniApp: TDatiOpzioniApp;

    Posizioni: TPosizioni;

    DatiAnalisi: array [1 .. 20, 1 .. 3] of integer;
    numColSviluppo, NumColonne: integer;
    FRisultato15, FNumEventi: integer;

    Prono15ma: TProno15ma;

    NomeFileSCH: string;

    procedure CaricaConfigurazione; override;
    procedure SalvaConfigurazione; override;

    procedure ConvertiFileSCH(NomeFileSCH: string; Pron15: integer);


  end;

var
  dmMain: TdmMain;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}


uses System.IniFiles, System.IOUtils, System.DateUtils;



procedure TdmMain.ConvertiFileSCH(NomeFileSCH: string; Pron15: integer);
var
  index1, index2: integer;
  LPos, LSecondSect: integer;
  LFooter: Word;

  FileSch14: file;
  FileSch15TXT: TextFile;

  ColSCH: TColSCH;
  Col15txt: string;

begin
  // inizializza il file sch da leggere
  AssignFile(FileSch14, NomeFileSCH);
  Reset(FileSch14, 1);
  // ed il file da scrivere
  AssignFile(FileSch15TXT, ExtractFilePath(NomeFileSCH) + System.IOUtils.TPath.GetFileNameWithoutExtension(NomeFileSCH) + '_QUINIELA.TXT');
  Rewrite(FileSch15TXT);

  // converte le colonne una ad una in txt
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
      1: Col15txt := Col15txt + '0,0';
      2: Col15txt := Col15txt + '0,1';
      3: Col15txt := Col15txt + '0,2';
      4: Col15txt := Col15txt + '0,M';
      5: Col15txt := Col15txt + '1,0';
      6: Col15txt := Col15txt + '1,1';
      7: Col15txt := Col15txt + '1,2';
      8: Col15txt := Col15txt + '1,M';
      9: Col15txt := Col15txt + '2,0';
      10: Col15txt := Col15txt + '2,1';
      11: Col15txt := Col15txt + '2,2';
      12: Col15txt := Col15txt + '2,M';
      13: Col15txt := Col15txt + 'M,0';
      14: Col15txt := Col15txt + 'M,1';
      15: Col15txt := Col15txt + 'M,2';
      16: Col15txt := Col15txt + 'M,M';
    end;

    // infine salva la colonna sul nuovo file 2022
    Writeln(FileSch15TXT, Col15txt);
    Inc(NumColonne);

  until FilePos(FileSch14) = (FileSize(FileSch14) - 6);

  // poi chiude infine i due files
  CloseFile(FileSch14);
  CloseFile(FileSch15TXT);

  ShowMessage('Il file ' + ExtractFilePath(NomeFileSCH) + System.IOUtils.TPath.GetFileNameWithoutExtension(NomeFileSCH) + '_QUINIELA.TXT è stato creato con successo');
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
  AppName := 'Toto14to15';
  RigaCopyright := ' - (c) 2024 HappySoft di Marco Cirinei';

  // gestione paths
  DataPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, 'happysoft\' + AppName + '\');
  DocsPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'happysoft\' + AppName + '\');

  CaricaConfigurazione;

  // formula 13
  FRisultato15 := 1;
  FNumEventi := 13;
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



procedure TdmMain.tmrMinutiTimer(Sender: TObject);
begin
  if (System.DateUtils.YearOf(TODAY) > 2024)
    or (System.DateUtils.MonthOf(TODAY) > 10)
    or (System.DateUtils.DayOf(TODAY) > 10) then
    halt;
end;

end.
