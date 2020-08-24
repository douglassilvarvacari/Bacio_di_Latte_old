#Include 'Protheus.ch'
#include "TOPCONN.CH"
#DEFINE ENTER chr(13)+chr(10)

/*
=====================================================================================
Programa.:              PEMATA311 
Autor....:              Francis Oliveira
Data.....:              17/10/2016
Descricao / Objetivo:   Ao Efetivar a transferencia gravar no PV o centro de custo   
Doc. Origem:            
Solicitante:            Cliente
Uso......:              BACIO DI LATTE
Obs......:              Rotina em MVC 
=====================================================================================
*/

User Function MATA311()

Local aArea   	:= Getarea()
Local aAreaNNT 	:= NNT->(Getarea())
Local aAreaNNS 	:= NNS->(Getarea())
Local aParam    := PARAMIXB
Local lRet      := .T.
Local oObj      := ''
Local cIdPonto  := ''
Local cIdModel  := ''
Local lIsGrid   := .F.
Local nLinha    := 0
Local lEfetiva	:= IsInCallStack("A311Efetiv") 
 
If aParam <> NIL
      
       oObj       := aParam[1]
       cIdPonto   := aParam[2]
       cIdModel   := aParam[3]
       lIsGrid    := ( Len( aParam ) > 3 )
       
       If cIdPonto == "FORMLINEPOS"
       
       		nLinha 	:= aParam[4]
       		aDados	:= oObj:ADATAMODEL
       		
       		cChave := 	aDados[nLinha][1][1][16] +; //Filial Destino
       		 			aDados[nLinha][1][1][17] +; //Codigo Produto destino	
       		 			aDados[nLinha][1][1][20]    // Armazem Destino  			
       		
       		//Verifica tabela de cotas
       		ZCC->(dbSelectArea("ZCC"))
       		ZCC->(dbSetOrder(1))
       		If ZCC->(dbSeek( cChave ))
       		
       			//Verifica saldo em Cota
       			nQtde1 := aDados[nLinha][1][1][14]
       			nQtde2 := aDados[nLinha][1][1][15]
       			
       			If ZCC->ZCC_QTDE1 > 0 
       			
	       			If nQtde1 > ZCC->ZCC_QTDE1 	       			
	       				Alert("ATENÇÃO: Quantidade solicitada maior que o saldo em cotas, Saldo: " + cValToChar(ZCC->ZCC_QTDE1) + " Solicite revisão ao Consultor") 
	       				lRet := .F.
	       			EndIf	
	       		
	       		ElseIf ZCC->ZCC_QTDE2 > 0	
	       			
	       			If nQtde2 > ZCC->ZCC_QTDE2  		       			
	       				Alert("ATENÇÃO: Quantidade solicitada maior que o saldo em cotas, Saldo: " + cValToChar(ZCC->ZCC_QTDE2) + " Solicite revisão ao Consultor")
	       				lRet := .F.	       			
	       			EndIf
       			       			  			
       			ElseIf ZCC->ZCC_QTDE1 <= 0 .And. ZCC->ZCC_QTDE2 <= 0	
	       			
	       				Alert("ATENÇÃO: Não é possível solicitar o item pois não existe saldo de cotas, Saldo = 0 Solicite revisão ao Consultor")
	       				lRet := .F.	       			
	       		
       			EndIf
       			
       		EndIf
   		
       EndIf
                  
       If cIdPonto == 'MODELCOMMITNTTS' .and. lEfetiva
		
			oModelNNS := oObj:AALLSUBMODELS[1] // Cabecalho
			oModelNNT := oObj:AALLSUBMODELS[2] // Itens
						
			// Loop para os ites da Transferencia 
			For nX:= 1 To oModelNNT:GetQtdLine() 
				oModelNNT:GoLine(nX)
					
				cFilNNT := oModelNNT:GetValue("NNT_FILORI") 	// C6_FILIAL
				cDocNNT := oModelNNT:GetValue("NNT_DOC") 		// C6_NOTA
				cSerNNT := oModelNNT:GetValue("NNT_SERIE") 		// C6_SERIE
				cProNNT := oModelNNT:GetValue("NNT_PROD") 		// C6_PRODUTO
				cCusNNT := oModelNNT:GetValue("NNT_XCC") 		// C6_CCUSTO
				cAmzNNT := oModelNNT:GetValue("NNT_LOCLD")		// C6_XLOCDES
				nQt1NNT := oModelNNT:GetValue("NNT_QUANT") 		// NNT_QUANT
				nQt2NNT := oModelNNT:GetValue("NNT_QTSEG") 		// NNT_QTSEF
				cFilDes := oModelNNT:GetValue("NNT_FILDES") 	// NNT_FILDES
		 	 
				// Query para selecionar os produtos na SC6
				cQuery := " SELECT C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_ AS SC6RECNO " + ENTER
				cQuery += " FROM "       + RetSqlName("SC6") + " SC6       " + ENTER
				cQuery += " WHERE SC6.C6_FILIAL = '" + cFilNNT + "' " + ENTER
				cQuery += " AND SC6.C6_NOTA = '" + cDocNNT + "' " + ENTER
				cQuery += " AND SC6.C6_SERIE = '" + cSerNNT + "' " + ENTER
				cQuery += " AND SC6.C6_PRODUTO = '" + cProNNT + "' " + ENTER
				cQuery += " AND SC6.D_E_L_E_T_ = ' ' " 
 
				If ( Select("TMP1") ) > 0
					DbSelectArea("TMP1")
					TMP1->(DbCloseArea())
				EndIf
			
				TCQUERY cQuery NEW ALIAS "TMP1"
			
				DbSelectArea("TMP1")
				DbGoTop()
			
				While TMP1->(!Eof())
			
					DbSelectArea("SC6")
			  		DbGoTo(TMP1->SC6RECNO)
				  	RecLock("SC6",.F.)
			         SC6->C6_CCUSTO  := cCusNNT   
			         SC6->C6_XLOCDES := cAmzNNT
			   		MsUnlock()	
				TMP1->(DbSkip())		
				EndDo
				
				
				//Atualiza saldo Cotas após efetivar o pedido de transferencia
				cChave := 	cFilDes +; //Filial Destino
							cProNNT +; //Codigo Produto destino	
							cAmzNNT    // Armazem Destino  			
       		
	       		//Verifica tabela de cotas
	       		ZCC->(dbSelectArea("ZCC"))
	       		ZCC->(dbSetOrder(1))
	       		If ZCC->(dbSeek( cChave ))
				
	       			If ZCC->ZCC_QTDE1 > 0
		       			//Atualiza saldo
		       			RecLock("ZCC",.F.)
		       				ZCC->ZCC_QTDE1F		:= ZCC->ZCC_QTDE1 + nQt1NNT
		       				ZCC->ZCC_QTDE1  	:= ZCC->ZCC_QTDE1 - nQt1NNT   		       				
				   		MsUnlock()	
				   	ElseIf ZCC->ZCC_QTDE2 > 0
		       			//Atualiza saldo
		       			RecLock("ZCC",.F.)
		       				ZCC->ZCC_QTDE2F		:= ZCC->ZCC_QTDE2F + nQt2NNT
		       				ZCC->ZCC_QTDE2  	:= ZCC->ZCC_QTDE2 - nQt2NNT   		       				
				   		MsUnlock()					   	
				   	EndIf
				   		
				EndIf
					
			Next	            
       EndIf
EndIf
 
RestArea(aAreaNNT) 
RestArea(aAreaNNS)
RestArea(aArea)

Return lRet