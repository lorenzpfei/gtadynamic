
new Float:v_enterdist = 3.0;
new bool:isSpawned[MAX_VEHICLES] = false;
new vSecondTimer[MAX_VEHICLES];


enum eVehicles{
	veID,
	vModel,
	vStatus,
	vOwnerID,
	Float:vX,
	Float:vY,
	Float:vZ,
	Float:vR,
	vInt,
	vWorld,
	vEngine,
	vLights,
	vLock,
	vColor1,
	vColor2,
	vKennzeichen[32],
	Float:vHealth,
	Float:vTank,
	vKM,
	vSlot[14]
};
new VehicleData[MAX_VEHICLES][eVehicles];


stock VehicleOnGameModeInit()
{
	new vi = 0, vResult[200], curVehId = 0;
	mysql_query("SELECT `id`, `model`, `status`, `owner`, `x`, `y`, `z`, `r`, `int`, `world`,\n\
				`engine`, `lights`, `locked`, `color_1`, `color_2`, `number_plate`, `health`, `tank`, `km`, `slot_0`, `slot_1`,\n\
				`slot_2`, `slot_3`, `slot_4`, `slot_5`, `slot_6`, `slot_7`, `slot_8`, `slot_9`, `slot_10`, `slot_11`, `slot_12`, `slot_13` FROM `vehicles` WHERE `status` != 1;");
	mysql_store_result();
	while(mysql_fetch_row_format(vResult))
	{
		new vehicle[eVehicles];
		sscanf(vResult, "p<|>e<iiiiffffiiiiiiis[32]ffiiiiiiiiiiiiiii>", vehicle);
		
		curVehId = CreateAVehicle(vehicle[vModel], vehicle[vX], vehicle[vY], vehicle[vZ], vehicle[vR], vehicle[vColor1], vehicle[vColor2], vehicle[vKennzeichen], vehicle[vEngine], vehicle[vLights], vehicle[vLock]);
		if(curVehId < 0)
		{
			print("Es gibt keine freien Parkplätze mehr!");
		}
		else
		{
			for(new x; x < sizeof vehicle[vSlot]; x++)
				AddVehicleComponent(curVehId, vehicle[vSlot][x]);
			VehicleData[curVehId] = vehicle;
			++vi;
		}
	}
    mysql_free_result();

	printf("[START] Fahrzeuge geladen. [%d]", vi);
}

stock VehiclesOnPlayerStateChange(playerid, newkeys, oldkeys)
{
	new vehicleid = GetPlayerVehicleID(playerid),
		vehID = vehicleid;
	//========================================== MOTOR ==========================================
	if((PRESSED(KEY_ANALOG_DOWN)) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
 	{
		if(isSpawned[vehicleid] == true)
		{
			new lights,engine, alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(engine == 1){
				engine = 0;
				HideTacho(playerid);
			}
			else{
				engine = 1;
				ShowTacho(playerid);
			}
			SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		}
		else
		{
			if(VehicleData[vehID][vOwnerID] == SpielerInfo[playerid][peID])
			{
				new lights,alarm,doors,bonnet,boot,objective;
				GetVehicleParamsEx(vehicleid,VehicleData[vehID][vEngine],lights,alarm,doors,bonnet,boot,objective);
				if(VehicleData[vehID][vEngine] == 1){
					VehicleData[vehID][vEngine] = 0;
					KillTimer(vSecondTimer[vehicleid]);
					HideTacho(playerid);
				}
				else{
					VehicleData[vehID][vEngine] = 1;
					vUpdateSecond(vehicleid);
					vSecondTimer[vehicleid] = SetTimerEx("vUpdateSecond", 1000, 1, "i", vehicleid);
					ShowTacho(playerid);
				}
				SetVehicleParamsEx(vehicleid,VehicleData[vehID][vEngine],lights,alarm,doors,bonnet,boot,objective);
			}
			else return echo(playerid, cRot, "Du besitzt keinen Schlüssel!");
		}
		return 1;
	}
	//========================================== LICHT ==========================================
	if((PRESSED(KEY_ANALOG_UP)) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
 	{
		if(isSpawned[vehicleid] == true)
		{
			new engine,lights, alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(lights == 1){
				lights = 0;
			}
			else{
				lights = 1;
			}
			SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		}
		else
		{
			if(VehicleData[vehID][vOwnerID] == SpielerInfo[playerid][peID])
			{
				new engine,alarm,doors,bonnet,boot,objective;
				GetVehicleParamsEx(vehicleid,engine,VehicleData[vehID][vLights],alarm,doors,bonnet,boot,objective);
				if(VehicleData[vehID][vLights] == 1){
					VehicleData[vehID][vLights] = 0;
				}
				else{
					VehicleData[vehID][vLights] = 1;
				}
				SetVehicleParamsEx(vehicleid,engine,VehicleData[vehID][vLights],alarm,doors,bonnet,boot,objective);
			}
			else return echo(playerid, cRot, "Du besitzt keinen Schlüssel!");
		}
		return 1;
	}
	//========================================== LICHT ==========================================
	if((PRESSED(KEY_ANALOG_UP)) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
 	{
		if(isSpawned[vehicleid] == true)
		{
			new engine,lights, alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(lights == 1){
				lights = 0;
			}
			else{
				lights = 1;
			}
			SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		}
		else
		{
			if(VehicleData[vehID][vOwnerID] == SpielerInfo[playerid][peID])
			{
				new engine,alarm,doors,bonnet,boot,objective;
				GetVehicleParamsEx(vehicleid,engine,VehicleData[vehID][vLights],alarm,doors,bonnet,boot,objective);
				if(VehicleData[vehID][vLights] == 1){
					VehicleData[vehID][vLights] = 0;
				}
				else{
					VehicleData[vehID][vLights] = 1;
				}
				SetVehicleParamsEx(vehicleid,engine,VehicleData[vehID][vLights],alarm,doors,bonnet,boot,objective);
			}
			else return echo(playerid, cRot, "Du besitzt keinen Schlüssel!");
		}
		return 1;
	}
	return 1;
}

stock SpawnPlayerVehicles(playerid)
{
	new vi = 0,
		vResult[512],
		curVehId = 0;
	format(vResult, sizeof vResult, "SELECT `id`, `model`, `status`, `owner`, `x`, `y`, `z`, `r`, `int`, `world`,\n\
				`engine`, `lights`, `locked`, `color_1`, `color_2`, `number_plate`, `health`, `tank`, `km`, `slot_0`, `slot_1`,\n\
				`slot_2`, `slot_3`, `slot_4`, `slot_5`, `slot_6`, `slot_7`, `slot_8`, `slot_9`, `slot_10`, `slot_11`, `slot_12`, `slot_13` FROM `vehicles` WHERE `status` = 1 AND `owner` = %i;", SpielerInfo[playerid][peID]);
	mysql_query(vResult);
	mysql_store_result();
	while(mysql_fetch_row_format(vResult))
	{
		new vehicle[eVehicles];
		sscanf(vResult, "p<|>e<iiiiffffiiiiiiis[32]ffiiiiiiiiiiiiii>", vehicle);
		curVehId = CreateAVehicle(vehicle[vModel], vehicle[vX], vehicle[vY], vehicle[vZ], vehicle[vR], vehicle[vColor1], vehicle[vColor2], vehicle[vKennzeichen], vehicle[vEngine], vehicle[vLights], vehicle[vLock]);
		SetVehicleHealth(curVehId, vehicle[vHealth]);
		if(curVehId < 0)
		{
			print("Es gibt keine freien Parkplätze mehr!");
		}
		else
		{
			for(new x; x < sizeof vehicle[vSlot]; x++)
				AddVehicleComponent(curVehId, vehicle[vSlot][x]);
			VehicleData[curVehId] = vehicle;
			++vi;
		}
	}
    mysql_free_result();

	printf("[Spieler %s] Fahrzeuge geladen. [%d]", SpielerName(playerid), vi);
}

stock DeSpawnPlayerVehicles(playerid, var)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(GetPVarInt(playerid, "Eingeloggt") != 1) return 1;
	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(VehicleData[i][vStatus] == 1 && VehicleData[i][vOwnerID] == SpielerInfo[playerid][peID])
		{
			new e;
			GetVehiclePos(i, VehicleData[i][vX], VehicleData[i][vY], VehicleData[i][vZ]);
			GetVehicleZAngle(i, VehicleData[i][vR]);
			GetVehicleColor(i, VehicleData[i][vColor1], VehicleData[i][vColor2]);
			GetVehicleParamsEx(i, VehicleData[i][vEngine], VehicleData[i][vLights], e, VehicleData[i][vLock], e, e, e);
			GetVehicleHealth(i, VehicleData[i][vHealth]);
			if(VehicleData[i][vEngine] == -1) return VehicleData[i][vEngine] = 0;
			if(VehicleData[i][vLights] == -1) return VehicleData[i][vLights] = 0;
			if(VehicleData[i][vLock] == -1) return VehicleData[i][vLock] = 0;
			
			KillTimer(vSecondTimer[i]);
			
			new query[1024];
			format(query, sizeof query, "UPDATE `vehicles` SET `model` = %i, `status` = %i, `owner` = %i, `x` = %f, `y` = %f, `z` = %f, `r` = %f, `engine` = %i, `lights` = %i, `color_1` = %i, `color_2` = %i, `number_plate` = '%s', `locked` = %d, `health` = %f, `tank` = %f, `km` = %d",
				VehicleData[i][vModel], VehicleData[i][vStatus], SpielerInfo[playerid][peID], VehicleData[i][vX], VehicleData[i][vY], VehicleData[i][vZ], VehicleData[i][vR],
				VehicleData[i][vEngine], VehicleData[i][vLights], VehicleData[i][vColor1], VehicleData[i][vColor2], VehicleData[i][vKennzeichen], VehicleData[i][vLock], VehicleData[i][vHealth], VehicleData[i][vTank], VehicleData[i][vKM]);
			for(new x; x < 14; x++)
			{
				VehicleData[i][vSlot][x] = GetVehicleComponentInSlot(i, x);
				format(query, sizeof query, "%s, `slot_%i` = %i", query, x, VehicleData[i][vSlot][x]);
			}
			format(query, sizeof query, "%s WHERE `id` = %i;", query, VehicleData[i][veID]);
			mysql_query(query);
			
			//printf("[Despawn] %d %s [OwnerID %d]", i, e, VehicleData[i][vOwnerID]);
			if(var == 1)
				DestroyVehicle(i);
		}
	}
	return 1;
}

stock CreateAVehicle(modelid, Float:x, Float:y, Float:z, Float:r, colorid1, colorid2, kennzeichen[], engine, lights, doors)
{
	new id = CreateVehicle(modelid, x, y, z, r, colorid1, colorid2, -1);
	if(id < 1)
	{
		print("Das Limit für die Fahrzeuge ist erreicht");
		return 0;
	}
	SetVehicleNumberPlate(id, kennzeichen);
	SetVehicleParamsEx(id, engine, lights, 0, doors, 0, 0, 0);
	if(engine == 1)
		vSecondTimer[id] = SetTimerEx("vUpdateSecond", 1000, 1, "i", id);
	return id;
}

stock VCreateVehicle(playerid, status, modelid, Float:x, Float:y, Float:z, Float:r, colorid1, colorid2, kennzeichen[], bool:engine, bool:lights, Float:tank)
{
	new id = CreateAVehicle(modelid, x, y, z, r, colorid1, colorid2, kennzeichen, engine, lights, 0);
	if(id < 1)
		return print("Das Limit für die Fahrzeuge ist erreicht");
	
	new query[299];
	format(query, sizeof query, "INSERT INTO `vehicles` (`model`, `status`, `owner`, `x`, `y`, `z`, `r`, `color_1`, `color_2`, `number_plate`, `tank`, `km`) VALUES (%d, %d, %d, %f, %f, %f, %f, %d, %d, '%s', %f, 0)", modelid, status, SpielerInfo[playerid][peID], x, y, z, r, colorid1, colorid2, kennzeichen, tank);
	mysql_query(query);
	printf("Freie ID: %d - %d", id, mysql_insert_id());
	VehicleData[id][veID] = mysql_insert_id();
	VehicleData[id][vStatus] = status;
	VehicleData[id][vModel] = modelid;
	VehicleData[id][vOwnerID] = SpielerInfo[playerid][peID];
	VehicleData[id][vX] = x;
	VehicleData[id][vY] = y;
	VehicleData[id][vZ] = z;
	VehicleData[id][vR] = r;
	VehicleData[id][vEngine] = engine;
	VehicleData[id][vLights] = lights;
	VehicleData[id][vColor1] = colorid1;
	VehicleData[id][vColor2] = colorid2;
	VehicleData[id][vTank] = tank;
	VehicleData[id][vHealth] = 1000;
	VehicleData[id][vKM] = 0;
	for(new i; i < 14; i++)
		VehicleData[id][vSlot][i] = 0;
	format(VehicleData[id][vKennzeichen], 32, "%s", kennzeichen);
	return 1;
}


ocmd:vinfo(playerid, params[])
{
	new vehID = getNearVehicle(playerid, 8.0);
	if(!IsValidVehicle(vehID)) return echo(playerid, cRot, "Es konnte kein Fahrzeug in deiner Nähe gefunden werden.");
	echo(playerid, cRot, "----- Fahrzeug -----");
	new strVehName[75];
	format(strVehName, sizeof(strVehName), "Fahrzeugname: %s", getcarname(GetVehicleModel(vehID)));
	echo(playerid, cRot, strVehName);
	new strBesitzer[50];
	switch(VehicleData[vehID][vStatus])
	{
		case 0:
		{
			format(strBesitzer, sizeof(strBesitzer), "Ungültiger Besitzer.");
		}
		case 1:
		{
			new strOwnerID[8];
			valstr(strOwnerID, VehicleData[vehID][vOwnerID]);
			format(strBesitzer, sizeof(strBesitzer), "Besitzer: %s", mysql_GetString("accounts", "name", "id", strOwnerID));
		}
		case 2:
		{
			format(strBesitzer, sizeof(strBesitzer), "Club");
		}
		case 3:
		{
			format(strBesitzer, sizeof(strBesitzer), "Firma");
		}
		default:
		{
			format(strBesitzer, sizeof(strBesitzer), "Besitzer: Unbekannt");
		}
	}
	
	if(VehicleData[vehID][veID] < 1) return echo(playerid, cRot, "Besitzer: Adminteam");
	
	echo(playerid, cRot, strBesitzer);
	new strKZ[50];
	format(strKZ, sizeof(strKZ), "Kennzeichen: %s", VehicleData[vehID][vKennzeichen]);
	echo(playerid, cRot, strKZ);
	new strVehID[50];
	format(strVehID, sizeof(strVehID), "Datenbank ID: %i", VehicleData[vehID][veID]);
	echo(playerid, cRot, strVehID);
	format(strVehID, sizeof(strVehID), "Tankinhalt: %.0f liter", VehicleData[vehID][vTank]);
	echo(playerid, cRot, strVehID);
	return 1;
}

ocmd:lock(playerid, params[])
{
	new vehID = getNearVehicle(playerid, 8.0);
	if(!IsValidVehicle(vehID)) return echo(playerid, cRot, "Es konnte kein Fahrzeug in deiner Nähe gefunden werden.");
	new engine, lights, alarm, bonnet, doors, boot, objective;
	GetVehicleParamsEx(vehID, engine, lights, alarm, doors ,bonnet, boot, objective);
	if(isSpawned[vehID] == true)
	{
		//Adminteam
		if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist nicht im Adminteam.");
		if(doors == 1)
		{
			//auf
			doors = 0;
			SetVehicleParamsEx(vehID, engine, lights, alarm, doors, bonnet, boot, objective);
			echo(playerid, cGruen, "[Fahrzeug aufgeschlossen]");
			vHupe(vehID);
			return 1;
		}
		else
		{
			//zu
			doors = 1;
			SetVehicleParamsEx(vehID, engine, lights, alarm, doors, bonnet, boot, objective);
			echo(playerid, cRot, "[Fahrzeug abgeschlossen]");
			vHupe(vehID);
			return 1;
		}
	}
	else
	{
		//Spieler
		if(VehicleData[vehID][vOwnerID] != SpielerInfo[playerid][peID]) return echo(playerid, cRot, "Du besitzt keinen Schlüssel!");
		if(VehicleData[vehID][vLock] == 0)
		{
			//zu
			VehicleData[vehID][vLock] = 1;
			SetVehicleParamsEx(vehID, engine, lights, alarm, VehicleData[vehID][vLock], bonnet, boot, objective);
			echo(playerid, cRot, "[Fahrzeug abgeschlossen]");
			vHupe(vehID);
			return 1;
		}
		else
		{
			//auf
			VehicleData[vehID][vLock] = 0;
			SetVehicleParamsEx(vehID, engine, lights, alarm, VehicleData[vehID][vLock], bonnet, boot, objective);
			echo(playerid, cGruen, "[Fahrzeug aufgeschlossen]");
			vHupe(vehID);
			return 1;
		}
	}
}

ocmd:tanken(playerid, params[])
{
	#pragma unused params
	return ocmd_fill(playerid, params);
}

ocmd:fill(playerid, params[])
{
	for(new i=0; i<sizeof(BizData); i++)
	{
		if(!BizData[i][bID])continue;
		if(!IsPlayerInRangeOfPoint(playerid,B_enterdist,BizData[i][bX], BizData[i][bY], BizData[i][bZ])) continue;
		if(!strcmp(BizData[i][bName], "Tankstelle"))
		{
			new vehid = GetPlayerVehicleID(playerid);
			if(!IsValidVehicle(vehid)) return echo(playerid, cRot, "Du bist in keinem Fahrzeug");
			if(isSpawned[vehid] == true) return echo(playerid, cRot, "Dieses Auto kann nicht betankt werden.");
			if(VehicleData[vehid][vTank] >= 50) return echo(playerid, cRot, "Dein Auto ist bereits voll getankt.");
			if(BizData[i][bProds] < 1) return echo(playerid, cRot, "Die Zapfsäulen sind leer!");
			if(BizData[i][bOpen] == 0) return echo(playerid, cBlau, "Das Biz ist verschlossen.");
			new Float:noetig = 50.0 - VehicleData[vehid][vTank];
			new preis = BizData[i][bProdPreis] * floatround(noetig, floatround_round);
			if(SpielerInfo[playerid][pGeld] <= 0) return echo(playerid, cRot, "Du hast kein Geld.");
			if(preis <= 0) return echo(playerid, cRot, "Dein Auto ist bereits voll getankt.");
			if(SpielerInfo[playerid][pGeld] < preis)
			{
				new Float:menge = float(SpielerInfo[playerid][pGeld] / BizData[i][bProdPreis]);
				new string[128];
				format(string, sizeof(string), "[Tankstelle] Du hast für dein komplettes Geld getankt. [Menge: %.0f liter] [Preis: %d$]", menge, SpielerInfo[playerid][pGeld]);
				
				BizData[i][bKasse] = BizData[i][bKasse]+SpielerInfo[playerid][pGeld];
				AGivePlayerMoney(playerid, -SpielerInfo[playerid][pGeld]);
				VehicleData[vehid][vTank] = VehicleData[vehid][vTank]+menge;
				if(menge < 10) 
					BizData[i][bProds] --;
				else if(menge < 20) 
					BizData[i][bProds] = BizData[i][bProds]-2;
				else if(menge < 30) 
					BizData[i][bProds] = BizData[i][bProds]-3;
				else if(menge < 40) 
					BizData[i][bProds] = BizData[i][bProds]-4;
				else 
					BizData[i][bProds] = BizData[i][bProds]-5;

					
				echo(playerid, cGruen, string);
				return 1;
			}
			else
			{
				new string[128];
				format(string, sizeof(string), "[Tankstelle] Du hast für %d$ getankt. [Menge: %.0f liter]", preis, noetig);
				
				BizData[i][bKasse] = BizData[i][bKasse]+preis;
				AGivePlayerMoney(playerid, -preis);
				VehicleData[vehid][vTank] = VehicleData[vehid][vTank]+noetig;
				if(noetig < 10) 
					BizData[i][bProds] --;
				else if(noetig < 20) 
					BizData[i][bProds] = BizData[i][bProds]-2;
				else if(noetig < 30) 
					BizData[i][bProds] = BizData[i][bProds]-3;
				else if(noetig < 40) 
					BizData[i][bProds] = BizData[i][bProds]-4;
				else 
					BizData[i][bProds] = BizData[i][bProds]-5;

					
				echo(playerid, cGruen, string);
			}
		}
	}
	return 1;
}