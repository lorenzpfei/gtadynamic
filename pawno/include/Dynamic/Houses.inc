#define MAX_HOUSES 50
new Float:H_enterdist = 1.25;
new Float:H_Distance = 10.0;
new houseIcon2[MAX_HOUSES];

enum eHouse {
    hID,
	hOwnerID,
	hInterior,
	hStatus,
	Float:hX,
	Float:hY,
	Float:hZ,
	hInt,
	hWorld,
	hOpen,
	hHeal,
	hMietpreis,
	hPreis,
	hName[50],
	hKasse,
	hPickup,
	Text3D:hText
};
new HouseData[MAX_HOUSES][eHouse];

stock HouseOnGameModeInit()
{
	mysql_query("SELECT COUNT(`id`) FROM `house_interiors`");
	mysql_store_result();
	new jHI = mysql_fetch_int();
	mysql_free_result();
	
	for(new i = 0; i != jHI+1; i++)
	{
		new e[16];
		format(e, sizeof(e), "%d", i);
		houseIcon2[i] = CreatePickup(1272,1,mysql_GetFloat("house_interiors", "x", "id", e) ,mysql_GetFloat("house_interiors", "y", "id", e),mysql_GetFloat("house_interiors", "z", "id", e),-1); 
		//Create3DTextLabel("Ausgang",cHellblau,mysql_GetFloat("house_interiors", "x", "id", e) ,mysql_GetFloat("house_interiors", "y", "id", e),mysql_GetFloat("house_interiors", "z", "id", e),H_Distance,0);
	}
	
	new houseamount = 0;
	new i, result[200], hausname[50], ownID[64];
	mysql_query("SELECT `id`, `owner`, `target_int`, `status`, `x`, `y`, `z`, `int`, `world`,\n\
				`opened`, `heal`, `rental`, `price`, `name`, `cash` FROM `houses`;");
	mysql_store_result();
	while(mysql_fetch_row_format(result)) 
	{
		sscanf(result,"p<|>e<iiiifffiiiiiis[50]i>",HouseData[i]);
		houseamount++;
		i++;
	}
    mysql_free_result();
	
	for(new houseI = 0; houseI < houseamount; houseI++)
	{
		new preisstring[128];
		format(hausname, sizeof(hausname), "%s",HouseData[houseI][hName]);
		if(HouseData[houseI][hStatus] == 0)
		{
			HouseData[houseI][hPickup] = CreatePickup(1272, 1, HouseData[houseI][hX], HouseData[houseI][hY], HouseData[houseI][hZ], -1);
			format(preisstring, sizeof(preisstring), "Zu verkaufen! \nPreis: %d$\n[ENTER]", HouseData[houseI][hPreis]);
			HouseData[houseI][hText] = Create3DTextLabel(preisstring,cHellblau,HouseData[houseI][hX],HouseData[houseI][hY],HouseData[houseI][hZ],H_Distance,0);
		}
		if(HouseData[houseI][hStatus] == 1)
		{
			HouseData[houseI][hPickup] = CreatePickup(1272, 1, HouseData[houseI][hX], HouseData[houseI][hY], HouseData[houseI][hZ], -1);
			format(ownID, sizeof(ownID), "%d",HouseData[houseI][hOwnerID]);
			format(hausname, sizeof(hausname), "%s \nInhaber: %s \nMiete: %d$", HouseData[houseI][hName], mysql_GetString("accounts", "Name", "id", ownID), HouseData[houseI][hMietpreis]);
			HouseData[houseI][hText] = Create3DTextLabel(hausname,cHellblau,HouseData[houseI][hX],HouseData[houseI][hY],HouseData[houseI][hZ],H_Distance,0);
		}
		if(HouseData[houseI][hStatus] == 2)
		{
			HouseData[houseI][hPickup] = CreatePickup(1272, 1, HouseData[houseI][hX], HouseData[houseI][hY], HouseData[houseI][hZ], -1);
			format(ownID, sizeof(ownID), "%d",HouseData[houseI][hOwnerID]);
			format(hausname, sizeof(hausname), "%s \nInhaber: %s \nMiete: %d$", HouseData[houseI][hName], mysql_GetString("accounts", "Name", "id", ownID), HouseData[houseI][hMietpreis]);
			HouseData[houseI][hText] = Create3DTextLabel(hausname,cHellblau,HouseData[houseI][hX],HouseData[houseI][hY],HouseData[houseI][hZ],H_Distance,0);			
		}
	}
	
	printf("[START] Häuser geladen. [%d]", houseamount);
}


stock HouseOnGameModeExit()
{
	for(new i=0; i<sizeof(HouseData); i++)
	{
		if(HouseData[i][hPickup])
		{
			DestroyPickup(HouseData[i][hPickup]);
		}
		if(HouseData[i][hText])
		{
			Delete3DTextLabel(HouseData[i][hText]);
		}
	}
}


ocmd:house(playerid, params[])
{
	for(new i=0; i<sizeof(HouseData); i++)
	{
		if(!HouseData[i][hID])continue;
		if(IsPlayerInRangeOfPoint(playerid,H_enterdist,HouseData[i][hX], HouseData[i][hY], HouseData[i][hZ]))
		{
			if(GetPVarInt(playerid, "Eingeloggt") != 1)
			{
				echo(playerid, cRot, "Du bist nicht eingeloggt!");
				KickTimer(playerid, 100);
				return 1;
			}
			if(HouseData[i][hStatus] != 0)
			{
				if((HouseData[i][hOwnerID] == SpielerInfo[playerid][peID]) || isPlayerAnAdmin(playerid, 5))
				{
					PlayerInfo[playerid][WhereHouse] = i;
					ShowHouse(playerid, i);
				}
			}
		}
	}
	mysql_query("SELECT COUNT(`id`) FROM `house_interiors`");
	mysql_store_result();
	new jHA = mysql_fetch_int();
	mysql_free_result();
		
	for(new i = 0; i != jHA+1; i++)
	{
		new e[16];
		format(e, sizeof(e), "%d", i);	
		if(IsPlayerInRangeOfPoint(playerid,H_enterdist,mysql_GetFloat("house_interiors", "x", "id", e), mysql_GetFloat("house_interiors", "y", "id", e), mysql_GetFloat("house_interiors", "z", "id", e)))
		{
			new hi = GetPlayerVirtualWorld(playerid);
			if(HouseData[hi][hStatus] != 0)
			{
				if((HouseData[hi][hOwnerID] == SpielerInfo[playerid][peID]) || isPlayerAnAdmin(playerid, 5))
				{
					PlayerInfo[playerid][WhereHouse] = hi;
					ShowHouse(playerid, hi);
				}
			}
		}
	}
	return 1;
}

ocmd:haus(playerid, params[])
{
	#pragma unused params
	return ocmd_house(playerid, params);
}


ocmd:createhouse(playerid, params[])
{
	new int, Float:ax, Float:ay, Float:az, query[256], strName[50], amount;
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	if(sscanf(params,"ii",int, amount))return echo(playerid,cRot,"Benutzung: /createhouse [Int] [Preis]");
	if(int <= 0) return echo(playerid, cRot, "Du musst ein gültiges Interior setzen! [/getints]");
	if(amount < 0) return echo(playerid, cRot, "Du musst einen gültigen Preis setzen!");
	GetPlayerPos(playerid, ax, ay, az);
	new swag = GetPlayerInterior(playerid);
	format(strName, sizeof(strName), "-");
	
	
	new id = getFreeHouseID();
	HouseData[id][hID] = id;
	HouseData[id][hX] = ax;
	HouseData[id][hY] = ay;
	HouseData[id][hZ] = az;
	HouseData[id][hInt] = swag;
	HouseData[id][hInterior] = int;
	HouseData[id][hOpen] = 0;
	HouseData[id][hHeal] = 0;
	HouseData[id][hMietpreis] = 0;
	HouseData[id][hName] = strName;
	HouseData[id][hPreis] = amount;

	format(query, sizeof query, "INSERT INTO `houses` (`id`, `target_int`, `status`, `x`, `y`, `z`, `int`, `world`, `opened`, `price`) VALUES (%i, %i, %i, %i, %i, %i, %i, %i, %i, %i);",
														id,     int,           0,    ax,  ay,  az,  GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), 0, amount);
	mysql_query(query);

	printf("%s hat ein Haus erstellt. [ID %d]", SpielerName(playerid), id);
	UpdateHouse(id);
	return 1;
}

ocmd:deletehouse(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	
	for(new i=0; i<sizeof(HouseData); i++)
	{
	    if(!HouseData[i][hID])continue;
		if(!IsPlayerInRangeOfPoint(playerid, 2.5, HouseData[i][hX], HouseData[i][hY], HouseData[i][hZ]))continue;
		new query[128], strName[50];
		format(query,sizeof(query), "DELETE FROM `houses` WHERE `id` = %i LIMIT 1;", HouseData[i][hID]);
		mysql_query(query);
		
		format(strName, sizeof(strName), "-");
		
		HouseData[i][hStatus] = 0;
		HouseData[i][hOwnerID] = 0;
		HouseData[i][hX]=0.0;
		HouseData[i][hY]=0.0;
		HouseData[i][hZ]=0.0;
		HouseData[i][hInt] = 0;
		HouseData[i][hInterior] = 0;
		HouseData[i][hOpen] = 0;
		HouseData[i][hHeal] = 0;
		HouseData[i][hMietpreis] = 0;
		HouseData[i][hPreis] = 0;

	    DestroyPickup(HouseData[i][hPickup]);
		Delete3DTextLabel(HouseData[i][hText]);
		
		echo(playerid, cGruen, "[AdmCmd] Du hast das Haus erfolgreich gelöscht.");
		printf("--> %s hat das Haus mit der ID %d gelöscht.", SpielerName(playerid), i);
		return 1;
	}
	return 1;
}


ocmd:setint(playerid, params[])
{
	new amount;
	if(sscanf(params,"i",amount))return echo(playerid,cRot,"Benutzung: /setint [Interior]");
	for(new i=0; i<sizeof(HouseData); i++)
	{
	    if(!HouseData[i][hID])continue;
		new e[64];
		format(e, sizeof(e), "%d",HouseData[i][hID]);
		if(IsPlayerInRangeOfPoint(playerid,H_enterdist,HouseData[i][hX], HouseData[i][hY], HouseData[i][hZ]))
		{
			if(isPlayerAnAdmin(playerid, 5))
			{
				if(amount < 0) return 1;
				HouseData[i][hInterior] = amount;				
				mysql_UpdateInt("houses", "target_int", amount, "id", e);
				
				new strPlayer[128];
				format(strPlayer, sizeof(strPlayer), "[Haus] Du hast das Interior erfolgreich zu %d$ geändert.", amount);
				echo(playerid, cGruen, strPlayer);
				printf("[Haus] %s hat das Interior auf %d$ gesetzt.", SpielerName(playerid), amount);
				
				UpdateHouse(i);
			}
			else return echo(playerid, cRot, "Du bist kein Fulladmin.");
		}
	}
	return 1;
}

stock HouseOnPlayerKeyStateChange(playerid)
{
	new haveahouse = 0;
	for(new i=0; i<sizeof(HouseData); i++)
	{
		if(!HouseData[i][hID])continue;
		
		new idhomo[64];
		format(idhomo, sizeof(idhomo), "%d",HouseData[i][hInterior]);
		
		if(HouseData[i][hOwnerID] == SpielerInfo[playerid][peID])
		{
			haveahouse ++;
		}
		if(IsPlayerInRangeOfPoint(playerid,H_enterdist,HouseData[i][hX], HouseData[i][hY], HouseData[i][hZ]))
		{
			if(HouseData[i][hStatus] != 0)
			{
				if(!HouseData[i][hOpen])
				{
					//closed
					echo(playerid, cRot, "Das Haus ist verschlossen!");
				}
				else
				{
					SetPlayerPos(playerid, mysql_GetFloat("house_interiors", "x", "id", idhomo), mysql_GetFloat("house_interiors", "y", "id", idhomo), mysql_GetFloat("house_interiors", "z", "id", idhomo));
					SetPlayerInterior(playerid, mysql_GetInt("house_interiors", "int", "id", idhomo));
					SetPlayerVirtualWorld(playerid, i);
					printf("gotohausint: %f, %f, %f",mysql_GetFloat("house_interiors", "x", "id", idhomo), mysql_GetFloat("house_interiors", "y", "id", idhomo), mysql_GetFloat("house_interiors", "z", "id", idhomo)); 
					printf("gotohausint: %d, %d", mysql_GetInt("house_interiors", "int", "id", idhomo), i);
				}
			}
			else
			{
				//Haus kaufen (SPIELER)
				if(SpielerInfo[playerid][pGeld] >= HouseData[i][hPreis])
				{
					if(haveahouse > 0)
					{
						echo(playerid, cRot, "Du hast bereits ein Haus.");
						break;
					}
					new strPlayer[128], query[256];
					HouseData[i][hStatus] = 1;
					HouseData[i][hOwnerID] = SpielerInfo[playerid][peID];
					AGivePlayerMoney(playerid, -HouseData[i][hPreis]);
					format(strPlayer, sizeof(strPlayer), "Herzlichen Glueckwunsch! Du hast dir erfolgreich ein Haus für %d$ gekauft!", HouseData[i][hPreis]);
					echo(playerid, cRot, strPlayer);
					
					format(query, sizeof(query), "UPDATE `houses` SET `owner` = %i, `status` = %i, `name` = '%s' WHERE `id` = %i;", HouseData[i][hOwnerID], HouseData[i][hStatus], HouseData[i][hName], HouseData[i][hID]);
					mysql_query(query);
					UpdateHouse(i);
					
					printf("[Haus] %s hat sich das Haus mit der ID %d gekauft.", SpielerName(playerid), HouseData[i][hID]);
				}
				else
				{
					new strHaus[128];
					format(strHaus, sizeof(strHaus), "Du besitzt nicht genug Geld, um das Haus für %d$ zu kaufen.", HouseData[i][hPreis]);
					echo(playerid, cRot, strHaus);
				}
			}
		}
	}
	//Ausgang
	mysql_query("SELECT COUNT(`id`) FROM `house_interiors`");
	mysql_store_result();
	new jHA = mysql_fetch_int();
	mysql_free_result();
		
	for(new i = 0; i != jHA+1; i++)
	{
		new e[16];
		format(e, sizeof(e), "%d", i);	
		if(IsPlayerInRangeOfPoint(playerid,H_enterdist,mysql_GetFloat("house_interiors", "x", "id", e), mysql_GetFloat("house_interiors", "y", "id", e), mysql_GetFloat("house_interiors", "z", "id", e)))
		{
			new vw = GetPlayerVirtualWorld(playerid);
			SetPlayerPos(playerid, HouseData[vw][hX], HouseData[vw][hY], HouseData[vw][hZ]);
			SetPlayerInterior(playerid, HouseData[vw][hInt]);
			SetPlayerVirtualWorld(playerid, 0);
		}
	}
}

stock HouseOnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == diaHouse)
	{
		new i = PlayerInfo[playerid][WhereHouse];
		if(response == 1)
		{
			switch(listitem)
			{
				case 0:
				{
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Hausmenü - Kasse: %d$", HouseData[i][hKasse]);
					ShowDialog(playerid, diaHouseKasse, DIALOG_STYLE_LIST, strTitel, "Abheben \nEinzahlen", "Auswählen", "Abbrechen");
				}
				case 1:
				{
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Hausmenü - Name: %s", HouseData[i][hName]);
					ShowDialog(playerid, diaHouseName, DIALOG_STYLE_INPUT, strTitel, "Bitte gib einen neuen Namen ein:", "Ändern", "Abbrechen");
				}
				case 2:
				{
					new strInhalt[128];
					format(strInhalt, sizeof(strInhalt), "Interior: %d", HouseData[i][hInterior]);
					ShowDialog(playerid, diaHouseInfos, DIALOG_STYLE_MSGBOX, "Hausmenü - Infos", strInhalt, "Fertig", "");
				}
				case 3:
				{
					new strTitel[128];
					format(strTitel, sizeof(strTitel), "Hausmenü - Mietpreis: %d$", HouseData[i][hMietpreis]);
					ShowDialog(playerid, diaHouseMiete, DIALOG_STYLE_INPUT, strTitel, "Bitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				}
				case 4:
				{
					if(HouseData[i][hOpen] == 0)
					{
						HouseData[i][hOpen] = 1;
						ShowHouse(playerid, i);
						return 1;
					}
					if(HouseData[i][hOpen] == 1)
					{
						HouseData[i][hOpen] = 0;
						ShowHouse(playerid, i);
						return 1;
					}
				}
				case 6:
				{
					ShowDialog(playerid, diaHouseSell, DIALOG_STYLE_MSGBOX, "Hausmenü - Verkaufen", "Möchtest du dein Haus wirklich verkaufen?", "Verkaufen", "Abbrechen");
				}
			}
		}
	}
	if(dialogid == diaHouseKasse)
	{
		if(response == 1)
		{
			switch(listitem)
			{
				case 0:
				{
					ShowDialog(playerid, diaHouseKasseOut, DIALOG_STYLE_INPUT, "Hausmenü - Auszahlen", "Bitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
				}
				case 1:
				{
					ShowDialog(playerid, diaHouseKasseIn, DIALOG_STYLE_INPUT, "Hausmenü - Einzahlen", "Bitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
				}
			}
		}
	}
	if(dialogid == diaHouseKasseOut)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereHouse];
			new e[8], swag;
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount)) return ShowDialog(playerid, diaBizKasseOut, DIALOG_STYLE_INPUT, "BIZMENÜ - Auszahlen", "Ungültige Eingabe\nBitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
			if(amount < 1) return ShowDialog(playerid, diaHouseKasseOut, DIALOG_STYLE_INPUT, "Hausmenü - Auszahlen", "Ungültige Eingabe\nBitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
			if(amount > HouseData[i][hKasse])return ShowDialog(playerid, diaHouseKasseOut, DIALOG_STYLE_INPUT, "Hausmenü - Auszahlen", "Ungültige Eingabe\nBitte gib die Summe zum Auszahlen ein:", "Abheben", "Abbrechen");
			swag = HouseData[i][hKasse]-amount;
			HouseData[i][hKasse] = swag;
			mysql_UpdateInt("houses", "cash", swag, "id", e);
			AGivePlayerMoney(playerid, amount);
			ShowHouse(playerid, i);
		}
	}
	if(dialogid == diaHouseKasseIn)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereHouse];
			new e[8], swag;
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount)) return ShowDialog(playerid, diaHouseKasseIn, DIALOG_STYLE_INPUT, "Hausmenü - Einzahlen", "Ungültige Eingabe\nBitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
			if(amount < 1) return ShowDialog(playerid, diaHouseKasseIn, DIALOG_STYLE_INPUT, "Hausmenü - Einzahlen", "Ungültige Eingabe\nBitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
			if(amount > SpielerInfo[playerid][pGeld])return ShowDialog(playerid, diaHouseKasseIn, DIALOG_STYLE_INPUT, "Hausmenü - Einzahlen", "Ungültige Eingabe\nBitte gib die Summe zum Einzahlen ein:", "Einzahlen", "Abbrechen");
			swag = HouseData[i][hKasse]+amount;
			HouseData[i][hKasse] = swag;
			
			HouseData[i][hKasse] = swag;
			mysql_UpdateInt("houses", "cash", swag, "id", e);
			AGivePlayerMoney(playerid, -amount);
			ShowHouse(playerid, i);
		}
	}
	if(dialogid == diaHouseMiete)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereHouse];
			new e[8];
			format(e, sizeof(e), "%d", i+1);
			new amount;
			if(sscanf(inputtext, "i", amount))
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Hausmenü - Mietpreis: %d$", HouseData[i][hMietpreis]);
				ShowDialog(playerid, diaHouseMiete, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				return 1;
			}
			if(amount < 1)
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Hausmenü - Mietpreis: %d$", HouseData[i][hMietpreis]);
				ShowDialog(playerid, diaHouseMiete, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Preis ein:", "Ändern", "Abbrechen");
				return 1;
			}
			HouseData[i][hMietpreis] = amount;
			mysql_UpdateInt("houses", "rental", amount, "id", e);
			UpdateHouse(i);
			ShowHouse(playerid, i);
		}
	}
	if(dialogid == diaHouseSell)
	{
		new i = PlayerInfo[playerid][WhereHouse];
		if(response == 1)
		{
			new e[8], strMoney[128];
			format(e, sizeof(e), "%d", i+1);
			HouseData[i][hOwnerID] = 0;
			HouseData[i][hStatus] = 0;
			mysql_UpdateInt("houses", "owner", 0, "id", e);
			mysql_UpdateInt("houses", "status", 0, "id", e);
			
			format(strMoney, sizeof(strMoney), "Du hast dein Haus verkauft und %d$ erhalten.", HouseData[i][hPreis]);
			AGivePlayerMoney(playerid, HouseData[i][hPreis]);
			echo(playerid, cGruen, strMoney);
			UpdateHouse(i);
		}
	}
	if(dialogid == diaHouseName)
	{
		if(response == 1)
		{
			new i = PlayerInfo[playerid][WhereHouse];
			new e[8];
			format(e, sizeof(e), "%d", i+1);
			new text[50];
			if(sscanf(inputtext, "s[50]", text))
			{
				new strTitel[128];
				format(strTitel, sizeof(strTitel), "Hausmenü - Name: %s", HouseData[i][hName]);
				ShowDialog(playerid, diaHouseName, DIALOG_STYLE_INPUT, strTitel, "Ungültige Eingabe\nBitte gib einen neuen Namen ein:", "Ändern", "Abbrechen");
				return 1;
			}
			HouseData[i][hName] = text;
			mysql_UpdateString("houses", "name", text, "id", e);
			UpdateHouse(i);
			ShowHouse(playerid, i);
		}
	}
	//INTERIORS
	if(dialogid == diaInts)
	{
		if(response == 1)
		{
			//listitem
			new idhomo[16], strPlayer[128];
			format(idhomo, sizeof(idhomo), "%d", listitem+1);
				
			SetPlayerPos(playerid, mysql_GetFloat("house_interiors", "x", "id", idhomo), mysql_GetFloat("house_interiors", "y", "id", idhomo), mysql_GetFloat("house_interiors", "z", "id", idhomo));
			SetPlayerInterior(playerid, mysql_GetInt("house_interiors", "int", "id", idhomo));
			
			format(strPlayer, sizeof(strPlayer), "Du hast dich erfolgreich in Interior %d geportet.", listitem+1);
			admcmd(playerid, cRot, strPlayer);
		}
	}
	return 1;
}

stock ShowHouse(playerid, i)
{
	new hausname[128], hausinhalt[512], strOpen[16];
	if(HouseData[i][hOpen] == 0)
	{
		strOpen = "Nein";
	}
	if(HouseData[i][hOpen] == 1)
	{
		strOpen = "Ja";
	}
	format(hausname, sizeof(hausname), "Hausmenü: [%s]", HouseData[i][hName]);
	format(hausinhalt, sizeof(hausinhalt), "Kasse: %d$ \nName: %s \nInformationen \nMietpreis: %d$ \nGeöffnet: %s \n \nVerkaufen", HouseData[i][hKasse], HouseData[i][hName], HouseData[i][hMietpreis], strOpen);
	ShowDialog(playerid, diaHouse, DIALOG_STYLE_LIST, hausname, hausinhalt, "Auswählen", "Fertig");
}

stock getFreeHouseID()
{
	for(new i=0; i<sizeof(HouseData); i++)
	{
	    if(HouseData[i][hID]==0)return i;
	}
	return 0;
}

stock UpdateHouse(id)
{
    new ownID[16], hausname[128], preisstring[128];
	if(HouseData[id][hPickup])
    {
		DestroyPickup(HouseData[id][hPickup]);
	}
	if(HouseData[id][hText])
    {
		Delete3DTextLabel(HouseData[id][hText]);
	}
	
	HouseData[id][hPickup] = CreatePickup(1272, 1, HouseData[id][hX], HouseData[id][hY], HouseData[id][hZ], -1);
	if(HouseData[id][hStatus] == 0)
	{
		format(preisstring, sizeof(preisstring), "Zu verkaufen! \nPreis: %d$\n[ENTER]", HouseData[id][hPreis]);
		HouseData[id][hText] = Create3DTextLabel(preisstring,cHellblau,HouseData[id][hX],HouseData[id][hY],HouseData[id][hZ],H_Distance,0);
	}
	if(HouseData[id][hStatus] == 1)
	{
		format(ownID, sizeof(ownID), "%d",HouseData[id][hOwnerID]);
		format(hausname, sizeof(hausname), "%s \nInhaber: %s \nMiete: %d$", HouseData[id][hName], mysql_GetString("accounts", "name", "id", ownID), HouseData[id][hMietpreis]);
		HouseData[id][hText] = Create3DTextLabel(hausname,cHellblau,HouseData[id][hX],HouseData[id][hY],HouseData[id][hZ],H_Distance,0);
	}
	if(HouseData[id][hStatus] == 2)
	{
		format(ownID, sizeof(ownID), "%d",HouseData[id][hOwnerID]);
		format(hausname, sizeof(hausname), "%s \nInhaber: %s \nMiete: %d$", HouseData[id][hName], mysql_GetString("accounts", "name", "id", ownID), HouseData[id][hMietpreis]);
		HouseData[id][hText] = Create3DTextLabel(hausname,cHellblau,HouseData[id][hX],HouseData[id][hY],HouseData[id][hZ],H_Distance,0);
	}
	return 1;
}

ocmd:getints(playerid, params[])
{
	new strDialog[256];
	mysql_query("SELECT COUNT(`id`) FROM `house_interiors`");
	mysql_store_result();
	new jHI = mysql_fetch_int();
	mysql_free_result();
	
	for(new i = 1; i != jHI+1; i++)
	{
		new e[16];
		format(e, sizeof(e), "%d", i);
		{
			format(strDialog, sizeof(strDialog), "%s ID: %d - %s\n", strDialog, i, mysql_GetString("house_interiors", "comment", "id", e));
		}
		ShowDialog(playerid, diaInts, DIALOG_STYLE_LIST, "Liste der Interiors", strDialog, "Teleportieren", "Okay");
	}
	return 1;
}