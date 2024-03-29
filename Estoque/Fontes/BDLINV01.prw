#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北篜rograma � BDLINV01     篈utor� Felipe Mayer	      � Data Ini� 03/02/2020 �		  北
北掏屯屯屯屯赝屯屯屯屯屯屯屯屯释屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯凸北
北篋esc.    � 	Excluir Itens Duplicados do inventario			 					  北
北掏屯屯屯屯赝屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北篣so      � 		BACIO DI LATTE                                            		 罕�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function BDLINV01()

Local aPergs   := {}
Private oDlg
Private nOpca  := 0
Private dData  := SToD('')

	aAdd(aPergs, {1, "Data do Inventario ",  dData,  "", ".T.", "", ".T.", 80,  .F.})
	
		If ParamBox(aPergs, "Exclus鉶 de itens duplicados")
			
			DEFINE MSDIALOG oDlg FROM 003,001 To 120,520 TITLE OemToAnsi("Exclus鉶 de itens duplicados") PIXEL   
			@ 005,003 To 048,258 LABEL "" OF oDlg  PIXEL
			@ 015,015 SAY OemToAnsi("Esta rotina realiza a exclus鉶 de itens duplicados no inventario da empresa Bacio di Latte.") SIZE 268, 8 OF oDlg PIXEL
			@ 027,015 SAY OemToAnsi("Confirma a exclus鉶 dos itens duplicados?") SIZE 268, 8 OF oDlg PIXEL
			DEFINE SBUTTON FROM 032,188 TYPE 1 ACTION PRCQRY() ENABLE OF oDlg
			DEFINE SBUTTON FROM 032,218 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER
			
		EndIf	
		        
Return

Static Function PRCQRY()

processa( {|| QRYUPDT() }, "BDLINV01", "Processando aguarde...", .f.)

MsgInfo("Processo Finalizado!","BDLINV01")
oDlg:End()

Return

Static Function QRYUPDT()

Local cQuery
	
		cQuery := " WITH DPL AS (SELECT B7_FILIAL, B7_COD, B7_LOCAL, B7_QUANT, B7_DATA, B7_DOC, MAX(R_E_C_N_O_) RECNO FROM "+RETSQLNAME("SB7")+"  "
		cQuery += " WHERE B7_DATA =  '"+ DToS(MV_PAR01) +"' AND D_E_L_E_T_ = '' "
		cQuery += " GROUP BY B7_FILIAL, B7_COD, B7_LOCAL, B7_QUANT, B7_DATA, B7_DOC "
		cQuery += " HAVING COUNT(*) > 1) "
		cQuery += " UPDATE B7 "
		cQuery += " SET D_E_L_E_T_ ='*' "
		cQuery += " "+RETSQLNAME("SB7")+" "
		cQuery += " JOIN DPL ON "
		cQuery += " B7.B7_FILIAL = DPL.B7_FILIAL "
		cQuery += " AND B7.B7_COD = DPL.B7_COD "
		cQuery += " AND B7.B7_LOCAL = DPL.B7_LOCAL "
		cQuery += " AND B7.B7_QUANT = DPL.B7_QUANT "
		cQuery += " AND B7.B7_DATA = DPL.B7_DATA "
		cQuery += " AND B7.R_E_C_N_O_ < DPL.RECNO "
	
		TCSQLExec(cQuery)
						
Return