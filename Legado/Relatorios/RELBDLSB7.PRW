#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RELBDSB7   �Autor  Andre Sarraipa       � Data �  05/02/18  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function RELBDSB7()
//������������������������������������������Ŀ
//�Declaracao de variaveis                   �
//��������������������������������������������
Private oReport  := Nil
Private oSecCab	 := Nil    
Private cPerg 	 := "RELBDSB7"

//������������������������������������������Ŀ
//�Definicoes/preparacao para impressao      �
//��������������������������������������������
ReportDef()
oReport:PrintDialog()

Return Nil




/*
�������������������������������������������������������������������������͹��
���Desc.     � Defini��o da estrutura do relat�rio.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()

oReport := TReport():New("RELBDSB7","Inventarios Digitados",cPerg,{|oReport| PrintReport(oReport)},"Impress�o inventarios digitados por lojas considerando os tres ultimos meses.")
oReport:SetLandscape(.T.)

oSecCab := TRSection():New( oReport , "Inventarios Digitados", {"QRYTSB7"} )
TRCell():New( oSecCab, "CTT_CUSTO"             , "QRYTSB7","Cod Loja")
TRCell():New( oSecCab, "CTT_DESC01"           , "QRYTSB7","Loja")
TRCell():New( oSecCab, "ANO_MES"       , "QRYTSB7","Mes Ano")
TRCell():New( oSecCab, "QTD_DIG"       , "QRYTSB7","Qtd Prod Dig")
//TRCell():New( oSecCab, "NNS_XNOMSO"     , "QRYTSB7")

DBCloseArea()

Return Nil



Static Function PrintReport(oReport)

Local cQuery     := ""

//Pergunte(cPerg,.F.)

cQuery += "SELECT CTT_CUSTO,CTT_DESC01, "
cQuery += " SUBSTRING(B7_DATA ,5,2) + '/' + SUBSTRING(B7_DATA ,1,4) AS ANO_MES, COUNT(B7_LOCAL) AS QTD_DIG "
cQuery += "FROM " + RetSqlName("CTT") + " CTT "
cQuery += "LEFT JOIN " + RetSqlName("SB7") + " B7 ON B7_LOCAL = CTT_CUSTO AND B7.D_E_L_E_T_='' "
cQuery += "AND B7_DATA BETWEEN replace(CONVERT (date, DATEADD (m, -3, GETDATE () )),'-','')  AND "
cQuery += "replace(CONVERT (date, GETDATE()+10),'-','') "
cQuery += "WHERE CTT.D_E_L_E_T_='' "
cQuery += "AND CTT_CLASSE = '2' "
cQuery += "AND CTT_DESC01 LIKE 'LJ%' "
cQuery += "AND CTT_BLOQ<>'1' "
cQuery += "GROUP BY CTT_CUSTO,CTT_DESC01,SUBSTRING(B7_DATA ,5,2) + '/' + SUBSTRING(B7_DATA ,1,4) "
cQuery += "ORDER BY 1 ,3 " 


If Select("QRYTSB7") > 0
	Dbselectarea("QRYTSB7")
	QRYTSB7->(DbClosearea())
EndIf

TcQuery cQuery New Alias "QRYTSB7"

oSecCab:BeginQuery()
oSecCab:EndQuery({{"QRYTSB7"},cQuery})
oSecCab:Print()

Return Nil
