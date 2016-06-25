new Text:Werbungsbox;
new Text:Werbungstext;

new adclosed = 0;
new werbungdone = 0;
new Werbungtimer;

ocmd:ad(playerid, params[])
{
	new text[100], string[200], strPlayer[128], strGeld[128];
	format(strGeld, sizeof(strGeld), "Benutzung: /ad [Text] (Umlaute werden nicht angezeigt) [%d$]", BizData[1][bProdPreis]);
	if(adclosed == 1) return echo(playerid, cBlau, "Die Werbung wurde von einem Administrator deaktiviert.");
	if(BizData[1][bOpen] == 0) return echo(playerid, cBlau, "Das Biz ist verschlossen. Es kann daher keine Werbung verfasst werden.");
	if(sscanf(params, "s[100]", text)) return echo(playerid, cBlau, strGeld);
	if(werbungdone == 1) return echo(playerid, cBlau, "Es wurde erst vor kurzem eine Werbung verfasst. Bitte warte eine Minute.");
	if(strfind(text,"~",true) != -1) return echo(playerid, cBlau, "Das Zeichen ''~'' ist nicht erlaubt.");
	if(BizData[1][bProdPreis] > SpielerInfo[playerid][pGeld]) return echo(playerid, cBlau, "Du hast nicht genug Geld.");
	if(BizData[1][bProds] < 1) return echo(playerid, cBlau, "Es sind keine Materialien mehr vorhanden.");

	werbungdone = 1;
	BizData[1][bProds] --;
	AGivePlayerMoney(playerid, -BizData[1][bProdPreis]);
	BizData[1][bKasse] += BizData[1][bProdPreis];
	PlayerPlaySound(playerid,1057,0,0,0);
	format(string, sizeof(string), "~b~Werbung: ~g~%s ~r~Kontakt: %s (%d)", text, SpielerName(playerid), 1337);
	TextDrawSetString(Werbungstext, string);
	format(strPlayer, sizeof(strPlayer), "Du hast eine Werbung mit folgendem Inhalt erstellt: %s [Preis: %d$]", text, BizData[1][bProdPreis]);
	echo(playerid, cGruen, strPlayer);
	UpdateBiz(1);
	printf("[Werbung] %s hat erstellt: %s", SpielerName(playerid), text);
	Werbungtimer = SetTimer("Werbungok", 60000, false);
	return 1;
}

stock WerbungOnGameModeInit()
{
	Werbungsbox = TextDrawCreate(907.666625, 438.714813, "usebox");
	TextDrawLetterSize(Werbungsbox, 0.000000, 0.835599);
	TextDrawTextSize(Werbungsbox, -2.000000, 0.000000);
	TextDrawAlignment(Werbungsbox, 1);
	TextDrawColor(Werbungsbox, 0);
	TextDrawUseBox(Werbungsbox, true);
	TextDrawBoxColor(Werbungsbox, 102);
	TextDrawSetShadow(Werbungsbox, 0);
	TextDrawSetOutline(Werbungsbox, 0);
	TextDrawFont(Werbungsbox, 0);

	Werbungstext = TextDrawCreate(315.666534, 437.629638, "~b~Werbung: ~g~Hier koennte Ihre Werbung stehen! ~r~Kontakt: /ad (-)");
	TextDrawLetterSize(Werbungstext, 0.228333, 0.990222);
	TextDrawAlignment(Werbungstext, 2);
	TextDrawColor(Werbungstext, -1);
	TextDrawSetShadow(Werbungstext, 0);
	TextDrawSetOutline(Werbungstext, 1);
	TextDrawBackgroundColor(Werbungstext, 51);
	TextDrawFont(Werbungstext, 1);
	TextDrawSetProportional(Werbungstext, 1);
}

stock WerbungOnPlayerConnect(playerid)
{
	TextDrawShowForPlayer(playerid, Werbungsbox);
	TextDrawShowForPlayer(playerid, Werbungstext);
}

forward Werbungok();

public Werbungok()
{
	werbungdone = 0;
	KillTimer(Werbungtimer);
	return 1;
}