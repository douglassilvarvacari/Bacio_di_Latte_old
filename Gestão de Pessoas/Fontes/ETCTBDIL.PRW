#INCLUDE "rwmake.ch"
#INCLUDE "ETIQCT.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ETCTBDIL ¦ Autor ¦ R.H. - JORGE SATO   ¦ Data ¦ 03/03/2017 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Emissã de Etiqueta de Contrato de Trabalho			      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ SigaGPE                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦						Histórico de Alterações	  						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Data      ¦ Analista            				                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦       				  									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Alteração¦                                                            ¦¦¦
¦¦¦                        				  								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ETCTBDIL()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CBTXT,CSTRING,AORD,CDESC1,CDESC2,CDESC3")
SetPrvt("LEND,ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG")
SetPrvt("AT_PRG,WCABEC0,WCABEC1,WCABEC2,CONTFL,LI")
SetPrvt("NTAMANHO,TITULO,WNREL,CMOSTRA,CDET,NTOT")
SetPrvt("CCAB,CNOME,CFIM,NTAM,NLC,NLN")
SetPrvt("NPULA,AVETOR,NALIN,AINFO,NORDEM,CFILDE")
SetPrvt("CFILATE,CCCDE,CCCATE,CMATDE,CMATATE,CNOMEDE")
SetPrvt("CNOMEATE,CCATEGORIA,DDTDE,DDTATE,CSINDICATO,NCOLUNAS")
SetPrvt("CESPESTAB,NTIPIMP,T,CINICIO,CHAVE,NCOL")
SetPrvt("CFIL,CTIPINSC,CCGC,CTIPPAGTO,CEXT,CTIPO")
SetPrvt("NCONT,C,I,nContEtq")

Private nCol:=0
Private aVetor:={}
Private nTipImp:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbTxt     := ''
cString := "SRA"  // alias do arquivo principal (Base)
aOrd    := {STR0001,STR0002,STR0003}		//"Matricula"###"Centro de Custo"###"Nome"
cDesc1  := STR0004								//"Emiss„o de Etiqueta de Contrato de Trabalho."
cDesc2  := STR0005								//"Ser  impresso de acordo com os parametros solicitados pelo"
cDesc3  := STR0006								//"usuario."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lEnd     := .F.
aReturn  := {STR0007,1,STR0008,2,2,1,"",1 }		//"Zebrado"###"Administra‡„o"
NomeProg := "ETIQCT"
aLinha   := {" "," "," "}
nLastKey := 0
cPerg    := "GPR320    "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AT_PRG   := "ETIQCT"
wCabec0  := 2
wCabec1  := ""
wCabec2  := ""
Contfl   := 1
Li       := 0
nTamanho := "P"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis de Acesso do Usuario                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cAcessaSRA	:= &( " { || " + ChkRH( "ETIQCT" , "SRA" , "2" ) + " } " )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("GPR320",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial De                                ³
//³ mv_par02        //  Filial Ate                               ³
//³ mv_par03        //  Centro de Custo De                       ³
//³ mv_par04        //  Centro de Custo Ate                      ³
//³ mv_par05        //  Matricula De                             ³
//³ mv_par06        //  Matricula Ate                            ³
//³ mv_par07        //  Nome De                                  ³
//³ mv_par08        //  Nome Ate                                 ³
//³ mv_par09        //  Categorias                               ³
//³ mv_par10        //  Periodo De                               ³
//³ mv_par11        //  Periodo Ate                              ³
//³ mv_par12        //  Sindicato (99 Todos)                     ³
//³ mv_par13        //  Numero de Colunas                        ³
//³ mv_par14        //  Esp.Estabelecimento                      ³
//³ mv_par15        //  Tipo Entrada/Saida                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo := STR0009		//"EMISSŽO ETIQUETA DE CONTRATO DE TRABALHO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="ETIQCT"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({||GR530Imp()})
Return Nil

Static function GR530Imp()

lEnd     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMostra := "S"
cDet    := ""
nTot    := ""
cCab    := ""
cNome   := ""
cFim    := ""
nTam    := 0
nLC     := 189
nLN     := 105
nPula   := 1

aVetor:={}  
nAlin :=0
aInfo :={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem     := aReturn[8]
cFilDe     := mv_par01
cFilAte    := mv_par02
cCcDe      := mv_par03
cCcAte     := mv_par04
cMatDe     := mv_par05
cMatAte    := mv_par06
cNomeDe    := mv_par07
cNomeAte   := mv_par08
cCategoria := mv_par09
dDtDe      := mv_par10
dDtAte     := mv_par11
cSindicato := mv_par12
nColunas   := If( mv_par13 > 4 , 4 , mv_par13 )
cEspEstab  := mv_par14
nTipImp    := mv_par15           // Verifica Etiq de Entrada/Saida

For T:=1 TO nColunas
	If nTipImp==1             // Etiq de Entrada
		aAdd(aVetor,{" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "})
	Else
		aAdd(aVetor,{" "," "," "," "," "," "," "})
	Endif
Next

dbSelectArea( "SRA" )
If nOrdem == 1
	dbSetOrder( 1 )
ElseIf nOrdem == 2
	dbSetOrder( 2 )
ElseIf nOrdem == 3
	dbSetOrder(3)
Endif

dbGoTop()

If nOrdem == 1
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim    := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomeAte + cMatAte
Endif

dbSelectArea( "SRA" )
SetRegua(RecCount())

Chave := 0
Li 	  := 3
nCol  := 1
nAlin := 0
cFil  := "  "
nContEtq := 0

@Li,0 PSAY Chr(15)

While !Eof() .And. Chave == 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua Processamento                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncRegua()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica Quebra de Filial                                    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If SRA->RA_FILIAL #cFil
      If !fInfo(@aInfo,Sra->ra_Filial)
         Exit
      Endif
		cFil:=SRA->RA_FILIAL
   Endif

	While !Eof() .And. SRA->RA_FILIAL == cFil 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta Regua Processamento                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncRegua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o De / Ate Solicitado                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOrdem == 1
			If SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 2
			If SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 3
			If SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT > cFilAte + cNomeAte + cMatAte
				Chave := 1
				Exit
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela ImpresÆo ao se pressionar <ALT> + <A>                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
			Chave := 1
			Exit
		EndIF
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametriza‡Æo do Intervalo de ImpressÆo            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Sra->Ra_Nome < cNomeDe) .Or. (Sra->Ra_Nome > cNomeAte) .Or. ;
		   (Sra->Ra_Mat < cMatDe) .Or. (Sra->Ra_Mat > cMatAte) .Or. ;
			(Sra->Ra_CC < cCcDe) .Or. (Sra->Ra_CC > cCCAte)
			dbSkip(1)
			Loop
		EndIf
		
    	/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Consiste Filiais e Acessos                                             ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
			dbSelectArea("SRA")
      		dbSkip()
       		Loop
		EndIF
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Situacao e Categoria do Funcionario                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( SRA->RA_CATFUNC $ cCategoria )
			dbSkip()
			Loop
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Sindicatos - 99 Todos                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cSindicato #"99" .And. SRA->RA_SINDICA # cSindicato
			dbSkip()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se for Tipo Saida - Imprime apenas demitidos        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipImp==2	
			If SRA->RA_SITFOLH#"D" .And. (SRA->RA_DEMISSA < dDtDe .Or. SRA->RA_DEMISSA > dDtAte)
				dbSkip()
				Loop
			Endif
		Else
			If SRA->RA_ADMISSA < dDtDe .Or. SRA->RA_ADMISSA > dDtAte
				dbSkip()
				Loop
			Endif
		Endif

		nAlin:=nAlin+1
		If nTipImp==1
			cTipInsc  := If (aInfo[15] == 1 ,"2","1" )
			cCgc      := If (cTipInsc == "2",aInfo[8],Transform(aInfo[8],"@R ##.###.###/####-##")) // CGC 
					
            cTipPagto := If(SRA->RA_CATFUNC$"M*C*E",STR0010,If(SRA->RA_CATFUNC$"H*G",STR0011,STR0012))	//" POR MES"###" POR HRS"###" POR DIA"

			// - Monta Extenso do Salario			F530MTL()

			nTamanho:=42-Len(STR0013+ALLTRIM(TRANSFORM(SRA->RA_SALARIO,"@E 999,999,999.99"))+" ")	//"Remuneracao R$ "
			cExt := "("+Extenso(SRA->RA_SALARIO,.F.,1)+")"+cTipPagto
			If Len(cExt)<=nTamanho
				aLinha[1]:= cExt
				aLinha[2]:= Space(42)
				aLinha[3]:=	Space(32)
			ElseIf Len(cExt)<=(41+nTamanho)
				aLinha[1]:= Left(cExt,nTamanho)
				aLinha[2]:= SubStr(cExt,nTamanho+1,42)
				aLinha[3]:=	Space(32)
			Else
				aLinha[1]:= Left(cExt,nTamanho)
				aLinha[2]:= SubStr(cExt,nTamanho+1,42)
				aLinha[3]:=	SubStr(cExt,nTamanho+42+1,32)
			Endif

			//
			
			aVetor[nAlin,1]:= SUBSTR(aInfo[3],1,45)
			aVetor[nAlin,2]:= aInfo[4]
			aVetor[nAlin,3]:= AllTrim(aInfo[5]) + " - " + aInfo[6] 
			aVetor[nAlin,4]:= Iif(cPaisLoc =="BRA",STR0014 + cCgc,"")  //"  CGC "
			aVetor[nAlin,5]:= STR0015	//"Esp. Estabelecimento "
			aVetor[nAlin,6]:= cEspEstab
			aVetor[nAlin,7]:= " "
			aVetor[nAlin,8]:= STR0016+ALLTRIM(DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL)) + Iif(cPaisLoc=="BRA",STR0017 +  fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dDataBase),"") 	//"CARGO "###" "
			aVetor[nAlin,9]:= " "
			aVetor[nAlin,10]:= STR0018+SUBSTR(DTOC(SRA->RA_ADMISSA),1,2)+STR0019+MesExtenso(MONTH(SRA->RA_ADMISSA))+STR0019+STR(YEAR(SRA->RA_ADMISSA),4)	//"Data Admissao "###" de "###" de "
			aVetor[nAlin,11]:= STR0020+SRA->RA_MAT 	//"Registro No. "###" "
			aVetor[nAlin,12]:= " "
			aVetor[nAlin,13]:= STR0022+ALLTRIM(TRANSFORM(SRA->RA_SALARIO,"@E 999,999,999.99"))+" "+aLinha[1]	//"Remuneracao R$ "
			aVetor[nAlin,14]:= aLinha[2]
			aVetor[nAlin,15]:= aLinha[3]
			aVetor[nAlin,16]:= " "
			aVetor[nAlin,17]:= " "
			aVetor[nAlin,18]:= "________________________________________"
			aVetor[nAlin,19]:= SUBSTR(aInfo[3],1,45)
			aVetor[nAlin,20]:= " "
			aVetor[nAlin,21]:= " "
			aVetor[nAlin,22]:= " "
			aVetor[nAlin,23]:= " "
		Else
			aVetor[nAlin,1]:= " "
			aVetor[nAlin,2]:= STR0023+SRA->RA_FILIAL+"  "+STR0024+SRA->RA_MAT	//"FIL.: "###"MATRIC: "###
			aVetor[nAlin,3]:= STR0025+SRA->RA_NUMCP+"/"+SRA->RA_SERCP	//"CART.PROF: "
			aVetor[nAlin,4]:= STR0026+SUBSTR(DTOC(SRA->RA_DEMISSA),1,2)+STR0027+MesExtenso(MONTH(SRA->RA_DEMISSA))+STR0027+STR(YEAR(SRA->RA_DEMISSA),4)	//"Data Saida "###" de "###" de "
			aVetor[nAlin,5]:= " "
			aVetor[nAlin,6]:= " "
			aVetor[nAlin,7]:= " "
		Endif
		cTipo:="I"
		FChkET530()

		dbSelectArea( "SRA" )
		dbSkip()

	Enddo

	IF Chave == 1
		Exit
	Endif

	If Eof()
		Exit
	Endif
Enddo
cTipo:="F"
FChkET530()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do Relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SRA" )
Set Filter to
dbSetOrder(1)
Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

*-------------------------------------
Static FuncTion FChkET530()
*-------------------------------------
If (cTipo == "I" .And. nAlin == nColunas) .Or. (cTipo == "F" .And. nAlin > 0)
	nCont:=If(nTipImp==1,23,7) // Verifica Etiq de Entrada/Saida
	For C:= 1 To nCont
		nCol:=0
		For I:= 1 To nColunas       
			 @ Li,nCol PSAY aVetor[I,C]
			 nCol := nCol + 47
			 If nTipImp==2 //Se etiq de saida, soma mais 27 na coluna
			 	nCol += 27
			 EndIf
			 aVetor[I,C]:= " "
		Next
		Li := Li + 1
	Next

	If nTipImp==2 .and. ((nContEtq/2) > int(nContEtq/2)) //Se for etiq.saida e linha impar ou quebra de folha
		Li := Li + 1
    EndIf
	nContEtq ++ //contador horizontal de etiquetas

	nAlin:=0              

Endif

If cTipo == "F" 
	@ Li, 0 PSAY " "
Endif	

If Li > if(nTipImp==1,66,72)
	Li 	  := 3
	@ Li,0 PSAY Chr(15)
Endif	

Return(nil)  
