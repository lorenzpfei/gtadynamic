#include <a_samp>
new MAX_SPEED[MAX_VEHICLES];
new SPEED_TIMER[MAX_VEHICLES];


stock ResetVehicleSpeedMax(vehicleid)
{
MAX_SPEED[vehicleid] = 0;
}

stock SetVehicleSpeedMax(vehicleid,speedmax)
{
	MAX_SPEED[vehicleid] = speedmax;
}

forward sm_OnVehicleSpawn(vehicleid);
public sm_OnVehicleSpawn(vehicleid)
{
	MAX_SPEED[vehicleid] = 0;
}

forward sm_OnPlayerStateChange(playerid, newstate, oldstate);
public sm_OnPlayerStateChange(playerid, newstate, oldstate)
{
	new carid = GetPlayerVehicleID(playerid);
	{
		if(newstate == PLAYER_STATE_DRIVER)
		{
			SPEED_TIMER[carid] = SetTimerEx("UpdateVehiclesMAX",500,1,"i",carid);
		}
		if(oldstate == PLAYER_STATE_DRIVER)
		{
			KillTimer(SPEED_TIMER[carid]);
		}
	}
}

forward UpdateVehiclesMAX(vehicleid);
public UpdateVehiclesMAX(vehicleid)
{
	if(MAX_SPEED[vehicleid] != 0)
	{
		if(sm_GetVehicleSpeed(vehicleid) >= MAX_SPEED[vehicleid])
		{
			sm_SetVehicleSpeed(vehicleid,MAX_SPEED[vehicleid]);
		}
	}
}
		
		
stock sm_GetVehicleSpeed(vehicleid)
{
    new Float:X,Float:Y,Float:Z;
    new Float:Speed;
    GetVehicleVelocity(vehicleid, X, Y, Z);
    Speed = floatsqroot(X*X + Y*Y + Z*Z)*190;
    new dd;
    dd = floatround(Speed);
    return dd;
}

stock sm_SetVehicleSpeed(vehicleid, Float:speed)
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, Float:a;
    GetVehicleVelocity(vehicleid, x1, y1, z1);
    GetVehiclePos(vehicleid, x2, y2, z2);
    GetVehicleZAngle(vehicleid, a); a = 360 - a;
    x1 = (floatsin(a, degrees) * (speed/190) + floatcos(a, degrees) * 0 + x2) - x2;
    y1 = (floatcos(a, degrees) * (speed/190) + floatsin(a, degrees) * 0 + y2) - y2;
    SetVehicleVelocity(vehicleid, x1, y1, z1);
}