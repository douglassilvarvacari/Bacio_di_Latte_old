#Include "tbiconn.ch"
#Include "protheus.ch"


/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 篜rograma � BDLFIS01         篈utor� RVACARI Felipe Mayer	    � Data Ini� 09/03/2020   罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 篋esc.    � Excluir duplicidade da camada                                                  北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 篣so      � BACIO DI LATTE	                                            		  		  北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北*/

User Function BDLFIS01()

Local aPergs  := {}
Local cMes    := Space(2)
Local cAno    := Space(4)

    aAdd(aPergs, {1, "M阺",  cMes,  "",  ".T.",   "",  ".T.", 80,  .T.})
    aAdd(aPergs, {1, "Ano",	 cAno,  "",  ".T.",   "",  ".T.", 80,  .T.})

    If ParamBox(aPergs, "Excluir Duplicidade da Camada")
        MsAguarde({|| DelDupli()},,"Excluindo duplicidade...")
    EndIf

Return Nil


/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 Static.	 � DelDupli     |    篈utor� RVACARI Felipe Mayer	    � Data Ini� 09/03/2020    北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 篋escR.   � Respons醰el por montar Query do Update               						  北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北*/

Static Function DelDupli()

Local cData   := MV_PAR02+MV_PAR01
Local cQuery  := ''

Private MV_PAR01
Private MV_PAR02

    cQuery := " UPDATE "+RetSqlName("PIN")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
    cQuery += " WHERE SUBSTRING(PIN_EMISNF,1,6) = '"+cData+"' "
    cQuery += " AND PIN_LOGINT IN  ('STR0130' , 'STR0132') "
    cQuery += " AND D_E_L_E_T_ != '*' "

    TCSQLExec(cQuery)

    MsgInfo("Processo Finalizado!","BDLFIS01")

Return