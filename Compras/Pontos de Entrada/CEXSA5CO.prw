#Include "Totvs.ch"

/*/{Protheus.doc} CEXSA5CO
@description 	Ponto de entrada na conversao produto x fornecedor
@obs			(Utilizado na Central XML - Especifico Bacio)
@author 		Fabrica de Software (Fabritech)
@obs            Para retorno vazio, a conversao nao tentará ser feita
@since 			01/2020
@version		1.0
@return			Array (Tipo de conversao / Fator de conversao)
@type 			Function
/*/
User Function CEXSA5CO()
	Local aParamIXB	:= PARAMIXB
	Local cProdPro	:= aParamIXB[ 01 ]	//Produto Protheus
	Local cFornece	:= aParamIXB[ 02 ]	//Fornecedor
	Local cLoja		:= aParamIXB[ 03 ]	//Loja
    Local cCodNFE	:= aParamIXB[ 04 ]  //Codigo Referencia
    Local cUmNFe    := aParamIXB[ 05 ]  //UM da NF-e
    Local aConver   := Array( 02 )

    Local cUmSA5    := ""
    Local cTipSA5   := ""
    Local nFatSA5   := 0

    Local cTipRet   := ""
    Local nFatRet   := 0
    Local nX        := 0

    DbSelectarea("SA5")
    SA5->( DbSetorder(1) )  //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA
    If SA5->( DbSeek( xFilial("SA5") + cFornece + cLoja + cProdPro ) )
        
        //Verifica Produto x Fornecedor (Faz a conversao ou nao)
        If Alltrim( SA5->A5_XCONVER ) == "2"

            // ---------------------------------------
            // Campos da SA5 que devem ser comparados
            // ---------------------------------------
            // A5_XUM    (1-4)  -  Unidade de Medida
            // A5_XCONV  (1-4)  -  Fator de Conversao
            // A5_XTIPCV (1-4)  -  Tipo de Conversao
            // ---------------------------------------
            
            //Tipo de Conversao padrao, caso nenhum estiver preenchido, esse irá prevalecer
            cTipRet := SA5->A5_XTIPCOV

            //Foram criados 4 campos na SA4 para comparacao
            For nX := 1 To 4
                
                cUmSA5  := &( "SA5->A5_XUM"    + Alltrim( Str( nX ) ) )
                cTipSA5 := &( "SA5->A5_XTIPCV" + Alltrim( Str( nX ) ) )
                nFatSA5 := &( "SA5->A5_XCONV"  + Alltrim( Str( nX ) ) )

                //Compara a Unidade Atual com a Unidade do Produto
                If !Empty( cUmSA5 ) .And. Alltrim( Upper( cUmNFe ) ) == Alltrim( Upper( cUmSA5 ) )

                    //Tipo de Conversao
                    If !Empty( cTipSA5 )
                        cTipRet := cTipSA5
                    EndIf
                    
                    //Fator de Conversao
                    If nFatSA5 > 0
                        nFatRet := nFatSA5
                    EndIf

                EndIf

            Next nX

        EndIf

        //Atribui retorno, caso retore {} nao Programa principal nao ira fazer a conversao
        If !Empty( cTipRet ) .And. nFatRet > 0
            aConver[ 01 ]   := cTipRet
            aConver[ 02 ]   := nFatRet
        Else
            aConver := {}
        EndIf
        
    Else
        aConver := {}
    EndIf

Return aConver
