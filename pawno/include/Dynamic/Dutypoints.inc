#define MAX_DUTYPOINTS 20
#define DP_Distance 5.0

enum eDutypoints{
	dpID,
	Float:dpX,
	Float:dpY,
	Float:dpZ,
	dpInt,
	dpWorld,
	dpGroup,
	dpFaction
}

new dpamount = 0;

new DutypointData[MAX_DUTYPOINTS][eDutypoints];

stock DutypointsOnGameModeInit()
{
	new dpi, dpresult[200];
	mysql_query("SELECT `id`, `x`, `y`, `z`, `int`, `world`, `group`, `faction` FROM `dutypoints`;");
	mysql_store_result();
	while(mysql_fetch_row_format(dpresult)) 
	{
		sscanf(dpresult,"p<|>e<ifffiiii>",DutypointData[dpi]);
		dpamount++;
		dpi++;
	}
    mysql_free_result();
	
	for(new dpI = 0; dpI < dpamount; dpI++)
	{
		if(DutypointData[dpI][dpID] > 0)
		{
			CreatePickup(1239, 1, DutypointData[dpI][dpX], DutypointData[dpI][dpY], DutypointData[dpI][dpZ], -1); 
			CreateDynamic3DTextLabel("Benutzung: /duty", cEnter, DutypointData[dpI][dpX], DutypointData[dpI][dpY], DutypointData[dpI][dpZ], DP_Distance);
		}
	}
	
	printf("[START] Dutypoints geladen. [%d]", dpamount);
}


ocmd:duty(playerid, params[])
{
	new strDutyGone[150], strDutyLeft[128];
	for(new i = 0; i < dpamount; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 5.0, DutypointData[i][dpX], DutypointData[i][dpY], DutypointData[i][dpZ]))
		{
			if(SpielerInfo[playerid][pFraktion] == DutypointData[i][dpFaction])
			{
				if(SpielerInfo[playerid][pDuty] == 0)
				{
					SetPlayerArmour(playerid, 100);
					GivePlayerWeapon(playerid, 3, 1);
					GivePlayerWeapon(playerid, 41, 200);
					format(strDutyGone, sizeof(strDutyGone), "* %s holt seine Dienstmarke aus dem Schrank und begibt sich in den Dienst.", SpielerName(playerid));
					SendClientMessageInRange(playerid, strDutyGone, cLila, 20);
					SpielerInfo[playerid][pDuty] = 1;
					return 1;
				}
				else
				{
					SetPlayerArmour(playerid, 0);
					ResetPlayerWeapons(playerid);
					format(strDutyLeft, sizeof(strDutyLeft), "* %s legt seine Dienstmarke in den Schrank und begibt sich außer Dienst.", SpielerName(playerid));
					SendClientMessageInRange(playerid, strDutyLeft, cLila, 20);
					SpielerInfo[playerid][pDuty] = 0;
					return 1;
				}
			}
			if(SpielerInfo[playerid][pGruppierung] == 1 && DutypointData[i][dpGroup] == 1)
			{
				if(SpielerInfo[playerid][pDuty] == 0)
				{
					GivePlayerWeapon(playerid, 34, 50);
					format(strDutyGone, sizeof(strDutyGone), "* %s holt seine Maske aus dem Schrank, zieht die Handschuhe an und beginnt seine Arbeit.", SpielerName(playerid));
					SendClientMessageInRange(playerid, strDutyGone, cLila, 20);
					SpielerInfo[playerid][pDuty] = 1;
					return 1;
				}
				else
				{
					if(SpielerInfo[playerid][pMask] == 0)
					{
						for(new mi = 0; mi < MAX_PLAYERS; mi++)
						{
							ShowPlayerNameTagForPlayer(mi, playerid, 1); 
						}
						SpielerInfo[playerid][pMask] = 0;
						echo(playerid, cGruppe, "[Hitman Agency] Du hast deine Maske abgezogen.");
					}
					SetPlayerArmour(playerid, 0);
					ResetPlayerWeapons(playerid);
					format(strDutyLeft, sizeof(strDutyLeft), "* %s legt seine Maske in den Schrank, zieht die Handschuhe aus und beendet seine Arbeit.", SpielerName(playerid));
					SendClientMessageInRange(playerid, strDutyLeft, cLila, 20);
					SpielerInfo[playerid][pDuty] = 0;
				}
			}
		}
	}
	return 1;
}