#include 'protheus.ch'
#include 'parmtype.ch'
#include "restful.CH"

//dummy function para reservar o nome do fonte
user function InvProduto()
return

/*/{Protheus.doc} InvProd
Classe para retornar os produtos com as informa��es pertinentes as convers�es
dos poss�veis padr�es de embalagem. 
Ex: Copo 
UM1   Caixa - UM2   Fardo - UM3   Unidade
Conv1  5000   Conv2   200   Conv3       1 
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@UpGrade Rodolfo Vacari <rodolfo.vacari@mobibytes.com.br> -- 02-09-2019
@since 05/09/2018
/*/
class InvProd
	
	data produto as string
	data descricao as string
	data bloqueado as logical
	data UM as string
	data conv1 as numeric
	data conv2 as numeric
	data conv3 as numeric
	data UM1 as string
	data UM2 as string
	data UM3 as string	
	
	method new(cCodigo, cDescricao, lStatus, UM, nConv1, nConv2, nConv3, UM1, UM2, UM3) constructor 
endclass
/*/{Protheus.doc} new
M�todo construtor da classe InvProd
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 10/09/2018
@param cCodigo, characters, codigo do produto B1_COD
@param cDescricao, characters, descricao do produto B1_DESC
@param lStatus, logical, indica se o produto est� bloqueado
@param nConv1, numeric, conversor 1 
@param nConv2, numeric, conversor 2
@param nConv3, numeric, conversor 3
@param UM1, characters, unidade de medida conversor 1
@param UM2, characters, unidade de medida conversor 2
@param UM3, characters, unidade de medida conversor 1
@param nConvProt, numeric, conversor da UM 3 para a UM padr�o do Protheus
/*/
method new(cCodigo, cDescricao, lBloqueado, UM, nConv1, nConv2, nConv3, UM1, UM2, UM3) class InvProd
::produto := cCodigo
::descricao := trim(cDescricao)
::bloqueado := lBloqueado
::UM := UM
::conv1 := nConv1
::conv2 := nConv2
::conv3 := nConv3
::UM1 := iif(trim(UM1)!= "", trim(UM1), " ")
::UM2 := iif(trim(UM2)!= "", trim(UM2), " ")
::UM3 := iif(trim(UM3)!= "", trim(UM3), " ")
return
/*/{Protheus.doc} InvProds
Classe com o array contendo os itens da class InvProd
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
/*/
class InvProds
	
	data Produtos as array //of InvProduto
	
	method new(aProdutos) constructor
endclass
/*/{Protheus.doc} new
M�todo construtur da classe InvProds
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
@param aProdutos, array, array com os objetos da classe InvProd
/*/
method new(aProdutos) class InvProds
::Produtos := aProdutos
return
/*/{Protheus.doc} InvEst
Classe referente ao item em estoque no Protheus
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
@version undefined
/*/
class InvEst	
	data produto as string
	data estoque as numeric
	data custo as numeric
	data armazem as string
	method new(cProd, nEstoque, nCusto, _cArmazem) constructor
endclass	
/*/{Protheus.doc} new
M�todo construtor da classe InvEst
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
@param cProd, characters, c�digo do produto B2_COD
@param nEstoque, numeric, quantidade em estoque B2_QATU
@param nCusto, numeric, custo, B2_VATU1 / B2_QATU
/*/
method new(cProd, nEstoque, nCusto, _cArmazem) class InvEst
::produto := cProd
::estoque := nEstoque
::custo := nCusto
::armazem := _cArmazem
return
/*/{Protheus.doc} InvEsts
Classe com os itens em estoque
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
/*/
class InvEsts
	data estoques as array
	
	method new(aEstoques) constructor
endclass
/*/{Protheus.doc} new
M�todo construtor da classe InvEsts
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
@param aEstoques, array, descricao
/*/
method new(aEstoques) class InvEsts
::estoques := aEstoques
return
/*/{Protheus.doc} INVENTARIO
REST SERVER INVENT�RIO
Cont�m os m�todos para a integra��o com a aplica��o das lojas para a digita��o de invent�rio
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
/*/
WSRESTFUL INVENTARIO DESCRIPTION "Metodos para a integracao de inventario" 
WSDATA armazem AS STRING  
WSMETHOD GET PRODUTO DESCRIPTION "Retorna os produtos movimentados no armazem. Necessario login, tenantid e armazem" WSSYNTAX "/prods" PATH "/prods"
WSMETHOD GET ESTOQUE DESCRIPTION "Retorna o estoque. Necessario login, tentantid e armazem" WSSYNTAX "/estoque" PATH "/estoque"
WSMETHOD POST DESCRIPTION "Incluir Inventario" WSSYNTAX "/invent" PATH "/invent"
WSMETHOD PUT DESCRIPTION "Altera Inventario" WSSYNTAX "/invent" PATH "/invent"
END WSRESTFUL
/*/{Protheus.doc} GET PRODUTO
M�todo para retornar o cadastro dos produtos, � necess�rio estar logado e 
informar o tenantId para consumir este m�todo
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
@return return, JSON com a serializa��o da classe InvProds => InvProd
@param armazem, characters, armaz�m onde o invent�rio ser� executado
/*/
WSMETHOD GET PRODUTO WSSERVICE INVENTARIO
local _aProdutos := {}
local _cAlias := GetNextAlias()
local _cJsonRet := ""
local _lBloqueado := .F.
local _oProds
local _nTamConv := TamSx3("B1_XCONV1")[1]
local _nPresConv := TamSx3("B1_XCONV1")[2]
local _cError := ""
local _oError := ErrorBlock({|e| _cError := e:Description + e:ErrorStack})
Local lBloc	:= .F.

::SetContentType("application/json")  
if empty(__cUserId)
	SetRestFault(403,"E obrigatorio efetuar login")
	return .F.
endif
begin sequence 
beginsql alias _cAlias
	column B1_XCONV1 AS NUMERIC(_nTamConv,_nPresConv)
	column B1_XCONV2 AS NUMERIC(_nTamConv,_nPresConv)
	column B1_XCONV3 AS NUMERIC(_nTamConv,_nPresConv)		
	%noparser%
	SELECT 
		B1_COD, 
		B1_DESC, 
		B1_MSBLQL STATUS,
		B1_UM, 
		B1_XCONV1, 
		B1_XCONV2, 
		B1_XCONV3, 
		ISNULL(AH1.AH_DESCPO,' ') B1_XUM1, 
		ISNULL(AH2.AH_DESCPO,' ') B1_XUM2, 
		ISNULL(AH3.AH_DESCPO,' ') B1_XUM3,
		B1_TIPO	
	FROM %TABLE:SB1% B1
	LEFT JOIN %TABLE:SAH% AH1 ON
	AH1.AH_UNIMED = B1_XUM1
	AND AH1.%NOTDEL%
	LEFT JOIN %TABLE:SAH% AH2 ON
	AH2.AH_UNIMED = B1_XUM2
	AND AH2.%NOTDEL%
	LEFT JOIN %TABLE:SAH% AH3 ON
	AH3.AH_UNIMED = B1_XUM3
	AND AH3.%NOTDEL%
	WHERE B1.%NOTDEL%  
endsql
dbSelectArea(_cAlias)
if !eof()
	while !(_cAlias)->(eof())
		
		If (_cAlias)->B1_TIPO $ 'MC|VE'
			lBloc := .T.
		ElseIf (_cAlias)->STATUS == "1"
			lBloc := .T.
		Else
			lBloc := .F.
		EndIf
		
		aAdd(_aProdutos, InvProd():New((_cAlias)->B1_COD, FwCutOff((_cAlias)->B1_DESC,.T.), lBloc, (_cAlias)->B1_UM, (_cAlias)->B1_XCONV1, (_cAlias)->B1_XCONV2, (_cAlias)->B1_XCONV3, (_cAlias)->B1_XUM1, (_cAlias)->B1_XUM2, (_cAlias)->B1_XUM3))
		
		dbskip()
	enddo
	_oProds := InvProds():New(_aProdutos)
	_cJsonRet := FWJsonSerialize(_oProds, .F., .F.) //parametros: objeto, nome da class no json, converte data para utc
	::SetResponse(_cJsonRet)
else
	SetRestFault(204,"Sem dados")
endif
end sequence
ErrorBlock(_oError)
if !empty(_cError)
	SetRestFault(500, '{"erro":"' + _cError + '"}')
	return .F.
endif
return .T.
/*/{Protheus.doc} GET ESTOQUE
M�todo para retornar o estoque atual da loja, � necess�rio estar logado e 
informar o tenantId para consumir este m�todo
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
@return return, JSON com a serializa��o da classe InvEsts => InvEst
@param armazem, characters, armaz�m onde o invent�rio ser� executado
teste
/*/
WSMETHOD GET ESTOQUE WSRECEIVE armazem WSSERVICE INVENTARIO
local _aEstoques := {}
local _cAlias := GetNextAlias()
local _cArmazem := ""
local _cJsonRet := ""
local _oEstoque
local _nTamQtd := TamSx3("B2_QATU")[1]
local _nPresQtd := TamSx3("B2_QATU")[2]
local _nTamCus := TamSx3("B2_CM1")[1]
local _nPresCus := TamSx3("B2_CM1")[2]
local _cTipos := "% B1_TIPO IN " + formatIn(SuperGetMv("MV_XTPPINV", .F., "PA|PI|ME|EM|MP"), "|") + " %"
Default ::armazem := ""
::SetContentType("application/json")  
_cArmazem := ::armazem
if empty(__cUserId)
	SetRestFault(403,"é obrigatório efetuar login")
	return .F.
endif
if empty(_cArmazem)
	SetRestFault(400,"Obrigatório informar o armazém")
	return .F.
endif
beginsql alias _cAlias
	column B2_QATU AS NUMERIC(_nTamQtd, _nPresQtd)
	column B2_CM AS NUMERIC(_nTamCus, _nPresCus)
	%noparser%
	SELECT 
		B2_COD,
		B2_QATU,		
		B1_CUSTD B2_CM, //ISNULL(B2_VATU1 / NULLIF(B2_QATU, 0), 0) B2_CM,
		B2_LOCAL
	FROM %TABLE:SB2% B2 
	JOIN %TABLE:SB1% B1 ON
	B1_COD = B2_COD
	AND B1.%NOTDEL%
	AND %exp:_cTipos%
	WHERE
	B2_FILIAL = %xfilial:SB2%
	AND B2_LOCAL = %exp:_cArmazem%
	AND B2.%NOTDEL%	
endsql
dbSelectArea(_cAlias)
if !eof()
	while !(_cAlias)->(eof())
		aAdd(_aEstoques, InvEst():New((_cAlias)->B2_COD, (_cAlias)->B2_QATU, (_cAlias)->B2_CM, (_cAlias)->B2_LOCAL))
		dbskip()
	enddo
	_oEstoque := InvEsts():New(_aEstoques)
	_cJsonRet := FWJsonSerialize(_oEstoque, .F., .F.) //parametros: objeto, nome da class no json, converte data para utc
	::SetResponse(_cJsonRet)
else
	SetRestFault(204,"Sem dados")
endif
return .T.
/*/{Protheus.doc} POST (INCLUS�O)
M�todo para inclus�o de invent�rio, � necess�rio estar logado e 
informar o tenantId para consumir este m�todo.
formato do body: 
{
	filial:"0001"
	documento:"DOCEXEMP01",
	data:"05/10/2018",
	armazem: "000101",
	itens: [
		{produto:"PA001000000001", quantidade: 10.5},
		{produto:"PA001000000002", quantidade: 1.0},
	]
}
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
/*/
WSMETHOD POST WSSERVICE INVENTARIO
local _cBody := ::GetContent() //retorna o conteudo do body
local _cDoc 
local _dData
local _cFilial := xFilial("SB7")
local _cArmazem
local _aLog := {}
Local _cJsonErro := '{"erro":"'
local _aInv := {}
local _cErro := ""
local _aChkPrd
local _cError := ""
local _oError := ErrorBlock({|e| _cError := e:Description + e:ErrorStack})
private lMsErroAuto := .F.
private lAutoErrNoFile := .T.
private _oData
::SetContentType("application/json")  
if !FWJsonDeserialize(_cBody, @_oData)		
	//Retorna BadRequest
	SetRestFault(400, "ERROR ON DESERIALIZE JSON, VERIFY JSON ON BODY")
	return .F.
endif
_dData := dDataBase := stod(_oData:data)
_cDoc := _oData:documento
_cArmazem := _oData:armazem
dbSelectArea("SB7")
dbSetOrder(1)//B7_FILIAL, B7_DATA, B7_COD, B7_LOCAL, B7_LOCALIZ, B7_NUMSERI, B7_LOTECTL, B7_NUMLOTE, B7_CONTAGE, R_E_C_N_O_, D_E_L_E_T_
begin sequence
for i:=1 to len(_oData:itens)
	_aChkPrd := isProdOk(_oData:itens[i]:produto)
	if !_aChkPrd[1]
		aAdd(_aLog, _aChkPrd[2])
		loop
	endif
	
	_aChkEst := CheckSB2(_oData:itens[i]:produto, _cArmazem, _dData)
	
	//verifica se n�o � retentativa de inclus�o de invent�rio
	if SB7->(dbSeek(_cFilial + dtos(_dData) + _oData:itens[i]:produto + _cArmazem))
		//aAdd(_aLog, "Produto: " + _oData:itens[i]:produto + ", Item j� invent�riado para o per�odo - chave: " + _cFilial + dtos(_dData) + _oData:itens[i]:produto + _cArmazem)
		loop
	endif
	
	if !_aChkEst[1]
		aAdd(_aLog, _aChkEst[2])
		loop
	endif
	
	_aInv := {;
			 	{"B7_FILIAL", _cFilial, NIL},;
			 	{"B7_COD", _oData:itens[i]:produto, NIL},;
			 	{"B7_DOC", _cDoc, NIL},;
			 	{"B7_QUANT", _oData:itens[i]:quantidade, NIL},;
			 	{"B7_LOCAL", _cArmazem, NIL},;
			 	{"B7_DATA", _dData, NIL};				 	
			  }
	MsExecAuto({|x,y,z| MATA270(x,y,z)}, _aInv, .T., 3)
	if lMsErroAuto
		_cError := ""
		aEval(GetAutoGrLog(), {|x| _cError += x})
		aAdd(_aLog, _cError)
		_cJsonErro += _cError + '"}'	
		SetRestFault(500,_cJsonErro)
		return .F.		
	endif
next
if len(_aLog) > 0
	aEval(_aLog,{|x| _cJsonErro += x + ".\n"})
	_cJsonErro += '"}'
	::SetResponse(_cJsonErro)
endif
end sequence
ErrorBlock(_oError)
if !empty(_cError)
	SetRestFault(500, '{"erro":"' + _cError + '"}')
	return .F.
endif
return .T.
/*/{Protheus.doc} PUT (ALTERA��O)
M�todo para inclus�o de invent�rio, � necess�rio estar logado e 
informar o tenantId para consumir este m�todo.
formato do body: 
{
	filial:"0001"
	documento:"DOCEXEMP01",
	data:"05/10/2018",
	armazem: "000101",
	itens: [
		{produto:"PA001000000001", quantidade: 10.5},
		{produto:"PA001000000002", quantidade: 1.0},
	]
}
@author Renan Paiva <renan.paiva@mobibytes.com.br>
@since 05/09/2018
/*/
WSMETHOD PUT WSSERVICE INVENTARIO
local _cBody := ::GetContent() //retorna o conteudo do body
local _cDoc 
local _dData
local _cFilial
local _cArmazem
local _aLog := {}
Local _cJsonErro := '{"erro":"'
local _aInv := {}
local _aChkEst := {}
local _cError := ""
local _oError := ErrorBlock({|e| _cError := e:Description + e:ErrorStack})
local _nOpc := 4
private lMsErroAuto := .F.
private lAutoErrNoFile := .T.
private _oData
::SetContentType("application/json")  
if !FWJsonDeserialize(_cBody, @_oData)		
	//Retorna BadRequest
	SetRestFault(400, "ERROR ON DESERIALIZE JSON, VERIFY JSON ON BODY")
	return .F.
endif
_dData := dDataBase := stod(_oData:data)
_cDoc := _oData:documento
_cFilial := xFilial("SB1")
_cArmazem := _oData:armazem
dbSelectArea("SB7")
dbSetOrder(1)//B7_FILIAL, B7_DATA, B7_COD, B7_LOCAL, B7_LOCALIZ, B7_NUMSERI, B7_LOTECTL, B7_NUMLOTE, B7_CONTAGE, R_E_C_N_O_, D_E_L_E_T_
begin sequence
for i:=1 to len(_oData:itens)
	
	_aChkPrd := isProdOk(_oData:itens[i]:produto)
	if !_aChkPrd[1]
		aAdd(_aLog, _aChkPrd[2])
		loop
	endif
	
	//verifica se n�o � retentativa de inclus�o de invent�rio
	_nOpc := Iif(SB7->(dbSeek(_cFilial + dtos(_dData) + _oData:itens[i]:produto + _cArmazem)), 4, 3)
			
	_aChkEst := CheckSB2(_oData:itens[i]:produto, _cArmazem, _dData)
	if !_aChkEst[1]
		aAdd(_aLog, _aChkEst[2])
		loop
	endif
	
	_aInv := {;
			 	{"B7_FILIAL", _cFilial, NIL},;
			 	{"B7_COD", _oData:itens[i]:produto, NIL},;
			 	{"B7_DOC", _cDoc, NIL},;
			 	{"B7_QUANT", _oData:itens[i]:quantidade, NIL},;
			 	{"B7_LOCAL", _cArmazem, NIL},;
			 	{"B7_DATA", _dData, NIL};				 	
			  }
	MsExecAuto({|x,y,z| MATA270(x,y,z)}, _aInv, .T., _nOpc)
	if lMsErroAuto
		_cErro := ""
		aEval(GetAutoGrLog(), {|x| _cErro += x})
		aAdd(_aLog, _cErro)	
		_cJsonErro += _cErro + '"}'	
		SetRestFault(500,_cJsonErro)
		return .F.		
	endif
next
if len(_aLog) > 0
	aEval(_aLog,{|x| _cJsonErro += x + ".\n"})
	_cJsonErro += '"}'
	::SetResponse(_cJsonErro)
endif
end sequence
ErrorBlock(_oError)
if !empty(_cError)
	SetRestFault(500, '{"erro":"' + _cError + '"}')
	return .F.
endif
return .T.
Static Function isProdOk(_cProduto)
//Verifica se o produto esta bloqueado, caso sim realiza o desbloqueio
dbSelectArea("SB1")
dbSetOrder(1)
if !dbSeek(xFilial("SB1") + trim(_cProduto))
	return {.F., "O Produto " + trim(_cProduto) + " Nao Encontrado"}
endif
if SB1->B1_MSBLQL == '1'
	return {.F., "O Produto " + trim(_cProduto) + " Esta Bloqueado"}
endif
return {.T.}
static function CheckSB2(_cProduto, _cLocal, _dData)
local _aDadosB9 := {}
local _cErro := ""
//verifica se existe saldos iniciais
dbSelectArea("SB2")
dbSetOrder(1)
if !dbSeek(xFilial("SB2") + _cProduto + _cLocal)
	aAdd(_aDadosB9, {"B9_FILIAL", xFilial("SB9") , NIL})
	aAdd(_aDadosB9, {"B9_COD", _cProduto, NIL})
	aAdd(_aDadosB9, {"B9_LOCAL", _cLocal, NIL})
	aAdd(_aDadosB9, {"B9_QINI", 0, NIL})
	
	msExecAuto({|x, y| MATA220(x, y)}, _aDadosB9, 3)
	
	if lMsErroAuto
		lMsErroAuto := .F.		
		aEval(GetAutoGrLog(), {|x| _cErro += x})	
		return {.F., _cErro}			
	endif
	
elseif Found() .and. SB2->B2_DTINV >= _dData
	return {.F., "PRODUTO " + _cProduto + " INVENT�RIO J� PROCESSADO"}
endif
return {.T.}