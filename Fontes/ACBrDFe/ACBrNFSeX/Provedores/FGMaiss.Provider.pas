{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Italo Giurizzato Junior                         }
{                                                                              }
{  Você pode obter a última versão desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior.                                                   }
{                                                                              }
{  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU      }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto}
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,  }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Você também pode obter uma copia da licença em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Simões de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatuí - SP - 18270-170         }
{******************************************************************************}

{$I ACBr.inc}

unit FGMaiss.Provider;

interface

uses
  SysUtils, Classes, Variants,
  ACBrNFSeXClass, ACBrNFSeXConversao,
  ACBrNFSeXGravarXml, ACBrNFSeXLerXml,
  WebFisco.Provider,
  ACBrNFSeXWebserviceBase;

type
  TACBrNFSeXWebserviceFGMaiss = class(TACBrNFSeXWebserviceWebFisco)
  protected
    function GetSoapActionURL: string; override;

  public
    property SoapActionURL: string read GetSoapActionURL;
  end;

  TACBrNFSeProviderFGMaiss = class (TACBrNFSeProviderWebFisco)
  protected
    function CriarGeradorXml(const ANFSe: TNFSe): TNFSeWClass; override;
    function CriarLeitorXml(const ANFSe: TNFSe): TNFSeRClass; override;
    function CriarServiceClient(const AMetodo: TMetodo): TACBrNFSeXWebservice; override;

  end;

  TACBrNFSeXWebserviceFGMaiss101 = class(TACBrNFSeXWebserviceFGMaiss)

  end;

  TACBrNFSeProviderFGMaiss101 = class (TACBrNFSeProviderWebFisco101)
  protected
    function CriarGeradorXml(const ANFSe: TNFSe): TNFSeWClass; override;
    function CriarLeitorXml(const ANFSe: TNFSe): TNFSeRClass; override;
    function CriarServiceClient(const AMetodo: TMetodo): TACBrNFSeXWebservice; override;

  end;

implementation

uses
  ACBrDFe.Conversao,
  ACBrXmlBase, ACBrDFeException,
  FGMaiss.GravarXml, FGMaiss.LerXml;

{ TACBrNFSeProviderFGMaiss }

function TACBrNFSeProviderFGMaiss.CriarGeradorXml(
  const ANFSe: TNFSe): TNFSeWClass;
begin
  Result := TNFSeW_FGMaiss.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderFGMaiss.CriarLeitorXml(
  const ANFSe: TNFSe): TNFSeRClass;
begin
  Result := TNFSeR_FGMaiss.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderFGMaiss.CriarServiceClient(
  const AMetodo: TMetodo): TACBrNFSeXWebservice;
var
  URL: string;
begin
  URL := GetWebServiceURL(AMetodo);

  if URL <> '' then
    Result := TACBrNFSeXWebserviceFGMaiss.Create(FAOwner, AMetodo, URL)
  else
  begin
    if ConfigGeral.Ambiente = taProducao then
      raise EACBrDFeException.Create(ERR_SEM_URL_PRO)
    else
      raise EACBrDFeException.Create(ERR_SEM_URL_HOM);
  end;
end;

{ TACBrNFSeXWebserviceFGMaiss }

function TACBrNFSeXWebserviceFGMaiss.GetSoapActionURL: string;
begin
  Result := 'https://www1.fgmaiss.com.br:443/issqn/wservice/';
end;

{ TACBrNFSeProviderFGMaiss101 }

function TACBrNFSeProviderFGMaiss101.CriarGeradorXml(
  const ANFSe: TNFSe): TNFSeWClass;
begin
  Result := TNFSeW_FGMaiss101.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderFGMaiss101.CriarLeitorXml(
  const ANFSe: TNFSe): TNFSeRClass;
begin
  Result := TNFSeR_FGMaiss101.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderFGMaiss101.CriarServiceClient(
  const AMetodo: TMetodo): TACBrNFSeXWebservice;
var
  URL: string;
begin
  URL := GetWebServiceURL(AMetodo);

  if URL <> '' then
    Result := TACBrNFSeXWebserviceFGMaiss101.Create(FAOwner, AMetodo, URL)
  else
  begin
    if ConfigGeral.Ambiente = taProducao then
      raise EACBrDFeException.Create(ERR_SEM_URL_PRO)
    else
      raise EACBrDFeException.Create(ERR_SEM_URL_HOM);
  end;
end;

end.
