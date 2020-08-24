#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} User Function BDINVIMP
    (long_description)
    @type  Function
    @author user
    @since 10/04/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function BDINVIMP()

    Local aPergs 	 := {}
    Local cCaminho  := Space(90)
    Local aRet      := {}

    aAdd( aPergs ,{6,"Diretorio do Arquivo?"	,cCaminho	,"@!",,'.T.',80,.F.,"Arquivos .xlsx |*.csv " }) 
    aAdd( aPergs, {1,"Data Inventario?"			,Ctod(Space(8)),"","","","",50,.F.})
    aAdd( aPergs, {1,"Filial"  			        ,Space(4),"","","SM0","",50,.F.})
    aAdd( aPergs, {1,"Armazem" 			        ,Space(6),"","","NNR","",50,.F.})

    If ParamBox(aPergs ,"Parametros ",aRet)
        processa( {|| ImporCSV(MV_PAR01) } ,'Aguarde Efetuando Importacao da Planilha' )
    EndIf

RETURN

/*/{Protheus.doc} ImporCSV()

   (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function ImporCSV(cFile)

    Local cLinha
    Local lPrim     := .T.
    Local aCampos   := {}
    Local aDados    := {}

   	If ! Empty(cFile) 

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

    EndIf


     //Efetua leitura dos dados
    ProcRegua( Len(aDados) )
    Begin Transaction
        For i := 1 to Len(aDados) //Leitura do Array importa��o dos dados
        
            //IncProc("Importando dados tabela SB7...")

            SB7->(dbSelectArea("SB7"))
            SB7->(dbSetOrder(1)) //Filial Data Cod Local
            
            If ! SB7->(dbSeek(xFilial("SB7") + DTOS(MV_PAR02) + aDados[i][1] + MV_PAR04 ))
    
                RecLock("SB7", .T.)

                    SB7->B7_FILIAL  := xFilial("SB7")
                    SB7->B7_COD     := Alltrim(aDados[i][1])
                    SB7->B7_LOCAL   := MV_PAR04
                    SB7->B7_TIPO    := SUBSTR( aDados[i][1] ,1,2)
                    SB7->B7_DOC     := DTOS(MV_PAR02)
                    SB7->B7_QUANT   := VAL(aDados[i][4])
                    SB7->B7_QTSEGUM := VAL(aDados[i][5])
                    SB7->B7_DATA    := MV_PAR02
                    SB7->B7_DTVALID := MV_PAR02
                    SB7->B7_ORIGEM  := "BDINVIMP"
                    SB7->B7_STATUS  := "1"
                    
                MsUnLock() 

            EndIf

        Next i
    End Transaction   

Return 

/*
STATIC Function ImporCSV()

Private nJuros    	:= 0
Private cDTHRIn		:= DTOC( Date() ) + " " + Time()
Private cDTHRFi		:= DTOC( Date() ) + " " + Time()
Private _nProcSuce	:= 0
Private _nProcFalh	:= 0
	
	If ! Empty(cFile) 

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



        Next 
    End Transaction    
            
*/
Return 