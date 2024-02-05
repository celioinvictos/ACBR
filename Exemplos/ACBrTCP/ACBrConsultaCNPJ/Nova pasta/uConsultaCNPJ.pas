unit uConsultaCNPJ;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.OleCtrls, SHDocVw,
  WebView2, Winapi.ActiveX, Vcl.Edge, Vcl.ExtCtrls;

type
  TfrmConsulta = class(TForm)
    btConsultar: TButton;
    mHTML: TMemo;
    EdgeBrowser1: TEdgeBrowser;
    btExtrairDados: TButton;
    mExtracao: TMemo;
    pnTop: TPanel;
    lblCNPJ: TLabel;
    edCNPJ: TEdit;
    procedure btConsultarClick(Sender: TObject);
    procedure EdgeBrowser1ExecuteScript(Sender: TCustomEdgeBrowser;
      AResult: HRESULT; const AResultObjectAsJson: string);
    procedure btExtrairDadosClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConsulta: TfrmConsulta;

implementation

{$R *.dfm}
uses System.NetEncoding;


procedure TfrmConsulta.btConsultarClick(Sender: TObject);
begin
  EdgeBrowser1.Navigate('https://solucoes.receita.fazenda.gov.br/Servicos/cnpjreva/Cnpjreva_Solicitacao.asp?cnpj=' +edCNPJ.text);
end;

procedure TfrmConsulta.btExtrairDadosClick(Sender: TObject);
var
 p,q,r:integer;
 s:string;
begin
  mHTML.Text := '';
  mExtracao.Text := '';
  EdgeBrowser1.ExecuteScript('encodeURI(document.documentElement.outerHTML)');
  while mHTML.Text = '' do
    Application.ProcessMessages;

  p:= pos('ABERTURA',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('ABERTURA='+ Trim(s));

  p:= pos('EMPRESARIAL',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('RAZÃO='+ Trim(s));

  p:= pos('LOGRADOURO',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('LOGRADOURO='+ Trim(s));

  p:= pos('NÚMERO',mHTML.text,r);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('NÚMERO='+ Trim(s));

  p:= pos('COMPLEMENTO',mHTML.text,r);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('COMPLEMENTO='+ Trim(s));

  p:= pos('CEP',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('CEP='+ Trim(s));


  p:= pos('BAIRRO/DISTRITO',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('BAIRRO/DISTRITO='+ Trim(s));

  p:= pos('MUNICÍPIO',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('MUNICÍPIO='+ Trim(s));

  p:= pos('UF',mHTML.text);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('UF='+ Trim(s));

  p:= pos('SITUAÇÃO CADASTRAL',mHTML.text,r);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('SITUAÇÃO CADASTRAL='+ Trim(s));

  p:= pos('DATA DA SITUAÇÃO CADASTRAL',mHTML.text,r);
  q :=pos('<b>',mHTML.text,p);
  r :=pos('</b>',mHTML.text,q);
  s:= copy(mHTML.text,q+3,r-q-3);
  mExtracao.lines.Add('DATA DA SITUAÇÃO CADASTRAL='+ Trim(s));

end;

procedure TfrmConsulta.EdgeBrowser1ExecuteScript(Sender: TCustomEdgeBrowser;
  AResult: HRESULT; const AResultObjectAsJson: string);
begin
 if AResultObjectAsJson <> 'null' then
    mHTML.text := TNetEncoding.URL.Decode(AResultObjectAsJson).DeQuotedString('"');
end;

end.
