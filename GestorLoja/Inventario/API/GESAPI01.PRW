#include 'protheus.ch'
#include 'Restful.ch'

WSRESTFUL Gestor_Inventario_Produtos DESCRIPTION "RestFul Gestor Lojas Inventario" FORMAT "application/json"

    WSDATA apiKey AS STRING  //PARAMETRO COM A CHAVE PARA AUTENTICACAO

    WSMETHOD GET DESCRIPTION "Cadastro Armazens Lojas" WSSYNTAX "/Gestor_Inventario_Produtos/{}"

END WSRESTFUL

WSMETHOD GET WSSERVICE Gestor_Inventario_Produtos

    Local lRet := .T.
    Local cGrupo1
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

    SB1->(DbSetOrder(1))
    SB1->(DbGoTop())
    Do While SB1->(!Eof())

        oJsonSB1 := JsonObject():New()

        If SB1->B1_XLISTA == 'S'

            oJsonSB1['Codigo_produto']  := SB1->B1_COD
            oJsonSB1['Descricao_prod']	:= Alltrim(SB1->B1_DESC)
            oJsonSB1['Descricao_inve']	:= Alltrim(SB1->B1_XDESINV)

            oJsonSB1['Unid_camara_fria']:= Alltrim(SB1->B1_XUNCF)
            oJsonSB1['Unid_deposito']   := Alltrim(SB1->B1_XUNDE)
            oJsonSB1['Unid_estoque']    := Alltrim(SB1->B1_XUNES)
            oJsonSB1['Unid_freezer']    := Alltrim(SB1->B1_XUNFR)
            oJsonSB1['Unid_loja_vitrine']:=Alltrim(SB1->B1_XUNLV)

            oJsonSB1['Conv_camara_fria']:= SB1->B1_XFACF
            oJsonSB1['Conv_deposito']   := SB1->B1_XFADE
            oJsonSB1['Conv_estoque']    := SB1->B1_XFAES
            oJsonSB1['Conv_freezer']    := SB1->B1_XFAFR
            oJsonSB1['Conv_loja_vitrine']:=SB1->B1_XFALV

            If SB1->B1_XGPR1 == '1'
                cGrupo1 := '1 Cafes & Doces'
            ElseIf SB1->B1_XGPR1 == '2'
                cGrupo1 := '2 Embalagens'
            ElseIf SB1->B1_XGPR1 == '3'
                cGrupo1 := '3 Gelato'
            ElseIf SB1->B1_XGPR1 == '4'
                cGrupo1 := '4 Insumos'
            Else
                cGrupo1 := '5 Outros'
            EndIf

            oJsonSB1['Grupo1_inventario']:= Alltrim(cGrupo1)

            oJsonSB1['Grupo2_inventario']:= SB1->B1_XINVGRP

            oJsonSB1['Mostra_inventario']:= IIF(SB1->B1_XLISTA == 'S', '1', '2')

        EndIf

        aAdd(oResponse['dados'], oJsonSB1)
        SB1->(DbSkip())
    EndDo

    ::SetResponse(oResponse:toJson())

Return lRet := .T.