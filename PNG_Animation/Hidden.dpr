program Hidden;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  TangentThread in 'Externals\TangentThread\TangentThread.pas',
  pngimage in 'Externals\PNGLib\pngimage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Hidden';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
