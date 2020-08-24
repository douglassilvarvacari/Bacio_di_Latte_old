#include 'protheus.ch'
#include 'Restful.ch'
#include 'tbiconn.ch'

/*/{Protheus.doc} User Function REST010
    (long_description)
    @type  Function
    @author Douglas Rodrigues da Silva
    @since 17/04/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function REST011()
Return 

WSRESTFUL Gestor_Inventario DESCRIPTION "RestFul Gestor Lojas Inventario" FORMAT "application/json"

    WSDATA apiKey AS STRING  //PARAMETRO COM A CHAVE PARA AUTENTICACAO

    WSMETHOD GET DESCRIPTION "Gestor Lojas Base de dados" WSSYNTAX "/Gestor_Inventario/{}"
    WSMETHOD POST DESCRIPTION "Gestor Lojas Post Inventï¿½rio" WSSYNTAX "/Gestor_Inventario/{}"

END WSRESTFUL

WSMETHOD GET WSSERVICE Gestor_Inventario

    Local lRet          := .T.
    Local oResponse     := JsonObject():New()
    Local apiKeyAuth	:= ::apiKey
    Local lLoginOk      := SuperGetMV("MV_XAPIKEY",.F.,"1234") == apiKeyAuth
    Local nLin          := 1
    Local cAmbinetes    := ""
    Local aAmbientes

     If Valtype(apiKeyAuth) == 'U'
        SetRestFault(400, 'Informe a chave token! ' + apiKeyAuth)
        lRet := .F.
    EndIf       

    if !lLoginOk
    	SetRestFault(403,"Falha durante o login, verifique a chave " + apiKeyAuth )	
	    return .F.
    endif

    If Intransaction()
        DisarmTransaction()
        SetRestFault(500, '{"erro - Thread em Aberto"}')
        ConOut("Erro - Thread em aberto...")   
        return .F.
    EndIf

    ::SetContentType('application/json')

    //Montagem Json Ambientes
    oResponse['ambientes']  := {}

    For nLin := 1 To 5

        oJsonAmb := JsonObject():New()   

        If nLin == 1
            oJsonAmb['id']      := '1'
            oJsonAmb['desc']    := "Camara fria"   
        ElseIf nLin == 2
            oJsonAmb['id']      := '2'
            oJsonAmb['desc']    := "Deposito"
        ElseIf nLin == 3
            oJsonAmb['id']      := '3'
            oJsonAmb['desc']    := "Estoque"
        ElseIf nLin == 4    
            oJsonAmb['id']      := '4'
            oJsonAmb['desc']    := "Freezer" 
        ElseIf nLin == 5   
            oJsonAmb['id']      := '5'
            oJsonAmb['desc']    := "Loja Vitrine"
        EndIf               
     
        aAdd(oResponse['ambientes'], oJsonAmb)
    Next
  
    oResponse['lojas']  := {}

    NNR->(DbSetOrder(1))
	NNR->(DbGoTop())
	Do While NNR->(!Eof())
		
        oJsonlj := JsonObject():New()
            
            If NNR->NNR_CODIGO != '000001' .And. NNR->NNR_XINV == '1'

                //Verifica se AramzÃ©m vai para inventÃ¡rio e estÃ¡ desbloqueado
                oJsonlj['filial_loja']  := NNR->NNR_FILIAL
                oJsonlj['codigo_Loja']	:= NNR->NNR_CODIGO
                oJsonlj['nome_loja']	:= Alltrim(NNR->NNR_DESCRI)
                oJsonlj['bloqueado']    := IIF(NNR->NNR_MSBLQL == "1", "1","2") 
                oJsonlj['nf_pendente']    := "1"
                
                cAmbinetes := ""

                If  NNR->NNR_XACA == '1'
                    cAmbinetes  += '1,'
                EndIf    
                
                If NNR->NNR_XADE == '1'
                    cAmbinetes +=  '2,'
                EndIf    
                
                If NNR->NNR_XAES == '1'
                    cAmbinetes += '3,'
                EndIf    

                If NNR->NNR_XAFR == '1'
                    cAmbinetes += '4,'
                EndIf    
                
                If NNR->NNR_XALV == '1'
                    cAmbinetes += '5'  
                EndIf    

                aAmbientes := SEPARA (cAmbinetes, ',', .f.)

                oJsonlj['ambientes']    := aAmbientes                         

                aAdd(oResponse['lojas'], oJsonlj)

            EndIf    
        		
		NNR->(DbSkip())
	EndDo
    
    oResponse['produtos']  := {}
    
    SB1->(DbSetOrder(1))
    SB1->(DbGoTop())
    Do While SB1->(!Eof())     

        If SB1->B1_XLISTA == 'S'

            oJsonSB1 := JsonObject():New()

            oJsonSB1['codigo_produto']  := SB1->B1_COD
            oJsonSB1['descricao_prod']	:= Alltrim(SB1->B1_DESC)
            oJsonSB1['descricao_inve']	:= Alltrim(SB1->B1_XDESINV)
            oJsonSB1['mostra_inventario']:= IIF(SB1->B1_XLISTA == 'S', '1', '2')

                //Monta Json Grupos

                oJsonGRP := JsonObject():New()
                oJsonAGL := JsonObject():New()
                oJsonAGL := {}   

                If !EMPTY(SB1->B1_XUNCF) .And. !EMPTY(SB1->B1_XFACF)
                    oJsonGRP['id']      := '1'
                    oJsonGRP['unidade'] := SB1->B1_XUNCF
                    oJsonGRP['conv']    := SB1->B1_XFACF
                Endif

                aAdd(oJsonAGL, oJsonGRP)

                oJsonGRP := JsonObject():New()
                
                If !EMPTY(SB1->B1_XUNDE) .And. !EMPTY(SB1->B1_XFADE)
                    oJsonGRP['id']      := '2'
                    oJsonGRP['unidade'] := SB1->B1_XUNDE
                    oJsonGRP['conv']    := SB1->B1_XFADE
                Endif

                aAdd(oJsonAGL, oJsonGRP)

                oJsonGRP := JsonObject():New()
                
                If !EMPTY(SB1->B1_XUNES) .And. !EMPTY(SB1->B1_XFAES)
                    oJsonGRP['id']      := '3'
                    oJsonGRP['unidade'] := SB1->B1_XUNES
                    oJsonGRP['conv']    := SB1->B1_XFAES
                Endif

                aAdd(oJsonAGL, oJsonGRP)

                oJsonGRP := JsonObject():New()
                
                If !EMPTY(SB1->B1_XFAFR) .And. !EMPTY(SB1->B1_XUNFR)
                    oJsonGRP['id']      := '4'
                    oJsonGRP['unidade'] := SB1->B1_XUNFR
                    oJsonGRP['conv']    := SB1->B1_XFAFR
                Endif

                aAdd(oJsonAGL, oJsonGRP)

                 oJsonGRP := JsonObject():New()
                
                If !EMPTY(SB1->B1_XFALV) .And. !EMPTY(SB1->B1_XUNLV)
                    oJsonGRP['id']      := '5'
                    oJsonGRP['unidade'] := SB1->B1_XUNLV
                    oJsonGRP['conv']    := SB1->B1_XFALV
                Endif

            aAdd(oJsonAGL, oJsonGRP)

            oJsonSB1['ambientes']    := oJsonAGL

            oJsonSB1['grupo1']      := IIF( EMPTY(SB1->B1_XGPR1) , '5', SB1->B1_XGPR1)
            oJsonSB1['grupo2']      := IIF( EMPTY(SB1->B1_XINVGRP), '99', SB1->B1_XINVGRP)     

            aAdd(oResponse['produtos'], oJsonSB1)

        EndIf
        
        SB1->(DbSkip())
    EndDo
     
    //Cria Tabela de grupo1
    oResponse['grupo1']  := {}
    For nLin := 1 To 5

        oJson1GPR := JsonObject():New()

         If nLin== 1
            oJson1GPR['id']     := '1'
            oJson1GPR['desc']   := 'Cafes & Doces'
        ElseIf nLin == 2
            oJson1GPR['id']     := '2'
            oJson1GPR['desc']   := 'Embalagens'
        ElseIf nLin == 3
            oJson1GPR['id']     := '3'
            oJson1GPR['desc']   := 'Gelato'
        ElseIf nLin == 4
            oJson1GPR['id']     := '4'
            oJson1GPR['desc']   := 'Insumos'
        ElseIf nLin == 5
            oJson1GPR['id']     := '5'
            oJson1GPR['desc']   := 'Outros'
         EndIf

        aAdd(oResponse['grupo1'], oJson1GPR)

    Next 
    
    oResponse['grupo2']  := {}

    SX5->(dbSelectArea("SX5"))
    SX5->(dbSetOrder(1))
    SX5->(dbSeek( xFilial("SX5") + "Z3"))

    Do While SX5->(!EOF() .And. SX5->X5_TABELA == "Z3")

        oJsonSX5 := JsonObject():New()
        
        oJsonSX5['Codigo']      := Alltrim(SX5->X5_CHAVE)
        oJsonSX5['Descricao']	:= Alltrim(SX5->X5_DESCRI)

         aAdd(oResponse['grupo2'], oJsonSX5)	

        SX5->(dbSkip())
    Enddo  

    oJsonSX5['Codigo']      := "99"
    oJsonSX5['Descricao']	:= "outros"

    aAdd(oResponse['grupo2'], oJsonSX5)
    
    oResponse['bloqueados']  := {}

    ZZ2->(dbSelectArea("ZZ2"))
    ZZ2->(dbSetOrder(1))
    
    Do While ZZ2->(!EOF() )

        oJsonZZ2 := JsonObject():New()
        
        oJsonZZ2['filial']      := Alltrim(ZZ2->ZZ2_FILIAL)
        oJsonZZ2['codigo']	    := Alltrim(ZZ2->ZZ2_COD)
        oJsonZZ2['loja']	    := Alltrim(ZZ2->ZZ2_LOCAL)

         aAdd(oResponse['bloqueados'], oJsonZZ2)	

        ZZ2->(dbSkip())
    Enddo    
    
    ::SetResponse(oResponse:toJson())

Return lRet 

WSMETHOD POST WSSERVICE Gestor_Inventario

    Local lPost     := .T.
    Local cJson     := ::getContent()
    Local oResponse := JsonObject():New()
    Local oItens
	  
    Local nCampo1 := TamSx3("B7_FILIAL")[1]
    Local nCampo2 := TamSx3("B7_COD")[1]
    Local nCampo3 := TamSx3("B7_LOCAL")[1]
    Local nCampo4 := TamSx3("B7_DOC")[1]

    Local cXFilial
    Local cXCod
    Local cXLocal
    Local xXDoc
    Local aProdGrv  := {}
    Local cHoraIni
    Local dDataIni
    Local nOK := 0 
    Local nDP := 0
    Local nER := 0
    
    Private lMsErroAuto     := .F.
    Private oJson
    Private aDados    := {}
    
    oJson   := JsonObject():New()
    cError  := oJson:FromJson(cJson)
    //Se tiver algum erro no Parse, encerra a execuï¿½ï¿½o
    IF .NOT. Empty(cError)
        SetRestFault(500,'Parser Json Error')
        lRet    := .F.
    Else
    
        SB7->(dbSelectArea("SB7"))
        SB7->(dbSetOrder(3)) 
        
        dDataIni    := Date()
        cHoraIni    := Time()
        
        oItens  := oJson:GetJsonObject('itens')
        For i:=1 To Len(oItens)
            
            aDados := {}

            //Inicia motagem array de dados inventï¿½rio
            aAdd(aDados,{'B7_FILIAL', oJson:GetJsonObject('filial')	    , nil})
            aAdd(aDados,{'B7_LOCAL' , oJson:GetJsonObject('loja')       , nil})	
            aAdd(aDados,{'B7_DOC'	, oJson:GetJsonObject('documento')	, nil})
            aAdd(aDados,{'B7_COD'	, oItens[i]:GetJsonObject('produto')	, nil})
            aAdd(aDados,{'B7_QUANT'	, oItens[i]:GetJsonObject('qtde1') , nil})	
            aAdd(aDados,{'B7_QTSEGUM',oItens[i]:GetJsonObject('qtde2') , nil})	
            aAdd(aDados,{'B7_DATA'	, STOD(  oJson:GetJsonObject('documento') ), nil})
            
            cXFilial    := Alltrim( oJson:GetJsonObject('filial') ) + SPACE(nCampo1 - Len ( Alltrim( oJson:GetJsonObject('filial') ) ))
            cXCod       := Alltrim( oItens[i]:GetJsonObject('produto') ) + SPACE(nCampo2 - Len ( Alltrim( oItens[i]:GetJsonObject('produto') )) )
            cXLocal     := Alltrim( oJson:GetJsonObject('loja') ) + SPACE(nCampo3 - Len ( Alltrim( oJson:GetJsonObject('loja') )) )
            xXDoc       := Alltrim( oJson:GetJsonObject('documento') ) + SPACE(nCampo4 - Len ( Alltrim( oJson:GetJsonObject('documento') )) )

            SB7->(dbSetOrder(3)) //B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL
            
            If ! SB7->(dbSeek( cXFilial + xXDoc + cXCod + cXLocal ))
                
               // xFilial("SB7") := oJson:GetJsonObject('filial')

                //MsExecAuto({|x,y,z| MATA270(x,y,z)}, aDados, .T., 3)
                lMsErroAuto := GRAVASB7(aDados)
                                            
                If lMsErroAuto
                    nOK++
                    aAdd( aProdGrv , {"OK", (cXFilial + "|" + xXDoc + "|" + cXCod + "|" + cXLocal) } )   
                else
                    aAdd( aProdGrv , {"ER", (cXFilial + "|" + xXDoc + "|" + cXCod + "|" + cXLocal) } )   
                    nER++
                EndIf  

            Else
                aAdd( aProdGrv , {"DP", (cXFilial + "|" + xXDoc + "|" + cXCod + "|" + cXLocal) } )
                nDP++
            EndIf    
                                 
        Next i       
        
        oResponse['aproc']      := "OK " + cValTochar(nOK) + " DP " + cValTochar(nDP) + " ER " + cValTochar(nER) + " total " + cValTochar(Len(oItens))
        oResponse['data']       := "inicio " + DTOC(dDataIni) + " fim " + DTOC( Date() )
        oResponse['hora']       := "inicio " + cHoraIni + " fim " + Time()
        oResponse['mensagem']   := "rotina concluida com sucesso"
        oResponse['Prod']       := { aProdGrv }

    EndIf
    
    ::SetResponse( oResponse:toJson() )

Return lPost

/*/{Protheus.doc} GRAVASB7
    (long_description)
    @type  Static Function
    @author user
    @since 30/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function GRAVASB7(aDados)

    Local lRet := .T.

    //Inicia gravação tabela SB7

    //Busca Cadastro de produto

    SB1->(DBSelectArea("SB1"))
    SB1->(DBSetOrder(1))

    If SB1->(dbSeek (xFilial("SB1") + aDados[4][2] ))

        RecLock("SB7", .T.)

            SB7->B7_FILIAL  := aDados[1][2]
            SB7->B7_COD     := aDados[4][2]
            SB7->B7_LOCAL   := aDados[2][2]
            SB7->B7_TIPO    := SB1->B1_TIPO
            SB7->B7_DOC     := aDados[3][2]
            SB7->B7_QUANT   := aDados[5][2]
            SB7->B7_QTSEGUM := ConvUm(SB1->B1_COD, aDados[5][2] ,SB7->B7_QTSEGUM,2)
            SB7->B7_DATA    := aDados[7][2]   
            SB7->B7_DTVALID := DATE()    
            SB7->B7_CONTAGE := "001"    
            SB7->B7_ORIGEM  := "GESAPI05"
            SB7->B7_STATUS  := "1"
            
        MsUnLock() 

    EndIf    

Return lRet
