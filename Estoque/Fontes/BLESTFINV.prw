#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TopConn.ch"

user function BLESTFINV()

/*//#########################################################################################
Projeto : Inventario
Modulo  : Estoque
Fonte   : BLESTFINV - Rodolfo Vacari 23/01/2020
Objetivo: Deletar o inventario, conforme parametro
*///#########################################################################################

    Local cPergINV := PadR('blestfinv',10)
    //local ccAlias := getNextAlias()

    xCriaPerg(cPergINV)

    If Pergunte(cPergINV,.T.)
    	xDELINV01()
    EndIf
    	
Return

/*/{Protheus.doc} xDELINV01
   Deletar Inventario
   @author  Nome
   @table   Tabelas
   @since   23-01-2020
/*/
Static Function xDELINV01()

    local _xTotal := 0
    local _cQuery := ""
	local _cFili  := ""
	local _cCod	  := ""
    
    _cQuery := "SELECT B7_FILIAL,B7_COD,ISNULL(B7_DOC,'') B7_DOC, SUM(SB7.B7_QUANT*SB1.B1_CUSTD) AS CUSTO_TOTAL "
    _cQuery += "FROM "+RetSqlName("SB7")+" SB7 JOIN "+RetSqlName("SB1")+" SB1 ON B7_COD = B1_COD " 
    _cQuery += "WHERE B7_DATA = '"+DTOS(MV_PAR03)+"'"+" AND SB7.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
    _cQuery += "AND B7_LOCAL = '"+MV_PAR02+"'"+" AND B7_DOC = '"+MV_PAR01+"'" 
    _cQuery += "GROUP BY B7_FILIAL, B7_DOC, B7_LOCAL "
     
    If ( Select("TMP1") ) > 0
		DbSelectArea("TMP1")
		TMP1->(DbCloseArea())
	EndIf

	TCQUERY _cQuery NEW ALIAS "TMP1"
	
	_xTotal := TMP1->CUSTO_TOTAL
	_cFili	:= TMP1->B7_FILIAL
	_cCod	:= TMP1->B7_COD
	
	If Empty( TMP1->B7_DOC )
		Alert("ATENÇÃO: Inventário não localizado, verifique documento e dada!")
	Else	
		Alert('Loja:'+MV_PAR02+' - Valor:'+_xTotal+' - Data:'+MV_PAR03)    
	
		If MsgYesNo('Deseja Deletar Inventário?')

		/* 			Alteração feita por Felipe Mayer RVACARI - Motivo: Método anterior estava corrompendo a tabela SB7 - 04/05/2020  

		TCSQLEXEC("DELETE FROM "+ RetSqlName("SB7")+" WHERE D_E_L_E_T_ != '*' AND B7_DATA = '"+DTOS(MV_PAR03)+"' "+" B7_DOC = '"+MV_PAR01+"' "+"B7_LOCAL = '"+MV_PAR02+"'")  */

		    DbSelectArea('SB7')
			SB7->(DbSetOrder(1))
			SB7->(DbGoTop())
			
			If SB7->(DbSeek(_cFili+DToS(MV_PAR03)+_cCod+MV_PAR02))
				RecLock('SB7', .F.)
				DbDelete()
				SB7->(MsUnlock())
    		EndIf

		EndIf
		
		MsgInfo("Finalizado!!!")
		
	EndIf	
	
return

/*/{Protheus.doc} xCriaPerg
   Ajustar Grupo de perguntas ou criá-lo caso não exista
   @author  Rodolfo Vacari
   @table   SX1
   @since   23-01-2020
/*/
Static Function xCriaPerg(cPerg)

Local _aPerg  := {}
Local _ni

Aadd(_aPerg,{"Documento:","mv_ch1","C",8,0,"G","","mv_par01","","","","","","",""})
Aadd(_aPerg,{"Loja:","mv_ch2","C",6,0,"G","","mv_par02","","","","","","NNR",""})
Aadd(_aPerg,{"Data Inv:","mv_ch3","D",8,0,"G","","mv_par03","","","","","","",""})


dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(cPerg+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_PERSPA   := _aPerg[_ni][1]
		SX1->X1_PERENG   := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_DECIMAL  := _aPerg[_ni][5]
		SX1->X1_GSC      := _aPerg[_ni][6]
		SX1->X1_VALID	 := _aPerg[_ni][7]
		SX1->X1_VAR01    := _aPerg[_ni][8]
		SX1->X1_DEF01    := _aPerg[_ni][9]
		SX1->X1_DEFSPA1  := _aPerg[_ni][9]
		SX1->X1_DEFENG1  := _aPerg[_ni][9]
		SX1->X1_DEF02    := _aPerg[_ni][10]
		SX1->X1_DEFSPA2  := _aPerg[_ni][10]
		SX1->X1_DEFENG2  := _aPerg[_ni][10]
		SX1->X1_DEF03    := _aPerg[_ni][11]
		SX1->X1_DEFSPA3  := _aPerg[_ni][11]
		SX1->X1_DEFENG3  := _aPerg[_ni][11]
        SX1->X1_DEF04    := _aPerg[_ni][12]
		SX1->X1_DEFSPA4  := _aPerg[_ni][12]
		SX1->X1_DEFENG4  := _aPerg[_ni][12]
        SX1->X1_DEF05    := _aPerg[_ni][13]
		SX1->X1_DEFSPA5  := _aPerg[_ni][13]
		SX1->X1_DEFENG5  := _aPerg[_ni][13]
        SX1->X1_F3       := _aPerg[_ni][14]
		SX1->X1_CNT01    := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return
	
return