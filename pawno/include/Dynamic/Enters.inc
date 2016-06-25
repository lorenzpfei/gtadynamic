#define MAX_ENTERS 100
new Float:E_enterdist = 1.25; //Reichweite von der man enter drücken muss
new Float:E_Distance = 5.0; // Anzeige des 3D-Textes
new Float:I_Distance = 5.0;

enum e_info
{
	enter_id,
	faction,
	grupp,
	icon,
    Float:a_x,
    Float:a_y,
    Float:a_z,
	a_int,
	a_world,
	a_text[70],
	a_visible,
    Float:i_x,
    Float:i_y,
    Float:i_z,
    i_int,
	i_world,
	i_text[70],
	i_visible
}

new enteramount = 0;
new EnterData[MAX_ENTERS][e_info];


stock EnterOnGameModeInit()
{
	new intDurchlauf = 1,
		e_result[200];
	mysql_query("SELECT `id`, `faction`, `grouping`, `icon`, `x`, `y`, `z`, `int`, `world`, `text`, `visible`, `to_x`, `to_y`, `to_z`, `to_int`, `to_world`, `to_text`, `to_visible` FROM `enters`;"); 
	mysql_store_result();
	while(mysql_fetch_row_format(e_result)) 
	{
		sscanf(e_result,"p<|>e<iiiifffiis[70]ifffiis[70]i>",EnterData[intDurchlauf]);
		
		enteramount ++;
		intDurchlauf++;
	}
	mysql_free_result();
	
	for(new intDurchlaufZwei = 1; intDurchlaufZwei < enteramount+1; intDurchlaufZwei++)
	{
		if(EnterData[intDurchlaufZwei][a_visible])
		{
			CreatePickup(1239, 1, EnterData[intDurchlaufZwei][a_x], EnterData[intDurchlaufZwei][a_y], EnterData[intDurchlaufZwei][a_z], EnterData[intDurchlaufZwei][a_world]);
			CreateDynamic3DTextLabel(EnterData[intDurchlaufZwei][a_text], cEnter, EnterData[intDurchlaufZwei][a_x], EnterData[intDurchlaufZwei][a_y], EnterData[intDurchlaufZwei][a_z], E_Distance);
		}
		if(EnterData[intDurchlaufZwei][i_visible])
		{
			CreatePickup(1239, 1, EnterData[intDurchlaufZwei][i_x], EnterData[intDurchlaufZwei][i_y], EnterData[intDurchlaufZwei][i_z], EnterData[intDurchlaufZwei][i_world]);
			CreateDynamic3DTextLabel(EnterData[intDurchlaufZwei][i_text], cEnter, EnterData[intDurchlaufZwei][i_x], EnterData[intDurchlaufZwei][i_y], EnterData[intDurchlaufZwei][i_z], I_Distance);
		}
	}
	printf("[START] Enters geladen. [%d]", enteramount);
}


stock EnterOnPlayerConnect(playerid)
{
	for(new i = 0; i < enteramount; i++)
	{
		if(EnterData[i][icon] > 0)
		{
			CreateMapIcon(playerid, EnterData[i][a_x], EnterData[i][a_y], EnterData[i][a_z], EnterData[i][icon], 0, 0);
		}
	}
}


stock EnterOnPlayerKeyStateChange(playerid)
{
	for(new i = 0; i < sizeof EnterData; i++)
	{
      	if(GetPlayerVirtualWorld(playerid) == EnterData[i][a_world] && GetPlayerInterior(playerid) == EnterData[i][a_int] && IsPlayerInRangeOfPoint(playerid, E_enterdist, EnterData[i][a_x], EnterData[i][a_y], EnterData[i][a_z]))
		{
			if((!EnterData[i][faction] && !EnterData[i][grupp]) || (EnterData[i][faction] == SpielerInfo[playerid][pFraktion] || EnterData[i][grupp] == SpielerInfo[playerid][pGruppierung]))
      	    {
				SetPlayerInterior(playerid, EnterData[i][i_int]);
				SetPlayerVirtualWorld(playerid, EnterData[i][i_world]);
				SetPlayerPos(playerid, EnterData[i][i_x], EnterData[i][i_y], EnterData[i][i_z]);
				return 1;
			}
		}
      	else if(GetPlayerVirtualWorld(playerid) == EnterData[i][i_world] && GetPlayerInterior(playerid) == EnterData[i][i_int] && IsPlayerInRangeOfPoint(playerid, E_enterdist, EnterData[i][i_x], EnterData[i][i_y], EnterData[i][i_z]))
      	{
			if((!EnterData[i][faction] && !EnterData[i][grupp]) || (EnterData[i][faction] == SpielerInfo[playerid][pFraktion] || EnterData[i][grupp] == SpielerInfo[playerid][pGruppierung]))
      	    {
				SetPlayerInterior(playerid, EnterData[i][a_int]);
				SetPlayerVirtualWorld(playerid, EnterData[i][a_world]);
				SetPlayerPos(playerid, EnterData[i][a_x], EnterData[i][a_y], EnterData[i][a_z]);
				return 1;
			}
		}
   	}
	return 1;
}