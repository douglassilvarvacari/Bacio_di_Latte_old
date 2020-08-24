/*//#########################################################################################
Modulo  : Estoque
Fonte   : blestr14
Objetivo: Exibir dados para relatório de inventário
*///#########################################################################################

#INCLUDE 'TOTVS.CH'
#INCLUDE 'REPORT.CH'

/*/{Protheus.doc} blestr14
   Gerenciador de Processamento
   @author  Douglas Rodrigues da Silva
   @table   Tabelas
   @since   28-01-2020
/*/
User Function BLESTR14()
  
  	Local aParamBox := {}
	
	Private aRet := {}
		
	aAdd(aParamBox,{1,"Data Inventário"  ,Ctod(Space(8)),"","","","",50,.T.})
		
	If ParamBox(aParamBox,"Extrator Dados...",@aRet)
			
		xProc9(aRet[1])
	
	EndIf

Return


Static Function xProc9(dData)
	
	cQuery := " SELECT "
	cQuery += " 	SB7.B7_FILIAL, " 
	cQuery += " 	B7_COD, " 
	cQuery += " 	B1_DESC, " 
	cQuery += " 	B1_UM, " 
	cQuery += " 	B7_LOCAL, " 
	cQuery += " 	B7_QUANT, " 
	cQuery += " 	SB7.B7_QUANT * SB1.B1_CUSTD AS B1_CUSTD, " 
	cQuery += " 	SB1.B1_CUSTD "
	cQuery += " FROM "+RETSQLNAME("SB7")+" SB7 WITH (NOLOCK) "
	cQuery += " JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) 
	cQuery += " 	ON SB1.B1_FILIAL = '' " 
	cQuery += " 	AND SB7.B7_COD = SB1.B1_COD "  
	cQuery += " 	AND SB1.D_E_L_E_T_ != '*' "
	cQuery += " WHERE " 
	cQuery += " 	B7_FILIAL != '' "
	cQuery += " 	AND B7_DATA = '"+DTOS(dData)+"' " 
	cQuery += " 	AND SB7.D_E_L_E_T_ = '' " 
	cQuery += " 	AND SB1.D_E_L_E_T_ = '' "
	cQuery += " 	AND B7_DOC = '"+DTOS(dData)+"' "
	cQuery += " 	ORDER BY 2 "
	
	U_QRYCSV(cQuery,"SB7 - Resumo Inventário")

Return