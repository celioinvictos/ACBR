CLS
ECHO OFF
ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO �  Esse arquivo de Lote permite demonstarar o funcionamento do  �
ECHO �  ACBrMonitor monitorando arquivos TXT.                        �
ECHO �                                                               �
ECHO �  - O ACBrMonitor deve estar configurado para TXT              �
ECHO �  - O arquivo de Entrada deve ser ENT.TXT e o de saida SAI.TXT �
ECHO �  - Configure e Teste o MODELO e PORTA do ECF no ACBrMonitor   �
ECHO �  - Deixe o ACBrmonitor Aberto para visualizar as Respostas    �
ECHO �                                                               �
ECHO � Pressione CTRL-C para interromper ou ENTER para continuar     �
ECHO �       ( Ligue e configure o ECF antes de continuar )          �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
pause

:ATIVAR
ECHO *** Ativando o ECF ***
ECHO ECF.Ativar > ..\ENT.TXT

:INICIO
ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
ECHO �  0 - Ativar ACBrECF                    �
ECHO �  1 - Imprime uma Leitura X             �
ECHO �  2 - Imprime uma Cupom Fiscal          �
ECHO �  3 - Cancela o Ultimo Cupom            �
ECHO �  4 - Retorna Informacoes da Impressora �
ECHO �  5 - Reducao Z                         �
ECHO �                                        �
ECHO �  9 - Voltar para o DOS                 �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
choice /c:0123459

if errorlevel 7 GOTO FIM
if errorlevel 6 GOTO REDUCAOZ
if errorlevel 5 GOTO INFO
if errorlevel 4 GOTO CANCELA
if errorlevel 3 GOTO CUPOM
if errorlevel 2 GOTO LEITURAX
if errorlevel 1 GOTO ATIVAR

GOTO INICIO

:REDUCAOZ
ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
ECHO �  Deseja realmente imprimir uma REDUCAO Z ? �
ECHO �                                            �
ECHO �        1 - S I M      2 - N A O            �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
choice /c:12

if errorlevel 2 GOTO INICIO

ECHO ECF.ReducaoZ > ..\ENT.TXT
GOTO INICIO

:LEITURAX
ECHO ECF.LeituraX > ..\ENT.TXT
GOTO INICIO

:CUPOM
REM *** Criando Arquivo ENT.TMP (temporario) com todos os comandos ***
ECHO ECF.AbreCupom("12345678901")  > ENT.TMP
ECHO ECF.VendeItem("789012456789","PRODUTO TESTE, ISENTO","II", 1.5, 2.5 ) >> ENT.TMP
ECHO ECF.VendeItem("789012223233","PRODUTO TESTE, TRIBUTADO","18", 1, 100, 10, "LT" ) >> ENT.TMP
ECHO ECF.VendeItem("789012443434","PRODUTO COM A DESCRICAO GRANDE. M U I T O   G R A N D E   SERA QUE IMPRIME TUDO ?","18", 1, 5, 0, "UN" ) >> ENT.TMP
ECHO ECF.SubTotalizaCupom(-0.75) >> ENT.TMP
ECHO ECF.EfetuaPagamento("01",100,"DEVE VOLTAR TROCO DE 1,25") >> ENT.TMP
ECHO ECF.FechaCupom("Componentes ACBr|http://acbr.sourceforge.net") >> ENT.TMP

REM *** copiando para o arquivo de Entrada **
copy ENT.TMP ..\ENT.TXT

GOTO INICIO

:CANCELA
ECHO ECF.CancelaCupom > ..\ENT.TXT
GOTO INICIO

:INFO
del ..\SAI.TXT
cls
ECHO ECF.DataHora >  ENT.TMP
ECHO ECF.NumCupom >> ENT.TMP
ECHO ECF.NumSerie >> ENT.TMP
copy ENT.TMP ..\ENT.TXT

ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
ECHO � Pressione ENTER para ver         �
ECHO � DataHora,  NumCupom  e  NumSerie �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pause

type ..\SAI.TXT
GOTO INICIO

:FIM
ECHO FIM >> ..\ENT.TXT
