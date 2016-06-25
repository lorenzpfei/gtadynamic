
#define MAX_BIZZES 40
new Float:B_Distance = 20.0;
new Float:B_enterdist = 1.25;

enum eBiz {
	bID,
	bOwnerID,
	bStatus,
	Float:bX,
	Float:bY,
	Float:bZ,
	bInt,
	bWorld,
	Float:biX,
	Float:biY,
	Float:biZ,
	biInt,
	biWorld,
	bPreis,
	bProds,
	bProdPreis,
	bBuyProdPreis,
	bOpen,
	bName[50],
	bUsername[50],
	bPort,
	bKasse,
	bPickup,
	biPickup,
	Text3D:bText
};
new BizData[MAX_BIZZES][eBiz];
new bizamount = 0;

stock BizOnGameModeInit()
{
	new bi, bResult[500];
	mysql_query("SELECT `id`, `owner`, `status`, `x`, `y`, `z`, `int`, `world`, `int_x`, `int_y`, `int_z`,\n\
				`int_int`, `int_world`, `price`, `prods`, `prod_price`, `prod_buy_price`, `opened`,\n\
				`name`, `name_user`, `port`, `cash` FROM `bizzes`;");
	mysql_store_result();
	while(mysql_fetch_row_format(bResult)) 
	{
		sscanf(bResult,"p<|>e<iiifffiifffiiiiiiis[50]s[50]ii>",BizData[bi]);
		//print(bResult);
		bizamount ++;
		bi++;
	}
    mysql_free_result();
	
	//print("bizI");
	for(new bizI = 0; bizI < bizamount; bizI++)
	{
		//printf("id: %d", bizI);
		new preisstring[128], o[8];
		valstr(o, BizData[bizI][bOwnerID]);
		if(BizData[bizI][bStatus] == 0)
		{
			BizData[bizI][bPickup] = CreatePickup(1273, 1, BizData[bizI][bX], BizData[bizI][bY], BizData[bizI][bZ], -1);
			format(preisstring, sizeof(preisstring), "Zu verkaufen! \nPreis: %d$\n[ENTER]", BizData[bizI][bPreis]);
			BizData[bizI][bText] = Create3DTextLabel(preisstring,cBizgruen,BizData[bizI][bX], BizData[bizI][bY], BizData[bizI][bZ],B_Distance,0);
		}
		if(BizData[bizI][bStatus] == 1)
		{
			BizData[bizI][bPickup] = CreatePickup(1273, 1, BizData[bizI][bX], BizData[bizI][bY], BizData[bizI][bZ], -1);
			format(preisstring, sizeof(preisstring), "Besitzer: %s \n%s \n(%s) \nEinheiten: %d \nEinheitenpreis: %d$\n Eintrittspreis: %d$", mysql_GetString("accounts", "Name", "id", o), BizData[bizI][bUsername], BizData[bizI][bName],BizData[bizI][bProds], BizData[bizI][bProdPreis], BizData[bizI][bBuyProdPreis]);
			BizData[bizI][bText] = Create3DTextLabel(preisstring,cBizgruen,BizData[bizI][bX], BizData[bizI][bY], BizData[bizI][bZ],B_Distance,0);
		}
		if(BizData[bizI][bPort] == 1)
		{
			BizData[bizI][biPickup] = CreatePickup(1273, 1, BizData[bizI][biX], BizData[bizI][biY], BizData[bizI][biZ], -1);
		}
	}
	
	
	printf("[START] Bizzes geladen. [%d]", bizamount);
}


stock BizOnGameModeExit()
{
	for(new i=0; i<sizeof(BizData); i++)
	{
		if(BizData[i][bPickup])
		{
			DestroyPickup(BizData[i][bPickup]);
		}
		if(BizData[i][biPickup])
		{
			DestroyPickup(BizData[i][biPickup]);
		}
		if(BizData[i][bText])
		{
			Delete3DTextLabel(BizData[i][bText]);
		}
	}
}

stock BizOnPlayerConnect(playerid)
{
	for(new i = 0; i < bizamount; i++)
	{
		if(BizData[i][bStatus] == 0)
		{
			CreateMapIcon(playerid, BizData[i][bX], BizData[i][bY], BizData[i][bZ], 31, 0, 0);
		}
		if(BizData[i][bStatus] == 1)
		{
			CreateMapIcon(playerid, BizData[i][bX], BizData[i][bY], BizData[i][bZ], 31, 0, 0);
		}
		if(BizData[i][bStatus] == 2)
		{
			CreateMapIcon(playerid, BizData[i][bX], BizData[i][bY], BizData[i][bZ], 31, 0, 0);
		}
	}
}

ocmd:biz(playerid, params[])
{
	for(new i=0; i<sizeof(BizData); i++)
	{
		if(!BizData[i][bID])continue;
		if(IsPlayerInRangeOfPoint(playerid,B_enterdist,BizData[i][bX], BizData[i][bY], BizData[i][bZ]))
		{
			if(GetPVarInt(playerid, "Eingeloggt") != 1)
			{
				echo(playerid, cRot, "Du bist nicht eingeloggt!");
				KickTimer(playerid, 100);
				return 1;
			}
			if(BizData[i][bStatus] != 0)
			{
				if((BizData[i][bOwnerID] == SpielerInfo[playerid][peID]) || isPlayerAnAdmin(playerid, 5))
				{
					PlayerInfo[playerid][WhereBiz] = i;
					ShowBiz(playerid, i);
				}
			}
		}
	}
	return 1;
}

stock SaveBizzes()
{
	for(new i = 0; i < bizamount; i++)
	{
		new query[560];
		format(query, sizeof query, "UPDATE `bizzes` SET `owner` = %i, `status` = %i, `price` = %i, `prods` = %i, `prod_price` = %i, `prod_buy_price` = %i, `opened` = %i, `name_user` = '%s', `cash` = %i WHERE `id` = %i;",
			BizData[i][bOwnerID], BizData[i][bStatus], BizData[i][bPreis], BizData[i][bProds], BizData[i][bProdPreis], BizData[i][bBuyProdPreis], BizData[i][bOpen], BizData[i][bUsername], BizData[i][bKasse], i);
		mysql_query(query);
	}
	//Adminecho(cGelb, "[INFO] Bizzes wurden gespeichert.");
	return 1;
}

stock BizOnPlayerKeyStateChange(playerid)
{
	new haveabiz = 0;
	for(new i=0; i<sizeof(BizData); i++)
	{
		if(!BizData[i][bID])continue;
		new e[8];
		if(BizData[i][bOwnerID] == SpielerInfo[playerid][peID])
		{
			haveabiz ++;
		}
		if(IsPlayerInRangeOfPoint(playerid,B_enterdist,BizData[i][bX], BizData[i][bY], BizData[i][bZ]))
		{
			if(BizData[i][bStatus] != 0)
			{
				if(BizData[i][bOpen] == 0)
				{
					//closed
					echo(playerid, cRot, "Das Biz ist verschlossen!");
				}
				if(BizData[i][bOpen] == 1)
				{
					if(BizData[i][bPort] == 1)
					{
						if(BizData[i][bBuyProdPreis] <= SpielerInfo[playerid][pGeld])
						{
							format(e, sizeof(e), "%d", i+1);
							SetPlayerPos(playerid, BizData[i][biX], BizData[i][biY], BizData[i][biZ]);
							SetPlayerInterior(playerid, BizData[i][biInt]);
							SetPlayerVirtualWorld(playerid, i);
							AGivePlayerMoney(playerid, -BizData[i][bBuyProdPreis]);
							BizData[i][bKasse] += BizData[i][bBuyProdPreis];
							mysql_UpdateInt("bizzes", "cash", BizData[i][bKasse], "id", e);
							SetPVarInt(playerid, "Biz", i+1);
							if(GetPVarInt(playerid, "Biz") == 1)
							{
								GivePlayerWeapon(playerid, 24, 9999);
								GivePlayerWeapon(playerid, 29, 9999);
								GivePlayerWeapon(playerid, 31, 9999);
							}
						}
						else return echo(playerid, cRot, "Du hast nicht genug Geld!");
					}
				}
			}
			else
			{
				//kaufen
				if(SpielerInfo[playerid][pGeld] >= BizData[i][bPreis])
				{
					if(haveabiz > 0)
					{
						echo(playerid, cRot, "Du hast bereits ein Biz.");
						break;
					}
					new strPlayer[128], query[256], o[8];
					format(o, sizeof(o), "%d", BizData[i][bOwnerID]);
					BizData[i][bStatus] = 1;
					BizData[i][bOwnerID] = SpielerInfo[playerid][peID];
					UpdateBiz(i);
					AGivePlayerMoney(playerid, -BizData[i][bPreis]);
					format(strPlayer, sizeof(strPlayer), "Herzlichen Glückwunsch! Du hast dir erfolgreich ein Biz für %d$ gekauft!", BizData[i][bPreis]);
					echo(playerid, cBizgruen, strPlayer);
					
					format(query, sizeof query, "UPDATE `bizzes` SET `owner` = %i, `status` = %i WHERE `id` = %i;", BizData[i][bOwnerID], BizData[i][bStatus], BizData[i][bID]);
					mysql_query(query);
					
					printf("[Biz] %s hat sich das Biz mit der ID %d gekauft.", SpielerName(playerid), BizData[i][bID]);
				}
				else
				{
					new strBiz[128];
					format(strBiz, sizeof(strBiz), "Du besitzt nicht genug Geld, um das Biz für %d$ zu kaufen.", BizData[i][bPreis]);
					echo(playerid, cRot, strBiz);
				}
					
			}
		}
		if(IsPlayerInRangeOfPoint(playerid,B_enterdist,BizData[i][biX], BizData[i][biY], BizData[i][biZ]))
		{
			SetPlayerPos(playerid, BizData[i][bX], BizData[i][bY], BizData[i][bZ]);
			SetPlayerInterior(playerid, BizData[i][bInt]);
			SetPlayerVirtualWorld(playerid, 0);
			ResetPlayerWeapons(playerid);
			DeletePVar(playerid, "Biz");
		}
	}
	return 1;
}

stock BizOnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == diaBiz)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereBiz];
			new e[8];
			format(e, sizeof(e), "%d", i+1);
			switch(listitem)
			{
				case 0:
				{
					//Kasse
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Bizmenü - Kasse: %d$", BizData[i][bKasse]);
					ShowDialog(playerid, diaBizKasse, DIALOG_STYLE_LIST, strTitel, "Abheben \nEinzahlen", "Auswählen", "Abbrechen");
				}
				case 1:
				{
					//Username
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Bizmenü - Name: %s", BizData[i][bUsername]);
					ShowDialog(playerid, diaBizName, DIALOG_STYLE_INPUT, strTitel, "Bitte gib einen neuen Namen ein:", "Ändern", "Abbrechen");	
				}
				case 2:
				{
					//Art/Infos
					new strInhalt[128], strPort[16];
					if(BizData[i][bPort] == 0)
					{
						strPort = "Nein";
					}
					if(BizData[i][bPort] == 1)
					{
						strPort = "Ja";
					}
					format(strInhalt, sizeof(strInhalt), "Bizart: %s \nBizid (DB): %d \nPort: %s", BizData[i][bName], i+1, strPort);
					ShowDialog(playerid, diaBizArt, DIALOG_STYLE_MSGBOX, "Bizmenü - Art/Infos", strInhalt, "Okay", "");
				}
				case 3:
				{
					//Einheitenpreis VK
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Bizmenü - Einheitenpreis (Verkauf): %d$", BizData[i][bBuyProdPreis]);
					ShowDialog(playerid, diaBizVK, DIALOG_STYLE_INPUT, strTitel, "Bitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				}
				case 4:
				{
					//Einheitenpreis EK
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Bizmenü - Einheitenpreis (Einkauf): %d$", BizData[i][bProdPreis]);
					ShowDialog(playerid, diaBizEK, DIALOG_STYLE_INPUT, strTitel, "Bitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				}
				case 5:
				{
					//Einheiten
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Einheiten: %d", BizData[i][bProds]);
					ShowDialog(playerid, diaInfo, DIALOG_STYLE_MSGBOX, "Bizmenü - Einheiten", strTitel, "Okay", "");
				}
				case 6:
				{
					//LOCKED
					if(BizData[i][bOpen] == 0)
					{
						BizData[i][bOpen] = 1;
						mysql_UpdateInt("bizzes", "opened", 1, "id", e);
					}
					else
					{
						BizData[i][bOpen] = 0;
						mysql_UpdateInt("bizzes", "opened", 0, "id", e);
					}
					ShowBiz(playerid, i);
				}
				case 8:
				{
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Bizmenü - Verkaufen - %s", BizData[i][bUsername]);
					ShowDialog(playerid, diaBizSell, DIALOG_STYLE_MSGBOX, strTitel, "Möchtest du dein Biz wirklich verkaufen?", "Verkaufen", "Abbrechen");
				}
			}
		}
	}
	if(dialogid == diaBizSell)
	{
		new i = PlayerInfo[playerid][WhereBiz];
		if(response == 1)
		{
			new e[8], strMoney[128];
			format(e, sizeof(e), "%d", i+1);
			BizData[i][bOwnerID] = 0;
			BizData[i][bStatus] = 0;
			mysql_UpdateInt("bizzes", "owner", 0, "id", e);
			mysql_UpdateInt("bizzes", "status", 0, "id", e);
			
			format(strMoney, sizeof(strMoney), "Du hast dein Biz verkauft und %d$ erhalten.", BizData[i][bPreis]);
			AGivePlayerMoney(playerid, BizData[i][bPreis]);
			echo(playerid, cBizgruen, strMoney);
			UpdateBiz(i);
		}
	}
	if(dialogid == diaBizKasse)
	{
		if(response == 1)
		{
			switch(listitem)
			{
				case 0:
				{
					ShowDialog(playerid, diaBizKasseOut, DIALOG_STYLE_INPUT, "BIZMENÜ - Auszahlen", "Bitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
				}
				case 1:
				{
					ShowDialog(playerid, diaBizKasseIn, DIALOG_STYLE_INPUT, "BIZMENÜ - Einzahlen", "Bitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
				}
			}
		}
	}
	if(dialogid == diaBizKasseOut)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereBiz];
			new e[8], swag;
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount)) return ShowDialog(playerid, diaBizKasseOut, DIALOG_STYLE_INPUT, "BIZMENÜ - Auszahlen", "Ungültige Eingabe\nBitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
			if(amount < 1) return ShowDialog(playerid, diaBizKasseOut, DIALOG_STYLE_INPUT, "BIZMENÜ - Auszahlen", "Ungültige Eingabe\nBitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
			if(amount > BizData[i][bKasse])return ShowDialog(playerid, diaBizKasseOut, DIALOG_STYLE_INPUT, "BIZMENÜ - Auszahlen", "Ungültige Eingabe\nBitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
			swag = BizData[i][bKasse]-amount;
			BizData[i][bKasse] = swag;
			mysql_UpdateInt("bizzes", "cash", swag, "id", e);
			AGivePlayerMoney(playerid, amount);
			ShowBiz(playerid, i);
		}
	}
	if(dialogid == diaBizKasseIn)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereBiz];
			new e[8], swag;
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount)) return ShowDialog(playerid, diaBizKasseIn, DIALOG_STYLE_INPUT, "BIZMENÜ - Einzahlen", "Ungültige Eingabe\nBitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
			if(amount < 1) return ShowDialog(playerid, diaBizKasseIn, DIALOG_STYLE_INPUT, "BIZMENÜ - Einzahlen", "Ungültige Eingabe\nBitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
			if(amount > SpielerInfo[playerid][pGeld])return ShowDialog(playerid, diaBizKasseIn, DIALOG_STYLE_INPUT, "BIZMENÜ - Einzahlen", "Ungültige Eingabe\nBitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
			swag = BizData[i][bKasse]+amount;
			BizData[i][bKasse] = swag;
			
			BizData[i][bKasse] = swag;
			mysql_UpdateInt("bizzes", "cash", swag, "id", e);
			AGivePlayerMoney(playerid, -amount);
			ShowBiz(playerid, i);
		}
	}
	if(dialogid == diaBizName)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereBiz];
			new e[8];
			format(e, sizeof(e), "%d", i+1);
			new text[50];
			if(sscanf(inputtext, "s[50]", text))
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Bizmenü - Name: %s", BizData[i][bUsername]);
				ShowDialog(playerid, diaBizName, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Namen ein:", "Ändern", "Abbrechen");
				return 1;
			}
			BizData[i][bUsername] = text;
			mysql_SetString("bizzes", "name_user", text, "id", e);
			UpdateBiz(i);
			ShowBiz(playerid, i);
		}
	}
	if(dialogid == diaBizVK)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereBiz];
			new e[8];
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount))
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Bizmenü - Einheitenpreis (Verkauf): %d$", BizData[i][bBuyProdPreis]);
				ShowDialog(playerid, diaBizVK, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				return 1;
			}
			if(amount < 1)
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Bizmenü - Einheitenpreis (Verkauf): %d$", BizData[i][bBuyProdPreis]);
				ShowDialog(playerid, diaBizVK, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				return 1;
			}
			BizData[i][bProdPreis] = amount;
			mysql_UpdateInt("bizzes", "prod_price", amount, "id", e);
			UpdateBiz(i);
			ShowBiz(playerid, i);
		}
	}
	if(dialogid == diaBizEK)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereBiz];
			new e[8];
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount))
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Bizmenü - Einheitenpreis (Einkauf): %d$", BizData[i][bProdPreis]);
				ShowDialog(playerid, diaBizEK, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				return 1;
			}
			if(amount < 1)
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Bizmenü - Einheitenpreis (Einkauf): %d$", BizData[i][bProdPreis]);
				ShowDialog(playerid, diaBizEK, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				return 1;
			}
			BizData[i][bBuyProdPreis] = amount;
			mysql_UpdateInt("bizzes", "prod_buy_price", amount, "id", e);
			UpdateBiz(i);
			ShowBiz(playerid, i);
		}
	}
	return 1;
}

stock ShowBiz(playerid, i)
{
	new bizname[128], bizinhalt[512], strOpen[16];
	if(BizData[i][bOpen] == 0)
	{
		strOpen = "Nein";
	}
	if(BizData[i][bOpen] == 1)
	{
		strOpen = "Ja";
	}
	format(bizname, sizeof(bizname), "Bizmenü: [%s]", BizData[i][bUsername]);
	format(bizinhalt, sizeof(bizinhalt), "Kasse: %d$ \nName: %s \nArt: %s \nEinheitenpreis(Verkauf): %d$ \nEinheitenpreis(Kauf): %d$ \nEinheiten: %d \nGeöffnet: %s \n \nVerkaufen", BizData[i][bKasse], BizData[i][bUsername], BizData[i][bName], BizData[i][bProdPreis], BizData[i][bBuyProdPreis], BizData[i][bProds], strOpen);
	ShowDialog(playerid, diaBiz, DIALOG_STYLE_LIST, bizname, bizinhalt, "Auswählen", "Fertig");
}

stock UpdateBiz(id)
{
	new preisstring[128], o[8];
	format(o, sizeof(o), "%d", BizData[id][bOwnerID]);

	if(BizData[id][bStatus] == 0)
	{
		format(preisstring, sizeof(preisstring), "Zu verkaufen! \nPreis: %d$\n[ENTER]", BizData[id][bPreis]);
		Update3DTextLabelText(BizData[id][bText], cBizgruen, preisstring);
	}
	if(BizData[id][bStatus] == 1)
	{
		format(preisstring, sizeof(preisstring), "Besitzer: %s \n%s \n(%s) \nEinheiten: %d \nEinheitenpreis: %d$\n Eintrittspreis: %d$", mysql_GetString("accounts", "name", "id", o), BizData[id][bUsername], BizData[id][bName],BizData[id][bProds], BizData[id][bProdPreis], BizData[id][bBuyProdPreis]);
		Update3DTextLabelText(BizData[id][bText], cBizgruen, preisstring);
	}
	return 1;
}