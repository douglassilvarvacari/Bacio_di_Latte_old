#Include 'PROTHEUS.CH'

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma ³ MT140LOK     ºAutor³ RVACARI Felipe Mayer	      º Data ³ 28/02/2020	 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.    ³ P.E - Não deixar descer a linha se o Produto for <> de SV e == 'NFSE'	  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso      ³ BACIO DI LATTE                       		                     		 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function  MT140LOK()

Local lRet	:= .T.
Local cCod  := ''
Local nX	:= 0

	For nX := 1 To Len(aCols)
		cCod := aCols[nX,02]
		If Subs(cCod,1,2) <> "SV" .And. Alltrim(cEspecie) == 'NFSE'
			MsgAlert("Espécie do documento inválida para o produto: "+cCod,"Milano - MT140LOK")
			lRet  := .F. 
		Endif
	Next nX	
	
Return lRet