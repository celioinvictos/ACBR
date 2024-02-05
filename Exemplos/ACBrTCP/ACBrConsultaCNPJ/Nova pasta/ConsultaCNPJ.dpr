program ConsultaCNPJ;

uses
  Vcl.Forms,
  uConsultaCNPJ in 'uConsultaCNPJ.pas' {frmConsulta};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmConsulta, frmConsulta);
  Application.Run;
end.
