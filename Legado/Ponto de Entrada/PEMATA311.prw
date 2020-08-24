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

Local aArea    := Getarea()
Local aAreaNNT := NNT->(Getarea())
Local aAreaNNS := NNS->(Getarea())
Local aParam     := PARAMIXB
Local lRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''
Local lEfetiva	:= IsInCallStack("A311Efetiv") 
Local nLinha := 0 
 
If aParam <> NIL
      
       oObj       := aParam[1]
       cIdPonto   := aParam[2]
       cIdModel   := aParam[3]
       lIsGrid    := ( Len( aParam ) > 3 )
                  
       If cIdPonto == 'MODELCOMMITNTTS' .and. lEfetiva
		
			oModelNNS := oObj:AALLSUBMODELS[1] // Cabecalho
			oModelNNT := oObj:AALLSUBMODELS[2] // Itens
						
			// Loop para os ites da Transferencia 
			For nX:= 1 To oModelNNT:GetQtdLine() 
				oModelNNT:GoLine(nX)
					
				cFilNNT := oModelNNT:GetValue("NNT_FILORI") // C6_FILIAL
				cDocNNT := oModelNNT:GetValue("NNT_DOC") // C6_NOTA
				cSerNNT := oModelNNT:GetValue("NNT_SERIE") // C6_SERIE
				cProNNT := oModelNNT:GetValue("NNT_PROD") // C6_PRODUTO
				cCusNNT := oModelNNT:GetValue("NNT_XCC") // C6_CCUSTO
				cAmzNNT := oModelNNT:GetValue("NNT_LOCLD") // C6_XLOCDES
		 	 
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
			Next	            
       EndIf
EndIf
 
RestArea(aAreaNNT) 
RestArea(aAreaNNS)
RestArea(aArea)

Return lRet
