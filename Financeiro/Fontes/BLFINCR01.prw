#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/

User Function BLFINCR0()

LOCAL oDlg
LOCAL nOpca:=0
Local aPergs 	  := {}
Local cCaminho  := Space(60)
Local oSay1

Private aRet 	  := {}

aAdd( aPergs ,{6,"Diretorio do Arquivo?"	,cCaminho	,"@!",,'.T.',80,.F.,"Arquivos .xlsx |*.csv " }) 
aAdd( aPergs ,{3,"Somente Processamento?",1,{"N�o","Sim","Relatorio Hora","Relatorio Status","Relatorio Simular"},50,"",.T.})
aAdd( aPergs, {1,"Data Baixa?"  			,Ctod(Space(8)),"","","","",50,.F.})

If ParamBox(aPergs ,"Parametros ",aRet)
		
	DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importacao Pedido de Venda") PIXEL    //"Rec�lculo do Custo de Reposi��o"
	@ 18, 4 TO 80, 287 LABEL "" OF oDlg  PIXEL
	@ 29, 15 SAY OemToAnsi("Esta rotina realiza a importacao de Planilha Excel Com  os dados para Geracao de Baixas") SIZE 268, 8 OF oDlg PIXEL
	@ 38, 15 SAY OemToAnsi("Da empresa Bacio diLatte.") SIZE 268, 8 OF oDlg PIXEL
	@ 48, 15 SAY OemToAnsi("Confirma Geracao de Baixas?") SIZE 268, 8 OF oDlg PIXEL
    @ 58, 15 SAY oSay1 PROMPT "Informe a quantidade de titulos." SIZE 089, 007 OF oDlg COLORS 0, 16777215 PIXEL    

	DEFINE SBUTTON FROM 90, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
	DEFINE SBUTTON FROM 90, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
		
	If nOpca == 1 .And. ( aRet[2] == 1 .And. !Empty( aRet[1] ) )
		processa( {|| fImpExcel() } ,'Aguarde Efetuando Importacao da Planilha' )
	ElseIf aRet[2] == 1 .And. Empty( aRet[1] )
		MsgAlert("ATEN��O: Informar para n�o porcessar, necess�rio selecionar o arquivo!")
	ElseIf aRet[2] == 2 
		processa( {|| fImpExcel() } ,'Aguarde Efetuando Importacao da Planilha' )	
	ElseIf aRet[2] == 3
		processa( {|| fRet001() } ,'Aguarde Gerando Dados Excel' )	
	ElseIf aRet[2] == 4
		processa( {|| fRet002() } ,'Aguarde Gerando Dados Excel' )	
	ElseIf aRet[2] == 5
		processa( {|| fRet003() } ,'Aguarde Gerando Dados Excel' )			
	 Endif
	
Endif

Return

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/

Static Function FImpExcel()

Local lPrim			:= .T.	
Local aDados		:= {}
Local aCampos		:= {}
Local lBaixa		:= .F.	
Local nReg			:= 0

Private nJuros    	:= 0
Private cDTHRIn		:= DTOC( Date() ) + " " + Time()
Private cDTHRFi		:= DTOC( Date() ) + " " + Time()
Private _nProcSuce	:= 0
Private _nProcFalh	:= 0

	//Busca tabela no protheus
	ZCZ->(dbSelectArea("ZCZ"))
	ZCZ->(dbSetOrder(1))
	
	cFile   := aRet[1]

	If ! Empty(cFile) .And. aRet[2] == 1 

		FT_FUSE(cFile)
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			
			IncProc("Selecionando Registros...")
	 
			cLinha := FT_FREADLN()
			
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
							
			EndIf
			
			FT_FSKIP()
		EndDo
		
		//Efetua leitura dos dados
		ProcRegua( Len(aDados) )
		Begin Transaction
			For i := 1 to Len(aDados) //Leitura do Array importa��o dos dados
			
				IncProc("Importando dados tabela ZCZ...")
			
				ZCZ->(dbSelectArea("ZCZ"))
				ZCZ->(dbSetOrder(1)) //ZCZ_FILORI, ZCZ_PREFIX, ZCZ_NUM, ZCZ_PARCEL, ZCZ_TIPO, ZCZ_CLIENT, ZCZ_LOJA
				
				If ! ZCZ->(dbSeek( 	PADR( aDados[i][18] , TamSx3('ZCZ_FILORI')[1]) +;
				 					PADR( aDados[i][1] ,TamSx3('ZCZ_PREFIX')[1]) +;
				 					PADR( aDados[i][2] ,TamSx3('ZCZ_NUM')[1]) +;
				 					PADR( aDados[i][3] ,TamSx3('ZCZ_PARCEL')[1])+;
				 					PADR( aDados[i][4] ,TamSx3('ZCZ_TIPO')[1])+;
				 					PADR( aDados[i][8] ,TamSx3('ZCZ_CLIENT')[1])+;
				 					PADR( aDados[i][9] ,TamSx3('ZCZ_LOJA')[1]) ) )
				
				 	//Resposta para inicio das baixas
				 	lBaixa	:= .T.					
				
				 	nReg++
				
					RecLock("ZCZ", .T.)
						ZCZ->ZCZ_PREFIX 	:= aDados[i][1]
					    ZCZ->ZCZ_NUM		:= aDados[i][2]
					    ZCZ->ZCZ_PARCEL 	:= aDados[i][3]
					    ZCZ->ZCZ_TIPO		:= aDados[i][4]
					    ZCZ->ZCZ_NATURE		:= aDados[i][5]
					    ZCZ->ZCZ_PORTAD		:= aDados[i][6]
					    ZCZ->ZCZ_DEPOSI		:= aDados[i][7]
					    ZCZ->ZCZ_CLIENT		:= aDados[i][8]
					    ZCZ->ZCZ_LOJA		:= aDados[i][9]
					    ZCZ->ZCZ_NOMCLI		:= aDados[i][10]
					    ZCZ->ZCZ_EMISSA		:= CTOD(aDados[i][11])
					    ZCZ->ZCZ_VENCTO		:= CTOD(aDados[i][12])
					    ZCZ->ZCZ_VENCRE		:= CTOD(aDados[i][13])
					    ZCZ->ZCZ_VALOR		:= VAL( STRTRAN(aDados[i][14],",",".") )
					    ZCZ->ZCZ_BAIXA		:= CTOD(aDados[i][15])
					    ZCZ->ZCZ_SALDO		:= VAL( STRTRAN(aDados[i][16],",",".") )
					    ZCZ->ZCZ_VALREA		:= VAL( STRTRAN(aDados[i][17],",",".") )
					    ZCZ->ZCZ_FILORI		:= aDados[i][18]
					    ZCZ->ZCZ_CUSTO		:= aDados[i][19]
					    ZCZ->ZCZ_VLRBAI		:= VAL( STRTRAN(aDados[i][20],",",".") )
					    ZCZ->ZCZ_DESCON		:= VAL( STRTRAN(aDados[i][21],",",".") )
					    ZCZ->ZCZ_DTPG		:= CTOD(aDados[i][22])
					    ZCZ->ZCZ_BANCO		:= aDados[i][23]
					    ZCZ->ZCZ_AGENCI		:= aDados[i][24]
					    ZCZ->ZCZ_CONTA		:= aDados[i][25]
					    ZCZ->ZCZ_FMR		:= "2"
					    ZCZ->ZCZ_PROC		:= "N"
					    ZCZ->ZCZ_LOGIN		:= "DATA " + DTOC( Date() ) + " HORA " + TIME() + " USUARIO " +  Alltrim(UPPER(UsrRetName(__CUSERID)))
				    MsUnLock() 
				EndIf
			Next i
		
		End Transaction
	
	EndIf
		
	//Apos gera��o dos dados envia para gerar baixas
	If aRet[2] == 2
		BXTITREC()
	Else
		MsgInfo("Importa��o conclu�da com sucesso, numero de registros: " + cValToChar(nReg))
	EndIf

Return

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/
	
Static Function BXTITREC()	

	Local _nSomaLin		:= 0
	Local _nProcSuce	:= 0
	Local nRecTRB		:= 0
	
	ZCZ->(dbSelectArea("ZCZ"))
	ZCZ->(DbSetFilter( {|| ZCZ_FMR == "2" .AND. ZCZ_PROC == "N" .And. ZCZ_DTPG = aRet[3]  }, 'ZCZ_FMR == "2" .AND. ZCZ_PROC == "N" .AND. ZCZ_DTPG == DTOS(aRet[3]) '))	
	ZCZ->(dbGoTop())		
	
	Procregua( nRecTRB )
								
	Do While ZCZ->(!EOF())
		
		//Registra barra de processamento
		incproc("Efetivando baixas de t�tulos " + cValToChar(_nSomaLin) + "/" + cValToChar(nRecTRB))	
		
		//Verifica se cont�m Juros
		nJuros := 0
		If ZCZ->ZCZ_VLRBAI > ZCZ->ZCZ_SALDO 
			nJuros := ZCZ->ZCZ_VLRBAI - ZCZ->ZCZ_SALDO 
		Endif  
	    
		//Array do titulo a receber, para a baixa do titulo
					
		aFinA070 :={{"E1_NUM"				,ZCZ->ZCZ_NUM		,Nil},;
					{"E1_PREFIXO" 			,ZCZ->ZCZ_PREFIX   	,Nil},;
					{"E1_FILIAL"  			,xFilial('SE1')		,Nil},;
					{"E1_TIPO" 				,ZCZ->ZCZ_TIPO		,Nil},;
					{"E1_NATUREZ"			,ZCZ->ZCZ_NATURE	,Nil},;
					{"E1_PARCELA"			,ZCZ->ZCZ_PARCEL	,Nil},;
					{"E1_LOJA"				,ZCZ->ZCZ_LOJA		,Nil},;
					{"E1_CLIENTE" 			,ZCZ->ZCZ_CLIENT	,Nil},;
					{"E1_NOMCLI"			,ZCZ->ZCZ_NOMCLI	,Nil},;
					{"AUTMOTBX"	    		,"NOR"         		,Nil},; 
					{"E1_DTDIGIT"			,dDatabase		   	,Nil},;
					{"AUTDTCREDITO"			,ZCZ->ZCZ_DTPG		,Nil},;
					{"AUTDESCONT"			,ZCZ->ZCZ_DESCON	,Nil},;
					{"AUTDECRESC"			,0					,Nil},;
					{"AUTACRESC" 			,0   				,Nil},;
					{"AUTMULTA"	   			,0					,Nil},;
					{"AUTJUROS"	 			,nJuros	       		,Nil},;
					{"E1_ORIGEM" 			,'BLFINCR'     	  	,Nil},;
					{"E1_FLUXO"				,"S"          		,Nil},;
					{"AUTBANCO"				,ZCZ->ZCZ_BANCO		,Nil},;
					{"AUTAGENCIA"			,ZCZ->ZCZ_AGENCI	,Nil},;
					{"AUTCONTA"				,ZCZ->ZCZ_CONTA		,Nil},;
					{"AUTVALREC"			,ZCZ->ZCZ_VLRBAI	,Nil}}							
			        
		//verifica se ha erro no execauto
		lMsErroAuto := .F.
		
		//Altera data base
		_dDataBase 	:= dDataBase
		dDataBAse 	:= ZCZ->ZCZ_DTPG
	
		// Extrai os Dados das Celulas Cabe�alho pedido
		If ZCZ->ZCZ_PROC == "N" //Verifica se ainda est� N�o
			
			SE5->(dbSelectArea("SE5"))
			SE5->(dbSetOrder(7)) //E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ
			If SE5->(dbSeek( xFilial("SE5") + ZCZ->ZCZ_PREFIX + ZCZ->ZCZ_NUM + ZCZ->ZCZ_PARCEL + ZCZ->ZCZ_TIPO + ZCZ->ZCZ_CLIENT + ZCZ->ZCZ_LOJA ))
				lMsErroAuto := .F.
			Else
				MSExecAuto({|x,y| Fina070(x,y)},aFinA070,3) //Inclusao da baixa
			EndIf
									
			dDataBase := _dDataBase
	
			cErro := ''
			
			If lMsErroAuto
								 
				//Verifica se baixa j� ocorreu em outro processameento							 
				Reclock("ZCZ",.F.)
					ZCZ->ZCZ_PROC	:= "S"
					ZCZ->ZCZ_LOG	:= "LOG PROCESSO ERRO DATA " + DTOC( Date() ) + " HORA " + TIME() + " USUARIO " +  Alltrim(UPPER(UsrRetName(__CUSERID)))
					ZCZ->ZCZ_DATAP	:= Date()
					ZCZ->ZCZ_HORAP	:= TIME()  
				ZCZ->(MsUnlock())
			
				_nProcFalh++
														
			Else
			
				//Atualiza status e Log de Processamento:
				Reclock("ZCZ",.F.)
					ZCZ->ZCZ_PROC	:= "S"
					ZCZ->ZCZ_LOG	:= "LOG PROCESSO SUCESSO DATA " + DTOC( Date() ) + " HORA " + TIME() + " USUARIO " + Alltrim(UPPER(UsrRetName(__CUSERID)))
					ZCZ->ZCZ_DATAP	:= Date()
					ZCZ->ZCZ_HORAP	:= TIME()  
				ZCZ->(MsUnlock())
									
			    _nProcSuce++
			    
			EndIf
	     
	     EndIf
	        
		_nSomaLin++
					
		ZCZ->(dbSkip())
	Enddo

	//Finaliza Filtro
	ZCZ->(DBClearFilter())
		
	//Alimenta Final Rotina
	cDTHRFi		:= DTOC( Date() ) + " " + Time()
	
	MsgAlert(	'Total processado: ' + cValToChar(_nSomaLin) + '.' 	+ chr(13) + chr(10) + ;
				'Total processado com sucesso: ' + cValToChar(_nProcSuce) + '.' 	+ chr(13) + chr(10) + ;
				'Total processado com falha: ' + cValToChar(_nProcFalh) + '.'  + chr(13) + chr(10) + ;
				'Inicio: ' + cDTHRIn + ' Fim ' + cDTHRFi, 'Processamento finalizado')
	
Return

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/

User Function VERDADG(_nArq,_cMatriz,_nElemento,_nSoma,_lExtrai)

Local _cRetorno	:= ''
Local _cBufferPl:= ''
Local _nBytesPl	:= 0
Local _cCelula	:=''
Local _cDescCam	:=''
Local _cColuna	:=''
Local _cLinha	:=''
Local _cTipo	:=''
Local _cTamanho	:=''
Local _cDecimal	:=''
Local _cString	:=''

If _lExtrai == Nil
	_lExtrai := .F.
Endif
_cDescCam		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",1]"
_cColuna		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",2]"
_cLinha			:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",3]"
_cTipo   		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",4]"
_cTamanho		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",5]"
_cDecimal		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",6]"

_cDescCam		:= &_cDescCam
_cColuna		:= &_cColuna
_cLinha			:= Alltrim(Str(&_cLinha+_nSoma))
_cTipo   		:= Upper(&_cTipo)
_cTamanho		:= &_cTamanho
_cDecimal		:= &_cDecimal

_cCelula		:= _cColuna+_cLinha

// Efetua Leitura da Planilha
_cBufferPl := _cCelula + Space(1024)
_nBytesPl  := ExeDLLRun2(_nArq, CMD_READCELL, @_cBufferPl)
_cRetorno  := Subs(_cBufferPl, 1, _nBytesPl)
_cRetorno  := Alltrim(_cRetorno)

// Realiza tratamento do campo  de acordo com o Tipo

If _cTipo =='N' // Numerico
	_cString	:=''
	_cNewRet :=''
	For _nElem	:= 1 To Len(_cRetorno)
		_cString := SubStr(_cRetorno,_nElem,1)
		If _cString ==','
			_cString :='.'
		Endif
		_cNewRet	:=Alltrim(_cNewRet)+_cString
	Next _nElem
	_cNewRet		:= Val(_cNewRet)
	_cRetorno    := Round(_cNewRet,_cDecimal)
Endif

If _cTipo =='D' // Data 21/01/2006
	_cNewRet 	:= Left(_cRetorno,6)+Right(_cRetorno,2)
	_cRetorno    := CtoD(_cNewRet)
Endif

If _cTipo =='C' .AND. _lExtrai // Caracter e extra��o de caracteres
	_cString	:=''
	_cNewRet :=''
	For _nElem	:= 1 To Len(_cRetorno)
		_cString := SubStr(_cRetorno,_nElem,1)
		If _cString $ '#/#,#.#-'
			Loop
		Endif
		_cNewRet	:=Alltrim(_cNewRet)+_cString
	Next _nElem
	_cRetorno    := _cNewRet
Endif

// Ajusta O Tamanho da variavel

If _cTipo =='C'
	_cRetorno := Alltrim(_cRetorno)
	_cRetorno := _cRetorno+Space(_cTamanho-Len(_cRetorno))
Endif

Return _cRetorno

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/
Static Function fRet001()

	Local cQuery := ""

	cQuery := " SELECT SUBSTRING(ZCZ_DATAP,7,2) + '/' + SUBSTRING(ZCZ_DATAP,5,2) + '/' + SUBSTRING(ZCZ_DATAP,1,4) AS 'ZCZ_DATAP', "
	cQuery += " SUBSTRING(ZCZ_HORAP,1,2) 'F2_HORA', COUNT(*) 'C6_QTDVEN' "
	cQuery += " FROM "+RETSQLNAME("ZCZ")+" "
	cQuery += " WHERE " 
	cQuery += " 	D_E_L_E_T_ != '*' "
	cQuery += " 	AND ZCZ_FMR = '2' "
	cQuery += " 	AND ZCZ_DATAP != '' "
	cQuery += " 	AND ZCZ_DATAP = '"+DTOS(aRet[3])+"' "
	cQuery += " GROUP BY SUBSTRING(ZCZ_DATAP,7,2) + '/' + SUBSTRING(ZCZ_DATAP,5,2) + '/' + SUBSTRING(ZCZ_DATAP,1,4), SUBSTRING(ZCZ_HORAP,1,2) "
	cQuery += " ORDER BY 1,2 DESC "

	//Chamada fun��o para gerar em Excel
	U_QRYEXCEL(cQuery,"Processamento Hora")

Return

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/
Static Function fRet002()

	Local cQuery := ""

	cQuery := " SELECT SUBSTRING(ZCZ_DTPG,7,2) + '/' + SUBSTRING(ZCZ_DTPG,5,2) + '/' + SUBSTRING(ZCZ_DTPG,1,4) ZCZ_DTPG, COUNT(*) as C6_QTDVEN"
	cQuery += " FROM "+RETSQLNAME("ZCZ")+" "
	cQuery += " WHERE ZCZ_PROC = 'N' AND ZCZ_FMR = '2' AND D_E_L_E_T_ != '*' AND ZCZ_DTPG != ''"
	cQuery += " GROUP BY SUBSTRING(ZCZ_DTPG,7,2) + '/' + SUBSTRING(ZCZ_DTPG,5,2) + '/' + SUBSTRING(ZCZ_DTPG,1,4)"
	cQuery += " ORDER BY 2"
	

	//Chamada fun��o para gerar em Excel
	U_QRYEXCEL(cQuery,"Status a Processar")

Return

/*/
{Protheus.doc} BLFINCR0
Description

	Importacao de Planilha Excel para Baixar Títulos CR 

@param xParam Parameter Description
@return Nil
@author  - Rodolfo Vacari
@since 23/05/19 
/*/
Static Function fRet003()

	Local cQuery := ""

	cQuery := " SELECT "
	cQuery += " 	ZCZ_BANCO, "
	cQuery += " 	ZCZ_AGENCI, "
	cQuery += " 	ZCZ_CONTA, "
	cQuery += " 	ZCZ_TIPO, " 
	cQuery += " 	ZCZ_CLIENT, "
	cQuery += " 	ZCZ_NOMCLI, "
	cQuery += " 	ZCZ_NATURE, "
	cQuery += " 	ROUND(SUM(ZCZ_VALOR),2) AS ZCZ_VALOR "
	cQuery += " FROM "+RETSQLNAME("ZCZ")+" ZCZ "
	cQuery += " WHERE ZCZ.ZCZ_FILIAL != '*' "
	cQuery += " 	AND ZCZ.ZCZ_DTPG = '"+DTOS(aRet[3])+"' "
	cQuery += " 	AND ZCZ_FMR = '2' "
	cQuery += " 	AND D_E_L_E_T_ != '*' "
	cQuery += " GROUP BY "
	cQuery += " 	ZCZ_TIPO, " 
	cQuery += " 	ZCZ_NATURE, "
	cQuery += " 	ZCZ_CLIENT, "
	cQuery += " 	ZCZ_NOMCLI, "
	cQuery += " 	ZCZ_BANCO, "
	cQuery += " 	ZCZ_AGENCI, "
	cQuery += " 	ZCZ_CONTA "
	cQuery += " ORDER BY 1,2,3,6 "

	//Chamada fun��o para gerar em Excel
	U_QRYEXCEL(cQuery,"Simular Valores - CP")

Return