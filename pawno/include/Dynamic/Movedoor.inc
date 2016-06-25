enum movingDoors
{
	DoorModel,
    Float:aDoorX,
	Float:aDoorY,
	Float:aDoorZ,
	Float:aDoorRX,
	Float:aDoorRY,
	Float:aDoorRZ,
	Float:bDoorX,
	Float:bDoorY,
	Float:bDoorZ,
	Float:bDoorRX,
	Float:bDoorRY,
	Float:bDoorRZ,
	Float:DoorSpeed,
	Float:DoorOpenRange,
	DoorID,
	bool:DoorOpen,
	DoorFaction,
	DoorGrouping
}

#define MAX_MoveDoors 21

new moveDoorInfo[MAX_MoveDoors][movingDoors] =
{
	//Türen im PD
	{19302, 275.79709, 121.97370, 1004.85553,   0.00000, 0.00000, 90.00000,
	275.79709, 120.47370, 1004.85553,   0.00000, 0.00000, 90.00000,
	3.0, 5.0, 0, true, 1, 0},
	//Türen im PD
	{19302, 222.83560, 119.50960, 1010.47467,   0.00000, 0.00000, 0.00000,
	221.29559, 119.50960, 1010.47467,   0.00000, 0.00000, 0.00000,
	3.0, 5.0, 0, true, 1, 0},
	//Türen außerhalb des PD´s
	{10184, -1631.78931, 688.17407, 8.70070,   0.00000, 0.00000, 90.00000,
	-1631.72925, 688.17407, 3.68070,   0.00000, 0.00000, 90.00000,
	3.0, 10.0, 0, true, 1, 0},
	//Türen außerhalb des PD´s
	{13817,-1619.45593, 688.19360, 7.88520,   0.00000, 0.00000, 90.00000,
	-1619.45593, 688.19360, 4.80520,   0.00000, 0.00000, 90.00000,
	3.0, 5.0, 0, true, 1, 0},
	//Türen außerhalb des PD´s
	{19302, -1618.67920, 681.57703, 7.30420,   0.00000, 0.00000, 90.00000,
	-1618.67920, 681.57703, 4.92420,   0.00000, 0.00000, 90.00000,
	3.0, 5.0, 0, true, 1, 0},
	//Türen im PD
	{1495, 239.63721, 116.58170, 1002.21478,   0.00000, 0.00000, 90.00000,
	239.63721, 115.08170, 1002.21478,   0.00000, 0.00000, 90.00000,
	3.0, 5.0, 0, true, 1, 0},
	//Türen im PD
	{1495, 253.18829, 110.08810, 1002.21509,   0.00000, 0.00000, -90.00000,
	253.18829, 111.60810, 1002.21509,   0.00000, 0.00000, -90.00000,
	3.0, 5.0, 0, true, 1, 0},
	//Flugzeugtraeger Tor Boote
	{3113, -888.43781, 470.55911, 0.96120,   0.00000, 0.00000, 0.00000,
	-885.70947, 469.97839, -9.31880, 0.00000, 0.00000, 0.00000,
	3.0, 17.0, 0, true, 3, 0},
	//Plattform Flugzeugträger
	{3115, -879.37329, 470.55051, 16.82000,   0.00000, 0.00000, 0.00000,
	-879.33331, 470.53049, 9.76000,   0.00000, 0.00000, 0.00000,
	3.0, 20.0, 0, true, 3, 0},
	//Plattform Flugzeugträger
	{3114, -837.11713, 485.70731, 9.49700,   0.00000, 0.00000, 0.00000,
	-837.13708, 485.70731, 16.55700,   0.00000, 0.00000, 0.00000,
	3.0, 17.0, 0, true, 3, 0},
	//Tore in der Army
	{985, -1530.74878, 482.26685, 7.90130,   0.00000, 0.00000, -3.86000,
	-1538.58875, 482.80679, 7.90130,   0.00000, 0.00000, -3.86000,
	3.0, 5.0, 0, true, 3, 0},
	//Tore in der Army
	{985, -1522.90308, 481.73819, 7.90130,   0.00000, 0.00000, -3.86000,
	-1515.06311, 481.21820, 7.90130,   0.00000, 0.00000, -3.86000,
	3.0, 5.0, 0, true, 3, 0},
	//Tore in der Army
	{985, -1447.23840, 481.86972, 7.90130,   0.00000, 0.00000, 0.00000,
	-1441.35840, 481.86969, 7.90130,   0.00000, 0.00000, 0.00000,
	3.0, 5.0, 0, true, 3, 0},
	//Tore in der Army
	{985, -1317.39185, 481.94534, 7.90130,   0.00000, 0.00000, 0.00000,
	-1311.85181, 481.94531, 7.90130,   0.00000, 0.00000, 0.00000,
	3.0, 5.0, 0, true, 3, 0},
	//Tore in der Army
	{986, -1626.19397, 259.98981, 7.90020,   0.00000, 0.00000, 180.00000,
	-1620.65405, 259.98981, 7.90020,   0.00000, 0.00000, 180.00000,
	3.0, 5.0, 0, true, 3, 0},
	//Mechaniker Tür
	 {1499, -2163.69531, -225.81770, 35.42750,   0.00000, 0.00000, 0.00000,
	-2162.19531, -225.81770, 35.42750,   0.00000, 0.00000, 0.00000,
	3.0, 5.0, 0, true, 0, 2},
	//Mechaniker Tor
	{3037, -2180.71558, -210.01311, 36.89240,   0.00000, 0.00000, 0.00000,
	-2180.71558, -210.01311, 33.29240,   0.00000, 0.00000, 0.00000,
	3.0, 5.0, 0, true, 0, 2},
	//Fahrschule Tor
	{987, -2041.43396, -102.68730, 34.17520,   0.00000, 0.00000, 180.00000,
	-2053.33398, -102.68730, 34.17520,   0.00000, 0.00000, 180.00000,
	3.0, 10.0, 0, true, 1, 0},
	//O-Amt Tor
	{975, -1669.59998, -38.80000, 0.00000,   0.00000, 0.00000, 134.00000,
	-1679.59998, -28.40000, 4.20000,   0.00000, 0.00000, 133.99500,
	3.0, 10.0, 0, true, 2, 0},
	//O-Amt Tor
	{975, -1669.59961, -38.79980, 4.20000,   0.00000, 0.00000, 133.99500,
	-1679.59961, -28.40039, 0.00000,   0.00000, 0.00000, 133.99500,
	3.0, 10.0, 0, true, 2, 0},
	//O-Amt Tor
	{987, -1735.40002, -109.00000, 2.10000,   0.00000, 0.00000, 314.00000,
	-1735.40002, -109.00000, -3.80000,   0.00000, 0.00000, 314.00000,
	3.0, 10.0, 0, true, 2, 0}
};


stock MovedoorOnGameModeInit()
{
	new intMoveDoorAmount;
	for(new intDurchlauf; intDurchlauf < MAX_MoveDoors; intDurchlauf++)
	{
		moveDoorInfo[intDurchlauf][DoorID] = CreateDynamicObject(moveDoorInfo[intDurchlauf][DoorModel], moveDoorInfo[intDurchlauf][aDoorX], moveDoorInfo[intDurchlauf][aDoorY], moveDoorInfo[intDurchlauf][aDoorZ], moveDoorInfo[intDurchlauf][aDoorRX], moveDoorInfo[intDurchlauf][aDoorRY], moveDoorInfo[intDurchlauf][aDoorRZ]);
		intMoveDoorAmount = intDurchlauf;
	}
	printf("[START] BeweglicheTore geladen. [%d]", intMoveDoorAmount+1);
}


stock MovedoorOnPlayerStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerDriver(playerid) && (PRESSED(KEY_CROUCH)) || ((GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) && (PRESSED(KEY_YES))))
	{
		for(new intDurchlauf; intDurchlauf < MAX_MoveDoors; intDurchlauf++)
		{
			if(IsPlayerInRangeOfPoint(playerid, moveDoorInfo[intDurchlauf][DoorOpenRange], moveDoorInfo[intDurchlauf][aDoorX], moveDoorInfo[intDurchlauf][aDoorY], moveDoorInfo[intDurchlauf][aDoorZ]))
			{
				if((moveDoorInfo[intDurchlauf][DoorFaction] > 0) && (moveDoorInfo[intDurchlauf][DoorFaction] != SpielerInfo[playerid][pFraktion]))
				{
					continue;
				}
				if((moveDoorInfo[intDurchlauf][DoorGrouping] > 0) && (moveDoorInfo[intDurchlauf][DoorGrouping] != SpielerInfo[playerid][pGruppierung]))
				{
					continue;
				}
				if(moveDoorInfo[intDurchlauf][DoorOpen] == false)
				{
					MoveDynamicObject(moveDoorInfo[intDurchlauf][DoorID], moveDoorInfo[intDurchlauf][bDoorX], moveDoorInfo[intDurchlauf][bDoorY], moveDoorInfo[intDurchlauf][bDoorZ], moveDoorInfo[intDurchlauf][DoorSpeed], moveDoorInfo[intDurchlauf][bDoorRX], moveDoorInfo[intDurchlauf][bDoorRY], moveDoorInfo[intDurchlauf][bDoorRZ]);
					moveDoorInfo[intDurchlauf][DoorOpen] = true;
					return 1;
				}
				else
				{
					MoveDynamicObject(moveDoorInfo[intDurchlauf][DoorID], moveDoorInfo[intDurchlauf][aDoorX], moveDoorInfo[intDurchlauf][aDoorY], moveDoorInfo[intDurchlauf][aDoorZ], moveDoorInfo[intDurchlauf][DoorSpeed], moveDoorInfo[intDurchlauf][aDoorRX], moveDoorInfo[intDurchlauf][aDoorRY], moveDoorInfo[intDurchlauf][aDoorRZ]);
					moveDoorInfo[intDurchlauf][DoorOpen] = false;
					return 1;
				}
			}
		}
	}
	return 1;
}