#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SPDR0001  � Autor � ANDREZA DUARTE      � Data �  06/12/13   ���
�������������������������������������������������������������������������͹��
���Descricao �Relat�rio contendo as informa��es do livro fiscal para      ���
���          �auxiliar na confer�ncia do SPED Pis/Cofins                  ���
�������������������������������������������������������������������������͹��
���Uso       �Livros Fiscais 									          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

//INCLUS�O DE NOVOS GRUPOS DE TRIBURA��O - TABELA 21 DA SX5
User Function MntSX521()
       Local aArea := GetArea()
       dbselectarea("SX5")
       dbSetOrder(1)
       Set filter to X5_TABELA = "21"
       AxCadastro("SX5","Grupo Tributario")
       Set Filter to
       RestArea(aArea)
Return

//INCLUIR NO X3_WHEN DOS CAMPOS X5_TABELA E X5_CHAVE
!(FUNNAME()=="MNTSX521")                                    

//INCLUIR NO X3_RELACAO DO CAMPO X5_TABELA
IIF(FUNNAME()=="MNTSX521","21",.T.)

//INCLUIR NO X3_VLDUSER DO CAMPO X5_DESCRI                                    	
IIF(FUNNAME()=="MNTSX521",U_ProxSX521(),.T.)

User Function ProxSX521()
       Local aArea   := GetArea()
       Local cCodigo := ''
       
       cSql := "SELECT MAX(X5_CHAVE) AS CODIGO FROM "+RetSqlName("SX5")
       cSql += " WHERE D_E_L_E_T_<>'*' "
       cSql += " AND X5_TABELA = '21' "
       TcQuery cSql NEW ALIAS "_QRY"
       
       If Empty(_QRY->CODIGO)
         cCodigo := '0000'
       Else                        
         cCodigo := Soma1(Alltrim(_QRY->CODIGO)) 
       Endif           
       _QRY->(dbclosearea())
       
       M->X5_CHAVE := cCodigo
                                                     
       RestArea(aArea)                
Return .T.