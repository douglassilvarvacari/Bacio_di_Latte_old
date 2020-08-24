#include "totvs.ch"
#include "topconn.ch"
/* detalhamento de aPIO

*/
//------------------------------------------------------------
// Função fwimppio                        | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Faz a importação de vendas paras as tabelas 
// PIO, preparando para o motor do protheus
//------------------------------------------------------------
user function fwimppip()
Local aFiles := {}

//Local cPath  := "\\172.28.8.245\SSNP9K_pr_TST_data\Outsourcing\Clientes\SSNP9K_TST\Protheus_Data\IMPORT"
Local cExtFiles := "\*PIP.TXT"
Local nX := 0
Local oFile
Private cPath  := "\\172.28.8.117\SSNP9K_pr_PRD_data\Outsourcing\Clientes\SSNP9K_PRD\Protheus_data\IMPORT"
//Private cPath  := "c:\rvacari\bl\vendas\IMPORT"

Public cErrorMessage := ""
 

If IsRunning(FunName())
    //Conout(cErrorMessage)
    Return
EndIf                                    


aFiles := Directory(cPath+cExtFiles, "D")

For nX := 1 to Len(aFiles)
    // Tratamento dos arquivos
    oFile := FWFileReader():New(cPath+"\"+aFiles[nX,1])
    AddPip(oFile)
Next nX

Return(.T.)

//------------------------------------------------------------
// Função AddError                          | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Trata a inclusão de mensagem de erro
//------------------------------------------------------------
Static Function AddError(cErrorText)
If !Empty(cErrorMessage)
    cErrorMessage += CHR(13)+CHR(10)
EndIf    
cErrorMessage := CErrorText+"-|"+Date()+"-"+Time()
Return

//------------------------------------------------------------
// Função IsRunning                         | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Verifica se a rotina está sendo executada
//------------------------------------------------------------
Static Function IsRunning(cFunction)
Local aInfo := GetUserInfoArray()
Local nIndex := 0
Local lRet := .F.

For nIndex := 1 to Len(aInfo)
    If aInfo[nIndex,5] == cFunction
        lRet := .T.
        If !Empty(cErrorMessage)
            cErrorMessage += Chr(10)+Chr(13)
        EndIf    
        AddError("Função já está em execução, será executado no próximo looping do job.")
    EndIf
Next        
Return(lRet)

//------------------------------------------------------------
// Função AddPIP                            | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Inclui registro na tabela PIP
//------------------------------------------------------------
Static Function AddPIP(oFile)
Local aPIP := {}
Local aPINInfo := {}

if (oFile:Open())
   while (oFile:hasLine())
        aPIP := StrTokArr(oFile:GetLine(),"|")
        //If aPIP[2] == "PIP"
            //If ChkCodex(aPIP[1])
                // Gravar a PIN
                // Verifica filial e seta environment
                //cFilImp := RetFil(aPIO[41])

                aPINInfo := GetPINInfo(aPIP[1])

                If Len(aPINInfo) > 0
                    //PREPARE ENVIRONMENT EMPRESA '01' FILIAL cFilImp;
                    dbSelectArea("PIP")
                    RecLock("PIP",.T.)
					PIP->PIP_FILIAL	:= aPINInfo[8,1]
					PIP->PIP_NUM	:= SUBSTR(aPINInfo[9,1],4,6)
					PIP->PIP_DATA	:= STOD(aPIP[3])
					PIP->PIP_VALOR	:= Val(aPIP[4])
					PIP->PIP_FORMA	:= aPIP[5]
					PIP->PIP_ADMINI	:= IIF(aPIP[6]=="\N","",aPIP[6])
					PIP->PIP_HORATE	:= IIF(aPIP[8]=="\N","",aPIP[8]) 
					PIP->PIP_NSUTEF	:= IIF(aPIP[14]=="\N","",aPIP[14])
                    PIP->PIP_NSUHOS	:= IIF(aPIP[14]=="\N","",aPIP[14])
					PIP->PIP_VENDTE	:= IIF(aPIP[15]=="\N","",aPIP[15])
					PIP->PIP_DATEXP	:= Date()
					PIP->PIP_DATIMP	:= Date()
					PIP->PIP_CODORI	:= "2"
					PIP->PIP_CODDES	:= "1"
					PIP->PIP_STAIMP	:= "9"
					PIP->PIP_PROTHE	:= "PIP_FILIAL+PIP_NUM"
					PIP->PIP_ACAO	:= "1"
					PIP->PIP_PDV	:= ALLTRIM(aPINInfo[6,1])
					PIP->PIP_XTPREG	:= "5"	
					PIP->PIP_CHVORI	:= aPINInfo[4,1] 
					PIP->PIP_CNPJOR	:= aPINInfo[3,1]
					PIP->PIP_LJORI	:= RIGHT(aPINInfo[2,1],4)
					PIP->PIP_XCODEX	:= aPIP[1]
					PIP->PIP_CODORI	:= '2'
					PIP->PIP_CODDES := '1'
					PIP->PIP_ACAO 	:= "1"
					PIP->PIP_RECCAB := aPINInfo[7,1]
					PIP->PIP_SITUA  := aPINInfo[5,1] 
					MsUnLock()
                EndIf

            //Else
            //    AddError("Codex já existe, registro não importado.")
            //EndIf
        //Else
        //    AddError("Registro não é da tabela PIP.")    
        //EndIf    
   end
   oFile:Close()
endif


Return()

//------------------------------------------------------------
// Função ChkCodex                          | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Verifica se existe o Codex na PIP
//------------------------------------------------------------
Static Function ChkCodex(cCodex)
Local cQuery := ""
Local lRet := .T.

cQuery := "SELECT * FROM "+RetSQLName("PIN")+" WHERE D_E_L_E_T_='' AND PIN_XCODEX='"+Alltrim(cCodex)+"'"

If Select("IMPPIN")<>0
    IMPPIN->(dbCloseArea())
EndIf    

TCQuery cQuery New Alias "IMPPIN"

If !IMPPIN->(Eof())
    lRet := .T.
EndIf    

Return(lRet)

//------------------------------------------------------------
// Função GetPINInfo                      | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Busca dados na PIP, via xCodex
//------------------------------------------------------------
/*
1 - xCodex  4 - CHVORI   7 - RECCAB
2 - LJORI   5 - SITUA
3 - CNPJOR  6 - PDV
*/
Static Function GetPINInfo(cXCodex)
Local cQueryPIN := ""
Local aRet := {}

cQueryPIN := " SELECT PIN_XCODEX,PIN_LJORI,PIN_CNPJOR,PIN_CHVORI,PIN_SITUA,PIN_PDV,PIN_RECCAB,PIN_FILIAL,PIN_DOC "
cQueryPIN += " FROM "+RetSQLName("PIN")+" WHERE D_E_L_E_T_='' AND PIN_XCODEX='"+Alltrim(cXCodex)+"'"

If Select("INFOPIN")<>0
    INFOPIN->(dbCloseArea())
EndIf    

TCQuery cQueryPIN New Alias "INFOPIN"

If !INFOPIN->(Eof())
    Aadd(aRet,{INFOPIN->PIN_XCODEX})  //1
    Aadd(aRet,{INFOPIN->PIN_LJORI})   //2
    Aadd(aRet,{INFOPIN->PIN_CNPJOR})  //3
    Aadd(aRet,{INFOPIN->PIN_CHVORI})  //4
    Aadd(aRet,{INFOPIN->PIN_SITUA})   //5
    Aadd(aRet,{INFOPIN->PIN_PDV})     //6
    Aadd(aRet,{INFOPIN->PIN_RECCAB})  //7
    Aadd(aRet,{INFOPIN->PIN_FILIAL})  //8
    Aadd(aRet,{INFOPIN->PIN_DOC})     //9
EndIf    

Return(aRet)

//------------------------------------------------------------
// Função RetFil                            | Data: 09.03.2019
// Autor: Eduardo Pessoa
// Descrição: Retorna a Filial da informação importada
//------------------------------------------------------------
Static Function RetFil(cCnpjOri)
Local CCnpj := STRTRAN(cCnpjOri,"/","")
Local aSM0  := FWLoadSM0()
Local nI    := 0
Local cRet  := ""

For nI := 1 to Len(aSM0)
    IIF(aSM0[nI,18]==CCnpj,cRet:=aSM0[nI,2],)
Next nI

If Empty(cRet)
    AddError("Filial não encontrada.")
EndIf

Return(cRet)