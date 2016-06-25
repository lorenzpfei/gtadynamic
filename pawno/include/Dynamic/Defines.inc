#include <a_samp>
#include <a_mysql>

#define echoAll SendClientMessageToAll

#define cHellGruen 0x86FF59FF
#define cGelb 0xFFBE0082
#define cRot 0xe1333396
#define cWeiss 0xFFFFFFFF
#define cWeiß 0xFFFFFFFF
#define cSchwarz 0x050000FF
#define cBlau 0x224affFF
#define cGruen 0x007D00FF
#define cFullGelb 0xffff00FF
#define cDunkelgruen 0x2C882CAA
#define cDunkelblau 0x0005FFAA
#define cDunkelgelb 0xF5FF00AA
#define cDunkelgrau 0x8C8C8CAA
#define cSupGelb 0xd9d900AA
#define cTürkis 0x00ff73FF
#define cPink 0xFA00FFFF
#define cGrau 0x969696FF
#define cHellblau 0x358cffFF
#define cBizgruen 0x00B200FF
#define cLila 0x8200FFFF
#define cOrange 0xFF8A05FF
#define cAond 0xA76EFBFF
#define cWantedBlau 0x5b5cffFF
#define cUnsichtbar 0xFFFFFF00
#define GroveColor 0x22B14C66
#define VagosColor 0xFFC90E66
#define BallasColor 0xA349A466
#define LCNColor 0x00000066
#define GuerillaColor 0x75483166
#define YakuzaColor 0xFF000066
#define NoDMColor 0xFFFFFF66
#define cGruppe 0x4BAF00FF
//#define cTuerkis 0x00ff73FF
#define cTuerkis 0x690000FF
//#define cGruppe 0xdd5643FF
#define cFlagge 0xFFD200FF
#define cEnter 0xFFFF8BFF
#define cPayday 0xC8C8C8FF
#define cBank 0xCDFF00FF

#define ciRot "{e13333}"
#define ciWeiß "{FFFFFF}"
#define ciGelb "{EBFF67}"
#define ciHellblau "{358cff}"
#define ciOrange "{FF8A05}"


enum SpielerDaten
{
	peID,
	pName[MAX_PLAYER_NAME],
	pGeld,
	pAdminlevel,
	Float:pPosX,
	Float:pPosY,
	Float:pPosZ,
	pPosInt,
	pSkin,
	pFraktion,
	pGruppierung,
	pSpawn,
	pMask,
	pAond,
	pPremiumpunkte,
	pDuty,
	pKopfgeld,
	pGRank,
	pGLeader,
	pFRank,
	pFLeader,
	pWanteds,
	pWantedReason[50],
	pLevel,
	pJoined,
	pExp,
	pPayday
}

new SpielerInfo[MAX_PLAYERS][SpielerDaten];


//Temporäre Variablen
enum TSpielerDaten
{
	pTicketson,
	Float:saveX,
	Float:saveY,
	Float:saveZ,
	saveInt,
	saveVW,
	WhereBiz,
	WhereHouse,
	WhereArea,
	WhereGArray,
	Lotto,
	EditObj,
	WhereVW
}

new PlayerInfo[MAX_PLAYERS][TSpielerDaten];


#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
	
forward KickTime(playerid);

stock IsPlayerName(playerid, const name[])
{
    new tmpname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, tmpname, sizeof(tmpname));
    if(!strcmp(tmpname, name, false)) return true;
    return false;
}

stock SpielerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,sizeof(name));
	return name;
}

stock KickTimer(playerid, time)
{
	SetTimerEx("KickTime", time, false, "playerid", playerid);
}

public KickTime(playerid)
{
	Kick(playerid);
}


stock strget(strx[], pos, search = ' ') {
	new arg, ret[128], idxx;
	for (new i = 0; i < strlen(strx); i++) {
		if(strx[i] == search || i == strlen(strx) || strx[i + 1] == 10) {
			arg++;
			if (arg == pos + 1){
				ret[i-idxx] = EOS;
				return ret;
			} else if (arg == pos)
				idxx= i+1;
		}
		else if (arg == pos)
	    		ret[i - idxx] = strx[i];
	}
	return ret;
}

stock Connect_To_Database()
{
	mysql_connect(SQL_HOST, SQL_USER, SQL_DATA, SQL_PASS); //Wir versuchen mit den Angaben die wir oben im Script gemacht haben uns mit dem MySQL Server zu verbinden.
	if(mysql_ping() == 1) //Es wird überprüft ob die Verbindung steht.
	{
		//Falls ja wird das in die Console geschrieben und die Funktion wird beendet.
		print("<-| [MYSQL] Verbindung zur Datenbank wurde erfolgreich hergestellt!");
		return true;
	}
	else
	{
		//Falls nicht wird erneut versucht eine verbindung aufzubauen.
		print("<-| [MYSQL] Es konnte keine Verbindung zur Datenbank hergestellt werden!");
		print("<-| [MYSQL] Es wird erneut versucht eine Verbindung zur Datenbank herzustellen!");
		mysql_connect(SQL_HOST, SQL_USER, SQL_DATA, SQL_PASS);
		if(mysql_ping() == 1)
		{
			print("<-| [MYSQL] Es konnte im 2 Versuch eine Verbindung hergestellt werden!");
			return true;
		}
		else
		{
			//Falls das auch nicht Funktioniert wird der Server zur Sicherheit wieder heruntergefahren.
			print("<-| [MYSQL] Es konnte keine Verbindung zur Datenbank hergestellt werden!");
			print("<-| [MYSQL] Der Server wird nun beendet!");
			SendRconCommand("exit");
			return true;
		}
	}
}
stock mysql_CheckAccount(playerid)
{
	new query[128],
		Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
	mysql_real_escape_string(Name, Name);
	format(query, sizeof query, "SELECT `id` FROM `accounts` WHERE `name` = '%s' LIMIT 1;", Name);
	mysql_query(query);
	mysql_store_result();
	new response = mysql_num_rows();
	mysql_free_result();
	return response;
}
stock CreateAccount(playerid, pass[])
{
	new query[256],
		Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
	mysql_real_escape_string(Name, Name);
	mysql_real_escape_string(pass, pass);
	format(query, sizeof query, "INSERT INTO `accounts` (`name`, `password`) VALUES ('%s', '%s');", Name, pass);
	mysql_query(query);
	return true;
}
stock mysql_ReturnPasswort(Name[])
{
	new query[130], Get[130];
	mysql_real_escape_string(Name, Name);
	format(query, sizeof query, "SELECT `password` FROM `accounts` WHERE `name` = '%s' LIMIT 1;", Name);
	mysql_query(query);
	mysql_store_result();
	mysql_fetch_row(Get);
	mysql_free_result();
	return Get;
}

stock mysql_GetString(Table[], Field[], Where[], Is[])
{
	new query[128],
		Get[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Is, Is);
	format(query, sizeof query, "SELECT %s FROM %s WHERE %s = '%s'", Field, Table, Where, Is);
	mysql_query(query);
	mysql_store_result();
	mysql_fetch_row(Get);
	mysql_free_result();
	return Get;
}
stock mysql_GetInt(Table[], Field[], Where[], Is[])
{
    new query[128];
    mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Is, Is);
    format(query, sizeof query, "SELECT %s FROM %s WHERE %s = '%s'", Field, Table, Where, Is);
	mysql_query(query);
	mysql_store_result();
	new sqlint = mysql_fetch_int();
	mysql_free_result();
	return sqlint;
}
stock Float:mysql_GetFloat(Table[], Field[], Where[], Is[])
{
	new query[128], Float:sqlfloat;
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Is, Is);
	format(query, sizeof query, "SELECT `%s` FROM `%s` WHERE `%s` = '%s'", Field, Table, Where, Is);
	mysql_query(query);
	mysql_store_result();
	mysql_fetch_float(sqlfloat);
	mysql_free_result();
	return sqlfloat; //Zeile
}

stock mysql_UpdateInt(Table[], Field[], To, Where[], Where2[])
{
	new query[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Where2, Where2);
	format(query, sizeof query, "UPDATE %s SET %s = '%d' WHERE %s = '%s'", Table, Field, To, Where, Where2);
	mysql_query(query);
	return true;
}

stock mysql_SetInt(Table[], Field[], To, Where[], Where2[])
{
	new sql[256];

	format(sql, sizeof(sql), "SELECT * FROM %s WHERE %s = %s",Table, Where, Where2);
	mysql_query(sql);
	mysql_store_result();
	
	new query[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Where2, Where2);
	
	if(mysql_num_rows()) 
	{
		format(query, sizeof query, "UPDATE %s SET %s = '%d' WHERE %s = '%s'", Table, Field, To, Where, Where2);
	}
	else 
	{
		format(query, sizeof query, "INSERT INTO %s (%s, %s) VALUES ('%d', '%s')", Table, Field, Where, To, Where2);
		
	}
	mysql_free_result();
	mysql_query(query);
	return true;
}

stock mysql_SetString(Table[], Field[], To[], Where[], Where2[])
{
	new sql[256];

	format(sql, sizeof(sql), "SELECT * FROM %s WHERE %s = %s",Table, Where, Where2);
	mysql_query(sql);
	mysql_store_result();
	
	new query[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(To, To);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Where2, Where2);
	
	if(mysql_num_rows()) 
	{
		format(query, 128, "UPDATE %s SET %s = '%s' WHERE %s = '%s'", Table, Field, To, Where, Where2);
	}
	else 
	{
		format(query, 128, "INSERT INTO %s (%s, %s) VALUES ('%s', '%s')", Table, Field, Where, To, Where2);
		
	}
	mysql_free_result();
	mysql_query(query);
	return true;
}

stock mysql_SetStringWhere(Table[], Field[], To[], Where[], Where2[], Where3[], Where4[])
{
	new sql[256];

	format(sql, sizeof(sql), "SELECT * FROM %s WHERE %s = '%s' AND %s = '%s'",Table, Where, Where2, Where3, Where4);
	mysql_query(sql);
	mysql_store_result();
	
	new query[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(To, To);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Where2, Where2);
	mysql_real_escape_string(Where3, Where3);
	mysql_real_escape_string(Where4, Where4);
	
	if(mysql_num_rows()) 
	{
		format(query, 128, "UPDATE %s SET %s = '%s'  WHERE %s = '%s' AND %s = '%s'", Table, Field, To, Where, Where2, Where3, Where4);
	}
	else 
	{
		format(query, 128, "INSERT INTO %s (%s, %s, %s) VALUES ('%s', '%s', '%s')", Table, Field, Where, Where3, To, Where2, Where4);
		
	}
	mysql_free_result();
	mysql_query(query);
	return true;
}

stock mysql_UpdateString(Table[], Field[], To[], Where[], Where2[])
{
	new query[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(To, To);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Where2, Where2);
	format(query, 128, "UPDATE %s SET %s = '%s' WHERE %s = '%s'", Table, Field, To, Where, Where2);
	mysql_query(query);
	return true;
}


stock mysql_SetFloat(Table[], Field[], Float:To, Where[], Where2[])
{
	new query[128];
	mysql_real_escape_string(Table, Table);
	mysql_real_escape_string(Field, Field);
	mysql_real_escape_string(Where, Where);
	mysql_real_escape_string(Where2, Where2);
	format(query, 128, "UPDATE %s SET %s = '%.1f' WHERE %s = '%s'", Table, Field, To, Where, Where2);
	mysql_query(query);
	return true;
}


stock LoadPlayer(playerid)
{
	if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid))
	{
	    new name[MAX_PLAYER_NAME],
			string[128],
			query[512];

    	GetPlayerName(playerid, name, sizeof name);
	    GetPlayerName(playerid, SpielerInfo[playerid][pName], MAX_PLAYER_NAME);

		format(query, sizeof query, "SELECT \n\
					`id`, `money`, `admin_level`, `pos_x`, `pos_y`, `pos_z`, `pos_int`, `skin`, `faction`,\n\
					`grouping`, `spawn`, `premium_points`, `bounty`, `grouping_rank`, `grouping_leader`, `faction_rank`,\n\
					`faction_leader`, `wanteds`, `wanted_reason`, `level`, `joined`, `experience`, `payday`\n\
					FROM `accounts` WHERE `name` = '%s';", SpielerInfo[playerid][pName]);
		mysql_query(query);
		mysql_store_result();
		while(mysql_fetch_row_format(query))
		{
			sscanf(query, "p<|>iiifffiiiiiiiiiiiis[50]iiii",
					SpielerInfo[playerid][peID], SpielerInfo[playerid][pGeld], SpielerInfo[playerid][pAdminlevel],
					SpielerInfo[playerid][pPosX], SpielerInfo[playerid][pPosY], SpielerInfo[playerid][pPosZ],
					SpielerInfo[playerid][pPosInt], SpielerInfo[playerid][pSkin], SpielerInfo[playerid][pFraktion],
					SpielerInfo[playerid][pGruppierung], SpielerInfo[playerid][pSpawn], SpielerInfo[playerid][pPremiumpunkte],
					SpielerInfo[playerid][pKopfgeld], SpielerInfo[playerid][pGRank], SpielerInfo[playerid][pGLeader],
					SpielerInfo[playerid][pFRank], SpielerInfo[playerid][pFLeader], SpielerInfo[playerid][pWanteds],
					SpielerInfo[playerid][pWantedReason], SpielerInfo[playerid][pLevel], SpielerInfo[playerid][pJoined], SpielerInfo[playerid][pExp], SpielerInfo[playerid][pPayday]
			);
		}
		mysql_free_result();

		for(new i=0; i<MAX_PLAYERS; i++)
		{
			if(SpielerInfo[i][pJoined] == 0 || SpielerInfo[i][pJoined] == 1)
	   		{
				format(string, sizeof(string), "[Betreten] %s hat den Server betreten.",name);
				SendClientMessage(i, cGruen, string);
			}
		}
	}
	return 1;
}

stock SavePlayer(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
	    if(GetPVarInt(playerid, "Eingeloggt"))
		{
			new query[1024];
			format(query, sizeof query, "UPDATE `accounts` SET `money` = %i", SpielerInfo[playerid][pGeld]);
			format(query, sizeof query, "%s, `pos_x` = '%f'", query, SpielerInfo[playerid][pPosX]);
			format(query, sizeof query, "%s, `pos_y` = '%f'", query, SpielerInfo[playerid][pPosY]);
			format(query, sizeof query, "%s, `pos_z` = '%f'", query, SpielerInfo[playerid][pPosZ]);
			format(query, sizeof query, "%s, `pos_int` = %i", query, SpielerInfo[playerid][pPosInt]);
			format(query, sizeof query, "%s, `admin_level` = %i", query, SpielerInfo[playerid][pAdminlevel]);
			format(query, sizeof query, "%s, `skin` = %i", query, SpielerInfo[playerid][pSkin]);
			format(query, sizeof query, "%s, `spawn` = %i", query, SpielerInfo[playerid][pSpawn]);
			format(query, sizeof query, "%s, `premium_points` = %i", query, SpielerInfo[playerid][pPremiumpunkte]);
			format(query, sizeof query, "%s, `bounty` = %i", query, SpielerInfo[playerid][pKopfgeld]);
			format(query, sizeof query, "%s, `grouping` = %i", query, SpielerInfo[playerid][pGruppierung]);
			format(query, sizeof query, "%s, `grouping_rank` = %i", query, SpielerInfo[playerid][pGRank]);
			format(query, sizeof query, "%s, `grouping_leader` = %i", query, SpielerInfo[playerid][pGLeader]);
			format(query, sizeof query, "%s, `faction` = %i", query, SpielerInfo[playerid][pFraktion]);
			format(query, sizeof query, "%s, `faction_rank` = %i", query, SpielerInfo[playerid][pFRank]);
			format(query, sizeof query, "%s, `faction_leader` = %i", query, SpielerInfo[playerid][pFLeader]);
			format(query, sizeof query, "%s, `wanteds` = %i", query, SpielerInfo[playerid][pWanteds]);
			format(query, sizeof query, "%s, `wanted_reason` = '%s'", query, SpielerInfo[playerid][pWantedReason]);
			format(query, sizeof query, "%s, `level` = %i", query, SpielerInfo[playerid][pLevel]);
			format(query, sizeof query, "%s, `joined` = %i", query, SpielerInfo[playerid][pJoined]);
			format(query, sizeof query, "%s, `experience` = %i", query, SpielerInfo[playerid][pExp]);
			format(query, sizeof query, "%s, `payday` = %i", query, SpielerInfo[playerid][pPayday]);
			format(query, sizeof query, "%s WHERE `id` = %i;", query, SpielerInfo[playerid][peID]);
			mysql_query(query);
			
			printf("%s wurde gespeichert", SpielerName(playerid));
		}
		else return printf("%s wurde NICHT gespeichert", SpielerName(playerid));
	}
	return 1;
}