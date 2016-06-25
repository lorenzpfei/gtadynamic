
forward vUpdateSecond(vehicleid);
public vUpdateSecond(vehicleid)
{
	if(VehicleData[vehicleid][vTank] > 0)
		VehicleData[vehicleid][vTank] -= 0.00925;
	
	new playerid = GetVehicleDriver(vehicleid);
	new string[128];
		
	if(VehicleData[vehicleid][vTank] > 50)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIIIIIIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 45)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIIIIIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 40)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIIIIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 35)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIIIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 30)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 25)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 20)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 15)
		format(string, sizeof(string), "KRAFTSTOFF: ~g~~h~IIII~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 10)
		format(string, sizeof(string), "KRAFTSTOFF: ~r~~h~III~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 5)
		format(string, sizeof(string), "KRAFTSTOFF: ~r~~h~II~n~0 KM");
	else if(VehicleData[vehicleid][vTank] >= 1)
		format(string, sizeof(string), "KRAFTSTOFF: ~r~~h~I~n~0 KM");
	else
	{
		format(string, sizeof(string), "KRAFTSTOFF: ~r~~h~LEER~n~0 KM");
		VehicleData[vehicleid][vTank] = 0;
		
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
		VehicleData[vehicleid][vEngine] = 0;
		
	}
	if(playerid != INVALID_PLAYER_ID)
		TextDrawSetString(tmh[playerid], string);
	return 1;
}