/*
==================================================
=================== TO DO LIST ===================
==================================================
LEGENDE: 
   [ ] = Offen
   [T] = Vorbereitet/Teilweise fertig
   [X] = Fertig


[X] [30.06.2014] Gangfight System
[X] [01.07.2014] Enters und Vehgates mit VirtualWorld kennzeichnen
[X] [01.07.2014] Fahrzeuge werden nicht an ihrer Position gespeichert (FIX)
[X] [02.07.2014] Einige Fahrzeug Befehle erstellen (/vinfo, /lock) 
[X] [03.07.2014] Waffen speichern
[X] [05.07.2014] Werbung
[X] [06.07.2014] Connect Kamera ändern
[X] [07.07.2014] Lotto
[X] [14.07.2014] Dynamisches ATM System
[T] [] Tank System
[X] [07.11.2014] Todespickups
[X] [12.11.2014] Flagge in GF einbauen
[] [] Shopfight
[] [] Live Speicherung
[] [] Passwörter umstellen von MD5 auf etwas ?sicheres?
[] [] Dynamische Fraktions-/Gruppierungsfahrzeuge (OnDialogResponse asettings)
[] [] Bank System (Bankkarte, PIN, ATM)
[] [] /gsettings und /fsettings verbessern (Rang adden, löschen etc)
[] [] ASettings erweitern
[] [] Clan Tag verbieten (+ Regipage)
[] [] Animationen hinzufügen
[] [] Anticheat
[] [] BSN etc mit Animation  Cest la vie auch 
[T] [] Bann System
[] [] Tacho Design ändern
[] [] GFStand Design ändern
[] [] zonetext in 24/7 als Navi kaufbar
[T] [] Bankraub
[] [] 24/7 Raub
[] [] Busbots


==================================================
*/

#include <a_samp>
native IsValidVehicle(vehicleid);
#include <ocmd>
#include <a_mysql>
#include <md5>
//#include <callbacks>
#include <sscanf2>
#include <a_npc>
#include <dini>
#include <vehcolors>
#include <streamer>
#include <Dynamic/Maps>
#include <GetVehicleColor>
#include <afk>

//SCRIPTINTERN
#include <Dynamic/Config>
#include <Dynamic/Defines>
#include <Dynamic/Dialogs>
#include <Dynamic/Enters>
#include <Dynamic/Houses>
#include <Dynamic/Business>
#include <Dynamic/Vehgates>
#include <Dynamic/Atm>
#include <Dynamic/Werbung>
#include <Dynamic/Vehicles>
#include <Dynamic/Dutypoints>
#include <Dynamic/Infopoints>
#include <Dynamic/Gangfight>
#include <Dynamic/Movedoor>
#include <Dynamic/Zonenames>
#include <Dynamic/Vehnames>

//============== DEFINITIONEN =================
#define MAX_GANGRANKS 10
#define MAX_FRAKTIONRANKS 10
#define MIN_CONTRACTMONEY 1000

//FAHRZEUGE
#define VTYPE_CAR 1
#define VTYPE_HEAVY 2
#define VTYPE_MONSTER 3
#define VTYPE_BIKE 4
#define VTYPE_QUAD 5
#define VTYPE_BMX 6
#define VTYPE_HELI 7
#define VTYPE_PLANE 8
#define VTYPE_SEA 9
#define VTYPE_TRAILER 10
#define VTYPE_TRAIN 11
#define VTYPE_BOAT VTYPE_SEA
#define VTYPE_BICYCLE VTYPE_BMX

//====== SETTINGS ========
#define GET_EXP 100
#define SERVER_SLOGAN "Slogan"


//=======BANKROB========
new bankrobstarted = 0;
new bankrobTresorR = 0;
new bankrobTresorL = 0;

new moneyTresorR = 0;
new moneyTresorL = 0;

//======Spielerrekord======
new spieleronline = 0;
new spielerrekord;


new Tempo[MAX_PLAYERS] = -1;

new restartvar = 0;

new clpl[MAX_PLAYERS];

new Text:underdollar[MAX_PLAYERS];

new Text:u_h_r;
new Text:u_h_d;

new Text:xwanted[MAX_PLAYERS];


new Text:Login0;
new Text:Login1;
new Text:LoginNews;
new Text:LoginNewsHead;

new Text:LoginServername;
new Text:LoginSlogan;

//Tacho
new Text:kmh[MAX_PLAYERS];
new Text:kmhBox;
new Text:tmh[MAX_PLAYERS];
new Text:tachoVeh[MAX_PLAYERS];
new Text:tachoStrich;
new TachoTimer[MAX_PLAYERS];

#include <Dynamic/Tank>


//Infobox
new Text:InfobarBox;
new Text:InfobarText[MAX_PLAYERS];

//ANTICHEAT
new antiCheatTimer[MAX_PLAYERS];
forward UpdateCheat(playerid);
new unverwundbarkeitTimer[MAX_PLAYERS];
forward CheckUnverwundbarkeit(playerid, Float:hp);


forward UpdateClock();
forward TimeUpdate();

//Spieler laden
new Text:td1992;

new weather;
new iconid;


//Tickets
new TicketZeile[MAX_PLAYERS]; 
new SupportTicket[MAX_PLAYERS]; 
new TicketAngenommen[MAX_PLAYERS]; 
new DeinSupport[MAX_PLAYERS]; 
new DeinGrund[MAX_PLAYERS][128]; 
forward UpdateTickets();
new Text:Hintergrund;
new Text:Ueberschrift;
new Text:Ticket;
new Text:Verdichtung;
new Text:Strich;

new Text:Logo1;
new Text:Logo2;
new Text:Logo3;
new Text:Zonetext[MAX_PLAYERS];

new SecondTimer[MAX_PLAYERS];
	

enum knast_info
{
	Float:knast_x, Float:knast_y, Float:knast_z
}

new KnastSpawns[3] [knast_info] =
{
	{264.2028, 86.5352, 1001.0391},
	{264.1775, 82.1307, 1001.0391},
	{263.8978, 77.5281, 1001.0391}
};

enum paintball_info
{
	Float:p_x, Float:p_y, Float:p_z
}

new PaintballSpawns[7] [paintball_info] =
{
	{959.3135, 2098.0034, 1011.0234},
	{948.2693, 2104.9888, 1011.0234},
	{933.4009, 2129.7693, 1011.0234},
	{950.6957, 2148.9263, 1011.0234},
	{934.2119, 2176.4285, 1011.0234},
	{953.9312, 2176.3513, 1011.0234},
	{964.3407, 2160.5857, 1011.0303}
};


enum weaponpickup_info
{
	pWeaponID, pWeaponPickupID
}

new WeaponPickupID[44] [weaponpickup_info] = 
{
	{0, 0},
	{1, 331},
	{2, 333},
	{3, 334},
	{4, 335},
	{5, 336},
	{6, 337},
	{7, 338},
	{8, 339},
	{9, 341},
	{10, 321},
	{11, 322},
	{12, 323},
	{13, 324},
	{14, 325},
	{15, 326},
	{16, 342},
	{17, 343},
	{18, 344},
	{0, 0},
	{0, 0},
	{0, 0},
	{22, 346},
	{23, 347},
	{24, 348},
	{25, 349},
	{26, 350},
	{27, 351},
	{28, 352},
	{29, 353},
	{30, 355},
	{31, 356},
	{32, 372},
	{33, 357},
	{34, 358},
	{35, 359},
	{36, 360},
	{37, 361},
	{38, 362},
	{39, 363},
	{40, 364},
	{41, 365},
	{42, 366},
	{43, 367}
};


new VehicleColoursTableARGB[256] = 
{
	// The existing colours from San Andreas
	0xFF000000,0xFFF5F5F5,0xFFA1772A,0xFF100484,0xFF393726,0xFF6E4486,0xFF108ED7,0xFFB7754C,0xFFC6BEBD,0xFF72705E,
	0xFF7A5946,0xFF796A65,0xFF8D7E5D,0xFF5A5958,0xFFD6DAD6,0xFFA3A19C,0xFF3F5F33,0xFF1A0E73,0xFF2A0A7B,0xFF949D9F,
	0xFF784E3B,0xFF3E2E73,0xFF3B1E69,0xFF8C9196,0xFF595451,0xFF453E3F,0xFFA7A9A5,0xFF5A5C63,0xFF684A3D,0xFF929597,
	0xFF211F42,0xFF2B275F,0xFFAB9484,0xFF7C7B76,0xFF646464,0xFF52575A,0xFF272525,0xFF353A2D,0xFF96A393,0xFF887A6D,
	0xFF181922,0xFF5F676F,0xFF2A1C7C,0xFF150A5F,0xFF263819,0xFF201B5D,0xFF72989D,0xFF60757A,0xFF869598,0xFFB0B0AD,
	0xFF888984,0xFF454F30,0xFF68624D,0xFF482216,0xFF4B2F27,0xFF56627D,0xFFABA49E,0xFF718D9C,0xFF22186D,0xFF81684E,
	0xFF989C9C,0xFF477391,0xFF261C66,0xFF9F9D94,0xFFA5A7A4,0xFF468C8E,0xFF1E1A34,0xFF8C7A6A,0xFF8EADAA,0xFF8F98AB,
	0xFF2E1F85,0xFF97826F,0xFF535858,0xFF90A79A,0xFF231A60,0xFF2C2020,0xFF96A0A4,0xFF849DAA,0xFF2B2278,0xFF6D310E,
	0xFF3F2A72,0xFF5E717B,0xFF281D74,0xFF322E1E,0xFF2F324D,0xFF441B7C,0xFF205B2E,0xFF835A39,0xFF37286D,0xFF8FA2A7,
	0xFFB1B1AF,0xFF554136,0xFF6E6C6D,0xFF896A0F,0xFF6B4B20,0xFF573E2B,0xFF9D9F9B,0xFF95846C,0xFF95844D,0xFF7F9BAE,
	0xFF8F6C40,0xFF3B251F,0xFF7692AB,0xFF734513,0xFF6C8196,0xFF6A6864,0xFF825010,0xFF8399A1,0xFF945638,0xFF615652,
	0xFF56697F,0xFF9A928C,0xFF876E59,0xFF323547,0xFF4F6244,0xFF270A73,0xFF573422,0xFF1B0D64,0xFFC6ADA3,0xFF535869,
	0xFF808B9B,0xFF1C0B62,0xFF5E5D5B,0xFF284462,0xFF271873,0xFF6D371B,0xFFAE6AEC,0xFF000000,
	// SA-MP erweiterte Farben (0.3x)
	0xFF177517,0xFF060621,0xFF785412,0xFF0D2A45,0xFF1E1E57,0xFF010701,0xFF5A2225,0xFFAA892C,0xFFBD4D8A,0xFF3A9635, // 128-137
	0xFFB7B7B7,0xFF8D4C46,0xFF8C8884,0xFF677881,0xFF267A81,0xFF6F506A,0xFF6F3E58,0xFF72B98C,0xFF784F82,0xFF6A276D, // 138-147
	0xFF131D1E,0xFF06131E,0xFF18251F,0xFF31452C,0xFF994C1E,0xFF435F2E,0xFF48991E,0xFF99991E,0xFF769999,0xFF99847C, // 148-157
	0xFF1E2E99,0xFF081E2C,0xFF072414,0xFF4D3E99,0xFF994C1E,0xFF818119,0xFF2A291A,0xFF6F6116,0xFF87661B,0xFF993F6C, // 158-167
	0xFF0E1A48,0xFF99737A,0xFF996D74,0xFF7E3853,0xFF072422,0xFF0C193E,0xFF0E2146,0xFF1E1E99,0xFF8D4C8D,0xFF805B80, // 168-177
	0xFF7E3E7B,0xFF37173C,0xFF173573,0xFF181878,0xFF1A3483,0xFF1C2F8E,0xFF533E7E,0xFF7C6D7C,0xFF020C02,0xFF072407, // 178-187
	0xFF123016,0xFF1B3016,0xFF4F2B64,0xFF528436,0xFF909599,0xFF968D81,0xFF1E9999,0xFF4C997F,0xFF929283,0xFF228278, // 188-197
	0xFF993C2B,0xFF0B3A3A,0xFF4E798A,0xFF491F0E,0xFF1C3715,0xFF3A2715,0xFF755737,0xFF200806,0xFF261307,0xFF4B3920, // 198-207
	0xFF89502C,0xFF6C4215,0xFF503210,0xFF631624,0xFF152069,0xFF948D8C,0xFF136051,0xFF020F09,0xFF3A578C,0xFF8E8852, // 208-217
	0xFF525C99,0xFF1E5899,0xFF633A99,0xFF4E8F99,0xFF1E3199,0xFF42180D,0xFF1E1E52,0xFF0D4242,0xFF1E994C,0xFF1D2A08, // 218-227
	0xFF1D8296,0xFF197F19,0xFF1F143B,0xFF175274,0xFF8D3F89,0xFF6C1A7E,0xFF0B370B,0xFF0D4527,0xFF241F07,0xFF734578, // 228-237
	0xFF3A658A,0xFF172673,0xFF909431,0xFF1D9456,0xFF3D1659,0xFF2F8A1B,0xFF0B1638,0xFF041804,0xFF8E5D35,0xFF5B3F2E,  // 238-247
	0xFF281A56,0xFF270E4E,0xFF676C70,0xFF423E3B,0xFF332D2E,0xFF7D7E7B,0xFF42444A,0xFF4E3428
};

stock AGivePlayerMoney(playerid, geld)
{
	SpielerInfo[playerid][pGeld] += geld;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, SpielerInfo[playerid][pGeld]);
	new eidi[24];
	valstr(eidi, SpielerInfo[playerid][peID]);
	mysql_UpdateInt("accounts", "money", SpielerInfo[playerid][pGeld], "id", eidi);
}

stock ResetPlayerMonez(playerid)
{
	SpielerInfo[playerid][pGeld] = 0;
	ResetPlayerMoney(playerid);
	new eidi[24];
	valstr(eidi, SpielerInfo[playerid][peID]);
	mysql_UpdateInt("accounts", "money", 0, "id", eidi);
	return 1;
}
stock GetPlayerMonez(playerid)
	return SpielerInfo[playerid][pGeld]; // Oder lieber jedes Mal aus der Datenbank abrufen?

// Bis zu diesen Definierungen sind die normalen Funktionen noch aktiv. Ab hier werden diese dann überschrieben.
#define GivePlayerMoney AGivePlayerMoney
#define GetPlayerMoney GetPlayerMonez
#define ResetPlayerMoney ResetPlayerMonez

main()
{

}







public OnGameModeInit()
{
	AntiDeAMX();
	
	Connect_To_Database();
	
	
	new strVersion [64];
	format(strVersion, sizeof(strVersion), "==                    Version %s                  ==", Version());
	print("\n=====================================================");
	print("==                                                 ==");
	print("==                 DYNAMIC ROLEPLAY                ==");
	print("==                                                 ==");
	print("==                   BY ELDIABOLO                  ==");
	print("==                   BY  BUBELBUB                  ==");
	print("==                                                 ==");
	print(strVersion);
	print("==                                                 ==");
	print("=====================================================");
	print("hiaaaa");
	
	//================= NPCS =================

	ConnectNPC("[DYN]Wurzel_Sepp","Wurzel");
	print("[Start - BOTS]Seppl is hier :)");

	//============================================
	
	
	mysql_debug(false);

	
	//STANDARDS
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
 	EnableStuntBonusForAll(0);
	ManualVehicleEngineAndLights();
	
	
	restartvar = 0;
	
	new hour;
	gettime(hour);
	SetWorldTime(hour);
	
	
	//GLOBALS LADEN
	LoadGlobals();
	
	//========================================== WETTER ==========================================
	weather=random(20);
	SetWeather(weather);
	printf("[START] Wetter geladen. [%d]", weather);
	
	EnterOnGameModeInit();
	
	//========================================== VEHGATES ==========================================
	mysql_query("SELECT COUNT(`id`) FROM `vehicle_gates`");
	mysql_store_result();
	new jV = mysql_fetch_int();
	mysql_free_result();
    
	new vehgateamount = 0;
	for(new d = 0; d != jV+1; d++)
	{
		new e[16];
		format(e, sizeof(e), "%d", d);
		if((mysql_GetFloat("vehicle_gates", "x", "id", e) != 0.0) || (mysql_GetFloat("vehicle_gates", "y", "id", e) != 0.0) || (mysql_GetFloat("vehicle_gates", "z", "id", e) != 0.0))
		{
			vehgateamount ++;
		}
		if(mysql_GetInt("vehicle_gates", "visible", "id", e) == 1)
		{
			CreatePickup(1318,1,mysql_GetFloat("vehicle_gates", "x", "id", e),mysql_GetFloat("vehicle_gates", "y", "id", e),mysql_GetFloat("vehicle_gates", "z", "id", e),-1); 
		}
		if(mysql_GetInt("vehicle_gates", "to_visible", "id", e) == 1)
		{
			CreatePickup(1318,1,mysql_GetFloat("vehicle_gates", "to_x", "id", e),mysql_GetFloat("vehicle_gates", "to_y", "id", e),mysql_GetFloat("vehicle_gates", "to_z", "id", e),-1); 
		}
	}
	printf("[START] Vehgates geladen. [%d]", vehgateamount);
	
	DutypointsOnGameModeInit();
	InfopointsOnGameModeInit();
	
	HouseOnGameModeInit();
	BizOnGameModeInit();
	VehicleOnGameModeInit();
	
	GangzoneOnGameModeInit();
	
	AtmOnGameModeInit();
	
	MovedoorOnGameModeInit();
	//========================================== SPIELERREKORD ==========================================
	spielerrekord = mysql_GetInt("server", "record", "id", "1");
	
	//========================================== AUTOHAUS ==========================================
	CreatePickup(1239, 0, -1659.2321, 1212.4449, 13.6719, -1);
	Create3DTextLabel("/Autohaus",cHellblau,-1659.2321, 1212.4449, 13.6719, 10.0, 0);
	print("[START] Autohaus geladen.");
	
	
	//========================================== SPIELER LADEN ==========================================
	new strCopyright[128];
	format(strCopyright, sizeof(strCopyright), "%s - %s~n~Bitte warten...",Servername(), Homepage());
	td1992 = TextDrawCreate(315.000000,201.000000,strCopyright);
	TextDrawAlignment(td1992,2);
	TextDrawBackgroundColor(td1992,0x00000000);
	TextDrawFont(td1992,1);
	TextDrawLetterSize(td1992,0.199999,1.000000);
	TextDrawColor(td1992,0xffffffff);
	TextDrawSetOutline(td1992,1);
	TextDrawSetProportional(td1992,1);
	TextDrawSetShadow(td1992,1);
	
	
	//========================================== TICKETS ==========================================	
	Login0 = TextDrawCreate(-22.000000, -15.000000, "_");
	TextDrawBackgroundColor(Login0, 255);
	TextDrawFont(Login0, 1);
	TextDrawLetterSize(Login0, 1.560000, 16.399999);
	TextDrawColor(Login0, -1);
	TextDrawSetOutline(Login0, 0);
	TextDrawSetProportional(Login0, 1);
	TextDrawSetShadow(Login0, 1);
	TextDrawUseBox(Login0, 1);
	TextDrawBoxColor(Login0, 255);
	TextDrawTextSize(Login0, 667.000000, -38.000000);

	Login1 = TextDrawCreate(680.000000, 311.000000, "_");
	TextDrawBackgroundColor(Login1, 255);
	TextDrawFont(Login1, 1);
	TextDrawLetterSize(Login1, 0.500000, 17.200000);
	TextDrawColor(Login1, -1);
	TextDrawSetOutline(Login1, 0);
	TextDrawSetProportional(Login1, 1);
	TextDrawSetShadow(Login1, 1);
	TextDrawUseBox(Login1, 1);
	TextDrawBoxColor(Login1, 255);
	TextDrawTextSize(Login1, -50.000000, -31.000000);
	
	LoginNews = TextDrawCreate(308.000213, 341.392639, "Wird geladen...");
	TextDrawLetterSize(LoginNews, 0.243665, 1.139554);
	TextDrawAlignment(LoginNews, 2);
	TextDrawColor(LoginNews, -1);
	TextDrawSetShadow(LoginNews, 0);
	TextDrawSetOutline(LoginNews, 1);
	TextDrawBackgroundColor(LoginNews, 51);
	TextDrawFont(LoginNews, 1);
	TextDrawSetProportional(LoginNews, 1);
	
	LoginNewsHead = TextDrawCreate(307.333435, 314.014648, "Servernews");
	TextDrawLetterSize(LoginNewsHead, 0.399999, 2.218072);
	TextDrawAlignment(LoginNewsHead, 2);
	TextDrawColor(LoginNewsHead, -5963521);
	TextDrawSetShadow(LoginNewsHead, 0);
	TextDrawSetOutline(LoginNewsHead, 1);
	TextDrawBackgroundColor(LoginNewsHead, 51);
	TextDrawFont(LoginNewsHead, 3);
	TextDrawSetProportional(LoginNewsHead, 1);
	
	LoginServername = TextDrawCreate(314.333282, 29.866662, "GTA Dynamic");
	TextDrawLetterSize(LoginServername, 0.693666, 3.557926);
	TextDrawAlignment(LoginServername, 2);
	TextDrawColor(LoginServername, -1);
	TextDrawSetShadow(LoginServername, 0);
	TextDrawSetOutline(LoginServername, 1);
	TextDrawBackgroundColor(LoginServername, 51);
	TextDrawFont(LoginServername, 3);
	TextDrawSetProportional(LoginServername, 1);

	LoginSlogan = TextDrawCreate(322.333251, 59.318504, SERVER_SLOGAN);
	TextDrawLetterSize(LoginSlogan, 0.449999, 1.600000);
	TextDrawAlignment(LoginSlogan, 1);
	TextDrawColor(LoginSlogan, -5963521);
	TextDrawSetShadow(LoginSlogan, 0);
	TextDrawSetOutline(LoginSlogan, 1);
	TextDrawBackgroundColor(LoginSlogan, 51);
	TextDrawFont(LoginSlogan, 3);
	TextDrawSetProportional(LoginSlogan, 1);
	
	//STRICHER STRICH
	tachoStrich = TextDrawCreate(375.666656, 406.103698, "LD_SPAC:white");
	TextDrawLetterSize(tachoStrich, 0.000000, 0.000000);
	TextDrawTextSize(tachoStrich, -119.999984, 1.244444);
	TextDrawAlignment(tachoStrich, 1);
	TextDrawColor(tachoStrich, -1);
	TextDrawSetShadow(tachoStrich, 0);
	TextDrawSetOutline(tachoStrich, 0);
	TextDrawFont(tachoStrich, 4);
	
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
	
	
	//================================= LOGO ==========================================
	
	Logo1 = TextDrawCreate(53.000000, 317.000000, "Dynamic");
	TextDrawBackgroundColor(Logo1, 255);
	TextDrawFont(Logo1, 0);
	TextDrawLetterSize(Logo1, 0.540000, 2.700000);
	TextDrawColor(Logo1, -1);
	TextDrawSetOutline(Logo1, 1);
	TextDrawSetProportional(Logo1, 1);

	new strLogoVersion[26];
	format(strLogoVersion, sizeof(strLogoVersion), "V %s", Version());
	Logo2 = TextDrawCreate(113.000000, 336.000000, strLogoVersion);
	TextDrawBackgroundColor(Logo2, 255);
	TextDrawFont(Logo2, 2);
	TextDrawLetterSize(Logo2, 0.129998, 1.100000);
	TextDrawColor(Logo2, -5614849);
	TextDrawSetOutline(Logo2, 1);
	TextDrawSetProportional(Logo2, 1);
	
	Logo3 = TextDrawCreate(57.000000, 313.000000, SERVER_SLOGAN);
	TextDrawBackgroundColor(Logo3, 255);
	TextDrawFont(Logo3, 2);
	TextDrawLetterSize(Logo3, 0.129998, 1.100000);
	TextDrawColor(Logo3, -5614849);
	TextDrawSetOutline(Logo3, 1);
	TextDrawSetProportional(Logo3, 1);

	Hintergrund = TextDrawCreate(502.000000, 133.000000, "_");
	TextDrawBackgroundColor(Hintergrund, 255);
	TextDrawFont(Hintergrund, 3);
	TextDrawLetterSize(Hintergrund, 0.050000, 15.299999);
	TextDrawColor(Hintergrund, -1);
	TextDrawSetOutline(Hintergrund, 0);
	TextDrawSetProportional(Hintergrund, 1);
	TextDrawSetShadow(Hintergrund, 1);
	TextDrawUseBox(Hintergrund, 1);
	//TextDrawBoxColor(Hintergrund, 100);
	TextDrawBoxColor(Hintergrund,0x00000033);
	TextDrawTextSize(Hintergrund, 605.000000, 366.000000);

	Verdichtung = TextDrawCreate(608.000000, 133.000000, "_________");
	TextDrawBackgroundColor(Verdichtung, 255);
	TextDrawFont(Verdichtung, 1);
	TextDrawLetterSize(Verdichtung, 0.260000, 1.900000);
	TextDrawColor(Verdichtung, -1);
	TextDrawSetOutline(Verdichtung, 0);
	TextDrawSetProportional(Verdichtung, 1);
	TextDrawSetShadow(Verdichtung, 1);
	TextDrawUseBox(Verdichtung, 1);
	TextDrawBoxColor(Verdichtung, 100);
	TextDrawTextSize(Verdichtung, 499.000000, 18.000000);

	Ueberschrift = TextDrawCreate(534.000000, 134.000000, "Tickets");
	TextDrawBackgroundColor(Ueberschrift, 255);
	TextDrawFont(Ueberschrift, 1);
	TextDrawLetterSize(Ueberschrift, 0.330000, 1.399999);
	TextDrawColor(Ueberschrift, -94829057);
	TextDrawSetOutline(Ueberschrift, 0);
	TextDrawSetProportional(Ueberschrift, 1);
	TextDrawSetShadow(Ueberschrift, 1);

	Strich = TextDrawCreate(608.000000, 153.000000, "___________");
	TextDrawBackgroundColor(Strich, 255);
	TextDrawFont(Strich, 1);
	TextDrawLetterSize(Strich, 0.500000, -0.200000);
	TextDrawColor(Strich, -1);
	TextDrawSetOutline(Strich, 0);
	TextDrawSetProportional(Strich, 1);
	TextDrawSetShadow(Strich, 1);
	TextDrawUseBox(Strich, 1);
	TextDrawBoxColor(Strich, -65281);
	TextDrawTextSize(Strich, 499.000000, 0.000000);


	Ticket = TextDrawCreate(504.000000, 158.000000, "");
	TextDrawBackgroundColor(Ticket, 255);
	TextDrawFont(Ticket, 1);
	TextDrawLetterSize(Ticket, 0.200000, 1.000000);
	TextDrawColor(Ticket, -65281);
	TextDrawSetOutline(Ticket, 0);
	TextDrawSetProportional(Ticket, 1);
	TextDrawSetShadow(Ticket, 1);
	
	//Infobox
	InfobarBox = TextDrawCreate(608.333374, 114.329635, "usebox");
	TextDrawLetterSize(InfobarBox, 0.000000, 1.526954);
	TextDrawTextSize(InfobarBox, 498.666656, 0.000000);
	TextDrawAlignment(InfobarBox, 1);
	TextDrawColor(InfobarBox, 0);
	TextDrawUseBox(InfobarBox, true);
	TextDrawBoxColor(InfobarBox, 102);
	TextDrawSetShadow(InfobarBox, 0);
	TextDrawSetOutline(InfobarBox, 0);
	TextDrawFont(InfobarBox, 0);
	
	GFStandBox = TextDrawCreate(392.666656, 5.233333, "usebox");
	TextDrawLetterSize(GFStandBox, 0.000000, 1.665226);
	TextDrawTextSize(GFStandBox, 213.000000, 0.000000);
	TextDrawAlignment(GFStandBox, 1);
	TextDrawColor(GFStandBox, 0);
	TextDrawUseBox(GFStandBox, true);
	TextDrawBoxColor(GFStandBox, 102);
	TextDrawSetShadow(GFStandBox, 0);
	TextDrawSetOutline(GFStandBox, 0);
	TextDrawFont(GFStandBox, 0);
	
	GFStandText = TextDrawCreate(303.333343, 6.637037, "~r~Angreifer   ~w~0  -  1~b~   Verteidiger");
	TextDrawLetterSize(GFStandText, 0.232000, 1.330370);
	TextDrawAlignment(GFStandText, 2);
	TextDrawColor(GFStandText, -1);
	TextDrawSetShadow(GFStandText, 0);
	TextDrawSetOutline(GFStandText, 1);
	TextDrawBackgroundColor(GFStandText, 51);
	TextDrawFont(GFStandText, 1);
	TextDrawSetProportional(GFStandText, 1);
	
	WerbungOnGameModeInit();
	
	
	u_h_r = TextDrawCreate(547.000000,23.000000,"UHR");
	u_h_d = TextDrawCreate(547.000000,36.000000,"UHR");
	TextDrawAlignment(u_h_r,0);
	TextDrawAlignment(u_h_d,0);
	TextDrawBackgroundColor(u_h_r,0x00000033);
	TextDrawBackgroundColor(u_h_d,0x00000033);
	TextDrawFont(u_h_r,3);
	TextDrawLetterSize(u_h_r,0.299999,1.400000);
	TextDrawFont(u_h_d,3);
	TextDrawLetterSize(u_h_d,0.199999,0.799999);
	TextDrawColor(u_h_r,0xffffffff);
	TextDrawColor(u_h_d,0xffffffff);
	TextDrawSetOutline(u_h_r,1);
	TextDrawSetOutline(u_h_d,1);
	TextDrawSetProportional(u_h_r,1);
	TextDrawSetProportional(u_h_d,1);
	TextDrawSetShadow(u_h_r,1);
	TextDrawSetShadow(u_h_d,1);

	SetTimer("UpdateClock",1000,1);
	SetTimer("TimeUpdate",1000,1);
	SetTimer("Savegame", 600000, 1);
	SetTimer("TempoUpdate",100,1);
	
	UpdateTickets();
	
	CreateObjects();
	
	print("[START] Textdraw geladen.");
	
	arrFlagtyp[0] = -1;
	arrFlagtyp[1] = -1;
	arrFlagtyp[2] = -1;
	
	SetTimer("Afk", 1000, true);
	
	AddPlayerClass(5,1456.7605,2773.3208,10.8203,270.5923,0,0,0,0,0,0);
	return 1;
}

forward Afk();
public Afk()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerNPC(i))
		{
			if(GetPVarInt(i, "Eingeloggt") == 1) 
			{
				if(IsPlayerOnDesktop(i))
				{
					//printf("desk - %s", SpielerName(i)); //todo: Fixxen
				}
			}
		}
	}
	return 1;
}

ocmd:savegame(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin!");
	Savegame();
	return 1;
}

forward Savegame();

public Savegame()
{
	new strAdm[128];
	new count=GetTickCount();
	SaveAllStuff();
	format(strAdm, sizeof(strAdm), "[SAVEGAME] Alles gespeichert. Dauer: [%d ms]", GetTickCount()-count);
	Adminecho(cGelb, strAdm);
	return 1;
}


public OnGameModeExit()
{
	HouseOnGameModeExit();
	BizOnGameModeExit();
	if(restartvar == 0)
	{
		SaveAllStuff();
		echoAll(cOrange, "Der Server wurde beendet.");
	}
	else
	{
		SaveAllStuff();
		echoAll(cOrange, "Der Server wurde neu gestartet.");
	}
	echoAll(cOrange, "Bitte gedulde dich eine Weile, bis er wieder läuft.");
	
	mysql_close();
	
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetSpawnInfo(playerid, 0, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0 );
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	RemoveMaps(playerid);
	if(playerid > MAX_PLAYERS)
	{
		new strError[128];
		format(strError, sizeof strError, "[SCHWERER FEHLER] MAX_PLAYERS ANPASSEN! (PLAYERID %d) (MAX %d)", playerid, MAX_PLAYERS);
		Adminecho(cGelb, strError);
		Kick(playerid);
		return 1;
	}
	if(IsPlayerNPC(playerid))
	{
		SetPVarInt(playerid,"Eingeloggt",1);
		if(!strcmp(SpielerName(playerid), "[DYN]Wurzel_Sepp", true))
		{
			SpielerInfo[playerid][pAdminlevel] = 5;
			SpielerInfo[playerid][pAond] = 1;
			SetPlayerColor(playerid,0xFFFFFF00);
		}
		return 1;
	}
	
	TextDrawShowForPlayer(playerid, Login0);
	TextDrawShowForPlayer(playerid, Login1);
	
	new strAMotd[128];
	format(strAMotd, sizeof(strAMotd), "%s", mysql_GetString("server", "motd", "id", "1"));
	TextDrawSetString(LoginNews, strAMotd);
	TextDrawShowForPlayer(playerid, LoginNews);
	TextDrawShowForPlayer(playerid, LoginNewsHead);
	TextDrawShowForPlayer(playerid, LoginServername);
	TextDrawShowForPlayer(playerid, LoginSlogan);
	
	for(new i; i < 15; i++)
	{
		SendClientMessage(playerid, cSchwarz, "");
	}
	
	if(!mysql_CheckAccount(playerid))
	{
		//Kein Acc vorhanden
		SetPVarInt(playerid, "LoginKamera", 1);
		new string[128];
		format(string, sizeof(string), "Du hast noch keinen Account. Bitte erstelle dir einen: %s" ,Homepage());
		ShowPlayerDialog(playerid, diaNoAcc, DIALOG_STYLE_MSGBOX, "FEHLER", string, "Okay", "");
		KickTimer(playerid, 10);
	}
	/*else
	{
		new string[128];
		SendClientMessage(playerid, cRot, "[Fehler] {e13333}Es ist ein Fehler mit der Datenbank unterlaufen. Bitte wende dich an einen Administrator.");
		format(string, sizeof(string), "%s hatte einen Fehler mit der Datenbank und wurde deshalb gekickt.", SpielerName(playerid));
		print(string);
		KickTimer(playerid, 10);
	}
	*/
	new b = mysql_GetInt("accounts", "banned", "name", SpielerName(playerid));
	if(b == 0)
	{
		new str1[128];
		format(str1, sizeof(str1), "%s", SpielerName(playerid));
		//if(strfind(str1,"_",true) != -1)
		//{
		if(mysql_CheckAccount(playerid))
		{
			SetPVarInt(playerid, "LoginKameraPos", 1);
			SetTimerEx("LoginKamera", 100, false, "i", playerid);
			new string[200], string2[50];
			format(string2,sizeof(string2),"{FF8A05}Login");
			format(string,sizeof(string),"{FFFFFF}Willkommen zurück, {FF8A05}%s{FFFFFF}!\nGib bitte dein Passwort ein, um den Server zu betreten.\nBitte passe auf, dass nur du dein Passwort kennst!",SpielerName(playerid));
			ShowPlayerDialog(playerid, diaLogin,DIALOG_STYLE_PASSWORD,string2, string,"Einloggen","");
		}
	//}
	//else
	//{
	//	SendClientMessage(playerid, cRot, "Fehler: Ungültiger Name. Gewünscht: {ffffff}Vorname_Nachname");
	//	KickTimer(playerid, 10);
	//}
	}
	else
	{
		new strBann[128], strBann2[128];
		if(b == 1) //TIME BANN
		{
			format(strBann, sizeof(strBann), "Du wurdest vom Server bis zum [X] gesperrt.");
			format(strBann2, sizeof(strBann2), "Grund: [%s] Ausführender Admin: [X]", mysql_GetString("accounts", "ban_reason", "name", SpielerName(playerid)));
			SendClientMessage(playerid, cRot, strBann);
			SendClientMessage(playerid, cRot, "Du kannst nicht mit deinem Account spielen.");
			SendClientMessage(playerid, cRot, strBann2);
			SendClientMessage(playerid, cRot, "Solltest du Einwände oder Fragen haben, melde dich im Forum oder im Teamspeak.");
			KickTimer(playerid, 100);
		}
		if(b == 2) //TIME BANN IP
		{
			format(strBann, sizeof(strBann), "Du wurdest vom Server bis zum [X] gesperrt. (IP BANN)");
			format(strBann2, sizeof(strBann2), "Grund: [%s] Ausführender Admin: [X]", mysql_GetString("accounts", "ban_reason", "name", SpielerName(playerid)));
			SendClientMessage(playerid, cRot, strBann);
			SendClientMessage(playerid, cRot, "Du kannst nicht mit deinem Account spielen.");
			SendClientMessage(playerid, cRot, strBann2);
			SendClientMessage(playerid, cRot, "Solltest du Einwände oder Fragen haben, melde dich im Forum oder im Teamspeak.");
			KickTimer(playerid, 100);
		}
		if(b == 3) //Perma Bann
		{
			format(strBann, sizeof(strBann), "Du wurdest permanent vom Server gesperrt.");
			format(strBann2, sizeof(strBann2), "Grund: [%s] Ausführender Admin: [X]", mysql_GetString("accounts", "ban_reason", "name", SpielerName(playerid)));
			SendClientMessage(playerid, cRot, strBann);
			SendClientMessage(playerid, cRot, "Du kannst nicht mit deinem Account spielen.");
			SendClientMessage(playerid, cRot, strBann2);
			SendClientMessage(playerid, cRot, "Solltest du Einwände oder Fragen haben, melde dich im Forum oder im Teamspeak.");
			KickTimer(playerid, 100);
		}
		if(b == 4)//PERMA BANN IP
		{
			format(strBann, sizeof(strBann), "Du wurdest permanent vom Server gesperrt. (IP BANN)");
			format(strBann2, sizeof(strBann2), "Grund: [%s] Ausführender Admin: [X]", mysql_GetString("accounts", "ban_reason", "name", SpielerName(playerid)));
			SendClientMessage(playerid, cRot, strBann);
			SendClientMessage(playerid, cRot, "Du kannst nicht mit deinem Account spielen.");
			SendClientMessage(playerid, cRot, strBann2);
			SendClientMessage(playerid, cRot, "Solltest du Einwände oder Fragen haben, melde dich im Forum oder im Teamspeak.");
			KickTimer(playerid, 100);
		}
	}
	
	//========================================== KARTENSYMBOLE ==========================================
	CreateMapIcon(playerid, -1951.6475, 641.0552, 46.5625, 38, 0, 0); //Spawn
	
	BizOnPlayerConnect(playerid);
	EnterOnPlayerConnect(playerid);
	//========================================== TICKETS ==========================================
	TicketZeile[playerid] = 0;
	SupportTicket[playerid] = 0;
	TicketAngenommen[playerid] = 0;
	DeinSupport[playerid] = 0;
	
	TextDrawHideForPlayer(playerid, Hintergrund);
	TextDrawHideForPlayer(playerid, Ueberschrift);
	TextDrawHideForPlayer(playerid, Verdichtung);
	TextDrawHideForPlayer(playerid, Ticket);
	TextDrawHideForPlayer(playerid, Strich);
	
	//========================================== TEXTDRAWS ==========================================
	
	InfobarText[playerid] = TextDrawCreate(551.666748, 113.244445, "~r~Spawnschutz");
	TextDrawLetterSize(InfobarText[playerid], 0.309000, 1.641481);
	TextDrawTextSize(InfobarText[playerid], -152.333282, 167.170349);
	TextDrawAlignment(InfobarText[playerid], 2);
	TextDrawColor(InfobarText[playerid], -1);
	TextDrawSetShadow(InfobarText[playerid], 0);
	TextDrawSetOutline(InfobarText[playerid], 1);
	TextDrawBackgroundColor(InfobarText[playerid], 51);
	TextDrawFont(InfobarText[playerid], 1);
	TextDrawSetProportional(InfobarText[playerid], 1);
	
	kmh[playerid] = TextDrawCreate(315.000000,362.000000,"0 km/h");
	tmh[playerid] = TextDrawCreate(317.000000,384.000000,"KRAFTSTOFF: ~g~~h~IIIIIIIIII~n~0 KM");
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
	
	Zonetext[playerid] = TextDrawCreate(88.666694, 421.866668, "Downtown");
	TextDrawLetterSize(Zonetext[playerid], 0.295333, 1.512888);
	TextDrawAlignment(Zonetext[playerid], 2);
	TextDrawColor(Zonetext[playerid], 0xffffffff);
	TextDrawSetShadow(Zonetext[playerid], 1);
	TextDrawSetOutline(Zonetext[playerid], 1);
	TextDrawBackgroundColor(Zonetext[playerid], 51);
	TextDrawFont(Zonetext[playerid], 1);
	TextDrawSetProportional(Zonetext[playerid], 1);	
	
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
	
	
	underdollar[playerid]=TextDrawCreate(498.000000,99.000000,"~g~]000 - Wird geladen");
	TextDrawAlignment(underdollar[playerid],0);
	TextDrawBackgroundColor(underdollar[playerid],0x000000ff);
	TextDrawFont(underdollar[playerid],2);
	TextDrawLetterSize(underdollar[playerid],0.199999,1.000000);
	TextDrawColor(underdollar[playerid],0xffffffff);
	TextDrawSetOutline(underdollar[playerid],1);
	TextDrawSetProportional(underdollar[playerid],1);
	TextDrawSetShadow(underdollar[playerid],1);
	
	xwanted[playerid] = TextDrawCreate(501.000000,111.000000," ");
	TextDrawAlignment(xwanted[playerid],0);
	TextDrawBackgroundColor(xwanted[playerid],0x00000033);
	TextDrawFont(xwanted[playerid],2);
	TextDrawLetterSize(xwanted[playerid],0.399999,1.300000);
	TextDrawColor(xwanted[playerid],0xffffffff);
	TextDrawSetOutline(xwanted[playerid],1);
	TextDrawSetProportional(xwanted[playerid],1);
	TextDrawSetShadow(xwanted[playerid],1);
	
	antiCheatTimer[playerid] = SetTimerEx("UpdateCheat",1000,1, "i", playerid);
	return 1;
}

stock CreateMapIcon(playerid, Float:x, Float:y, Float:z, markertype, color, style)
{
	SetPlayerMapIcon(playerid, iconid, Float:x, Float:y, Float:z, markertype, color, style);
	iconid ++;
}


forward LoginKamera(playerid);
public LoginKamera(playerid)
{
	if(GetPVarInt(playerid, "Eingeloggt") == 1) 
		return 1;
	if(GetPVarInt(playerid, "LoginKameraPos") == 1)
	{
		TogglePlayerSpectating(playerid, 1);
		SetPlayerPos(playerid, -2212.3594, 553.0010, 34.2820);
		SetPlayerVirtualWorld(playerid, 99);
		InterpolateCameraPos(playerid, -2551.106933, 664.716674, 73.172340, -2504.664550, 628.062683, 73.172340, 6000, 1);
		InterpolateCameraLookAt(playerid, -2553.273193, 661.650085, 71.792854, -2507.128417, 624.985473, 72.494377, 6000, 1);
		SetPVarInt(playerid, "LoginKameraPos", 2);
		SetTimerEx("LoginKamera", 6000, false, "i", playerid);
		return 1;
	}
	else if(GetPVarInt(playerid, "LoginKameraPos") == 2)
	{
		InterpolateCameraPos(playerid, -2504.664550, 628.062683, 73.172340, -2488.793212, 590.993347, 60.071250, 1000, 1);
		InterpolateCameraLookAt(playerid, -2507.128417, 624.985473, 72.494377, -2488.676513, 587.138671, 59.009143, 1000, 1);
		SetPVarInt(playerid, "LoginKameraPos", 3);
		SetTimerEx("LoginKamera", 1000, false, "i", playerid);
		return 1;
	}
	else if(GetPVarInt(playerid, "LoginKameraPos") == 3)
	{
		InterpolateCameraPos(playerid, -2488.793212, 590.993347, 60.071250, -2439.582275, 575.382324, 52.368869, 4000, 1);
		InterpolateCameraLookAt(playerid, -2488.676513, 587.138671, 59.009143, -2441.416015, 571.983215, 51.327869, 4000, 1);
		SetPVarInt(playerid, "LoginKameraPos", 4);
		SetTimerEx("LoginKamera", 4000, false, "i", playerid);
		return 1;
	}
	else if(GetPVarInt(playerid, "LoginKameraPos") == 4)
	{
		InterpolateCameraPos(playerid, -2439.582275, 575.382324, 52.368869, -2311.433593, 592.479797, 74.368980, 3000, 1);
		InterpolateCameraLookAt(playerid, -2441.416015, 571.983215, 51.327869, -2309.122070, 589.393005, 73.306877, 3000, 1);
		SetPVarInt(playerid, "LoginKameraPos", 5);
		SetTimerEx("LoginKamera", 3000, false, "i", playerid);
		return 1;
	}
	else
	{
		InterpolateCameraPos(playerid, -2311.433593, 592.479797, 74.368980, -2215.698486, 571.861816, 82.911743, 6000, 1);
		InterpolateCameraLookAt(playerid, -2309.122070, 589.393005, 73.306877, -2218.525146, 569.690612, 81.096298, 6000, 1);
		DeletePVar(playerid, "LoginKameraPos");
		return 1;
	}
}

public OnPlayerDisconnect(playerid, reason)
{
	SetPlayerScore(playerid, 0);
	if(IsPlayerNPC(playerid))
	{
		SpielerInfo[playerid][pAdminlevel] = 0;
		SpielerInfo[playerid][pAond] = 0;
		return 1;
	}
	if(GetPVarInt(playerid, "Eingeloggt") == 1)
	{
		GangfightOnPlayerDisconnect(playerid);
		
		
		//Position speichern
		new Float:x,Float:y,Float:z, saveInterior;
		GetPlayerPos(playerid,x,y,z);
		saveInterior = GetPlayerInterior(playerid);
		SpielerInfo[playerid][pPosX] = Float:x;
		SpielerInfo[playerid][pPosY] = Float:y;
		SpielerInfo[playerid][pPosZ] = Float:z;
		SpielerInfo[playerid][pPosInt] = saveInterior;
		
		SavePlayer(playerid);
		DeSpawnPlayerVehicles(playerid, 1);
		SaveWeapon(playerid);
		
		new string[128];
		if(restartvar == 0)
		{
			for(new i=0; i<MAX_PLAYERS; i++)
			{
					if(SpielerInfo[i][pJoined] == 0 || SpielerInfo[i][pJoined] == 2)
					{
						switch(reason)
						{
							case 0: format(string, sizeof(string), "[Verbindung unterbrochen] %s hat den Server verlassen.", SpielerName(playerid));
							case 1: format(string, sizeof(string), "[Beendet] %s hat den Server verlassen.", SpielerName(playerid));
							case 2: return 0;
						}
						SendClientMessage(i, cRot, string);
					}
			}
		}
		
		spieleronline --;
		
		HideInfobar(playerid);
		HideGFStand(playerid);
		

		TextDrawHideForPlayer(playerid, underdollar[playerid]);
		TextDrawHideForPlayer(playerid,u_h_r);
		TextDrawHideForPlayer(playerid,u_h_d);
		TextDrawHideForPlayer(playerid,xwanted[playerid]);
		
		TextDrawHideForPlayer(playerid,Logo1);
		TextDrawHideForPlayer(playerid,Logo2);
		TextDrawHideForPlayer(playerid,Logo3);
		TextDrawHideForPlayer(playerid,Zonetext[playerid]);	
		
		TextDrawHideForPlayer(playerid,kmh[playerid]);
		TextDrawHideForPlayer(playerid,tmh[playerid]);
		TextDrawHideForPlayer(playerid,kmhBox);
		
		KillTimer(SecondTimer[playerid]);
		
		HideTacho(playerid);
		
		new save[512];
		format(save,sizeof save,"Tickets/%s.ini",SpielerName(playerid));
		if(dini_Exists(save)) // Ob ein Ticket offen ist
		{
			dini_Remove(save);
			TicketZeile[playerid] = 0;
			TicketAngenommen[playerid] = 0;
			DeinSupport[playerid] = 0;
			SupportTicket[playerid] = 0;
			DeinGrund[playerid] = "";
			UpdateTickets();
		}
		
		//VARS LÖSCHEN
		for(new i = 0; i < sizeof(SpielerInfo[]); i++)
		{
			SpielerInfo[playerid][SpielerDaten:i] = 0;
		}
		for(new i = 0; i < sizeof(PlayerInfo[]); i++)
		{
			PlayerInfo[playerid][TSpielerDaten:i] = 0;
		}
		
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	
	if(GetPVarInt(playerid, "LoginKamera") == 1)
	{
		print("login kamera");
		LoginKamera(playerid);
		return 1;
	}
	
	
	if(GetPVarInt(playerid, "Eingeloggt") != 1) return 1;
	
	SetPlayerSkin(playerid, SpielerInfo[playerid][pSkin]);
	
	if(GetPVarInt(playerid, "copyrightSpieler") == 1)
	{
		SetPlayerPos(playerid, -1943.0544, 536.6857, 209.7817);
		SetPlayerFacingAngle(playerid, 52.3149);
		SetCameraBehindPlayer(playerid);
		SetPlayerVirtualWorld(playerid, 99);
		return 1;
	}
	
	if(GetPVarInt(playerid, "pWillkommen") == 1)
	{
		DeletePVar(playerid, "pWillkommen");
		SpawnPlayerDynamic(playerid);
		Willkommen(playerid);
		return 1;
	}
	
	if(GetPVarInt(playerid, "Biz") == 1)
	{
		SpawnPaintball(playerid);
		return 1;
	}
	else
	{
		SpawnPlayerDynamic(playerid);
	}
	return 1;
}

new arrDeathWeapon[MAX_PLAYERS*2][5];


getFreePickupID()
{
	for(new i;i<sizeof(arrDeathWeapon);i++)
	{
		if(!arrDeathWeapon[i][2]) return i;
	}
	return -1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	printf("pickuppickup: %d", pickupid);
	GangfightOnPlayerPickUpPickup(playerid, pickupid);
	//Todespickups
	for(new i;i<sizeof(arrDeathWeapon);i++)
	{
		if(arrDeathWeapon[i][0] == pickupid)
		{
			printf("picked: %d", pickupid);
			DestroyPickup(pickupid);
			if(arrDeathWeapon[i][1] >= 0)
			{
				GivePlayerWeapon(playerid, arrDeathWeapon[i][1], arrDeathWeapon[i][2]);
			}
			arrDeathWeapon[i][0] = 0;
			arrDeathWeapon[i][1] = 0;
			arrDeathWeapon[i][2] = 0;
		}
		if(arrDeathWeapon[i][3] == pickupid)
		{
			printf("picked: %d", pickupid);
			DestroyPickup(pickupid);
			if(arrDeathWeapon[i][3] >= 0)
			{
				GivePlayerMoney(playerid, arrDeathWeapon[i][4]);
			}
			arrDeathWeapon[i][3] = 0;
			arrDeathWeapon[i][4] = 0;
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	HideTacho(playerid);
	if(GetPVarInt(playerid, "Biz") == 1)
	{
		GameTextForPlayer(killerid,"~g~~>~Paintballkill!~<~",2200,6);
		return 1;
	}
	new Float:Koords[3];
	GetPlayerPos(playerid, Koords[0], Koords[1], Koords[2]);
	
	GangfightOnPlayerDeath(playerid, killerid);
	
	new pickupid = getFreePickupID();
	if(pickupid > -1)
	{
		print("nach pickup");
		
		new weaponid = GetPlayerWeapon(playerid),
			ammo = GetPlayerAmmo(playerid);
		printf("weaponid= %d & ammo=%d", weaponid, ammo);
		if(weaponid && ammo)
		{
			printf("spawned %d ,, %d", WeaponPickupID[weaponid][pWeaponPickupID], weaponid);
			arrDeathWeapon[pickupid][0] = CreatePickup(WeaponPickupID[weaponid][pWeaponPickupID], 1, Koords[0], Koords[1], Koords[2], -1);
			arrDeathWeapon[pickupid][1] = weaponid;
			arrDeathWeapon[pickupid][2] = ammo;
		}
		new	money = SpielerInfo[playerid][pGeld];
		new dropMoney = 1000;
		if(money >= dropMoney)
		{
			GivePlayerMoney(playerid, -dropMoney);
			printf("spawned %d", pickupid);
			arrDeathWeapon[pickupid][3] = CreatePickup(1212, 1, Koords[0] + 0.5, Koords[1] + 0.5, Koords[2], -1);
			arrDeathWeapon[pickupid][4] = dropMoney;
		}
		else if(money > 0)
		{
			GivePlayerMoney(playerid, -money);
			printf("spawned %d", pickupid);
			arrDeathWeapon[pickupid][3] = CreatePickup(1212, 1, Koords[0] + 0.5, Koords[1] + 0.5, Koords[2], -1);
			arrDeathWeapon[pickupid][4] = money;
		}
	}
	if(SpielerInfo[playerid][pMask] == 1)
	{
		SpielerInfo[playerid][pMask] = 0; 
		echo(playerid, cGruppe, "[Hitman Agency]Deine Maske ist abgefallen.");
	}
	if(SpielerInfo[playerid][pKopfgeld] >= 1)
	{
		if(SpielerInfo[killerid][pGruppierung] == 1)
		{
			new strPlayer[128], strHitman[128];
			format(strPlayer, sizeof(strPlayer), "~b~%s~n~~w~ausgeschaltet~n~~g~%d$ erhalten", SpielerName(playerid), SpielerInfo[playerid][pKopfgeld]);
			format(strHitman, sizeof(strHitman), "[Hitman] >> %s wurde von %s ausgeschaltet! <<", SpielerName(playerid), SpielerName(killerid));
			AGivePlayerMoney(killerid, SpielerInfo[playerid][pKopfgeld]);			
			SpielerInfo[playerid][pKopfgeld] = 0;
			EchoGruppierung(1, strHitman);
			GameTextForPlayer(killerid,strPlayer,2200,3);
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(SpielerInfo[i][pGruppierung] == 1)
				{
					PlayerPlaySound(i,1058,0,0,0);
				}
			}
		}
	}
	if(((SpielerInfo[killerid][pFraktion] != 1) || (SpielerInfo[killerid][pGruppierung] != 1)) && (SpielerInfo[killerid][pDuty] != 1))
	{
		suspect(0, killerid, 3, "Mord");
	}
	if((SpielerInfo[playerid][pWanteds] > 0) && (SpielerInfo[killerid][pFraktion] == 1))
	{
		new strKILL[128];
		format(strKILL, sizeof(strKILL), "[EILMELDUNG] Officer %s hat den Gesuchten %s ausgeschaltet!", SpielerName(killerid), SpielerName(playerid));
		echoAll(cRot, strKILL);
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(SpielerInfo[i][pFraktion] == 1)
			{
				PlayerPlaySound(i,1057,0,0,0);
			}
		}
		SetWanteds(playerid, 0);
		GameTextForPlayer(killerid, "~r~Gesuchten~n~ausgeschaltet", 1200, 1);
		//knast setzen
		GameTextForPlayer(playerid, "~r~Willkommen im Knast", 1200, 1);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(GetPVarInt(playerid, "Eingeloggt") == 1)
	{
		new string[128];
		format(string,sizeof(string),"%s sagt: {ffffff}%s",SpielerName(playerid),text);
		SendClientMessageInRange(playerid,string,cOrange,20);
		print(string);
	}
	return 0;
}

new ActorCJ;

ocmd:createactor(playerid)
{
	new Float:x, Float:y, Float:z, Float:r;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	ActorCJ = CreateActor(0, x, y, z, r);
	
	SetActorInvulnerable(ActorCJ, false);
	return 1;
}

ocmd:checkactor(playerid)
{
	new Float:actorHealth;
    GetActorHealth(ActorCJ, actorHealth);
    printf("Actor ID %d has %.2f health.", ActorCJ, actorHealth);
	if(IsActorInvulnerable(ActorCJ))
    {
        print("Actor is invulnerable.");
    }
    else
    {
        print("Actor is vulnerable.");
    }
	return 1;
}

ocmd:setactor(playerid)
{
	new strRtrn = SetActorHealth(ActorCJ, 0);
	printf("set %d", strRtrn);
	return 1;
}


ocmd:tune(playerid)
{
	if(!IsPlayerDriver(playerid)) return echo(playerid, cRot, "Du bist in keinem Fahrzeug!");
	if(IsPlayerInRangeOfPoint(playerid, 7.0, -2177.2407,-260.9210,36.5156)) //Hebedingens
	{
		ShowDialog(playerid, diaTuning, DIALOG_STYLE_LIST, "Tuning Menü", "Auspuff ändern\nFronststoßstange ändern\nHeckstoßstange ändern\nDach ändern\nSpoiler ändern\nSeitenteile ändern\nRäder ändern", "Auswählen", "Abbrechen");
	}
	else if(IsPlayerInRangeOfPoint(playerid, 7.0, -2178.6567,-246.7156,36.5156))
	{
		ShowDialog(playerid, diaTuningMotor, DIALOG_STYLE_LIST, "Tuning Menü", "Neon anbringen\nHydraulik einbauen\nNitro einbauen\nBass einbauen", "Auswählen", "Abbrechen");
	}
	else if(IsPlayerInRangeOfPoint(playerid, 7.0, -2127.5547,-257.8443,35.3446)) //Umspray Dingens
	{
		ShowDialog(playerid, diaColorTuning, DIALOG_STYLE_LIST, "Lackierer Menü", "Paintjob ändern\nFarben ändern\nFahrzeug reparieren", "Färben", "Abbrechen");
	}
	return 1;
}

ocmd:gotovw(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin");
	new vw, strPlayer[128];
	if(sscanf(params,"i",vw))return echo(playerid, cRot,"Benutzung: /gotovw [World]");
	format(strPlayer, sizeof(strPlayer), "[AdmCmd] %s hat dich in die virtuelle Welt mit der Nummer %d gesetzt.", SpielerName(playerid), vw);
	echo(playerid, cRot, strPlayer);
	SetPlayerVirtualWorld(playerid, vw);
	return 1;
}


ocmd:setlevel(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin");
	new pID, lvl, strPlayer[128], strAdmin[128];
	if(sscanf(params,"ui",pID, lvl))return echo(playerid, cRot,"Benutzung: /setlevel [Spieler] [Level]");
	format(strPlayer, sizeof(strPlayer), "[AdmCmd] %s hat dich auf Level %d gesetzt.", SpielerName(playerid), lvl);
	format(strAdmin, sizeof(strAdmin), "[AdmCmd] Du hast %s auf das Level %d gesetzt.", SpielerName(pID), lvl);
	echo(playerid, cRot, strAdmin);
	echo(pID, cRot, strPlayer);
	SpielerInfo[pID][pLevel] = lvl;
	SetPlayerScore(pID, lvl);
	return 1;
}

ocmd:getcommands(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin");
	new strRead[256], strAusgabe[2048];
	new File:Commands;
	if(dini_Exists("/Commands/AlleBefehle.txt"))
	{
		Commands = fopen("/Commands/AlleBefehle.txt", io_read);
		while(fread(Commands,strRead))
		{
			format(strAusgabe,sizeof strAusgabe, "%s%s",strAusgabe,strRead);
		}
		fclose(Commands);
		ShowDialog(playerid, diaCommands, DIALOG_STYLE_MSGBOX, "Alle Befehle", strAusgabe, "Fertig", "");
	}
	else
	{
		echo(playerid, cRot, "Datei nicht vorhanden.");
	}
	return 1;
}

ocmd:setweather(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 4)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	ShowDialog(playerid,diaWeather,DIALOG_STYLE_LIST,"Wetter auswaehlen!", "Schoenwetter\nbewoelkt\nRegen+Sturm\nnebelig\nextreme Hitze\npinker Nebel\nregnerisch\nSandsturm\nblauer Himmel\ntuerkieser Himmel\ngrauer Himmel\nSonnenaufgang\nSonnenuntergang\nkommendes Gewitter","Anwenden","Abbrechen");
	return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	AtmOnPlayerEditDynamicObject(playerid, objectid, response, x, y, z, rx, ry, rz);
	return 1;
}

ocmd:avgethere(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 4)) return echo(playerid, cRot, "Du bist kein Admin.");
	new int, string[128], Float:ax, Float:ay, Float:az, Float:ar, aint;
	if(sscanf(params,"i",int))return echo(playerid,cRot,"Benutzung: /avgethere [vID]");
	if(!IsValidVehicle(int)) return echo(playerid, cRot, "Fehler: Ungültige ID");
	format(string, sizeof(string), "Du hast das Fahrzeug mit der ID %d zu dir geportet.", int);
	GetPlayerPos(playerid, ax, ay, az);
	GetPlayerFacingAngle(playerid, ar);
	aint = GetPlayerInterior(playerid);
	
	SetVehicleZAngle(int, ar);
	SetVehiclePos(int, ax, ay+5, az);
	LinkVehicleToInterior(int, aint);
	
	echo(playerid, cRot, string);
	return 1;
}

ocmd:avgoto(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Admin.");
	new int, string[128], Float:ax, Float:ay, Float:az, Float:ar;
	if(sscanf(params,"i",int))return echo(playerid,cRot,"Benutzung: /avgoto [vID]");
	if(!IsValidVehicle(int)) return echo(playerid, cRot, "Fehler: Ungültige ID");
	format(string, sizeof(string), "Du hast dich zum Fahrzeug mit der ID [%d] geportet.", int);
	GetVehiclePos(int, ax, ay, az);
	GetVehicleZAngle(int, ar);
	
	SetPlayerPos(playerid, ax, ay, az+5);
	SetPlayerFacingAngle(playerid, ar);
	
	echo(playerid, cRot, string);
	return 1;
}

ocmd:settings(playerid, params[])
{
	#pragma unused params
	new strSettings[512], strSpawn[56], strJoin[80];
	
	if(SpielerInfo[playerid][pSpawn] == 0) 
	{
		format(strSpawn, sizeof(strSpawn), "Standardspawn");
	}
	if(SpielerInfo[playerid][pSpawn] == 1) 
	{
		format(strSpawn, sizeof(strSpawn), "Letzter Standort");
	}
	if(SpielerInfo[playerid][pSpawn] == 2) 
	{
		format(strSpawn, sizeof(strSpawn), "Fraktion");
	}
	if(SpielerInfo[playerid][pSpawn] == 3)
	{
		format(strSpawn, sizeof(strSpawn), "Gruppierung");
	}
	
	if(SpielerInfo[playerid][pJoined] == 0) 
	{
		format(strJoin, sizeof(strJoin), "Betreten & Beendet");
	}
	if(SpielerInfo[playerid][pJoined] == 1) 
	{
		format(strJoin, sizeof(strJoin), "Nur Betreten");
	}
	if(SpielerInfo[playerid][pJoined] == 2) 
	{
		format(strJoin, sizeof(strJoin), "Nur Beendet");
	}
	if(SpielerInfo[playerid][pJoined] == 3) 
	{
		format(strJoin, sizeof(strJoin), "Keine");
	}
	format(strSettings, sizeof(strSettings), "Spawn: [%s] \nNachrichten: [%s]", strSpawn, strJoin);
	ShowDialog(playerid, diaSettings, DIALOG_STYLE_LIST, "Einstellungen", strSettings, "Ändern", "Fertig");
	return 1;
}

ocmd:fraks(playerid, params[])
{
	#pragma unused params
	new strAllFraks[1024];
	for(new i = 1; i <= 10; i++)
	{
		new e[8];
		format(e, sizeof(e), "%d", i);
		if((mysql_GetInt("factions", "id", "id", e) == i))
		{
			format(strAllFraks, sizeof(strAllFraks), "%s %d [%s]\n", strAllFraks, i, mysql_GetString("factions", "name", "id", e));
		}
	}
	ShowDialog(playerid, diaInfo, DIALOG_STYLE_LIST, "Alle Fraktionen", strAllFraks, "Okay", "");
	return 1;
}

ocmd:grupps(playerid, params[])
{
	#pragma unused params
	new strAllFraks[1024];
	for(new i = 1; i <= 10; i++)
	{
		new e[8];
		format(e, sizeof(e), "%d", i);
		if((mysql_GetInt("groupings", "id", "id", e) == i))
		{
			format(strAllFraks, sizeof(strAllFraks), "%s %d [%s]\n", strAllFraks, i, mysql_GetString("groupings", "name", "id", e));
		}
	}
	ShowDialog(playerid, diaInfo, DIALOG_STYLE_LIST, "Alle Gruppierungen", strAllFraks, "Okay", "");
	return 1;
}

ocmd:gruppierungen(playerid, params[])
{
	#pragma unused params
	return ocmd_grupps(playerid, params);
}

ocmd:fraktionen(playerid, params[])
{
	#pragma unused params
	return ocmd_fraks(playerid, params);
}

ocmd:motor(playerid, params[])
{
	#pragma unused params
	return ocmd_vhelp(playerid, params);
}

ocmd:lights(playerid, params[])
{
	#pragma unused params
	return ocmd_vhelp(playerid, params);
}

ocmd:licht(playerid, params[])
{
	#pragma unused params
	return ocmd_vhelp(playerid, params);
}

ocmd:motd(playerid, params[])
{
	#pragma unused params
	ShowMOTD(playerid);
	return 1;
}

ocmd:allvehs(playerid, params[])
{
	#pragma unused params
	new strAllVehs[3048];
	for(new i = 400; i < maxSpaner+400; i++)
	{
		if(strcmp(getcarname(i), "Nicht gültig!")) 
		{
			format(strAllVehs, sizeof(strAllVehs), "%s %s [ID: %d]\n", strAllVehs, getcarname(i), i);
		}
	}
	ShowDialog(playerid, diaAllvehs, DIALOG_STYLE_LIST, "Alle Fahrzeuge", strAllVehs, "Okay", "");
	return 1;
}

ocmd:savepos(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5))return echo(playerid, cRot, "Du bist kein Fulladmin.");
	new Float:x, Float:y, Float:z, int, vw, string[128];
	GetPlayerPos(playerid, x, y, z);
	int = GetPlayerInterior(playerid);
	vw = GetPlayerVirtualWorld(playerid);
	PlayerInfo[playerid][saveX] = x;
	PlayerInfo[playerid][saveY] = y;
	PlayerInfo[playerid][saveZ] = z;
	PlayerInfo[playerid][saveInt] = int;
	PlayerInfo[playerid][saveVW] = vw;
	format(string, sizeof(string),"Du hast deine Position erfolgreich gespeichert.");
	admcmd(playerid, cRot, string);
	return 1;
}

ocmd:loadpos(playerid, params[])
{
	new string[128];
	if(!isPlayerAnAdmin(playerid, 5))return echo(playerid, cRot, "Du bist kein Fulladmin.");
	if((PlayerInfo[playerid][saveX] == 0) && (PlayerInfo[playerid][saveY] == 0) && (PlayerInfo[playerid][saveZ] == 0)) return echo(playerid, cRot, "Du hast keine Position gespeichert.");
	SetPlayerPos(playerid, PlayerInfo[playerid][saveX], PlayerInfo[playerid][saveY], PlayerInfo[playerid][saveZ]);
	SetPlayerInterior(playerid, PlayerInfo[playerid][saveInt]);
	SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][saveVW]);
	format(string, sizeof(string),"Du hast dich zu deiner gespeicherten Position teleportiert.");
	admcmd(playerid, cRot, string);
	return 1;
}

ocmd:freeze(playerid, params[])
{
	new pID, strAdmin[128], strSpieler[128];
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter.");
	if(sscanf(params, "u", pID)) return echo(playerid, cRot, "Benutzung: /freeze [Spieler]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	TogglePlayerControllable(pID, 0);
	format(strAdmin, sizeof(strAdmin), "Du hast %s gefreezed.", SpielerName(pID));
	format(strSpieler, sizeof(strSpieler), "%s hat dich gefreezed.", SpielerName(playerid));
	admcmd(playerid, cRot, strAdmin);
	admcmd(pID, cRot, strSpieler);
	return 1;
}

ocmd:unfreeze(playerid, params[])
{
	new pID, strAdmin[128], strSpieler[128];
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter.");
	if(sscanf(params, "u", pID)) return echo(playerid, cRot, "Benutzung: /unfreeze [Spieler]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	TogglePlayerControllable(pID, 1);
	format(strAdmin, sizeof(strAdmin), "Du hast %s unfreezed.", SpielerName(pID));
	format(strSpieler, sizeof(strSpieler), "%s hat dich unfreezed.", SpielerName(playerid));
	admcmd(playerid, cRot, strAdmin);
	admcmd(pID, cRot, strSpieler);
	return 1;
}

ocmd:spec(playerid,params[])
{
    new pID;
    if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter.");
    if(sscanf(params,"u",pID)) return echo(playerid,cRot,"Benutzung: /spec [Spieler]");
    if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
    if(IsPlayerInAnyVehicle(pID))
    {
        TogglePlayerSpectating(playerid, 1);
        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(pID));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pID));
		SetPlayerInterior(playerid, GetPlayerInterior(pID));
        return 1;
    }
    else
    {
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectatePlayer(playerid, pID);
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pID));
		SetPlayerInterior(playerid, GetPlayerInterior(pID));
		return 1;
	}
}

ocmd:slap(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 2)) return echo(playerid, cRot, "Du bist kein Moderator.");
	new pID, Float:X, Float:Y, Float:Z, string[128], string2[128];
    if(sscanf(params,"u",pID))return echo(playerid, cRot,"Benutzung: /slap [Spieler]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
    if(GetPVarInt(playerid, "Adminlevel") < GetPVarInt(pID, "Adminlevel")) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
    format(string, sizeof(string), "Du hast %s geslappt.", SpielerName(pID));
 	format(string2, sizeof(string2), "Du wurdest von %s geslappt.", SpielerName(playerid));
    admcmd(playerid, cRot, string);
	admcmd(pID, cRot, string2);
   	GetPlayerPos(pID ,X, Y, Z);
   	SetPlayerPos(pID, X, Y, Z+20);
	return 1;
}

ocmd:specoff(playerid, params[])
{
	#pragma unused params
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter.");
	TogglePlayerSpectating(playerid, 0);
	return 1;
}

ocmd:sup(playerid,params[])
{
	new text[256];
	if(sscanf(params,"s[128]",text))
	{
		echo(playerid, cTuerkis,"[Benutzung]: /sup [text]");
	}
	else
	{
		if(TicketAngenommen[playerid] == 0)
		{
 			new save[512], string[128];
			format(save,sizeof save,"Tickets/%s.ini",SpielerName(playerid));
			if(!dini_Exists(save) && TicketZeile[playerid] == 0) // Wenn noch kein Ticket existiert und auch die TicketZeile auf 0 ist.
			{
				SupportTicket[playerid] = 1;
				TicketZeile[playerid] = 1;
				dini_Create(save);
				dini_Set(save,"Suptext",text);
				echo(playerid, cTuerkis, "[Support] Dein Ticket wurde abgesendet. Bitte gedulde dich, bis es bearbeitet wird.");
				format(string, sizeof(string), "%s", text);
				echo(playerid, cTuerkis, string);
				echo(playerid, cTuerkis, "[Support] Benutze /sup, um dein Ticket um eine Zeile zu erweitern. Du kannst bis zu 3 Zeilen abschicken.");
				echo(playerid, cTuerkis, "[Support] Thema geklärt? /ct und dein Ticket wird gelöscht.");
				UpdateTickets();
				return 1;
   			}
			else if(TicketZeile[playerid] == 1) // Wenn die erste Zeile schon geschrieben wurde
			{
				new string2[128];
				dini_Set(save, "Suptext2",text);
 				echo(playerid, cTuerkis, "[Support] Du hast dein Ticket um folgende Zeile erweitert:");
				format(string2, sizeof(string2), "[Support] %s", text);
				echo(playerid, cTuerkis, string2);
				echo(playerid, cTuerkis, "[Support] Verbleibende Zeilen: 1");
				TicketZeile[playerid] = 2;
				return 1;
			}
			else if(TicketZeile[playerid] == 2) // Wenn bereits 2 Zeilen ausgefüllt sind
			{
				new string3[128];
				dini_Set(save, "Suptext3",text);
 				echo(playerid, cTuerkis, "[Support] Du hast dein Ticket um folgende Zeile erweitert:");
				format(string3, sizeof(string3), "[Support] %s", text);
				echo(playerid, cTuerkis, string3);
				echo(playerid, cTuerkis, "[Support] Verbleibende Zeilen: Keine");
				TicketZeile[playerid] = 3;
				return 1;
			}
			else if(TicketZeile[playerid] == 3) // Wenn das Ticket bereits 3 Zeilen hat
			{
				echo(playerid, cTuerkis, "[Support] Du hast bereits 3 Zeilen in dein Ticket eingetragen. Du kannst nichts mehr hinzufügen.");
				return 1;
			}
		}
		if(TicketAngenommen[playerid] == 1) // Zum direkten Antworten per /sup , wenn das Ticket angenommen wurde.
		{
			new pID = DeinSupport[playerid];
			new antwort[128], antwort2[128];
			format(antwort, sizeof (antwort),"(( ==> %s: %s ))", SpielerName(pID), text);
			echo(playerid, cSupGelb, antwort);
			format(antwort2, sizeof (antwort2), "(( %s: %s ))", SpielerName(playerid), text);
 			echo(pID, cSupGelb, antwort2);
		}

 	}
	return 1;
}

ocmd:ot(playerid,params[])
{
	new pID;
	new string2[256], string[256], string3[256], string4[256],mitteilung[128];
	if(sscanf(params,"u",pID)){
	return echo(playerid, cGelb,"[Benutzung]: /ot [Spieler]");
}
	new save[512];
	format(save,sizeof save,"Tickets/%s.ini",SpielerName(pID));
	if(dini_Exists(save)) // Ob ein Ticket existiert! bzw. Datei-Abfrage
	{
		if(isPlayerAnAdmin(playerid, 1))
		{
			if(TicketAngenommen[pID] != 1)
			{
				format(string, sizeof(string), "[Support] Du bearbeitest nun das Ticket von %s. Der User hat folgenden Text verfasst:", SpielerName(pID));
				format(string2, sizeof(string2),"[Support] %s", dini_Get(save,"Suptext"));
				format(string3, sizeof(string3),"[Support] %s", dini_Get(save,"Suptext2"));
				format(string4, sizeof(string4),"[Support] %s", dini_Get(save,"Suptext3"));
				echo(playerid, cTuerkis, string);
				echo(playerid, cTuerkis, string2);
				echo(playerid, cTuerkis, string3);
				echo(playerid, cTuerkis, string4);
				format(mitteilung, sizeof(mitteilung), "[Support] %s bearbeitet nun dein Ticket.",SpielerName(playerid));
				echo(pID, cSupGelb, mitteilung);
				echo(pID, cSupGelb, "[Support] Benutze nun /sup, um mit ihm zu schreiben.");
				DeinSupport[pID] = playerid; // Der persönliche Supporter wird gesetzt , um die Antworten an ihn weiterzuleiten
				TicketAngenommen[pID] = 1;
				UpdateTickets();
			}
		}
	}
	return 1;
}

ocmd:st(playerid,params[])
{
	new pID;
	new string[256],mitteilung[128], reason[128];
	if(sscanf(params,"us[128]",pID, reason)){
	return echo(playerid, cGelb,"[Benutzung]: /st [Spieler] [Grund]");
}
	if(TicketAngenommen[pID] == 1)
	{
		new save[512];
		format(save,sizeof save,"Tickets/%s.ini",SpielerName(pID));
		if(dini_Exists(save)) // Ob ein Ticket existiert! bzw. Datei-Abfrage
		{
			if(isPlayerAnAdmin(playerid, 1))
			{
				format(string, sizeof(string), "[Support] Du hast das Ticket von %s abgelegt.", SpielerName(pID));
				format(mitteilung, sizeof(mitteilung), "[Support] %s hat dein Ticket abgelegt.",SpielerName(playerid));
				echo(pID, cSupGelb, mitteilung);
				echo(pID, cSupGelb, "[Support] Bitte warte, bis es erneut geöffnet wird.");
				echo(playerid, cSupGelb, string);
				DeinSupport[pID] = 0;
				TicketAngenommen[pID] = 2;
				DeinGrund[pID] = reason;
				UpdateTickets();
			}
		}
	}
	return 1;
}

ocmd:et(playerid,params[])
{
	new pID;
	new string[256],mitteilung[128];
	if(sscanf(params,"u",pID)){
	return echo(playerid, cGelb,"[Benutzung]: /et [Spieler]");
}
	if(TicketAngenommen[pID] == 1)
	{
		new save[512];
		format(save,sizeof save,"Tickets/%s.ini",SpielerName(pID));
		if(dini_Exists(save)) // Ob ein Ticket existiert! bzw. Datei-Abfrage
		{
			if(isPlayerAnAdmin(playerid, 1))
			{
				format(string, sizeof(string), "[Support] Du hast das Ticket von %s abgelegt.", SpielerName(pID));
				format(mitteilung, sizeof(mitteilung), "[Support] %s hat dein Ticket abgelegt.",SpielerName(playerid));
				echo(pID, cSupGelb, mitteilung);
				echo(pID, cSupGelb, "[Support] Bitte warte, bis es erneut geöffnet wird.");
				echo(playerid, cSupGelb, string);
				DeinSupport[pID] = 0;
				TicketAngenommen[pID] = 3;
				DeinGrund[pID] = "Einweisung";
				UpdateTickets();
			}
		}
	}
	return 1;
}

ocmd:at(playerid,params[])
{
	new pID;
	new string[256],mitteilung[128], reason[128];
	if(sscanf(params,"us[128]",pID, reason)){
	return echo(playerid, cGelb,"[Benutzung]: /at [Spieler] [Grund]");
}

	if(TicketAngenommen[pID] == 1)
	{
		new save[512];
		format(save,sizeof save,"Tickets/%s.ini",SpielerName(pID));
		if(dini_Exists(save)) // Ob ein Ticket existiert! bzw. Datei-Abfrage
		{
			if(isPlayerAnAdmin(playerid, 1))
			{
				format(string, sizeof(string), "[Support] Du hast das Ticket von %s abgelegt.", SpielerName(pID));
				format(mitteilung, sizeof(mitteilung), "[Support] %s hat dein Ticket abgelegt.",SpielerName(playerid));
				echo(pID, cSupGelb, mitteilung);
				echo(pID, cSupGelb, "[Support] Bitte warte, bis es erneut geöffnet wird.");
				echo(playerid, cSupGelb, string);
				DeinSupport[pID] = 0;
				TicketAngenommen[pID] = 4;
				DeinGrund[pID] = reason;
				UpdateTickets();
			}
		}
	}
	return 1;
}

ocmd:ct(playerid, params[])
{
	if(isPlayerAnAdmin(playerid, 1))
	{
		new pID;
		if(sscanf(params,"u",pID))
		{
			return echo(playerid, cTuerkis,"[Benutzung]: /ct [Spieler]");
		}
		new save[512];
		format(save,sizeof save,"Tickets/%s.ini",SpielerName(pID));
		if(dini_Exists(save)) // Ob ein Ticket offen ist
		{
			new string2[128], string3[128];
			dini_Remove(save);
			format(string3, sizeof(string3), "[Support] Du hast das Ticket von %s gelöscht.", SpielerName(pID));
			echo(playerid, cSupGelb, string3);
			format(string2, sizeof(string2), "[Support] %s hat dein Ticket gelöscht.", SpielerName(playerid));
			echo(pID, cSupGelb, string2);
			TicketZeile[pID] = 0;
			TicketAngenommen[pID] = 0;
			DeinSupport[pID] = 0;
			SupportTicket[pID] = 0;
			DeinGrund[pID] = "";
			UpdateTickets();
		}
	}
	else
	{
	    new save[512];
		format(save,sizeof save,"Tickets/%s.ini",SpielerName(playerid));
		if(dini_Exists(save))
		{
			if(TicketAngenommen[playerid] != 1)
		    {
				dini_Remove(save);
				TicketZeile[playerid] = 0;
				TicketAngenommen[playerid] = 0;
				DeinSupport[playerid] = 0;
				SupportTicket[playerid] = 0;
				DeinGrund[playerid] = "";
				echo(playerid, cTuerkis, "[Support] Du hast dein Ticket erfolgreich gelöscht.");
				UpdateTickets();
			}
		}
	}
	return 1;
}

ocmd:rt(playerid, params[])
{
	new pID, adminid;
	if(sscanf(params,"uu",pID,adminid)) return echo(playerid, cGelb,"[Benutzung]: /rt [Spieler] [Admin]");
	if(!IsPlayerConnected(adminid)) return echo(playerid, cGelb,"Admin nicht online");
	if(!isPlayerAnAdmin(adminid, 1)) return echo(playerid, cGelb, "Der Spieler ist kein Admin");
	//if(TicketAngenommen[pID] == 1) return echo(playerid, cGelb, "Das ist nicht dein Ticket ;)");
 	new save[512];
	format(save,sizeof save,"Tickets/%s.ini",SpielerName(pID));
	if(!dini_Exists(save)) // Ob ein Ticket besteht
	{
		return echo(playerid, cGelb,"Die ID hat kein offenes Ticket");
	}
	DeinSupport[pID] = adminid;
	new string2[128], string3[128], string5[128], string6[128], string7[128];
	format(string2, sizeof(string2), "[SUPPORT] %s hat dein Ticket an %s weitergegeben.", SpielerName(playerid), SpielerName(adminid));
	UpdateTickets();
	echo(pID, cGelb, string2);
	echo(playerid, cGelb, "Erfolgreich weitergeleitet");
	format(string3, sizeof(string3), "[SUPPORT] %s hat dir %s´s Ticket gegeben. Er schrieb folgendes:", SpielerName(playerid), SpielerName(pID));
	format(string5, sizeof(string5),"[Support] %s", dini_Get(save,"Suptext"));
	format(string6, sizeof(string6),"[Support] %s", dini_Get(save,"Suptext2"));
	format(string7, sizeof(string7),"[Support] %s", dini_Get(save,"Suptext3"));
	echo(pID, cTuerkis, string3);
	echo(pID, cTuerkis, string5);
	echo(pID, cTuerkis, string6);
	echo(pID, cTuerkis, string7);
	return 1;
}


ocmd:do(playerid,params[])
{
    if(!isPlayerAnAdmin(playerid,1))return echo(playerid,cRot,"Du bist kein Supporter.");
    new pID, text[128], string[128], string2[128];
    if(sscanf(params,"us[128]",pID,text))return echo(playerid,cRot,"/do [Spieler] [Text]");
    if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
    format(string, sizeof(string), "(( %s: %s ))", SpielerName(playerid), text);
    format(string2, sizeof(string2), "(( ==> %s: %s ))", SpielerName(pID), text);
    echo(pID, cSupGelb, string); echo(playerid, cSupGelb, string2);
	return 1;
}

ocmd:togsup(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter.");
	if(PlayerInfo[playerid][pTicketson] == 0)
	{
		PlayerInfo[playerid][pTicketson] = 1;
		TextDrawShowForPlayer(playerid, Hintergrund);
		TextDrawShowForPlayer(playerid, Ueberschrift);
		TextDrawShowForPlayer(playerid, Verdichtung);
		TextDrawShowForPlayer(playerid, Ticket);
		TextDrawShowForPlayer(playerid, Strich);
		echo(playerid, cGruen, "Ticketbox aktiviert!");
		return 1;
	}
    if(PlayerInfo[playerid][pTicketson] == 1)
	{
		PlayerInfo[playerid][pTicketson] = 0;
		TextDrawHideForPlayer(playerid, Hintergrund);
		TextDrawHideForPlayer(playerid, Ueberschrift);
		TextDrawHideForPlayer(playerid, Verdichtung);
		TextDrawHideForPlayer(playerid, Ticket);
		TextDrawHideForPlayer(playerid, Strich);
		echo(playerid, cGruen, "Ticketbox deaktiviert!");
		return 1;
	}
	return 1;
}

ocmd:help(playerid, params[])
{
	ShowDialog(playerid, diaHelp, DIALOG_STYLE_LIST, "Dynamic Roleplay - Hilfe", "Allgemein\nFraktion\nGruppierung\nNaa\nHäuser\nCredits","Auswählen", "Abbrechen"); 
	return 1;
}

ocmd:hilfe(playerid, params[])
{
	return ocmd_help(playerid, params);
}

ocmd:members(playerid, params[])
{
	echo(playerid, cWeiss, "Benutze /gmembers oder /fmembers.");
	return 1;
}

ocmd:asettings(playerid, params[])
{
	new string[500], strWerbung[20];
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	if(adclosed == 0)
	{
		format(strWerbung, sizeof(strWerbung), "sperren");
	}
	if(adclosed == 1)
	{
		format(strWerbung, sizeof(strWerbung), "entsperren");
	}
	format(string, sizeof(string), "MOTD ändern\nFraktionsspawn ändern\nGruppierungsspawn ändern\nFraktionsfahrzeuge ändern\nGruppierungsfahrzeuge ändern \nWerbung %s", strWerbung);
	ShowDialog(playerid, diaASettings, DIALOG_STYLE_LIST, "Fraktion/Gruppierungs Einstellungen", string, "Auswählen", "Abbrechen");
	return 1;
}

ocmd:gsettings(playerid, params[])
{
	if(SpielerInfo[playerid][pGLeader] == 0) return echo(playerid, cGruppe, "Du bist kein Leader.");
	ShowDialog(playerid, diaGSettings, DIALOG_STYLE_LIST, "Gruppierungs Einstellungen", "Gruppierungsname ändern\nRangnamen ändern\nMOTD ändern", "Auswählen", "Abbrechen");
	return 1;
}

ocmd:fsettings(playerid, params[])
{
	if(SpielerInfo[playerid][pFLeader] == 0) return echo(playerid, cHellblau, "Du bist kein Leader.");
	ShowDialog(playerid, diaFSettings, DIALOG_STYLE_LIST, "Fraktions Einstellungen", "Fraktionsname ändern\nRangnamen ändern\nMOTD ändern", "Auswählen", "Abbrechen");
	return 1;
}


ocmd:su(playerid, params[])
{
	new pID, amount, reason[50];
	if(SpielerInfo[playerid][pFraktion] != 1) return echo(playerid, cRot, "Du bist kein Polizist.");
	if(sscanf(params,"uis[50]",pID, amount, reason))return echo(playerid,cHellblau,"/su [Spieler] [Wanteds] [Grund]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	if(amount < 1) return echo(playerid, cHellblau, "Du musst mindestens 1 Wanted setzen.");
	
	
	suspect(playerid, pID, amount, reason);
	return 1;
}

ocmd:clear(playerid, params[])
{
	new pID, strPID[128], strPD[128], reason[50];
	if(SpielerInfo[playerid][pFraktion] != 1) return echo(playerid, cRot, "Du bist kein Polizist.");
	if(sscanf(params,"u",pID))return echo(playerid,cHellblau,"Benutzung: /clear [Spieler]"); 
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	SetWanteds(pID, 0);
	
	format(reason, sizeof(reason), " ");
	SpielerInfo[pID][pWantedReason] = reason;
	
	format(strPID, sizeof(strPID), ">> Officer %s hat deine Akte bereinigt.", SpielerName(playerid));
	format(strPD, sizeof(strPD), "[SFPD] Officer %s hat die Akte von %s bereinigt.", SpielerName(playerid), SpielerName(pID));
	echo(pID, cRot, strPID);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pFraktion] == 1)
		{
			PlayerPlaySound(i,1057,0,0,0);
			echo(i, cHellblau, strPD);
		}
	}
	return 1;
}

ocmd:wanted(playerid, params[])
{
	new strDialog[256];
	if(SpielerInfo[playerid][pFraktion] != 1) return echo(playerid, cRot, "Du bist kein Polizist.");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pWanteds] >= 1)
		{
			format(strDialog, sizeof(strDialog), "%s (ID: %d)Name: %s  Wanteds: %d Grund: [%s]\n", strDialog, i, SpielerName(i), SpielerInfo[i][pWanteds], SpielerInfo[i][pWantedReason]);
		}
	}
	ShowDialog(playerid, diaWanted, DIALOG_STYLE_LIST, "Liste der Wanteds", strDialog, "Okay", "");
	return 1;
}


ocmd:contract(playerid, params[])
{
	new pID, strPlayer[128], strHitman[128], amount;
	if(sscanf(params,"ui",pID, amount))return echo(playerid,cRot,"Benutzung: /contract [Spieler] [Geld in $]");
	if(!IsPlayerConnected(pID)) return echo(pID, cRot, "Der Spieler ist nicht online.");
	if(SpielerInfo[playerid][pGruppierung] == 1) return echo(playerid, cRot, "Niemand ist sein eigener Auftraggeber...");
	if(SpielerInfo[playerid][pGeld] < amount) return echo(playerid, cRot, "Du hast nicht genug Geld!");
	if(amount < MIN_CONTRACTMONEY) return echo(playerid, cRot, "Du musst mindestens 1000$ Kopfgeld setzen.");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	AGivePlayerMoney(playerid, -amount);
	SpielerInfo[pID][pKopfgeld] = SpielerInfo[pID][pKopfgeld] + amount;
	format(strPlayer, sizeof(strPlayer), "Du hast erfolgreich %d$ Kopfgeld auf %s ausgesetzt!", amount, SpielerName(pID));
	format(strHitman, sizeof(strHitman), "[Hitman Agency] %s hat %d$ Kopfgeld auf %s ausgesetzt.", SpielerName(playerid), amount, SpielerName(pID));
	echo(playerid, cRot, strPlayer);
	EchoGruppierung(1, strHitman);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pGruppierung] == 1)
		{
			PlayerPlaySound(i,1056,0,0,0);
		}
	}
	return 1;
}

ocmd:hitman(playerid, params[])
{
	new strDialog[256];
	if(SpielerInfo[playerid][pGruppierung] != 1) return echo(playerid, cRot, "Du bist kein Mitglied der Hitman Agency.");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pKopfgeld] >= 1)
		{
			format(strDialog, sizeof(strDialog), "%s Name: %s  Kopfgeld: %d$ (ID: %d)\n", strDialog, SpielerName(i), SpielerInfo[i][pKopfgeld], i);
		}
	}
	ShowDialog(playerid, diaHitman, DIALOG_STYLE_LIST, "Liste der Aufträge", strDialog, "Okay", "");
	return 1;
}

ocmd:gmembers(playerid, params[])
{
	new strMembers[256];
	if(SpielerInfo[playerid][pGruppierung] == 0) return echo(playerid, cGruppe, "Du bist in keiner Gruppierung.");
	
	new string[128], strDuty[20];
	format(string, sizeof(string), "======== %s ========",Gruppierungname(SpielerInfo[playerid][pGruppierung]));
	echo(playerid, cGruppe, string);
	format(strDuty, sizeof(strDuty), "");
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pGruppierung] == SpielerInfo[playerid][pGruppierung])
		{
			if(SpielerInfo[i][pDuty] == 1) format(strDuty, sizeof(strDuty), " - Duty");
			if(SpielerInfo[i][pGLeader] == 1)
			{
				format(strMembers, sizeof(strMembers), "[Leader] %s: %s (Rang: %d)%s", GRangName(SpielerInfo[i][pGruppierung], SpielerInfo[i][pGRank]),SpielerName(i), SpielerInfo[i][pGRank], strDuty);
			}
			else
			{
				format(strMembers, sizeof(strMembers), "%s: %s (Rang: %d)%s", GRangName(SpielerInfo[i][pGruppierung], SpielerInfo[i][pGRank]),SpielerName(i), SpielerInfo[i][pGRank], strDuty);
			}
			echo(playerid, cGruppe, strMembers);
		}
	}
	return 1;
}

ocmd:fmembers(playerid, params[])
{
	new strMembers[256];
	if(SpielerInfo[playerid][pFraktion] == 0) return echo(playerid, cHellblau, "Du bist in keiner Fraktion.");
	
	new string[128], strDuty[20];
	format(string, sizeof(string), "======== %s ========",frakname(SpielerInfo[playerid][pFraktion]));
	echo(playerid, cHellblau, string);
	format(strDuty, sizeof(strDuty), "");
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pDuty] == 1) format(strDuty, sizeof(strDuty), " - Duty");
		if(SpielerInfo[i][pFraktion] == SpielerInfo[playerid][pFraktion])
		{
			if(SpielerInfo[i][pFLeader] == 1)
			{
				format(strMembers, sizeof(strMembers), "[Leader] %s: %s (Rang: %d)%s", FRangName(SpielerInfo[i][pFraktion], SpielerInfo[i][pFRank]),SpielerName(i), SpielerInfo[i][pFRank], strDuty);
			}
			else
			{
				format(strMembers, sizeof(strMembers), "%s: %s (Rang: %d)%s", FRangName(SpielerInfo[i][pFraktion], SpielerInfo[i][pFRank]),SpielerName(i), SpielerInfo[i][pFRank], strDuty);
			}
			echo(playerid, cHellblau, strMembers);
		}
	}
	return 1;
}

ocmd:playsound(playerid, params[])
{
	new soundid;
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin");
	if(sscanf(params,"i",soundid))return echo(playerid,cRot,"Benutzung: /playsound [ID]");
	PlayerPlaySound(playerid,soundid,0,0,0);
	return 1;
}

ocmd:b(playerid, params[])
{
	new text[128], string[128];
	if(sscanf(params,"s[128]",text))return echo(playerid,cGrau,"Benutzung: /b [Text]");
	format(string,sizeof(string),"(([UNRP] %st: %s ))",SpielerName(playerid),text);
	SendClientMessageInRange(playerid,string,cGrau,20);
	printf("%s", string);
	return 1;
}

ocmd:shout(playerid, params[])
{
	new text[128], string[128];
	if(sscanf(params,"s[128]",text))return echo(playerid,cGrau,"Benutzung: /s [Text]");
	format(string,sizeof(string),"%s schreit: %s!",SpielerName(playerid),text);
	SendClientMessageInRange(playerid,string,cWeiss,40);
	printf("%s", string);
	return 1;
}

ocmd:s(playerid, params[])
{
	return ocmd_shout(playerid, params);
}

ocmd:me(playerid, params[])
{
	new text[128], string[128];
	if(sscanf(params,"s[128]",text))return echo(playerid,cLila,"Benutzung: /me [Text]");
	format(string,sizeof(string),"%s %s",SpielerName(playerid),text);
	SendClientMessageInRange(playerid,string,cLila,20);
	printf("%s", string);
	return 1;
}

ocmd:slash(playerid, params[])
{
	new swag[32];
	if(sscanf(params,"s[128]",swag)) return 1;
	if(strfind(swag,"Kuh",true)!=-1)
	{
		new string[128];
		echo(playerid, cRot, "OH MEIN GOTT, DU HAST DIE KUH GETÖTET!");
		format(string, sizeof(string), "[Leave] %s hat den Server verlassen.", SpielerName(playerid));
		echoAll(cRot, string);
		KickTimer(playerid, 10);
	}
	return 1;
}

ocmd:getpos(playerid, params[])
{
	new Float:xpos, Float:ypos, Float:zpos;
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	GetPlayerPos(playerid, xpos, ypos, zpos);
	
	new string[128];
	format(string, sizeof(string), "Koords [%f, %f, %f] Int [%d]", xpos, ypos, zpos, GetPlayerInterior(playerid));
	admcmd(playerid, cRot, string);
	return 1;
}

ocmd:gotopos(playerid, params[])
{
	new Float:xpos, Float:ypos, Float:zpos, int;
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	if(sscanf(params,"fffi",xpos, ypos, zpos, int))return echo(playerid, cRot, "Benutzung: /gotopos [X] [Y] [Z] [Interior]");
	SetPlayerPos(playerid, xpos, ypos, zpos);
	SetPlayerInterior(playerid, int);
	printf("--> [AdmCmd] %s hat sich zur Stelle [%f, %f, %f] geportet. Int [%d]", SpielerName(playerid), xpos, ypos, zpos, int);
	return 1;
}

ocmd:aond(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter.");
	if(SpielerInfo[playerid][pAond] == 0)
	{
		new string[128];
		format(string, sizeof(string), ">> %s hat sich als %s {a76efb}angemeldet <<", SpielerName(playerid), adminname(SpielerInfo[playerid][pAdminlevel]));
		echoAll(cAond, string);
		print(string);
		SpielerInfo[playerid][pAond] = 1;
		underdollarUD(playerid);
		SetPlayerColor(playerid,0xFF00FFFF);
		return 1;
	}
	else
	{
		new string[128];
		format(string, sizeof(string), ">> %s hat sich als %s {a76efb}abgemeldet <<", SpielerName(playerid), adminname(SpielerInfo[playerid][pAdminlevel]));
		echoAll(cAond, string);
		print(string);
		SpielerInfo[playerid][pAond] = 0;
		underdollarUD(playerid);
		SetPlayerColor(playerid,0xFFFFFF00);
		return 1;
	}
}


ocmd:f(playerid,params[])
{
	new text[128], string[128]; //swort[128];
	if(SpielerInfo[playerid][pFraktion] == 0) return echo(playerid, cHellblau, "Du bist in keiner Fraktion.");
	if(sscanf(params,"s[128]",text))return echo(playerid, cHellblau, "Benutzung: /f [TEXT]");
	format(string,sizeof(string),"[%s] %s: %s",FRangName(SpielerInfo[playerid][pFraktion], SpielerInfo[playerid][pFRank]),SpielerName(playerid),text);
	EchoFraktion(SpielerInfo[playerid][pFraktion], string);
	return 1;
}

ocmd:g(playerid,params[])
{
	new text[128], string[128];
	if(SpielerInfo[playerid][pGruppierung] == 0) return echo(playerid, cGruppe, "Du bist in keiner Gruppierung.");
	if(sscanf(params,"s[128]",text))return echo(playerid, cGruppe, "Benutzung: /g [Text]");
	format(string,sizeof(string),"[%s] %s: %s",GRangName(SpielerInfo[playerid][pGruppierung], SpielerInfo[playerid][pGRank]),SpielerName(playerid),text);
	EchoGruppierung(SpielerInfo[playerid][pGruppierung], string);
	return 1;
}

ocmd:admins(playerid, params[])
{
    echo(playerid, cWeiss, "====== Admins online ======");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(SpielerInfo[i][pAdminlevel] != 0)
			{
		    	new string[128], duty[16];
				if(SpielerInfo[i][pAond] == 0)
				{
					duty = "";
				}
				if(SpielerInfo[i][pAond] == 1)
				{
					duty = "(Onduty)";
				}
				format(string,sizeof(string),"%s%s {ffffff}%s %s\n",string , adminname(SpielerInfo[i][pAdminlevel]), SpielerName(i), duty);
				echo(playerid, cWeiss, string);
			}
		}
	}
	echo(playerid, cWeiss, "=========================");
	return 1;
}

ocmd:setgruppierung(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin!");
	new pID, team, strPID[128], strPlayer[128], rangid, leaderid, leadername[16];
	if(sscanf(params,"uddd",pID, team, rangid, leaderid))return echo(playerid, cRot,"Benutzung: /setgruppierung [Name] [Team] [Rang] [Leader]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	if(rangid<0||rangid>MAX_GANGRANKS)return echo(playerid,cRot,"Bitte gib eine gültige Rang ID an.");
	if(leaderid<0||leaderid>1)return echo(playerid,cRot,"Bitte gib einen gültigen Leaderwert an.");
	if(leaderid == 0) 
	{
		leadername = "Nein";
	}
	if(leaderid == 1)
	{
		leadername = "Ja";
	}
	SpielerInfo[pID][pGruppierung] = team;
	SpielerInfo[pID][pGRank] = rangid;
	SpielerInfo[pID][pGLeader] = leaderid;
	
	if(team != 0)
	{
		Gruppierungspawn(pID, team);
	}
	else
	{
		SpawnPlayerZivi(playerid);
	}
	
	format(strPID, sizeof(strPID),"%s hat dich in die Gruppierung namens %s gesetzt. [Rang:%d Leader:%s]", SpielerName(playerid), Gruppierungname(team), rangid, leadername);
	format(strPlayer, sizeof(strPlayer),"Du hast %s in die Gruppierung namens %s gesetzt. [Rang:%d Leader:%s]", SpielerName(pID), Gruppierungname(team), rangid, leadername);
	admcmd(playerid, cRot, strPlayer);
	admcmd(pID, cRot, strPID);
	printf("--> [AdmCmd] %s hat %s in die Gruppierung namens %s gesetzt. [Rang:%d Leader:%s]", SpielerName(playerid), SpielerName(pID), Gruppierungname(team), rangid, leadername);
	return 1;
}

ocmd:setfraktion(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin!");
	new pID, team, strPID[128], strPlayer[128], rangid, leaderid, leadername[16];
	if(sscanf(params,"uddd",pID, team, rangid, leaderid))return echo(playerid, cRot,"Benutzung: /setfraktion [Name] [Team] [Rang] [Leader]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	if(rangid<0||rangid>MAX_FRAKTIONRANKS)return echo(playerid,cRot,"Bitte gib eine gültige Rang ID an.");
	if(leaderid<0||leaderid>1)return echo(playerid,cRot,"Bitte gib einen gültigen Leaderwert an.");
	if(leaderid == 0) 
	{
		leadername = "Nein";
	}
	if(leaderid == 1)
	{
		leadername = "Ja";
	}	
	SpielerInfo[pID][pFraktion] = team;
	SpielerInfo[pID][pFRank] = rangid;
	SpielerInfo[pID][pFLeader] = leaderid;
	if(team != 0)
	{
		fraktionspawn(pID, team);
	}
	else
	{
		SpawnPlayerZivi(playerid);
	}
	format(strPID, sizeof(strPID),"%s hat dich in die Fraktion namens %s gesetzt. [Rang:%d Leader:%s]", SpielerName(playerid), frakname(team), rangid, leadername);
	format(strPlayer, sizeof(strPlayer),"Du hast %s in die Fraktion namens %s gesetzt. [Rang:%d Leader:%s]", SpielerName(pID), frakname(team), rangid, leadername);
	admcmd(playerid, cRot, strPlayer);
	admcmd(pID, cRot, strPID);
	printf("--> [AdmCmd] %s hat %s in die Fraktion namens %s gesetzt. [Rang:%d Leader:%s]", SpielerName(playerid), SpielerName(pID), frakname(team), rangid, leadername);
	return 1;
}

ocmd:setadmin(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 6)) return echo(playerid, cRot, "Du bist kein Projektleiter!");
	new pID, team, strPID[128], strPlayer[128];
	if(sscanf(params,"ud",pID, team))return echo(playerid, cRot,"Benutzung: /setadmin [Name] [Adminlevel]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	SpielerInfo[pID][pAdminlevel] = team;
	if(team == 0)
	{
		format(strPID, sizeof(strPID),"%s hat dich zum Zivilist degradiert.", SpielerName(playerid));
		format(strPlayer, sizeof(strPlayer), "[AdmCmd] %s hat %s zum Zivilisten degradiert.", SpielerName(playerid), SpielerName(pID));
	}
	else
	{
		format(strPID, sizeof(strPID),"%s hat dir den Adminrang %s {FFBE00}verliehen.", SpielerName(playerid), adminname(team));
		format(strPlayer, sizeof(strPlayer), "[AdmCmd] %s hat %s den Adminrang %s {FFBE00}verliehen.", SpielerName(playerid), SpielerName(pID), adminname(team));
	}
	admcmd(pID, cRot, strPID);
	Adminecho(cGelb, strPlayer);
	return 1;
}

ocmd:mask(playerid, params[])
{
	if(SpielerInfo[playerid][pGruppierung] != 1) return echo(playerid, cGruppe, "[Hitman Agency] Du bist kein Hitman.");
	if(SpielerInfo[playerid][pDuty] != 1) return echo(playerid, cGruppe, "[Hitman Agency] Du musst im Dienst sein!");
	if(SpielerInfo[playerid][pMask] == 1) return echo(playerid, cGruppe, "[Hitman Agency] Du hast doch schon eine Maske auf.");
	for(new i = 0; i < MAX_PLAYERS; i++)
    {
		ShowPlayerNameTagForPlayer(i, playerid, 0); 
    }
	SpielerInfo[playerid][pMask] = 1;
	echo(playerid, cGruppe, "[Hitman Agency] Du hast eine Maske aufgezogen.");
	return 1;
}

ocmd:unmask(playerid, params[])
{
	if(SpielerInfo[playerid][pGruppierung] != 1) return echo(playerid, cRot, "Du bist kein Hitman.");
	if(SpielerInfo[playerid][pMask] == 0) return echo(playerid, cGruppe, "[Hitman Agency] Du hast doch gar keine Maske auf.");
	for(new i = 0; i < MAX_PLAYERS; i++)
    {
		ShowPlayerNameTagForPlayer(i, playerid, 1); 
    }
	SpielerInfo[playerid][pMask] = 0;
	echo(playerid, cGruppe, "[Hitman Agency] Du hast deine Maske abgezogen.");
	return 1;
}


ocmd:stats(playerid, params[])
{
	ShowStats(playerid, playerid);
	return 1;
}

ocmd:pstats(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 4)) return echo(playerid, cRot, "Du bist kein Admin.");
	new pID;
	if(sscanf(params,"u",pID))return echo(playerid, cRot,"Benutzung: /pstats [Spieler]");
	echo(playerid, cRot, "=======ADMINSTATISTIKEN=======");
	ShowStats(pID, playerid);
	echo(playerid, cRot, "===============================");
	return 1;
}

ocmd:checkhack(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 3)) return echo(playerid, cRot, "Du bist kein Admin!");
	new pID, strAdmin[128], Float:hp;
	if(sscanf(params,"u",pID))return echo(playerid, cRot,"Benutzung: /checkhack [Spieler]");
	
	format(strAdmin, sizeof(strAdmin), "Du hast %s auf Unverwundbarkeit gecheckt. Ergebnis folgt...", SpielerName(pID));
	echo(playerid, cRot, strAdmin);
	
	new Float:x, Float:y, Float:z;
    GetPlayerPos(pID, x, y, z);
    CreateExplosion(x, y, z, 0, 10.0);
	
	GetPlayerHealth(pID, hp);
	
	unverwundbarkeitTimer[playerid] = SetTimerEx("CheckUnverwundbarkeit", 1000, false, "if", pID, hp);
	return 1;
}

ocmd:autohaus(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 7.0, -1659.2321, 1212.4449, 13.6719)) return echo(playerid, cRot, "Du bist nicht beim Autohaus.");
	ShowDialog(playerid, diaAutohaus, DIALOG_STYLE_LIST, "Autohaus", "Sultan\nInfernus", "Kaufen", "Abbrechen");
	return 1;
}

ocmd:vhelp(playerid, params[])
{
	ShowDialog(playerid, diaVHelp, DIALOG_STYLE_MSGBOX, "Fahrzeughilfe", "Numpad 2 - Motor starten/stoppen \nNumpad 8 - Licht an-/ausschalten", "Okay", "");
	return 1;
}

ocmd:ahelp(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter!");
	ShowAHelp(playerid);
	return 1;
}

ocmd:setskin(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 4)) return echo(playerid, cRot, "Du bist kein Admin!");
	new pID, skinid, strAdmin[128], strPID[128];
	if(sscanf(params,"ui",pID, skinid))return echo(playerid, cRot,"Benutzung: /setskin [Name] [SkinID]");
	if(skinid<0||skinid>311)return echo(playerid,cRot,"Bitte gib eine gültige Skin ID an.");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	SetSkin(pID, skinid);
	format(strAdmin, sizeof(strAdmin), "Du hast %s den Skin mit der ID %d gesetzt.", SpielerName(pID), skinid);
	format(strPID, sizeof(strPID), "%s hat dir den Skin mit der ID %d gesetzt.", SpielerName(playerid), skinid);
	printf("-->[AdmCmd]%s hat %s den Skin mit der ID %d gesetzt.", SpielerName(playerid), SpielerName(pID), skinid);
	admcmd(playerid, cRot, strAdmin);
	admcmd(pID, cRot, strPID);
	SavePlayer(pID);
	return 1;
}

ocmd:sultan(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Supporter!");
    new Float:x,Float:y,Float:z,Float:a, car;
	GetPlayerPos(playerid,x,y,z);
	GetPlayerFacingAngle(playerid,a);
	SetVehicleNumberPlate(car = CreateVehicle(560,x,y,z,a,-1,-1,-1), "Support");
	SetVehicleVirtualWorld(car,GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(car,GetPlayerInterior(playerid));
	PutPlayerInVehicle(playerid, car, 0);
	
	isSpawned[car] = true;
	
	new string[128];
	format(string, sizeof(string), "[AdmCmd] %s hat sich einen Sultan gespawned.", SpielerName(playerid));
	Adminecho(cGelb, string);
	return 1;
}

ocmd:a(playerid, params[])
{
	new text[256], string[128], string2[128], stringprint[128];
    if(sscanf(params,"s[128]",text))return echo(playerid, cGelb,"Benutzung: /a [Text]");
    format(string, sizeof(string), "[AdmChat] %s {FFBE00}%s: %s",adminname(SpielerInfo[playerid][pAdminlevel]), SpielerName(playerid),text);
	format(stringprint, sizeof(stringprint), "-->[AdmCmd]%s %s: %s",adminname(SpielerInfo[playerid][pAdminlevel]), SpielerName(playerid),text);
    print(stringprint);
    if(isPlayerAnAdminAnd(playerid, 0))
    {
		format(string2, sizeof(string2), "Deine Adminnachricht: %s", text);
		echo(playerid, cGelb, string2);
    }
 	for(new i=0; i<MAX_PLAYERS; i++)
	{
	    if(isPlayerAnAdmin(i, 1))
	    {
			echo(i,cGelb,string);
		}
	}
	return 1;
}

ocmd:veh(playerid,params[])
{
	if(isPlayerAnAdmin(playerid,2))
	{
   		new modelid, col1, col2, car;
   		new Float:PosX, Float:PosY, Float:PosZ, Float:PosZA;

   		if(sscanf(params,"iii",modelid,col1,col2))
		{
			if(sscanf(params,"i",modelid,col1,col2)) return echo(playerid, cRot,"Benutzung: /veh [ID] ([Farbe 1] [Farbe 2])");
			col1 = -1;
			col2 = -1;
		}
		else 
			if(col1 < -1 || col2 < -1 || col1 > 255 || col2 > 255) return echo(playerid, cRot, "Ungültige Farbe");

    	GetPlayerPos(playerid, PosX, PosY, PosZ);
		GetPlayerFacingAngle(playerid, PosZA);

		SetVehicleNumberPlate(car = CreateVehicle(modelid,PosX, PosY, PosZ, PosZA, col1, col2, -1), "Admin");
        SetVehicleVirtualWorld(car,GetPlayerVirtualWorld(playerid));
        LinkVehicleToInterior(car,GetPlayerInterior(playerid));
		PutPlayerInVehicle(playerid,car,0);
		isSpawned[car] = true;

		new string[128];
		format(string, sizeof(string), "-->[AdmCmd]%s hat sich ein Fahrzeug gespawnt. [ID:%d %d %d]",SpielerName(playerid), modelid, col1, col2);
		Adminecho(cGelb, string);

	}
	//else return ZugriffVerweigert(playerid, -1, 0, 2);
	return 1;
}

ocmd:respawn(playerid, params[])
{
	new pID, strAdmin[128], strPID[128], strLog[128];
	if(sscanf(params,"u",pID))return echo(playerid, cRot, "Benutzung: /respawn [ID]");
	if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	format(strAdmin, sizeof(strAdmin), "Du hast %s respawned.",SpielerName(pID));
	format(strPID, sizeof(strPID), "%s hat dich respawned.",SpielerName(playerid));
	format(strLog, sizeof(strLog), "-->[AdmCmd]%s hat %s respawned.",SpielerName(playerid), SpielerName(pID));
	
	admcmd(playerid, cRot, strAdmin);
	admcmd(pID, cRot, strPID);
	Adminecho(cGelb, strLog);
	SpawnPlayer(pID);
	return 1;
}

ocmd:vehrem(playerid,params[])
{
	#pragma unused params
    if(!isPlayerAnAdmin(playerid,1)) return echo(playerid, cRot, "Du bist nicht im Adminteam.");
	new car = GetPlayerVehicleID(playerid);
	if(isSpawned[car] == true)
	{
		isSpawned[car] = false;
		DestroyVehicle(car);
		return 1;
	}
	return echo(playerid, cRot, "Du kannst dieses Auto nicht entfernen.");
}

ocmd:vehremall(playerid, params[])
{
	new var, string[128];
    if(isPlayerAnAdmin(playerid, 4))
    {
		format(string, sizeof(string), "Es wurden keine gespawnten Fahrzeuge gespawned.");
		for(new i=0; i<MAX_VEHICLES; i++)
		{
		    if(isSpawned[i] == true)
		    {
		        if(IsVehicleEmpty(i))
		        {
					DestroyVehicle(i);
					isSpawned[i] = false;
					var ++;
					format(string, sizeof(string), "Die gespawnten Fahrzeuge wurden erfolgreich gelöscht. [%d]", var);
				}
			}
		}
		Adminecho(cGelb, string);
		var = 0;
	}
	else echo(playerid, cRot, "Du bist kein Fulladmin.");
	return 1;
}

ocmd:agivecash(playerid,params[])
{
	if(!isPlayerAnAdmin(playerid,5)) return echo(playerid, cRot, "Du bist kein Fulladmin");
 	new pID, money, string[128], strAdmin[128];
   	if(sscanf(params,"ui",pID, money))return echo(playerid, cRot,"Benutzung: /agivecash [Spieler] [Geld]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	format(string, sizeof(string), "Du hast von %s %d$ in Bar erhalten.",SpielerName(playerid),money);
	admcmd(pID, cRot, string);
	AGivePlayerMoney(pID, money);
	format(strAdmin, sizeof(strAdmin), "--> [AdmCmd] %s hat %s %d$ Bar gegeben.", SpielerName(playerid), SpielerName(pID), money);
	Adminecho(cGelb, strAdmin);
	return 1;
}

ocmd:agivegun(playerid,params[])
{
	if(!isPlayerAnAdmin(playerid,5)) return echo(playerid, cRot, "Du bist kein Fulladmin");
  	new pID, gun, ammo, string[128], string2[128], gunname[32];
   	if(sscanf(params,"uii",pID, gun, ammo))return echo(playerid, cRot,"Benutzung: /agivegun [Spieler] [ID] [Ammu]");
	if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	GetWeaponName(gun,gunname,sizeof(gunname));
	format(string, sizeof(string), "%s hat dir die Waffe %s mit %d Schuss gegeben.",SpielerName(playerid),gunname,ammo);
    format(string2, sizeof(string2), "Du hast %s die Waffe %s mit %d Schuss gegeben.",SpielerName(pID),gunname,ammo);
    admcmd(playerid, cRot, string2); admcmd(pID, cRot, string);
	GivePlayerWeapon(pID, gun, ammo);
	printf("--> [AdmCmd] %s hat %s Waffe %s mit %d Schuss gegeben.", SpielerName(playerid), SpielerName(pID), gunname, ammo);
	return 1;
}

ocmd:arepair(playerid,params[])
{
	if(isPlayerAnAdmin(playerid, 4))
	{
	    new pID, string[128];
	    if(sscanf(params,"u",pID))
		{
			if(!IsPlayerInAnyVehicle(playerid))return echo(playerid, cRot, "Du bist in keinem Fahrzeug!");
			new vehicle = GetPlayerVehicleID(playerid);
			RepairVehicle(vehicle);
			echo(playerid, cRot, "[AdmCmd]Du hast dich selbst repariert.");
			printf("--> [AdmCmd] %s hat sich repariert.",SpielerName(playerid));
			return 1;
		}
		if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
		if(!IsPlayerInAnyVehicle(pID))return echo(playerid, cRot, "Spieler ist in keinem Fahrzeug!");
	    if(IsPlayerConnected(playerid))
		{
			new vehicle = GetPlayerVehicleID(pID);
			RepairVehicle(vehicle);
			format(string, sizeof(string), "[AdmCmd]Du hast %s repariert.", SpielerName(pID));
			admcmd(playerid, cRot, string);
		}
		printf("--> [AdmCmd] %s hat %s repariert.",SpielerName(playerid), SpielerName(pID));
	}
	else return echo(playerid, cRot, "Du bist kein Admin.");
	return 1;
}

ocmd:arefill(playerid,params[])
{
	if(isPlayerAnAdmin(playerid, 4))
	{
	    new pID, string[128];
	    if(sscanf(params,"u",pID))
		{
			if(!IsPlayerInAnyVehicle(playerid))return echo(playerid, cRot, "Du bist in keinem Fahrzeug!");
			new vehicle = GetPlayerVehicleID(playerid);
			VehicleData[vehicle][vTank] = 50;
			echo(playerid, cRot, "[AdmCmd]Du hast dich selbst voll getankt.");
			printf("--> [AdmCmd] %s hat sich voll getankt.",SpielerName(playerid));
			return 1;
		}
		if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
		if(!IsPlayerInAnyVehicle(pID))return echo(playerid, cRot, "Spieler ist in keinem Fahrzeug!");
	    if(IsPlayerConnected(playerid))
		{
			new vehicle = GetPlayerVehicleID(pID);
			VehicleData[vehicle][vTank] = 50;
			format(string, sizeof(string), "[AdmCmd]Du hast %s voll getankt.", SpielerName(pID));
			admcmd(playerid, cRot, string);
		}
		printf("--> [AdmCmd] %s hat %s voll getankt.",SpielerName(playerid), SpielerName(pID));
	}
	else return echo(playerid, cRot, "Du bist kein Admin.");
	return 1;
}

ocmd:flip(playerid,params[])
{
	if(isPlayerAnAdmin(playerid, 4))
	{
	    new pID, string[128];
	    if(sscanf(params,"u",pID))
		{
			if(!IsPlayerInAnyVehicle(playerid))return echo(playerid, cRot, "Du bist in keinem Fahrzeug!");
			new Float:angle;
			RepairVehicle(GetPlayerVehicleID(playerid));
			GetVehicleZAngle(GetPlayerVehicleID(playerid),angle);
			SetVehicleZAngle(GetPlayerVehicleID(playerid),angle);
			echo(playerid, cRot, "[AdmCmd]Du hast dein eigenes Fahrzeug gedreht.");
			printf("--> [AdmCmd] %s hat sein Fahrzeug gedreht.",SpielerName(playerid));
			return 1;
		}
		if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
		if(!IsPlayerInAnyVehicle(pID))return echo(playerid, cRot, "Spieler ist in keinem Fahrzeug!");
	    if(IsPlayerConnected(playerid))
		{
			new Float:angle;
			RepairVehicle(GetPlayerVehicleID(pID));
			GetVehicleZAngle(GetPlayerVehicleID(pID),angle);
			SetVehicleZAngle(GetPlayerVehicleID(pID),angle);
			format(string, sizeof(string), "[AdmCmd]Du hast das Fahrzeug von %s gedreht.", SpielerName(pID));
			admcmd(playerid, cRot, string);
		}
		printf("--> [AdmCmd] %s hat das Fahrzeug von %s gedreht.",SpielerName(playerid), SpielerName(pID));
	}
	else return echo(playerid, cRot, "Du bist kein Admin.");
	return 1;
}

ocmd:goto(playerid,params[])
{
	if(isPlayerAnAdmin(playerid,1))
	{
	    new pID, string[128];
	    new Float:PosX, Float:PosY, Float:PosZ, vehid;
	    if(sscanf(params,"u",pID))return echo(playerid, cRot,"Benutzung: /goto [Spieler]");
	    if(!IsPlayerConnected(pID)) return echo(playerid, cRot,"Spieler nicht gefunden.");
	    vehid = GetPlayerVehicleID(playerid);
	    GetPlayerPos(pID, PosX, PosY, PosZ);
		SetPlayerPos(playerid, PosX+2, PosY+2, PosZ+2);
		new int = GetPlayerInterior(pID);
		if(IsPlayerInAnyVehicle(playerid))
		{
			SetVehiclePos(vehid, PosX+2, PosY+2, PosZ+2);
			PutPlayerInVehicle(playerid, vehid, 0);
			LinkVehicleToInterior(vehid, int);
		}
	    SetCameraBehindPlayer(playerid);
	    SetPlayerInterior(playerid, int);
	    new vw = GetPlayerVirtualWorld(pID);
	    SetPlayerVirtualWorld(playerid, vw);
	    format(string, sizeof(string), "Du hast dich erfolgreich zu %s geportet.",SpielerName(pID));
	    admcmd(playerid, cRot, string);
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pID));
		printf("--> [AdmCmd] %s hat sich zu %s geportet.", SpielerName(playerid), SpielerName(pID));
	}
    else return echo(playerid, cRot, "Du bist kein Supporter.");
	return 1;
}

ocmd:gethere(playerid,params[])
{
	if(!isPlayerAnAdmin(playerid,2)) return echo(playerid, cRot, "Du bist kein Moderator.");
    new pID, string[128], string2[128];
    new Float:PosX, Float:PosY, Float:PosZ;
    if(sscanf(params,"u",pID))return echo(playerid, cRot,"Benutzung: /gethere [Spieler]");
    if(!IsPlayerConnected(pID)) return echo(playerid, cRot,"Spieler nicht gefunden.");
    if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
    GetPlayerPos(playerid, PosX, PosY, PosZ);
	SetPlayerPos(pID, PosX+2, PosY+2, PosZ+2);
	new int = GetPlayerInterior(playerid);
    SetPlayerInterior(pID, int);
    if(IsPlayerInAnyVehicle(pID))
	{
		new plveh = GetPlayerVehicleID(pID);
		SetVehiclePos(plveh, PosX+2, PosY+2, PosZ+2);
		LinkVehicleToInterior(plveh, int);
		SetVehicleVirtualWorld(plveh, GetPlayerVirtualWorld(playerid));
		PutPlayerInVehicle(pID, plveh, 0);
	}
    SetCameraBehindPlayer(pID);
    new vw = GetPlayerVirtualWorld(playerid);
    SetPlayerVirtualWorld(pID, vw);
    format(string, sizeof(string), "Du hast %s erfolgreich zu dir geportet.",SpielerName(pID));
    format(string2, sizeof(string2), "Du wurdest von %s zu ihm geportet.",SpielerName(playerid));
    admcmd(playerid, cRot, string); admcmd(pID, cRot, string2);
	SetPlayerVirtualWorld(pID, GetPlayerVirtualWorld(playerid));
	printf("--> [AdmCmd] %s hat %s zu sich geportet.", SpielerName(playerid), SpielerName(pID));
	return 1;
}

ocmd:sethp(playerid, params[])
{
	if(isPlayerAnAdmin(playerid, 4))
	{
	    new pID, Float:HP, string[128], string2[128];
	    if(sscanf(params,"uf",pID, HP)) return echo(playerid, cRot, "Benutzung: /sethp [Spieler] [Leben]");
		if(!IsPlayerConnected(pID)) return echo(playerid, cRot, "Spieler nicht online!");
	    if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	    SetPlayerHealth(pID, HP);
	    format(string, sizeof(string), "Du hast die Leben von %s auf %.0f gesetzt.",SpielerName(pID), HP); admcmd(playerid, cRot, string);
	    format(string2, sizeof(string2), "%s hat deine Leben auf %.0f gesetzt.",SpielerName(playerid), HP); admcmd(pID, cRot, string2);
		printf("--> [AdmCmd] %s hat die HP von %s auf %.0f gesetzt.", SpielerName(playerid), SpielerName(pID), HP);
	}
	else return echo(playerid, cRot, "Du bist Admin.");
	return 1;
}

ocmd:gmx(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
	SaveAllStuff();
	restartvar = 1;
	SendRconCommand("gmx");
	return 1;
}

ocmd:nos(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 5)) return echo(playerid, cRot, "Du bist kein Fulladmin.");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,cRot,"Du sitzst in keinem Auto!");
    return AddVehicleComponent(GetPlayerVehicleID(playerid),1010);
}

ocmd:checkweapons(playerid, params[])
{
    if(SpielerInfo[playerid][pAdminlevel] >= 3)
    {
        new count = 0;
        new ammo, weaponid, weapon[24], string[128], id;
        if(!sscanf(params, "u", id))
        {
                for (new c = 0; c < 13; c++)
                {
                    GetPlayerWeaponData(id, c, weaponid, ammo);
                    if (weaponid != 0 && ammo != 0)
                    {
                        count++;
                    }
                }
                echo(playerid, cRot, "||=============WEAPONS AND AMMO===========||");
                if(count > 0)
                {
                    for (new c = 0; c < 13; c++)
                    {
                        GetPlayerWeaponData(id, c, weaponid, ammo);
                        if (weaponid != 0 && ammo != 0)
                        {
                            GetWeaponName(weaponid, weapon, 24);
                            format(string, sizeof(string), "Weapons: %s  Ammo: %d", weapon, ammo);
                            echo(playerid, cRot, string);
                        }
                    }
                }
                else
                {
                    echo(playerid, cRot, "This player has no weapons!");
                }
                return 1;
        }
        else return echo(playerid, cRot, "USAGE: /checkweapons [ID]");
    }
    else return echo(playerid, cRot, "You are not allowed to do this");
}


ocmd:bankrob(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, 2143.9968,1626.3088,993.6882)) return echo(playerid, cRot, "Du bist nicht vor der Tresortür!"); 
	if(bankrobstarted != 0) return echo(playerid, cRot, "Es läuft bereits ein Bankraub.");
	echo(playerid, cBank, "Du bringst C4 an der Tresortür an und machst es scharf...");
	Dynamit[0] = CreateDynamicObject(354, 2144.89990, 1626.83899, 993.08698,   0.00000, 90.00000, 0.00000);
	Dynamit[1] = CreateDynamicObject(354, 2144.89990, 1626.83899, 994.18701,   0.00000, 90.00000, 0.00000);
	Dynamit[2] = CreateDynamicObject(354, 2144.89990, 1626.83899, 995.30701,   0.00000, 90.00000, 0.00000);
	Dynamit[3] = CreateDynamicObject(354, 2144.19995, 1626.83899, 995.60699,   0.00000, 0.00000, 0.00000);
	Dynamit[4] = CreateDynamicObject(354, 2143.33984, 1626.83899, 995.30701,   0.00000, 90.00000, 0.00000);
	Dynamit[5] = CreateDynamicObject(354, 2143.33984, 1626.83899, 994.20697,   0.00000, 90.00000, 0.00000);
	Dynamit[6] = CreateDynamicObject(354, 2143.33984, 1626.83899, 993.10699,   0.00000, 90.00000, 0.00000);
	Dynamit[7] = CreateDynamicObject(354, 2144.15991, 1626.83899, 992.88702,   0.00000, 0.00000, 0.00000);
	
	Tresortuer[2] = CreateDynamicObject(2634, 2143.18408, 1630.47546, 992.74432,   90.00000, 180.00000, 10.00000);
	Tresortuer[3] = CreateDynamicObject(2634, 2143.18408, 1630.47546, 992.68433,   90.00000, 180.00000, 10.00000);
	
	bankrobstarted = 1;
	
	TresorMoney();
	
	SetTimer("ExplodeTresor", 10000, false);
	return 1;
}

forward ExplodeTresor();
public ExplodeTresor()
{
	CreateExplosion(2144.18994, 1627.03113, 994.24432, 0, 5.0);
	
	for(new i; i < 8; i++)
		DestroyDynamicObject(Dynamit[i]);
	
	
	DestroyDynamicObject(Tresortuer[0]);
	DestroyDynamicObject(Tresortuer[1]);
	
	new string[128];
	format(string, sizeof(string), "[Notruf] Hilfe! Die Bank wird überfallen, bitte kommen Sie schnell!");	
	EchoFraktion(1, string);
	return 1;
}



public OnPlayerCommandText(playerid, cmdtext[])
{
	new string[128];
	format(string, sizeof(string), "Fehler: {ffffff}Der Befehl "ciOrange"%s {ffffff}konnte nicht gefunden werden.", cmdtext);
	echo(playerid, cOrange, string);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)Tempo[playerid] = -1;
	if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
	    if(SpielerInfo[playerid][pLevel] <= 5)
		{
			SendClientMessage(playerid, cGrau, "Fahrzeughilfe gibt es unter /vhelp.");
		}
		new engine, lights, alarm, doors, bonnet, boot, objective, vehicleid;
		vehicleid = GetPlayerVehicleID(playerid);
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		if(engine == 1) return ShowTacho(playerid);
	}
	if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER)
	{
		HideTacho(playerid);
	}
	if(newstate == PLAYER_STATE_SPECTATING && oldstate == PLAYER_STATE_DRIVER)
	{
		HideTacho(playerid);
	}
	return 1;
}

forward TempoUpdate();
public TempoUpdate()
{
        for(new i = 0; i<MAX_PLAYERS; i++)
        {
            if(!IsPlayerConnected(i))continue;
            if(!IsPlayerInAnyVehicle(i))continue;
            if(Tempo[i] < 0)continue;
            if(GetPlayerSpeed(i)<Tempo[i])continue;
			new Float:X, Float:Y, Float:Z;
            GetVehicleVelocity(GetPlayerVehicleID(i),X,Y,Z);
            SetVehicleVelocity(GetPlayerVehicleID(i),((X/100)*97),((Y/100)*97),Z);
        }
}

forward SpawnInKnast(playerid);
public SpawnInKnast(playerid)
{
    new rand = random(sizeof(KnastSpawns));
	SetPlayerPos(playerid, KnastSpawns[rand] [knast_x], KnastSpawns[rand] [knast_y], KnastSpawns[rand] [knast_z]);
	SetPlayerInterior(playerid, 6);
	GameTextForPlayer(playerid, "~g~Willkommen im ~r~Knast!", 3000, 6);
	//SetTimerEx("Knasttimer", 1000, false, "i", playerid);
	
	return 1;
}

stock ShowStats(playerid, pID)
{
	new strStats[128], frangtext[12], grangtext[12];
	if(SpielerInfo[playerid][pFRank] == 0)
	{
		frangtext = "Nein";
	}
	else
	{
		frangtext = "Ja";
	}
	if(SpielerInfo[playerid][pGRank] == 0)
	{
		grangtext = "Nein";
	}
	else 
	{
		grangtext = "Ja";
	}
	format(strStats, sizeof(strStats), "=============== STATISTIKEN VON {FF8A05}%s{FFFFFF} ===============", SpielerName(playerid));
	echo(pID, cWeiss, strStats);
	new pleft = 1800 - SpielerInfo[playerid][pPayday];
	new pMin = pleft /60;
	new pSek;
	if(pMin == 0)
		pSek = pleft;
	else
		pSek = pleft - pMin * 60;
		
	if(pSek < 10)
	{
		if(pSek == 0) 
			pSek = 00;
		if(pSek == 1) 
			pSek = 01;
		if(pSek == 2) 
			pSek = 02;
		if(pSek == 3) 
			pSek = 03;
		if(pSek == 4) 
			pSek = 04;
		if(pSek == 5) 
			pSek = 05;
		if(pSek == 6) 
			pSek = 06;
		if(pSek == 7) 
			pSek = 07;
		if(pSek == 8) 
			pSek = 08;
		if(pSek == 9) 
			pSek = 09;
	}
	if(pMin < 10)
	{
		if(pMin == 0) 
			pMin = 00;
		if(pMin == 1) 
			pMin = 01;
		if(pMin == 2) 
			pMin = 02;
		if(pMin == 3) 
			pMin = 03;
		if(pMin == 4) 
			pMin = 04;
		if(pMin == 5) 
			pMin = 05;
		if(pMin == 6) 
			pMin = 06;
		if(pMin == 7) 
			pMin = 07;
		if(pMin == 8) 
			pMin = 08;
		if(pMin == 9) 
			pMin = 09;
	}
	new strZeit[30];
	format(strZeit, sizeof(strZeit), "%d:%d" ,pMin, pSek);
	if(pMin < 10)
	{
		format(strZeit, sizeof(strZeit), "0%d:%d" ,pMin, pSek);
	}
	if(pSek < 10)
	{
		format(strZeit, sizeof(strZeit), "%d:0%d" ,pMin, pSek);
	}
	if(pMin < 10 && pSek < 10)
	{
		format(strZeit, sizeof(strZeit), "0%d:0%d" ,pMin, pSek);
	}
	format(strStats, sizeof(strStats), "Allgemein | Level: {FF8A05}%d{FFFFFF} Erfahrung: {FF8A05}[%d/%d]{FFFFFF} Payday in: {FF8A05}[%smin]{FFFFFF}", SpielerInfo[playerid][pLevel], SpielerInfo[playerid][pExp], SpielerInfo[playerid][pLevel]*GET_EXP, strZeit);
	echo(pID, cWeiss, strStats);
	format(strStats, sizeof(strStats), "Beruf | Name: {FF8A05}%s{FFFFFF} Erfahrung: {FF8A05}%s{FFFFFF}", "Test", "Anfänger");
	echo(pID, cWeiss, strStats);
	format(strStats, sizeof(strStats), "Finanzen | Bargeld: {FF8A05}%d{FFFFFF} Bankguthaben: {FF8A05}%d{FFFFFF}", SpielerInfo[playerid][pGeld], 0);
	echo(pID, cWeiss, strStats);
	format(strStats, sizeof(strStats), "Premium | Premiumpunkte: {FF8A05}%d{FFFFFF}", SpielerInfo[playerid][pPremiumpunkte]);
	echo(pID, cWeiss, strStats);
	if(SpielerInfo[playerid][pFraktion] > 0)
	{
		format(strStats, sizeof(strStats), "Fraktion | Name: {FF8A05}%s{FFFFFF} Rang: {FF8A05}%s{FFFFFF} Leader: {FF8A05}%s{FFFFFF}", frakname(SpielerInfo[playerid][pFraktion]), FRangName(SpielerInfo[playerid][pFraktion], SpielerInfo[playerid][pFRank]), frangtext);
		echo(pID, cWeiss, strStats);
	}
	if(SpielerInfo[playerid][pGruppierung] > 0)
	{
		format(strStats, sizeof(strStats), "Gruppierung | Name: {FF8A05}%s{FFFFFF} Rang: {FF8A05}%s{FFFFFF} Leader: {FF8A05}%s{FFFFFF}", Gruppierungname(SpielerInfo[playerid][pGruppierung]), GRangName(SpielerInfo[playerid][pGruppierung], SpielerInfo[playerid][pGRank]), grangtext);
		echo(pID, cWeiss, strStats);
	}
	format(strStats, sizeof(strStats), "Sonstiges | Skin: {FF8A05}%d{FFFFFF} Wanteds: {FF8A05}%d{FFFFFF}", SpielerInfo[playerid][pSkin], SpielerInfo[playerid][pWanteds]);
	echo(pID, cWeiss, strStats);
	echo(pID, cWeiss, "=====================================================");
}

stock TresorMoney()
{
	moneyTresorL = spieleronline*4748;
	moneyTresorR = spieleronline*4621;
	
	new string[128];
	format(string, sizeof(string), "Linker Tresor: %d$ ; Rechter Tresor: %d$", moneyTresorL, moneyTresorR);
	SendClientMessageToAll(cBank, string);
	return 1;
}

stock PlayerPayday(playerid)
{
	SpielerInfo[playerid][pPayday] = 0;
	echo(playerid, cPayday, "========== PAYDAY ==========");
	SpielerInfo[playerid][pExp] = SpielerInfo[playerid][pExp]+100;
	new noetig = SpielerInfo[playerid][pLevel] * GET_EXP;
	if(SpielerInfo[playerid][pExp] >= noetig)
	{
		//LEVEL Up
		new strLVL[128];
		SpielerInfo[playerid][pLevel] ++;
		SpielerInfo[playerid][pExp] = 0;
		format(strLVL, sizeof(strLVL), "[Payday] Herzlichen Glückwunsch! Du bist nun Level {FF8A05}%d{C8C8C8}!", SpielerInfo[playerid][pLevel]);
		echo(playerid, cPayday, strLVL);
		SetPlayerScore(playerid, SpielerInfo[playerid][pLevel]);
		return 1;
	}
	new strNoetig[128];
	format(strNoetig, sizeof(strNoetig), "[Payday] Du hast %d Erfahrung erhalten. Benötigte Erfahrung zum nächsten Level: %d [%d]", GET_EXP, noetig-SpielerInfo[playerid][pExp], noetig);
	echo(playerid, cPayday, strNoetig);
	return 1;
}

stock SpawnPlayerDynamic(playerid)
{
	if(SpielerInfo[playerid][pSpawn] == 0)
	{
		SpawnPlayerZivi(playerid);
	}
	else if(SpielerInfo[playerid][pSpawn] == 1)
	{
		SetPlayerPos(playerid, SpielerInfo[playerid][pPosX], SpielerInfo[playerid][pPosY], SpielerInfo[playerid][pPosZ]);
		SetCameraBehindPlayer(playerid);
	}
	else if(SpielerInfo[playerid][pSpawn] == 2)
	{
		fraktionspawn(playerid, SpielerInfo[playerid][pFraktion]);
	}
	else if(SpielerInfo[playerid][pSpawn] == 3)
	{
		Gruppierungspawn(playerid, SpielerInfo[playerid][pGruppierung]);
	}
}


stock SaveWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 1;
	if(GetPVarInt(playerid, "Eingeloggt") != 1)
		return 1;
		
	if(PlayerInfo[playerid][WhereBiz] > 0) 
		return 1;
	
	new query[124],
		weaponID,
		ammo;

	format(query, sizeof query, "DELETE FROM `weapons` WHERE `owner` = %i;", SpielerInfo[playerid][peID]);
	mysql_query(query);

	for (new i; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, weaponID, ammo);

		if(!weaponID)
			continue;

		format(query, sizeof query, "INSERT INTO `weapons` (`owner`, `weapon`, `ammo`) VALUES (%i, %i, %i);", SpielerInfo[playerid][peID], weaponID, ammo);
		mysql_query(query);
	}

	return 1;
}

stock LoadWeapon(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 1;

	new query[97],
		weaponID[11],
		ammo[11];
	format(query, sizeof query, "SELECT `weapon`, `ammo` FROM `weapons` WHERE `owner` = %i;", SpielerInfo[playerid][peID]);
	mysql_query(query);
	mysql_store_result();
	while(mysql_retrieve_row())
	{
		mysql_fetch_field_row(weaponID, "weapon");
		mysql_fetch_field_row(ammo, "ammo");

		GivePlayerWeapon(playerid, strval(weaponID), strval(ammo));
	}
	mysql_free_result();

	return 1;
}

stock vHupe(vehicleid)
{
	new Float:carx,Float:cary,Float:carz;
	GetVehiclePos(vehicleid,carx,cary,carz);
    for(new i=0; i<MAX_PLAYERS; i++)
	{
		PlayerPlaySound(i,1147,carx,cary,carz);
	}
}

stock GetDistanceBetweenVehicles(playerid,playerid2)
{
	new Float:x11,Float:y11,Float:z11,Float:x21,Float:y21,Float:z21;
	new Float:dis;

	GetPlayerPos(playerid,x11,y11,z11);
	GetVehiclePos(playerid2,x21,y21,z21);
	dis = floatsqroot((x21-x11)*(x21-x11)+(y21-y11)*(y21-y11)+(z21-z11)*(z21-z11));
	if(GetVehicleVirtualWorld(playerid2)!=GetPlayerVirtualWorld(playerid))return 99999;

	return floatround(dis);
}
stock getNearVehicle(player,Float:range)
{
	new Float:ccx,Float:ccy,Float:ccz,moment=-1,current;

	for(new i;i<MAX_VEHICLES;i++)
	{
		GetVehiclePos(i,ccx,ccy,ccz);
		current=GetDistanceBetweenVehicles(player,i);
		if(current<range)
		{
		    moment=i;
		    range=current;
		}
	}
	return moment;
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
	new strKMH[50], strVeh[50], vehicleid;
	vehicleid = GetPlayerVehicleID(playerid);
	format(strKMH, sizeof(strKMH), "~w~%d km/h",GetPlayerSpeed(playerid));
	TextDrawSetString(kmh[playerid], strKMH);
	format(strVeh, sizeof(strVeh), "~w~%s", getcarname(GetVehicleModel(vehicleid)));
	//printf("VNAME: %d | %s", GetVehicleModel(vehicleid), getcarname(GetVehicleModel(vehicleid)));
	TextDrawSetString(tachoVeh[playerid], strVeh);
	return 1;
}

stock SpawnPaintball(playerid)
{
    new rand = random(sizeof(PaintballSpawns));
	SetPlayerPos(playerid, PaintballSpawns[rand] [p_x], PaintballSpawns[rand] [p_y], PaintballSpawns[rand] [p_z]);
	SetPlayerInterior(playerid, 1);
	GivePlayerWeapon(playerid, 24, 9999);
	GivePlayerWeapon(playerid, 29, 9999);
	GivePlayerWeapon(playerid, 31, 9999);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}


public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

forward ExplodeR();
forward ExplodeL();

public ExplodeL()
{
	CreateExplosion(2143.20728, 1642.40088, 993.11572, 0, 5.0);
	
	moneyTresor[3] = CreateObject(1829, 2143.30151, 1642.37244, 993.02570,   0.00000, 0.00000, 0.00000);
	
	DestroyDynamicObject(moneyTresorDynamit[0]);
	DestroyDynamicObject(moneyTresorDoor[1]);
	DestroyDynamicObject(moneyTresor[1]);
	
	bankrobTresorL = 2;
	return 1;
}

public ExplodeR()
{
	CreateExplosion(2144.66724, 1642.40088, 993.11572, 0, 5.0);
	
	moneyTresor[2] = CreateObject(1829, 2144.76147, 1642.37244, 993.02570,   0.00000, 0.00000, 0.00000);
	
	DestroyDynamicObject(moneyTresorDynamit[1]);
	DestroyDynamicObject(moneyTresorDoor[0]);
	DestroyDynamicObject(moneyTresor[0]);
	
	bankrobTresorR = 2;
	return 1;
}

stock ReloadTresor()
{
	DestroyDynamicObject(moneyTresor[2]);
	DestroyDynamicObject(moneyTresor[3]);
	DestroyDynamicObject(Tresortuer[2]);
	DestroyDynamicObject(Tresortuer[3]);
	
	moneyTresor[0] = CreateDynamicObject(2003, 2144.75610, 1642.76233, 993.02509,   0.00000, 0.00000, 0.00000); //Links
	moneyTresor[1] = CreateDynamicObject(2003, 2143.29614, 1642.76233, 993.02509,   0.00000, 0.00000, 0.00000); 
	moneyTresorDoor[0] = CreateDynamicObject(2004, 2144.35840, 1642.50427, 993.02667,   0.00000, 0.00000, 0.00000); //links
	moneyTresorDoor[1] = CreateDynamicObject(2004, 2142.89844, 1642.50427, 993.02667,   0.00000, 0.00000, 0.00000);
	
	
	
	Tresortuer[0] = CreateDynamicObject(2634, 2144.17285, 1627.02075, 994.24432,   0.00000, 0.00000, 180.00000);
	Tresortuer[1] = CreateDynamicObject(2634, 2144.17285, 1627.08081, 994.24432,   0.00000, 0.00000, 180.00000);
	
	bankrobstarted = 0;
	bankrobTresorL = 0;
	bankrobTresorR = 0;
}


ocmd:bankrobreload(playerid, params[])
{
	ReloadTresor();
	return 1;
}

forward UnlockL();

public UnlockL()
{
	bankrobTresorL = 2;
}

forward UnlockR();

public UnlockR()
{
	bankrobTresorR = 2;
}

stock GetMoneyTresorL(playerid)
{
	new yolomoneyL  = spieleronline*4748;
	new partyoloL = yolomoneyL/15;
	new string[128];
	
	if(moneyTresorL <= partyoloL)
	{
		if(moneyTresorL < 1) return echo(playerid, cBank, "Der Tresor ist leer!");
		format(string, sizeof(string), "Du nimmst %d$ aus dem Tresor und steckst das Geld in einen Beutel. Der Tresor ist nun leer.", moneyTresorL);
		GivePlayerMoney(playerid, moneyTresorL);
		moneyTresorL = 0;
		//BANKRAUBENDE
	}
	else
	{
		format(string, sizeof(string), "Du nimmst %d$ aus dem Tresor und steckst das Geld in einen Beutel.", partyoloL);
		moneyTresorL = moneyTresorL-partyoloL;
		GivePlayerMoney(playerid, partyoloL);
	}
	echo(playerid, cBank, string);
	return 1;
}

stock GetMoneyTresorR(playerid)
{
	new yolomoneyR  = spieleronline*4621;
	new partyoloR = yolomoneyR/15;
	new string[128];
	
	if(moneyTresorR <= partyoloR)
	{
		if(moneyTresorR < 1) return echo(playerid, cBank, "Der Tresor ist leer!");
		format(string, sizeof(string), "Du nimmst %d$ aus dem Tresor und steckst das Geld in einen Beutel. Der Tresor ist nun leer.", moneyTresorR);
		GivePlayerMoney(playerid, moneyTresorR);
		moneyTresorR = 0;
		//BANKRAUBENDE
	}
	else
	{
		format(string, sizeof(string), "Du nimmst %d$ aus dem Tresor und steckst das Geld in einen Beutel.", partyoloR);
		moneyTresorR = moneyTresorR-partyoloR;
		GivePlayerMoney(playerid, partyoloR);
	}
	echo(playerid, cBank, string);
	return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new vehicleid = GetPlayerVehicleID(playerid),
		vehID = vehicleid;
		
	VehiclesOnPlayerStateChange(playerid, newkeys, oldkeys);
	
	//========================================== YES ==========================================
//	if((newkeys == KEY_YES) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	//========================================== BANKROB ==========================================
	if(newkeys == KEY_SECONDARY_ATTACK)
 	{
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 2143.4675,1641.5721,993.5761)) //LINKER TRESOR
		{
			if(bankrobstarted == 0) return 1;
			if(bankrobTresorL == 0)
			{
				moneyTresorDynamit[0] = CreateDynamicObject(354, 2143.20728, 1642.40088, 993.11572,   0.00000, 50.00000, 0.00000);
				echo(playerid, cBank, "Du platzierst C4 am linken Tresor und machst es scharf...");
				SetTimer("ExplodeL", 10000, false);
				bankrobTresorL = 1;
				return 1;
			}
			else if(bankrobTresorL == 2)
			{
				ApplyAnimation(playerid, "ROB_BANK", "CAT_Safe_Rob", 3.1, 0, 1, 1, 0, 0, 1);
				GetMoneyTresorL(playerid);
				bankrobTresorL = 1;
				SetTimer("UnlockL", 3000, 0);
				return 1;
			}
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 2144.7434,1641.4152,993.5761)) //RECHTER TRESOR
		{
			if(bankrobstarted == 0) return 1;
			if(bankrobTresorR == 0)
			{
				moneyTresorDynamit[1] = CreateDynamicObject(354, 2144.66724, 1642.40088, 993.11572,   0.00000, 50.00000, 0.00000);
				echo(playerid, cBank, "Du platzierst C4 am rechten Tresor und machst es scharf...");
				SetTimer("ExplodeR", 10000, false);
				bankrobTresorR = 1;
				return 1;
			}
			else if(bankrobTresorR == 2)
			{
				ApplyAnimation(playerid, "ROB_BANK", "CAT_Safe_Rob", 3.1, 0, 1, 1, 0, 0, 1);
				GetMoneyTresorR(playerid);
				bankrobTresorR = 1;
				SetTimer("UnlockR", 3000, 0);
				return 1;
			}
		}
		AtmOnPlayerKeyStateChange(playerid);
		EnterOnPlayerKeyStateChange(playerid);
		HouseOnPlayerKeyStateChange(playerid);
		BizOnPlayerKeyStateChange(playerid);
	}
		
	//========================================== VEHGATES ==========================================
	if(newkeys == KEY_SUBMISSION && IsPlayerDriver(playerid))
 	{
        	mysql_query("SELECT COUNT(`id`) FROM `vehicle_gates`");
			mysql_store_result();
			new jVV = mysql_fetch_int();
			mysql_free_result();
			
			for(new d = 0; d != jVV+1; d++)
			{
				new e[16];
				format(e, sizeof(e), "%d", d);
				if(IsPlayerInRangeOfPoint(playerid,v_enterdist,mysql_GetFloat("vehicle_gates", "x", "id", e), mysql_GetFloat("vehicle_gates", "y", "id", e), mysql_GetFloat("vehicle_gates", "z", "id", e)))
				{
					if((!mysql_GetInt("vehicle_gates", "faction", "id", e) && !mysql_GetInt("vehicle_gates", "grouping", "id", e)) || mysql_GetInt("vehicle_gates", "faction", "id", e) == SpielerInfo[playerid][pFraktion] || mysql_GetInt("vehicle_gates", "grouping", "id", e) == SpielerInfo[playerid][pGruppierung])
					{
						new currentveh = GetPlayerVehicleID(playerid);

						SetPlayerPos(playerid, mysql_GetFloat("vehicle_gates", "to_x", "id", e), mysql_GetFloat("vehicle_gates", "to_y", "id", e), mysql_GetFloat("vehicle_gates", "to_z", "id", e));
						SetPlayerInterior(playerid, mysql_GetInt("vehicle_gates", "to_int", "id", e));
						SetPlayerVirtualWorld(playerid, d);

						SetVehiclePos(currentveh, mysql_GetFloat("vehicle_gates", "to_x", "id", e), mysql_GetFloat("vehicle_gates", "to_y", "id", e), mysql_GetFloat("vehicle_gates", "to_z", "id", e));
						LinkVehicleToInterior(currentveh, mysql_GetInt("vehicle_gates", "to_int", "id", e));
						SetVehicleVirtualWorld(currentveh, d);

						PutPlayerInVehicle(playerid, currentveh, 0);
						return 1;
					}
				}
				new a[16];
				format(a, sizeof(a), "%d", GetPlayerVirtualWorld(playerid));
				if(IsPlayerInRangeOfPoint(playerid,v_enterdist,mysql_GetFloat("vehicle_gates", "to_x", "id", a), mysql_GetFloat("vehicle_gates", "to_y", "id", a), mysql_GetFloat("vehicle_gates", "to_z", "id", a)))
				{
					if((!mysql_GetInt("vehicle_gates", "faction", "id", a) && !mysql_GetInt("vehicle_gates", "grouping", "id", a)) || mysql_GetInt("vehicle_gates", "faction", "id", a) == SpielerInfo[playerid][pFraktion] || mysql_GetInt("vehicle_gates", "grouping", "id", a) == SpielerInfo[playerid][pGruppierung])
					{
						new currentveh;
						currentveh = GetPlayerVehicleID(playerid);
						SetPlayerPos(playerid,mysql_GetFloat("vehicle_gates", "x", "id", a), mysql_GetFloat("vehicle_gates", "y", "id", a), mysql_GetFloat("vehicle_gates", "z", "id", a));
						SetPlayerInterior(playerid,mysql_GetInt("vehicle_gates", "int", "id", a));
						SetPlayerVirtualWorld(playerid, 0);

						SetVehiclePos(currentveh, mysql_GetFloat("vehicle_gates", "x", "id", a), mysql_GetFloat("vehicle_gates", "y", "id", a), mysql_GetFloat("vehicle_gates", "z", "id", a));
						LinkVehicleToInterior(currentveh, mysql_GetInt("vehicle_gates", "int", "id", a));
						SetVehicleVirtualWorld(currentveh, 0);

						PutPlayerInVehicle(playerid, currentveh, 0);
						return 1;
					}
				}
			}
	}
	
	MovedoorOnPlayerStateChange(playerid, newkeys, oldkeys);
	//========================================== ABSCHLEPPER ==========================================
	if((newkeys == KEY_ACTION)&&(IsPlayerDriver(playerid)&& SpielerInfo[playerid][pFraktion] == 2)) 
	{
		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525)
		{
			if(IsTrailerAttachedToVehicle(vehID))
			{
				//Fahrzeug abhängen
				DetachTrailerFromVehicle(vehID);
			}
			else
			{
				//Fahrzeug anhängen
				new carID = INVALID_VEHICLE_ID;
				new Float:abstand = 8;
				new Float:xc, Float:yc, Float:zc;
				GetVehiclePos(vehicleid, xc, yc, zc);
				for(new i=0; i<MAX_VEHICLES; i++)
				{
					if(!IsVehicleStreamedIn(i, playerid))continue;
					if(i==vehID)continue;
					if(GetVehicleDistanceFromPoint(i, xc, yc, zc) < abstand)
					{
						abstand = GetVehicleDistanceFromPoint(i, xc, yc, zc);
						carID = i;
					}
				}
				if(carID != INVALID_VEHICLE_ID)
				{
					AttachTrailerToVehicle(carID, vehID);
				}
			}
		}
		else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 453)
		{
			if(IsTrailerAttachedToVehicle(vehID))
			{
				//Fahrzeug abhängen
				DetachTrailerFromVehicle(vehID);
			}
			else
			{
				//Fahrzeug anhängen
				new carID = INVALID_VEHICLE_ID;
				new Float:abstand = 50;
				new Float:xc, Float:yc, Float:zc;
				GetVehiclePos(vehicleid, xc, yc, zc);
				for(new i=0; i<MAX_VEHICLES; i++)
				{
					if(!IsVehicleStreamedIn(i, playerid))continue;
					if(i==vehID)continue;
					if(GetVehicleDistanceFromPoint(i, xc, yc, zc) < abstand)
					{
						abstand = GetVehicleDistanceFromPoint(i, xc, yc, zc);
						carID = i;
					}
				}
				if(carID != INVALID_VEHICLE_ID)
				{
					AttachTrailerToVehicle(carID, vehID);
				}
			}
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new pip[16], strSuccess[50];
	if(success == 1)
		format(strSuccess, sizeof(strSuccess), "Erfolgreich");
	if(success == 0)
		format(strSuccess, sizeof(strSuccess), "Fehlerhaft");
	
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerNPC(i))
			continue;
		GetPlayerIp(i, pip, sizeof(pip));
        if(!strcmp(ip, pip, true)) 
		{
			new string[128];
			format(string, sizeof(string), "[INFO] %s hat versucht sich als RCON-Admin einzuloggen. (%s)", SpielerName(i), strSuccess);
			Adminecho(cGelb, string);
			break;
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
		//========================================== LOGIN ==========================================
		if(dialogid == diaLogin)
		{
		    if(response == 1)
			{
			    if(strlen(inputtext) == 0)
			    {
					new string[200], string2[50];
					format(string2,sizeof(string2),"{FF8A05}Login");
					format(string,sizeof(string),"{FFFFFF}Willkommen zurück, {FF8A05}%s{FFFFFF}!\nGib bitte dein Passwort ein, um den Server zu betreten.\nBitte passe auf, dass nur du dein Passwort kennst!",SpielerName(playerid));
					ShowPlayerDialog(playerid, diaLogin,DIALOG_STYLE_PASSWORD,string2, string,"Einloggen","");
					return 1;
				}
				else
				{
				    new Name[MAX_PLAYER_NAME];
				    GetPlayerName(playerid, Name, MAX_PLAYER_NAME);
					if(!strcmp(MD5_Hash(inputtext), mysql_ReturnPasswort(Name), true))
					{
						DeletePVar(playerid, "LoginKamera");
					    SetPVarInt(playerid,"Eingeloggt",1);
					    LoadPlayer(playerid);
                    	SpawnPlayer(playerid);
						TextDrawShowForPlayer(playerid,Logo1);
						TextDrawShowForPlayer(playerid,Logo2);
						TextDrawShowForPlayer(playerid,Logo3);
						TextDrawShowForPlayer(playerid,Zonetext[playerid]);
						
						TextDrawHideForPlayer(playerid,Login0);
						TextDrawHideForPlayer(playerid,Login1);
						TextDrawHideForPlayer(playerid,LoginNews);
						TextDrawHideForPlayer(playerid,LoginNewsHead);
						TextDrawHideForPlayer(playerid,LoginServername);
						TextDrawHideForPlayer(playerid,LoginSlogan);
						
						TextDrawShowForPlayer(playerid,u_h_r);
						TextDrawShowForPlayer(playerid,u_h_d);
						TextDrawShowForPlayer(playerid, underdollar[playerid]);
						TextDrawShowForPlayer(playerid,xwanted[playerid]);
						
						copyrightSpielerLadenundso(playerid);
						return 1;
					}
					else
					{
						new string[200], string2[50];
						format(string2,sizeof(string2),"{FF8A05}Login");
						format(string,sizeof(string),"Bitte gib dein richtiges Passwort ein! \n{FFFFFF}Willkommen zurück, {FF8A05}%s{FFFFFF}!\nGib bitte dein Passwort ein, um den Server zu betreten.\nBitte passe auf, dass nur du dein Passwort kennst!",SpielerName(playerid));
						ShowPlayerDialog(playerid, diaLogin,DIALOG_STYLE_PASSWORD,string2, string,"Einloggen","");
						return 1;
					}
				}
			}
			if(response == 0)
	        {
	            Kick(playerid);
				return 1;
			}
		}
		//========================================== SMS ==========================================
		if(dialogid == diaSMS)
		{
			if(response == 1)
			{
				new strPlayer[128], strPID[128], strLog[128];
				format(strPlayer, sizeof(strPlayer), "Nachricht gesendet an %s: %s", SpielerName(clpl[playerid]), inputtext);
				format(strPID, sizeof(strPID), "Nachricht empfangen von %s: %s", SpielerName(playerid), inputtext);
				format(strLog, sizeof(strLog), "--> SMS von %s an %s: %s", SpielerName(playerid), SpielerName(clpl[playerid]), inputtext);
				echo(playerid, cFullGelb, strPlayer);
				echo(clpl[playerid], cFullGelb, strPID);
				print(strLog);
			}
			if(response == 0)
			{
				
			}
		}
		//========================================== AUTOHAUS ==========================================
		if(dialogid == diaAutohaus)
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						VCreateVehicle(playerid, 1, 560,  -1637.4935,1210.0513,6.8119,224.8517, -1,-1, SpielerName(playerid), false, false, 50.0);
						echo(playerid, cGruen, "Sultan gekauft...");
					}
					case 1:
					{
						VCreateVehicle(playerid, 1, 411,  -1637.4935,1210.0513,6.8119,224.8517, -1,-1, SpielerName(playerid), false, false, 50.0);
						echo(playerid, cGruen, "Infernus gekauft...");
					}
				}
			}
			if(response == 0)
			{
				
			}
		}
		//========================================== Grupperiung Settings ==========================================
		if(dialogid == diaGSettings)
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						ShowDialog(playerid, diaGName, DIALOG_STYLE_INPUT, "Name der Gruppierung ändern", "Benutzung: [Name]", "Absenden", "Abbrechen");
					}
					case 1:
					{
						new strInhalt[256];
						for(new i; i < 11; i++)
						{
							format(strInhalt, sizeof strInhalt, "%s %s [%d]\n", strInhalt, GRangName(SpielerInfo[playerid][pGruppierung], i), i);
						}
						ShowDialog(playerid, diaGRang, DIALOG_STYLE_LIST, "Gruppierung - Rangnamen", strInhalt, "Ändern", "Fertig");
					}
					case 2:
					{
						ShowDialog(playerid, diaGMOTD, DIALOG_STYLE_INPUT, "Gruppierung - MOTD", "Bitte gib den neuen Text der MOTD ein: \n(Benutze ''~'' für eine neue Zeile)", "Ändern", "Fertig");
					}
				}
			}
			if(response == 0)
			{
				
			}
		}
		if(dialogid == diaGName)
		{
			if(response == 1)
			{
				new text[128], strPlayer[256], gid[8];
				if(sscanf(inputtext,"s[128]",text))return ShowDialog(playerid, diaGName, DIALOG_STYLE_INPUT, "Name der Gruppierung ändern", "Fehler: Ungültige Eingabe\nBenutzung: [Name]", "Absenden", "Abbrechen");
				valstr(gid, SpielerInfo[playerid][pGruppierung]);
				mysql_SetString("groupings", "name", text, "id", gid);
				format(strPlayer, sizeof(strPlayer), ">> [Gruppierung]Du hast den Namen der Gruppierung erfolgreich zu [%s] geändert.", text);
				printf(">> [Gruppierung]%s hat den Namen der Gruppierung erfolgreich zu [%s] geändert.", SpielerName(playerid), text);
				echo(playerid, cGruppe, strPlayer);
			}
			if(response == 0)
			{
				
			}
		}
		if(dialogid == diaGRang)
		{
			if(response == 1)
			{
				SetPVarInt(playerid, "GRangListItem", listitem);
				ShowDialog(playerid, diaGRangBla, DIALOG_STYLE_INPUT, "Rangnamen ändern", "Bitte gib den neuen Rangnamen ein:", "Ändern", "Abbrechen");
			}
		}
		if(dialogid == diaGRangBla)
		{
			if(response == 1)
			{
				new text[128], strPlayer[256];
				if(sscanf(inputtext,"s[50]",text)) return ShowDialog(playerid, diaGRangBla, DIALOG_STYLE_INPUT, "Rangnamen ändern", "Fehler: Ungültige Eingabe\nBitte gib den neuen Rangnamen ein:", "Ändern", "Abbrechen");
				new strListitem[4], strGrpID[4];
				valstr(strListitem, GetPVarInt(playerid, "GRangListItem"));
				valstr(strGrpID, SpielerInfo[playerid][pGruppierung]);
				mysql_SetStringWhere("grouping_rank_names", "name", text, "grouping", strGrpID, "rank", strListitem);
				format(strPlayer, sizeof(strPlayer), ">> [Gruppierung]Du hast den Namen des Ranges [%d] zu [%s] geändert.", GetPVarInt(playerid, "GRangListItem"), text);
				printf(">> [Fraktion]%s hat den Namen des Ranges [%d] zu [%s] geändert.", SpielerName(playerid), GetPVarInt(playerid, "GRangListItem"), text);
				echo(playerid, cGruppe, strPlayer);
				DeletePVar(playerid, "GRangListItem");
			}
		}
		if(dialogid == diaGMOTD)
		{
			if(response == 1)
			{
				new text[128], strPlayer[128];
				if(sscanf(inputtext,"s[50]",text)) return ShowDialog(playerid, diaFMOTD, DIALOG_STYLE_INPUT, "Gruppierung - MOTD", "Fehler: Ungültige Eingabe\nBitte gib den neuen Text der MOTD ein: \n(Benutze ''~'' für eine neue Zeile)", "Ändern", "Fertig");
				new strgid[4];
				valstr(strgid, SpielerInfo[playerid][pGruppierung]);
				mysql_SetString("groupings", "motd", text, "id", strgid);
				format(strPlayer, sizeof strPlayer, "Du hast die Message of the Day geändert. [%s]", text);
				echo(playerid, cGruppe, strPlayer);
				ShowMOTD(playerid);
			}
		}
		//========================================== Fraktions Settings ==========================================
		if(dialogid == diaFSettings)
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						ShowDialog(playerid, diaFName, DIALOG_STYLE_INPUT, "Name der Fraktion ändern", "Benutzung: [Name]", "Absenden", "Abbrechen");
					}
					case 1:
					{
						new strInhalt[256];
						for(new i; i < 11; i++)
						{
							format(strInhalt, sizeof strInhalt, "%s %s [%d]\n", strInhalt, FRangName(SpielerInfo[playerid][pFraktion], i), i);
						}
						ShowDialog(playerid, diaFRang, DIALOG_STYLE_LIST, "Fraktion - Rangnamen", strInhalt, "Ändern", "Fertig");
					}
					case 2:
					{
						ShowDialog(playerid, diaFMOTD, DIALOG_STYLE_INPUT, "Fraktion - MOTD", "Bitte gib den neuen Text der MOTD ein: \n(Benutze ''~'' für eine neue Zeile)", "Ändern", "Fertig");
					}
				}
			}
			if(response == 0)
			{
				
			}
		}
		if(dialogid == diaFName)
		{
			if(response == 1)
			{
				new text[128], strPlayer[256], frakint[64];
				if(sscanf(inputtext,"s[128]",text))return ShowDialog(playerid, diaFName, DIALOG_STYLE_INPUT, "Name der Fraktion ändern", "Fehler: Ungültige Eingabe\nBenutzung: [Name]", "Absenden", "Abbrechen");
				format(frakint, sizeof(frakint), "%d", SpielerInfo[playerid][pFraktion]);
				mysql_SetString("factions", "name", text, "id", frakint);
				format(strPlayer, sizeof(strPlayer), ">> [Fraktion]Du hast den Namen der Fraktion erfolgreich zu [%s] geändert.", text);
				printf(">> [Fraktion]%s hat den Namen der Fraktion erfolgreich zu [%s] geändert.", SpielerName(playerid), text);
				echo(playerid, cHellblau, strPlayer);
			}
			if(response == 0)
			{
				
			}
		}
		if(dialogid == diaFRang)
		{
			if(response == 1)
			{
				SetPVarInt(playerid, "FRangListItem", listitem);
				ShowDialog(playerid, diaFRangBla, DIALOG_STYLE_INPUT, "Rangnamen ändern", "Bitte gib den neuen Rangnamen ein:", "Ändern", "Abbrechen");
			}
		}
		if(dialogid == diaFRangBla)
		{
			if(response == 1)
			{
				new text[128], strPlayer[256];
				if(sscanf(inputtext,"s[50]",text)) return ShowDialog(playerid, diaFRangBla, DIALOG_STYLE_INPUT, "Rangnamen ändern", "Fehler: Ungültige Eingabe\nBitte gib den neuen Rangnamen ein:", "Ändern", "Abbrechen");
				new strListitem[4], strFrakID[4];
				valstr(strListitem, GetPVarInt(playerid, "FRangListItem"));
				valstr(strFrakID, SpielerInfo[playerid][pFraktion]);
				mysql_SetStringWhere("faction_rank_names", "name", text, "faction", strFrakID, "rank", strListitem);
				format(strPlayer, sizeof(strPlayer), ">> [Fraktion]Du hast den Namen des Ranges [%d] zu [%s] geändert.", GetPVarInt(playerid, "FRangListItem"), text);
				printf(">> [Fraktion]%s hat den Namen des Ranges [%d] zu [%s] geändert.", SpielerName(playerid), GetPVarInt(playerid, "FRangListItem"), text);
				echo(playerid, cHellblau, strPlayer);
				DeletePVar(playerid, "FRangListItem");
			}
		}
		if(dialogid == diaFMOTD)
		{
			if(response == 1)
			{
				new text[128], strPlayer[128];
				if(sscanf(inputtext,"s[50]",text)) return ShowDialog(playerid, diaFMOTD, DIALOG_STYLE_INPUT, "Fraktion - MOTD", "Fehler: Ungültige Eingabe\nBitte gib den neuen Text der MOTD ein: \n(Benutze ''~'' für eine neue Zeile)", "Ändern", "Fertig");
				new strFID[4];
				valstr(strFID, SpielerInfo[playerid][pFraktion]);
				mysql_SetString("factions", "motd", text, "id", strFID);
				format(strPlayer, sizeof strPlayer, "Du hast die Message of the Day geändert. [%s]", text);
				echo(playerid, cHellblau, strPlayer);
				ShowMOTD(playerid);
			}
		}
		//========================================== Admin Settings ==========================================
		if(dialogid == diaASettings)
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						ShowDialog(playerid, diaAMOTD, DIALOG_STYLE_INPUT, "Adminpanel - MOTD ändern", "Bitte gib den neuen Text für die Message of the Day ein: \n(Benutze ''~'' für eine neue Zeile)", "Ändern", "Abbrechen");
					}
					case 1:
					{
						ShowDialog(playerid, diaAFrakSpawn, DIALOG_STYLE_MSGBOX, "Adminpanel - Fraktionsspawn ändern", "Mit einem Klick auf ''Setzen'' wird dein\naktueller Standpunkt als Spawn deiner\naktuellen Fraktion gesetzt.", "Abbrechen", "Setzen");
					}
					case 2:
					{
						ShowDialog(playerid, diaAGrpSpawn, DIALOG_STYLE_MSGBOX, "Adminpanel - Gruppierungsspawn ändern", "Mit einem Klick auf ''Setzen'' wird dein\naktueller Standpunkt als Spawn deiner\naktuellen Fraktion gesetzt.", "Abbrechen", "Setzen");
					}
					case 3:
					{
						ShowDialog(playerid, diaAFrakCars, DIALOG_STYLE_MSGBOX, "-", "-", "-", "-");
					}
					case 4:
					{
						ShowDialog(playerid, diaAGrpCars, DIALOG_STYLE_MSGBOX, "-", "-", "-", "-");
					}
					case 5:
					{
						if(adclosed == 0)
						{
							new string[128];
							format(string, sizeof(string), "[AdmCmd] %s hat die Werbung deaktiviert.", SpielerName(playerid));
							Adminecho(cGelb, string);
							adclosed = 1;
							ocmd_asettings(playerid, inputtext);
							TextDrawSetString(Werbungstext, "~b~Werbung: ~g~Werbung wurde von einem Admin deaktiviert. ~r~Kontakt: /sup (-)");
							return 1;
						}
						if(adclosed == 1)
						{
							new string[128];
							format(string, sizeof(string), "[AdmCmd] %s hat die Werbung aktiviert.", SpielerName(playerid));
							Adminecho(cGelb, string);
							adclosed = 0;
							ocmd_asettings(playerid, inputtext);
							TextDrawSetString(Werbungstext, "~b~Werbung: ~g~Hier koennte Ihre Werbung stehen! ~r~Kontakt: /ad (-)");
							return 1;
						}
					}
				}
			}
			if(response == 0)
			{
				
			}
		}
		if(dialogid == diaAFrakSpawn)
		{
			if(response == 1)
			{
				
			}
			if(response == 0)
			{
				new Float:ax, Float:ay, Float:az, strA[128], strFChat[128], int, frak[16];
				GetPlayerPos(playerid, ax, ay, az);
				
				int = GetPlayerInterior(playerid);
				format(frak, sizeof(frak),"%d",SpielerInfo[playerid][pFraktion]);
				
				
				mysql_SetInt("factions", "spawn_int", int, "id", frak);
				mysql_SetInt("factions", "spawn_world", GetPlayerVirtualWorld(playerid), "id", frak);
				mysql_SetFloat("factions", "spawn_x", ax, "id", frak);
				mysql_SetFloat("factions", "spawn_y", ay, "id", frak);
				mysql_SetFloat("factions", "spawn_z", az, "id", frak);
				
				format(strA, 128, "Du hast den Spawn von %s erfolgreich auf %f %f %f [%d] geändert.", frakname(SpielerInfo[playerid][pFraktion]), ax, ay, az, int);
				format(strFChat, 128, "[AdmCmd] %s hat euren Spawn neu gesetzt!", SpielerName(playerid));
				
				echo(playerid, cHellblau, strA);
				EchoFraktion(SpielerInfo[playerid][pFraktion], strFChat);
				
				printf("--> [AdmCmd] %s hat den Spawn von %s auf folgende Koordinaten gesetzt: %f %f %f [%d]",SpielerName(playerid), frakname(SpielerInfo[playerid][pFraktion]), ax, ay, az, int);
				
			}
		}
		if(dialogid == diaAGrpSpawn)
		{
			if(response == 1)
			{
				
			}
			if(response == 0)
			{
				new Float:ax, Float:ay, Float:az, strA[128], strFChat[128], int, frak[16];
				GetPlayerPos(playerid, ax, ay, az);
				
				int = GetPlayerInterior(playerid);
				format(frak, sizeof(frak),"%d",SpielerInfo[playerid][pGruppierung]);
				
				
				mysql_SetInt("groupings", "spawn_int", int, "id", frak);
				mysql_SetFloat("groupings", "spawn_x", ax, "id", frak);
				mysql_SetFloat("groupings", "spawn_y", ay, "id", frak);
				mysql_SetFloat("groupings", "spawn_z", az, "id", frak);
				mysql_SetInt("groupings", "spawn_vw", GetPlayerVirtualWorld(playerid), "id", frak);
				
				format(strA, 128, "Du hast den Spawn von %s erfolgreich auf %f %f %f [%d] geändert.", Gruppierungname(SpielerInfo[playerid][pGruppierung]), ax, ay, az, int);
				format(strFChat, 128, "[AdmCmd] %s hat euren Spawn neu gesetzt!", SpielerName(playerid));
				
				echo(playerid, cGruppe, strA);
				EchoGruppierung(SpielerInfo[playerid][pGruppierung], strFChat);
				
				printf("--> [AdmCmd] %s hat den Spawn von %s auf folgende Koordinaten gesetzt: %f %f %f [%d]",SpielerName(playerid), Gruppierungname(SpielerInfo[playerid][pGruppierung]), ax, ay, az, int);
				
			}
		}
		if(dialogid == diaAMOTD)
		{
			if(response == 1)
			{
				new text[128], strPlayer[128];
				if(sscanf(inputtext,"s[50]",text)) return ShowDialog(playerid, diaFMOTD, DIALOG_STYLE_INPUT, "Adminpanel - MOTD ändern", "Fehler: Ungültige Eingabe\nBitte gib den neuen Text der MOTD ein: \n(Benutze ''~'' für eine neue Zeile)", "Ändern", "Abbrechen");
				mysql_SetString("server", "motd", text, "id", "1");
				
				format(strPlayer, sizeof strPlayer, "[AdmCmd]Du hast die Message of the Day geändert. [%s]", text);
				echo(playerid, cRot, strPlayer);
				ShowMOTD(playerid);
			}
		}
		//========================================== Hilfe ==========================================
		if(dialogid == diaHelp)
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						//ALLGEMEIN
						
					}
					case 1:
					{
						//Fraktion
						
					}
					case 2:
					{
						//Gruppierung
						
					}
					case 3:
					{
						//Naa
						
					}
					case 4:
					{
						//Häuser
						ShowDialog(playerid, diaHouseHelp, DIALOG_STYLE_MSGBOX, "Dynamic Roleplay - Häuser Hilfe", "Zum kaufen oder zum betreten einfach [Enter] drücken. ;)\n\nBefehle: \n/setname, /verkaufen(sell), /setrent, /lock", "Okay", "");
					}
					case 5:
					{
						//Credits
						ShowDialog(playerid, diaCredits, DIALOG_STYLE_MSGBOX, "Dynamic Roleplay - Credits", "made by ElDiabolo... \nweiteres folgt...", "Okay", "");
					}
				}
			}
			if(response == 0)
			{
				
			}
		}
		//========================================== WANTEDS ==========================================
		if(dialogid == diaWanted)
		{
			new varWanteds;
			if(response == 1)
			{
				for(new i; i < MAX_PLAYERS; i++)
				{
					if(SpielerInfo[i][pWanteds] > 0)
					{
						if(varWanteds == listitem)
						{
							new string[256], strTitel[64];
							format(strTitel, sizeof(strTitel), "Gesuchter: %s", SpielerName(i));
							format(string, sizeof(string), "Name: %s\nVerbrechen: %d\nGesucht wegen: %s\nZuletzt gesehen: %s", SpielerName(i), SpielerInfo[i][pWanteds], SpielerInfo[i][pWantedReason], getzone(i));
							ShowDialog(playerid, diaWanteds, DIALOG_STYLE_MSGBOX, strTitel, string, "Okay", "");
							return 1;
						}
						varWanteds ++;
						
					}
				}
			}
			if(response == 0)
			{
				
			}
		}
		BizOnDialogResponse(playerid, dialogid, response, listitem, inputtext);
		HouseOnDialogResponse(playerid, dialogid, response, listitem, inputtext);
		if(dialogid == diaSettings)
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						if(SpielerInfo[playerid][pSpawn] == 0)
						{
							SpielerInfo[playerid][pSpawn] = 1;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
						if(SpielerInfo[playerid][pSpawn] == 1)
						{
							SpielerInfo[playerid][pSpawn] = 2;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
						if(SpielerInfo[playerid][pSpawn] == 2)
						{
							SpielerInfo[playerid][pSpawn] = 3;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
						if(SpielerInfo[playerid][pSpawn] == 3)
						{
							SpielerInfo[playerid][pSpawn] = 0;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
					}
					case 1:
					{
						if(SpielerInfo[playerid][pJoined] == 0)
						{
							SpielerInfo[playerid][pJoined] = 1;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
						if(SpielerInfo[playerid][pJoined] == 1)
						{
							SpielerInfo[playerid][pJoined] = 2;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
						if(SpielerInfo[playerid][pJoined] == 2)
						{
							SpielerInfo[playerid][pJoined] = 3;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
						if(SpielerInfo[playerid][pJoined] == 3)
						{
							SpielerInfo[playerid][pJoined] = 0;
							ocmd_settings(playerid, inputtext);
							return 1;
						}
					}
				}
			}
		}
		AtmOnDialogResponse(playerid, dialogid, response, listitem, inputtext);		
		if(dialogid == diaWeather && response == 1)
		{
			switch(listitem)
			{
				case 0:
				{
					weather=0;
					SetWeather(0);
					echo(playerid, cRot, "Du hast das Wetter auf Schoenwetter gesetzt");
				}
				case 1:
				{
					weather=12;
					SetWeather(12);
					echo(playerid, cRot, "Du hast das Wetter auf bewoelkt gesetzt");
				}
				case 2:
				{
					weather=8;
					SetWeather(8);
					echo(playerid, cRot, "Du hast das Wetter auf Regen+Sturm gesetzt");
				}
				case 3:
				{
					weather=9;
					SetWeather(9);
					echo(playerid, cRot, "Du hast das Wetter auf neblelig gesetzt");
				}
				case 4:
				{
					weather=11;
					SetWeather(11);
					echo(playerid, cRot, "Du hast das Wetter auf extreme Hitze gesetzt");
				}
				case 5:
				{
					weather=2009;
					SetWeather(2009);
					echo(playerid, cRot, "Du hast das Wetter auf pinker Himmel gesetzt");
				}
				case 6:
				{
					weather=16;
					SetWeather(16);
					echo(playerid, cRot, "Du hast das Wetter auf regnerisch gesetzt");
				}
				case 7:
				{
					weather=19;
					SetWeather(19);
					echo(playerid, cRot, "Du hast das Wetter auf Sandsturm gesetzt");
				}
				case 8:
				{
					weather=23;
					SetWeather(23);
					echo(playerid, cRot, "Du hast das Wetter auf blauer Himmel gesetzt");
				}
				case 9:
				{
					weather=24;
					SetWeather(24);
					echo(playerid, cRot, "Du hast das Wetter auf tuerkieser Himmel gesetzt");
				}
				case 10:
				{
					weather=30;
					SetWeather(30);
					echo(playerid, cRot, "Du hast das Wetter auf grauer Himmel gesetzt");
				}
				case 11:
				{
					weather=36;
					SetWeather(36);
					echo(playerid, cRot, "Du hast das Wetter auf Sonnenaufgang gesetzt");
				}
				case 12:
				{
					weather=46;
					SetWeather(46);
					echo(playerid, cRot, "Du hast das Wetter auf Sonnenuntergang gesetzt");
				}
				case 13:
				{
					weather=50;
					SetWeather(50);
					echo(playerid, cRot, "Du hast das Wetter auf kommendes Gewitter gesetzt");
				}
			}
		}
		//======================================================== TUNING ====================================================================
		if(dialogid == diaColorTuning)
		{
			if(response == 1 && listitem == 1)
			{
				ShowDialog(playerid, diaColorTuningChange, DIALOG_STYLE_LIST, "Farbart wählen", "Farbe 1\nFarbe 2", "Auswählen", "Abbrechen");
			}
			if(response == 1 && listitem == 0)
			{
				ShowDialog(playerid, diaPaintjob, DIALOG_STYLE_LIST, "Paintjob wählen", "Paintjob 1\nPaintjob 2\nPaintjob 3", "Auswählen", "Abbrechen");
			}
			if(response == 1 && listitem == 2)
			{
				RepairVehicle(GetPlayerVehicleID(playerid));
				echo(playerid, cGruen, "Fahrzeug repariert.");
			}
		}
		if(dialogid == diaColorTuningChange)
		{
			if(response == 1)
			{
				new strFarbwahl[3048];
				for(new i; i < sizeof(VehicleColoursTableARGB); i++)
				{
					format(strFarbwahl, sizeof(strFarbwahl), "%s{%06x}%d\n", strFarbwahl, VehicleColoursTableARGB[i] >>> 8, i);
				}
				
				if(listitem == 0)
				{
					ShowDialog(playerid, diaColorTuningChangeA, DIALOG_STYLE_LIST, "Farbe wählen", strFarbwahl, "Auswählen", "Abbrechen");
				}
				if(listitem == 1)
				{
					ShowDialog(playerid, diaColorTuningChangeB, DIALOG_STYLE_LIST, "Farbe wählen", strFarbwahl, "Auswählen", "Abbrechen");
				}
			}
		}
		if(dialogid == diaColorTuningChangeA)
		{
			if(response == 1)
			{
				new color, a;
				new vID = GetPlayerVehicleID(playerid);
				GetVehicleColor(vID, a, color);
				ChangeVehicleColor(vID, listitem, color);
				new strPlayer[128];
				format(strPlayer, sizeof(strPlayer), "Du hast das Fahrzeug gefärbt. Farbe: %d", listitem);
				echo(playerid, cGruen, strPlayer);
			}
		}
		if(dialogid == diaColorTuningChangeB)
		{
			if(response == 1)
			{
				new color, a;
				new vID = GetPlayerVehicleID(playerid);
				GetVehicleColor(vID, color, a);
				ChangeVehicleColor(vID, color, listitem);
				new strPlayer[128];
				format(strPlayer, sizeof(strPlayer), "Du hast das Fahrzeug gefärbt. Farbe: %d", listitem);
				echo(playerid, cGruen, strPlayer);
			}
		}
		if(dialogid == diaPaintjob)
		{
			if(response == 1)
			{
				if(!canHavePaintjob(GetVehicleModel(GetPlayerVehicleID(playerid)))) return echo(playerid, cRot, "Du kannst diesem Fahrzeug keinen Paintjob verpassen!");
				ChangeVehiclePaintjob(GetPlayerVehicleID(playerid), listitem);
			}
		}
		//Auspuff ändern\nFronststoßstange ändern\nHeckstoßstange ändern\nDach ändern\nSpoiler ändern\nSeitenteile ändern\nRäder ändern
		if(dialogid == diaTuning)
		{
			if(response == 1)
			{
				if(listitem == 0)
				{
					//Auspuff
					ShowDialog(playerid, diaTuningAuspuff, DIALOG_STYLE_LIST, "Tuningmenü - Auspuff", "", "Einbauen", "Abbrechen");
				}
				if(listitem == 1)
				{
					//Fronststoßstange
				}
				if(listitem == 2)
				{
					//Heckstoßstange
				}
				if(listitem == 3)
				{
					//Dach
				}
				if(listitem == 4)
				{
					//Spoiler
				}
				if(listitem == 5)
				{
					//Seitenteile
				}
				if(listitem == 6)
				{
					//Räder
					ShowDialog(playerid, diaTuningRaeder, DIALOG_STYLE_LIST, "Tuningmenü - Räder", "Shadow \nMega \nRimshine \nWires \nClassic \nTwist \nCutter \nSwitch \nGrove \nImport \nDollar \nTrance \nAtomic \nAhab \nVirtual \nAccess", "Einbauen", "Abbrechen");
				}
			}
		}
		if(dialogid == diaTuningMotor)
		{
			if(response == 1)
			{
				if(listitem == 0)
				{
					//Neon 
				}
				if(listitem == 1)
				{
					new vID = GetPlayerVehicleID(playerid);
					if(!IsPlayerInACar(playerid)) return echo(playerid, cRot, "Du bist in keinem Auto.");
					AddVehicleComponent(vID, 1087);
					echo(playerid, cGruen, "Hydraulik wurde eingebaut.");
					//Hydraulik
				}
				if(listitem == 2)
				{
					//Nitro
					ShowDialog(playerid, diaTuningNitro, DIALOG_STYLE_LIST, "Tuningmenü - Nitro", "2x Nitro \n5x Nitro \n10x Nitro", "Einbauen", "Abbrechen");
				}
				if(listitem == 3)
				{
					//Bass
					new vID = GetPlayerVehicleID(playerid);
					if(!IsPlayerInACar(playerid)) return echo(playerid, cRot, "Du bist in keinem Auto.");
					AddVehicleComponent(vID, 1086);
					echo(playerid, cGruen, "Bass wurde eingebaut.");
				}
			}
		}
		if(dialogid == diaTuningNitro)
		{
			if(response == 1)
			{
				new vID = GetPlayerVehicleID(playerid);
				if(!IsPlayerInACar(playerid)) return echo(playerid, cRot, "Du bist in keinem Auto.");
				if(listitem == 0)
				{
					AddVehicleComponent(vID, 1009);
				}
				if(listitem == 1)
				{
					AddVehicleComponent(vID, 1008);
				}
				if(listitem == 2)
				{
					AddVehicleComponent(vID, 1010);
				}
				echo(playerid, cGruen, "Nitro wurde eingebaut.");
			}
		}
		if(dialogid == diaTuningRaeder)
		{
			if(response == 1)
			{
				new vID = GetPlayerVehicleID(playerid);
				if(!IsPlayerInACar(playerid)) return echo(playerid, cRot, "Du bist in keinem Auto.");
				if(listitem <= 12)
				{
					AddVehicleComponent(vID, 1073+listitem);
				}
				else
				{
					AddVehicleComponent(vID, 1083+listitem);
				}
				echo(playerid, cGruen, "Räder wurden angebracht.");
			}
		}
		return 1;
}

ocmd:colortest(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 6)) return echo(playerid, cRot, "Du bist kein Projektleiter");
	new hex;
	if(sscanf(params, "x", hex)) return echo(playerid, cRot, "colortest [hex]");
	echo(playerid, hex, "colortest");
	new string[128];
	format(string, sizeof(string), "%x | {%06x}test | {%06x}test", hex, (hex << 8) >>> 8, hex >>> 8);
	echo(playerid, cWeiss, string);
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new strSMS[128];
	format(strSMS, sizeof(strSMS), "SMS an %s", SpielerName(clickedplayerid));
	ShowDialog(playerid, diaSMS, DIALOG_STYLE_INPUT, strSMS, "Verfasse eine neue Nachricht:", "Absenden", "Abbrechen");
	clpl[playerid] = clickedplayerid;
	return 0;
}



public UpdateClock()
{
 		new Hour,Minute,Sec,String[256];
	   	gettime(Hour,Minute,Sec);
	   	if(Hour<9 && Minute<9){format(String,sizeof(String),"0%d:0%d",Hour,Minute);}
	   	else if(Hour>9 && Minute<9){format(String,sizeof(String),"%d:0%d",Hour,Minute);}
	   	else if(Hour<9 && Minute>9){format(String,sizeof(String),"0%d:%d",Hour,Minute);}
	   	else{format(String,sizeof(String),"%d:%d",Hour,Minute);}
	   	TextDrawSetString(u_h_r, String);
		
		if(Minute == 00 && Sec == 00)
		{
			//UHR
			new strVoll[128];
			format(strVoll, sizeof(strVoll), "Es ist %d:0%d Uhr.", Hour, Minute);
			SendClientMessageToAll(cGrau, strVoll);
			
			SetWorldTime(Hour);
			
			doLotto();
			
			weather=random(20);
			SetWeather(weather);
		}
			
			
		new strZiehung[128];
		if(Minute == 51 && Sec == 00)
		{
			//lotto
			format(strZiehung, sizeof(strZiehung), "[Lotto] In zehn Minuten startet die nächste Lottoziehung! [Jackpot: %d$] Benutzung: /lotto", BizData[2][bKasse]);
			SendClientMessageToAll(cBlau, strZiehung);
		}
		if(Minute == 56 && Sec == 00)
		{
			//lotto
			format(strZiehung, sizeof(strZiehung), "[Lotto] In fünf Minuten startet die nächste Lottoziehung! [Jackpot: %d$] Benutzung: /lotto", BizData[2][bKasse]);
			SendClientMessageToAll(cBlau, strZiehung);
		}
   		return 1;
}

ocmd:schranke(playerid, params[])
{
	if(armyschrankev == 0)
	{
		MoveDynamicObject(armyschranke1, 1447.49438, 283.49100, 7.42210,   0.00000, 0.00000, -1.30000);
		MoveDynamicObject(armyschranke2, -1464.67615, 284.16040, 7.66210,   0.00000, 0.00000, -1.30000);
		armyschrankev = 1;
		echo(playerid, cRot, "Schranke geschlossen");
		return 1;
	}
	else
	{
		MoveDynamicObject(armyschranke1, -1447.49438, 283.49100, 7.42210,   0.00000, -90.00000, -1.30000);
		MoveDynamicObject(armyschranke2, -1464.67615, 284.16040, 7.66210,   0.00000, 90.00000, -1.30000);
		armyschrankev = 0;
		echo(playerid, cRot, "Schranke geöffnet");
		return 1;
	}
}

ocmd:clock(playerid, params[])
{
	new time;
	if(sscanf(params, "i", time)) return echo(playerid, cRot, "clock []");
	SetWorldTime(time);
	return 1;
}

ocmd:neon(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return echo(playerid, cRot, "Do bisch in keinem Fahrzeug");
	if(GetPVarInt(playerid, "neon"))
	{
		DestroyDynamicObject(GetPVarInt(playerid, "neon"));
		DestroyDynamicObject(GetPVarInt(playerid, "neon1"));
		DeletePVar(playerid, "neon");
		DeletePVar(playerid, "neon1");
		echo(playerid, cGruen, "Abmontiert");
	}
	else
	{
		SetPVarInt(playerid, "neon", CreateDynamicObject(18648,0,0,0,0,0,0));
		SetPVarInt(playerid, "neon1", CreateDynamicObject(18648,0,0,0,0,0,0));
		AttachDynamicObjectToVehicle(GetPVarInt(playerid, "neon"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.57, 0.0, 0.0, 0.0);
		AttachDynamicObjectToVehicle(GetPVarInt(playerid, "neon1"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.57, 0.0, 0.0, 0.0);
		echo(playerid, cGruen, "Montiert");
	}
	return 1;
}

ocmd:resetweapons(playerid, params[])
{
	new pID, strPID[128], strPlayer[128];
	if(!isPlayerAnAdmin(playerid, 4)) return echo(playerid, cRot, "Du bist kein Admin.");
	if(sscanf(params, "u", pID)) return echo(playerid, cRot, "Benutzung: /resetweapons [Spieler]");
	ResetPlayerWeapons(pID);
	format(strPID, sizeof(strPID), "%s hat deine Waffen gelöscht", SpielerName(playerid));
	format(strPlayer, sizeof(strPlayer), "Du hast die Waffen von %s gelöscht.", SpielerName(pID));
	admcmd(pID, cRot, strPID);
	admcmd(playerid, cRot, strPlayer);
	return 1;
}

ocmd:dolotto(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 4)) return echo(playerid, cRot, "Du bist kein Admin.");
	doLotto();
	new string[128];
	format(string, sizeof(string), "[AdmCmd] %s hat die Lottoziehung ausgeführt.", SpielerName(playerid));
	Adminecho(cGelb, string);
	return 1;
}

forward ShowBank(playerid);
public ShowBank(playerid)
{
	ShowDialog(playerid, diaBank, DIALOG_STYLE_LIST, "Bank", "Test\nfolgt...", "Auswählen", "Fertig");
	return 1;
}

stock doLotto()
{
	//LOTTO
	new Winners[10], winneramount = 0, strWinner[300];
	new rand = random(49);
	rand ++;
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(PlayerInfo[i][Lotto] > 0)
		{
			if(PlayerInfo[i][Lotto] == rand)
			{
				//WIN
				Winners[winneramount] = i;
				winneramount ++;
			}
			PlayerInfo[i][Lotto] = 0;
		}
	}
	if(winneramount == 0)
	{
		format(strWinner, sizeof(strWinner), "[Lotto] Die gezogene Lottozahl lautet: %d. Es gab keinen Gewinner. [Jackpot: %d$]", rand, BizData[2][bKasse]);
		SendClientMessageToAll(cBlau, strWinner);
	}
	else if(winneramount == 1)
	{
		format(strWinner, sizeof(strWinner), "[Lotto] %s hat den Jackpot geknackt und erhält %d$! [Lottozahl :%d]", BizData[2][bKasse], rand);
		SendClientMessageToAll(cBlau, strWinner);
	}
	else
	{
		format(strWinner, sizeof(strWinner), "[Lotto] Der Jackpot wurde geknackt! (%d$) Der Gewinn wird an folgende Spieler verteilt:", BizData[2][bKasse]);
		for(new i; i < winneramount; i++)
		{
			GivePlayerMoney(Winners[i], BizData[2][bKasse]/winneramount);
			if(i == 0)
				format(strWinner, sizeof(strWinner), "%s %s", strWinner, SpielerName(Winners[i]));
			else
				format(strWinner, sizeof(strWinner), "%s ,%s", strWinner, SpielerName(Winners[i]));
		}
		SendClientMessageToAll(cBlau, strWinner);
		BizData[2][bKasse] = 0;
	}
	print(strWinner);
}

public TimeUpdate()
{
    new Day, Month, Year;
    new TimeString[256];
    getdate(Year, Month, Day);
    if(Day <= 9)
   	{
    	format(TimeString,25,"0%d.%d.%d", Day, Month, Year);
        }else{
        format(TimeString,25,"%d.%d.%d", Day, Month, Year);
	}
    TextDrawSetString(u_h_d,TimeString);
    return 1;
}

public UpdateCheat(playerid)
{
 	if(GetPlayerMoney(playerid) > SpielerInfo[playerid][pGeld])
	{
		//Geld Cheat
	}
   	return 1;
}


forward UpdateSecond(playerid);
public UpdateSecond(playerid)
{
	new strZone[50];
	format(strZone, sizeof(strZone), "%s", getzone(playerid));
	TextDrawSetString(Zonetext[playerid], strZone);
	
	SpielerInfo[playerid][pPayday] ++;
	if(SpielerInfo[playerid][pPayday] >= 1800)
	{
		PlayerPayday(playerid);
	}
	return 1;
}

stock IsPlayerInACar(playerid) //By Gabriel "Larcius" Cordes
{
	if(IsPlayerConnected(playerid) && IsPlayerInAnyVehicle(playerid))
	{
		new vtyp = GetVehicleType(GetPlayerVehicleID(playerid));
		if(vtyp==VTYPE_CAR || vtyp==VTYPE_HEAVY || vtyp==VTYPE_MONSTER)
		{
			return 1;
		}
	}
	return 0;
}

stock canHavePaintjob(vID)
{
	if(vID == 562 ||
		vID == 565 ||
		vID == 559 ||
		vID == 561 ||
		vID == 560 ||
		vID == 575 ||
		vID == 534 ||
		vID == 567 ||
		vID == 536 ||
		vID == 535 ||
		vID == 576 ||
		vID == 558)	
	{
		print("return true;");
		return true;
	}
	else return false;
}

stock canHaveExhaust(vID) //Auspuff
{
	if(vID == 562 ||
		vID == 565 ||
		vID == 559 ||
		vID == 558 ||
		vID == 561 ||
		vID == 560)	
	{
		return true;
	}
	else return false;
}

stock GetVehicleDriver(vehicleid)
{
	new i;
	for(;i!=MAX_PLAYERS;i++) if(IsPlayerConnected(i) && GetPlayerState(i) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(i) == vehicleid) return i;
	return INVALID_PLAYER_ID;
}

public UpdateTickets()
{
	new string[1024], nix;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SupportTicket[i] == 1)
		{
			nix = 1;
			if(TicketAngenommen[i] == 0)
			{
				format(string, sizeof(string), "%s~g~[Neu]%s (ID: %d)~n~",string, SpielerName(i), i);
			}
  			if(TicketAngenommen[i] == 1)
			{
				format(string, sizeof(string), "%s~b~[%s]%s (ID: %d)~n~",string, SpielerName(DeinSupport[i]), SpielerName(i), i);
			}
			if(TicketAngenommen[i] == 2) //st
			{
				format(string, sizeof(string), "%s~g~[%s]%s (ID: %d)~n~",string, DeinGrund[i], SpielerName(i), i);
			}
			if(TicketAngenommen[i] == 3) //et
			{
				format(string, sizeof(string), "%s~w~[%s]%s (ID: %d)~n~",string, DeinGrund[i], SpielerName(i), i);
			}
			if(TicketAngenommen[i] == 4) //at
			{
				format(string, sizeof(string), "%s~r~[%s]%s (ID: %d)~n~",string, DeinGrund[i], SpielerName(i), i);
			}
		}
	}
	if(nix == 1)
	{
		TextDrawSetString(Ticket, string);
	}
	else return TextDrawSetString(Ticket, "~p~Keine Tickets vorhanden.");
	return 1;
}


public CheckUnverwundbarkeit(playerid, Float:hp)
{
	new Float:hp2;
	GetPlayerHealth(playerid, hp2);
	if(hp2 > hp)
	{
		printf("%s isn Hacker", SpielerName(playerid));
	}
	else return printf("%s is kein Hacker", SpielerName(playerid));
	return 1;
}

stock copyrightSpielerLadenundso(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPVarInt(playerid,"copyrightSpieler",1);
	TextDrawShowForPlayer(playerid,td1992);
	SetTimerEx("copyrightSpielerBla",2000,false,"d",playerid);
	return 1;
}

forward copyrightSpielerBla(playerid);

public copyrightSpielerBla(playerid)
{
	TextDrawHideForPlayer(playerid,td1992);
	SetPlayerVirtualWorld(playerid, 0);
	DeletePVar(playerid,"copyrightSpieler");
	SetPVarInt(playerid, "pWillkommen", 1);
	SpawnPlayer(playerid);
}

stock ShowMOTD(playerid)
{
	new fID[8], gid[8], strMOTD[555], strFMotd[50], strGMotd[50];
	
	format(fID, sizeof(fID), "%d", SpielerInfo[playerid][pFraktion]);
	format(gid, sizeof(gid), "%d", SpielerInfo[playerid][pGruppierung]);
	
	format(strFMotd, sizeof(strFMotd), "%s", mysql_GetString("factions", "motd", "id", fID));
	format(strGMotd, sizeof(strGMotd), "%s", mysql_GetString("groupings", "motd", "id", gid));
	
	while(strfind(strFMotd, "~") != -1)
    {
		new p = strfind(strFMotd, "~"), l2 = strlen("~");
		strdel(strFMotd, p, (p+l2));
		strins(strFMotd, "\n", p);
    }
	while(strfind(strGMotd, "~") != -1)
    {
		new p = strfind(strGMotd, "~"), l2 = strlen("~");
		strdel(strGMotd, p, (p+l2));
		strins(strGMotd, "\n", p);
    }
	
	
	format(strMOTD, sizeof(strMOTD), "======= MOTD =======\n");
	if(SpielerInfo[playerid][pFraktion] > 0)
	{
		format(strMOTD, sizeof(strMOTD), "%s \n\n======= Fraktion =======\n%s", strMOTD, strFMotd);
	}
	if(SpielerInfo[playerid][pGruppierung] > 0)
	{
		format(strMOTD, sizeof(strMOTD), "%s \n\n======= Gruppierung =======\n%s", strMOTD, strGMotd);
	}
	ShowDialog(playerid, diaMOTD, DIALOG_STYLE_MSGBOX, "Message of the Day", strMOTD, "Okay", "");
}


stock getzone(playerid)
{
	new Float:X,Float:Y,Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	new str[30];
	format(str, sizeof(str), "Nicht gesichtet!");
	for(new z;z<MZM;z++)
	{
	    if(X>=mainzonenames[z][zone_minx]&&Y>=mainzonenames[z][zone_miny]&&Z>=mainzonenames[z][zone_minz]&&X<=mainzonenames[z][zone_maxx]&&Y<=mainzonenames[z][zone_maxy]&&Z<=mainzonenames[z][zone_maxz])format(str,sizeof(str),"%s",mainzonenames[z][zone_name]);
	}
	for(new z;z<MZN;z++)
	{
	    if(X>=zonenames[z][zone_minx]&&Y>=zonenames[z][zone_miny]&&Z>=zonenames[z][zone_minz]&&X<=zonenames[z][zone_maxx]&&Y<=zonenames[z][zone_maxy]&&Z<=zonenames[z][zone_maxz])format(str,sizeof(str),"%s",zonenames[z][zone_name]);
	}
	return str;
}


stock getcarname(vehid)
{
	new str[15];
	format(str, sizeof(str), "Nicht gültig!");
	for(new z;z<maxSpaner;z++)
	{
	    if(spaner[z][ahModel] == vehid)format(str,sizeof(str),"%s",spaner[z][ahName]);
	}
	return str;
}

stock suspect(playerid, pID, amount, reason[50])
{
	new strPID[128], strPD[128];
	SetWanteds(pID, SpielerInfo[pID][pWanteds]+amount);
	
	SpielerInfo[pID][pWantedReason] = reason;
	
	
	
	if(playerid == 0)
	{
		format(strPID, sizeof(strPID), ">> Dir wurden %d Verbrechen in deine Akte eingetragen. Grund: [%s]", amount, reason);
		format(strPD, sizeof(strPD), "[SFPD] Neues Verbrechen gemeldet: Akte %s Tatbestand: [%s] Anzahl: %d [SYSTEM]", SpielerName(pID), reason, amount);
	}
	else
	{
		format(strPID, sizeof(strPID), ">> Officer %s hat dir %d Verbrechen in deine Akte eingetragen. Grund: [%s]", SpielerName(playerid), amount, reason);
		format(strPD, sizeof(strPD), "[SFPD] Neues Verbrechen gemeldet: Akte %s Tatbestand: [%s] Anzahl: %d Melder: %s", SpielerName(pID), reason, amount, SpielerName(playerid));
	}
	
	echo(pID, cRot, strPID);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(SpielerInfo[i][pFraktion] == 1)
		{
			PlayerPlaySound(i,1056,0,0,0);
			echo(i, cHellblau, strPD);
		}
	}
}

stock BanPlayerEx(opfer, art, time, grund[50])
{
	new strBannYolo[16];
	format(strBannYolo, sizeof(strBannYolo), "%d", SpielerInfo[opfer][peID]);
	if(art == 1) //TIME BANN
	{
		new timestamp;
		timestamp = gettime();
		new sekunden = time * 60;
		timestamp += sekunden;
		mysql_UpdateInt("accounts", "banned", 1, "id", strBannYolo);
		mysql_UpdateInt("accounts", "ban_time", timestamp, "id", strBannYolo);
		mysql_UpdateString("accounts", "ban_reason", grund, "id", strBannYolo);
	}
	if(art == 2) //TIME IP
	{
		new timestamp;
		timestamp = gettime();
		new sekunden = time * 60;
		timestamp += sekunden;
		mysql_UpdateInt("accounts", "banned", 2, "id", strBannYolo);
		mysql_UpdateInt("accounts", "ban_time", timestamp, "id", strBannYolo);
		mysql_UpdateString("accounts", "ban_reason", grund, "id", strBannYolo);
	}
	if(art == 3) //Perma bann
	{
		mysql_UpdateInt("accounts", "banned", 3, "id", strBannYolo);
		mysql_UpdateInt("accounts", "ban_time", 0, "id", strBannYolo);
		mysql_UpdateString("accounts", "ban_reason", grund, "id", strBannYolo);
	}
	if(art == 4) //perma ip
	{
		mysql_UpdateInt("accounts", "banned", 4, "id", strBannYolo);
		mysql_UpdateInt("accounts", "ban_time", 0, "id", strBannYolo);
		mysql_UpdateString("accounts", "ban_reason", grund, "id", strBannYolo);
	}
}

ocmd:ban(playerid, params[])
{
	if(!isPlayerAnAdmin(playerid, 1)) return echo(playerid, cRot, "Du bist kein Admin.");
	echo(playerid, cRot, "Arten: [/pban - Permanent] [/tban - Timebann]");
	return 1;
}

ocmd:pban(playerid, params[])
{
	new pID, reason[50];
	if(sscanf(params, "us[50]", pID, reason)) return echo(playerid, cRot, "Benutzung: /pban [Spieler] [Grund]");
	if(!IsPlayerConnected(playerid)) return echo(playerid, cRot, "Spieler nicht gefunden!");
	BanPlayerEx(pID, 3, 0, reason);
	
	new bannstring[128];
	format(bannstring, sizeof(bannstring), "[AdmCmd] %s hat %s permanent vom Server gebannt. Grund: %s", SpielerName(playerid), SpielerName(pID), reason);
	print(bannstring);
	SendClientMessageToAll(cRot, bannstring);
	KickTimer(pID, 100);
	return 1;
}

ocmd:kick(playerid, params[])
{
	new pID, reason[50];
	if(sscanf(params, "us[50]", pID, reason)) return echo(playerid, cRot, "Benutzung: /kick [Spieler] [Grund]");
	if(!IsPlayerConnected(playerid)) return echo(playerid, cRot, "Spieler nicht gefunden!");
	if(SpielerInfo[playerid] [pAdminlevel] < SpielerInfo[pID] [pAdminlevel]) return echo(playerid,cRot,"Du kannst diesen Befehl nicht an höherrangigen Admins ausführen!");
	new bannstring[128];
	format(bannstring, sizeof(bannstring), "[AdmCmd] %s hat %s vom Server gekickt. Grund: %s", SpielerName(playerid), SpielerName(pID), reason);
	print(bannstring);
	SendClientMessageToAll(cRot, bannstring);
	KickTimer(pID, 10);
	return 1;
}


stock GetPlayerSpeed(playerid)
{
    new Float:x,Float:y,Float:z,Float:rtn;
    if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid),x,y,z); else GetPlayerVelocity(playerid,x,y,z);
    rtn = floatsqroot(x*x+y*y+z*z);
    return kmh?floatround(rtn * 50 * 3.11):floatround(rtn * 50);
    //return kmh?floatround(rtn * 50 * 1.61):floatround(rtn * 50);
}


stock LoadGlobals()
{
	new strVersion[64], strGameMode[32], strMapName[32], strHomePage[32];
	format(strVersion, sizeof(strVersion), "hostname %s", Servername());
	format(strGameMode, sizeof(strGameMode), "%s %s", GameModeName(), Version());
	format(strMapName, sizeof(strMapName), "mapname %s", Mapname());	
	format(strHomePage, sizeof(strHomePage), "weburl %s", Homepage());	
	

	
	SendRconCommand(strVersion);
	SetGameModeText(strGameMode);
	SendRconCommand(strMapName);
	SendRconCommand(strHomePage);
}

stock Version()
{
	new str[50];
	format(str, sizeof str, "%s", mysql_GetString("server", "version", "id", "1"));
	return str;
}

stock Servername()
{
	new str[50];
	format(str, sizeof str, "%s", mysql_GetString("server", "name", "id", "1"));
	return str;
}

stock GameModeName()
{
	new str[50];
	format(str, sizeof str, "%s", mysql_GetString("server", "gamemode", "id", "1"));
	return str;
}

stock Mapname()
{
	new str[50];
	format(str, sizeof str, "%s", mysql_GetString("server", "map", "id", "1"));
	return str;
}

stock Homepage()
{
	new str[50];
	format(str, sizeof str, "%s", mysql_GetString("server", "homepage", "id", "1"));
	return str;
}


stock echo(playerid, farbe, const string[])
{
	if(GetPVarInt(playerid, "Eingeloggt") == 1)
	{
		SendClientMessage(playerid, farbe, string);

	}
	/*else
	{
		SendClientMessage(playerid, cRot, ">>> Achtung! Buguse? Du wirst nun gekickt. Sollte ein Fehler vorliegen, melde es bitte dem Support! <<<");
		printf(">>> %s wurde gekickt, weil er beim Login ein Echo erhielt! <<<", SpielerName(playerid));
		KickTimer(playerid, 100);
	}*/
	return 1;
}

stock ShowDialog(playerid, diaid, diaStyle, titel[], inhalt[], ok1[], ok2[])
{
	if(GetPVarInt(playerid, "Eingeloggt") == 1)
	{
		ShowPlayerDialog(playerid, diaid, diaStyle, titel, inhalt, ok1, ok2);
	}
	else
	{
		SendClientMessage(playerid, cRot, ">>> Achtung! Buguse? Du wirst nun gekickt. Sollte ein Fehler vorliegen, melde es bitte dem Support! <<<");
		printf(">>> %s wurde gekickt, weil er beim Login einen anderen Dialog öffnete! <<<", SpielerName(playerid));
		KickTimer(playerid, 100);
	}
	return 1;
}

stock admcmd(playerid, farbe, text[128])
{
	format(text, sizeof(text), "[AdmCmd] %s", text);
	echo(playerid, farbe, text);
	format(text, sizeof(text), "");
	return 1;
}

stock EchoGruppierung (team, const string[])
{
	print(string);
	for(new i;i<MAX_PLAYERS;i++)
	{
  		if(SpielerInfo[i][pGruppierung] == team)
  		{
   			echo(i, cGruppe, string);
  		}
	}
}

stock EchoFraktion (team, const string[])
{
	print(string);
	for(new i;i<MAX_PLAYERS;i++)
	{
  		if(SpielerInfo[i][pFraktion] == team)
  		{
   			echo(i, cHellblau, string);
  		}
	}
}


stock SendClientMessageInRange(playerid,msg[],farbe,range)
{
	for(new i=0;i<GetMaxPlayers();i++)
	{
		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid,x,y,z);
		if(IsPlayerInRangeOfPoint(i,range,x,y,z))
		{
			echo(i,farbe,msg);
		}
	}
	return 1;
}

stock underdollarUD(playerid)
{
	new str[128];
	format(str,sizeof str,"~g~]%03d",SpielerInfo[playerid][pPremiumpunkte]);
	if(SpielerInfo[playerid][pAond] == 1)
	{
		format(str,sizeof str,"%s - ~p~Aond",str);
	}
	else
	{
		format(str,sizeof str,"%s - %s",str, Homepage());
	}
	TextDrawSetString(underdollar[playerid],str);
	TextDrawShowForPlayer(playerid,underdollar[playerid]);
	//if(GetPVarInt(playerid, "pPremium")>99&&!checkErr(playerid,er100pp))addErrEx(playerid,er100pp);
	return 1;
}

stock frakname(teamid)
{
	new tstr[128];
	if(teamid != 0)
	{
		new query[128];
		format(query, sizeof query, "%i", teamid);
		format(tstr, sizeof tstr, "%s", mysql_GetString("factions", "name", "id", query));
	}
	else
	{
		tstr = "-";
	}
	return tstr;
}


stock Gruppierungname(teamid)
{
	new tstr[128];
	if(teamid != 0)
	{
		new query[128];
		format(query, sizeof query, "%i", teamid);
		format(tstr, sizeof tstr, "%s", mysql_GetString("groupings", "name", "id", query));
	}
	else
	{
		tstr = "-";
	}
	return tstr;
}

stock GRangName(teamid, rang)
{
	new tstr[128],
		query[128];
	format(query, sizeof query, "SELECT `name` FROM `grouping_rank_names` WHERE `grouping` = %d AND `rank` = %d", teamid, rang);
	mysql_query(query);
	mysql_store_result();
	mysql_fetch_row(tstr);
	mysql_free_result();
	return tstr;
}

stock FRangName(teamid, rang)
{
	new tstr[128],
		query[128];
	format(query, sizeof query, "SELECT `name` FROM `faction_rank_names` WHERE `faction` = %d AND `rank` = %d", teamid, rang);
	mysql_query(query);
	mysql_store_result();
	mysql_fetch_row(tstr);
	mysql_free_result();
	return tstr;
}

stock fraktionspawn(playerid, team)
{
	if(!team)
	{
		SpawnPlayerZivi(playerid);
		return 1;
	}
	new string[4];
	valstr(string, team);
	
	SetPlayerPos(playerid, mysql_GetFloat("factions", "spawn_x", "id", string) ,mysql_GetFloat("factions", "spawn_y", "id", string) ,mysql_GetFloat("factions", "spawn_z", "id", string));
	SetPlayerInterior(playerid, mysql_GetInt("factions", "spawn_int", "id", string));
	SetPlayerVirtualWorld(playerid, mysql_GetInt("factions", "spawn_world", "id", string));
	SetCameraBehindPlayer(playerid);
	return 1;
}

stock Gruppierungspawn(playerid, team)
{
	if(team == 0)
	{
		SpawnPlayerZivi(playerid);
		return 1;
	}
	new string[4];
	valstr(string,team);
	SetPlayerPos(playerid, mysql_GetFloat("groupings", "spawn_x", "id", string) ,mysql_GetFloat("groupings", "spawn_y", "id", string) ,mysql_GetFloat("groupings", "spawn_z", "id", string));
	SetPlayerInterior(playerid, mysql_GetInt("groupings", "spawn_int", "id", string));
	SetPlayerVirtualWorld(playerid, mysql_GetInt("groupings", "spawn_world", "id", string));
	SetCameraBehindPlayer(playerid);
	return 1;
}

stock SpawnPlayerZivi(playerid)
{
	SetPlayerPos(playerid, -1951.6475,641.0552,46.5625);
	SetPlayerFacingAngle(playerid, 359.7485);
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid,0); 
	SetPlayerVirtualWorld(playerid, 0);
}

stock IsVehicleEmpty(vehicleid)
{
    for(new i =0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(IsPlayerInVehicle(i,vehicleid)) return 0;
    }
    return 1;
}

stock SaveAllStuff()
{
	SaveBizzes();
	for(new i=0; i<MAX_PLAYERS; i++)
	{
	    if(GetPVarInt(i, "Eingeloggt") == 1)
	    {
	   		SavePlayer(i);
			DeSpawnPlayerVehicles(i, 0);
			SaveWeapon(i);
		}
	}
}




stock IsPlayerDriver(playerid)
{
	if(IsPlayerConnected(playerid) && GetPlayerState(playerid)==PLAYER_STATE_DRIVER)
	{
		return 1;
	}
	return 0;
}

stock Adminecho(color,const string[])
{
	print(string);
	for(new i;i<MAX_PLAYERS;i++)
	{
  		if(isPlayerAnAdmin(i, 1))
  		{
   			echo(i, color, string);
  		}
	}
	return 1;
}


stock IsAFly(vehicleid)
{
    if(vehicleid==417||vehicleid==425||vehicleid==447||vehicleid==460||vehicleid==469||vehicleid==476||vehicleid==487||vehicleid==488||vehicleid==497||vehicleid==511||vehicleid==512||vehicleid==513||vehicleid==519||vehicleid==520||vehicleid==548||vehicleid==553||vehicleid==563||vehicleid==577||vehicleid==592||vehicleid==593)return 1;
    return 0;
}

stock IsACar(vehicleid)
{
	if(vehicleid==400||vehicleid==401||vehicleid==402||vehicleid==404||vehicleid==405||vehicleid==409||vehicleid==410||vehicleid==411||vehicleid==412||vehicleid==413||vehicleid==414||vehicleid==415||vehicleid==416||vehicleid==418||vehicleid==419||vehicleid==420||vehicleid==421||vehicleid==422||vehicleid==423)return 1;
    if(vehicleid==424||vehicleid==426||vehicleid==427||vehicleid==428||vehicleid==429||vehicleid==431||vehicleid==432||vehicleid==434||vehicleid==436||vehicleid==437||vehicleid==438||vehicleid==439||vehicleid==440||vehicleid==441||vehicleid==442||vehicleid==444||vehicleid==445||vehicleid==451||vehicleid==457)return 1;
    if(vehicleid==458||vehicleid==459||vehicleid==466||vehicleid==467||vehicleid==470||vehicleid==474||vehicleid==475||vehicleid==477||vehicleid==478||vehicleid==479||vehicleid==480||vehicleid==482||vehicleid==483||vehicleid==489||vehicleid==490||vehicleid==491||vehicleid==492||vehicleid==494||vehicleid==495||vehicleid==496||vehicleid==498||vehicleid==499||vehicleid==500)return 1;
    if(vehicleid==502||vehicleid==503||vehicleid==504||vehicleid==505||vehicleid==506||vehicleid==507||vehicleid==508||vehicleid==516||vehicleid==517||vehicleid==518||vehicleid==525||vehicleid==526||vehicleid==527||vehicleid==528||vehicleid==529||vehicleid==530||vehicleid==531||vehicleid==532||vehicleid==533||vehicleid==534||vehicleid==535||vehicleid==536||vehicleid==537)return 1;
    if(vehicleid==589||vehicleid==596||vehicleid==597||vehicleid==598||vehicleid==599||vehicleid==600||vehicleid==601||vehicleid==602||vehicleid==603||vehicleid==604||vehicleid==605||vehicleid==609)return 1;
    if(vehicleid==538||vehicleid==539||vehicleid==540||vehicleid==541||vehicleid==542||vehicleid==543||vehicleid==545||vehicleid==547||vehicleid==549||vehicleid==550||vehicleid==551||vehicleid==552||vehicleid==554||vehicleid==555||vehicleid==556||vehicleid==557||vehicleid==558||vehicleid==559||vehicleid==560)return 1;
    if(vehicleid==561||vehicleid==562||vehicleid==565||vehicleid==566||vehicleid==567||vehicleid==568||vehicleid==569||vehicleid==570||vehicleid==571||vehicleid==572||vehicleid==575||vehicleid==576||vehicleid==579||vehicleid==580||vehicleid==582||vehicleid==583||vehicleid==585||vehicleid==587||vehicleid==588)return 1;
    return 0;
}

stock IsALKW(vehicleid)
{
	if(vehicleid==403||vehicleid==406||vehicleid==407||vehicleid==408||vehicleid==433||vehicleid==443||vehicleid==455||vehicleid==456||vehicleid==514||vehicleid==515||vehicleid==544||vehicleid==573||vehicleid==578)return 1;
    return 0;
}

stock IsABike(vehicleid)
{
	if(vehicleid==463||vehicleid==468||vehicleid==471||vehicleid==421||vehicleid==422||vehicleid==423||vehicleid==481||vehicleid==586)return 1;
 	return 0;
}

stock Willkommen(playerid)
{
	spieleronline ++;
	
	for(new i; i != 15; i++)
	{
		echo(playerid, cWeiss, "");
	}
	
	new string[128];
	format(string, sizeof(string), "Hallo, "ciOrange"%s. {ffffff}Willkommen auf "ciOrange"%s{ffffff}.", SpielerName(playerid), Servername());
	echo(playerid, cWeiss, string);
	
	SetWanteds(playerid, SpielerInfo[playerid][pWanteds]);
	SpawnPlayerVehicles(playerid);
	SetPlayerColor(playerid,0xFFFFFF00);
	
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, SpielerInfo[playerid][pGeld]);
	underdollarUD(playerid);
	
	WerbungOnPlayerConnect(playerid);
	
	if(spieleronline > spielerrekord)
	{
		new strRekord[128];
		format(strRekord, sizeof(strRekord), "--> Neuer Rekord: %d Spieler online! <--", spieleronline);
		SendClientMessageToAll(cGelb, strRekord);
		print(strRekord);
		mysql_UpdateInt("server", "record", spieleronline, "id", "1");
		spielerrekord = spieleronline;
	}
	
	if(isPlayerAnAdmin(playerid, 1))
	{
		PlayerInfo[playerid][pTicketson] = 1;
		TextDrawShowForPlayer(playerid, Hintergrund);
		TextDrawShowForPlayer(playerid, Ueberschrift);
		TextDrawShowForPlayer(playerid, Verdichtung);
		TextDrawShowForPlayer(playerid, Ticket);
		TextDrawShowForPlayer(playerid, Strich);
	}
	SetPlayerScore(playerid, SpielerInfo[playerid][pLevel]);
	PlayerInfo[playerid][WhereGArray] = -1;
	GangfightWillkommen(playerid);
	LoadWeapon(playerid);
	ShowMOTD(playerid);
	
	SecondTimer[playerid] = SetTimerEx("UpdateSecond", 1000, 1, "i", playerid);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	GangfightOnEnterDynamicArea(playerid, areaid);
	return 1;
}

stock ShowInfobar(playerid, name[])
{
	TextDrawSetString(InfobarText[playerid], name);
	TextDrawShowForPlayer(playerid, InfobarBox);
	TextDrawShowForPlayer(playerid, InfobarText[playerid]);
	return 1;
}

stock HideInfobar(playerid)
{
	TextDrawHideForPlayer(playerid, InfobarBox);
	TextDrawHideForPlayer(playerid, InfobarText[playerid]);
	return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	GangfightOnLeaveDynamicArea(playerid);
	return 1;
}

ocmd:lotto(playerid, params[])
{
	new strGeld[128], zahl, strNummer[128];
	format(strGeld, sizeof(strGeld), "Benutzung: /lotto [Zahl 1-50] (%d$)", BizData[1][bProdPreis]);
	if(BizData[2][bOpen] == 0) return echo(playerid, cBlau, "Das Biz ist verschlossen. Es kann daher kein Lotto gespielt werden.");
	if(sscanf(params, "d", zahl)) return echo(playerid, cBlau, strGeld);
	if(zahl < 1 || zahl > 50) return echo(playerid, cBlau, strGeld);
	if(BizData[2][bProdPreis] > SpielerInfo[playerid][pGeld]) return echo(playerid, cBlau, "Du hast nicht genug Geld.");
	if(BizData[2][bProds] < 1) return echo(playerid, cBlau, "Es sind keine Materialien mehr vorhanden.");
	
	format(strNummer, sizeof(strNummer), "Du hast dir einen Lottoschein mit der Nummer [%d] gekauft.", zahl);
	echo(playerid, cGruen, strNummer);
	PlayerInfo[playerid][Lotto] = zahl;
	BizData[2][bProds] --;
	AGivePlayerMoney(playerid, -BizData[2][bProdPreis]);
	BizData[2][bKasse] += BizData[1][bProdPreis];
	UpdateBiz(2);
	return 1;
}

stock isPlayerInGang(playerid)
{
	if(SpielerInfo[playerid][pGruppierung] < 3)
	{
		return false;
	}
	else return true;
}

stock echoGangfight(text[])
{
	new areaid;
	for(new i; i < MAX_GANGZONES; i++)
	{
		if(GangzoneData[i][gGangwarStarted] > 0)
		{
			areaid = i;
			break;
		}
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(SpielerInfo[i][pGruppierung] == GangzoneData[areaid][gGangwarStarted] || SpielerInfo[i][pGruppierung] == GangzoneData[areaid][gOwnerID])
			{
				echo(i, cRot, text);
			}
		}
	}
}

stock SetWanteds(playerid, wanted)
{
	SpielerInfo[playerid][pWanteds] = wanted;
	new eidi[24];
	valstr(eidi, SpielerInfo[playerid][peID]);
	mysql_UpdateInt("accounts", "wanteds", SpielerInfo[playerid][pWanteds], "id", eidi);
	if(SpielerInfo[playerid][pWanteds] > 0)
	{
		//Textdraw anzeigen
		if(SpielerInfo[playerid][pWanteds] == 1) return TextDrawSetString(xwanted[playerid],"~w~]");
		if(SpielerInfo[playerid][pWanteds] == 2) return TextDrawSetString(xwanted[playerid],"~w~]]");
		if(SpielerInfo[playerid][pWanteds] == 3) return TextDrawSetString(xwanted[playerid],"~w~]]]");
		if(SpielerInfo[playerid][pWanteds] == 4) return TextDrawSetString(xwanted[playerid],"~w~]]]]");
		if(SpielerInfo[playerid][pWanteds] == 5) return TextDrawSetString(xwanted[playerid],"~w~]]]]]");
		if(SpielerInfo[playerid][pWanteds] == 6) return TextDrawSetString(xwanted[playerid],"~w~]]]]]]");
		if(SpielerInfo[playerid][pWanteds] == 7) return TextDrawSetString(xwanted[playerid],"~w~]]]]]]]");
		if(SpielerInfo[playerid][pWanteds] == 8) return TextDrawSetString(xwanted[playerid],"~w~]]]]]]]]");
		if(SpielerInfo[playerid][pWanteds] >= 9) return TextDrawSetString(xwanted[playerid],"~r~]]]]]]]]");
	}
	else return TextDrawSetString(xwanted[playerid]," ");
	return 1;
}

stock SetSkin(playerid, skinid)
{
	SetPlayerSkin(playerid, skinid);
	SpielerInfo[playerid][pSkin] = skinid;
	new eidi[24];
	valstr(eidi, SpielerInfo[playerid][peID]);
	mysql_UpdateInt("accounts", "skin", SpielerInfo[playerid][pSkin], "id", eidi);
}

stock isPlayerAnAdmin(playerid,rang)
{
	if(SpielerInfo[playerid][pAdminlevel] >= rang)return 1;
	return 0;
}

stock isPlayerAnAdminAnd(playerid,rang)
{
	if(SpielerInfo[playerid][pAdminlevel] == rang)return 1;
	return 0;
}

stock adminname(adminname)
{
	new tstr[64];
	switch(adminname)
	{
	    case 0: tstr = "{ffffff}User";
	    case 1: tstr = "{99ff99}Supporter";
		case 2: tstr = "{F5FF00}Moderator";
		case 3: tstr = "{9999ff}Super Moderator";
		case 4: tstr = "{0073FF}Admin";
       	case 5: tstr = "{e13333}Fulladmin";
       	case 6: tstr = "{005FFF}Projektleiter";
	}
	return tstr;
}

stock ShowAHelp(playerid)
{
	new strListe1[128], strListe2[128], strListe3[128], strListe4[128], strListe5[256], strListe6[128], strAll[1024];
	format(strListe1, sizeof(strListe1), "/aond [1] \n/sultan [1]\n/a [1] \n/vehrem [1] \n/goto [1] \n/togsup [1] \n/ot [1] \n/rt [1] \n/ct [1] \n/do [1] \n/et [1] \n/at [1] \n/st [1] \n/slap [1]\n/freeze [1]\n/unfreeze [1]\n/spec [1]\n/specoff [1]");
	format(strListe2, sizeof(strListe2), "\n/gethere [2] \n");
	format(strListe3, sizeof(strListe3), "");
	format(strListe4, sizeof(strListe4), "/veh [4]\n/respawn[4] \n/setskin [4] \n/arepair [4] \n/sethp [4] \n/vehremall [4] \n");
	format(strListe5, sizeof(strListe5), "/gotopos [5] \n/getpos [5] \n/agivegun [5] \n/setgruppierung [5] \n/setfraktion [5] \n/playsound [5] \n/asettings [5] \n/createhouse [5] \n/deletehouse [5] \n/setint [5] /setpreis [5] \n\n/gmx [5] (NUR AUF ANWEISUNG) \n");
	format(strListe6, sizeof(strListe6), "/setadmin [6]");
	
	format(strAll, sizeof(strAll), "/getints [0]\n{99ff99}%s{F5FF00}%s{9999ff}%s{0073FF}%s{e13333}%s{005FFF}%s", strListe1, strListe2, strListe3, strListe4, strListe5, strListe6);
	
	ShowDialog(playerid, diaAHelp, DIALOG_STYLE_LIST, "Adminbefehle [Rang]", strAll, "Okay", "");
}

public OnQueryError(errorid, error[], resultid, extraid, callback[], query[], connectionHandle)
{
	print("MySQL Query Error...");
	printf("[%i] %s", errorid, error);
	printf("Query: %s", query);
	return 1;
}

stock IsVehicleConnected(vehicleid) //By Sacky (edited by Gabriel "Larcius" Cordes)
{
	new Float:x1,Float:y1,Float:z1;
	GetVehiclePos(vehicleid,x1,y1,z1);
	if(x1==0.0 && y1==0.0 && z1==0.0)
	{
		return 0;
	}
	return 1;
}

stock GetVehicleType(vehicleid) //By YellowBlood (edited by Gabriel "Larcius" Cordes)
{
	new type=0;
	if(IsVehicleConnected(vehicleid))
	{
		switch(GetVehicleModel(vehicleid))
		{
	// ================== CARS =======
		case
			416,   //ambulan  -  car
			445,   //admiral  -  car
			602,   //alpha  -  car
			485,   //baggage  -  car
			568,   //bandito  -  car
			429,   //banshee  -  car
			499,   //benson  -  car
			424,   //bfinject,   //car
			536,   //blade  -  car
			496,   //blistac  -  car
			504,   //bloodra  -  car
			422,   //bobcat  -  car
			609,   //boxburg  -  car
			498,   //boxville,   //car
			401,   //bravura  -  car
			575,   //broadway,   //car
			518,   //buccanee,   //car
			402,   //buffalo  -  car
			541,   //bullet  -  car
			482,   //burrito  -  car
			431,   //bus  -  car
			438,   //cabbie  -  car
			457,   //caddy  -  car
			527,   //cadrona  -  car
			483,   //camper  -  car
			524,   //cement  -  car
			415,   //cheetah  -  car
			542,   //clover  -  car
			589,   //club  -  car
			480,   //comet  -  car
			596,   //copcarla,   //car
			599,   //copcarru,   //car
			597,   //copcarsf,   //car
			598,   //copcarvg,   //car
			578,   //dft30  -  car
			486,   //dozer  -  car
			507,   //elegant  -  car
			562,   //elegy  -  car
			585,   //emperor  -  car
			427,   //enforcer,   //car
			419,   //esperant,   //car
			587,   //euros  -  car
			490,   //fbiranch,   //car
			528,   //fbitruck,   //car
			533,   //feltzer  -  car
			544,   //firela  -  car
			407,   //firetruk,   //car
			565,   //flash  -  car
			455,   //flatbed  -  car
			530,   //forklift,   //car
			526,   //fortune  -  car
			466,   //glendale,   //car
			604,   //glenshit,   //car
			492,   //greenwoo,   //car
			474,   //hermes  -  car
			434,   //hotknife,   //car
			502,   //hotrina  -  car
			503,   //hotrinb  -  car
			494,   //hotring  -  car
			579,   //huntley  -  car
			545,   //hustler  -  car
			411,   //infernus,   //car
			546,   //intruder,   //car
			559,   //jester  -  car
			508,   //journey  -  car
			571,   //kart  -  car
			400,   //landstal,   //car
			403,   //linerun  -  car
			517,   //majestic,   //car
			410,   //manana  -  car
			551,   //merit  -  car
			500,   //mesa  -  car
			418,   //moonbeam,   //car
			572,   //mower  -  car
			423,   //mrwhoop  -  car
			516,   //nebula  -  car
			582,   //newsvan  -  car
			467,   //oceanic  -  car
			404,   //peren  -  car
			514,   //petro  -  car
			603,   //phoenix  -  car
			600,   //picador  -  car
			413,   //pony  -  car
			426,   //premier  -  car
			436,   //previon  -  car
			547,   //primo  -  car
			489,   //rancher  -  car
			441,   //rcbandit,   //car
			594,   //rccam  -  car
			564,   //rctiger  -  car
			515,   //rdtrain  -  car
			479,   //regina  -  car
			534,   //remingtn,   //car
			505,   //rnchlure,   //car
			442,   //romero  -  car
			440,   //rumpo  -  car
			475,   //sabre  -  car
			543,   //sadler  -  car
			605,   //sadlshit,   //car
			495,   //sandking,   //car
			567,   //savanna  -  car
			428,   //securica,   //car
			405,   //sentinel,   //car
			535,   //slamvan  -  car
			458,   //solair  -  car
			580,   //stafford,   //car
			439,   //stallion,   //car
			561,   //stratum  -  car
			409,   //stretch  -  car
			560,   //sultan  -  car
			550,   //sunrise  -  car
			506,   //supergt  -  car
			601,   //swatvan  -  car
			574,   //sweeper  -  car
			566,   //tahoma  -  car
			549,   //tampa  -  car
			420,   //taxi  -  car
			459,   //topfun  -  car
			576,   //tornado  -  car
			583,   //tug  -  car
			451,   //turismo  -  car
			558,   //uranus  -  car
			552,   //utility  -  car
			540,   //vincent  -  car
			491,   //virgo  -  car
			412,   //voodoo  -  car
			478,   //walton  -  car
			421,   //washing  -  car
			529,   //willard  -  car
			555,   //windsor  -  car
			456,   //yankee  -  car
			554,   //yosemite -  car
			477   //zr350  -  car
			: type = VTYPE_CAR;

		// ================== BIKES =======
			case
			581,   //bf400  -  bike
			523,   //copbike  -  bike
			462,   //faggio  -  bike
			521,   //fcr900  -  bike
			463,   //freeway  -  bike
			522,   //nrg500  -  bike
			461,   //pcj600  -  bike
			448,   //pizzaboy,   //bike
			468,   //sanchez  -  bike
			586   //wayfarer,   //bike
			: type = VTYPE_BIKE;

		// =================== BMX =======
			case
			509,   //bike  -  bmx
			481,   //bmx  -  bmx
			510   //mtbike  -  bmx
			: type = VTYPE_BMX;

		// ================== QUADS =======
			case
			471   //quad  -  quad
			: type = VTYPE_QUAD;

		// ================== SEA =======
			case
			472,   //coastg  -  boat
			473,   //dinghy  -  boat
			493,   //jetmax  -  boat
			595,   //launch  -  boat
			484,   //marquis  -  boat
			430,   //predator,   //boat
			453,   //reefer  -  boat
			452,   //speeder  -  boat
			446,   //squalo  -  boat
			454   //tropic  -  boat
			: type = VTYPE_SEA;

		// ================= HELI =======
			case
			548,   //cargobob,   //heli
			425,   //hunter  -  heli
			417,   //leviathn,   //heli
			487,   //maverick,   //heli
			497,   //polmav  -  heli
			563,   //raindanc,   //heli
			501,   //rcgoblin,   //heli
			465,   //rcraider,   //heli
			447,   //seaspar  -  heli
			469,   //sparrow  -  heli
			488   //vcnmav  -  heli
			: type = VTYPE_HELI;

		// ================ PLANE =======
			case
			592,   //androm  -  plane
			577,   //at	400  -  plane
			511,   //beagle  -  plane
			512,   //cropdust,   //plane
			593,   //dodo  -  plane
			520,   //hydra  -  plane
			553,   //nevada  -  plane
			464,   //rcbaron  -  plane
			476,   //rustler  -  plane
			519,   //shamal  -  plane
			460,   //skimmer  -  plane
			513,   //stunt  -  plane
			539   //vortex  -  plane
			: type = VTYPE_PLANE;

		// ================== HEAVY =======
			case
			588,   //hotdog  -  car
			437,   //coach  -  car
			532,   //combine  -  car
			433,   //barracks,   //car
			414,   //mule  -  car
			443,   //packer  -  car
			470,   //patriot  -  car
			432,   //rhino  -  car
			525,   //towtruck,   //car
			531,   //tractor  -  car
			408   //trash  -  car
			: type = VTYPE_HEAVY;

		// ================ MONSTER =======
			case
			406,   //dumper  -  mtruck
			573,   //duneride,   //mtruck
			444,   //monster  -  mtruck
			556,   //monstera,   //mtruck
			557   //monsterb,   //mtruck
			: type = VTYPE_MONSTER;

		// ================ TRAILER =======
			case
			435,   //artict1  -  trailer
			450,   //artict2  -  trailer
			591,   //artict3  -  trailer
			606,   //bagboxa  -  trailer
			607,   //bagboxb  -  trailer
			610,   //farmtr1  -  trailer
			584,   //petrotr  -  trailer
			608,   //tugstair -  trailer
			611   //utiltr1  -  trailer
			: type = VTYPE_TRAILER;

		// ================== TRAIN =======
			case
			590,   //freibox  -  train
			569,   //freiflat,   //train
			537,   //freight  -  train
			538,   //streak  -  train
			570,   //streakc  -  train
			449   //tram  -  train
			: type = VTYPE_TRAIN;
		}
	}
	return type;
}

AntiDeAMX()
{
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}
