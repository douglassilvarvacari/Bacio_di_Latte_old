﻿#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
                                

/*/
   {Protheus.doc} blintstq
   Funcao para gravar os dados dos cupons de venda nas tabelas do motor padr�o TOTVS
   @author  Nome Renan Paiva
   @author  Nome Rodolfo Vacari
   @example Exemplos
   @param   [Nome_do_Parametro],Tipo_do_Parametro,Descricao_do_Parametro
   @return  Especifica_o_retorno
   @table   Tabelas
   @since   27-02-2019
   Revisado 29-07-2019
/*/

USER FUNCTION blintstq
RETURN
WSRESTFUL Vendas DESCRIPTION "Servico Rest para Integracaoo de Vendas"
WSMETHOD POST CUPONS DESCRIPTION "Metodo responsavel por incluir os cupons" WSSYNTAX "/cupons" PATH "/cupons"
//WSMETHOD POST DESCRIPTION "Metodo responsavel por incluir as reducoes Z" WSSYNTAX "/reducao" PATH "/reducao"
END WSRESTFUL
WSMETHOD POST CUPONS WSSERVICE Vendas
local _cBody := ::GetContent()//retorna o conteudo do body da requisicao
local i
local _nRecPIN := 0
local _cError := ""
local _oError := ErrorBlock({|e| _cError := e:Description + e:ErrorStack})
local _oCodexRet := JsonObject():New()
local i := 1
local _cJson := ""
_oCodexRet['XCODEXES'] := JsonObject():New()
_oCodexRet['XCODEXES'] := {}
private _oData
Private _nXRecno := 0
Private _nPICM := 0

::SetContentType("application/json")
if !FWJsonDeserialize(_cBody, @_oData)		
	//Retorna BadRequest
	SetRestFault(400, "ERROR ON DESERIALIZE JSON, VERIFY JSON ON BODY")
	return .F.
endif

//Ajuste pela Equipe TOTVS - 06-08-2019
//Reunião com o Paulo Santos da TOTVS
If Intransaction()
    DisarmTransaction()
    SetRestFault(500, '{"erro - Thread em Aberto"}')
    ConOut("Erro - Thread em aberto...")   
	return .F.
EndIf
//FIM ajuste

begin sequence
for i:=1 to len(_oData:Orcamento )
    BEGIN TRANSACTION
    _cXCodeX := _oData:Orcamento[i]:xCodex
    	_nRecPIN := GravaPIN(_oData:Orcamento[i], _cXCodeX)
    	GravaPIO(_oData:Orcamento[i]:Items, _oData:Orcamento[i]:Filial, _oData:Orcamento[i]:ChaveNFCe, _nRecPIN, _cXCodeX)
    	GravaPIP(_oData:Orcamento[i]:Pagamentos, _nRecPIN, _cXCodeX)
    aAdd(_oCodexRet['XCODEXES'], JsonObject():New())
    _oCodexRet['XCODEXES'][i]['XCODEX'] := _cXCodeX //RETORNO DO XCODEX
    _oCodexRet['XCODEXES'][i]['RECNO'] := _nXRecno //rETORNO DO RECNO 
    i++
    END TRANSACTION
next
end sequence
ErrorBlock(_oError)
if !empty(_cError)
    SetRestFault(500, '{"erro":"' + _cError + '"}')
    ConOut("Erro na API Vendas...Error - xCodexs - "+_cXCodeX)   
    DisarmTransaction()
	return .F.
endif
//Serializa os codex e faz o retorno
_cJson := FWJsonSerialize(_oCodexRet, .F., .F., .T.)
::SetResponse(_cJson)
return .t.
static function GravaPIN(Orcamento, _cXCodeX)

//validacao de inclusão do registro PIN
//Atualizado dia 29-08-19
reclock("PIN", .T.)
PIN->PIN_FILIAL := Orcamento:Filial
PIN->PIN_NUM	:= IF(ALLTRIM(Orcamento:Orcamento)=="\N",STRZERO(VAL(Orcamento:NotaFiscal),6),STRZERO(VAL(Orcamento:Orcamento ),6))
PIN->PIN_VEND	:= "000001"
PIN->PIN_CLIENT	:= "000001"
PIN->PIN_LOJA	:= Orcamento:Filial //Left(Orcamento:NumeroPDV,4)
PIN->PIN_TIPOCL	:= "F"
PIN->PIN_VLRTOT	:= Orcamento:ValorTotal	
PIN->PIN_VLRLIQ	:= Orcamento:ValorLiquido
PIN->PIN_DOC	:= Orcamento:NotaFiscal
PIN->PIN_EMISNF	:= STOD( Orcamento:Emissao )
PIN->PIN_PDV	:= Orcamento:NumeroPDV
PIN->PIN_VALBRU	:= Orcamento:ValorBrutoNF	
PIN->PIN_VALMER	:= Orcamento:ValorMercadoria
PIN->PIN_TIPO	:= "V"
PIN->PIN_OPERAD	:= "001"
PIN->PIN_DINHEI	:= IIF ( Orcamento:Dinheiro > 0, Orcamento:Entrada, 0) 
PIN->PIN_CARTAO	:= IIF ( Orcamento:Dinheiro == 0, Orcamento:Entrada, 0)
PIN->PIN_ENTRAD	:= Orcamento:Entrada
PIN->PIN_PARCEL	:= 1
PIN->PIN_CONDPG	:= "CN"
PIN->PIN_EMISSA	:= STOD( Orcamento:Emissao )
PIN->PIN_NUMCFI	:= Orcamento:CupomFiscal
PIN->PIN_VENDTE	:= IIF( Orcamento:Dinheiro > 0, "N", "S")
					
If PIN->PIN_VENDTE == "S"
    PIN->PIN_DATATE	:=	Orcamento:Emissao
EndIf  
					
PIN->PIN_HORATE	:= IIF( Orcamento:Dinheiro > 0, "", Orcamento:HoraTEF )
PIN->PIN_SITUA	:= "RX"
PIN->PIN_CGCCLI	:= Orcamento:CPFCNPJ
PIN->PIN_ESTACA	:= "001"  //IIF( EMPTY( SLG->LG_CODIGO ) , "001", SLG->LG_CODIGO) /*TODO*/
PIN->PIN_KEYNFC	:= Orcamento:ChaveNFCe
PIN->PIN_SERSAT	:= Orcamento:SerieSat // verifica a serie do SAT
PIN->PIN_ESPECI := Iif(!EMPTY(Orcamento:SerieSat), "SATCE", "")
PIN->PIN_SERIE	:= Iif(!EMPTY(Orcamento:SerieSat), "", STRZERO(VAL(Orcamento:Serie),3)) //Atualizado com 3 posicoes
PIN->PIN_DESCON	:= Orcamento:Desconto
PIN->PIN_BRICMS	:= Orcamento:BaseICMSSol
PIN->PIN_VALICM	:= Orcamento:ValICMS
PIN->PIN_VALPIS	:= Orcamento:ValPIS
PIN->PIN_VALCOF	:= Orcamento:ValCOF
PIN->PIN_TPORC	:= "E" 
PIN->PIN_XTPREG	:= "5"
PIN->PIN_DATIMP	:= Date() 
PIN->PIN_DATEXP	:= STOD( Orcamento:Emissao ) //importacao do documento
PIN->PIN_CODORI	:= "2"
PIN->PIN_CODDES	:= "1"
PIN->PIN_ACAO	:= "1"
PIN->PIN_STAIMP	:= ""
PIN->PIN_RECCAB := PIN->(Recno()) //será utilizado para as tabelas PIO e PIP.
PIN->PIN_PROTHE	:= "PIN_FILIAL+PIN_NUM+PIN_PDV"
PIN->PIN_LJORI	:= SUBSTR ( ALLTRIM(Orcamento:NumeroPDV ),1,4)  //cValtoChar (VAL( SUBSTR ( ALLTRIM(Orcamento:NumeroPDV ),1,4) ) )  					
PIN->PIN_CXOR	:= SUBSTR ( ALLTRIM(Orcamento:NumeroPDV ),5,2)  //cValtoChar (VAL (SUBSTR ( ALLTRIM(Orcamento:NumeroPDV ),5,2) ) ) 		
PIN->PIN_CNPJOR	:= SUBSTR( Orcamento:ChaveNFCe,7,14)
PIN->PIN_CHVORI	:= Orcamento:Filial + SUBSTR( Orcamento:ChaveNFCe,7,14) + ALLTRIM( Orcamento:NotaFiscal ) + DTOS(DATE()) + SUBSTR(TIME(),1,2)  
PIN->PIN_XCODEX	:= _cXCodeX
PIN->PIN_ORIGEM	:= "N"
_nXRecno := PIN->(Recno())

MsUnlock()

return _nXRecno
static function GravaPIO(_oItems, _cFilial, _cChaveNFCe, _nRecPIO, _cXCodeX)
local x
for x := 1 to len( _oItems)
Posicione("SB1", 1, XFILIAL("SB1") + _oItems[x]:Produto, "B1_DESC")
reclock("PIO", .T.)

PIO->PIO_FILIAL	:= _cFilial
PIO->PIO_NUM	:= STRZERO ( VAL( _oItems[x]:NotaFiscal ) ,6) //Numero do Cupom Fiscal
PIO->PIO_PRODUT	:= _oItems[x]:Produto
PIO->PIO_ITEM	:= STRZERO(Val(_oItems[x]:Item), 2)
PIO->PIO_QUANT	:= _oItems[x]:Quantidade
PIO->PIO_VRUNIT	:= _oItems[x]:PrcUnit
PIO->PIO_VLRITE	:= _oItems[x]:VlrItem
PIO->PIO_DESC	:= 0 
PIO->PIO_LOCAL	:= "01"
PIO->PIO_UM		:= SB1->B1_UM
PIO->PIO_TES	:= "XXX"
PIO->PIO_CF		:= _oItems[x]:CFOP
PIO->PIO_VENDID	:= "S"
PIO->PIO_DOC	:= _oItems[x]:NotaFiscal
PIO->PIO_PDV	:= _oItems[x]:NumPdv
PIO->PIO_EMISSA	:= STOD( _oItems[x]:Emissao )
PIO->PIO_VALICM	:= _oItems[x]:ValICMS
PIO->PIO_BASEIC	:= _oItems[x]:BaseICMS
PIO->PIO_PICM	:= _oItems[x]:AliqICMS //valor encaminhado a partir do dia 01/10/2019
PIO->PIO_VALPS2	:= _oItems[x]:ValPIS
PIO->PIO_VALCF2	:= _oItems[x]:ValCOF
PIO->PIO_BASEPS	:= _oItems[x]:BasePIS
PIO->PIO_BASECF	:= _oItems[x]:BaseCOF
PIO->PIO_ALIQPS	:= _oItems[x]:AliqPIS
PIO->PIO_ALIQCF	:= _oItems[x]:AliqCOF					
PIO->PIO_PRCTAB	:= _oItems[x]:PrcTabela
PIO->PIO_VEND	:= "000001"
PIO->PIO_SITUA	:= "RX"
PIO->PIO_SITTRI	:= "T" + STRTRAN(  cValToChar( _oItems[x]:AliqICMS /10), ".","") + REPLICATE("0", 4 - Len( STRTRAN(  cValToChar( _oItems[x]:AliqICMS /10), ".","") ) ) //"T0300" Alterado dia 04/11/2019
PIO->PIO_DATEXP	:= STOD( _oItems[x]:Emissao )
PIO->PIO_DATIMP	:= Date()
PIO->PIO_CODORI	:= "2"
PIO->PIO_CODDES	:= "1"
PIO->PIO_STAIMP	:= ""
PIO->PIO_PROTHE	:= "PIO_RECCAB"
PIO->PIO_ACAO	:= "1"
PIO->PIO_DESCRI	:= SB1->B1_DESC
PIO->PIO_XTPREG	:= "5"
PIO->PIO_LJORI	:= SUBSTR(ALLTRIM( _oItems[x]:NumPdv),1,4)  // cValtoChar (VAL( SUBSTR ( ALLTRIM( _oItems[x]:NumPdv ),1,4) ) ) 
PIO->PIO_CNPJOR	:= SUBSTR ( _cChaveNFCe,7,14 )
PIO->PIO_CHVORI	:= _cFilial + SUBSTR( _cChaveNFCe,7,14) + ALLTRIM( _oItems[x]:NotaFiscal ) + DTOS(DATE()) + SUBSTR(TIME(),1,2) 
PIO->PIO_RECCAB	:= _nRecPIO //caso não tenha o RECCAB
PIO->PIO_XCODEX	:= _cXCodeX
PIO->PIO_CODORI	:= '2' 
PIO->PIO_CODDES := '1'
PIO->PIO_ACAO	:= "1"
MsUnLock()
next
return .t.
static function GravaPIP(_oPagamentos, _nRecPIO, _cXCodeX)
x := 1
for x := 1 to len(_oPagamentos)
reclock("PIP", .t.)
PIP->PIP_FILIAL	:= _oPagamentos[x]:Filial
PIP->PIP_NUM	:= STRZERO ( VAL( _oPagamentos[x]:Orcamento ) ,6)
PIP->PIP_DATA	:= STOD( _oPagamentos[x]:Emissao )
PIP->PIP_VALOR	:= _oPagamentos[x]:Valor
PIP->PIP_FORMA	:= IIF(ALLTRIM(_oPagamentos[x]:FormaPagto) != "",_oPagamentos[x]:FormaPagto,"R$")
PIP->PIP_ADMINI	:= _oPagamentos[x]:AdmFin
PIP->PIP_HORATE	:= IIF( _oPagamentos[x]:DocTEF != "", _oPagamentos[x]:HoraTrans, "" )
PIP->PIP_NSUTEF	:= _oPagamentos[x]:NSUTEF
PIP->PIP_VENDTE	:= IIF( _oPagamentos[x]:NSUTEF != "", "S", "N")
PIP->PIP_DATEXP	:= STOD( _oPagamentos[x]:Emissao )
PIP->PIP_DATIMP	:= Date()
PIP->PIP_CODORI	:= "2"
PIP->PIP_CODDES	:= "1"
PIP->PIP_STAIMP	:= ""
PIP->PIP_PROTHE	:= "PIP_FILIAL+PIP_NUM+PIP_ORIGEM"
PIP->PIP_ACAO	:= "1"
PIP->PIP_PDV	:= _oPagamentos[x]:PDV 
PIP->PIP_XTPREG	:= "5"	
PIP->PIP_CHVORI	:= _oPagamentos[x]:Filial + _oPagamentos[x]:CNPJFilOri + ALLTRIM( _oPagamentos[x]:Orcamento ) + DTOS( DATE()) + SUBSTR( TIME(),1,2) 
PIP->PIP_CNPJOR	:= _oPagamentos[x]:CNPJFilOri
PIP->PIP_LJORI	:= SUBSTR(ALLTRIM(_oPagamentos[x]:PDV ),1,4)   //cValtoChar (VAL( SUBSTR ( ALLTRIM(_oPagamentos[x]:PDV ),1,4) ) )
PIP->PIP_XCODEX	:= _cXCodeX
PIP->PIP_CODORI	:= '2'
PIP->PIP_CODDES := '1'
PIP->PIP_ACAO 	:= "1" 
PIP->PIP_RECCAB := _nRecPIO //caso não tenha o RECCAB
MsUnLock()
//ConOut("PAGTO...xCodexs-"+_cXCodeX+" - RECCAB:"+str(_nRecPIO))
next
return .t.