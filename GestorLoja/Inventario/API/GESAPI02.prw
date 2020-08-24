#include 'protheus.ch'
#include 'Restful.ch'

WSRESTFUL Gestor_Inventario_Lojas DESCRIPTION "RestFul Gestor Lojas Inventario" FORMAT "application/json"

    WSDATA apiKey AS STRING  //PARAMETRO COM A CHAVE PARA AUTENTICACAO

    WSMETHOD GET DESCRIPTION "Cadastro Armazens Lojas" WSSYNTAX "/Gestor_Inventario_Lojas/{}"

END WSRESTFUL

WSMETHOD GET WSSERVICE Gestor_Inventario_Lojas

	Local lRet := .T.
	Local oResponse := JsonObject():New()
    Local apiKeyAuth	:= ::apiKey
    Local lLoginOk      := SuperGetMV("MV_XAPIKEY",.F.,"1234") == apiKeyAuth

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

    oResponse['status'] := 251
	oResponse['dados']  := {}
    
    NNR->(DbSetOrder(1))
	NNR->(DbGoTop())
	Do While NNR->(!Eof())
		
        oJsonNNR := JsonObject():New()
            
            If NNR->NNR_CODIGO != '000001'

                //Verifica se Aramzém vai para inventário e está desbloqueado
                oJsonNNR['Filial_loja'] := NNR->NNR_FILIAL
                oJsonNNR['Codigo_Loja']	:= NNR->NNR_CODIGO
                oJsonNNR['Nome_loja']	:= Alltrim(NNR->NNR_DESCRI)
                oJsonNNR['Camara_fria']	:= IIF(NNR->NNR_XACA == "1", "1","2")
                oJsonNNR['Deposito']	:= IIF(NNR->NNR_XADE == "1", "1","2")  
                oJsonNNR['Estoque']	    := IIF(NNR->NNR_XAES == "1", "1","2")
                oJsonNNR['Freezer']	    := IIF(NNR->NNR_XAFR == "1", "1","2")
                oJsonNNR['Loja_Vitrine']:= IIF(NNR->NNR_XALV == "1", "1","2")
                oJsonNNR['Bloqueado']   := IIF(NNR->NNR_MSBLQL == "1", "1","2") 

                aAdd(oResponse['dados'], oJsonNNR)

            EndIf    
        		
		NNR->(DbSkip())
	EndDo
    
	::SetResponse(oResponse:toJson())

Return lRet := .T.