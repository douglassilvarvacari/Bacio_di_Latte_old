#INCLUDE 'PROTHEUS.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DLV070RG  �Autor  � Reinaldo Dias      � Data �  23/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para calcular o proximo codigo.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RETCOD()
Local aArea   := GetArea()
Local cCodigo := "00000001"

cQuery := " SELECT MAX(SUBSTRING(B1_COD,7,8)) AS MAX_COD FROM "+RETSQLNAME("SB1")
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND D_E_L_E_T_=' '"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySB1",.F.,.T.)
cCodigo := Soma1(QrySB1->MAX_COD,8)
DBCloseArea()

RestArea(aArea)                   

Return(cCodigo)