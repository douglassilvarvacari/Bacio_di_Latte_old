#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SF2460I   �Autor  �Elaine Mazaro       � Data �  23/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada localizado apos a atualizacao das tabelas  ���
���          � referentes a nota fiscal (SF2/SD2), mas antes da           ��� 
���          � contabilizacao.                                            ��� 
�������������������������������������������������������������������������͹��
���Uso       � Bacio                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SF2460I() 
                                     	 
U_BACDM040()

Return(Nil)