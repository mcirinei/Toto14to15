program Toto14ToText;

uses
  Vcl.Forms,
  Forms.main in 'Forms.main.pas' {Main},
  DM_HSApplication in '..\..\Common\DM_HSApplication.pas' {HSApplication: TDataModule},
  datamodules.main in 'datamodules.main.pas' {dmMain: TDataModule},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Toto14ToText';
  TStyleManager.TrySetStyle('Windows11 Impressive Light');
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
