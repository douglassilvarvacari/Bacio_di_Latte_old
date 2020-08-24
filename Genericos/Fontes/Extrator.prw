//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#include "fileio.ch"
  
/*/{Protheus.doc} Extrator
Função tem como objetivo gerar querys e exportar em excel
@author Douglas Silva
@since 03/01/2019
@version 1.0
    @obs Cuidado com colunas com mais de 200 caracteres, pode ser que o Excel dê erro ao abrir o XML
/*/
  
User Function Extrator()

	Local aParamBox := {}
	Local aCombo := {"SD1","SD2","SD2 Sumarizado","SE2","SE2 RAT NAT","SFT","CENTRAL XML","CENTRAL XML CTE","INVENTARIO","INVENTARIO PENDENTE"}
	Private aRet := {}
		
	aAdd(aParamBox,{2,"Tabela",2,aCombo,70,"",.T.})
	aAdd(aParamBox,{1,"Emissão De"  ,Ctod(Space(8)),"","","","",50,.T.})
	aAdd(aParamBox,{1,"Emissão Ate"  ,Ctod(Space(8)),"","","","",50,.T.})
	aAdd(aParamBox,{3,"Tipo Lanc",1,{"Entrada","Saída","Ambos"},50,"",.F.})
	
	
	If ParamBox(aParamBox,"Extrator Dados...",@aRet)
	
		If ( ValType( aRet [1] ) == "N" .And. aRet [1] == 1 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "SD1" )
			xProc1()
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 2 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "SD2" )
			xProc2()	
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 3 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "SD2 Sumarizado" )
			xProc3()		
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 4 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "SE2" )
			xProc4()
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 5 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "SE2 RAT NAT" )
			xProc5()
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 6 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "SFT" )
			xProc6()
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 7 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "CENTRAL XML" )
			xProc7()
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 8 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "CENTRAL XML CTE" )
			xProc8()
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 9 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "INVENTARIO" )
			xProc9()		
		ElseIf ( ValType( aRet [1] ) == "N" .And. aRet [1] == 10 ) .Or.  ( ValType( aRet [1] ) == "C" .And. aRet [1] == "INVENTARIO PENDENTE" )
			xProc10()					
		EndIf
	  
	Endif

Return

Static Function xProc1()

	cQuery := " SELECT "                                 
	cQuery += " D1_FILIAL,D1_DOC,D1_SERIE, D1_COD, B1_DESC, D1_CC,D1_TOTAL,D1_BASEICM,D1_PICM,D1_VALICM,D1_ICMSRET ICMS_Solid, "
	cQuery += " D1_DIFAL ICMS_Difal,D1_TES,D1_CF,D1_DESC, SUBSTRING(D1_EMISSAO,7,2) + '/' + SUBSTRING(D1_EMISSAO ,5,2) + '/' + SUBSTRING(D1_EMISSAO ,1,4) D1_EMISSAO, "                                
	cQuery += " SUBSTRING(D1_DTDIGIT,7,2) + '/' + SUBSTRING(D1_DTDIGIT ,5,2) + '/' + SUBSTRING(D1_DTDIGIT ,1,4) D1_DTDIGIT, D1_BASEICM "                                
	cQuery += " FROM "+RETSQLNAME("SD1")+" D1 "                                 
	cQuery += " JOIN "+RETSQLNAME("SB1")+" B1 ON B1_FILIAL = '' AND D1_COD = B1_COD AND B1.D_E_L_E_T_ = '' "
	cQuery += " WHERE " 
	cQuery += " 	D1.D1_FILIAL != '' "
	cQuery += " 	AND D1.D_E_L_E_T_=''  "
	cQuery += " 	AND D1_DTDIGIT BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' "                                
	cQuery += " ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA "

	//Chamada função para gerar em Excel
	U_QRYCSV(cQuery,"SD1 - Itens NF Entrada")

Return

Static Function xProc2()

	cQuery := " SELECT " 
	cQuery += " D2_FILIAL, D2_DOC, D2_SERIE,D2_ESPECIE, D2_COD, B1_DESC, D2_QUANT ,D2_CCUSTO,D2_PDV,D2_TOTAL,D2_BASEICM,D2_PICM, " 
	cQuery += " D2_VALICM,D2_ICMSRET ICMS_Solid,D2_DIFAL ICMS_Difal, D2_TES, D2_CF, D2_DESC ,SUBSTRING(D2_EMISSAO,7,2) + '/' + SUBSTRING(D2_EMISSAO ,5,2) + '/' + SUBSTRING(D2_EMISSAO ,1,4) D2_EMISSAO , " 
	cQuery += " D2_BASEICM,D2_BASIMP6 BASE_PIS, D2_VALIMP6 VALOR_PIS, F4_CSTPIS CST_PIS, D2_BASIMP5 BASE_COFINS, D2_VALIMP5 VALOR_COFINS, F4_CSTCOF CST_COFINS "
	cQuery += " FROM "+RETSQLNAME("SD2")+" D2 (NOLOCK) "
	cQuery += " JOIN "+RETSQLNAME("SB1")+" B1 ON B1_FILIAL = '' AND D2_COD = B1_COD AND B1.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RETSQLNAME("SF4")+" F4  (NOLOCK)ON F4_FILIAL = '' AND F4_CODIGO = D2_TES AND F4.D_E_L_E_T_ = '' "
	cQuery += " WHERE D2.D2_FILIAL != '' " 
	cQuery += " 	AND D2.D_E_L_E_T_='' " 
	cQuery += " 	AND D2_EMISSAO BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' "
	cQuery += " ORDER BY D2_FILIAL,D2_DOC,D2_SERIE "
	
	U_QRYCSV(cQuery,"SD2 - Itens NF Saida")
	
Return	


Static Function xProc3()

	cQuery := " SELECT D2_FILIAL, D2_COD, B1_DESC, SUM(D2_QUANT) D2_QUANT ,D2_CCUSTO, SUM(D2_TOTAL) D2_TOTAL, " 
	cQuery += " 	SUM(D2_BASEICM) D2_BASEICM, AVG(D2_PICM) D2_PICM, SUM(D2_VALICM) D2_VALICM, SUM(D2_ICMSRET) ICMS_Solid, " 
	cQuery += " 	SUM(D2_DIFAL) ICMS_Difal, D2_TES, D2_CF, SUM(D2_DESC) D2_DESC ,SUBSTRING(D2_EMISSAO,7,2) + '/' + SUBSTRING(D2_EMISSAO ,5,2) + '/' + SUBSTRING(D2_EMISSAO ,1,4) D2_EMISSAO, " 
	cQuery += " 	SUM(D2_BASEICM) D2_BASEICM,SUM(D2_BASIMP6) BASE_PIS, SUM(D2_VALIMP6) VALOR_PIS, F4_CSTPIS CST_PIS, " 
	cQuery += " 	SUM(D2_BASIMP5) BASE_COFINS, SUM(D2_VALIMP5) VALOR_COFINS, F4_CSTCOF CST_COFINS, B1_POSIPI NCM "
	cQuery += " FROM "+RETSQLNAME("SD2")+" D2 (NOLOCK) "
	cQuery += " JOIN "+RETSQLNAME("SB1")+" B1 (NOLOCK) ON B1_FILIAL = '' AND D2_COD = B1_COD AND B1.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RETSQLNAME("SF4")+" F4  (NOLOCK) ON F4_FILIAL = '' AND F4_CODIGO = D2_TES AND F4.D_E_L_E_T_ = '' "
	cQuery += " WHERE D2.D2_FILIAL != '' " 
	cQuery += " 	AND D2.D_E_L_E_T_='' " 
	cQuery += " 	AND D2_EMISSAO BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' "
	cQuery += " GROUP BY D2_FILIAL, D2_COD, B1_DESC, D2_CCUSTO, D2_TES, D2_CF, F4_CSTCOF, SUBSTRING(D2_EMISSAO,7,2) + '\/' + SUBSTRING(D2_EMISSAO ,5,2) + '\/' + SUBSTRING(D2_EMISSAO ,1,4),F4_CSTPIS, B1_POSIPI "
	cQuery += " ORDER BY D2_FILIAL, D2_CCUSTO, D2_EMISSAO, D2_TES "
	
	U_QRYCSV(cQuery,"SD2 - Itens NF Saida - Sumarizado")
	
Return	

Static Function xProc4()

	cQuery := " SELECT ISNULL(F1_ESPECIE,'FIN') F1_ESPECIE,ISNULL(F1_FILIAL,E2_FILORIG)F1_FILIAL ,E2_FILORIG, E2_PREFIXO,E2_NUM,E2_PARCELA, "  + CRLF  
 	cQuery += " E2_TIPO,E2_NATUREZ,E2_FORNECE,E2_LOJA,E2_FATURA,E2_FATPREF,E2_NOMFOR, "  + CRLF  
 	cQuery += " SUBSTRING(E2_EMISSAO,7,2) + '/' + SUBSTRING(E2_EMISSAO ,5,2) + '/' + SUBSTRING(E2_EMISSAO ,1,4) E2_EMISSAO, "  + CRLF  
 	cQuery += " ISNULL(SUBSTRING(F1_DTDIGIT,7,2) + '/' + SUBSTRING(F1_DTDIGIT ,5,2) + '/' + SUBSTRING(F1_DTDIGIT ,1,4),'') F1_DTDIGIT, "  + CRLF 
	cQuery += " ISNULL(SUBSTRING(F1_RECBMTO,7,2) + '/' + SUBSTRING(F1_RECBMTO ,5,2) + '/' + SUBSTRING(F1_RECBMTO ,1,4),'') F1_RECBMTO, "  + CRLF  
 	cQuery += " SUBSTRING(E2_VENCTO,7,2) + '/' + SUBSTRING(E2_VENCTO ,5,2) + '/' + SUBSTRING(E2_VENCTO ,1,4) E2_VENCTO, "  + CRLF  
 	cQuery += " E2_VALOR,ISNULL(F1_VALBRUT,E2_VALOR) F1_VALBRUT, E2_BASEIRF,E2_IRRF,E2_VRETIRF, "  + CRLF  
 	cQuery += " SUBSTRING(E2_BAIXA,7,2) + '/' + SUBSTRING(E2_BAIXA ,5,2) + '/' + SUBSTRING(E2_BAIXA ,1,4) E2_BAIXA, "  + CRLF  
	cQuery += " SUBSTRING(E2_EMIS1,7,2) + '/' + SUBSTRING(E2_EMIS1 ,5,2) + '/' + SUBSTRING(E2_EMIS1 ,1,4) E2_EMIS1, "  + CRLF  
 	cQuery += " E2_INSS,E2_PIS,E2_COFINS,E2_CSLL,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_BASEPIS,E2_VRETISS,E2_BASEISS,E2_VRETINS,E2_BASEINS "  + CRLF  
	cQuery += " FROM "+RETSQLNAME("SE2")+" (nolock) SE2 "  + CRLF  
 	cQuery += " LEFT JOIN "+RETSQLNAME("SF1")+" F1 ON F1_FILIAL != '' AND F1_DOC = E2_NUM AND F1_FORNECE = E2_FORNECE AND F1_LOJA = E2_LOJA AND F1_SERIE = E2_PREFIXO "  + CRLF  
 	cQuery += " WHERE SE2.E2_FILIAL = '' "  + CRLF   
 	cQuery += " AND SE2.D_E_L_E_T_='' "  + CRLF  
 	cQuery += " AND SE2.E2_EMIS1 BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' "  + CRLF 
	cQuery += " ORDER BY F1_FILIAL,E2_NUM "  + CRLF 

	U_QRYCSV(cQuery,"SE2 - Contas a Pagar")
	
Return	

Static Function xProc5()

	cQuery := " SELECT  " 
	cQuery += " 	E2_FILORIG, "
	cQuery += " 	E2_NUM, "
	cQuery += " 	E2_PREFIXO, "
	cQuery += " 	E2_PARCELA,
	cQuery += " 	E2_FORNECE, "
	cQuery += " 	E2_LOJA, "
	cQuery += " 	E2_NOMFOR, "
	cQuery += " 	E2_VALOR, "
	cQuery += " 	SUBSTRING(E2_EMISSAO,7,2) + '/' + SUBSTRING(E2_EMISSAO ,5,2) + '/' + SUBSTRING(E2_EMISSAO ,1,4) E2_EMISSAO, "
	cQuery += " 	SUBSTRING(E2_VENCREA,7,2) + '/' + SUBSTRING(E2_VENCREA ,5,2) + '/' + SUBSTRING(E2_VENCREA ,1,4) E2_VENCREA, "
	cQuery += " 	SUBSTRING(E2_EMIS1,7,2) + '/' + SUBSTRING(E2_EMIS1 ,5,2) + '/' + SUBSTRING(E2_EMIS1 ,1,4) E2_EMIS1, "
	cQuery += " 	CASE WHEN EV_NATUREZ IS NULL THEN E2_NATUREZ ELSE EV_NATUREZ END EV_NATUREZ, "
	cQuery += " 	CASE WHEN ED.ED_DESCRIC IS NULL THEN ED2.ED_DESCRIC ELSE ED.ED_DESCRIC END ED_DESCRIC, "
	cQuery += " 	CASE WHEN EV_VALOR IS NULL THEN E2_VALOR ELSE EV_VALOR END VALOR, "
	cQuery += " 	CASE WHEN EZ_CCUSTO IS NULL THEN E2_CCUSTO ELSE EZ_CCUSTO END EZ_CCUSTO, "
	cQuery += " 	CTT_DESC01 CTT_DESC01, "
	cQuery += " 	EZ_VALOR EZ_VALOR, "
	cQuery += " 	EZ_PERC * 100 EZ_PERC " 
	cQuery += " FROM "+RETSQLNAME("SE2")+" E2 "                            
	cQuery += " LEFT JOIN "+RETSQLNAME("SEV")+" EV ON E2_PREFIXO = EV_PREFIXO AND E2_NUM = EV_NUM AND E2_PARCELA = EV_PARCELA AND E2_FORNECE = EV_CLIFOR AND E2_LOJA = EV_LOJA AND EV_SEQ = '' AND EV_RECPAG = 'P' AND EV.D_E_L_E_T_ = '' "                                                                
	cQuery += " LEFT JOIN "+RETSQLNAME("SED")+" ED ON EV_NATUREZ = ED_CODIGO AND ED.D_E_L_E_T_ = '' "                            
	cQuery += " LEFT JOIN "+RETSQLNAME("SED")+" ED2 ON E2_NATUREZ = ED2.ED_CODIGO AND ED2.D_E_L_E_T_ = '' "                            
	cQuery += " LEFT JOIN "+RETSQLNAME("SEZ")+" EZ ON E2_PREFIXO = EZ_PREFIXO AND E2_NUM = EZ_NUM AND E2_PARCELA = EZ_PARCELA AND E2_FORNECE = EZ_CLIFOR AND E2_LOJA = EV_LOJA AND EV.EV_NATUREZ = EZ_NATUREZ AND EZ_RECPAG = 'P' " 
	cQuery += " AND EZ_SEQ = '' AND EV.D_E_L_E_T_ = '' "                            
	cQuery += " LEFT JOIN CTT010 CTT ON EZ_CCUSTO = CTT_CUSTO AND CTT.D_E_L_E_T_ = '' "
	cQuery += " WHERE E2.D_E_L_E_T_ = '' "                                    
	cQuery += " AND E2_EMIS1 BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' "
	
	U_QRYCSV(cQuery,"SE2 - Contas a Pagar x Natureza")
	
Return	

Static Function xProc6()

	cQuery := " SELECT FT_FILIAL,FT_TIPOMOV, "
	cQuery += " 	SUBSTRING(FT_ENTRADA,7,2) + '/' + SUBSTRING(FT_ENTRADA ,5,2) + '/' + SUBSTRING(FT_ENTRADA ,1,4) FT_ENTRADA, "
	cQuery += " 	SUBSTRING(FT_EMISSAO,7,2) + '/' + SUBSTRING(FT_EMISSAO ,5,2) + '/' + SUBSTRING(FT_EMISSAO ,1,4) FT_EMISSAO, "
	cQuery += " 	FT_ESPECIE,FT_NFISCAL,FT_SERIE, "
	cQuery += " 	FT_CLIEFOR,FT_LOJA,FT_ITEM,FT_PRODUTO,B1_DESC,B1_POSIPI,FT_TES, "
	cQuery += " 	FT_POSIPI,FT_CEST,FT_ESTADO, "
	cQuery += " 	FT_CFOP,FT_VALCONT,FT_CLASFIS,FT_BASEICM,FT_ALIQICM,FT_VALICM,FT_ISENICM, "
	cQuery += " 	FT_OUTRICM,FT_FRETE,FT_DIFAL,FT_ICMSDIF,FT_DESPESA,FT_CTIPI,FT_BASEIPI, "
	cQuery += " 	FT_ALIQIPI,FT_VALIPI,FT_ISENIPI,FT_OUTRIPI,FT_GRPCST,FT_IPIOBS,FT_CREDST, "
	cQuery += " 	FT_CSTPIS,FT_BASEPIS,FT_ALIQPIS,FT_VALPIS,FT_CSTCOF,FT_BASECOF,FT_ALIQCOF, "
	cQuery += " 	FT_VALCOF,FT_CODBCC,FT_CHVNFE,FT_INDNTFR,FT_OBSERV,FT_VALFECP,FT_VFECPST,FT_ICMSRET,FT_ICMSCOM "                                 
	cQuery += " FROM "+RETSQLNAME("SFT")+" FT "                                 
	cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" B1 ON B1_COD = FT_PRODUTO AND B1.D_E_L_E_T_='' "                                 
	cQuery += " WHERE FT.FT_FILIAL != '' "
	cQuery += " AND FT.D_E_L_E_T_='' "                                   
	cQuery += " AND FT_ENTRADA BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' "
	
	If aRet[4] != 3
		cQuery += " AND FT_TIPOMOV = '"+ IIF(aRet[4] == 1, "E", "S") +"' "
	EndIf
		
	cQuery += " AND FT_DTCANC = '' "                                
	cQuery += " ORDER BY FT_FILIAL ,FT_NFISCAL,FT_ITEM "
	
	U_QRYCSV(cQuery,"SFT - Livros Fiscais")
	
Return	

Static Function xProc7()
	Alert("ATENÇÃO: Rotina não está disponível...")
Return

Static Function xProc8()

	cQuery := " SELECT D1_FILIAL FILIAL,F1_ESPECIE ESPECIE,D1_DOC DOCUMENTO,D1_SERIE SERIE, F1_FORNECE COD_FORN,A2_NOME FORNECEDOR, D1_COD CODIGO, " 
	cQuery += " B1_DESC DESCRICAO, D1_CC C_CUSTO,D1_TOTAL TOTAL,D1_VALICM,D1_ICMSRET ICMS_SOLID, D1_DIFAL ICMS_DIFAL,D1_TES TIPO_ENTRADA,D1_CF COD_FISCAL, "
	cQuery += " SUBSTRING(D1_EMISSAO,7,2) + '/' + SUBSTRING(D1_EMISSAO ,5,2) + '/' + SUBSTRING(D1_EMISSAO ,1,4) DT_EMISSAO, "
	cQuery += " SUBSTRING(D1_DTDIGIT,7,2) + '/' + SUBSTRING(D1_DTDIGIT ,5,2) + '/' + SUBSTRING(D1_DTDIGIT ,1,4) DT_DIGITACAO "
	cQuery += " FROM "+RETSQLNAME("SD1")+"  D1 "
	cQuery += " INNER JOIN "+RETSQLNAME("SB1")+"  B1 ON B1_FILIAL = '' AND D1_COD = B1_COD AND B1.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RETSQLNAME("SF1")+"  F1 ON F1_DOC=D1_DOC "
	cQuery += " INNER JOIN "+RETSQLNAME("SA2")+"  A2 ON A2.A2_COD=F1.F1_FORNECE "
	cQuery += " WHERE D1.D1_FILIAL != '' AND D1.D_E_L_E_T_=''  AND D1_EMISSAO BETWEEN '"+Dtos(aRet[2])+"' AND '"+Dtos(aRet[3])+"' AND F1.F1_ESPECIE='CTE' "
	cQuery += " GROUP BY D1_FILIAL,F1_ESPECIE,D1_DOC,D1_SERIE,F1_FORNECE, D1_COD, A2_NOME, B1_DESC, D1_CC,D1_TOTAL,D1_VALICM,D1_ICMSRET, "
	cQuery += " D1_DIFAL,D1_TES,D1_CF, D1_EMISSAO, D1_DTDIGIT  "
	cQuery += " ORDER BY FILIAL, DOCUMENTO, CODIGO, DT_EMISSAO "

	U_QRYCSV(cQuery,"CTE - Entradas CTE")

Return


Static Function xProc9()
	Alert("ATENÇÃO: Rotina não está disponível...")
Return

Static Function xProc10()
	
	cQuery := " WITH INV AS (SELECT DISTINCT B7_FILIAL, B7_LOCAL FROM "+RETSQLNAME("SB7")+" 
	cQuery += " 	WHERE B7_DATA = CONVERT(VARCHAR(8), '20191231', 112) AND D_E_L_E_T_ = '')
	cQuery += " 	SELECT NNR_CODIGO, NNR_DESCRI
	cQuery += " 	FROM NNR010 NNR
	cQuery += " 	LEFT JOIN INV ON NNR_CODIGO = B7_LOCAL AND NNR.D_E_L_E_T_ = ''WHERE B7_LOCAL IS NULL AND NNR_XINV = 'S'
	
	U_QRYCSV(cQuery,"SB7 - Inventário Pendente")

Return