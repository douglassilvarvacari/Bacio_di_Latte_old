/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    � SF1100I  � Autor � Jeremias Lameze Jr.   � Data � 10.02.17   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o � Validacao dos Itens da Nota Fiscal de Entrada                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � SF1100I			                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � BACIO                                                        潮�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

User Function SF1100I()
//*
Local aAreaLoc	:= GetArea(),cPrefSE2:= &(GetMv("MV_2DUPREF")),cFilSE2 := xFilial("SE2")
Local aAreaSE2,cPrefSE1:= AllTrim(&(GetMv("MV_1DUPREF"))),cFilSE1 := xFilial("SE1")
Local cFrmPgto,aAreaSD1,cCusto:=" ",cItemCta:=" ",cClVl:=" ",cGrupo:=" ",cDescIt:=" ",cXObs:=" ",aAreaSC7
Local nDifTam 	:= TamSX3("F1_DOC")[1] - 6
Local nTamData := IIF(__SetCentury(),10,8)
Local aRet		:= {}               
local cBdlHist  :=""

aAreaSF1 := SF1->(GetArea())
//*
cPrefSE1 := cPrefSE1+SPACE(03-Len(cPrefSE1))
//cPrefSE2 := cPrefSE2+SPACE(03-Len(cPrefSE2))// Removid em 05abril2018 muitos titulos est鉶 sendo gravos sem centro de custo, foi removido o altril deste variavel 
//*
//u_F1LANCTO()
//*
If !SF1->F1_TIPO $ "DB"
	If !Empty(SF1->F1_DUPL)
		dbSelectArea("SD1")
		aAreaSD1 := GetArea()
		dbSetOrder(1)
		MsSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		If !Eof()
			cCusto  := SD1->D1_CC
		Endif     
		
		//Historic0 financeiro Bacio 
   		DbSelectArea("SA2")
   		SA2->(DbSetOrder(1)) 
   		If SA2->(dbSeek( xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))   
   			cBdlHist := alltrim(SA2->A2_XHIST)   		
   		ENDIF
		
		

		dbSelectArea("SE2")
		dbSetOrder(1)
		dbSelectArea("SE2")
		aAreaSE2 := GetArea()
		dbSeek(cFilSE2+cPrefSE2+SF1->F1_DOC)
		While !Eof() .And. SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == cFilSE2+cPrefSE2+SF1->F1_DOC
			If SE2->E2_FORNECE+SE2->E2_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA              
			
				RecLock("SE2",.F.)
					IF !Empty(cCusto)
						SE2->E2_CCUSTO  := cCusto
					Else
						SE2->E2_CCUSTO	:= " "
					EndIf   
					
					IF !Empty(cBdlHist)  
						SE2->E2_HIST := cBdlHist				
					ENDIF	 
					
					//Altera玢o realizada por Douglas Silva 22/01/2020 - Verifica vencimento do t韙ulo
					If SE2->E2_VENCTO <= Date()
						SE2->E2_VENCTO 	:= Date() + 1
						SE2->E2_VENCREA := DataValida( Date() + 1 ,.T.)
					EndIf
									  
				MsUnLock()
			Endif
			dbSkip()
		End
		RestArea(aAreaSE2)
	Endif
Endif                           

RecLock("SF1",.F.) 
SF1->F1_XDTCLAS := Date() 
SF1->(MsUnlock()) 

RestArea(aAreaSF1)
RestArea(aAreaLoc)
Return