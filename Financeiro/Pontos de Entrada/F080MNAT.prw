#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function F080MNAT
    (long_description)
    @type  Function
    @author Douglas Silva
    @since 09/06/2020
    @version 1.0
    @return lReturn
    @example
    Ponto entrada para tratamento de multiplas naturezas títulos baixa via Rotina padrão ou Programa
    @see (links_or_references)
    /*/

User Function F080MNAT()
    
    Local lRet := .F.

    Local aAreaAnt := GETAREA()

        //Verifica se Origem contém Multiplas Naturezas 
        If SE2->E2_MULTNAT == "1"
            lRet := .T.
        EndIf    

    RESTAREA(aAreaAnt)   // Retorna o ambiente anterior

Return lRet