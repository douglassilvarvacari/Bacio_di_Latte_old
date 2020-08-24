#include 'protheus.ch'
#include 'Restful.ch'

WSRESTFUL Gestor_Inventario_Grupos DESCRIPTION "RestFul Gestor Lojas Inventario" FORMAT "application/json"

    WSDATA apiKey AS STRING  //PARAMETRO COM A CHAVE PARA AUTENTICACAO

    WSMETHOD GET DESCRIPTION "Grupos de Produtos" WSSYNTAX "/Gestor_Inventario_Grupos/{}"

END WSRESTFUL

WSMETHOD GET WSSERVICE Gestor_Inventario_Grupos

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

    SX5->(dbSelectArea("SX5"))
    SX5->(dbSetOrder(1))
    SX5->(dbSeek( xFilial("SX5") + "Z3"))

    Do While SX5->(!EOF() .And. SX5->X5_TABELA == "Z3")

        oJsonSX5 := JsonObject():New()
        
        oJsonSX5['Codigo']      := Alltrim(SX5->X5_CHAVE)
        oJsonSX5['Descricao']	:= Alltrim(SX5->X5_DESCRI)

         aAdd(oResponse['dados'], oJsonSX5)	

        SX5->(dbSkip())
    Enddo    
    
    ::SetResponse(oResponse:toJson())

Return lRet := .T.