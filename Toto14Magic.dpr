program Toto14Magic;

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
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
