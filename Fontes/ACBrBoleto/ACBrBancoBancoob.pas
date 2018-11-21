{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2009 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:   DOUGLAS TYBEL                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{ Desenvolvedor desta unit: DOUGLAS TYBEL -  dtybel@yahoo.com.br  -  www.facilassim.com.br  }
{                                                                              }
{******************************************************************************}

{Somente � aceito o Conv�nio Carteira 1 Sem Registro} 

{$I ACBr.inc}

unit ACBrBancoBancoob;

interface

uses
  Classes, SysUtils, ACBrBoleto;

type

  { TACBrBancoob}

  TACBrBancoob = class(TACBrBancoClass)
   protected
   private
      I: Int64;
   public
    Constructor create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String; override;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;
    function MontarCampoNossoNumero(const ACBrTitulo :TACBrTitulo): String; override;
    procedure GerarRegistroHeader400(NumeroRemessa : Integer; aRemessa: TStringList); override;
    procedure GerarRegistroTransacao400(ACBrTitulo :TACBrTitulo; aRemessa: TStringList); override;
    procedure GerarRegistroTrailler400( ARemessa: TStringList  ); override;
    function GerarRegistroHeader240(NumeroRemessa : Integer): String; override;
    function GerarRegistroTransacao240(ACBrTitulo : TACBrTitulo): String; override;
    function GerarRegistroTrailler240(ARemessa : TStringList): String;  override;
    Procedure LerRetorno400(ARetorno:TStringList); override;
    procedure LerRetorno240(ARetorno: TStringList); override;
    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia) : String; override;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia):String; override;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia:TACBrTipoOcorrencia; CodMotivo:Integer): String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
   end;

implementation

uses  StrUtils, Variants, math,
      {$IFDEF COMPILER6_UP} DateUtils {$ELSE} ACBrD5, FileCtrl {$ENDIF},
      ACBrUtil;

constructor TACBrBancoob.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpDigito := 0;
   fpNome   := 'SICOOB';
   fpNumero := 756;
   fpTamanhoMaximoNossoNum := 7;
   fpTamanhoCarteira   := 1;
   fpTamanhoConta      := 12;
   fpCodigosMoraAceitos:= '012';
   fpLayoutVersaoArquivo := 81;
   fpLayoutVersaoLote    := 40;
end;

function TACBrBancoob.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
var
  Num, Res :String;
  i, base, digito : Integer;
const
  indice = '319731973197319731973';
begin

   Result := '0';

   Num :=  PadLeft(ACBrTitulo.ACBrBoleto.Cedente.Agencia, 4, '0') +
           PadLeft(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente, 10, '0') +
           PadLeft(trim(ACBrTitulo.NossoNumero), 7, '0');


   base := 0;
   for i := 1 to Length(Num) do
     base := base + ( StrToInt(copy(Num,i,1)) * StrToInt(copy(indice,i,1)) );

   digito := 11-((  base )-( trunc(base/11) * 11));
   //(Se o Resto for igual a 0 ou 1 ent�o o DV � igual a 0)
   if (digito > 9) then
      digito := 0;

   Res    := IntToStr(digito);
   Result := Res;

   { Para o c�lculo do d�gito verificador do nosso n�mero, dever� ser utilizada
     a f�rmula abaixo:
     N�mero da Cooperativa    9(4) � 3009
     C�digo do Cliente   9(10) � cedente
     Nosso N�mero   9(7) � Iniciado contagem em 1

     Constante para c�lculo  = 3197


     a) Concatenar na seq��ncia completando com zero � esquerda.
        Ex.: N�mero da Cooperativa  = 0001
             N�mero do Cliente(cedente)  = 1-9
             Nosso N�mero  = 21
             000100000000190000021

     b) Alinhar a constante com a seq��ncia repetindo de traz para frente.
        Ex.: 000100000000190000021
             319731973197319731973

     c) Multiplicar cada componente da seq��ncia com o seu correspondente da
        constante e somar os resultados.
        Ex.: 1*7 + 1*3 + 9*1 + 2*7 + 1*3 = 36

     d) Calcular o Resto atrav�s do M�dulo 11.
        Ex.: 36/11 = 3, resto = 3

     e) O resto da divis�o dever� ser subtra�do de 11 achando assim o DV
        (Se o Resto for igual a 0 ou 1 ent�o o DV � igual a 0).
        Ex.: 11 � 3 = 8, ent�o Nosso N�mero + DV = 21-8


     Mem�ria de C�lculo
     Coop.(4)|Cliente(10)		    |Nosso N�mero(7)
     3	   0	 0	9	0	0	0	0	1	3	6	3	5	2	5	9	3	1	1	5	1
     3	   1 	 9	7	3	1	9	7	3	1	9	7	3	1	9	7	3	1	9	7	3
     9	   0	 0	63	0	0	0	0	3	3	54	21	15	2	45	63	9	1	9	35	3 = soma = 335

     digito = 11-((  soma )-( resto inteiro (trunc) da divisao da soma por 11 * 11))
     digito = 11-((  335 )-(30*11))
     digito = 6 }
end;

function TACBrBancoob.MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras, ANossoNumero,ACarteira :String;
  CampoLivre : String;
begin

    FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);
    ANossoNumero := ACBrTitulo.NossoNumero+CalcularDigitoVerificador(ACBrTitulo);

    if (ACBrTitulo.Carteira = '1') or (ACBrTitulo.Carteira = '3')then
       ACarteira := ACBrTitulo.Carteira
    else
       raise Exception.Create( ACBrStr('Carteira Inv�lida.'+sLineBreak+'Utilize "1" ou "3".') );

    {Montando Campo Livre}
    CampoLivre    := PadLeft(trim(ACBrTitulo.ACBrBoleto.Cedente.Modalidade), 2, '0') +
                     PadLeft(trim(ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente), 7, '0') +
                     PadLeft(Copy(ANossoNumero,1,8), 8, '0') +  //7 Sequenciais + 1 do digito
                     IntToStrZero(Max(1,ACBrTitulo.Parcela),3);

    {Codigo de Barras}
    with ACBrTitulo.ACBrBoleto do
    begin
       CodigoBarras := IntToStrZero(Banco.Numero, 3) +
                       '9' +
                       FatorVencimento +
                       IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +
                       PadLeft(ACarteira, 1, '0') +
                       PadLeft(OnlyNumber(Cedente.Agencia),4,'0') +
                       CampoLivre;
    end;

    DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
    Result:= copy( CodigoBarras, 1, 4) + DigitoCodBarras + copy( CodigoBarras, 5, 44);
end;

function TACBrBancoob.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;

var
  CodigoCedente: String;
begin
  CodigoCedente := ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente;
  Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia + '/'+
            copy(CodigoCedente,1,length(CodigoCedente)-1)+ '-'+
            copy(CodigoCedente,length(CodigoCedente),1);
end;

function TACBrBancoob.MontarCampoNossoNumero (const ACBrTitulo: TACBrTitulo ) : String;
begin
  Result := ACBrTitulo.NossoNumero + '-' + CalcularDigitoVerificador(ACBrTitulo);
end;

procedure TACBrBancoob.GerarRegistroHeader400(NumeroRemessa : Integer; aRemessa:TStringList);
var
  wLinha: String;
begin
   with ACBrBanco.ACBrBoleto.Cedente do
   begin
      wLinha:= '0'                                        + // ID do Registro
               '1'                                        + // ID do Arquivo( 1 - Remessa)
               'REMESSA'                                  + // Literal de Remessa
               '01'                                       + // C�digo do Tipo de Servi�o
               PadRight( 'COBRANÇA', 8 )                      + // Descri��o do tipo de servi�o
               Space(7)                                   + // Brancos
               PadLeft( OnlyNumber(Agencia), 4 )             + // Prefixo da Cooperativa
               PadLeft( AgenciaDigito, 1 )                   + // D�gito Verificador do Prefixo
               PadLeft( trim(CodigoCedente), 9,'0' )         + // C�digo do Cliente/Cedente
               Space(6)                                   + // Brancos
               PadLeft( Nome, 30 )                           + // Nome do Cedente
               PadRight( '756BANCOOBCED', 18 )                + // Identifica��o do Banco: "756BANCOOBCED"  //Enviado pelo pessoal da homologa��o por email
               FormatDateTime('ddmmyy',Now)               + // Data de gera��o do arquivo
               IntToStrZero(NumeroRemessa,7)              + // Seq�encial da Remessa: n�mero seq�encial acrescido de 1 a cada remessa. Inicia com "0000001"
               Space(287)                                 + // Brancos
               IntToStrZero(1,6);                           // Contador de Registros

      aRemessa.Text:= aRemessa.Text + UpperCase(wLinha);
   end;
end;

procedure TACBrBancoob.GerarRegistroTransacao400(ACBrTitulo :TACBrTitulo; aRemessa: TStringList);
var
  DigitoNossoNumero, Ocorrencia,aEspecie, AInstrucao1, AInstrucao2 :String;
  TipoSacado, ATipoAceite,MensagemCedente, DiasProtesto :String;
  TipoCedente, wLinha :String;
  I: Integer;
  wRespEntrega: Char;
  strDataDesconto, strValorDesconto:String;
  strCarteiraEnvio : Char;
begin

    if (Length(ACBrTitulo.Carteira) < 1 )then
       raise Exception.Create( ACBrStr('Carteira Inv�lida.'+sLineBreak) ) ;

   with ACBrTitulo do
   begin
      DigitoNossoNumero := CalcularDigitoVerificador(ACBrTitulo);

      {Pegando C�digo da Ocorrencia}
      case OcorrenciaOriginal.Tipo of
         toRemessaBaixar                         : Ocorrencia := '02'; {Pedido de Baixa}
         toRemessaConcederAbatimento             : Ocorrencia := '04'; {Concess�o de Abatimento}
         toRemessaCancelarAbatimento             : Ocorrencia := '05'; {Cancelamento de Abatimento concedido}
         toRemessaAlterarVencimento              : Ocorrencia := '06'; {Altera��o de vencimento}
         toRemessaAlterarNumeroControle          : Ocorrencia := '08'; {Altera��o de seu n�mero}
         toRemessaProtestar                      : Ocorrencia := '09'; {Pedido de protesto}
         toRemessaCancelarInstrucaoProtestoBaixa : Ocorrencia := '10'; {Desist�ncia do Protesto e Baixar T�tulo}
         toRemessaDispensarJuros                 : Ocorrencia := '11'; {Instru��o para Dispensar Juros}
         toRemessaAlterarDadosPagador            : Ocorrencia := '12'; {Altera��o de Pagador}
         toRemessaOutrasOcorrencias              : Ocorrencia := '31'; {Altera��o de Outros Dados}
         toRemessaBaixaporPagtoDiretoCedente     : Ocorrencia := '34'; {Baixa - Pagamento Direto ao Benefici�rio}
      else
         Ocorrencia := '01';                                          {Remessa}
      end;

      { Pegando o Aceite do Titulo }
      case Aceite of
         atSim :  ATipoAceite := '1';
         atNao :  ATipoAceite := '0';
      end;

      {INstrucao}
      AInstrucao1 := PadLeft(Trim(Instrucao1),2,'0');
      AInstrucao2 := PadLeft(Trim(Instrucao2),2,'0');

      {Pegando Especie}
      if trim(EspecieDoc) = 'DM' then
         aEspecie:= '01'
      else if trim(EspecieDoc) = 'NP' then
         aEspecie:= '02'
      else if trim(EspecieDoc) = 'NS' then
         aEspecie:= '03'
      else if trim(EspecieDoc) = 'CS' then
         aEspecie:= '04'
      else if trim(EspecieDoc) = 'ND' then
         aEspecie:= '11'
      else if trim(EspecieDoc) = 'DS' then
         aEspecie:= '12'
      else
         aEspecie := EspecieDoc;

      {Pegando Tipo de Sacado}
      case Sacado.Pessoa of
         pFisica   : TipoSacado := '01';
         pJuridica : TipoSacado := '02';
      else
         TipoSacado := '99';
      end;

      {Pegando Tipo de Cedente}
      if ACBrBoleto.Cedente.TipoInscricao  = pFisica then
         TipoCedente := '01'
      else
         TipoCedente := '02';

      if ACBrBoleto.Cedente.ResponEmissao= tbCliEmite then
         wRespEntrega := '2'
      else
         wRespEntrega := '1';
      
      if (ACBrTitulo.CarteiraEnvio = tceBanco) then
        strCarteiraEnvio := '1'
      else
        strCarteiraEnvio := '2';


      DiasProtesto := IntToStrZero(DiasDeProtesto,2);
         
      { Data do Primeiro Desconto}
      if ( DataDesconto <> 0 ) then
        strDataDesconto := FormatDateTime('ddmmyy', DataDesconto)
      else
        strDataDesconto := IntToStrZero(0, 6);

      { Valor do Primeiro Desconto}
      if ( ValorDesconto <> 0 ) then
        strValorDesconto := IntToStrZero( Round( ValorDesconto * 100 ), 13)
      else
        strValorDesconto := IntToStrZero(0, 13);

      with ACBrBoleto do
      begin
         MensagemCedente:= '';
         for I:= 0 to Mensagem.count-1 do
             MensagemCedente:= MensagemCedente + trim(Mensagem[i]);

         if length(MensagemCedente) > 40 then
            MensagemCedente:= copy(MensagemCedente,1,40);

         wLinha:= '1'                                                     +  // ID Registro
                  TipoCedente                                             +  // Identifica��o do Tipo de Inscri��o do Sacado 01 - CPF 02 - CNPJ
                  PadLeft(onlyNumber(Cedente.CNPJCPF),14,' ')             +  // N�mero de Inscri��o do Cedente
                  PadLeft(OnlyNumber(Cedente.Agencia), 4, '0')            +  // Ag�ncia
                  PadLeft( Cedente.AgenciaDigito, 1, '0')                 +  // Ag�ncia digito
                  PadLeft( RightStr(OnlyNumber(Cedente.Conta),8), 8, '0') +  // Conta Corrente
                  PadLeft( Cedente.ContaDigito, 1, ' ')                   +  // D�gito Conta Corrente
                  PadLeft( '0', 6, '0')                                   +  // N�mero do Conv�nio de Cobran�a do Cedente fixo zeros: "000000"
                  PadRight(trim(SeuNumero),  25)                          +  // Seu Numero (antes etava indo Brancos)
                  PadLeft( NossoNumero + DigitoNossoNumero, 12, '0')      +  // Nosso N�mero + //nosso numero com digito
                  IntToStrZero(ifthen(Parcela > 0, Parcela,1),2)          +  // N�mero da Parcela: "01" se parcela �nica
                  '00'                                                    +  // Grupo de Valor: "00"
                  Space(3)                                                +  // Brancos
                  Space(1)                                                +  // Indicativo de Mensagem ou Sacador/Avalista:
                  Space(3)                                                +  // Brancos
                  IntToStrZero( 0, 3)                                     +  // Varia��o da Carteira: "000"
                  IntToStrZero( 0, 1)                                     +  // Conta Cau��o: "0"
                  IntToStrZero( 0, 5)                                     +  // C�digo de responsabilidade: "00000"
                  IntToStrZero( 0, 1)                                     +  // DV do c�digo de responsabilidade: "0"
                  IntToStrZero( 0, 6)                                     +  // Numero do border�: �000000�
                  Space(4)                                                +  // Brancos
                  wRespEntrega                                            +  // Tipo de Emiss�o 1-Cooperativa - 2-Cliente
                  PadLeft( trim(Cedente.Modalidade), 2, '0')              +  // Carteira/Modalidade
                  Ocorrencia                                              +  // Ocorrencia (remessa)
                  PadRight(trim(NumeroDocumento),  10)                    +  // N�mero do Documento
                  FormatDateTime( 'ddmmyy', Vencimento)                   +  // Data de Vencimento do T�tulo
                  IntToStrZero( Round( ValorDocumento * 100 ), 13)        +  // Valor do T�tulo
                  IntToStrZero( Banco.Numero, 3)                          +  // N�mero Banco: "756"
                  PadLeft(OnlyNumber(Cedente.Agencia), 4, '0')            +  // Prefixo da Ag�ncia Cobradora: �0000�
                  PadLeft( Cedente.AgenciaDigito, 1, ' ')                 +  // D�gito Verificador do Prefixo da Ag�ncia Cobradora: Brancos
                  PadRight(aEspecie,2)                                    +  // Esp�cie do T�tulo
                  ATipoAceite                                             +  // Identifica��o
                  FormatDateTime( 'ddmmyy', DataDocumento )               +  // 32 Data de Emiss�o
                  PadLeft(AInstrucao1, 2, '0')                            +  // 33 Primeira instru��o (SEQ 34) = 00 e segunda (SEQ 35) = 00, n�o imprime nada.
                  PadLeft(AInstrucao2, 2, '0')                            +  // 34 Primeira instru��o (SEQ 34) = 00 e segunda (SEQ 35) = 00, n�o imprime nada.
                  IntToStrZero( Round( (ValorMoraJuros) * 10000 ), 6)     +  // Taxa de mora m�s
                  IntToStrZero( Round( PercentualMulta * 10000 ), 6)      +  // Taxa de multa
                  strCarteiraEnvio                                        +  // Responsabilidade Distribui��o
                  strDataDesconto                                         +  // Data do Primeiro Desconto, Preencher com zeros quando n�o for concedido nenhum desconto.
                  strValorDesconto                                        +  // Valor do Primeiro Desconto, Preencher com zeros quando n�o for concedido nenhum desconto.
                  IntToStrZero( 9 , 1)                                    +  // MOEDA 9 BRASIL
                  IntToStrZero( 0, 12)                                    +  // Valor IOF / Quantidade Monet�ria: "0000000000000"
                  IntToStrZero( 0, 13)                                    +  // Valor Abatimento
                  TipoSacado                                              +  // Tipo de Inscri��o do Sacado: 01 - CPF 02 - CNPJ
                  PadLeft(onlyNumber(Sacado.CNPJCPF),14,'0')              +  // N�mero de Inscri��o do Sacado
                  PadRight( Sacado.NomeSacado, 40, ' ')                   +  // Nome do Sacado
                  PadRight( Sacado.Logradouro +' '+ Sacado.Numero,37,' ') +  // Endere�o Completo
                  PadRight( Sacado.Bairro,15,' ')                         +  // Endere�o Bairro
                  PadRight( Sacado.CEP,8,' ')                             +  // Endere�o CEP
                  PadRight( Sacado.Cidade,15,' ')                         +  // Endere�o cidade
                  PadRight( Sacado.UF,2,' ')                              +  // Endere�o uf
                  PadRight( trim(MensagemCedente) ,40,' ')                +  // Observa��es/Mensagem ou Sacador/Avalista:
                  DiasProtesto                                            +  // N�mero de Dias Para Protesto
                  Space(1)                                                +  // Brancos
                  IntToStrZero( aRemessa.Count + 1, 6 );                     // Contador de Registros;

         aRemessa.Text:= aRemessa.Text + UpperCase(wLinha);
      end;
   end;
end;

procedure TACBrBancoob.GerarRegistroTrailler400( ARemessa: TStringList );
var
  wLinha: String;
begin
   wLinha:= '9'                                  + // ID Registro
            Space(193)                           + // Brancos
            Space(40)                            + // Mensagem responsabilidade Cedente
            Space(40)                            + // Mensagem responsabilidade Cedente
            Space(40)                            +
            Space(40)                            +
            Space(40)                            +
            IntToStrZero( ARemessa.Count + 1, 6);  // Contador de Registros

   ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
end;


procedure TACBrBancoob.LerRetorno240(ARetorno: TStringList);
var
  ContLinha: Integer;
  Titulo   : TACBrTitulo;
  Linha, rCedente, rCNPJCPF: String;
  rAgencia, rConta,rDigitoConta: String;
  MotivoLinha, I, CodMotivo: Integer;
begin
 
   if (copy(ARetorno.Strings[0],1,3) <> '756') then
      raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do '+ Nome));

   with ACBrBanco.ACBrBoleto do
   begin
     if LeCedenteRetorno then
     begin
       case StrToIntDef(Copy(ARetorno[1],18,1),0) of
         1: Cedente.TipoInscricao:= pFisica;
         2: Cedente.TipoInscricao:= pJuridica;
       else
         Cedente.TipoInscricao:= pJuridica;
       end;
     end;

     rCedente := trim(Copy(ARetorno[0],73,30));
     rAgencia := trim(Copy(ARetorno[0],53,5));
     rConta   := trim(Copy(ARetorno[0],59,12));
     rDigitoConta := Copy(ARetorno[0],71,1);

     NumeroArquivo := StrToIntDef(Copy(ARetorno[0], 158, 6), 0);
     DataArquivo   := StringToDateTimeDef(Copy(ARetorno[0],144,2)+'/'+
                                          Copy(ARetorno[0],146,2)+'/'+
                                          Copy(ARetorno[0],148,4),0, 'DD/MM/YY' );

     if StrToIntDef(Copy(ARetorno[1],200,6),0) <> 0 then
        DataCreditoLanc := StringToDateTimeDef(Copy(ARetorno[0],200,2)+'/'+
                                               Copy(ARetorno[0],202,2)+'/'+
                                               Copy(ARetorno[0],204,4),0, 'DD/MM/YY' );
     rCNPJCPF := trim( Copy(ARetorno[0],19,14)) ;

     if Cedente.TipoInscricao = pJuridica then
     begin
       rCNPJCPF := trim( Copy(ARetorno[1],19,15));
       rCNPJCPF := RightStr(rCNPJCPF,14) ;
     end
     else
     begin
       rCNPJCPF := trim( Copy(ARetorno[1],23,11));
       rCNPJCPF := RightStr(rCNPJCPF,11) ;
     end;


     if ( (not LeCedenteRetorno) and (rCNPJCPF <> OnlyNumber(Cedente.CNPJCPF)) ) then
       raise Exception.Create(ACBrStr('CNPJ\CPF do arquivo inv�lido'));

     if ( (not LeCedenteRetorno) and (StrToInt(rAgencia) <> StrToInt(Cedente.Agencia)) ) then
       raise Exception.CreateFMT('Agencia do arquivo %s inv�lida, config %s',[rAgencia,OnlyNumber(Cedente.Agencia)]);

     if ( (not LeCedenteRetorno) and (rConta + rDigitoConta <> OnlyNumber(Cedente.Conta + Cedente.ContaDigito)) ) then
       raise Exception.CreateFMT('Conta do arquivo %s inv�lida, config %s',[rConta,OnlyNumber(Cedente.Conta + Cedente.ContaDigito)]);

     if LeCedenteRetorno then
     begin
       Cedente.Nome    := rCedente;
       Cedente.CNPJCPF := rCNPJCPF;
       Cedente.Agencia := rAgencia;
       Cedente.AgenciaDigito:= '0';
       Cedente.Conta   := rConta;
       Cedente.ContaDigito:= rDigitoConta;
       Cedente.CodigoCedente:= rConta+rDigitoConta;
     end;
     Cedente.Conta := RemoveZerosEsquerda(Cedente.Conta);

     ListadeBoletos.Clear;
   end;

   Linha := '';
   Titulo := nil;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha] ;

      {Segmento T - S� cria ap�s passar pelo seguimento T depois U}
      if Copy(Linha,14,1)= 'T' then
         Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      if Assigned(Titulo) then
      with Titulo do
      begin
         {Segmento T}
         if Copy(Linha,14,1)= 'T' then
          begin
            SeuNumero                   := Trim(copy(Linha,106,25));
            NumeroDocumento             := copy(Linha,59,15);
            OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(copy(Linha,16,2),0));

            //05 = Liquida��o Sem Registro
            Vencimento := StringToDateTimeDef( Copy(Linha,74,2)+'/'+
                                               Copy(Linha,76,2)+'/'+
                                               Copy(Linha,80,2),0, 'DD/MM/YY' );

            ValorDocumento       := StrToFloatDef(Copy(Linha,82,15),0)/100;
            ValorDespesaCobranca := StrToFloatDef(Copy(Linha,199,15),0)/100;
            NossoNumero          := Copy(Linha,40,7);
            Carteira             := Copy(Linha,58,1);
            CodigoLiquidacao     := Copy(Linha,214,02);
            //CodigoLiquidacaoDescricao := CodigoLiquidacao_Descricao( StrToIntDef(CodigoLiquidacao,0) );

            // DONE -oJacinto Junior: Implementar a leitura dos motivos das ocorr�ncias.
            MotivoLinha := 214;

            for I := 0 to 4 do
            begin
              CodMotivo := StrToIntDef(IfThen(Copy(Linha, MotivoLinha, 2) = '00', '00', Copy(Linha, MotivoLinha, 2)), 0);

              if CodMotivo <> 0 then
              begin
                MotivoRejeicaoComando.Add(IfThen(Copy(Linha, MotivoLinha, 2) = '00', '00', Copy(Linha, MotivoLinha, 2)));
                DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo, CodMotivo));
              end;

              MotivoLinha := MotivoLinha + 2; // Incrementa a coluna dos motivos.
            end;
          end
         {Ssegmento U}
         else if Copy(Linha,14,1)= 'U' then
          begin

            if StrToIntDef(Copy(Linha,138,6),0) <> 0 then
               DataOcorrencia := StringToDateTimeDef( Copy(Linha,138,2)+'/'+
                                                      Copy(Linha,140,2)+'/'+
                                                      Copy(Linha,142,4),0, 'DD/MM/YYYY' );

            if StrToIntDef(Copy(Linha,146,6),0) <> 0 then
               DataCredito:= StringToDateTimeDef( Copy(Linha,146,2)+'/'+
                                                  Copy(Linha,148,2)+'/'+
                                                  Copy(Linha,150,4),0, 'DD/MM/YYYY' );

            ValorPago            := StrToFloatDef(Copy(Linha,78,15),0)/100;
            ValorMoraJuros       := StrToFloatDef(Copy(Linha,18,15),0)/100;
            ValorDesconto        := StrToFloatDef(Copy(Linha,33,15),0)/100;
            ValorAbatimento      := StrToFloatDef(Copy(Linha,48,15),0)/100;
            ValorIOF             := StrToFloatDef(Copy(Linha,63,15),0)/100;
            ValorRecebido        := StrToFloatDef(Copy(Linha,93,15),0)/100;
            ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,108,15),0)/100;
            ValorOutrosCreditos  := StrToFloatDef(Copy(Linha,123,15),0)/100;
         end
        {Segmento W}
        else if Copy(Linha, 14, 1) = 'W' then
         begin
           //verifica o motivo de rejei��o
           MotivoRejeicaoComando.Add(copy(Linha,29,2));
           DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(
                                              CodOcorrenciaToTipo(
                                              StrToIntDef(copy(Linha, 16, 2), 0)),
                                              StrToInt(Copy(Linha, 29, 2))));
         end;
      end;
   end;

end;

procedure TACBrBancoob.LerRetorno400(ARetorno: TStringList);
var
  ContLinha: Integer;
  Titulo   : TACBrTitulo;
  Linha, rCedente, rCNPJCPF : String;
begin

   if (copy(ARetorno.Strings[0],1,9) <> '02RETORNO') then
      raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do '+ Nome));

   rCedente := trim(Copy(ARetorno[0],32,8));


   ACBrBanco.ACBrBoleto.DataArquivo   := StringToDateTimeDef(Copy(ARetorno[0],95,2)+'/'+
                                                             Copy(ARetorno[0],97,2)+'/'+
                                                             Copy(ARetorno[0],99,2),0, 'DD/MM/YY' );

   ACBrBanco.ACBrBoleto.NumeroArquivo   := StrToIntDef(Copy(ARetorno[0],101,7), 0);

   ACBrBanco.ACBrBoleto.DataCreditoLanc := StringToDateTimeDef(Copy(ARetorno[1],111,2)+'/'+
                                                               Copy(ARetorno[1],113,2)+'/'+
                                                               Copy(ARetorno[1],115,2),0, 'DD/MM/YY' );
   rCNPJCPF := trim( Copy(ARetorno[1],4,14)) ;

   with ACBrBanco.ACBrBoleto do
   begin
      if LeCedenteRetorno then
      begin
        Cedente.Nome          := rCedente;
        Cedente.CNPJCPF       := rCNPJCPF;
        Cedente.Agencia       := trim(copy(ARetorno[1], 18, 4));
        Cedente.AgenciaDigito := trim(copy(ARetorno[1], 22, 1));
        Cedente.Conta         := trim(copy(ARetorno[1], 23, 8));
        Cedente.ContaDigito   := trim(copy(ARetorno[1], 31, 1));

        case StrToIntDef(Copy(ARetorno[1],2,2),0) of
           11: Cedente.TipoInscricao:= pFisica;
           else
              Cedente.TipoInscricao:= pJuridica;
        end;
      end;  
      ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha] ;

      if Copy(Linha,1,1)<> '1' then
         Continue;

      Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      with Titulo do
      begin
         SeuNumero                   := copy(Linha,38,25);
         NumeroDocumento             := copy(Linha,117,10);
         OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(
                                        copy(Linha,109,2),0));
         //05 = Liquida��o Sem Registro

         DataOcorrencia := StringToDateTimeDef( Copy(Linha,111,2)+'/'+
                                                Copy(Linha,113,2)+'/'+
                                                Copy(Linha,115,2),0, 'DD/MM/YY' );

         Vencimento := StringToDateTimeDef( Copy(Linha,147,2)+'/'+
                                            Copy(Linha,149,2)+'/'+
                                            Copy(Linha,151,2),0, 'DD/MM/YY' );

         ValorDocumento       := StrToFloatDef(Copy(Linha,153,13),0)/100;
         ValorIOF             := StrToFloatDef(Copy(Linha,215,13),0)/100;
         ValorAbatimento      := StrToFloatDef(Copy(Linha,228,13),0)/100;
         ValorDesconto        := StrToFloatDef(Copy(Linha,241,13),0)/100;
         ValorMoraJuros       := StrToFloatDef(Copy(Linha,267,13),0)/100;
         ValorOutrosCreditos  := StrToFloatDef(Copy(Linha,280,13),0)/100;
         ValorRecebido        := StrToFloatDef(Copy(Linha,254,13),0)/100;
         NossoNumero          := copy( Copy(Linha,63,11),Length( Copy(Linha,63,11) )-TamanhoMaximoNossoNum+1  ,TamanhoMaximoNossoNum);
         Carteira             := Copy(Linha,86,3);
         ValorDespesaCobranca := StrToFloatDef(Copy(Linha,182,7),0)/100;
         ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,189,13),0)/100;

         if StrToIntDef(Copy(Linha,176,6),0) <> 0 then
            DataCredito:= StringToDateTimeDef( Copy(Linha,176,2)+'/'+
                                               Copy(Linha,178,2)+'/'+
                                               Copy(Linha,180,2),0, 'DD/MM/YY' );
      end;
   end;

end;

function TACBrBancoob.GerarRegistroHeader240(
  NumeroRemessa: Integer): String;
var
  ATipoInscricao: string;
begin
  I := 0;

  with ACBrBanco.ACBrBoleto.Cedente do
    begin
      case TipoInscricao of
        pFisica  : ATipoInscricao := '1';
        pJuridica: ATipoInscricao := '2';
      end;
      { GERAR REGISTRO-HEADER DO ARQUIVO }
      Result:= IntToStrZero(ACBrBanco.Numero, 3)        + // 1 a 3 - C�digo do banco
               '0000'                                   + // 4 a 7 - Lote de servi�o
               '0'                                      + // 8 - Tipo de registro - Registro header de arquivo
               space(9)                                 + // 9 a 17 Uso exclusivo FEBRABAN/CNAB
               ATipoInscricao                           + // 18 - Tipo de inscri��o do cedente
               PadLeft(OnlyNumber(CNPJCPF), 14, '0')    + // 19 a 32 -N�mero de inscri��o do cedente
               StringOfChar(' ', 20)                    + // 33 a 52 - Brancos - Altera��o para passar no validador
               '0'                                      + // 53 - Zeros
               PadLeft(OnlyNumber(Agencia), 4, '0')     + // 54 a 57 - C�digo da ag�ncia do cedente
               PadRight(AgenciaDigito, 1, '0')          + // 58 - Digito ag�ncia do cedente
               PadLeft(OnlyNumber(Conta), 12, '0')      + // 59 a 70 - N�mero da conta do cedente
               PadRight(ContaDigito, 1, '0')            + // 71 - Digito conta do cedente
               PadRight(DigitoVerificadorAgenciaConta, 1, ' ')+ // 72 - D�gito verificador Ag/Conta (zero)
               PadRight(Nome, 30, ' ')                  + // 73 a 102 - Nome do cedente
               PadRight('SICOOB', 30, ' ')              + // 103 a 132 - Nome do banco
               space(10)                                + // 133 A 142 - Brancos
               '1'                                      + // 143 - C�digo de Remessa (1) / Retorno (2)
               FormatDateTime('ddmmyyyy', Now)          + // 144 a 151 - Data do de gera��o do arquivo
               FormatDateTime('hhmmss', Now)            + // 152 a 157 - Hora de gera��o do arquivo
//               '000001'                                 + // 158 a 163 - N�mero sequencial do arquivo retorno
               PadLeft(OnlyNumber(inttostr(NumeroRemessa)), 6, '0')     + // 158 a 163 - N�mero sequencial do arquivo retorno  - marcio ereno 09/06/2018
               PadLeft(IntToStr(fpLayoutVersaoArquivo) , 3, '0')  + // 164 a 166 - N�mero da vers�o do layout do arquivo  //Altera��o para passar no Validador
               '00000'                                  + // 167 a 171 - Zeros
               space(54)                                + // 172 a 225 - 54 Brancos
               space(3)                                 + // 226 a 228 - zeros
               space(12);                                 // 229 a 240 - Brancos
     { GERAR REGISTRO HEADER DO LOTE }
      Result:= Result + #13#10 +
               IntToStrZero(ACBrBanco.Numero, 3)       + //1 a 3 - C�digo do banco
               '0001'                                  + //4 a 7 - Lote de servi�o
               '1'                                     + //8 - Tipo de registro - Registro header de arquivo
               'R'                                     + //9 - Tipo de opera��o: R (Remessa) ou T (Retorno)
               '01'                                    + //10 a 11 - Tipo de servi�o: 01 (Cobran�a)
               '  '                                    + //12 a 13 - Forma de lan�amento: preencher com ZEROS no caso de cobran�a
               PadLeft(IntToStr(fpLayoutVersaoLote), 3, '0')     + //14 a 16 - N�mero da vers�o do layout do lote
               ' '                                     + //17 - Uso exclusivo FEBRABAN/CNAB
               ATipoInscricao                          + //18 - Tipo de inscri��o do cedente
               PadLeft(OnlyNumber(CNPJCPF), 15, '0')   + //19 a 33 -N�mero de inscri��o do cedente
               space(20)                               + //34 a 53 - Brancos
               '0'                                     + // 54 - Zeros
               PadLeft(OnlyNumber(Agencia), 4, '0')    + //55 a 58 - C�digo da ag�ncia do cedente
               PadLeft(AgenciaDigito, 1, '0')          + //59 - Digito da agencia do cedente
               PadLeft(OnlyNumber(Conta), 12, '0')     + //60 - 71  N�mero da conta do cedente
               PadLeft(ContaDigito, 1, '0')            + //72 - Digito da conta
               ' '                                     + //73
               PadRight(Nome, 30, ' ')                 + //74 a 103 - Nome do cedente
               space(80)                               + // 104 a 183 - Brancos
               PadLeft(IntToStr(NumeroRemessa) , 08, '0') + // 184 a 191 - N�mero sequ�ncia do arquivo retorno.
               FormatDateTime('ddmmyyyy', Now)         + //192 a 199 - Data de gera��o do arquivo
               PadLeft('', 8, '0')                     + //200 a 207 - Data do cr�dito - S� para arquivo retorno
               space(33);                                //208 a 240 - Uso exclusivo FEBRABAN/CNAB
    end;
end;

function TACBrBancoob.GerarRegistroTransacao240(
  ACBrTitulo: TACBrTitulo): String;
var AEspecieTitulo, ATipoInscricao, ATipoOcorrencia, ATipoBoleto, ADataMoraJuros,
    ADataDesconto,ADataDesconto2,ATipoAceite,NossoNum : string;
    DiasProtesto: String;
    ProtestoBaixa: String;
    ATipoInscricaoAvalista: Char;
    wModalidade, ValorMora: String;
    strCarteiraEnvio : Char;
    S :string;
    MsgBoleto: Array[1..5] of string;
    K: Integer;
begin
  if ( ACBrTitulo.NossoNumero <> IntToStrZero(0, length(ACBrTitulo.NossoNumero)) ) then
    NossoNum  := RemoveString('-', MontarCampoNossoNumero(ACBrTitulo))
  else
    NossoNum  := ACBrTitulo.NossoNumero;
  ATipoInscricaoAvalista := ' ';
  ValorMora := '';
  with ACBrTitulo do
    begin

      S:= Mensagem.Text;
      S:= RemoveString( #13, S );
      S:= RemoveString( #10, S );
      for K := Low(MsgBoleto) to High(MsgBoleto) do
      begin
        MsgBoleto[K] := Copy(S, 1, 40);
        Delete(S, 1, 40);
      end;

      {SEGMENTO P}
      {Pegando o Tipo de Ocorrencia}
      case OcorrenciaOriginal.Tipo of
        toRemessaBaixar                        : ATipoOcorrencia := '02';
        toRemessaConcederAbatimento            : ATipoOcorrencia := '04';
        toRemessaCancelarAbatimento            : ATipoOcorrencia := '05';
        toRemessaAlterarVencimento             : ATipoOcorrencia := '06';
        toRemessaConcederDesconto              : ATipoOcorrencia := '07';
        toRemessaCancelarDesconto              : ATipoOcorrencia := '08';
        toRemessaProtestar                     : ATipoOcorrencia := '09';
        toRemessaCancelarInstrucaoProtestoBaixa: ATipoOcorrencia := '10';
        toRemessaCancelarInstrucaoProtesto     : ATipoOcorrencia := '11';
        toRemessaOutrasOcorrencias             : ATipoOcorrencia := '31';
      else
       ATipoOcorrencia := '01';
      end;

     {Pegando o Aceite do Titulo }
      case Aceite of
        atSim :  ATipoAceite := 'A';
        atNao :  ATipoAceite := 'N';
      end;

      {Pegando Tipo de Boleto} //Quem emite e quem distribui o boleto?
      case ACBrBoleto.Cedente.ResponEmissao of
        tbCliEmite        : ATipoBoleto := '2';
        tbBancoEmite      : ATipoBoleto := '1';
        tbBancoReemite    : ATipoBoleto := '3';
        tbBancoNaoReemite : ATipoBoleto := '4';
      end;

      {Pegando especie do titulo}
      if EspecieDoc = 'CH' then
        AEspecieTitulo := '01'
      else if EspecieDoc = 'DM' then
        AEspecieTitulo := '02'
      else if EspecieDoc = 'DMI' then      // DMI Duplicata Mercantil indicada para protesto
        AEspecieTitulo := '03'             // no campo 107 e 108 tem que sair 03 - GR7 automa��o em 17.03.2017
      else if EspecieDoc = 'DS' then
        AEspecieTitulo := '04'
      else if EspecieDoc = 'DSI' then
        AEspecieTitulo := '05'
      else if EspecieDoc = 'DR' then
        AEspecieTitulo := '06'
      else if EspecieDoc = 'LC' then
        AEspecieTitulo := '07'
      else if EspecieDoc = 'NCC' then
        AEspecieTitulo := '08'
      else if EspecieDoc = 'NCE' then
        AEspecieTitulo := '09'
      else if EspecieDoc = 'NCI' then
        AEspecieTitulo := '10'
      else if EspecieDoc = 'NCR' then
        AEspecieTitulo := '11'
      else if EspecieDoc = 'NP' then
        AEspecieTitulo := '12'
      else if EspecieDoc = 'NPR' then
        AEspecieTitulo := '13'
      else if EspecieDoc = 'TM' then
        AEspecieTitulo := '14'
      else if EspecieDoc = 'TS' then
        AEspecieTitulo := '15'
      else if EspecieDoc = 'NS' then
        AEspecieTitulo := '16'
      else if EspecieDoc = 'RC' then
        AEspecieTitulo := '17'
      else if EspecieDoc = 'FAT' then
        AEspecieTitulo := '18'
      else if EspecieDoc = 'ND' then
        AEspecieTitulo := '19'
      else if EspecieDoc = 'AP' then
        AEspecieTitulo := '20'
      else if EspecieDoc = 'ME' then
        AEspecieTitulo := '21'
      else if EspecieDoc = 'PC' then
        AEspecieTitulo := '22'
      else if EspecieDoc = 'NF' then
        AEspecieTitulo := '23'
      else if EspecieDoc = 'DD' then
        AEspecieTitulo := '24'
      else if EspecieDoc = 'BDP' then
        AEspecieTitulo := '32'
      else if EspecieDoc = 'Outros' then
        AEspecieTitulo := '99'
      else
        AEspecieTitulo := '99';

      {Mora Juros}
      if (ValorMoraJuros > 0) then
        begin
          if (DataMoraJuros > 0) then
            ADataMoraJuros := FormatDateTime('ddmmyyyy', DataMoraJuros)
          else ADataMoraJuros := PadLeft('', 8, '0');
        end
      else ADataMoraJuros := PadLeft('', 8, '0');

     {Descontos}
     if (ValorDesconto > 0) then
       begin
         if(DataDesconto > 0) then
           ADataDesconto := FormatDateTime('ddmmyyyy', DataDesconto)
         else  ADataDesconto := PadLeft('', 8, '0');
       end
     else
       ADataDesconto := PadLeft('', 8, '0');

     DiasProtesto  := IntToStrZero(DiasDeProtesto,2);

     if (DataProtesto > 0) then
       ProtestoBaixa:= '1'
     else
       ProtestoBaixa:= '3';

     if CodigoMora = '' then
     begin
      CodigoMora := '0'; //assume como cjIsento
       // cjValorDia, cjTaxaMensal, cjIsento
      if ValorMoraJuros > 0 then // Se tem juro atribuido, mudar de acordo com o tipo que o banco processa
      begin
        if  CodigoMoraJuros = cjValorDia then
          CodigoMora :='1'
        else if  CodigoMoraJuros = cjTaxaMensal then
          CodigoMora :='2';
      end;
     end;

     if CodigoMora = '0' then
       ValorMora := PadLeft('', 15, '0')
     else
       ValorMora := IntToStrZero(Round(ValorMoraJuros * 100), 15);
    
     if (ACBrTitulo.CarteiraEnvio = tceBanco) then
       strCarteiraEnvio := '1'
     else
       strCarteiraEnvio := '2';

      Result:= IntToStrZero(ACBrBanco.Numero, 3)                             + //1 a 3 - C�digo do banco
               '0001'                                                        + //4 a 7 - Lote de servi�o
               '3'                                                           +
               IntToStrZero((i)+ 1 ,5)                                       + //9 a 13 - N�mero seq�encial do registro no lote - Cada registro possui dois segmentos
               'P'                                                           + //14 - C�digo do segmento do registro detalhe
               ' '                                                           + //15 - Uso exclusivo FEBRABAN/CNAB: Branco
               ATipoOcorrencia                                               + //16 a 17 - C�digo de movimento
               '0'                                                           + // 18
               PadLeft(OnlyNumber(ACBrBoleto.Cedente.Agencia),4,'0')         + //19 a 22 - Ag�ncia mantenedora da conta
               PadLeft(ACBrBoleto.Cedente.AgenciaDigito, 1, '0')             + //23 Digito agencia
               PadLeft(OnlyNumber(ACBrBoleto.Cedente.Conta), 12, '0')        + //24 a 35 - N�mero da Conta Corrente
               PadLeft(ACBrBoleto.Cedente.ContaDigito , 1, '0')              + //36 - D�gito da Conta Corrente
               ' ';                                                            //37 - DV Ag�ncia/COnta Brancos
               
              wModalidade:= ifthen(trim(ACBrBoleto.Cedente.Modalidade) = '',
                                    '02', ACBrBoleto.Cedente.Modalidade);

              Result := Result+PadLeft(NossoNum, 10, '0')+ // 38 a 57 - Carteira
                        PadLeft(inttostr(ifthen(parcela=0,1,parcela)), 02, '0')+ //PadLeft('01', 02, '0')+
                        PadLeft(wModalidade, 02, '0')+
                        '4'+
                        Space(5);

               Result := Result                                           +
                         PadRight(Carteira, 1)                            + // 58 a 58 carteira
                         '0'                                              + // 59 Forma de cadastramento no banco
                         ' '                                              + // 60 Brancos
                         ATipoBoleto                                      + // 61 Identifica��o da emiss�o do boleto
                         strCarteiraEnvio                                 + // 62  Identifica��o da distribui��o
                         PadRight(NumeroDocumento, 15, ' ')               + // 63 a 77 - N�mero que identifica o t�tulo na empresa [ Alterado conforme instru��es da CSO Bras�lia ] {27-07-09}
                         FormatDateTime('ddmmyyyy', Vencimento)           + // 78 a 85 - Data de vencimento do t�tulo
                         IntToStrZero( round( ValorDocumento * 100), 15)  + // 86 a 100 - Valor nominal do t�tulo
                         '00000'                                          + // 101 a 105 - Ag�ncia cobradora. // Ficando com Zeros o Ita� definir� a ag�ncia cobradora pelo CEP do sacado
                         ' '                                              + // 106 - D�gito da ag�ncia cobradora
                         PadRight(AEspecieTitulo, 2)                      + // 107 a 108 - Esp�cie do documento
                         ATipoAceite                                      + // 109 - Identifica��o de t�tulo Aceito / N�o aceito
                         FormatDateTime('ddmmyyyy', DataDocumento)        + // 110 a 117 - Data da emiss�o do documento
                         PadRight(CodigoMora, 1, '0')                     + // 118 - Codigo Mora (juros) - 1) Por dia, 2) Taxa mensal e 3) Isento
                         ADataMoraJuros                                   + //119 a 126 - Data a partir da qual ser�o cobrados juros
                         ValorMora                                        + // 127 a 141 - Valor de juros de mora por dia
                         TipoDescontoToString(TipoDesconto)               + // 142 - "C�digo do Desconto 1
                                                                            // '0'  =  N�o Conceder desconto
                                                                            // '1'  =  Valor Fixo At� a Data Informada
                                                                            // '2'  =  Percentual At� a Data Informada"
                         ADataDesconto                                    + // 143 a 150 - Data limite para desconto
                         IfThen(ValorDesconto > 0,
                                IntToStrZero( round(ValorDesconto * 100), 15),
                                PadLeft('', 15, '0'))                     + // 151 a 165 - Valor do desconto por dia
                         IntToStrZero( round(ValorIOF * 100), 15)         + // 166 a 180 - Valor do IOF a ser recolhido
                         IntToStrZero( round(ValorAbatimento * 100), 15)  + // 181 a 195 - Valor do abatimento
                         PadRight(SeuNumero, 25, ' ')                     + // 196 a 220 - Identifica��o do t�tulo na empresa
                         ProtestoBaixa                                    + // 221 - C�digo de protesto: "1"
                         DiasProtesto                                     + // 222 a 223 - Prazo para protesto (em dias corridos)
                         '0'                                              + // 224 - C�digo de Baixa
                         space(3)                                         + // 225 A 227 - Dias para baixa
                         '09'                                             + //
                         '0000000000'                                     + // Numero contrato da opera��o
                         ' ';
        Inc(i);
      {SEGMENTO Q}
      {Pegando tipo de pessoa do Sacado}
      case Sacado.Pessoa of
        pFisica  : ATipoInscricao := '1';
        pJuridica: ATipoInscricao := '2';
        pOutras  : ATipoInscricao := '9';
      end;

      {Pegando tipo de pessoa do Avalista}
      if Sacado.SacadoAvalista.CNPJCPF <> '' then
       begin
        case Sacado.SacadoAvalista.Pessoa of
          pFisica  : ATipoInscricaoAvalista := '1';
          pJuridica: ATipoInscricaoAvalista := '2';
          pOutras  : ATipoInscricaoAvalista := '9';
        end;
       end
      else
       ATipoInscricaoAvalista:= '0';

      Result:= Result + #13#10 +
               IntToStrZero(ACBrBanco.Numero, 3)                          + // C�digo do banco
               '0001'                                                     + // N�mero do lote
               '3'                                                        + // Tipo do registro: Registro detalhe
               IntToStrZero((i)+ 1 ,5)                                    + // 9 a 13 - N�mero seq�encial do registro no lote - Cada registro possui dois segmentos
               'Q'                                                        + // C�digo do segmento do registro detalhe
               ' '                                                        + // Uso exclusivo FEBRABAN/CNAB: Branco
               ATipoOcorrencia                                            + // 16 a 17 - C�digo de movimento
              {Dados do sacado}
               ATipoInscricao                                             + // 18 a 18 Tipo inscricao
               PadLeft(OnlyNumber(Sacado.CNPJCPF), 15, '0')               + // 19 a 33
               PadRight(Sacado.NomeSacado, 40, ' ')                       + // 34 a 73
               PadRight(Sacado.Logradouro + ' ' + Sacado.Numero + ' ' +
                        Sacado.Complemento, 40, ' ')                      + // 74 a 113
               PadRight(Sacado.Bairro, 15, ' ')                           + // 114 a 128
               PadLeft(Sacado.CEP, 8, '0')                                + // 129 a 136
               PadRight(Sacado.Cidade, 15, ' ')                           + // 137 a 151
               PadRight(Sacado.UF, 2, ' ')                                + // 152 a 153
                        {Dados do sacador/avalista}
               ATipoInscricaoAvalista                                     + // Tipo de inscri��o: N�o informado
               PadLeft(OnlyNumber(Sacado.SacadoAvalista.CNPJCPF),15, '0') + // N�mero de inscri��o
               PadRight(Sacado.SacadoAvalista.NomeAvalista, 30, ' ')      + // Nome do sacador/avalista
               space(10)                                                  + // Uso exclusivo FEBRABAN/CNAB
               PadRight('0',3, '0')                                       + // Uso exclusivo FEBRABAN/CNAB
               space(28);                                                   // Uso exclusivo FEBRABAN/CNAB
                Inc(i);
      //Registro detalhe R
      {Descontos 2}
       if (ValorDesconto2 > 0) then
         begin
           if(DataDesconto2 > 0) then
             ADataDesconto2 := FormatDateTime('ddmmyyyy', DataDesconto2)
           else  ADataDesconto2 := PadLeft('', 8, '0');
         end
       else
         ADataDesconto2 := PadLeft('', 8, '0');

      Result:= Result + #13#10 +
               IntToStrZero(ACBrBanco.Numero, 3)                          + // C�digo do banco
               '0001'                                                     + // N�mero do lote
               '3'                                                        + // Tipo do registro: Registro detalhe
               IntToStrZero((i)+ 1 ,5)                                    + // 9 a 13 - N�mero seq�encial do registro no lote - Cada registro possui dois segmentos
               'R'                                                        + // C�digo do segmento do registro detalhe
               ' '                                                        + // Uso exclusivo FEBRABAN/CNAB: Branco
               ATipoOcorrencia                                            + // 16 a 17 - C�digo de movimento
               TipoDescontoToString(TipoDesconto2)                        + // 18 - "C�digo do Desconto 2
                                                                            // '0'  =  N�o Conceder desconto
                                                                            // '1'  =  Valor Fixo At� a Data Informada
                                                                            // '2'  =  Percentual At� a Data Informada"
               ADataDesconto2                                             + // 19 - 26 Data limite para Desconto 2
               IfThen(ValorDesconto2 > 0,
                                IntToStrZero(Round(ValorDesconto2 * 100), 15),
                                PadLeft('', 15, '0'))                     + // 27 - 41 Valor/Percentual do Desconto 2
               '0'                                                        + // 42
               PadLeft('0', 8, '0')                                       + // 43-50 data do desconto 3
               PadLeft('0', 15, '0')                                      + // 51-65 Valor ou percentual a ser concedido
               IfThen((PercentualMulta > 0),
                       IfThen(MultaValorFixo,'1','2'), '0')               + // 66 C�digo da multa - 1 valor fixo / 2 valor percentual / 0 Sem Multa
               IfThen((DataMulta > 0),
                       FormatDateTime('ddmmyyyy', DataMulta),
                                      '00000000')                         + // 67 - 74 Se cobrar informe a data para iniciar a cobran�a ou informe zeros se n�o cobrar
               IfThen((PercentualMulta > 0),
                      IntToStrZero(round(PercentualMulta * 100), 15),
                      PadLeft('', 15, '0'))                               + // 75 - 89 Percentual de multa. Informar zeros se n�o cobrar
               space(10);                                                   // 90-99 Informa��es do sacado

               if Mensagem.Count > 0 then
               begin
                 Result :=  Result + PadRight(Copy(Mensagem[0],1,40),40);    // 100-139 Menssagem livre

                 if Mensagem.Count > 1 then
                   Result := Result + PadRight(Copy(Mensagem[1],1,40),40)    // 140-179 Menssagem livre
                 else
                   Result := Result + Space(40);
               end
               else
                 Result := Result + Space(80);

               Result := Result +
               space(20)                                                  + // 180-199 Uso da FEBRABAN "Brancos"
               PadLeft('0', 08, '0')                                      + // 200-207 C�digo oco. sacado "0000000"
               PadLeft('0', 3, '0')                                       + // 208-210 C�digo do banco na conta de d�bito "000"
               PadLeft('0', 5, '0')                                       + // 211-215 C�digo da ag. debito
               ' '                                                        + // 216 Digito da agencia
               PadLeft('0', 12, '0')                                      + // 217-228 Conta corrente para debito
               ' '                                                        + // 229 Digito conta de debito
               ' '                                                        + // 230 Dv agencia e conta
               '0'                                                        + // 231 Aviso debito automatico
               space(9);                                                    // 232-240 Uso FEBRABAN
           Inc(i);
      //Registro detalhe S
      Result:= Result + #13#10 +
               IntToStrZero(ACBrBanco.Numero, 3)  + // C�digo do banco
               '0001'                             + // N�mero do lote
               '3'                                + // Tipo do registro: Registro detalhe
               IntToStrZero((i)+ 1 ,5)            + // 9 a 13 - N�mero seq�encial do registro no lote - Cada registro possui dois segmentos
               'S'                                + // C�digo do segmento do registro detalhe
               ' '                                + // Uso exclusivo FEBRABAN/CNAB: Branco
               ATipoOcorrencia                    + // 16 a 17 - C�digo de movimento
               '3'                                + // 18 tipo impress�o
               PadRight(MsgBoleto[1], 40)+ //019	a 058	040	-	Alfa	Informa��o 5				"Mensagem 5: Texto de observa��es destinado ao envio de mensagens livres, a serem impressas no campo de instru��es da ficha de compensa��o do bloqueto.               As mensagens 5 � 9 prevalecem sobre as anteriores."
               PadRight(MsgBoleto[2], 40)+ //059	a 098	040	-	Alfa	Informa��o 6				"Mensagem 6: Texto de observa��es destinado ao envio de mensagens livres, a serem impressas no campo de instru��es da ficha de compensa��o do bloqueto.               As mensagens 5 � 9 prevalecem sobre as anteriores."
               PadRight(MsgBoleto[3], 40)+ //099	a 138	040	-	Alfa	Informa��o 7				"Mensagem 7: Texto de observa��es destinado ao envio de mensagens livres, a serem impressas no campo de instru��es da ficha de compensa��o do bloqueto.               As mensagens 5 � 9 prevalecem sobre as anteriores."
               PadRight(MsgBoleto[4], 40)+ //139	a 178	040	-	Alfa	Informa��o 8				"Mensagem 8: Texto de observa��es destinado ao envio de mensagens livres, a serem impressas no campo de instru��es da ficha de compensa��o do bloqueto.               As mensagens 5 � 9 prevalecem sobre as anteriores."
               PadRight(MsgBoleto[5], 40)+ //179	a 218	040	-	Alfa	Informa��o 9				"Mensagem 9: Texto de observa��es destinado ao envio de mensagens livres, a serem impressas no campo de instru��es da ficha de compensa��o do bloqueto.               As mensagens 5 � 9 prevalecem sobre as anteriores."
               space(22) //219 a	240	022	-	Alfa	CNAB				Uso Exclusivo FEBRABAN/CNAB: Preencher com espa�os em branco
               ;                          // 217-228 Conta corrente para debito
               Inc(i);
  end;
end;

function TACBrBancoob.GerarRegistroTrailler240(
  ARemessa: TStringList): String;
begin
  {REGISTRO TRAILER DO LOTE}
  Result:= IntToStrZero(ACBrBanco.Numero, 3)                          + //C�digo do banco
           '0001'                                                     + //N�mero do lote
           '5'                                                        + //Tipo do registro: Registro trailer do lote
           Space(9)                                                   + //Uso exclusivo FEBRABAN/CNAB
           IntToStrZero(((4 * (ARemessa.Count-1))+2), 6)              + //Quantidade de Registro da Remessa
           IntToStrZero(ARemessa.Count-1, 6)                          + // Quantidade de t�tulos em cobran�a simples
           PadLeft('',17, '0')                                        + //Valor dos t�tulos em cobran�a simples
           PadLeft('', 6, '0')                                        + //Quantidade t�tulos em cobran�a vinculada
           PadLeft('',17, '0')                                        + //Valor dos t�tulos em cobran�a vinculada
           PadLeft('',46, '0')                                        + //Complemento
           PadRight('', 8, ' ')                                       + //Referencia do aviso bancario
           space(117);
  {GERAR REGISTRO TRAILER DO ARQUIVO}
  Result:= Result + #13#10 +
           IntToStrZero(ACBrBanco.Numero, 3)                          + //C�digo do banco
           '9999'                                                     + //Lote de servi�o
           '9'                                                        + //Tipo do registro: Registro trailer do arquivo
           space(9)                                                   + //Uso exclusivo FEBRABAN/CNAB}
           '000001'                                                   + //Quantidade de lotes do arquivo}
           IntToStrZero(((4 * (ARemessa.Count-1))+4), 6)              + //Quantidade de registros do arquivo, inclusive este registro que est� sendo criado agora}
           PadLeft('', 6, '0')                                        + //Complemento
           space(205);

end;

function TACBrBancoob.CodMotivoRejeicaoToDescricao(
  const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String;
begin
  case TipoOcorrencia of
    //C�digos de rejei��es de '01' a '95' associados aos c�digos de movimento '02', '03', '26' e '30'
    toRetornoRegistroConfirmado, toRetornoRegistroRecusado,
    toRetornoInstrucaoRejeitada,toRetornoAlteracaoDadosRejeitados:
      case CodMotivo  of
        00: Result := 'Outros Motivos';
        01: Result := 'C�digo do Banco Inv�lido';
        02: Result := 'C�digo do Registro Detalhe Inv�lido';
        03: Result := 'C�digo do Segmento Inv�lido';
        04: Result := 'C�digo de Movimento N�o Permitido para Carteira';
        05: Result := 'C�digo de Movimento Inv�lido';
        06: Result := 'Tipo/N�mero de Inscri��o do Benefici�rio Inv�lidos';
        07: Result := 'Ag�ncia/Conta/DV Inv�lido';
        08: Result := 'Nosso N�mero Inv�lido';
        09: Result := 'Nosso N�mero Duplicado';
        10: Result := 'Carteira Inv�lida';
        11: Result := 'Forma de Cadastramento do T�tulo Inv�lido';
        12: Result := 'Tipo de Documento Inv�lido';
        13: Result := 'Identifica��o da Emiss�o do Boleto de Pagamento Inv�lida';
        14: Result := 'Identifica��o da Distribui��o do Boleto de Pagamento Inv�lida';
        15: Result := 'Caracter�sticas da Cobran�a Incompat�veis';
        16: Result := 'Data de Vencimento Inv�lida';
        17: Result := 'Data de Vencimento Anterior a Data de Emiss�o';
        18: Result := 'Vencimento Fora do Prazo de Opera��o';
        19: Result := 'T�tulo a Cargo de Bancos Correspondentes com Vencimento Inferior a XX Dias';
        20: Result := 'Valor do T�tulo Inv�lido';
        21: Result := 'Esp�cie do T�tulo Inv�lida';
        22: Result := 'Esp�cie do T�tulo N�o Permitida para a Carteira';
        23: Result := 'Aceite Inv�lido';
        24: Result := 'Data da Emiss�o Inv�lida';
        25: Result := 'Data da Emiss�o Posterior a Data de Entrada';
        26: Result := 'C�digo de Juros de Mora Inv�lido';
        27: Result := 'Valor/Taxa de Juros de Mora Inv�lido';
        28: Result := 'C�digo do Desconto Inv�lido';
        29: Result := 'Valor do Desconto Maior ou Igual ao Valor do T�tulo';
        30: Result := 'Desconto a Conceder N�o Confere';
        31: Result := 'Concess�o de Desconto - J� Existe Desconto Anterior';
        32: Result := 'Valor do IOF Inv�lido';
        33: Result := 'Valor do Abatimento Inv�lido';
        34: Result := 'Valor do Abatimento Maior ou Igual ao Valor do T�tulo';
        35: Result := 'Valor a Conceder N�o Confere';
        36: Result := 'Concess�o de Abatimento - J� Existe Abatimento Anterior';
        37: Result := '�digo para Protesto Inv�lido';
        38: Result := 'Prazo para Protesto Inv�lido';
        39: Result := 'Pedido de Protesto N�o Permitido para o T�tulo';
        40: Result := 'T�tulo com Ordem de Protesto Emitida';
        41: Result := 'Pedido de Cancelamento/Susta��o para T�tulos sem Instru��o de Protesto';
        42: Result := 'C�digo para Baixa/Devolu��o Inv�lido';
        43: Result := 'Prazo para Baixa/Devolu��o Inv�lido';
        44: Result := 'C�digo da Moeda Inv�lido';
        45: Result := 'Nome do Pagador N�o Informado';
        46: Result := 'Tipo/N�mero de Inscri��o do Pagador Inv�lidos';
        47: Result := 'Endere�o do Pagador N�o Informado';
        48: Result := 'CEP Inv�lido';
        49: Result := 'CEP Sem Pra�a de Cobran�a (N�o Localizado)';
        50: Result := 'CEP Referente a um Banco Correspondente';
        51: Result := 'CEP incompat�vel com a Unidade da Federa��o';
        52: Result := 'Unidade da Federa��o Inv�lida';
        53: Result := 'Tipo/N�mero de Inscri��o do Sacador/Avalista Inv�lidos';
        54: Result := 'Sacador/Avalista N�o Informado';
        55: Result := 'Nosso n�mero no Banco Correspondente N�o Informado';
        56: Result := 'C�digo do Banco Correspondente N�o Informado';
        57: Result := 'C�digo da Multa Inv�lido';
        58: Result := 'Data da Multa Inv�lida';
        59: Result := 'Valor/Percentual da Multa Inv�lido';
        60: Result := 'Movimento para T�tulo N�o Cadastrado';
        61: Result := 'Altera��o da Ag�ncia Cobradora/DV Inv�lida';
        62: Result := 'Tipo de Impress�o Inv�lido';
        63: Result := 'Entrada para T�tulo j� Cadastrado';
        64: Result := 'N�mero da Linha Inv�lido';
        65: Result := 'C�digo do Banco para D�bito Inv�lido';
        66: Result := 'Ag�ncia/Conta/DV para D�bito Inv�lido';
        67: Result := 'Dados para D�bito incompat�vel com a Identifica��o da Emiss�o do Boleto de Pagamento';
        68: Result := 'D�bito Autom�tico Agendado';
        69: Result := 'D�bito N�o Agendado - Erro nos Dados da Remessa';
        70: Result := 'D�bito N�o Agendado - Pagador N�o Consta do Cadastro de Autorizante';
        71: Result := 'D�bito N�o Agendado - Benefici�rio N�o Autorizado pelo Pagador';
        72: Result := 'D�bito N�o Agendado - Benefici�rio N�o Participa da Modalidade D�bito Autom�tico';
        73: Result := 'D�bito N�o Agendado - C�digo de Moeda Diferente de Real (R$)';
        74: Result := 'D�bito N�o Agendado - Data Vencimento Inv�lida';
        75: Result := 'D�bito N�o Agendado, Conforme seu Pedido, T�tulo N�o Registrado';
        76: Result := 'D�bito N�o Agendado, Tipo/Num. Inscri��o do Debitado, Inv�lido';
        77: Result := 'Transfer�ncia para Desconto N�o Permitida para a Carteira do T�tulo';
        78: Result := 'Data Inferior ou Igual ao Vencimento para D�bito Autom�tico';
        79: Result := 'Data Juros de Mora Inv�lido';
        80: Result := 'Data do Desconto Inv�lida';
        81: Result := 'Tentativas de D�bito Esgotadas - Baixado';
        82: Result := 'Tentativas de D�bito Esgotadas - Pendente';
        83: Result := 'Limite Excedido';
        84: Result := 'N�mero Autoriza��o Inexistente';
        85: Result := 'T�tulo com Pagamento Vinculado';
        86: Result := 'Seu N�mero Inv�lido';
        87: Result := 'e-mail/SMS enviado';
        88: Result := 'e-mail Lido';
        89: Result := 'e-mail/SMS devolvido - endere�o de e-mail ou n�mero do celular incorreto �90�= e-mail devolvido - caixa postal cheia';
        91: Result := 'e-mail/n�mero do celular do Pagador n�o informado';
        92: Result := 'Pagador optante por Boleto de Pagamento Eletr�nico - e-mail n�o enviado';
        93: Result := 'C�digo para emiss�o de Boleto de Pagamento n�o permite envio de e-mail';
        94: Result := 'C�digo da Carteira inv�lido para envio e-mail.';
        95: Result := 'Contrato n�o permite o envio de e-mail';
        96: Result := 'N�mero de contrato inv�lido';
        97: Result := 'Rejei��o da altera��o do prazo limite de recebimento (a data deve ser informada no campo 28.3.p)';
        98: Result := 'Rejei��o de dispensa de prazo limite de recebimento';
        99: Result := 'Rejei��o da altera��o do n�mero do t�tulo dado pelo Benefici�rio';
        101 { A1 } : Result := 'Rejei��o da altera��o do n�mero controle do participante';
        102 { A2 } : Result := 'Rejei��o da altera��o dos dados do Pagador';
        103 { A3 } : Result := 'Rejei��o da altera��o dos dados do Sacador/avalista';
        104 { A4 } : Result := 'Pagador DDA';
        105 { A5 } : Result := 'Registro Rejeitado � T�tulo j� Liquidado';
        106 { A6 } : Result := 'C�digo do Convenente Inv�lido ou Encerrado';
        107 { A7 } : Result := 'T�tulo j� se encontra na situa��o Pretendida';
        108 { A8 } : Result := 'Valor do Abatimento inv�lido para cancelamento';
        109 { A9 } : Result := 'N�o autoriza pagamento parcial';
        201 { B1 } : Result := 'Autoriza recebimento parcial';
        202 { B2 } : Result := 'Valor Nominal do T�tulo Conflitante';
        203 { B3 } : Result := 'Tipo de Pagamento Inv�lido';
        204 { B4 } : Result := 'Valor M�ximo/Percentual Inv�lido';
        205 { B5 } : Result := 'Valor M�nimo/Percentual Inv�lido';
        else
          Result := IntToStrZero(CodMotivo, 2) + ' - Outros Motivos';
      end;

    //C�digos de tarifas / custas de '01' a '20' associados ao c�digo de movimento '28'
    toRetornoDebitoTarifas:
      case CodMotivo of
        01: Result := 'Tarifa de Extrato de Posi��o';
        02: Result := 'Tarifa de Manuten��o de T�tulo Vencido';
        03: Result := 'Tarifa de Susta��o';
        04: Result := 'Tarifa de Protesto';
        05: Result := 'Tarifa de Outras Instru��es';
        06: Result := 'Tarifa de Outras Ocorr�ncias';
        07: Result := 'Tarifa de Envio de Duplicata ao Pagador';
        08: Result := 'Custas de Protesto';
        09: Result := 'Custas de Susta��o de Protesto';
        10: Result := 'Custas de Cart�rio Distribuidor';
        11: Result := 'Custas de Edital';
        12: Result := 'Tarifa Sobre Devolu��o de T�tulo Vencido';
        13: Result := 'Tarifa Sobre Registro Cobrada na Baixa/Liquida��o';
        14: Result := 'Tarifa Sobre Reapresenta��o Autom�tica';
        15: Result := 'Tarifa Sobre Rateio de Cr�dito';
        16: Result := 'Tarifa Sobre Informa��es Via Fax';
        17: Result := 'Tarifa Sobre Prorroga��o de Vencimento';
        18: Result := 'Tarifa Sobre Altera��o de Abatimento/Desconto';
        19: Result := 'Tarifa Sobre Arquivo mensal (Em Ser)';
        20: Result := 'Tarifa Sobre Emiss�o de Boleto de Pagamento Pr�-Emitido pelo Banco';
        else
          Result := IntToStrZero(CodMotivo, 2) + ' - Outros Motivos';
      end;

    //C�digos de liquida��o / baixa de '01' a '15' associados aos c�digos de movimento '06', '04'. '09' e '17'
    toRetornoLiquidado, toRetornoTransferenciaCarteira, toRetornoBaixaSimples,
    toRetornoLiquidadoAposBaixaOuNaoRegistro:
      case CodMotivo of
        //Liquida��o
        01: Result := 'Por Saldo';
        02: Result := 'Por Conta';
        03: Result := 'Liquida��o no Guich� de Caixa em Dinheiro';
        04: Result := 'Compensa��o Eletr�nica';
        05: Result := 'Compensa��o Convencional';
        06: Result := 'Por Meio Eletr�nico';
        07: Result := 'Ap�s Feriado Local';
        08: Result := 'Em Cart�rio';
        30: Result := 'Liquida��o no Guich� de Caixa em Cheque';
        31: Result := 'Liquida��o em banco correspondente';
        32: Result := 'Liquida��o Terminal de Auto-Atendimento';
        33: Result := 'Liquida��o na Internet (Home banking)';
        34: Result := 'Liquidado Office Banking';
        35: Result := 'Liquidado Correspondente em Dinheiro';
        36: Result := 'Liquidado Correspondente em Cheque';
        37: Result := 'Liquidado por meio de Central de Atendimento (Telefone)';
        // Baixa
        09: Result := 'Comandada Banco';
        10: Result := 'Comandada Cliente Arquivo';
        11: Result := 'Comandada Cliente On-line';
        12: Result := 'Decurso Prazo - Cliente';
        13: Result := 'Decurso Prazo - Banco';
        14: Result := 'Protestado';
        15: Result := 'T�tulo Exclu�do';
        else
          Result := IntToStrZero(CodMotivo, 2) + ' - Outros Motivos';
      end;
  end;

end;

function TACBrBancoob.CodOcorrenciaToTipo(
  const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
      02: Result := toRetornoRegistroConfirmado;
      03: Result := toRetornoRegistroRecusado;
      04: Result := toRetornoTransferenciaCarteiraEntrada;
      05: Result := toRetornoTransferenciaCarteiraBaixa;
      06: Result := toRetornoLiquidado;
      07: Result := toRetornoRecebimentoInstrucaoConcederDesconto;
      08: Result := toRetornoRecebimentoInstrucaoCancelarDesconto;
      09: Result := toRetornoBaixaSimples;
      10: Result := toRetornoBaixaSolicitada;
      11: Result := toRetornoTituloEmSer;
      12: Result := toRetornoAbatimentoConcedido;
      13: Result := toRetornoAbatimentoCancelado;
      14: Result := toRetornoVencimentoAlterado;
      15: Result := toRetornoLiquidadoEmCartorio;
      17: Result := toRetornoLiquidadoAposBaixaOuNaoRegistro;
      19: Result := toRetornoRecebimentoInstrucaoProtestar;
      20: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
      21: Result := toRetornoRecebimentoInstrucaoProtestar;
      23: Result := toRetornoEncaminhadoACartorio;
      24: Result := toRetornoInstrucaoProtestoRejeitadaSustadaOuPendente;
      25: Result := toRetornoBaixaPorProtesto;
      26: Result := toRetornoInstrucaoRejeitada;
      27: Result := toRetornoDadosAlterados;
      28: Result := toRetornoDebitoTarifas;
      30: Result := toRetornoAlteracaoDadosRejeitados;
      40: Result := toRetornoRecebimentoInstrucaoAlterarTipoCobranca;
      42: Result := toRetornoRecebimentoInstrucaoAlterarTipoCobranca;
      43: Result := toRetornoRecebimentoInstrucaoAlterarTipoCobranca;
      48: Result := toRetornoConfInstrucaoTransferenciaCarteiraModalidadeCobranca;
      51: Result := toRetornoTarifaMensalRefEntradasBancosCorrespCarteira;
      52: Result := toRetornoTarifaMensalBaixasCarteira;
      53: Result := toRetornoTarifaMensalBaixasBancosCorrespCarteira;
      98: Result := toRetornoProtestado;
      99: Result := toRetornoRegistroRecusado;

   else
      Result := toRetornoOutrasOcorrencias;
   end;

end;

function TACBrBancoob.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    08 : Result:= toRemessaAlterarNumeroControle;           {Altera��o de seu n�mero}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    10 : Result:= toRemessaCancelarInstrucaoProtestoBaixa;  {Instru��o para sustar protesto}
    11 : Result:= toRemessaDispensarJuros;                  {Instru��o para dispensar juros}
    12 : Result:= toRemessaAlterarDadosPagador;             {Altera��o de Pagador}
    31 : Result:= toRemessaOutrasOcorrencias;               {Altera��o de Outros Dados}
    34 : Result:= toRemessaBaixaporPagtoDiretoCedente;      {Baixa - Pagamento Direto ao Benefici�rio}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

function TACBrBancoob.TipoOCorrenciaToCod(
  const TipoOcorrencia: TACBrTipoOcorrencia): String;
begin
  case TipoOcorrencia of
      toRetornoRegistroConfirmado                           : Result :='02';
      toRetornoRegistroRecusado                             : Result :='03';
      toRetornoTransferenciaCarteiraEntrada                 : Result :='04';
      toRetornoTransferenciaCarteiraBaixa                   : Result :='05';
      toRetornoLiquidado                                    : Result :='06';
      toRetornoBaixaTransferenciaParaDesconto               : Result :='07';
      toRetornoBaixaSimples                                 : Result :='09';
      toRetornoBaixaSolicitada                              : Result :='10';
      toRetornoTituloEmSer                                  : Result :='11';
      toRetornoAbatimentoConcedido                          : Result :='12';
      toRetornoAbatimentoCancelado                          : Result :='13';
      toRetornoVencimentoAlterado                           : Result :='14';
      toRetornoLiquidadoEmCartorio                          : Result :='15';
      toRetornoRecebimentoInstrucaoProtestar                : Result :='19';
      toRetornoDebitoEmConta                                : Result :='20';
      toRetornoNomeSacadoAlterado                           : Result :='21';
      toRetornoEnderecoSacadoAlterado                       : Result :='22';
      toRetornoEncaminhadoACartorio                         : Result :='23';
      toRetornoInstrucaoProtestoRejeitadaSustadaOuPendente  : Result :='24';
      toRetornoRecebimentoInstrucaoDispensarJuros           : Result :='25';
      toRetornoInstrucaoRejeitada                           : Result :='26';
      toRetornoDadosAlterados                               : Result :='27';
      toRetornoManutencaoTituloVencido                      : Result :='28';
      toRetornoAlteracaoDadosRejeitados                     : Result :='30';
      toRetornoConfInstrucaoTransferenciaCarteiraModalidadeCobranca : Result :='48';
      toRetornoDespesasProtesto                             : Result :='96';
      toRetornoDespesasSustacaoProtesto                     : Result :='97';
      toRetornoDebitoCustasAntecipadas                      : Result :='98';
   else
      Result:= '02';
   end;

end;

function TACBrBancoob.TipoOcorrenciaToDescricao(
  const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
   CodOcorrencia: Integer;
begin
   CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia),0);

   case CodOcorrencia of
      02: Result:='02-CONFIRMA��O ENTRADA T�TULO' ;
      03: Result:='03-COMANDO RECUSADO' ;
      04: Result:='04-TRANSFERENCIA DE CARTEIRA - ENTRADA' ;
      05: Result:='05-LIQUIDA��O SEM REGISTRO';
      06: Result:='06-LIQUIDA��O NORMAL' ;
      09: Result:='09-BAIXA DE T�TULO' ;
      10: Result:='10-BAIXA SOLICITADA';
      11: Result:='11-T�TULOS EM SER' ;
      12: Result:='12-ABATIMENTO CONCEDIDO' ;
      13: Result:='13-ABATIMENTO CANCELADO' ;
      14: Result:='14-ALTERA��O DE VENCIMENTO' ;
      15: Result:='15-LIQUIDA��O EM CART�RIO' ;
      19: Result:='19-CONFIRMA��O INSTRU��O PROTESTO' ;
      20: Result:='20-D�BITO EM CONTA' ;
      21: Result:='21-ALTERA��O DE NOME DO SACADO' ;
      22: Result:='22-ALTERA��O DE ENDERE�O SACADO' ;
      23: Result:='23-ENCAMINHADO A PROTESTO' ;
      24: Result:='24-SUSTAR PROTESTO' ;
      25: Result:='25-DISPENSAR JUROS' ;
      26: Result:='26-INSTRU��O REJEITADA' ;
      27: Result:='27-CONFIRMA��O ALTERA��O DADOS' ;
      28: Result:='28-MANUTEN��O T�TULO VENCIDO' ;
      30: Result:='30-ALTERA��O DADOS REJEITADA' ;
      48: Result:='48-CONFIRMA��O INSTR. TRANSFERENCIA DE CARTEIRA';
      96: Result:='96-DESPESAS DE PROTESTO' ;
      97: Result:='97-DESPESAS DE SUSTA��O DE PROTESTO' ;
      98: Result:='98-DESPESAS DE CUSTAS ANTECIPADAS' ;
   end;

end;

end.
