#include 'protheus.ch'
#include 'Restful.ch'

WSRESTFUL Gestor_Inventario_Bloqueios DESCRIPTION "RestFul Gestor Lojas Inventario" FORMAT "application/json"

    WSDATA apiKey AS STRING  //PARAMETRO COM A CHAVE PARA AUTENTICACAO

    WSMETHOD GET DESCRIPTION "Bloqueios Produtos x Armazens" WSSYNTAX "/Gestor_Inventario_Bloqueios/{}"

END WSRESTFUL

WSMETHOD GET WSSERVICE Gestor_Inventario_Bloqueios

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

    ZZ2->(dbSelectArea("ZZ2"))
    ZZ2->(dbSetOrder(1))
    
    Do While ZZ2->(!EOF() )

        oJsonZZ2 := JsonObject():New()
        
        oJsonZZ2['Filial']      := Alltrim(ZZ2->ZZ2_FILIAL)
        oJsonZZ2['Codigo']	    := Alltrim(ZZ2->ZZ2_COD)
        oJsonZZ2['Loja']	    := Alltrim(ZZ2->ZZ2_LOCAL)

         aAdd(oResponse['dados'], oJsonZZ2)	

        ZZ2->(dbSkip())
    Enddo    
    
    ::SetResponse(oResponse:toJson())

Return lRet := .T.