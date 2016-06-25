
#define MAX_GFSTAND 10

#define MAX_GANGZONES 10
#define GZ_SeeDistance 15.0
#define GZ_DoDistance 5.0

#define FLAG_TIME 360
#define GANGFIGHT_POINTS 5

#define FightFlagge (2993) //PickupID

new arrFlagtyp[3];

enum eGangzones{
	gID,
	gOwnerID,
	gZonename[50],
	Float:gMinX,
	Float:gMinY,
	Float:gMaxX,
	Float:gMaxY,
	Float:gFlagX,
	Float:gFlagY,
	Float:gFlagZ,
	gGangwarStarted,
	gVerteidigerStand,
	gAngreiferStand,
	Text3D:GfFlaggenText
};
new GangzoneData[MAX_GANGZONES][eGangzones],
	GangZone[MAX_GANGZONES],
	GangZoneArea[MAX_GANGZONES],
	GfFlagge[MAX_GANGZONES];

	new Text:GFStandBox,
	Text:GFStandText;
	
stock GangzoneOnGameModeInit()
{
	new gI, result[200];
	mysql_query("SELECT `id`, `owner`, `name`, `min_x`, `min_y`, `max_x`, `max_y`, `flag_x`, `flag_y`, `flag_z` FROM `gangzones`;"); 
	mysql_store_result();
	while(mysql_fetch_row_format(result)) 
	{
		sscanf(result,"p<|>e<iis[50]fffffff>",GangzoneData[gI]);
		//print(result);
		if(GangzoneData[gI][gID] > 0)
		{
			GangZone[gI] = GangZoneCreate(GangzoneData[gI][gMinX], GangzoneData[gI][gMinY], GangzoneData[gI][gMaxX], GangzoneData[gI][gMaxY]);
			GangZoneArea[gI] = CreateDynamicRectangle(GangzoneData[gI][gMinX], GangzoneData[gI][gMinY], GangzoneData[gI][gMaxX], GangzoneData[gI][gMaxY]);
			
			GfFlagge[gI] = CreatePickup(2993, 1, GangzoneData[gI][gFlagX], GangzoneData[gI][gFlagY] , GangzoneData[gI][gFlagZ], -1);
			
			//printf("%d", gI);
		}
		gI++;
	}
    mysql_free_result();
	
	
	new strFlagText[128];
	for(new gzi; gzi < gI; gzi++)
	{
		if(GangzoneData[gzi][gID] > 0)
		{
			format(strFlagText, sizeof(strFlagText), "%s [%d] \nBesitzer: %s", GangzoneData[gzi][gZonename], gzi, Gruppierungname(GangzoneData[gzi][gOwnerID]));
			GangzoneData[gzi][GfFlaggenText] = Create3DTextLabel(strFlagText, cFlagge, GangzoneData[gzi][gFlagX], GangzoneData[gzi][gFlagY] , GangzoneData[gzi][gFlagZ], GZ_SeeDistance, 0);
		}
	}
	
	printf("[START] Gangzonen geladen. [%d]", gI);
}


stock GangfightOnPlayerDisconnect(playerid)
{
	if(arrFlagtyp[0] == playerid)
	{
		new wheregf;
		for(new i; i < MAX_GANGZONES; i++)
		{
			if(GangzoneData[i][gGangwarStarted] > 0)
			{
				wheregf = i;
			}
		}
		arrFlagtyp[0] = -1;
		arrFlagtyp[1] = 0;
		GfFlagge[wheregf] = CreatePickup(2993, 1, GangzoneData[wheregf][gFlagX], GangzoneData[wheregf][gFlagY] , GangzoneData[wheregf][gFlagZ], -1);
		new strDeathMsg[128];
		format(strDeathMsg, sizeof(strDeathMsg), "[Gangfight] %s hat das Spiel beendet. Die Flagge ist nun wieder an ihrem Platz.", SpielerName(playerid));
		echoGangfight(strDeathMsg);
		KillTimer(arrFlagtyp[2]);
	}
}

stock GangfightOnPlayerPickUpPickup(playerid, pickupid)
{
	//Gf Flagge
	for(new i; i<sizeof(GfFlagge);i++)
	{
		if(GfFlagge[i] == pickupid)
		
		{
			if(GangzoneData[i][gGangwarStarted] > 0)
			{
				arrFlagtyp[0] = playerid;
				arrFlagtyp[1] = 0; //Zeit
				DestroyPickup(pickupid);
				new strFlagMsg[128];
				format(strFlagMsg, sizeof(strFlagMsg), "[Gangfight] %s hat die Flagge aufgehoben.", SpielerName(playerid));
				echoGangfight(strFlagMsg);
				arrFlagtyp[2] = SetTimer("updateFlag", 1000, true);
			}
		}
	}	
}


stock GangfightOnPlayerDeath(playerid, killerid)
{
	new Float:Koords[3];
	GetPlayerPos(playerid, Koords[0], Koords[1], Koords[2]);
	if(arrFlagtyp[0] == playerid)
	{
		new wheregf;
		for(new i; i < MAX_GANGZONES; i++)
		{
			if(GangzoneData[i][gGangwarStarted] > 0)
			{
				wheregf = i;
			}
		}
		arrFlagtyp[0] = -1;
		arrFlagtyp[1] = 0;
		GfFlagge[wheregf] = CreatePickup(2993, 1, Koords[0], Koords[1], Koords[2], -1);
		new strDeathMsg[128];
		format(strDeathMsg, sizeof(strDeathMsg), "[Gangfight] %s hat die Flagge fallen gelassen.", SpielerName(playerid));
		echoGangfight(strDeathMsg);
		KillTimer(arrFlagtyp[2]);
	}
	new wheregf;
	for(new i; i < MAX_GANGZONES; i++)
	{
		if(GangzoneData[i][gGangwarStarted] > 0)
		{
			wheregf = i;
		}
	}
	if(GangzoneData[wheregf][gGangwarStarted] > 0 && PlayerInfo[killerid][WhereArea] > 0)
	{
		if(SpielerInfo[killerid][pGruppierung] == SpielerInfo[playerid][pGruppierung] && GangzoneData[wheregf][gGangwarStarted] == SpielerInfo[killerid][pGruppierung])
		{
			echo(playerid, cRot, "[Gangfight] Ein Teamkamerad hat dich getötet! Rede mal ein Wörtchen mit ihm ;)");
			echo(killerid, cRot, "[Gangfight] Du hast einen Teamkameraden getötet!");
			return 1;
		}
		if(GangzoneData[wheregf][gGangwarStarted] == SpielerInfo[killerid][pGruppierung] && GangzoneData[wheregf][gOwnerID] == SpielerInfo[playerid][pGruppierung])
		{
			//Angreifer
			GameTextForPlayer(killerid,"~y~Glueckwunsch,~n~~g~Gangfightkill!",2200,6);
			GangzoneData[wheregf][gAngreiferStand] ++;
			if(GangzoneData[wheregf][gAngreiferStand] >= MAX_GFSTAND)
			{
				GFEnd(SpielerInfo[killerid][pGruppierung]);
				return 1;
			}
			new strEvent[128];
			format(strEvent, sizeof(strEvent), "[Gangfight]%s hat %s getötet! Neuer Punktestand: [%s %d - %d %s]", SpielerName(killerid), SpielerName(playerid), Gruppierungname(GangzoneData[wheregf][gGangwarStarted]), GangzoneData[wheregf][gAngreiferStand], GangzoneData[wheregf][gVerteidigerStand], Gruppierungname(GangzoneData[wheregf][gOwnerID]));
			echoGangfight(strEvent);
			UpdateGFStand();
			return 1;
		}
		if(GangzoneData[wheregf][gOwnerID] == SpielerInfo[killerid][pGruppierung] && GangzoneData[wheregf][gGangwarStarted] == SpielerInfo[playerid][pGruppierung])
		{
			//Verteidiger
			GameTextForPlayer(killerid,"~y~Glückwunsch,~n~~g~Gangfightkill!",2200,6);
			GangzoneData[wheregf][gVerteidigerStand] ++;
			if(GangzoneData[wheregf][gVerteidigerStand] >= MAX_GFSTAND)
			{
				GFEnd(SpielerInfo[killerid][pGruppierung]);
				return 1;
			}
			new strEvent[128];
			format(strEvent, sizeof(strEvent), "[Gangfight]%s hat %s getötet! Neuer Punktestand: [%s %d - %d %s]", SpielerName(killerid), SpielerName(playerid), Gruppierungname(GangzoneData[wheregf][gGangwarStarted]), GangzoneData[wheregf][gAngreiferStand], GangzoneData[wheregf][gVerteidigerStand], Gruppierungname(GangzoneData[wheregf][gOwnerID]));
			echoGangfight(strEvent);
			UpdateGFStand();
			return 1;
		}
	}
	return 1;
}


forward updateFlag();
public updateFlag()
{
	arrFlagtyp[1] ++;
	if(arrFlagtyp[1] >= FLAG_TIME)
	{
		new wheregf;
		for(new i; i < MAX_GANGZONES; i++)
		{
			if(GangzoneData[i][gGangwarStarted] > 0)
			{
				wheregf = i;
			}
		}
		KillTimer(arrFlagtyp[2]);
		arrFlagtyp[1] = 0;
		GfFlagge[wheregf] = CreatePickup(2993, 1, GangzoneData[wheregf][gFlagX], GangzoneData[wheregf][gFlagY] , GangzoneData[wheregf][gFlagZ], -1);
		new strDeathMsg[128];
		format(strDeathMsg, sizeof(strDeathMsg), "[Gangfight] %s und seine Gang haben die Flagge erfolgreich verteidigt! Neuer Punktestand: [%s %d - %d %s]", SpielerName(arrFlagtyp[0]), Gruppierungname(GangzoneData[wheregf][gGangwarStarted]), GangzoneData[wheregf][gAngreiferStand], GangzoneData[wheregf][gVerteidigerStand], Gruppierungname(GangzoneData[wheregf][gOwnerID]));
		echoGangfight(strDeathMsg);
		
		if(GangzoneData[wheregf][gGangwarStarted] == SpielerInfo[arrFlagtyp[0]][pGruppierung])
		{
			GangzoneData[wheregf][gAngreiferStand] += GANGFIGHT_POINTS;
			if(GangzoneData[wheregf][gAngreiferStand] >= MAX_GFSTAND)
			{
				GFEnd(GangzoneData[wheregf][gGangwarStarted]);
				return 1;
			}
		}
		if(GangzoneData[wheregf][gOwnerID] == SpielerInfo[arrFlagtyp[0]][pGruppierung])
		{
			GangzoneData[wheregf][gVerteidigerStand] += GANGFIGHT_POINTS;
			if(GangzoneData[wheregf][gVerteidigerStand] >= MAX_GFSTAND)
			{
				GFEnd(GangzoneData[wheregf][gOwnerID]);
				return 1;
			}
		}
		UpdateGFStand();	
		
		arrFlagtyp[0] = 0;
		arrFlagtyp[0] = -1;
	}
	return 1;
}

stock GangfightWillkommen(playerid)
{
	ShowGangzones(playerid);
}

stock GangfightOnEnterDynamicArea(playerid, areaid)
{
	PlayerInfo[playerid][WhereArea] = areaid;
	PlayerInfo[playerid][WhereGArray] = areaid-1;
	
	if(GangzoneData[areaid-1][gGangwarStarted] > 0)
	{
		ShowInfobar(playerid, "~r~Gangfight");
	}
	return 1;
}

forward UpdateGFStand();

public UpdateGFStand()
{
	print("updategfstand");
	new areaid;
	for(new i; i < MAX_GANGZONES; i++)
	{
		if(GangzoneData[i][gGangwarStarted] > 0)
		{
			areaid = i;
			break;
		}
	}
	new strStand[128];
	format(strStand, sizeof strStand, "~r~Angreifer   ~w~%d  -  %d~b~   Verteidiger", GangzoneData[areaid][gAngreiferStand], GangzoneData[areaid][gVerteidigerStand]);
	TextDrawSetString(GFStandText, strStand);
	return 1;
}

stock ShowGFStand(playerid)
{
	if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid))
	{
		TextDrawShowForPlayer(playerid, GFStandBox);
		TextDrawShowForPlayer(playerid, GFStandText);
	}
	return 1;
}

stock HideGFStand(playerid)
{
	TextDrawHideForPlayer(playerid, GFStandBox);
	TextDrawHideForPlayer(playerid, GFStandText);
	return 1;
}


stock GangfightOnLeaveDynamicArea(playerid)
{
	PlayerInfo[playerid][WhereArea] = 0;
	PlayerInfo[playerid][WhereGArray] = -1;
	HideInfobar(playerid);
	if(arrFlagtyp[0] == playerid)
	{
		new wheregf;
		for(new i; i < MAX_GANGZONES; i++)
		{
			if(GangzoneData[i][gGangwarStarted] > 0)
			{
				wheregf = i;
			}
		}
		arrFlagtyp[0] = -1;
		arrFlagtyp[1] = 0;
		GfFlagge[wheregf] = CreatePickup(2993, 1, GangzoneData[wheregf][gFlagX], GangzoneData[wheregf][gFlagY] , GangzoneData[wheregf][gFlagZ], -1);
		new strDeathMsg[128];
		format(strDeathMsg, sizeof(strDeathMsg), "[Gangfight] %s hat das Gebiet verlassen. Die Flagge ist nun wieder an ihrem Platz.", SpielerName(playerid));
		echoGangfight(strDeathMsg);
		KillTimer(arrFlagtyp[2]);
	}
	return 1;
}

ocmd:gangfight(playerid, params[])
{
	new gwstarted;
	gwstarted = 0;
	new gegneramount;
	gegneramount = 0;
	if(PlayerInfo[playerid][WhereArea] == 0) return echo(playerid, cRot, "Du bist in keinem Gebiet!");
	if(SpielerInfo[playerid][pGLeader] != 1) return echo(playerid, cRot, "Du bist kein Leader!");
	if(!isPlayerInGang(playerid)) return echo(playerid, cRot, "Du bist kein Mitglied einer Gang");
	if(PlayerInfo[playerid][WhereGArray] >= 0 && SpielerInfo[playerid][pGruppierung] == GangzoneData[PlayerInfo[playerid][WhereGArray]][gOwnerID]) return echo(playerid, cRot, "Das Gebiet gehört euch doch schon!");
	if(PlayerInfo[playerid][WhereGArray] >= 0 && !IsPlayerInRangeOfPoint(playerid, GZ_DoDistance, GangzoneData[PlayerInfo[playerid][WhereGArray]][gFlagX], GangzoneData[PlayerInfo[playerid][WhereGArray]][gFlagY], GangzoneData[PlayerInfo[playerid][WhereGArray]][gFlagZ])) return echo(playerid, cRot, "Du bist nicht bei der Flagge.");
	for(new i; i < MAX_GANGZONES; i++)
	{
		if(GangzoneData[i][gGangwarStarted] > 0)
		{
			gwstarted = 1;
			break;
		}
	}
	if(gwstarted == 1)
	{
		echo(playerid, cRot, "Es läuft bereits ein Gangfight.");
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pGruppierung] == GangzoneData[PlayerInfo[playerid][WhereGArray]][gOwnerID])
		{
			gegneramount ++;
		}
	}
	if(gegneramount < 0) return echo(playerid, cRot, "Es sind weniger als zwei Gegner online. Du kannst keinen Gangfight starten.");
	else if(PlayerInfo[playerid][WhereGArray] >= 0)
	{
		GangzoneData[PlayerInfo[playerid][WhereGArray]][gGangwarStarted] = SpielerInfo[playerid][pGruppierung];
		GangZoneFlashForAll(GangZone[PlayerInfo[playerid][WhereGArray]], GetZoneColor(SpielerInfo[playerid][pGruppierung]));
		GangzoneData[PlayerInfo[playerid][WhereGArray]][gVerteidigerStand] = 0;
		GangzoneData[PlayerInfo[playerid][WhereGArray]][gAngreiferStand] = 0;
		
		SendClientMessageToAll(cBlau, "======{ffffff} Gangfight {224aff}======");
		new strAngreifer[50], strVerteidiger[50], strGangfightID[50];
		format(strAngreifer, sizeof strAngreifer, "Angreifer: %s", Gruppierungname(SpielerInfo[playerid][pGruppierung]));
		SendClientMessageToAll(cWeiss, strAngreifer);
		format(strVerteidiger, sizeof strVerteidiger, "Verteidiger: %s", Gruppierungname(GangzoneData[PlayerInfo[playerid][WhereGArray]][gOwnerID]));
		SendClientMessageToAll(cWeiss, strVerteidiger);
		format(strGangfightID, sizeof strGangfightID, "Gangzone: %s [%d]", GangzoneData[PlayerInfo[playerid][WhereGArray]][gZonename], PlayerInfo[playerid][WhereGArray]);
		SendClientMessageToAll(cWeiss, strGangfightID);
		SendClientMessageToAll(cBlau, "=====================");
		
		UpdateGFStand();
		ShowGFStand(playerid);
		ShowInfobar(playerid, "~r~Gangwar");
		
		for(new i; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && !IsPlayerNPC(i))
			{
				if(SpielerInfo[i][pGruppierung] == GangzoneData[PlayerInfo[i][WhereGArray]][gGangwarStarted] ||	SpielerInfo[i][pGruppierung] == GangzoneData[PlayerInfo[i][WhereGArray]][gOwnerID])
				{
					ShowGFStand(i);
					if(IsPlayerInDynamicArea(i, PlayerInfo[i][WhereArea]))
					{
						ShowInfobar(i, "~r~Gangwar");
					}
				}
			}
		}
	}
	return 1;
}


stock GFEnd(winner)
{
	new areaid;
	for(new i; i < MAX_GANGZONES; i++)
	{
		if(GangzoneData[i][gGangwarStarted] > 0)
		{
			areaid = i;
			break;
		}
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			HideGFStand(i);
		}
	}
	
	SendClientMessageToAll(cBlau, "======{ffffff} Gangfight beendet{224aff}======");
	new strAngreifer[50], strGangfightID[50];
	format(strAngreifer, sizeof strAngreifer, "Sieger: %s", Gruppierungname(winner));
	SendClientMessageToAll(cWeiss, strAngreifer);
	format(strGangfightID, sizeof strGangfightID, "Gangzone: %s [%d]", GangzoneData[areaid][gZonename], areaid);
	SendClientMessageToAll(cWeiss, strGangfightID);
	SendClientMessageToAll(cBlau, "===============================");
	
	GangzoneData[areaid][gOwnerID] = winner;
	GangzoneData[areaid][gGangwarStarted] = 0;
	GangzoneData[areaid][gAngreiferStand] = 0;
	GangzoneData[areaid][gVerteidigerStand] = 0;
	GangZoneStopFlashForAll(areaid);
	GangZoneHideForAll(areaid);
	GangZoneShowForAll(areaid, GetZoneColor(winner));
	
	new strFlagText[128];
	format(strFlagText, sizeof(strFlagText), "%s [%d] \nBesitzer: %s", GangzoneData[areaid][gZonename], areaid, Gruppierungname(GangzoneData[areaid][gOwnerID]));
	Update3DTextLabelText(GangzoneData[areaid][GfFlaggenText], cFlagge, strFlagText);
	
	new strID[8];
	valstr(strID, areaid+1);
	mysql_UpdateInt("gangzones", "owner", winner, "id", strID);
}

stock ShowGangzones(playerid)
{
	for(new i = 0; i < sizeof GangzoneData; i++)
	{
		if(GangzoneData[i][gID] > 0)
		{
			GangZoneShowForPlayer(playerid, GangZone[i], GetZoneColor(GangzoneData[i][gOwnerID]));
		}
	}
	return 1;
}

stock GetZoneColor(id)
{
        if(id == 2) return 0x00000095; 
        else if(id == 3) return 0x9D9D9D95; 
        else if(id == 4) return 0x00800095; 
        else if(id == 5) return 0x80008095; 
        else if(id == 6) return 0xFF000095; 
        else if(id == 7) return 0xFFFF0095; 
        else if(id == 8) return 0x0080FF95; 
        else return 0x0000E196; 
}