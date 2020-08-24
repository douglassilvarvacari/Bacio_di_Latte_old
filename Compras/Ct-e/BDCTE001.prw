#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} User Function DBCTE001
    (long_description)
    @type  Function
    @author Douglas Rodrigues da Silva
    @since 15/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function DBCTE001()

    Local aPergs 	 := {}
    Local cCaminho  := Space(90)
    Local aRet      := {}

    aAdd( aPergs ,{6,"Diretorio do Arquivo?"	,cCaminho	,"@!",,'.T.',80,.F.,"Arquivo...|*.txt " }) 
   
    If ParamBox(aPergs ,"Parametros ",aRet)
        processa( {|| Importxt(MV_PAR01) } ,'Aguarde Efetuando Importacao da Planilha' )
    EndIf

RETURN

Static Function Importxt(cFile)

    Local aDados    := {}
    Local aItens
    Local aCabec    := {}
    Local aItem     := {}
    Local nX
    Local lMsErroAuto := .F.
    Local _cChav
    Private cCCG := ""

   	If ! Empty(cFile) 

		FT_FUSE(cFile)
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		
        While !FT_FEOF()
			
			IncProc("Selecionando Registros...")
	 
			cLinha := FT_FREADLN()
            
            //Guarda CNPJ fornecedor CT-e
            If SUBSTR(cLinha,1,3) == "351"
                cCCG    := SUBSTR(cLinha,4,14)
            EndIf

            // Importa Linha DOCCOB 3.6
            If SUBSTR(cLinha,1,3) == "353"
            		    
                AADD(aDados, { SUBSTR(cLinha,14,5) , SUBSTR(cLinha,19,12) } )

            EndIf    
							
			FT_FSKIP()
		EndDo

    EndIf


      //Efetua leitura dos dados
    ProcRegua( Len(aDados) )
           
        For i := 1 to Len(aDados)  //Leitura do Array importacao dos dados

            //Limpa cabeçalho de nota
            aCabec  := {}
            aItens  := {}
            nX      := 1
            aItem   := {}

            //Monta numero da nota
            cNumNota := STRZERO(Val(aDados[i][1]),3) + STRZERO(Val(aDados[i][2]),9) + "  " 

            //Busca Nota Fiscal Central XML
            cQuery := " SELECT * FROM RECNFCTE A JOIN RECNFCTEITENS B ON B.XIT_CHAVE = A.XML_CHAVE AND B.D_E_L_E_T_ != '*' WHERE A.XML_NUMNF LIKE '"+cNumNota+"' AND A.XML_EMIT = "+cCCG+" AND A.D_E_L_E_T_ != '*' "

            DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"SQL",.F.,.T.)

            Do While SQL->(!EOF())
                
                //Busca fornecedor
                SA2->(dbSelectArea("SA2"))
                SA2->(dbSetOrder(3))

                If SA2->(dbSeek(xFilial("SA2") + SQL->XML_EMIT))

                    _cChav := SQL->XML_CHAVE

                    If Empty(aCabec)
                        aadd(aCabec,{"F1_TIPO"    ,"N" ,NIL})
                        aadd(aCabec,{"F1_FORMUL"  ,"N" ,NIL})
                        aadd(aCabec,{"F1_DOC"     ,STRZERO(Val(aDados[i][2]),9) ,NIL})
                        aadd(aCabec,{"F1_SERIE"   ,STRZERO(Val(aDados[i][1]),3) ,NIL})
                        aadd(aCabec,{"F1_EMISSAO" ,STOD(SQL->XML_EMISSA) ,NIL})
                        aadd(aCabec,{"F1_DTDIGIT" ,DDATABASE ,NIL})
                        aadd(aCabec,{"F1_FORNECE" ,SA2->A2_COD ,NIL})
                        aadd(aCabec,{"F1_LOJA"    ,SA2->A2_LOJA ,NIL})
                        aadd(aCabec,{"F1_ESPECIE" ,"CTE" ,NIL})
                        aadd(aCabec,{"F1_COND"    ,"001" ,NIL})
                        aadd(aCabec,{"F1_DESPESA" , 0 ,NIL})
                        aadd(aCabec,{"F1_DESCONT" , 0 ,Nil})
                        aadd(aCabec,{"F1_SEGURO"  , 0 ,Nil})
                        aadd(aCabec,{"F1_FRETE"   , 0 ,Nil})
                        aadd(aCabec,{"F1_MOEDA"   , 1 ,Nil})
                        aadd(aCabec,{"F1_TXMOEDA" , 1 ,Nil})
                        aadd(aCabec,{"F1_STATUS"  , "A" ,Nil})
                        aadd(aCabec,{"F1_CHVNFE"  , SQL->XML_CHAVE ,Nil})
                    EndIf    

                        aItem := {}
                        aadd(aItem,{"D1_ITEM"   ,StrZero(nX,4) ,NIL})
                        aadd(aItem,{"D1_COD"    ,IIF(EMPTY(SQL->XIT_CODPRD), "SV901000000564",SQL->XIT_CODPRD)  ,NIL})
                        aadd(aItem,{"D1_UM"     ,"UN" ,NIL})
                        aadd(aItem,{"D1_LOCAL"  ,"800003" ,NIL})
                        aadd(aItem,{"D1_QUANT"  ,1 ,NIL})
                        aadd(aItem,{"D1_VUNIT"  ,SQL->XIT_PRUNIT ,NIL})
                        aadd(aItem,{"D1_TOTAL"  ,SQL->XIT_TOTAL ,NIL})
                        aadd(aItem,{"D1_TES"    ,"045" ,NIL})
                        aadd(aItem,{"D1_CONTA"  ,"415020001           ",NIL})
                        aadd(aItem,{"D1_GRUPO"  ,"9010",NIL})
                        aadd(aItem,{"D1_CLASFIS","090",NIL})
                        aadd(aItem,{"D1_NFORI"  ,SQL->XIT_NFORI,NIL})
                        aadd(aItem,{"D1_SERIORI",SQL->XIT_SRORI,NIL})    
                        aadd(aItem,{"D1_PICM"   ,SQL->XIT_PICICM,NIL})    

                        
                        //Busca Centro de Custos
                        SF2->(dbSelectArea("SF2"))
                        SF2->(dbSetOrder(1))
                        If SF2->(dbSeek("0031" + SQL->XIT_NFORI + SQL->XIT_SRORI ) )

                               cQuery := " SELECT TOP 1 NNT_LOCLD FROM "+RETSQLNAME("NNT")+" WHERE NNT_DOC = '"+SQL->XIT_NFORI+"' "

                               DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

                              aadd(aItem,{"D1_CC"  ,TRB->NNT_LOCLD,NIL})       

                              TRB->(DBCloseArea())                    
                        EndIf

                        aAdd(aItens,aItem) 
                        nX++

                EndIf                         
                
                SQL->(dbSkip())
            Enddo    

            Begin Transaction

                If Empty(aCabec)
                    Alert("ATENÇÃO: Nota fiscal não localizada para lançamento, verifique a importação dos XMLs " + cNumNota)
                else
                    
                    MATA140(aCabec,aItens,3,,1)

                    If ! lMsErroAuto      							
                            DisarmTransaction()
                            lMsErroAuto := .T.
                            mostraerro()                                       
                    Else	

                        cQuery2 := "SELECT F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_TIPO " +CRLF   
                        cQuery2 += "FROM "+RETSQLNAME("SF1")+" SF1" +CRLF   
                        cQuery2 += "WHERE SF1.D_E_L_E_T_ != '*' AND SF1.F1_FILIAL = '"+xFilial("SF1")+ "' AND SF1.F1_DOC = '"+STRZERO(Val(aDados[i][2]),9)+"' AND SF1.F1_SERIE = '"+STRZERO(Val(aDados[i][1]),3) +"' " +CRLF  
                        
                        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2 ),"TF1",.F.,.T.)					
                        
                        If ! EMPTY(TF1->F1_DOC)
                                               
                            SF1->(DBSELECTAREA("SF1"))
                            SF1->(DBSETORDER(1))
                            If SF1->(DBSEEK(TF1->F1_FILIAL+TF1->F1_DOC+TF1->F1_SERIE+TF1->F1_FORNECE+TF1->F1_LOJA+TF1->F1_TIPO))
                                Reclock("SF1",.F.)
                                    SF1->F1_CHVNFE := _cChav
                                MSUnLock()
                            EndIf
                            
                        EndIf
                                                
                        TF1->(DBCLOSEAREA())	    
                    EndIf    

                    EndIf

            End Transaction     
            
            SQL->(DBCloseArea())

        Next i

    

Return
