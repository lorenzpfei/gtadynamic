#include <a_samp>


new armyschranke1;
new armyschranke2;
new armyschrankev = 0;

new Tresortuer[4];
new Dynamit[8];

new moneyTresor[4];
new moneyTresorDoor[2];
new moneyTresorDynamit[2];


stock CreateObjects()
{
	
	
	//===================================== BANKTRESOR =======================================
	moneyTresor[0] = CreateDynamicObject(2003, 2144.75610, 1642.76233, 993.02509,   0.00000, 0.00000, 0.00000); //Links
	moneyTresor[1] = CreateDynamicObject(2003, 2143.29614, 1642.76233, 993.02509,   0.00000, 0.00000, 0.00000); 
	moneyTresorDoor[0] = CreateDynamicObject(2004, 2144.35840, 1642.50427, 993.02667,   0.00000, 0.00000, 0.00000); //links
	moneyTresorDoor[1] = CreateDynamicObject(2004, 2142.89844, 1642.50427, 993.02667,   0.00000, 0.00000, 0.00000);
	
	
	
	Tresortuer[0] = CreateDynamicObject(2634, 2144.17285, 1627.02075, 994.24432,   0.00000, 0.00000, 180.00000);
	Tresortuer[1] = CreateDynamicObject(2634, 2144.17285, 1627.08081, 994.24432,   0.00000, 0.00000, 180.00000);
	
	
	
	print("[START] ======== MAPS GELADEN ========");
	return 1;
}

stock RemoveMaps(playerid)
{
	
}