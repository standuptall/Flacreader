LOCAL connessione,lSuccess
LOCAL ARRAY aCount[1]
aCount[1] = 0

Thisform.querysave()
IF Thisform.chkfields = .F.
	RETURN .F.
ENDIF

connessione = Search_Conness("OrdineTes")
verifica_righe = Thisform.ControlloRighe()
IF verifica_righe = .F.
	RETURN .F.
ENDIF

** carico i dati di testa e li memorizzo in variabili funzionali alla creazione dello statement SQL
WITH Thisform
	TipOrd = Alltrim(.tipo.Value)
	Cli = Alltrim(.cliente.txtsrc1.Value)
	With .pf.page1.pf.page1
		Ag1  = Iif(Empty(.Agente1.txtsrc1.Value) 	,Null,Alltrim(.Agente1.txtsrc1.Value))
		Pv1  = Iif(Empty(.provv1.Value)				,Null,Alltrim(.provv1.Value))
		Ag2  = Iif(Empty(.Agente2.txtsrc1.Value)	,Null,Alltrim(.Agente2.txtsrc1.Value))
		Pv2  = Iif(Empty(.provv2.Value)				,Null,Alltrim(.provv2.Value))
		Vlt  = Iif(Empty(.Valuta.txtsrc1.Value)		,Null,Alltrim(.Valuta.txtsrc1.Value))
		Pag  = Iif(Empty(.Pagamento.txtsrc1.Value)	,Null,Alltrim(.Pagamento.txtsrc1.Value))
		Sc1  = Iif(Empty(.sconto1.Value)			,Null,Alltrim(.sconto1.Value))
		Sc2  = Iif(Empty(.sconto2.Value)			,Null,Alltrim(.sconto2.Value))
		Sc3  = Iif(Empty(.sconto3.Value)			,Null,Alltrim(.sconto3.Value))
		NsB  = Iif(Empty(.NsBanca.txtsrc1.Value)	,Null,Alltrim(.NsBanca.txtsrc1.Value))
		Car  = Iif(Empty(.Cartellino.txtsrc1.Value)	,Null,Alltrim(.Cartellino.txtsrc1.Value))
		Eti  = Iif(Empty(.Etichetta.txtsrc1.Value)	,Null,Alltrim(.Etichetta.txtsrc1.Value))
		Pri  = Iif(Empty(.Priorita.txtsrc1.Value)	,Null,Alltrim(.Priorita.txtsrc1.Value))
		Ric  = Iif(Empty(.RichConf.txtsrc1.Value)	,Null,Alltrim(.RichConf.txtsrc1.Value))
		Rif  = Iif(Empty(.RifOrdCli.Text.Value)		,Null,Alltrim(.RifOrdCli.Text.Value))
		NCon = Iif(Empty(.NConf.Value)				,Null,Alltrim(.NConf.Value))
		Flsh = Iif(Empty(.Flash.txtsrc1.Value)		,Null,Alltrim(.Flash.txtsrc1.Value))
		Lin  = Iif(Empty(.Linea.txtsrc1.Value)		,Null,Alltrim(.Linea.txtsrc1.Value))
		Colz = Iif(Empty(.Collezione.txtsrc1.Value)	,Null,Alltrim(.Collezione.txtsrc1.Value))
		ScM  = Iif(Empty(.ScontoMerce.Text.Value)	,Null,Alltrim(.ScontoMerce.Text.Value))
		Roy  = Iif(Empty(.Royalty.Text.Value)		,Null,Alltrim(.Royalty.Text.Value))
		CDCo = Iif(Empty(.Cd_DCons.txtsrc1.Value)	,Null,Alltrim(.Cd_DCons.txtsrc1.Value))
		Lis  = Iif(Empty(.Listino.txtsrc1.Value)	,Null,Alltrim(.Listino.txtsrc1.Value))
		TSpe = Iif(Empty(.Cd_AnaSped.txtsrc1.Value)	,Null,"C")
		CSpe = Iif(Empty(.Cd_AnaSped.txtsrc1.Value)	,Null,Alltrim(.Cd_AnaSped.txtsrc1.Value))
		TFat = Iif(Empty(.Cd_AnaFatt.txtsrc1.Value)	,Null,"C")
		CFat = Iif(Empty(.Cd_AnaFatt.txtsrc1.Value)	,Null,Alltrim(.Cd_AnaFatt.txtsrc1.Value))
** Fix: 0194 >
		TSpD = Iif(Empty(.Cd_SpeDoc.txtsrc1.Value)	,Null,"C")
		CSpD = Iif(Empty(.Cd_SpeDoc.txtsrc1.Value)	,Null,Alltrim(.Cd_SpeDoc.txtsrc1.Value))
** Fix: 0194 <
		TLis  = Iif(Empty(.Cd_TipLis.txtsrc1.Value)	,Null,Alltrim(.Cd_TipLis.txtsrc1.Value))
		TDoc  = Iif(Empty(.Cd_TipDoc.txtsrc1.Value)	,Null,Alltrim(.Cd_TipDoc.txtsrc1.Value))
		TDoc2 = Iif(Empty(.Cd_TipDoc2.txtsrc1.Value)	,Null,Alltrim(.Cd_TipDoc2.txtsrc1.Value))
		
		xTDocBF = IIF(EMPTY(.TipoDoc.value)	,NULL,ALLTRIM(.TipoDoc.value)) && Pietro 17/06/2011
		
		Ann  = .Annullato.Value
		Sosp = .Sospeso.Value
		Blc  = .Bloccato.Value
		Rad  = .Radiato.Value
		
		xEsclPromo  = .Promo.Value

		If .AbiBank.Value
			Abi = Iif(Empty(.Abicab.txtsrc1.Value),Null,Alltrim(.Abicab.txtsrc1.Value))
			bnk = Null
		Else
			Abi = Null
			bnk = Iif(Empty(.Bank.Value),Null,Alltrim(.Bank.Value))
		Endif

		Stag = Alltrim(.Stagione.txtsrc1.Value)
		NOrd = .NOrdine.Value

		If Thisform.Status != "M"
			Cod = Alltrim(Thisform.tipo.Value)
			sqlstmt = "SELECT MAX(NOrdine) as maxOrd FROM OrdineTes"
			lSuccess = SQLExec(connessione,sqlstmt,"CodiceCur")
			If !check_query(lSuccess)
				cMessageText = "0000002COD"
				nDialogType = 0 + 64
				nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
				Return .F.
			Endif

			Select CodiceCur
			NOrd = Nvl(CodiceCur.maxOrd,0) + 1
		Endif

		DCo1 = Dtot(.DCons1.Value)
		DCo2 = Dtot(.DCons2.Value)
		DOrd = Dtot(.DOrdine.Value)

		DCon = Dtot(.DataConf.Value)
		If Empty(DCon)
			DCon = Null
		Endif
		DIni = Dtot(.DIniPag.Value)
		If Empty(DIni)
			DIni = Null
		Endif

	Endwith

	With .pf.page1.pf.page2
		vett1x 	  = Iif(Empty(.Vettore1.txtsrc1.Value)		,Null,Alltrim(.Vettore1.txtsrc1.Value))
		vett2x    = Iif(Empty(.Vettore2.txtsrc1.Value)		,Null,Alltrim(.Vettore2.txtsrc1.Value))
		ModSpedx  = Iif(Empty(.ModSpedizione.txtsrc1.Value)	,Null,Alltrim(.ModSpedizione.txtsrc1.Value))
		Portx     = Iif(Empty(.Porto.txtsrc1.Value)			,Null,Alltrim(.Porto.txtsrc1.Value))
		Itinx     = Iif(Empty(.Itinerario.txtsrc1.Value)	,Null,Alltrim(.Itinerario.txtsrc1.Value))
		Zonex     = Iif(Empty(.Zona.txtsrc1.Value)			,Null,Alltrim(.Zona.txtsrc1.Value))
		Settx     = Iif(Empty(.Settore.txtsrc1.Value)		,Null,Alltrim(.Settore.txtsrc1.Value))
		Classx    = Iif(Empty(.Classe.txtsrc1.Value)		,Null,Alltrim(.Classe.txtsrc1.Value))
		Categx    = Iif(Empty(.Categoria.txtsrc1.Value)		,Null,Alltrim(.Categoria.txtsrc1.Value))
		LCre      = Iif(Empty(.LettCred.Value)				,Null,Alltrim(.LettCred.Value))
		Notx      = Iif(Empty(.Note.Value)					,Null,Alltrim(.Note.Value))
		Permi      = .Permin.Text.Value

		Cdcx    = Iif(Empty(.cd_Cdc.txtsrc1.Value)				,Null,Alltrim(.cd_Cdc.txtsrc1.Value))
		Prox    = Iif(Empty(.cd_Project.txtsrc1.Value)				,Null,Alltrim(.cd_Project.txtsrc1.Value))

	Endwith
Endwith

If Empty(TipOrd) Or Empty(Stag) Or Empty(DCo1) Or Empty(DCo2) Or Empty(Cli)
	cMessageText = "0000001REG"
	nDialogType  = 0 + 48
	int_MESSAGEBOX(cMessageText, nDialogType,'','')
	Return .F.
Endif

&& Pietro 17/06/2011 : Tipo doc da ordine
IF thisform.tipodocdaord = .T.
	IF EMPTY(ALLTRIM(NVL(xTDocBF,'')))
		MESSAGEBOX("Tipo Documento non definito.",0+16)
		RETURN .F.
	ENDIF 
ENDIF 
&& Fine Pietro 17/06/2011

utente = Alltrim(oapp.utente)
datax  = Datetime()
Thisform.StatusBar.Panels(1).Text = " Transazioni in corso ... "

** salvataggio su db

connessione = Search_Conness("OrdineTes")
SQLSetprop(connessione,"Transactions",2)

lSuccess = SQLExec(connessione,"SELECT ID FROM OrdineTes WHERE NOrdine=?NOrd",'dati')
If !check_query(lSuccess)
	Sqlrollback(connessione)
	SQLSetprop(connessione,"Transactions",1)
	cMessageText = "0000001TRA"
	nDialogType = 16 + 256
	nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
	Return .F.
Endif

If Reccount('dati') != 0 && *************************** MODIFICA *********************************************************

	If Thisform.Status = "N" Or Thisform.Status = "D" && inconguenza.. stai creando qualcosa che già esiste
		Sqlrollback(connessione)
		SQLSetprop(connessione,"Transactions",1)
		cMessageText = "0000001VAL"
		nDialogType = 16 + 256
		int_MESSAGEBOX(cMessageText, nDialogType,'','')
		Return .F.
	Endif

********************
*** testa Ordine ***
********************

	sqlstmt = "UPDATE OrdineTes "+;
		"SET Tipo = ?Tipord,Cd_Ana =?Cli, Data =?DOrd, NConferma =?NCon, DConferma =?DCon, RifOrdCli =?Rif, TipoAnaSpe=?TSpe, Cd_AnaSped =?CSpe,"+;
		"TipoAnaFat=?TFat, Cd_AnaFatt =?CFat, Cd_Pag =?Pag, Cd_Valuta =?Vlt, Cd_Listino =?Lis, Cd_AbiCab =?Abi, Cd_Agente1 =?Ag1,"+;
		"TipoSpeDoc=?TSpD, Cd_SpeDoc = ?CSpD,"+;			&& Fix: 0194
	"Provv1 =?Pv1, Cd_Agente2 =?Ag2, Provv2 =?Pv2, Cd_Stagion =?Stag, Cd_Linea =?Lin, ScontoMerc =?ScM,"+;
		"Sconto1 =?Sc1, Sconto2 =?Sc2, Sconto3 =?Sc3, DIniPag =?DIni, Royalty =?Roy, Cd_DCons =?CDCo, DCons1 =?DCo1,"+;
		"DCons2 =?DCo2, Cd_Prio =?Pri, Cd_Etich =?Eti, Cd_Cart =?Car, Cd_Rich =?Ric, Cd_Flash =?Flsh, Cd_Colle =?Colz,"+;
		"Ann =?Ann, Sosp =?Sosp, Bloc =?Blc, Rad =?Rad, LettCred =?LCre, Note =?Notx,UtenteUpd =?Utente, DataUpd =?datax, NsBanca =?NsB, Bank =?bnk,"+;
		"cd_vett1 =?vett1x, cd_vett2 =?vett2x, cd_modsped =?ModSpedx,"+;
		"cd_porto =?Portx, cd_itin =?Itinx,cd_zona =?Zonex, cd_settore =?Settx, cd_anacls =?Classx, cd_categ =?Categx, Cd_TipLis =?TLis, cd_tipdoc = ?TDoc,cd_tipdo2 = ?TDoc2,Permin =?Permi, "+;
		" cd_cdc = ?Cdcx, Cd_project = ?Prox, "+;
		" cd_TDocBF = ?xTDocBF, " +; && Pietro 17/06/2011
		" EsclPromo = ?xEsclPromo " +;
		"WHERE NOrdine =?NOrd"

	lSuccess = SQLExec(connessione,sqlstmt)
	If !check_query(lSuccess)
		Sqlrollback(connessione)
		SQLSetprop(connessione,"Transactions",1)
		cMessageText = "0000001TRA"
		nDialogType = 16 + 256
		nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
		Return .F.
	Endif




* Aggiornamento campo Tipo sulle righe
	sqlstmt =	"IF EXISTS(SELECT id FROM OrdineContDett WHERE OrdineContDett.Nordine=?Nord) "+;
		" BEGIN "+;
		" UPDATE OrdineContDett SET Tipo = ?tipord "+;
		" WHERE OrdineContDett.Nordine=?Nord "+;
		" END "+;
		"IF EXISTS(SELECT id FROM OrdineArcC WHERE OrdineArcC.Nordine=?Nord) "+;
		" BEGIN "+;
		" UPDATE OrdineArcC SET Tipo = ?tipord "+;
		" WHERE OrdineArcC.Nordine=?Nord "+;
		" END "+;
		"IF EXISTS(SELECT id FROM OrdineDettC WHERE OrdineDettC.Nordine=?Nord) "+;
		" BEGIN "+;
		" UPDATE OrdineDettC SET Tipo = ?tipord "+;
		" WHERE OrdineDettC.Nordine=?Nord "+;
		" END "+;
		"IF EXISTS(SELECT id FROM OrdineFasce WHERE OrdineFasce.Nordine=?Nord) "+;
		" BEGIN "+;
		" UPDATE OrdineFasce SET Tipo = ?tipord "+;
		" WHERE OrdineFasce.Nordine=?Nord "+;
		" END "+;
		"IF EXISTS(SELECT id FROM OrdineAsso WHERE OrdineAsso.Nordine=?Nord) "+;
		" BEGIN "+;
		" UPDATE OrdineAsso SET Tipo = ?tipord "+;
		" WHERE OrdineAsso.Nordine=?Nord "+;
		" END "+;
		"IF EXISTS(SELECT id FROM OrdineSpese WHERE OrdineSpese.Nordine=?Nord) "+;
		" BEGIN "+;
		" UPDATE OrdineSpese SET Tipo = ?tipord "+;
		" WHERE OrdineSpese.Nordine=?Nord "+;
		" END "

	lSuccess = SQLExec(connessione,sqlstmt)
	If !check_query(lSuccess)
		Sqlrollback(connessione)
		SQLSetprop(connessione,"Transactions",1)
		cMessageText = "0000001TRA"
		nDialogType = 16 + 256
		nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
		Return .F.
	Endif

Else && ******************************************** INSERIMENTO *********************************************************


	If Thisform.Status = "M" && inconguenza.. stai creando qualcosa che avresti dovuto modificare ...
		cMessageText = "0000002VAL"
		nDialogType = 4 + 48 + 256
		nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
		If nAnswer != 6
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Return .F.
		Endif
	Endif

********************
*** testa Ordine ***
********************

	sqlstmt = "INSERT INTO OrdineTes ("+;
		"Tipo,NOrdine,Cd_Ana,Data,NConferma,DConferma,RifOrdCli,TipoAnaSpe,Cd_AnaSped,TipoAnaFat,Cd_AnaFatt,Cd_Pag,Cd_Valuta,Cd_Listino,Cd_AbiCab,"+;
		"Cd_Agente1,Provv1,Cd_Agente2,Provv2,Cd_Stagion,Cd_Linea,ScontoMerc,Sconto1,Sconto2,Sconto3,DIniPag,Royalty,"+;
		"Cd_DCons,DCons1,DCons2,Cd_Prio,Cd_Etich,Cd_Cart,Cd_Rich,Cd_Flash,Cd_Colle,Ann,Sosp,Bloc,Rad,LettCred,Note,"+;
		"UtenteIns,DataIns,UtenteUpd,DataUpd,NsBanca,Bank,cd_tipdoc,cd_tipdo2,cd_vett1,cd_vett2,cd_ModSped,"+;
		"TipoSpeDoc,Cd_SpeDoc,"+;				&& Fix: 0194
		"cd_TDocBF," +; && Pietro 17/06/2011
		"EsclPromo, " +;
	"cd_Porto,cd_Itin,cd_Zona,cd_Settore,cd_anaCls,cd_Categ,Cd_TipLis,Permin,cd_cdc,Cd_project) VALUES ("+;
		"?TipOrd,?NOrd,?Cli,?DOrd,?NCon,?DCon,?Rif,?TSpe,?CSpe,?TFat,?CFat,?Pag,?Vlt,?Lis,?Abi,?Ag1,?Pv1,?Ag2,?Pv2,?Stag,?Lin,?ScM,?Sc1,?Sc2,"+;
		"?Sc3,?DIni,?Roy,?CDCo,?DCo1,?DCo2,?Pri,?Eti,?Car,?Ric,?Flsh,?Colz,?Ann,?Sosp,?Blc,?Rad,?LCre,?Notx,"+;
		"?Utente,?datax,?Utente,?datax,?nsb,?bnk,?TDoc,?TDoc2,?vett1x,?vett2x,?ModSpedx,"+;
		"?TSpD,?CSpD,"+;						&& Fix: 0194
		"?xTDocBF," +; && Pietro 17/06/2011
		"?xEsclPromo, " +;
	"?Portx,?Itinx,?Zonex,?Settx,?Classx,?Categx,?TLis,?permi,?cdcx,?prox) "+;
		" select @@identity as IdNew "		&& Fix: 0381

	lSuccess = SQLExec(connessione,sqlstmt,"IdNewOrdineTes")
	If !check_query(lSuccess)
		Sqlrollback(connessione)
		SQLSetprop(connessione,"Transactions",1)
		cMessageText = "0000001TRA"
		nDialogType = 16 + 256
		nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
		Return .F.
	Endif

***modifica Romeo per note ****
	If (Used('note_cur'))
		connessione = Search_Conness("NoteGenerali")
		utente = Alltrim(oapp.utente)
		datax  = Datetime()

		Select note_cur
		Go Top
		Scan
			Vprefix  = Alltrim(note_cur.prefisso)
			Vcodnote = Alltrim(note_cur.cd_note)
			If (Alltrim(Vprefix)=="Testa OrdiniCliente")
				VKiavex  = Alltrim(Str(NOrd))
			Else
				If (Oldcode==NOrd)
					VKiavex  = Alltrim(note_cur.cd_Key)
				Else
					riga=Strtran(Alltrim(note_cur.cd_Key),Alltrim(Str(Oldcode)),'')
					VKiavex  =Alltrim(Str(NOrd))+Alltrim(riga)
				Endif
			Endif
			Vsequex  = note_cur.sequenza
			Va       = Alltrim(note_cur.descrizion)
			Vb       = note_cur.Conferma
			Vc       = note_cur.lavoraz
			Vd       = note_cur.Spediz
			Ve       = note_cur.Packing
			Vf       = note_cur.Fattura
			Vg       = note_cur.Altro

** Fix: 0381 >
			Select IdNewOrdineTes
			Go Top
			LcIdNOrd = Nvl(IdNewOrdineTes.IdNew,0)

			If !Empty(Va)
				TEXT TO LcSqlNot		TEXTMERGE NOSHOW
					INSERT INTO Notegenerali	(
					Prefisso,cd_note,cd_key,sequenza,descrizion,
					conferma,lavoraz,spediz,packing,fattura,altro,
					IdTabel,NomeTabel,
					UtenteIns,datains,utenteupd,dataupd)
					VALUES						(
					?Vprefix,?Vcodnote,?VKiavex,?VSequex,
					?Va,?Vb,?Vc,?Vd,?Ve,?Vf,?Vg,
					?LcIdNOrd,'OrdineTes',
					'<<ALLTRIM(oapp.Utente)>>',GETDATE(),'<<ALLTRIM(oapp.Utente)>>',GETDATE())
				ENDTEXT
				lSuccess = SQLExec(connessione,LcSqlNot)
				If !check_query(lSuccess)
					Sqlrollback(connessione)
					SQLSetprop(connessione,"Transactions",1)
					cMessageText = "0000001TRA"
					nDialogType = 16 + 256
					nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
					Return .F.
				Endif
			Endif
** Fix: 0381 <

			Select note_cur
		Endscan
	Endif
***fine Modifica Romeo per note
		*
		*Paolo SMI
		SET STEP ON
		IF b = 0			
			TEXT TO sqlstmt NOSHOW TEXTMERGE
				DELETE FROM OrdineOpzSMI WHERE Nordine = <<Nord>> AND Nriga = <<a>>
			ENDTEXT
			lSuccess = SQLExec(connessione,sqlstmt)
			If !check_query(lSuccess)
				Sqlrollback(connessione)
				SQLSetprop(connessione,"Transactions",1)
				Set Deleted On
				Return .F.
			ENDIF
			LOCAL lnSeq,lnTotVariadb,lcWhereVariadb,lnNewCode,lcValuaOpz,lnPrezzoOpz
			STORE 0 TO lnSeq,lnTotVariadb
			lcWhereVariadb = ''
			SELECT Opzioni_cur		
			SCAN FOR NRiga = a
				lnSeq = lnSeq + 1
				lcValuaOpz = ''
				lnPrezzoOpz = 0.00
				SELECT OpzPrz_cur
				LOCATE FOR OpzPrz_cur.Cd_Opzione = Opzioni_cur.Cd_Opzione AND OpzPrz_cur.Cd_Valuta = ALLTRIM(thisform.pf.page1.pf.page1.Valuta.Txtsrc1.Value)
				IF FOUND()
					lnPrezzoOpz = OpzPrz_cur.Prezzo
					lcValuaOpz = OpzPrz_cur.Cd_Valuta
				ENDIF
				TEXT TO sqlstmt NOSHOW TEXTMERGE
					INSERT INTO OrdineOpzSMI (Nordine, NRiga, Frazio, Sequenza, Cd_Parti, Cd_Opzione, 
									ConsPlus, ConsLess, Valore, Cd_Valuta, Prezzo)
									Values(<<Nord>>,<<a>>,0,<<lnSeq>>,NULLIF('<<Opzioni_cur.Cd_Parti>>',''),NULLIF('<<Opzioni_cur.Cd_Opzione>>',''),
									NULLIF(<<STRTRAN(ALLTRIM(STR(Opzioni_cur.ConsPlus,6,2)),',','.')>>,0),NULLIF(<<STRTRAN(ALLTRIM(STR(Opzioni_cur.ConsLess,6,2)),',','.')>>,0),NULLIF('<<Opzioni_cur.Valore>>',''),
									NULLIF('<<lcValuaOpz>>',''),NULLIF(<<STRTRAN(ALLTRIM(STR(lnPrezzoOpz,6,2)),',','.')>>,0))
				ENDTEXT
				lSuccess = SQLExec(connessione,sqlstmt)
				If !check_query(lSuccess)
					Sqlrollback(connessione)
					SQLSetprop(connessione,"Transactions",1)
					Set Deleted On
					Return .F.
				ENDIF
				IF !EMPTY(Opzioni_cur.Cd_VariaDb)
					lnTotVariadb = lnTotVariadb + 1
					lcWhereVariadb = lcWhereVariadb + "'"+ALLTRIM(Opzioni_cur.Cd_VariaDb)+"',"
				ENDIF
			ENDSCAN
			**TODO 
			*1)GENERAZIONE DELLA VARIANTE CAPO DA EVENTUALI VARIANZIONI PREVISTE NELLE OPZIONI
			SET STEP ON
			IF lnTotVariadb > 0
				*Controllo esistenza variante capo con combinazioni cd_variadb assegnate
				lcWhereVariadb = LEFT(ALLTRIM(lcWhereVariadb),LEN(lcWhereVariadb)-1)
				TEXT TO sqlstmt NOSHOW TEXTMERGE
					select Varianti.cd_Varia 
					from Varianti
					inner join (
					select Cd_Varia,COUNT(Cd_Varia) as Tot from RigheVarianti  group by Cd_Varia) TotRegole on Totregole.Cd_Varia = Varianti.Cd_varia and Tot = <<lnTotVariadb>>
					inner join (
					select Cd_Varia,COUNT(Cd_Varia) as Tot from RigheVarianti where Cd_variadb in(<<lcWhereVariadb>>) group by Cd_Varia) Regole on Regole.Cd_Varia = Totregole.Cd_varia and TotRegole.Tot = Regole.Tot
				ENDTEXT
				lSuccess = SQLExec(connessione,sqlstmt,'VariaDb_cur')
				If !check_query(lSuccess)
					Sqlrollback(connessione)
					SQLSetprop(connessione,"Transactions",1)
					Set Deleted On
					Return .F.
				ENDIF
				IF RECCOUNT('VariaDb_cur') > 0
					replace Cd_Varia WITH VariaDb_cur.Cd_Varia FOR cDettC.NRiga == cDettGen.NRiga IN cDettC
				ELSE
					*Generazione Variante capo
					TEXT TO sqlstmt NOSHOW TEXTMERGE
						SELECT CAST(MAX(RIGHT(CD_VARIA,LEN(CD_VARIA)-1)) AS INT)As LastNum  
						FROM Varianti 
						WHERE Cd_varia LIKE 'S%' AND isnumeric(RIGHT(CD_VARIA,LEN(CD_VARIA)-1))=1 
					ENDTEXT
					lSuccess = SQLExec(connessione,sqlstmt)
					If !check_query(lSuccess)
						Sqlrollback(connessione)
						SQLSetprop(connessione,"Transactions",1)
						Set Deleted On
						Return .F.
					ENDIF
					IF RECCOUNT('SQLRESULT')>0
						lnNewCode = NVL(SQLRESULT.LastNum,0) + 1
					ELSE
						lnNewCode = 1
					ENDIF
					TEXT TO sqlstmt NOSHOW TEXTMERGE
						INSERT INTO Varianti ( Cd_varia, Descrizion, UtenteIns, DataIns, UtenteUpd, DataUpd)
									VALUES('S'+RIGHT('00000'+'<<lnNewCode>>',5),'Variante Su Misura','<<ALLTRIM(oapp.Utente)>>',GETDATE(),'<<ALLTRIM(oapp.Utente)>>',GETDATE())						
					ENDTEXT
					lSuccess = SQLExec(connessione,sqlstmt)
					If !check_query(lSuccess)
						Sqlrollback(connessione)
						SQLSetprop(connessione,"Transactions",1)
						Set Deleted On
						Return .F.
					ENDIF
					*Inserimento righe variadb	
					lnSeq = 0
					SELECT Opzioni_cur
					GO top							
					SCAN FOR Opzioni_cur.NRiga = a AND !EMPTY(Opzioni_cur.Cd_VariaDb)
						lnSeq = lnSeq + 1
						TEXT TO sqlstmt NOSHOW TEXTMERGE
							INSERT INTO RigheVarianti (Cd_Varia,Cd_Variadb,Descrizion,Sequenza,UtenteIns, DataIns, UtenteUpd, DataUpd)
											VALUES('S'+RIGHT('00000'+'<<lnNewCode>>',5),'<<Opzioni_cur.Cd_VariaDb>>','.',<<lnSeq>>,'<<ALLTRIM(oapp.Utente)>>',GETDATE(),'<<ALLTRIM(oapp.Utente)>>',GETDATE())
						ENDTEXT
						lSuccess = SQLExec(connessione,sqlstmt)
						If !check_query(lSuccess)
							Sqlrollback(connessione)
							SQLSetprop(connessione,"Transactions",1)
							Set Deleted On
							Return .F.
						ENDIF						
					ENDSCAN
					replace Cd_Varia WITH 'S'+RIGHT('00000'+ALLTRIM(STR(lnNewCode)),5) FOR cDettC.NRiga == cDettGen.NRiga IN cDettC						
				ENDIF			
			ENDIF
*!*				
*!*				*2)FAR SCATTARE LA GENERAZIONE AUTOMATICA DELLA DIBA+
*!*				&& SMI-->
*!*				db_a  = ALLTRIM(cDettC.cd_stagion)
*!*				db_b  = IIF (EMPTY(cDettC.cd_flash),null,ALLTRIM(cDettC.cd_flash))
*!*				db_c  = IIF (EMPTY(cDettC.cd_linea),null,ALLTRIM(cDettC.cd_linea))
*!*				db_d  = IIF (EMPTY(cDettC.cd_colle),null,ALLTRIM(cDettC.cd_colle))
*!*				db_e1 = 'C' && tipoana
*!*				db_e  = ALLTRIM(cDettC.cd_ana)
*!*				db_f  = ALLTRIM(cDettC.cd_modello)
*!*				db_g  = ALLTRIM(cDettC.cd_varmod)
*!*				db_h  = ALLTRIM(cDettC.cd_artico)
*!*				db_i  = ALLTRIM(cDettC.cd_varart)
*!*				IF EMPTY(db_h)
*!*					db_h  = null
*!*					db_i  = null
*!*				ENDIF  
*!*				db_l  = ALLTRIM(cDettC.cd_cartell)
*!*				db_m  = 'ALL'
*!*				db_n  = IIF (EMPTY(cDettC.cd_varia),  null,ALLTRIM(cDettC.cd_varia))
*!*				db_o  = IIF (EMPTY(cDettC.cd_lavagg), null,ALLTRIM(cDettC.cd_lavagg))
*!*				db_p  = IIF (EMPTY(cDettC.cd_drop),   null,ALLTRIM(cDettC.cd_drop))
*!*				db_q  = IIF (EMPTY(cDettC.cd_statura),null,ALLTRIM(cDettC.cd_statura))
*!*				colr = ALLTRIM(NVL(cDettC.cd_Colore,''))

*!*				IF !EMPTY(ALLTRIM(NVL(db_n,'')))
*!*					id_distGenerale=CreaDistinteSMI_Generale(connessione,this,db_a,db_b,db_c,;
*!*					db_d,'C',db_e,db_f,db_g,db_h,db_i,db_l,'ALL',db_n,db_o,db_p,db_q,colr,0,0,.T.)
*!*					
*!*				&& SMI--<
*!*				*3)CREARE LA DIBA PERSONALIZZATA PARTENDO DALLA DIBA GENERATA
*!*					&& SMI-->
*!*					IF id_distGenerale>0
*!*						id_distOrdine=CreaDistinteSMI_Ordine(connessione,this,NOrd,a,id_distGenerale,db_a,db_b,db_c,;
*!*								db_d,'C',db_e,db_f,db_g,db_h,db_i,db_l,'ALL',db_n,db_o,db_p,db_q,colr,0,0,.T.)
*!*					ENDIF 
*!*				&& SMI--<
*!*				ENDIF
		ENDIF
		*	
Endif


************** Spese *****************
Set Deleted Off
Select TipoDocSpese_Cur
Scan

	h3 = TipoDocSpese_Cur.sequenza
	h4 = TipoDocSpese_Cur.tipospesa
	h5 = TipoDocSpese_Cur.Importo
	h6 = Iif(Empty(TipoDocSpese_Cur.percento),Null,Alltrim(TipoDocSpese_Cur.percento))
	h7 = Iif(Empty(TipoDocSpese_Cur.cd_iva),Null,Alltrim(TipoDocSpese_Cur.cd_iva))
	h8 = Iif(Empty(TipoDocSpese_Cur.cd_conto),Null,Alltrim(TipoDocSpese_Cur.cd_conto))

	Do Case
	Case  Empty(TipoDocSpese_Cur.tipospesa) Or (TipoDocSpese_Cur.Importo = 0 And Empty(TipoDocSpese_Cur.percento) And Empty(TipoDocSpese_Cur.cd_iva))
		sqlstmt = "DELETE FROM OrdineSpese "+;
			"WHERE Nordine =?Nord AND Sequenza = ?h3"
	Otherwise

		sqlstmt = "IF not exists(SELECT id FROM OrdineSpese WHERE Nordine=?Nord AND Sequenza=?h3) "+;
			"BEGIN "+;
			"INSERT INTO OrdineSpese "+;
			"(Tipo,Nordine,sequenza,tipospesa,importo,percento,cd_iva,cd_conto,UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
			"VALUES (?TipOrd,?Nord,?h3,?h4,?h5,?h6,?h7,?h8,?utente,?datax,?utente,?datax) "+;
			"END "+;
			"ELSE "+;
			"BEGIN "+;
			"UPDATE OrdineSpese "+;
			"SET Tipo=?TipOrd,tipospesa=?h4,Importo=?h5,percento=?h6,cd_iva=?h7,cd_conto=?h8,"+;
			"UtenteUpd=?Utente,DataUpd=?datax "+;
			"WHERE Nordine=?Nord AND Sequenza=?h3 "+;
			"END"

	Endcase
	If !Empty(sqlstmt)
		lSuccess = SQLExec(connessione,sqlstmt)
		If !check_query(lSuccess)
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Return .F.
		Endif
	Endif
Endscan



************** Acconti *****************
Set Deleted Off
Select Acconto_Cur
Scan

	h3 = Acconto_Cur.sequenza
	h4 = Iif(Empty(Acconto_Cur.Esercizio),Null,Acconto_Cur.Esercizio)
	h5 = Acconto_Cur.Importo
	h6 = Iif(Empty(Acconto_Cur.datadoc),Null,Dtot(Acconto_Cur.datadoc))
	h7 = Iif(Empty(Acconto_Cur.cd_iva),Null,Alltrim(Acconto_Cur.cd_iva))
	h8 = Iif(Empty(Acconto_Cur.cd_conto),Null,Alltrim(Acconto_Cur.cd_conto))
	h9 = Iif(Empty(Acconto_Cur.Cd_TipDoc),Null,Alltrim(Acconto_Cur.Cd_TipDoc))
	h10 = Iif(Empty(Acconto_Cur.NumDoc),0,Acconto_Cur.NumDoc)

	Do Case
	Case  Acconto_Cur.Importo = 0
		sqlstmt = "DELETE FROM OrdineAcconto "+;
			"WHERE Nordine =?Nord AND Sequenza = ?h3"
	Otherwise

		sqlstmt = "IF not exists(SELECT id FROM OrdineAcconto WHERE Nordine=?Nord AND Sequenza=?h3) "+;
			"BEGIN "+;
			"INSERT INTO OrdineAcconto "+;
			"(Nordine,sequenza,Esercizio,importo,datadoc,cd_iva,cd_conto,cd_tipdoc,numdoc,UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
			"VALUES (?Nord,?h3,?h4,?h5,?h6,?h7,?h8,?h9,?h10,?utente,?datax,?utente,?datax) "+;
			"END "+;
			"ELSE "+;
			"BEGIN "+;
			"UPDATE OrdineAcconto "+;
			"SET Esercizio=?h4,Importo=?h5,datadoc=?h6,cd_iva=?h7,cd_conto=?h8,cd_tipdoc=?h9,numdoc=?h10,"+;
			"UtenteUpd=?Utente,DataUpd=?datax "+;
			"WHERE Nordine=?Nord AND Sequenza=?h3 "+;
			"END"


	Endcase
	If !Empty(sqlstmt)
		lSuccess = SQLExec(connessione,sqlstmt)
		If !check_query(lSuccess)
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Return .F.
		Endif
	Endif
Endscan


************** Assortimenti *****************
Local Array ass[30]
For cik =1 To 30
	ass[cik] = 0
Next

Set Deleted Off
Select OrdineAsso_Cur
Scan For !Empty(OrdineAsso_Cur.descrizion)

	h3 = Alltrim(OrdineAsso_Cur.cd_assort)
	h4 = Alltrim(OrdineAsso_Cur.descrizion)
	h5 = Alltrim(OrdineAsso_Cur.cd_taglia)
	For cik =1 To 30
		campo = "OrdineAsso_Cur.tg"+Alltrim(Str(cik))
		ass[cik] = Evaluate(campo)
	Next

	sqlstmt = "IF not exists(SELECT id FROM OrdineAsso WHERE Nordine=?Nord AND cd_assort = ?h3) "+;
		"BEGIN "+;
		"INSERT INTO OrdineAsso "+;
		"(Tipo,Nordine,Cd_Assort,Descrizion,Cd_Taglia,tg1,tg2,tg3,tg4,tg5,tg6,tg7,tg8,tg9,tg10,tg11,tg12,tg13,tg14,tg15,tg16,tg17,tg18,tg19,tg20,"+;
		"tg21,tg22,tg23,tg24,tg25,tg26,tg27,tg28,tg29,tg30,UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
		"VALUES (?TipOrd,?Nord,?h3,?h4,?h5,?ass[1],?ass[2],?ass[3],?ass[4],?ass[5],?ass[6],?ass[7],?ass[8],?ass[9],?ass[10],"+ ;
		"?ass[11],?ass[12],?ass[13],?ass[14],?ass[15],?ass[16],?ass[17],?ass[18],?ass[19],?ass[20],"+;
		"?ass[21],?ass[22],?ass[23],?ass[24],?ass[25],?ass[26],?ass[27],?ass[28],?ass[29],?ass[30],"+;
		"?utente,?datax,?utente,?datax) "+;
		"END "+;
		"ELSE "+;
		"BEGIN "+;
		"UPDATE OrdineAsso "+;
		"SET Tipo=?TipOrd,descrizion=?h4,cd_taglia=?h5,tg1=?ass[1],tg2=?ass[2],tg3=?ass[3],tg4=?ass[4],tg5=?ass[5],tg6=?ass[6],tg7=?ass[7],tg8=?ass[8],tg9=?ass[9],tg10=?ass[10],"+;
		"tg11=?ass[11],tg12=?ass[12],tg13=?ass[13],tg14=?ass[14],tg15=?ass[15],tg16=?ass[16],tg17=?ass[17],tg18=?ass[18],tg19=?ass[19],tg20=?ass[20],"+;
		"tg21=?ass[21],tg22=?ass[22],tg23=?ass[23],tg24=?ass[24],tg25=?ass[25],tg26=?ass[26],tg27=?ass[27],tg28=?ass[28],tg29=?ass[29],tg30=?ass[30],"+;
		"UtenteUpd=?Utente,DataUpd=?datax "+;
		"WHERE Nordine=?Nord AND cd_assort = ?h3 "+;
		"END"

	If !Empty(sqlstmt)
		lSuccess = SQLExec(connessione,sqlstmt)
		If !check_query(lSuccess)
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Return .F.
		Endif
	Endif
Endscan



********************
aCount[1] = 0
Select Count(*) From cDettGen Where Mtest = 'M' Into Array aCount
If aCount[1] = 0
	aCount[1] = 1
Endif
**********************
** Dettaglio Ordine **
**********************
Select cDettGen
Thisform.oprogressBar.Max = aCount[1]
Thisform.oprogressBar.Value = 1

Thisform.oprogressBar.Top     = Thisform.Height - Thisform.oprogressBar.Height - 2
Thisform.oprogressBar.Left = 2
Thisform.oprogressBar.Visible = .T.
Thisform.oprogressBar.Width = Thisform.StatusBar.Panels(1).Width - 4

*** Dettaglio Ordine ---> Generico   Pulizia dati da cursore e cancellazione righe da tabella
Set Deleted Off


Select cDettGen
Go Top
Scan

	If cDettGen.Mtest = 'D'  && cancellazione
		a = cDettGen.NRiga
		b = cDettGen.Frazio
		c = cDettGen.TipoRiga
		sqlstmt = " Delete from OrdineContDett where OrdineContDett.Nordine = ?NOrd and NRiga = ?a and OrdineContDett.Frazio = ?b AND OrdineContDett.TipoRiga = ?c"
		lSuccess = SQLExec(connessione,sqlstmt)
		If !check_query(lSuccess)
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Set Deleted On
			Return .F.
		Endif
		Loop
	Endif
Endscan
Set Deleted On
tBar = 0
*** Dettaglio Ordine ---> Generico

Select cDettGen
Go Top
Scan
	If cDettGen.Mtest = 'M' && immissione e modifica

		tBar = tBar + 1
		Thisform.oprogressBar.Value = tBar


		a = cDettGen.NRiga
		b = cDettGen.Frazio
		c = cDettGen.TipoRiga

		g = Dtot(cDettGen.DCons1)
		h = Dtot(cDettGen.DCons2)

		f1 = cDettGen.omaggioM
		f2 = cDettGen.omaggioI
		f2x = cDettGen.omaggioIva
		f3 = cDettGen.inLav
		f4 = cDettGen.imp

*!* PTF_PRENOTATO 2008-03-19 rnd >>

		f4b	= cDettGen.Pre
		f4c = cDettGen.PreGreggio		&& Fix: 0279

*!* PTF_PRENOTATO 2008-03-19 rnd <<

		f5 = cDettGen.Ann
		f6 = cDettGen.Sosp
		f7 = cDettGen.Bloc
		f8 = cDettGen.Rad
		f9 = cDettGen.notint
		f10 = cDettGen.notcli
		f11 = cDettGen.notage
		f12 = Iif(Empty(cDettGen.noteAnn),Null,Alltrim(cDettGen.noteAnn))
		f13 = Iif(Empty(cDettGen.cd_cauann),Null,Alltrim(cDettGen.cd_cauann))
		f14 = Iif(Empty(cDettGen.cd_ctosca),Null,Alltrim(cDettGen.cd_ctosca))
		f15x = cDettGen.DecPSCM
		f16x = cDettGen.DecPSC1
		f17x = cDettGen.DecPSC2
		f18x = cDettGen.DecPSC3
		f19x = cDettGen.DecPSCR
		f20x = cDettGen.DecPOma
		f21x = cDettGen.DecPSCP
		f21y = cDettGen.ApplicaSC
		
		f22x = cDettGen.Minsped
		f23x = cDettGen.PerMinspe
		f24x = cDettGen.Mintgda
		f25x = cDettGen.Mintga
		
		xRifROCli = IIF(EMPTY(cDettGen.RifROCli),Null,ALLTRIM(cDettGen.RifROCli))
		
		** Fix: 1055 >
		IF Thisform.Status = "M"
			i1 = IIF(EMPTY(cDettGen.Cd_AnaSped)	,Null,ALLTRIM(cDettGen.Cd_AnaSped))
			i1x = IIF(EMPTY(cDettGen.Cd_AnaSped),Cli,ALLTRIM(cDettGen.Cd_AnaSped))
			i2 = IIF(EMPTY(cDettGen.Cd_AnaSped)	,Null,"C")
		ELSE
			i1 = IIF(EMPTY(ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaSped.Txtsrc1.Value)),Null,ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaSped.Txtsrc1.Value))
			i1x = IIF(EMPTY(ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaSped.Txtsrc1.Value)),Cli,ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaSped.Txtsrc1.Value))
			i2 = IIF(EMPTY(ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaSped.Txtsrc1.Value)),Null,"C")
		ENDIF
		
		IF Thisform.Status = "M"
			i3 = IIF(EMPTY(cDettGen.Cd_AnaFatt),Null,ALLTRIM(cDettGen.Cd_AnaFatt))
			i4 = IIF(EMPTY(cDettGen.Cd_AnaFatt),Null,"C")
		ELSE
			i3 = IIF(EMPTY(ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaFatt.Txtsrc1.Value)),Null,ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaFatt.Txtsrc1.Value))
			i4 = IIF(EMPTY(ALLTRIM(Thisform.PF.Page1.PF.Page1.Cd_AnaFatt.Txtsrc1.Value)),Null,"C")
		ENDIF
		** Fix: 1055 <
		
		i5 = Iif(Empty(cDettGen.cd_Prio)	,Null,Alltrim(cDettGen.cd_Prio))
		i6 = Iif(Empty(cDettGen.cd_asso)	,Null,Alltrim(cDettGen.cd_asso))
		i7 = cDettGen.NumAsso
		i8 = Iif(Empty(cDettGen.Note)		,Null,Alltrim(cDettGen.Note))
		i9 = Iif(cDettGen.cd_lotto= 0   	,Null,cDettGen.cd_lotto)

		i10 = Iif(Empty(cDettGen.cd_KIT)    ,Null,Alltrim(cDettGen.cd_KIT))
		i11 = Iif(cDettGen.PrezzoKit= 0   	,0,cDettGen.PrezzoKit)
		i12 = Iif(cDettGen.QtaKit= 0   	    ,0,cDettGen.QtaKit)
		i13 = Iif(Empty(cDettGen.Cd_Ivaord) ,Null,Alltrim(cDettGen.Cd_Ivaord))

		l1 = Iif(Empty(cDettGen.Cd_Agente1)	,Null,Alltrim(cDettGen.Cd_Agente1))
		l2 = Iif(Empty(cDettGen.provv1)		,Null,Alltrim(cDettGen.provv1))
		l3 = Iif(Empty(cDettGen.Cd_Agente2)	,Null,Alltrim(cDettGen.Cd_Agente2))
		l4 = Iif(Empty(cDettGen.provv2)		,Null,Alltrim(cDettGen.provv2))
		l5 = Iif(Empty(cDettGen.sconto)		,Null,Alltrim(cDettGen.sconto))
		l6 = Iif(Empty(cDettGen.Royalty)	,Null,Alltrim(cDettGen.Royalty))
		
		lcScoPromo = NVL(cDettGen.ScoPromo,.F.)
		
		** Salvataggio OrdineContDett
		sqlstmt = "IF not exists(SELECT id FROM OrdineContDett WHERE OrdineContDett.Nordine=?Nord AND OrdineContDett.NRiga = ?a AND OrdineContDett.Frazio = ?b and OrdineContDett.TipoRiga = ?c) "+;
			"BEGIN "+;
			"INSERT INTO OrdineContDett (NOrdine,NRiga,Frazio,Tipo,TipoRiga,"+;
			"DCons1,DCons2,Cd_Agente1,Provv1,Cd_Agente2,Provv2,Sconto,Royalty,"+;
			"OmaggioM,OmaggioI,OmaggioIva,InLav,Imp,"+;
			"Pre,"	+;	&& PTF_PRENOTATO 2008-03-19 rnd
		"PreGreggio,"+;		&& Fix: 0279
		"Ann,Sosp,Bloc,Rad,Note,TipoAnaSpe,Cd_AnaSped,TipoAnaFat,Cd_AnaFatt, "+;
			"cd_prio,cd_asso,numAsso,cd_lotto,notint,notcli,notage,noteann,cd_cauann,cd_ctosca,"+;
			"DecPSCM,DecPSC1,DecPSC2,DecPSC3,DecPSCR,DecPOma,DecPSCP,ApplicaSC,Minsped,PerMinspe,Mintgda,Mintga,"+;
			"UtenteIns,DataIns,UtenteUpd,DataUpd,Cd_Kit,PrezzoKit,QtaKit,Cd_IvaOrd,RifROCli,ScoPromo) "+;
			""+;
			"VALUES (?NOrd,?a,?b,?tipord,?c,"+;
			"?g,?h,?l1,?l2,?l3,?l4,?l5,?l6,?f1,?f2,?f2x,?f3,?f4,"+;
			"?f4b,"	+;	&& PTF_PRENOTATO 2008-03-19 rnd
		"?f4c,"	+;	&& Fix: 0279
		"?f5,?f6,?f7,?f8,?i8,?i2,?i1,?i4,?i3,?i5,?i6,?i7,?i9,"+;
			"?f9,?f10,?f11,?f12,?f13,?f14, " +;
			"?f15x,?f16x,?f17x,?f18x,?f19x,?f20x,?f21x,?f21y,?f22x,?f23x,?f24x,?f25x, " +;
			"?utente,?datax,?utente,?datax,?i10,?i11,?i12,?i13,?xRifROCli,?lcScoPromo) " +;
			" END " +;
			" ELSE " +;
			" BEGIN "+;
			"UPDATE OrdineContDett SET Tipo=?TipOrd,DCons1 = ?g,DCons2 = ?h,Cd_Agente1 = ?l1,Provv1 = ?l2,Cd_Agente2 = ?l3,Provv2 = ?l4,Sconto = ?l5,Royalty = ?l6,"+;
			"OmaggioM=?f1,OmaggioI=?f2,OmaggioIva=?f2x,InLav=?f3,Imp=?f4,"+;
			"Pre=?f4b,"		+;	&& PTF_PRENOTATO 2008-03-19 rnd
		"PreGreggio=?f4c,"	+;	&& Fix: 0279
		"Ann=?f5,Sosp=?f6,Bloc=?f7,Rad=?f8,Note=?i8,TipoAnaSpe=?i2,Cd_AnaSped=?i1,TipoAnaFat=?i4,Cd_AnaFatt=?i3, "+;
			"cd_prio = ?i5,cd_asso = ?i6,numAsso = ?i7,cd_lotto = ?i9,cd_kit =?i10,PrezzoKit=?i11,QtaKit=?i12,Cd_IvaOrd=?i13,UtenteUpd = ?utente,DataUpd = ?datax, "+;
			"notint = ?f9, notcli = ?f10,notage = ?f11,noteann = ?f12,cd_cauann =?f13,cd_ctosca =?f14, "+;
			"DecPSCM= ?f15x,DecPSC1= ?f16x,DecPSC2= ?f17x,DecPSC3= ?f18x,DecPSCR= ?f19x,DecPOma= ?f20x,DecPSCP= ?f21x,ApplicaSC= ?f21y, "+;
			" Minsped = ?f22x,PerMinspe = ?f23x,Mintgda = ?f24x,Mintga = ?f25x, RifROCli = ?xRifROCli,ScoPromo = ?lcScoPromo "+;
			" WHERE OrdineContDett.Nordine=?Nord AND OrdineContDett.NRiga = ?a AND OrdineContDett.Frazio = ?b and OrdineContDett.TipoRiga = ?c "+;
			""+;
			" END "

		lSuccess = SQLExec(connessione,sqlstmt)
		If !check_query(lSuccess)
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Set Deleted On
			Return .F.
		Endif

		Do Case
		Case cDettGen.TipoRiga = 'C'
* Riga Capi

			Select * From cDettC Where cDettC.NRiga == cDettGen.NRiga And cDettC.Frazio == cDettGen.Frazio Into Cursor cDettCx
			If Reccount('cDettCx') = 0
				Sqlrollback(connessione)
				SQLSetprop(connessione,"Transactions",1)
				cMessageText = "0000001TRA"
				nDialogType = 16 + 256
				nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
				Return .F.
			Endif

			Select * From cFasce Where cFasce.NRiga == cDettGen.NRiga Into Cursor cFascex
			If Reccount('cFascex') = 0
				Sqlrollback(connessione)
				SQLSetprop(connessione,"Transactions",1)
				cMessageText = "0000001TRA"
				nDialogType = 16 + 256
				nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
				Return .F.
			Endif

			Select cDettCx
			a = cDettCx.NRiga
			bnofrx = 0

			d = Left(Alltrim(cDettCx.TipoAbb),1)
			e = Left(Alltrim(cDettCx.TipoRigaCa),1)
			F = cDettCx.Abbina


			c1 = Iif(Empty(cDettCx.Cd_Stagion)	    ,Null,Alltrim(cDettCx.Cd_Stagion))
			c2 = Iif(Empty(cDettCx.Cd_Flash)		,Null,Alltrim(cDettCx.Cd_Flash))
			c3 = Iif(Empty(cDettCx.Cd_Linea)		,Null,Alltrim(cDettCx.Cd_Linea))
			c4 = Iif(Empty(cDettCx.Cd_Colle)		,Null,Alltrim(cDettCx.Cd_Colle))

			c5 = Alltrim(cDettCx.Cd_Modello)
			c6 = Alltrim(cDettCx.Cd_VarMod)
			c7 = Alltrim(cDettCx.Cd_AnaMod)
			c8 = Alltrim(cDettCx.Cd_Artico)
			c9 = Alltrim(cDettCx.Cd_VarArt)

&& Pietro 25/10/2010
			If Empty(c8)
				c8 = Null
				c9 = Null
			Else
				c9 = Alltrim(cDettCx.Cd_VarArt)
			Endif

			If Empty(Alltrim(Nvl(c8,'')))
				c8 = Null
				c9 = Null
			Else
				If Empty(Alltrim(Nvl(c9,'')))
					c9 =''
				Endif
			Endif
&& Pietro 25/10/2010

			c10 = Alltrim(cDettCx.Cd_Cartell)
			c11 = Alltrim(cDettCx.Cd_Colore)

			c12 = Iif(Empty(cDettCx.Cd_Varia)		,Null,Alltrim(cDettCx.Cd_Varia))
			c13 = Iif(Empty(cDettCx.Cd_Lavagg)	,Null,Alltrim(cDettCx.Cd_Lavagg))
			c14 = Iif(Empty(cDettCx.Cd_Drop)		,Null,Alltrim(cDettCx.Cd_Drop))
			c15 = Iif(Empty(cDettCx.Cd_Statura)	,Null,Alltrim(cDettCx.Cd_Statura))

			m1 = Iif(Empty(cDettCx.Cd_Etich)		,Null,Alltrim(cDettCx.Cd_Etich))
			m2 = Iif(Empty(cDettCx.Cd_Cart)		,Null,Alltrim(cDettCx.Cd_Cart))
			m3 = Iif(Empty(cDettCx.Cd_Rich)		,Null,Alltrim(cDettCx.Cd_Rich))
			m4 = Iif(Empty(cDettCx.cd_taglia)		,Null,Alltrim(cDettCx.cd_taglia))
			m5 = Iif(Empty(cDettCx.Cd_TagliaC)	,Null,Alltrim(cDettCx.Cd_TagliaC))
			m6 = Iif(Empty(cDettCx.cd_modif)	    ,Null,Alltrim(cDettCx.cd_modif))

			Mgc	   = Iif(Isnull(cDettCx.Cd_MagCap) Or Empty(cDettCx.Cd_MagCap),Null,Alltrim(cDettCx.Cd_MagCap))
			Sce    = Iif(Isnull(cDettCx.Cd_Scelta) Or Empty(cDettCx.Cd_Scelta),Null,Alltrim(cDettCx.Cd_Scelta))
			&& SMI--->
			xNominativo=Iif(Isnull(cDettCx.Nominativo) Or Empty(cDettCx.Nominativo),Null,Alltrim(cDettCx.Nominativo))
			xnotenomina=Iif(Isnull(cDettCx.notenomina) Or Empty(cDettCx.notenomina),"",Alltrim(cDettCx.notenomina))
			&& SMI---<
			*Paolo SMI
			IF Thisform.ordinesmi AND !f3 AND b = 0
			
				Lccolorechk = c11
				IF c10 = 'TINTI'
					Lccolorechk = '000'
				ENDIF 

				IF chkdistbaPer(c1,NVL(c2,''),c3,NVL(c4,''),'C',c7,c5,c6,NVL(c8,''),NVL(c9,''),c10,'ALL',NVL(c12,''),NVL(c13,''),NVL(c14,''),NVL(c15,''),Lccolorechk,Nord,a,.F.) < 0
					*Pulisco eventuali distinte legate all' ordine generate prima di eventuali modifche al codice prodotto
					TEXT TO sqlstmt NOSHOW TEXTMERGE
						Delete from DistintaBaseP where Nordine = <<Nord>> AND Nriga = <<a>>
						Delete from DistintaBaseSLP where Nordine = <<Nord>> AND Nriga = <<a>>
						Delete from DistintaElencoCord where Nordine = <<Nord>> AND Nriga = <<a>>
						Delete from TestaDistintaValOrd where Nordine = <<Nord>> AND Nriga = <<a>>
					ENDTEXT
					lSuccess = SQLExec(connessione,sqlstmt)
					If !check_query(lSuccess)
						Sqlrollback(connessione)
						SQLSetprop(connessione,"Transactions",1)
						Set Deleted On
						Return .F.
					ENDIF
					*				
					db_nor = chkdistba(c1,NVL(c2,''),c3,NVL(c4,''),'C',c7,c5,c6,NVL(c8,''),NVL(c9,''),c10,'ALL',NVL(c12,''),NVL(c13,''),NVL(c14,''),NVL(c15,''),Lccolorechk,Nord,a,.T.)
					IF db_nor > 0					
						IF build_distbaPer(c1,NVL(c2,''),c3,NVL(c4,''),'C',c7,c5,c6,NVL(c8,''),NVL(c9,''),c10,'ALL',NVL(c12,''),NVL(c13,''),NVL(c14,''),NVL(c15,''),Lccolorechk,Nord,a,.F.,db_nor) <= 0
							cMessageText = "0001DISTB"
							nDialogType  = 0 + 16
							nAnswer      = int_MESSAGEBOX(cMessageText, nDialogType,'','In Fase di generazione DB .... ')
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			*
			For iii = 1 To 30
				mystr = "T" + Alltrim(Str(iii)) + "= cDettCx.Tg" + Alltrim(Str(iii))
				&mystr
				If iii <= 10
					mystr = "P" + Alltrim(Str(iii)) + "= cDettCx.Prz" + Alltrim(Str(iii))
					&mystr
				Endif
			Endfor

************************ Tabella fasce prezzo ******************
			Select cFascex
			For iii = 1 To 10
				If iii <= 10
					mystr = "fda" + Alltrim(Str(iii)) + "= cFascex.ftgda" + Alltrim(Str(iii))
					&mystr
					mystr = "fa" + Alltrim(Str(iii)) + "= cFascex.ftga" + Alltrim(Str(iii))
					&mystr
				Endif
			Next
****************************
			sqlarc = ""+;
				" IF not exists(SELECT id FROM OrdineArcC WHERE OrdineArcC.Nordine=?Nord AND OrdineArcC.NRiga = ?a AND OrdineArcC.Frazio = ?bnofrx) "+;
				" BEGIN "+;
				" INSERT INTO OrdineArcC (Tipo,NOrdine,NRiga,Frazio,Tg1,Tg2,Tg3,Tg4,Tg5,Tg6,Tg7,Tg8,Tg9,Tg10,Tg11,Tg12,Tg13,Tg14,Tg15,Tg16,Tg17,"+;
				"Tg18,Tg19,Tg20,Tg21,Tg22,Tg23,Tg24,Tg25,Tg26,Tg27,Tg28,Tg29,Tg30,UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
				" VALUES (?TipOrd,?NOrd,?a,?bnofrx,?t1,?t2,?t3,?t4,?t5,?t6,?t7,?t8,?t9,?t10,?t11,?t12,?t13,?t14,?t15,?t16,?t17,?t18,?t19,?t20,?t21,?t22,"+;
				"?t23,?t24,?t25,?t26,?t27,?t28,?t29,?t30,?utente,?datax,?utente,?datax) "+;
				""+;
				" END "+;
				" ELSE " +;
				" BEGIN "+;
				" UPDATE OrdineArcC SET Tipo=?TipOrd,Tg1 = ?t1,Tg2 = ?t2,Tg3 = ?t3,Tg4 = ?t4,Tg5 = ?t5,Tg6 = ?t6,Tg7 = ?t7,Tg8 = ?t8,Tg9 = ?t9,Tg10 = ?t10,Tg11 = ?t11,Tg12 = ?t12,Tg13 = ?t13,Tg14 = ?t14,Tg15 = ?t15,Tg16 = ?t16,Tg17 = ?t17,"+;
				"Tg18 = ?t18,Tg19 = ?t19,Tg20 = ?t20,Tg21 = ?t21,Tg22 = ?t22,Tg23 = ?t23,Tg24 = ?t24,Tg25 = ?t25,Tg26 = ?t26,Tg27 = ?t27,Tg28 = ?t28,Tg29 = ?t29,Tg30 = ?t30,UtenteUpd = ?utente,DataUpd = ?datax "+;
				" WHERE OrdineArcC.Nordine=?Nord AND OrdineArcC.NRiga = ?a AND OrdineArcC.Frazio = ?bnofrx " +;
				" "+;
				" END "

			sqlarc2 =   		  															""+;
				" IF not exists(SELECT id FROM OrdineArcC WHERE OrdineArcC.Nordine=?Nord AND OrdineArcC.NRiga = ?a AND OrdineArcC.Frazio = ?bnofrx) "+;
				" BEGIN "+;
				" INSERT INTO OrdineArcC (Tipo,NOrdine,NRiga,Frazio,Tg1,Tg2,Tg3,Tg4,Tg5,Tg6,Tg7,Tg8,Tg9,Tg10,Tg11,Tg12,Tg13,Tg14,Tg15,Tg16,Tg17,"+;
				"Tg18,Tg19,Tg20,Tg21,Tg22,Tg23,Tg24,Tg25,Tg26,Tg27,Tg28,Tg29,Tg30,UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
				" VALUES (?TipOrd,?NOrd,?a,?bnofrx,?t1,?t2,?t3,?t4,?t5,?t6,?t7,?t8,?t9,?t10,?t11,?t12,?t13,?t14,?t15,?t16,?t17,?t18,?t19,?t20,?t21,?t22,"+;
				"?t23,?t24,?t25,?t26,?t27,?t28,?t29,?t30,?utente,?datax,?utente,?datax) "+;
				""+;
				" END "


			TestArc = Iif(cDettCx.TipoBlocco = .T.,sqlarc,sqlarc2)
*********************************************************************************************

			test_c1 = Alltrim(Nvl(c1,''))
			test_c2 = Alltrim(Nvl(c2,''))
			test_c3 = Alltrim(Nvl(c3,''))
			test_c4 = Alltrim(Nvl(c4,''))
			test_c5 = Alltrim(Nvl(c5,''))
			test_c6 = Alltrim(Nvl(c6,''))
			test_c7 = Alltrim(Nvl(c7,''))
			test_c8 = Alltrim(Nvl(c8,''))
			test_c9 = Alltrim(Nvl(c9,''))
			test_c10 = Alltrim(Nvl(c10,''))
			test_c11 = Alltrim(Nvl(c11,''))
			test_c12 = Alltrim(Nvl(c12,''))
			test_c13 = Alltrim(Nvl(c13,''))
			test_c14 = Alltrim(Nvl(c14,''))
			test_c15 = Alltrim(Nvl(c15,''))


			TEXT TO sqlStmt TEXTMERGE NOSHOW
				-- SMI-->
				Declare @Nominativo varchar(100)
				SET @Nominativo =?xNominativo
				-- SMI--<
						IF	NOT EXISTS
							(
								SELECT	Id
										FROM	OrdineDettC
										WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a
										AND		Frazio	= ?b
							)
						BEGIN
							INSERT	INTO	OrdineDettC
											(
												NOrdine, NRiga, Frazio,
												Tipo, TipoRigaCa, TipoAbb, Abbina,
												Cd_Stagion, Cd_Flash, Cd_Linea, Cd_Colle,
												Cd_Modello, Cd_VarMod, Cd_AnaMod,
												Cd_Artico, Cd_VarArt, Cd_Cartell, Cd_Colore,
												Cd_Varia, Cd_Lavagg, Cd_Drop, Cd_Statura,
												Cd_Etich, Cd_Cart, Cd_Rich, Cd_modif, Cd_Taglia, Cd_TagliaC,
												Tg1, Tg2, Tg3, Tg4, Tg5, Tg6, Tg7, Tg8, Tg9, Tg10,
												Tg11, Tg12, Tg13, Tg14, Tg15, Tg16, Tg17, Tg18, Tg19, Tg20,
												Tg21, Tg22, Tg23, Tg24, Tg25, Tg26, Tg27, Tg28, Tg29, Tg30,
												Prz1, Prz2, Prz3, Prz4, Prz5, Prz6, Prz7, Prz8, Prz9, Prz10,
												cd_magcap, cd_scelta,
												UtenteIns, DataIns, UtenteUpd, DataUpd
											)
									VALUES (
												?NOrd, ?a, ?b,
												?tipord, ?e, ?d, ?f,
												?c1, ?c2, ?c3, ?c4,
												?c5, ?c6, ?c7,
												?c8, ?c9, ?c10, ?c11,
												?c12, ?c13, ?c14, ?c15,
												?m1, ?m2, ?m3, ?m6, ?m4, ?m5,
												?t1, ?t2, ?t3, ?t4, ?t5, ?t6, ?t7, ?t8, ?t9, ?t10,
												?t11, ?t12, ?t13, ?t14, ?t15, ?t16, ?t17, ?t18, ?t19, ?t20,
												?t21, ?t22, ?t23, ?t24, ?t25, ?t26, ?t27, ?t28, ?t29, ?t30,
												?p1, ?p2, ?p3, ?p4, ?p5, ?p6, ?p7, ?p8, ?p9, ?p10,
												?mgc, ?sce,
												?utente, ?datax, ?utente, ?datax
											)
						END
						ELSE
						BEGIN
							UPDATE	OrdineDettC
									SET		Tipo		= ?tipord, TipoRigaCa	= ?e, TipoAbb	= ?d, Abbina	= ?f,
											Cd_Stagion	= ?c1, Cd_Flash	= ?c2, Cd_Linea	= ?c3, Cd_Colle	= ?c4,
											Cd_Modello	= ?c5, Cd_VarMod	= ?c6, Cd_AnaMod	= ?c7,
											Cd_Artico	= ?c8, Cd_VarArt	= ?c9, Cd_Cartell	= ?c10, Cd_Colore	= ?c11,
											Cd_Varia	= ?c12, Cd_Lavagg	= ?c13, Cd_Drop	= ?c14, Cd_Statura	= ?c15,
											Cd_Etich	= ?m1, Cd_Cart	= ?m2, Cd_Rich	= ?m3, Cd_modif	= ?m6,
											Cd_Taglia	= ?m4, Cd_TagliaC	= ?m5,
											Tg1		= ?t1, Tg2		= ?t2, Tg3		= ?t3, Tg4		= ?t4, Tg5		= ?t5,
											Tg6		= ?t6, Tg7		= ?t7, Tg8		= ?t8, Tg9		= ?t9, Tg10		= ?t10,
											Tg11	= ?t11, Tg12	= ?t12, Tg13	= ?t13, Tg14	= ?t14, Tg15	= ?t15,
											Tg16	= ?t16, Tg17	= ?t17, Tg18	= ?t18, Tg19	= ?t19, Tg20	= ?t20,
											Tg21	= ?t21, Tg22	= ?t22, Tg23	= ?t23, Tg24	= ?t24, Tg25	= ?t25,
											Tg26	= ?t26, Tg27	= ?t27, Tg28	= ?t28, Tg29	= ?t29, Tg30	= ?t30,
											Prz1	= ?p1, Prz2		= ?p2, Prz3		= ?p3, Prz4		= ?p4, Prz5		= ?p5,
											Prz6	= ?p6, Prz7		= ?p7, Prz8		= ?p8, Prz9		= ?p9, Prz10	= ?p10,
											cd_magcap	= ?mgc, cd_scelta	= ?sce,
											UtenteUpd	= ?utente, DataUpd	= ?datax
									WHERE	Nordine	= ?Nord
									AND		NRiga	= ?a
									AND		Frazio	= ?b

						END

						IF	NOT EXISTS
							(
								SELECT	Id
										FROM	OrdineFasce
										WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a
										--AND		Frazio	= !b	-- PTF_FRAZIONEFASCIA 2008-03-31 rnd
							)
						BEGIN
							INSERT	INTO	OrdineFasce
											(
												Tipo, NOrdine, NRiga, Frazio,
												ftgda1, ftgda2, ftgda3, ftgda4, ftgda5, ftgda6, ftgda7, ftgda8, ftgda9, ftgda10,
												ftga1, ftga2, ftga3, ftga4, ftga5, ftga6, ftga7, ftga8, ftga9, ftga10,
												UtenteIns, DataIns, UtenteUpd, DataUpd
											)
									VALUES	(
												?TipOrd, ?NOrd, ?a,
												0, --!b,	-- PTF_FRAZIONEFASCIA 2008-03-31 rnd
												?fda1, ?fda2, ?fda3, ?fda4, ?fda5, ?fda6, ?fda7, ?fda8, ?fda9, ?fda10,
												?fa1, ?fa2, ?fa3, ?fa4, ?fa5, ?fa6, ?fa7, ?fa8, ?fa9, ?fa10,
												?utente, ?datax, ?utente, ?datax
											)
						END
						ELSE
						BEGIN
							UPDATE	OrdineFasce
									SET		Tipo	= ?TipOrd,
											ftgda1		= ?fda1, ftgda2		= ?fda2, ftgda3		= ?fda3, ftgda4		= ?fda4, ftgda5		= ?fda5,
											ftgda6		= ?fda6, ftgda7		= ?fda7, ftgda8		= ?fda8, ftgda9		= ?fda9, ftgda10	= ?fda10,
											ftga1		= ?fa1, ftga2		= ?fa2, ftga3		= ?fa3, ftga4		= ?fa4, ftga5		= ?fa5,
											ftga6		= ?fa6, ftga7		= ?fa7, ftga8		= ?fa8, ftga9		= ?fa9, ftga10		= ?fa10,
											UtenteUpd	= ?utente, DataUpd	= ?datax
									WHERE	Nordine	= ?Nord
									AND		NRiga	= ?a
						END

						<<TestArc>>

						-- && gd.05.07.05 da qui

				--		IF	NOT EXISTS
						IF	EXISTS
							(
								SELECT	Id
										FROM	Posspec
										WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a AND NOT exists
										(SELECT id FROM ordinecall WHERE ordinecall.Nordine=?Nord AND ordinecall.NRiga =?a)
							)
						BEGIN
							UPDATE	Posspec
									SET		TipoAnaSpe	= 'C',
											Cd_AnaSped	= ?i1x
									WHERE	Nordine	= ?Nord
									AND		NRiga	= ?a
						END
						-- && gd.05.07.05 a qui

						IF	NOT EXISTS
							(
								SELECT	Id_Barcode
										FROM	BarCodeCapo
										WHERE	ISNULL (Cd_Stagion, '')	= ?test_c1
										AND		ISNULL (Cd_Flash, '')	= ?test_c2
										AND		ISNULL (Cd_Linea, '')	= ?test_c3
										AND		ISNULL (Cd_Colle, '')	= ?test_c4
										AND		ISNULL (Cd_Modello, '')	= ?test_c5
										AND		ISNULL (Cd_VarMod, '')	= ?test_c6
										AND		ISNULL (Cd_AnaMod, '')	= ?test_c7
										AND		ISNULL (Cd_Artico, '')	= ?test_c8
										AND		ISNULL (Cd_VarArt, '')	= ?test_c9
										AND		ISNULL (Cd_Cartell, '')	= ?test_c10
										AND		ISNULL (Cd_Colore, '')	= ?test_c11
										AND		ISNULL (Cd_Varia, '')	= ?test_c12
										AND		ISNULL (Cd_Lavagg, '')	= ?test_c13
										AND		ISNULL (Cd_Drop, '')	= ?test_c14
										AND		ISNULL (Cd_Statura, '')	= ?test_c15
										AND		TipoAnaMod				= 'C'
							)
						BEGIN
							INSERT	INTO	BarCodeCapo
											(
												Cd_Stagion, Cd_Flash, Cd_Linea, Cd_Colle,
												Cd_Modello, Cd_VarMod, Cd_AnaMod,
												Cd_Artico, Cd_VarArt, Cd_Cartell, Cd_Colore,
												Cd_Varia, Cd_Lavagg, Cd_Drop, Cd_Statura,
												UtenteIns, DataIns, UtenteUpd, DataUpd
											)
									VALUES	(
												?c1, ?c2, ?c3, ?c4,
												?c5, ?c6, ?c7, ?c8,
												?c9, ?c10, ?c11, ?c12,
												?c13, ?c14, ?c15,
												?utente, ?datax, ?utente, ?datax
											)
						END 
						--SMI--->
						IF ISNULL(@Nominativo,'')=''
						BEGIN  
						DELETE FROM OrdineNomi 										
								WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a
						END 
						ELSE
						BEGIN 
							IF exists (select id 
										from OrdineNomi
								WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a )
							BEGIN 
							 	UPDATE OrdineNomi 
							 	SET Tipo=?TipOrd,
							 		Nominativo=@Nominativo,
							 		Note=?xnotenomina,
							 		Dataupd=?datax,
							 		UtenteUpd=?utente
							 	WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a
							 	
							END 
							ELSE
							BEGIN 
								INSERT INTO OrdineNomi(
									NOrdine,NRiga,Frazio,Tipo,TipoAna,Cd_Ana,Nominativo,
									Note,UtenteIns,DataIns,UtenteUpd,DataUpd)
								values(?Nord,?a,?b,?TipOrd,'C',?Cli,@Nominativo,
								?xnotenomina,?utente,?datax,?utente,?datax)
							END 								
						END 
						--SMI---<

			ENDTEXT

*!* PTF_FRAZIONEFASCIA 2008-03-31 rnd <<

		Case cDettGen.TipoRiga = 'A'
* Riga Articoli
			Select * From cDettA Where cDettA.NRiga == cDettGen.NRiga And cDettA.Frazio == cDettGen.Frazio Into Cursor cDettAx
			If Reccount('cDettAx') = 0
				Sqlrollback(connessione)
				SQLSetprop(connessione,"Transactions",1)
				cMessageText = "0000001TRA"
				nDialogType = 16 + 256
				nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
				Return .F.
			Endif

			Select cDettAx
			a = cDettAx.NRiga
			bnofrx = 0

			xTipoRigaCa = Left(Alltrim(cDettAx.TipoRigaCa),1)
			xTipoAbb    = Left(Alltrim(cDettAx.TipoAbb),1)
			xAbbina     = cDettAx.Abbina

			xcd_Artico = Alltrim(cDettAx.Cd_Artico)
			xcd_VarArt = Alltrim(cDettAx.Cd_VarArt)
			xcd_Cartel = Alltrim(cDettAx.Cd_Cartel)
			xcd_Colore = Alltrim(cDettAx.Cd_Colore)

			xcd_UniMis = Alltrim(cDettAx.Cd_UniMis)
			xcd_Misura = Alltrim(cDettAx.Cd_Misura)
			xcd_Bagno  = Alltrim(cDettAx.Cd_Bagno)
			xcd_Pezza  = Alltrim(cDettAx.Cd_Pezza)

			xQta    = Nvl(cDettAx.Qta,0)
			xPrezzo = Nvl(cDettAx.Prezzo,0)

			xcd_Magazz = Iif(Empty(cDettAx.Cd_Magazz),Null,Alltrim(cDettAx.Cd_Magazz))
			xTipoMag   = Iif(Empty(cDettAx.TipoMag)  ,Null,Alltrim(cDettAx.TipoMag))


			sqlarc = ""+;
				" IF not exists(SELECT id FROM OrdineArcA WHERE OrdineArcA.Nordine=?Nord AND OrdineArcA.NRiga = ?a AND OrdineArcA.Frazio = ?bnofrx) "+;
				" BEGIN "+;
				" INSERT INTO OrdineArcA (Tipo,NOrdine,NRiga,Frazio,Qta,"+;
				"UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
				" VALUES (?TipOrd,?NOrd,?a,?bnofrx,?xQta,"+;
				"?utente,?datax,?utente,?datax) "+;
				""+;
				" END "+;
				" ELSE " +;
				" BEGIN "+;
				" UPDATE OrdineArcA SET Tipo=?TipOrd,Qta = ?xQta,UtenteUpd = ?utente,DataUpd = ?datax "+;
				" WHERE OrdineArcA.Nordine=?Nord AND OrdineArcA.NRiga = ?a AND OrdineArcA.Frazio = ?bnofrx " +;
				" "+;
				" END "

			sqlarc2 =   		  															""+;
				" IF not exists(SELECT id FROM OrdineArcA WHERE OrdineArcA.Nordine=?Nord AND OrdineArcA.NRiga = ?a AND OrdineArcA.Frazio = ?bnofrx) "+;
				" BEGIN "+;
				" INSERT INTO OrdineArcA (Tipo,NOrdine,NRiga,Frazio,Qta,"+;
				"UtenteIns,DataIns,UtenteUpd,DataUpd) "+;
				" VALUES (?TipOrd,?NOrd,?a,?bnofrx,?xQta,"+;
				"?utente,?datax,?utente,?datax) "+;
				""+;
				" END "

			TestArc = Iif(cDettAx.TipoBlocco = .T.,sqlarc,sqlarc2)
*********************************************************************************************

			TEXT TO sqlStmt TEXTMERGE NOSHOW

						IF	NOT EXISTS
							(
								SELECT	Id
										FROM	OrdineDettA
										WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a
										AND		Frazio	= ?b
							)
						BEGIN
							INSERT	INTO	OrdineDettA
											(
												NOrdine, NRiga, Frazio,
												Tipo, TipoRigaCa,TipoAbb, Abbina,
												Cd_Artico, Cd_VarArt, Cd_Cartel, Cd_Colore,
												Cd_UniMis, Cd_Misura, Cd_Bagno, Cd_Pezza,
												Qta, Prezzo,
												cd_magazz, TipoMag,
												UtenteIns, DataIns, UtenteUpd, DataUpd
											)
									VALUES (
												?NOrd, ?a, ?b,
												?tipord, ?xTipoRigaCa, ?xTipoAbb, ?xAbbina,
												?xCd_Artico, ?xCd_VarArt, ?xCd_Cartel, ?xCd_Colore,
												?xCd_UniMis, ?xCd_Misura, ?xCd_Bagno, ?xCd_Pezza,
												?xQta, ?xPrezzo,
												?xcd_magazz, ?xTipoMag,
												?utente, ?datax, ?utente, ?datax
											)
						END
						ELSE
						BEGIN
							UPDATE	OrdineDettA
									SET		Tipo		= ?tipord, TipoRigaCa	= ?xTipoRigaCa, TipoAbb	= ?xTipoAbb, Abbina	= ?xAbbina,
									        cd_Artico   = ?xCd_Artico, cd_VarArt = ?xCd_VarArt, cd_Cartel = ?xCd_Cartel, cd_Colore = ?xCd_Colore,
									        cd_UniMis   = ?xCd_UniMis, cd_Misura = ?xCd_Misura, cd_Bagno = ?xCd_Bagno, cd_Pezza = ?xCd_Pezza,
									        Qta         = ?xQta, Prezzo = ?xPrezzo,
									        cd_Magazz   = ?xcd_magazz, TipoMag = ?xTipoMag,
											UtenteUpd	= ?utente, DataUpd	= ?datax
									WHERE	Nordine	= ?Nord
									AND		NRiga	= ?a
									AND		Frazio	= ?b

						END

						<<TestArc>>

						IF	EXISTS
							(
								SELECT	Id
										FROM	PosspeA
										WHERE	Nordine	= ?Nord
										AND		NRiga	= ?a

							)
						BEGIN
							UPDATE	PosspeA
									SET		TipoAnaSpe	= 'C',
											Cd_AnaSped	= ?i1x
									WHERE	Nordine	= ?Nord
									AND		NRiga	= ?a
						END

			ENDTEXT
		Endcase

* Esecuzione mega query di aggiornamento
		lSuccess = SQLExec(connessione,sqlstmt)
		If !check_query(lSuccess)
			Sqlrollback(connessione)
			SQLSetprop(connessione,"Transactions",1)
			Set Deleted On
			Return .F.
		Endif
	Endif
Endscan


********************
Sqlcommit(connessione)
SQLSetprop(connessione,"Transactions",1)
Thisform.StatusBar.Panels(1).Text = " "
Thisform.oprogressBar.Visible = .F.


*** Aggiounto il 30/05/2004
lSuccess = SQLExec(connessione,"select id from OrdineTes where Nordine =?Nord ",'dati_id')

If !check_query(lSuccess)
*return .F.
Else
	If Reccount('dati_id') > 0
		Select dati_id
		Thisform.id_value = dati_id.Id
	Endif
Endif

connessione = Search_Conness("TipiOrdine")
lSuccess = SQLExec(connessione,"SELECT * FROM TipiOrdine Where cd_tipo = ?THISFORM.tipo.Value ",'chktipoord')
If !check_query(lSuccess)
	Return .F.
Endif

tt = ""
If Reccount('chktipoord') > 0
	Select chktipoord
	If chktipoord.pronto = .T.
		tt = '1'
	Endif
Endif


******************** Verifica documenti in essere ********
connessione = Search_Conness("DocumentoTesta")
sqlstmt = "SELECT distinct DocumentoDettc.Nordine " +;
	"FROM DocumentoDettc " 					+;
	"Where Nordine = ?Nord "					+;
	"UNION ALL "								+;
	"SELECT distinct DocumentoDettA.Nordine " +;
	"FROM DocumentoDettA " 					+;
	"Where Nordine = ?Nord "

lSuccess = SQLExec(connessione,sqlstmt,'chkdocumento')
If !check_query(lSuccess)
	Return .F.
Endif


If Reccount('chkdocumento') > 0
	messodoc = "Attenzione !! Parte o tutto l'ordine modificato è già stato avanzato su diversi documenti" +Chr(13) + "Vuoi estendere le modifiche apportate ove è possibile ai documenti collegati ?"
	cMessageText = "0000000GEN"
	nDialogType = 4 + 48
	nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'',messodoc)
	If nAnswer = 6

		Select cDettGen
		Scan
			If cDettGen.Mtest = 'M'

				a = cDettGen.NRiga
				b = cDettGen.Frazio
				c = cDettGen.TipoRiga

				f1 = cDettGen.omaggioM
				f2 = cDettGen.omaggioI
				f2x = cDettGen.omaggioIva
				f14 = Iif(Empty(cDettGen.cd_ctosca),Null,Alltrim(cDettGen.cd_ctosca))
				f15x = cDettGen.DecPSCM
				f16x = cDettGen.DecPSC1
				f17x = cDettGen.DecPSC2
				f18x = cDettGen.DecPSC3
				f19x = cDettGen.DecPSCR
				f20x = cDettGen.DecPOma
				f21x = cDettGen.DecPSCP
				f21y = cDettGen.ApplicaSC

				l1 = Iif(Empty(cDettGen.Cd_Agente1)	,Null,Alltrim(cDettGen.Cd_Agente1))
				l2 = Iif(Empty(cDettGen.provv1)		,Null,Alltrim(cDettGen.provv1))
				l3 = Iif(Empty(cDettGen.Cd_Agente2)	,Null,Alltrim(cDettGen.Cd_Agente2))
				l4 = Iif(Empty(cDettGen.provv2)		,Null,Alltrim(cDettGen.provv2))
				l6 = Iif(Empty(cDettGen.Royalty)	,Null,Alltrim(cDettGen.Royalty))
				l7 = Iif(Empty(cDettGen.Cd_Ivaord)	,Null,Alltrim(cDettGen.Cd_Ivaord))

				Do Case
				Case cDettGen.TipoRiga = 'C'
* Riga Capi
					SqlStmtDoc = " Update DocumentoCont SET  DocumentoCont.OmaggioM   = ?f1, "+;
						"DocumentoCont.OmaggioI   = ?f2, "+;
						"DocumentoCont.OmaggioIva = ?f2x, "+;
						"DocumentoCont.cd_ctosca  = ?f14, "+;
						"DocumentoCont.DecPSCM    = ?f15x, "+;
						"DocumentoCont.DecPSC1    = ?f16x, "+;
						"DocumentoCont.DecPSC2    = ?f17x, "+;
						"DocumentoCont.DecPSC3    = ?f18x, "+;
						"DocumentoCont.DecPSCR    = ?f19x, "+;
						"DocumentoCont.DecPOma    = ?f20x, "+;
						"DocumentoCont.DecPSCP    = ?f21x, "+;
						"DocumentoCont.ApplicaSC  = ?f21y, "+;
						"DocumentoCont.Cd_Agente1 = ?l1, "+;
						"DocumentoCont.Provv1     = ?l2, "+;
						"DocumentoCont.Cd_Agente2 = ?l3, "+;
						"DocumentoCont.Provv2     = ?l4, "+;
						"DocumentoCont.royalty    = ?l6,  "+;
						"DocumentoCont.Cd_IvaRig  = ?l7  "+;
						" FROM DocumentoCont "+;
						" Inner Join DocumentoTesta ON Documentotesta.id =  DocumentoCont.id_testa "+;
						" Inner Join DocumentoDettc ON DocumentoDettc.id_testa = DocumentoCont.id_testa AND DocumentoDettc.Sequenza = DocumentoCont.Sequenza AND DocumentoDettc.SequFrz = DocumentoCont.SequFrz "+;
						" WHERE DocumentoDettc.Nordine = ?Nord AND DocumentoDettc.Nriga = ?a and DocumentoDettc.Frazio = ?b "+;
						" AND DocumentoTesta.Tipo = 'B' "

					lSuccess = SQLExec(connessione,SqlStmtDoc)
					If !check_query(lSuccess)
						Return .F.
					Endif

&& Inizio sandro 20/01/2006
					Select * From cDettC Where cDettC.NRiga == cDettGen.NRiga And cDettC.Frazio == cDettGen.Frazio Into Cursor cDettC_agg
					If Reccount('cDettC_agg') > 0
						For dfg = 1 To 10
							campo = "xPrzx"+Alltrim(Str(dfg)) + " = 0 "
							&campo
							campo = "xPrzx"+Alltrim(Str(dfg)) + " = cDettC_agg.prz"+Alltrim(Str(dfg))
							&campo
						Next
						SqlStmtDoc = " Update DocumentoDettc SET  DocumentoDettc.Prz1   = ?xPrzx1, "+;
							" DocumentoDettc.Prz2   = ?xPrzx2, "+;
							" DocumentoDettc.Prz3   = ?xPrzx3, "+;
							" DocumentoDettc.Prz4   = ?xPrzx4, "+;
							" DocumentoDettc.Prz5   = ?xPrzx5, "+;
							" DocumentoDettc.Prz6   = ?xPrzx6, "+;
							" DocumentoDettc.Prz7   = ?xPrzx7, "+;
							" DocumentoDettc.Prz8   = ?xPrzx8, "+;
							" DocumentoDettc.Prz9   = ?xPrzx9, "+;
							" DocumentoDettc.Prz10   = ?xPrzx10 "+;
							" FROM DocumentoDettc "+;
							" Inner Join DocumentoTesta ON Documentotesta.id =  DocumentoDettc.id_testa "+;
							" Inner Join DocumentoCont ON DocumentoDettc.id_testa = DocumentoCont.id_testa AND DocumentoDettc.Sequenza = DocumentoCont.Sequenza AND DocumentoDettc.SequFrz = DocumentoCont.SequFrz "+;
							" WHERE DocumentoDettc.Nordine = ?Nord AND DocumentoDettc.Nriga = ?a and DocumentoDettc.Frazio = ?b "+;
							" AND DocumentoTesta.Tipo = 'B' "


						lSuccess = SQLExec(connessione,SqlStmtDoc)
						If !check_query(lSuccess)
							Return .F.
						Endif

					Endif
&& Fine sandro 20/01/2006

				Case cDettGen.TipoRiga = 'A'
* Riga Articoli
					SqlStmtDoc = " Update DocumentoCont SET  DocumentoCont.OmaggioM   = ?f1, "+;
						"DocumentoCont.OmaggioI   = ?f2, "+;
						"DocumentoCont.OmaggioIva = ?f2x, "+;
						"DocumentoCont.cd_ctosca  = ?f14, "+;
						"DocumentoCont.DecPSCM    = ?f15x, "+;
						"DocumentoCont.DecPSC1    = ?f16x, "+;
						"DocumentoCont.DecPSC2    = ?f17x, "+;
						"DocumentoCont.DecPSC3    = ?f18x, "+;
						"DocumentoCont.DecPSCR    = ?f19x, "+;
						"DocumentoCont.DecPOma    = ?f20x, "+;
						"DocumentoCont.DecPSCP    = ?f21x, "+;
						"DocumentoCont.ApplicaSC  = ?f21y, "+;
						"DocumentoCont.Cd_Agente1 = ?l1, "+;
						"DocumentoCont.Provv1     = ?l2, "+;
						"DocumentoCont.Cd_Agente2 = ?l3, "+;
						"DocumentoCont.Provv2     = ?l4, "+;
						"DocumentoCont.royalty    = ?l6,  "+;
						"DocumentoCont.Cd_IvaRig  = ?l7  "+;
						" FROM DocumentoCont "+;
						" Inner Join DocumentoTesta ON Documentotesta.id =  DocumentoCont.id_testa "+;
						" Inner Join DocumentoDettA ON DocumentoDettA.id_testa = DocumentoCont.id_testa AND DocumentoDettA.Sequenza = DocumentoCont.Sequenza AND DocumentoDettA.SequFrz = DocumentoCont.SequFrz "+;
						" WHERE DocumentoDettA.Nordine = ?Nord AND DocumentoDettA.Nriga = ?a and DocumentoDettA.Frazio = ?b "+;
						" AND DocumentoTesta.Tipo = 'B' "

					lSuccess = SQLExec(connessione,SqlStmtDoc)
					If !check_query(lSuccess)
						Return .F.
					Endif

&& Inizio sandro 20/01/2006
					Select * From cDettA Where cDettA.NRiga == cDettGen.NRiga And cDettA.Frazio == cDettGen.Frazio Into Cursor cDettA_agg
					If Reccount('cDettA_agg') > 0
						xPrezzo = cDettA_agg.Prezzo
						SqlStmtDoc = " Update DocumentoDettA SET  DocumentoDettA.Prezzo = ?xPrezzo "+;
							" FROM DocumentoDettA "+;
							" Inner Join DocumentoTesta ON Documentotesta.id =  DocumentoDettA.id_testa "+;
							" WHERE DocumentoDettA.Nordine = ?Nord AND DocumentoDettA.Nriga = ?a and DocumentoDettA.Frazio = ?b "+;
							" AND DocumentoTesta.Tipo = 'B' "


						lSuccess = SQLExec(connessione,SqlStmtDoc)
						If !check_query(lSuccess)
							Return .F.
						Endif

					Endif
&& Fine sandro 20/01/2006

				Endcase

			Endif
		Endscan
	Endif
Endif

* Applico le eventuali promozioni
SET PROCEDURE TO ordcli_promo.FXP ADDITIVE
xTest = ordcli_Calcolapromo(THISFORM.nordine.Value)
RELEASE PROCEDURE ordcli_promo

IF xTest = .T.
	modalform("Ordcli_PromoDettaglio",THISFORM.nordine.Value,'N',Thisform)		
ENDIF 
* Fine Applicazione eventuali promozioni

** se ci sono errori nel salvataggio ritorno sulla form altrimenti esco
Select * From cDettC 																					;
	INNER Join cDettGen On (cDettC.NRiga = cDettGen.NRiga And cDettC.Frazio = cDettGen.Frazio) 				;
	WHERE !Empty(Nvl(cDettC.Cd_MagCap,'')) And cDettGen.inLav = .F. And cDettGen.imp = .F.					;
	AND cDettGen.Pre = .F.																			;
	AND cDettGen.Ann = .F. And cDettGen.Rad = .F. And cDettGen.Bloc = .F. And cDettGen.Sosp = .F. 	;
	INTO Cursor DaMagazzinoC

Select * From cDettA 																					;
	INNER Join cDettGen On (cDettA.NRiga = cDettGen.NRiga And cDettA.Frazio = cDettGen.Frazio) 				;
	WHERE !Empty(Nvl(cDettA.Cd_Magazz,'')) And cDettGen.inLav = .F. And cDettGen.imp = .F.					;
	AND cDettGen.Pre = .F.																			;
	AND cDettGen.Ann = .F. And cDettGen.Rad = .F. And cDettGen.Bloc = .F. And cDettGen.Sosp = .F. 	;
	INTO Cursor DaMagazzinoA

If Reccount('DaMagazzinoC') > 0 Or Reccount('DaMagazzinoA') > 0 Or tt = "1"
	cMessageText = "0000ORDMAG"
	nDialogType = 4 + 48
	nAnswer = int_MESSAGEBOX(cMessageText, nDialogType,'','')
	If nAnswer = 6
		cfrm = 'OrdCli_Assegna'
		modalform(cfrm,'T',Alltrim(Str(NOrd)))
	Endif
Endif

If Thisform.pf.page1.pf.page3.fido.Value = .T.
	*docu        = thisform.calcolototaledoc_iva()
	
	Sqlstmt = "Select ValNSco,ValIva From OrdDettc_Ivato Where NOrdine = ?THISFORM.nordine.Value " +;
	          "Union All " +;
	          "Select ValNSco,ValIva From OrdDettA_Ivato Where NOrdine = ?THISFORM.nordine.Value " 
	          
	connessione = search_conness("Pagamento")
	lSucc = sqlexec(connessione,sqlstmt,'dati_ord')
	IF !Check_Query(lSucc)
		RETURN .F.
	ENDIF
	
	docu = 0
	SELECT dati_ord
	SCAN 
		docu = docu + NVL(dati_ord.ValNSco,0)+NVL(dati_ord.ValIva,0)
	ENDSCAN		
	
	xcd_AnaFatt = IIF(EMPTY(ALLTRIM(NVL(thisform.pf.page1.pf.page1.cd_AnaFatt.txtsrc1.Value,''))),ALLTRIM(thisform.cliente.txtsrc1.value),ALLTRIM(thisform.pf.page1.pf.page1.cd_AnaFatt.txtsrc1.Value))
	Cambio_Val  = 1
	xcd_Valuta  = ALLTRIM(thisform.pf.page1.pf.page1.valuta.txtsrc1.Value)
	xcd_StagioV = ALLTRIM(thisform.pf.page1.pf.page1.stagione.txtsrc1.Value)
	IF xcd_Valuta != oApp.Valuta					
		Sqlstmt = "Select * from vs_Cambi Where cd_valuta = ?xcd_valuta AND cd_valref = ?oApp.Valuta "
		lSucc = sqlexec(connessione,sqlstmt,'dati_valuta')
		IF !Check_Query(lSucc)
			RETURN .F.
		ENDIF
		
		IF RECCOUNT('dati_valuta') > 0
			Cambio_val = NVL(dati_valuta.cambio,1)
		ENDIF		
	ENDIF
	docu = ROUND((docu / Cambio_val), 2)

	* Modalità Analisi Fido (per stagione o tutte le stagoni)
	* S = Analisi per Stagione, T = Tutte le Stagioni
	connessione = search_conness("xPcoparameters")
	Sqlstmt = "Select * From xPCoparameters " +;
	          "Where NameSpace = 'modulobase' and object = 'FIDO' and campo = 'TIPOANALISI' "
	          
	lSucc = sqlexec(connessione,sqlstmt,'_paramFido_cur')
	IF !Check_Query(lSucc)
		RETURN .F.
	ENDIF

	xTipoAnalisi = "T"
	IF RECCOUNT('_paramFido_cur') > 0
		xTipoAnalisi = ALLTRIM(_paramFido_cur.Valore)
	ENDIF
		
	THISFORM.Valorefido = 0 
	*THISFORM.Valorefido = chkFido(docu,THISFORM.cliente.txtsrc1.value,THISFORM.nordine.value,oApp.Valuta)
	THISFORM.Valorefido = chkfido(docu, xcd_AnaFatt, thisform.NOrdine.Value, xcd_StagioV, xTipoAnaLisi)
	IF THISFORM.valorefido < 0
		THISFORM.int_toolbar1.bt_fido.Click()
	ENDIF 	
Endif

Thisform.Release()
