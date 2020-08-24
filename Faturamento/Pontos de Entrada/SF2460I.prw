#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SF2460I   �Autor  �Elaine Mazaro       � Data �  23/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada localizado apos a atualizacao das tabelas  ���
���          � referentes a nota fiscal (SF2/SD2), mas antes da           ��� 
���          � contabilizacao.                                            ��� 
�������������������������������������������������������������������������͹��
���Uso       � Bacio                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SF2460I() 
                                      	 
	U_BACDM040()
	ADJ_NF()
	
Return(Nil)

//+---------------------------------------------------------------------+
//| Ajuste Nota Fiscal                                                  |
//+---------------------------------------------------------------------+

Static Function ADJ_NF()

	Local lRet		:= .T.
	Local aAreaAnt 	:= GETAREA()
	Local aRet		:= {}
	Local aParamBox	:= {}
	Local cInfCompl	:= ""
	Local cMennota 	 
	
	//Verifica se esta fabrica
	If SF2->F2_FILIAL == "0031"
	
		//Cria mensagem padr�o para dados adicionais NF-e
		
		//Robo para buscar informa��es complementares Nota Fiscais
		
		//cInfCompl := XBUSCEND( SUBSTR(NNT->NNT_LOCLD,1,4)) + SPACE(100)		
		If Empty(cInfCompl)
		 	cInfCompl := SPACE(80)
		EndIf
					
		aAdd(aParamBox,{1,"Volume Pedido" ,SC5->C5_VOLUME1,"@E 999.99","","","",20,.F.}) // Volume de carga pedido de venda 
		aAdd(aParamBox,{1,"Transportadora",SC5->C5_TRANSP ,"","ExistCPO('SA4')","SA4","",0,.F.}) // Tipo caractere
		aAdd(aParamBox,{3,"Tipo Frete",1,{"CIF","FOB"},50,"",.F.})
		aAdd(aParamBox,{1,"Tipo Volume",Space(10),"","","SAH","",0,.F.})
		aAdd(aParamBox,{1,"Endere�o",Space(10),"","","SAH","",0,.F.})
		aAdd(aParamBox,{11,"Mensagem NF-e",cInfCompl,".T.",".T.",.T.})
		
		If ParamBox(aParamBox ,"Parametros ",aRet)
		    
			SF2->F2_VOLUME1	:= aRet[1]
			SF2->F2_TRANSP	:= aRet[2]
			SF2->F2_TPFRETE	:= IIF(aRet[3] == 1, "C", "F")
			SF2->F2_ESPECI1	:= Alltrim( UPPER(aRet[4]) )
			SF2->F2_XMENS	:= Alltrim( aRet[5] )
			SF2->F2_XSTATUS	:= "2"  

		Else
			
			Return( lRet )

		EndIf		
		
		//Efetua manuten��o cabe�alho pedido de venda
		If SC5->C5_FILIAL + SC5->C5_NUM == SD2->D2_FILIAL + SD2->D2_PEDIDO 
		
			If Empty( SC5->C5_MENNOTA )
		
				//Verifica se encontra a transfer�ncia e ajusta endere�o de entrega da nota fiscal
				NNR->(dbselectarea("NNR"))
				NNR->(dbsetorder(1))
				If NNR->( dbseek( NNT->NNT_FILDES + NNS->NNS_COD ))    		
					cMennota := "Entreg em: " + Alltrim( NNR->NNR_DESCRI ) + " Num Transferecia.: "+ Alltrim( NNT->NNT_COD ) 				       
				EndIf  
			
			EndIf	
		
			//Verificar se o Array foi preeochido ou a��o foi cancelada pelao usu�rio - Douglas Silva 10.03.2020
			If Len(aRet) > 1

				RecLock("SC5",.F.)
					SC5->C5_VOLUME1	:= aRet[1]
					SC5->C5_TRANSP	:= aRet[2]
					SC5->C5_TPFRETE	:= IIF(aRet[3] == 1, "C", "F")
					SC5->C5_ESPECI1	:= UPPER(aRet[4])	
					SC5->C5_MENNOTA	:= IIF (EMPTY(SC5->C5_MENNOTA), cMennota, SC5->C5_MENNOTA )													
				MsUnlock()

			EndIf

			
		EndIf
					
	EndIf
	
	RestArea(aAreaAnt)
	
Return( lRet )

//+---------------------------------------------------------------------+
//| Rotina autom�tica para envio do Endere�o de entrega                 |
//+---------------------------------------------------------------------+

Static Function XBUSCEND(xLocDes)

	Local cEndRet
	Local cQuery

	cQuery := " SELECT TOP 1 " + CRLF
	cQuery += " UPPER(F2_XMENS) XMENS " + CRLF
	cQuery += " FROM "+RETSQLNAME("SF2")+" " + CRLF 
	cQuery += " WHERE " + CRLF 
	cQuery += " 	F2_FILIAL = '0031' " + CRLF 
	cQuery += " 	AND SUBSTRING(F2_EMISSAO,1,4) = '2019' " + CRLF 
	cQuery += " 	AND SUBSTRING(F2_MENNOTA,15,4) =  '"+xLocDes+"' " + CRLF 
	cQuery += " 	AND F2_XMENS != '' " + CRLF 
	cQuery += " 	AND D_E_L_E_T_ != '*' " + CRLF
	cQuery += " ORDER BY F2_EMISSAO DESC " + CRLF
	
	If ( Select("TMP1") ) > 0
		DbSelectArea("TMP1")
		TMP1->(DbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "TMP1"

	DbSelectArea("TMP1")
	DbGoTop()
	
	cEndRet := TMP1->XMENS
			
Return(cEndRet)