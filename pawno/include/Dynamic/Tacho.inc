new Text:kmh[MAX_PLAYERS];
new Text:kmhBox;
new Text:tmh[MAX_PLAYERS];
new Text:tachoVeh[MAX_PLAYERS];
new Text:tachoStrich;

new TachoTimer[MAX_PLAYERS];

stock TachoOnGameModeInit()
{
	//STRICHER STRICH
	tachoStrich = TextDrawCreate(375.666656, 406.103698, "LD_SPAC:white");
	TextDrawLetterSize(tachoStrich, 0.000000, 0.000000);
	TextDrawTextSize(tachoStrich, -119.999984, 1.244444);
	TextDrawAlignment(tachoStrich, 1);
	TextDrawColor(tachoStrich, -1);
	TextDrawSetShadow(tachoStrich, 0);
	TextDrawSetOutline(tachoStrich, 0);
	TextDrawFont(tachoStrich, 4);
	print("Tachoid:");
	
	//KMH BOX
	kmhBox = TextDrawCreate(376.999908, 356.166687, "usebox");
	TextDrawLetterSize(kmhBox, 0.000000, 7.755345);
	TextDrawTextSize(kmhBox, 254.666656, 0.000000);
	TextDrawAlignment(kmhBox, 1);
	TextDrawColor(kmhBox, 0);
	TextDrawUseBox(kmhBox, true);
	TextDrawBoxColor(kmhBox, 102);
	TextDrawSetShadow(kmhBox, 0);
	TextDrawSetOutline(kmhBox, 0);
	TextDrawFont(kmhBox, 0);
	TextDrawBoxColor(kmhBox,0x00000033);
	print("kmhbox");
}

stock TachoOnPlayerConnect(playerid)
{
	kmh[playerid] = TextDrawCreate(315.000000,362.000000,"0 km/h");
	printf("kmh[playerid]: %d", kmh[playerid]);
	tmh[playerid] = TextDrawCreate(317.000000,384.000000,"KRAFTSTOFF: ~g~~h~IIIIIIIIII~n~0 KM");
	printf("tmh[playerid]: %d", tmh[playerid]);
	TextDrawUseBox(kmhBox,1);
	TextDrawAlignment(kmh[playerid],2);
	TextDrawAlignment(tmh[playerid],2);
	TextDrawBackgroundColor(kmh[playerid],0x000000ff);
	TextDrawBackgroundColor(tmh[playerid],0x000000ff);
	TextDrawFont(kmh[playerid],1);
	TextDrawLetterSize(kmh[playerid],0.400001,2.100001);
	TextDrawFont(tmh[playerid],1);
	TextDrawLetterSize(tmh[playerid],0.199999,1.000000);
	TextDrawColor(kmh[playerid],0xffffffff);
	TextDrawColor(tmh[playerid],0xffffffff);
	TextDrawSetOutline(kmh[playerid],1);
	TextDrawSetOutline(tmh[playerid],1);
	TextDrawSetProportional(kmh[playerid],1);
	TextDrawSetProportional(tmh[playerid],1);
	TextDrawSetShadow(kmh[playerid],1);
	TextDrawSetShadow(tmh[playerid],1);
	
	//Fahrzeugname
	tachoVeh[playerid] = TextDrawCreate(316.000000, 409.422393, "_");
	TextDrawLetterSize(tachoVeh[playerid], 0.250001,1.850001);
	TextDrawAlignment(tachoVeh[playerid], 2);
	TextDrawColor(tachoVeh[playerid], 0xffffffff);
	TextDrawBackgroundColor(tachoVeh[playerid], 0x000000ff);
	TextDrawFont(tachoVeh[playerid], 1);
	TextDrawSetProportional(tachoVeh[playerid], 1);
	TextDrawSetShadow(tachoVeh[playerid], 1);
	TextDrawSetOutline(tachoVeh[playerid], 1);
}

stock ShowTacho(playerid)
{
	TachoTimer[playerid] = SetTimerEx("UpdateTacho", 100, true, "i", playerid);
	TextDrawShowForPlayer(playerid,kmh[playerid]);
	TextDrawShowForPlayer(playerid,tmh[playerid]);
	TextDrawShowForPlayer(playerid,kmhBox);
	TextDrawShowForPlayer(playerid, tachoVeh[playerid]);
	TextDrawShowForPlayer(playerid, tachoStrich);
	return 1;
}

stock HideTacho(playerid)
{
	TextDrawHideForPlayer(playerid,kmh[playerid]);
	TextDrawHideForPlayer(playerid,tmh[playerid]);
	TextDrawHideForPlayer(playerid,kmhBox);
	TextDrawHideForPlayer(playerid, tachoVeh[playerid]);
	TextDrawHideForPlayer(playerid, tachoStrich);
	KillTimer(TachoTimer[playerid]);
	return 1;
}

forward UpdateTacho(playerid);
public UpdateTacho(playerid)
{
	//new strKMH[50], strVeh[50], vehicleid;
	//vehicleid = GetPlayerVehicleID(playerid);
	//format(strKMH, sizeof(strKMH), "~w~%d km/h",GetPlayerSpeed(playerid));
	//TextDrawSetString(kmh[playerid], strKMH);
	//format(strVeh, sizeof(strVeh), "~w~%s", getcarname(GetVehicleModel(vehicleid)));
	//printf("VNAME: %d | %s", GetVehicleModel(vehicleid), getcarname(GetVehicleModel(vehicleid)));
	//TextDrawSetString(tachoVeh[playerid], strVeh);
	return 1;
}