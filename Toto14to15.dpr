program Toto14to15;

uses
  Vcl.Forms,
  Forms.main in 'Forms.main.pas' {Main},
  DM_HSApplication in '..\..\Common\DM_HSApplication.pas' {HSApplication: TDataModule},
  datamodules.main in 'datamodules.main.pas' {dmMain: TDataModule},
  Units.TString in '..\..\Common\Units.TString.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Toto14to15';
  TStyleManager.TrySetStyle('Windows11 Impressive Light');
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
