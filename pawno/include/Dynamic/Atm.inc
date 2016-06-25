#define MAX_ATMS 30
#define ATM_Dist 1.25

new atmamount = 0;

enum eATMs{
	a_id,
	Float:a_x,
	Float:a_y,
	Float:a_z,
	Float:a_rx,
	Float:a_ry,
	Float:a_rz,
	a_comment[50]
}

new AtmData[MAX_ATMS][eATMs];
new AtmObj[MAX_ATMS];

stock AtmOnGameModeInit()
{
	new atmi, atm_result[200];
	mysql_query("SELECT `id`, `a_x`, `a_y`, `a_z`, `a_rx`, `a_ry`, `a_rz` FROM `atm`;");
	mysql_store_result();
	while(mysql_fetch_row_format(atm_result)) 
	{
		sscanf(atm_result,"p<|>e<iffffff>",AtmData[atmi]);
		atmi++;
	}
	mysql_free_result();
	for(new ai = 0; ai < atmi; ai++)
	{
		if(AtmData[ai][a_id] > 0)
		{
			atmamount ++;
			AtmObj[ai] = CreateDynamicObject(2942, AtmData[ai][a_x], AtmData[ai][a_y], AtmData[ai][a_z], AtmData[ai][a_rx], AtmData[ai][a_ry], AtmData[ai][a_rz]);
		}
	}
	printf("[START] ATMs geladen. [%d]", atmamount);
}

ocmd:atm(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin. Benutze ENTER");
	ShowDialog(playerid, diaATM, DIALOG_STYLE_LIST, "ATM - Menü", "Erstellen \nEditieren \n \nLöschen", "Auswählen", "Fertig");
	return 1;
}

stock AtmOnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	new id = atmamount-1;
	if(objectid == AtmObj[id])
	{
		if(response == EDIT_RESPONSE_CANCEL)
		{
			if(PlayerInfo[playerid][EditObj] == 0)
			{
				DestroyDynamicObject(AtmObj[id]);
				AtmObj[id] = 0;
				atmamount --;
				echo(playerid, cRot, "[AdmCmd] ATM-Erstellung abgebrochen.");
			}
			else
			{
				echo(playerid, cRot, "[AdmCmd] ATM-Editierung abgebrochen.");
				DestroyDynamicObject(AtmObj[id]);
				AtmObj[id] = CreateDynamicObject(2942, AtmData[id][a_x], AtmData[id][a_y], AtmData[id][a_z], AtmData[id][a_rx], AtmData[id][a_ry], AtmData[id][a_rz]);
			}
		}
		else if(response == EDIT_RESPONSE_FINAL)
		{
			if(PlayerInfo[playerid][EditObj] == 0)
			{
				new query[256], strAdmin[128];
				AtmObj[atmamount] = 0;
				AtmData[id][a_id] = atmamount;
				AtmData[id][a_x] = x;
				AtmData[id][a_y] = y;
				AtmData[id][a_z] = z;
				AtmData[id][a_rx] = rx;
				AtmData[id][a_ry] = ry;
				AtmData[id][a_rz] = rz;
				format(query, sizeof(query), "INSERT INTO `atm` (`id`, `a_x`, `a_y`, `a_z`, `a_rx`,`a_ry` ,`a_rz` ,`comment`) VALUES (%i, %f, %f, %f, %f, %f, %f, '%s');", 
					AtmData[id][a_id], AtmData[id][a_x], AtmData[id][a_y], AtmData[id][a_z], AtmData[id][a_rx], AtmData[id][a_ry], AtmData[id][a_rz], AtmData[id][a_comment]);
				format(strAdmin, sizeof(strAdmin), "[AdmCmd] %s hat einen neuen Atm erstellt. [ID: %d]", SpielerName(playerid), AtmData[id][a_id]);
				mysql_query(query);
				
				DestroyDynamicObject(AtmObj[id]);
				AtmObj[id] = CreateDynamicObject(2942, AtmData[id][a_x], AtmData[id][a_y], AtmData[id][a_z], AtmData[id][a_rx], AtmData[id][a_ry], AtmData[id][a_rz]);
				
				Adminecho(cGelb, strAdmin);
			}
			else
			{
				new query[256], strAdmin[128];
				AtmData[id][a_id] = atmamount;
				AtmData[id][a_x] = x;
				AtmData[id][a_y] = y;
				AtmData[id][a_z] = z;
				AtmData[id][a_rx] = rx;
				AtmData[id][a_ry] = ry;
				AtmData[id][a_rz] = rz;
				format(query, sizeof(query), "UPDATE `atm` SET `a_x` = %f, `a_y` = %f, `a_z` = %f, `a_rx` = %f,`a_ry` = %f ,`a_rz` = %f WHERE `id` = %i;", 
					AtmData[id][a_x], AtmData[id][a_y], AtmData[id][a_z], AtmData[id][a_rx], AtmData[id][a_ry], AtmData[id][a_rz], AtmData[id][a_id]);
				format(strAdmin, sizeof(strAdmin), "[AdmCmd] Du hast einen ATM verschoben. [ID: %d]", AtmData[id][a_id]);
				mysql_query(query);
				
				DestroyDynamicObject(AtmObj[id]);
				AtmObj[id] = CreateDynamicObject(2942, AtmData[id][a_x], AtmData[id][a_y], AtmData[id][a_z], AtmData[id][a_rx], AtmData[id][a_ry], AtmData[id][a_rz]);
				
				echo(playerid, cRot, strAdmin);
			}
		}
	}
}


stock AtmOnPlayerKeyStateChange(playerid)
{
	for(new i = 0; i < atmamount; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, ATM_Dist, AtmData[i][a_x], AtmData[i][a_y], AtmData[i][a_z]))
		{
			SetTimerEx("ShowBank", 10, false, "i", playerid);
		}
	}
}

stock AtmOnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == diaATM)
	{
		if(response == 1)
		{
			if(listitem == 0)
			{
				ShowDialog(playerid, diaATMCreate, DIALOG_STYLE_INPUT, "ATM - Erstellen", "Bitte gib zuerst einen Kommentar ein, durch welchen der ATM\nin der Datenbank leicht gefunden werden kann.", "Auswählen", "Abbrechen");
			}
			else if(listitem == 1 || listitem == 3)
			{
				new swag = 0;
				for(new i = 0; i < atmamount; i++)
				{
					if(IsPlayerInRangeOfPoint(playerid, ATM_Dist, AtmData[i][a_x], AtmData[i][a_y], AtmData[i][a_z]))
					{
						swag = 1;
						if(listitem == 1)
						{
							//edit
							EditDynamicObject(playerid, AtmObj[i]);
							PlayerInfo[playerid][EditObj] = 1;
							echo(playerid, cRot, "[ATM] Du editierst nun einen ATM.");
						}
						else
						{
							//delete
							new query[256], strAdmin[128];
							format(query, sizeof(query), "DELETE FROM `atm` WHERE `id` = %i LIMIT 1;", AtmData[i][a_id]);
							format(strAdmin, sizeof(strAdmin), "[AdmCmd] %s hat einen ATM gelöscht. [ID: %d]", SpielerName(playerid), AtmData[i][a_id]);
							mysql_query(query);
							DestroyDynamicObject(AtmObj[i]);
							AtmData[i][a_id] = 0;
							AtmData[i][a_x] = 0;
							AtmData[i][a_y] = 0;
							AtmData[i][a_z] = 0;
							AtmData[i][a_rx] = 0;
							AtmData[i][a_ry] = 0;
							AtmData[i][a_rz] = 0;
							AtmData[i][a_comment] = 0;
							Adminecho(cGelb, strAdmin);
							atmamount --;
						}
					}
				}
				if(swag != 1) return echo(playerid, cRot, "Du bist an keinem ATM.");
			}
		}
	}
	if(dialogid == diaATMCreate)
	{
		if(response == 1)
		{
			new strComment[50];
			format(strComment, sizeof(strComment), "%s", inputtext);
			PlayerInfo[playerid][EditObj] = 0;
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			AtmObj[atmamount] = CreateDynamicObject(2942, x+2, y, z,   0.00000, 0.00000, 180.00000);
			echo(playerid, cRot, "[AdmCmd] Der Atm wurde erstellt. Verschiebe ihn nun an die ausgewählte Position.");
			EditDynamicObject(playerid, AtmObj[atmamount]);
			AtmData[atmamount][a_comment] = strComment;
			atmamount ++;
		}
	}
	return 1;
}