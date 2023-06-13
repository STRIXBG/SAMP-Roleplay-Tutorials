#include <a_samp>
#include <izcmd>
#include <a_mysql>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <easyDialog>
#include <lookup>
#include <YSI\y_hooks>
#include <playerzone>

//COLORS
#define COLOR_LIGHTGREEN 0x3FE83FFF
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_GRAY 0xF2F1EBFF
#define COLOR_RED 0xE50000FF
#define COLOR_ORANGERED 0xF15800FF
#define COLOR_GOLD 0xF1F100FF
#define COLOR_ERROR1 0x788285FF
#define COLOR_ADMIN 0xEDDF2FFF
#define COLOR_YELLOW 0xFBFF00FF
#define COLOR_ORANGE 0xFFA900FF
#define COLOR_EMOTE 0xC2A2DAAA

//INTERIORS
#define HALL_INTERIOR 3
#define HALL_VIRTUAL_WORLD 1

//GENDERS
#define GENDER_NONE 0
#define GENDER_MALE 1
#define GENDER_FEMALE 2

//MAX DEFINES
#define MAX_FACTIONS 2

//HOST, SERVER
#define LOCAL_HOST 0
#define SERVER_HOST 1
#define HOST LOCAL_HOST

#define SERVER_LOGS_ON true
#define COMMAND_LOG     "/NRP/Command Logs/%s.txt"
#define ADMIN_LOG       "/NRP/Admin Logs/%s.txt"
#define CHAT_LOG		"/NRP/Chat Logs/%s.txt"
#define CASH_LOG		"/NRP/Cash Logs/%s.txt"

#define SERVER_NAME "[BG] New Reality Roleplay"
#define SERVER_GAMEMODE "NRP"
#define SERVER_VERSION "1.0"
#define SERVER_SCRIPTER "sTrIx"
#define SERVER_SITE "OFFICIAL SITE: SOON"

#if HOST == SERVER_HOST
	#define SQL_HOST "127.0.0.1"
	#define SQL_USER "root"
	#define SQL_PASS ""
	#define SQL_DB "new_reality_rp"
#endif

#if HOST == LOCAL_HOST
	#define SQL_HOST "127.0.0.1"
	#define SQL_USER "root"
	#define SQL_PASS ""
	#define SQL_DB "new_reality_rp"
#endif

//SQL VARIABLES
new SQL_CONNECTION;

//Variables

//FACTION VARIABLES
enum faction
{
    Name[64],
    Rank1[32],
    Rank2[32],
    Rank3[32],
    Rank4[32],
    Rank5[32],
    Rank6[32],
    Rank7[32],
    Rank8[32],
    Rank9[32],
    Rank10[32]
};

new FactionInfo[MAX_FACTIONS][faction] = {
    {
        "Civilian", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A"
    },
    {
        "Red County Police Department", "Полицай в обучение", "Техник по скоростта", "Специалист по животните", "Криминалист", "Разследващ инспектор", "Дознавателен инспектор", "Старши инспектор", "Инспектор по селата", "Заместник шериф", "Шериф"
    }
};

//PLAYER VARIABLES
enum pInfo
{
	SQLID,
	RegisterIP,
	Admin,
	Faction,
	FactionRank,
	Name[32],
	Cash,
	Bank,
	Float: Health,
	Float: Armour,
	Skin,
	Level,
	Float: X,
	Float: Y,
	Float: Z,
	Float: Angle,
	Gender,
	Age,
	Interior,
	VirtualWorld
}
new PlayerInfo[MAX_PLAYERS][pInfo];

enum ptInfo
{
	bool: loggedIn,
	LoginAttempt,
	TempGender,
	UsingLoopingAnim,
	UsingATM
}
new PlayerTemp[MAX_PLAYERS][ptInfo];

new Weapon[MAX_PLAYERS][13];
new WeaponAmmo[MAX_PLAYERS][13];

native WP_Hash(buffer[], len, const str[]);

//TEXTDRAWS
new Text: PublicTD[2];
new Text: txtAnimHelper;
new PlayerText: MessageInfo;
new PlayerText: PlayerLocation;
new PlayerText: VehMeter;

//PICKUPS AND 3D TEXTS
new cityHall;

//VEHICLE VARIABLES
new engineON[MAX_VEHICLES] = {false};
new vehFuel[MAX_VEHICLES] = {100};

//OBJECT VARIABLES
new AtmObjectID[17];
new AtmPickupID[18];

//SERVER VARIABLES
new ClockHours, ClockMinutes, ClockSeconds;
new bool: OOCStatus = false;
new Float:ClassSelectionData[13][12] =
{
	{1439.0410, -221.8372, 22.7985, 1440.0046, -221.5518, 22.6933, 1636.5062, -66.9961, 70.3919, 1635.6693, -66.4367, 70.2167},
	{180.9195, 1138.8217, 27.7668, 181.3019, 1139.7499, 27.6417, -270.1440, 1205.6362, 46.1036, -271.0848, 1205.2869, 45.9885},
	{-174.8245, 341.1865, 16.5733, -174.5815, 342.1605, 16.4633, -210.2901, -118.1688, 46.9579, -209.3116, -117.9448, 46.6678},
	{182.8430, -404.5717, 14.6186, 183.8444, -404.6406, 14.5386, 427.5617, -154.8631, 41.8298, 426.5782, -154.6632, 41.4898},
	{1004.3258, -376.9207, 94.2813, 1005.0281, -376.2045, 93.9662, 1312.7808, 79.5683, 59.5385, 1312.6805, 80.5663, 59.2334},
	{1317.0122, 477.7603, 29.6383, 1317.8527, 477.2135, 29.6082, 1454.9969, 225.1299, 50.8671, 1453.9943, 225.1293, 50.6120},
	{1833.4757, -130.9368, 50.2288, 1834.3181, -130.3933, 50.0187, 2347.2859, 224.9401, 63.6775, 2347.0322, 223.9702, 63.2974},
	{2248.0591, 453.6871, 21.3100, 2247.5483, 452.8203, 21.3448, 2076.9285, -166.3638, 29.7962, 2077.4338, -165.4950, 29.5760},
	{932.2772, -574.8990, 116.6781, 932.6947, -573.9850, 116.3879, 597.8068, -477.2111, 42.7448, 598.6305, -477.7866, 42.3495},
	{-69.3941, 302.7461, 13.7824, -70.2654, 302.2455, 13.7571, -477.1172, -199.8384, 95.6078, -477.7337, -199.0445, 95.3326},
	{-1486.9976, 755.0239, 62.4289, -1486.0818, 755.4375, 62.3287, -319.6878, 1481.4557, 107.3692, -319.9124, 1480.4750, 107.0441},
	{416.0463, 2537.4595, 19.3093, 415.3760, 2536.7065, 19.2141, 82.3415, 2306.4563, 50.6167, 81.5734, 2307.1150, 50.5914},
	{-2048.1794, -2572.1389, 38.6077, -2048.5913, -2571.2131, 38.5520, -2250.4536, -1491.6262, 690.8711, -2250.4121, -1492.6443, 690.0442}
};

forward HideScreenMsg(playerid);
public HideScreenMsg(playerid)
{
	PlayerTextDrawHide(playerid, MessageInfo);
	return 1;
}

forward HandleAccount(playerid);
public HandleAccount(playerid)
{
    if(cache_num_rows())
    {
        Login_Dialog(playerid);
    }
    else
    {
        Register_Dialog(playerid);
    }
    return 1;
}

forward OnPlayerConnectDelay(playerid);
public OnPlayerConnectDelay(playerid)
{
	ClearPlayerChat(playerid);
	TogglePlayerSpectating(playerid, true);
	PlayerTextDrawsCreate(playerid);

	new message[128];
	format(message, sizeof(message), "Добре дошли в %s, %s {FFFFFF}[Version: %s: %s]", SERVER_NAME, GetRoleplayName(playerid), SERVER_GAMEMODE, SERVER_VERSION);
	SendClientMessage(playerid, COLOR_GOLD, message);
	format(message, sizeof(message), "%s has joined the server", GetName(playerid));
    SendAdminsMessage(1, COLOR_GRAY, message);

	new query[400];
	mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT NULL FROM `accounts` WHERE username = '%e' LIMIT 1", GetName(playerid));
	mysql_tquery(SQL_CONNECTION, query, "HandleAccount", "i", playerid);

	SetTimerEx("ConnectMoveCamera", SECONDS(2), false, "i", playerid);
}

forward ConnectMoveCamera(playerid);
public ConnectMoveCamera(playerid)
{
	new loginScreen = random(sizeof(ClassSelectionData));
	InterpolateCameraPos(playerid, ClassSelectionData[loginScreen][0], ClassSelectionData[loginScreen][1], ClassSelectionData[loginScreen][2], ClassSelectionData[loginScreen][6], ClassSelectionData[loginScreen][7], ClassSelectionData[loginScreen][8], 70000, CAMERA_MOVE);
	InterpolateCameraLookAt(playerid, ClassSelectionData[loginScreen][3], ClassSelectionData[loginScreen][4], ClassSelectionData[loginScreen][5], ClassSelectionData[loginScreen][9], ClassSelectionData[loginScreen][10], ClassSelectionData[loginScreen][11], 70000, CAMERA_MOVE);
}

forward FixKick(playerid);
public FixKick(playerid)
{
	Kick(playerid);
	return 1;
}


forward MySQLConnect();
public MySQLConnect()
{
	SQL_CONNECTION = mysql_connect(SQL_HOST, SQL_USER, SQL_DB, SQL_PASS);
	mysql_log(LOG_ALL);
    if(mysql_errno(SQL_CONNECTION) == 0)
    {
		mysql_log(LOG_ERROR | LOG_WARNING | LOG_DEBUG);
		printf("------------------------------------------------------------------------------");
    	printf("[MYSQL]: Connection to `%s`@'%s' succesful!", SQL_DB, SQL_HOST);
		printf("------------------------------------------------------------------------------");
	}
	else
	{
		printf("------------------------------------------------------------------------------");
	    printf("[MYSQL]: ERROR: Connection to `%s`@'%s' failed!", SQL_DB, SQL_HOST);
		printf("------------------------------------------------------------------------------");
	}
	return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	switch(errorid)
	{
		case CR_SERVER_GONE_ERROR:
		{
			printf("Lost connection to server, trying reconnect...");
			mysql_reconnect(connectionHandle);
		}
		case ER_SYNTAX_ERROR:
		{
			printf("[MYSQL]: SYNTAX ERROR: %s",query);
		}
	}
	new str[128];
	print(str);
	return 1;
}

forward UpdateTime();
public UpdateTime()
{
	new Clockstr[128];
	gettime(ClockHours, ClockMinutes, ClockSeconds);
	format(Clockstr, sizeof(Clockstr), "%02d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);
	TextDrawSetString(PublicTD[0], Clockstr);
	foreach (Player, i)
	{
		SetPlayerTime(i, ClockHours, ClockMinutes);
	}
	return 1;
}

main()
{
	gettime(ClockHours, ClockMinutes, ClockSeconds);
	print("\n\nСървърът е успешно включен!");
	printf("\nВреме на пускане: %d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);
	printf("\n%s (copyright) %s [Version: %s]\n", SERVER_NAME, SERVER_SCRIPTER, SERVER_VERSION);
}

public OnGameModeInit()
{
	new str[32];
	MySQLConnect();
	format(str, sizeof(str), "%s %s", SERVER_GAMEMODE, SERVER_VERSION);
    SetGameModeText(str);
	SendRconCommand("rcon_password BG_RCON");
	SendRconCommand("loadfs Mapping");
	SendRconCommand("loadfs Maps_County");
    ManualVehicleEngineAndLights();
    ShowPlayerMarkers(0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	ServerTextdrawsCreate();
	SetTimer("UpdateTime", SECONDS(1), 1);
	LoadPickupsAnd3Texts();
	SetServerVars();
	CreateObjects();

	AddPlayerClass(1, -318.6522, 1049.3909, 20.3403, 358.4333, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	mysql_close(SQL_CONNECTION);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	Account_Reset(playerid);
	ClearPlayerChat(playerid);
	NameCheck(playerid);

	SetTimerEx("OnPlayerConnectDelay", 200, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Account_Save(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
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

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!PlayerTemp[playerid][loggedIn]) return SendErrorMesssage(playerid, "За да използваш команди трябва да си в профила си!");
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success) return SendClientMessage(playerid, COLOR_WHITE, "SERVER: Невалидна команда!");
	new cmd_str[1024];
	format(cmd_str, sizeof(cmd_str), "[%s] %s(ID %i): %s", GetServerTimeString(), GetName(playerid), playerid, cmdtext);
	if(PlayerInfo[playerid][Admin] == 0)
	{
		AddToLog("commands", cmd_str);
	}
	else
	{
		AddToLog("admin", cmd_str);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(!PlayerTemp[playerid][loggedIn]) return false;

	new chat_str[256], message_str[256];
	format(message_str, sizeof(message_str),"%s says: %s", GetRoleplayName(playerid), text);
	format(chat_str, sizeof(chat_str), "[%s] %s", GetServerTimeString(), message_str);
	if(PlayerInfo[playerid][Admin] == 0)
	{
		AddToLog("chat", chat_str);
	}
	else
	{
		AddToLog("admin", chat_str);
	}
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

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		PlayerTextDrawShow(playerid, VehMeter);
	}
	else
	{	
		PlayerTextDrawHide(playerid, VehMeter);
	}
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

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(pickupid == cityHall)
	{
		SendMessageScreenText(playerid, "~b~DOCUMENTS~n~~w~PRESS ~r~Y ~w~TO GET DOCUMENTS");
	}
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
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

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES)
	{
		if(IsPlayerNear(playerid, 226.8523,2348.3042,1017.1298, HALL_VIRTUAL_WORLD,  HALL_INTERIOR))
		{
			if(PlayerInfo[playerid][Gender] != GENDER_NONE && PlayerInfo[playerid][Age] != 0)
			{
				SendErrorMesssage(playerid, "Ти вече имаш издадени документи!");
				return 1;
			}
			new str[256];
    		format(str, sizeof(str), "{ffffff}Здравейте {33aa33}%s{ffffff}! Изберете вашия пол, чрез копчетата отдолу:", GetRoleplayName(playerid));
    		Dialog_Show(playerid, DOCUMENTS_MENU_1, DIALOG_STYLE_MSGBOX, "New Reality Roleplay | Gender Select", str, "Мъж", "Жена");
		}
	}

	if(newkeys & 16)
	{
		ButtonEnterBuilding(playerid);
		ButtonExitBuilding(playerid);
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	UpdatePlayerTextDraws(playerid);
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
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

forward StopLoopingAnim(playerid);
public StopLoopingAnim(playerid)
{
	PlayerTemp[playerid][UsingLoopingAnim] = false;
	TextDrawHideForPlayer(playerid,txtAnimHelper);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
}

stock FormatCash(amount)
{
	new formatted_amount[20];
	format(formatted_amount, sizeof(formatted_amount), "%i", amount);

	if(amount < 0)
	{
		strdel(formatted_amount, 0, 1);
	}

	new pos = strlen(formatted_amount);

	if(pos > 3)
	{
		strins(formatted_amount, ",", pos-3);
		if(pos > 6)
		{
			strins(formatted_amount, ",", pos-6);
			if(pos > 9)
			{
				strins(formatted_amount, ",", pos-9);
			}
		}
	}

	if(amount < 0)
	{
		strins(formatted_amount, "-", 0);
	}

	return formatted_amount;
}

stock OnePlayAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, freeze, lp)
{
	if(PlayerTemp[playerid][UsingLoopingAnim]) TextDrawHideForPlayer(playerid,txtAnimHelper);
	StopLoopingAnim(playerid);
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, freeze, lp, 1);
}

stock LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, freeze, lp)
{
	if(PlayerTemp[playerid][UsingLoopingAnim])TextDrawHideForPlayer(playerid,txtAnimHelper);
	PlayerTemp[playerid][UsingLoopingAnim] = true;
	TextDrawShowForPlayer(playerid,txtAnimHelper);
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, freeze, lp, 1);
}

stock CreateObjects()
{
	// ATM Bank Machines
	AtmObjectID[0] = CreateDynamicObject(2942, 2334.31900000, 57.43700000, 26.12700000, 0.0, 0.0, -270.0);
	AtmObjectID[1] = CreateDynamicObject(2942, 1289.75200000, 273.56800000, 19.19800000, 0.0, 0.0, -293.359);
	AtmObjectID[2] = CreateDynamicObject(2942, 1341.81347656, 215.34375000, 19.19000053, 0.0, 0.0, 156.63757324);
	AtmObjectID[3] = CreateDynamicObject(2942, 256.54600000, -62.21300000, 1.22100000, 0.0, 0.0, -720.859);
	AtmObjectID[4] = CreateDynamicObject(2942, 703.02148438, -494.71777344, 15.97900009, 0.0, 0.0, 179.13757324);
	AtmObjectID[5] = CreateDynamicObject(2942, 661.34863281, -554.77050781, 15.97900009, 0.0, 0.0, 269.13757324);
	AtmObjectID[6] = CreateDynamicObject(2942, 242.53222656, -184.89648438, 1.22099996, 0.0, 0.0, 270.85693359);
	AtmObjectID[7] = CreateDynamicObject(2942, -131.19999695, 1188.59997559, 19.39999962, 0.0, 0.0, 180.0);
	AtmObjectID[8] = CreateDynamicObject(2942, -856.50976562, 1533.20898438, 22.22994232, 0.0, 0.0, 90.0);
	AtmObjectID[9] = CreateDynamicObject(2942, -1215.40844727, 1825.91003418, 41.36164856, 0.0, 0.0, 45.67);
	AtmObjectID[10] = CreateDynamicObject(2942, -1475.02624512, 2610.81567383, 55.47883606, 0.0, 0.0, 0.0);
	AtmObjectID[11] = CreateDynamicObject(2942, 666.40185547, 1720.49011230, 6.83039951, 0.0, 0.0, 220.42041016);
	AtmObjectID[12] = CreateDynamicObject(2942, -1569.48681641, -2727.05493164, 48.38635635, 0.0, 0.0, 325.52026367);
	AtmObjectID[13] = CreateDynamicObject(2942, -2102.25488281, -2344.01367188, 30.26789856, 0.0, 0.0, 321.63574219);
	AtmObjectID[14] = CreateDynamicObject(2942, -2175.36132812, -2327.61328125, 30.24289894, 0.0, 0.0, 51.36108398);
	AtmObjectID[15] = CreateDynamicObject(2942, -2490.62890625, 2341.37695312, 4.62727451, 0.0, 0.0, 0.0);
	AtmObjectID[16] = CreateDynamicObject(19324, 1231.685, 184.435, 2090.9982, 0.000, 0.000, 90.000);

	//AtmPickupID[0] = AddStaticPickup(1274, 2, 1506.3359, 1432.3585, 10.1191, 0);
}

stock ProxDetector(Float:dist, playerid, text[], col1, col2, col3, col4, col5)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:pX, Float:pY, Float:pZ, vWorld = GetPlayerVirtualWorld(playerid);
		new Float:this_dist;
		GetPlayerPos(playerid, pX, pY, pZ);

		foreach (Player, i)
		{
			if(GetPlayerVirtualWorld(i) == vWorld)
			{
				this_dist = GetPlayerDistanceFromPoint(i, pX, pY, pZ);

				if(this_dist < dist/16) SendSplitMessage(i, col1, text);
				else if(this_dist < dist/8) SendSplitMessage(i, col2, text);
				else if(this_dist < dist/4) SendSplitMessage(i, col3, text);
				else if(this_dist < dist/2) SendSplitMessage(i, col4, text);
				else if(this_dist < dist) SendSplitMessage(i, col5, text);
			}
		}
	}
	return true;
}

stock SendSplitMessage(playerid, color, msg[])
{
	new ml = 115, result[160], len = strlen(msg), repeat;
	if(len > ml)
	{
		repeat = (len / ml);
		for(new i = 0; i <= repeat; i++)
		{
			result[0] = 0;
			if(len - (i * ml) > ml)
			{
				strmid(result, msg, ml * i, ml * (i+1));
				format(result, sizeof(result), "%s", result);
			}
			else
			{
				strmid(result, msg, ml * i, len);
				format(result, sizeof(result), "%s", result);
			}
			SendClientMessage(playerid, color, result);
		}
	}
	else
	{
		SendClientMessage(playerid, color, msg);
	}
	return true;
}

stock SetPlayerHealthEx(playerid, Float: health)
{
	PlayerInfo[playerid][Health] = 100;
	SetPlayerHealth(playerid, health);
}

stock SetPlayerArmourEx(playerid, Float: health)
{
	PlayerInfo[playerid][Health] = 100;
	SetPlayerHealth(playerid, health);
}

stock AddToLog(logtype[], msg[])
{
	#if SERVER_LOGS_ON == true
		new File:logfile, logpath[56], log_str[1024];
		format(log_str, sizeof(log_str), "%s\r\n", msg);

		if(strcmp("commands", logtype, true) == 0)
		{
			format(logpath, 56, COMMAND_LOG, GetDateString());
			logfile = fopen(logpath, io_append);
		}
		else if(strcmp("admin", logtype, true) == 0)
		{
			format(logpath, 56, ADMIN_LOG, GetDateString());
			logfile = fopen(logpath, io_append);
		}
		else if(strcmp("chat", logtype, true) == 0)
		{
			format(logpath, 56, CHAT_LOG, GetDateString());
			logfile = fopen(logpath, io_append);
		}
		else if(strcmp("cash", logtype, true) == 0)
		{
			format(logpath, 56, CASH_LOG, GetDateString());
			logfile = fopen(logpath, io_append);
		}
		if(logfile)
		{
			fwrite(logfile, log_str);
			fclose(logfile);
		}
	#endif

	return true;
}

stock GetDateString()
{
	new DateStr[32], StNdRdTh[3], MonthName[11], Year, Month, Day;
	getdate(Year,Month,Day);

	StNdRdTh = "th";
	if(Day == 1||Day == 21||Day == 31) StNdRdTh = "st";
	else if(Day == 2||Day == 22) StNdRdTh = "nd";
	else if(Day == 3||Day == 23) StNdRdTh = "rd";

	switch(Month)
	{
		case 1: MonthName = "January";
		case 2: MonthName = "February";
		case 3: MonthName = "March";
		case 4: MonthName = "April";
		case 5: MonthName = "May";
		case 6: MonthName = "June";
		case 7: MonthName = "July";
		case 8: MonthName = "August";
		case 9: MonthName = "September";
		case 10: MonthName = "October";
		case 11: MonthName = "November";
		case 12: MonthName = "December";
	}
	format(DateStr,sizeof(DateStr),"%i%s %s %i",Day,StNdRdTh,MonthName,Year);
	return DateStr;
}

stock GetTimeString()
{
	new AmPm[3], TimeStr[24];
	new hour = ClockHours;
	if(hour >= 0 && hour <= 11)
	{
		if(hour == 0) hour = 12;
		AmPm = "AM";
	}
	else if(hour >= 12 && hour <= 23)
	{
		if(hour != 12) hour -= 12;
		AmPm = "PM";
	}
	format(TimeStr,sizeof(TimeStr),"%02d:%02d:%02d %s", hour, ClockMinutes, ClockSeconds, AmPm);
	return TimeStr;
}

stock GetServerTimeString()
{
	new TimeStr[32];
	format(TimeStr,sizeof(TimeStr),"%02d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);
	return TimeStr;
}

stock GivePlayerCash(playerid, cash)
{
	PlayerInfo[playerid][Cash] += cash;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][Cash]);
	return PlayerInfo[playerid][Cash];
}

stock SetPlayerCash(playerid, cash)
{
	PlayerInfo[playerid][Cash] = cash;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][Cash]);
	return PlayerInfo[playerid][Cash];
}

stock HandlePlayerLogin(playerid)
{
	new str[128];
	SendClientMessage(playerid, COLOR_WHITE, "Здравейте отново! Вие успешно влязохте в профила си.");
	SendClientMessage(playerid, -1, " ");
	format(str, sizeof(str), "Character: %s | Admin Level: %d | Faction: %s | Rank: %d",GetRoleplayName(playerid),PlayerInfo[playerid][Admin], 
		GetPlayerFactionName(playerid), PlayerInfo[playerid][FactionRank]);
	SendClientMessage(playerid, COLOR_GOLD, str);
	PlayerTemp[playerid][loggedIn] = true;
	SetPlayerCash(playerid, PlayerInfo[playerid][Cash]);
	PlayerSpawnIn(playerid);
	ShowServerTextdraws(playerid);
}

stock HandlePlayerRegister(playerid)
{
	SendClientMessage(playerid, COLOR_WHITE, "Вие успешно регистрирахте вашия профил.");
	SetPlayerCash(playerid, 5050);
	PlayerInfo[playerid][Skin] = 34;
	PlayerInfo[playerid][Gender] = GENDER_NONE;
	PlayerInfo[playerid][FactionRank] = 1;
	PlayerInfo[playerid][Level] = 1;
	PlayerInfo[playerid][Health] = 100.0;
	PlayerInfo[playerid][X] = 1.0;
	PlayerInfo[playerid][Y] = 1.0;
	PlayerInfo[playerid][Z] = 1.0;
	PlayerInfo[playerid][Angle] = 1.0;
	PlayerTemp[playerid][loggedIn] = true;
	PlayerSpawnIn(playerid);
	ShowServerTextdraws(playerid);
}

stock ShowServerTextdraws(playerid)
{
	for(new i=0; i<sizeof(PublicTD); i++)
	{
		TextDrawShowForPlayer(playerid, PublicTD[i]);
	}
	PlayerTextDrawShow(playerid, PlayerLocation);
}

stock SendAdminsMessage(level, color, text[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            new str[128];
            if(PlayerInfo[i][Admin] >= level)
            {
                format(str, sizeof(str), "[Admin Msg] %s", text);
                SendClientMessage(i, color, str);
            }
        }
    }
}

stock NameCheck(playerid)
{
    if (strfind(GetName(playerid), "_", true) == -1)
	{
		ClearPlayerChat(playerid);
        SendClientMessage(playerid, COLOR_RED, "SERVER: За да играете тук, трябва вашето име да бъде в този формат Name_Family. Забележете, че трябва да има '_'");
		KickPlayer(playerid);
		new str[128];
		format(str, sizeof(str), "%s was kicked by the server. [Reason: Играчът влиза без RP име]",GetName(playerid));
		SendAdminsMessage(1, COLOR_ORANGERED, str);
	}
	return 1;
}

stock KickPlayer(playerid)
{
	SetTimerEx("FixKick", 200, false, "d", playerid);
}

stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    return name;
}

stock GetRoleplayName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    name[strfind(name,"_")] = ' ';
    return name;
}

stock ClearPlayerChat(playerid)
{
	for(new i=0; i<60; i++)
	{
		SendClientMessage(playerid, -1, "    ");
	}
}

stock Login_Dialog(playerid)
{
    new str[256];
    format(str, sizeof(str), "{ffffff}Здравейте {33aa33}%s{ffffff} вашият профил е вече регистриран.\nЗа да влезете в играта, трябва да напишете паролата си отолу:", GetName(playerid));
    Dialog_Show(playerid, LOGIN_MENU, DIALOG_STYLE_PASSWORD, "New Reality Roleplay | Login", str, "Login", "Leave");
    return 1;
}

stock Register_Dialog(playerid)
{
    new str[256];
    format(str, sizeof(str), "{ffffff}Здравейте {33aa33}%s{ffffff}, вашият профил не е регистриран.\nЗа да влезете в играта, трябва да се регистрирате, като напишете паролата си отдолу:", GetName(playerid));
    Dialog_Show(playerid, REGISTER_MENU, DIALOG_STYLE_PASSWORD, "New Reality Roleplay | Register", str,"Register","Leave");
    return 1;
}

Dialog:DOCUMENTS_MENU_1(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		SendClientMessage(playerid, COLOR_WHITE, "Вие избрахте да бъдете мъж. Сега трябва да посочите и желаната от вас възраст");
		PlayerTemp[playerid][TempGender] = GENDER_MALE;
	}
	else
	{
		SendClientMessage(playerid, COLOR_WHITE, "Вие избрахте да бъдете жена. Сега трябва да посочите и желаната от вас възраст");
		PlayerTemp[playerid][TempGender] = GENDER_FEMALE;
	}
	new str[256];
    format(str, sizeof(str), "{ffffff}Вие вече избрахте желания пол от вас, {33aa33}%s{ffffff}\nСега посочете вашата година на раждане:", GetRoleplayName(playerid));
    Dialog_Show(playerid, DOCUMENTS_MENU_2, DIALOG_STYLE_INPUT, "New Reality Roleplay | Gender Select", str, "OK", "Close");
	return 1;
}

Dialog:DOCUMENTS_MENU_2(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_WHITE, "SERVER: Вие се отказахте от документите, които подготвяхте!");
	new birthYear = strval(inputtext);
	if(birthYear < 1968 || birthYear > 2004)
	{
		SendErrorMesssage(playerid, "Годината на раждане трябва да бъде между 1968 и 2004!");
		return 1;
	}
	PlayerInfo[playerid][Gender] = PlayerTemp[playerid][TempGender];
	PlayerInfo[playerid][Age] = birthYear;
	new str[128];

	if(PlayerInfo[playerid][Gender] == GENDER_MALE)
	{
		format(str, sizeof(str), "Вашите документи са готови! Вие сте Мъж, роден през %d", birthYear);
		PlayerInfo[playerid][Skin] = 34;
	}
	else
	{
		format(str, sizeof(str), "Вашите документи са готови! Вие сте Жена, родена през %d", birthYear);
		PlayerInfo[playerid][Skin] = 12;
	}
	SendClientMessage(playerid, COLOR_LIGHTGREEN, str);
	Account_Save(playerid);
	return 1;
}

Dialog:REGISTER_MENU(playerid, response, listitem, inputtext[])
{
	if(strlen(inputtext) < 6 || strlen(inputtext) > 24)
    {
        SendClientMessage(playerid, COLOR_ORANGERED, "Паролата трябва да бъде с дължина между 6 и 24 символа!");
        Register_Dialog(playerid);
    }
    else if(strlen(inputtext) > 5 && strlen(inputtext) < 24)
    {
        new query[400],escapepass[129];
        
        WP_Hash(escapepass, sizeof(escapepass), inputtext);

		GetPlayerIp(playerid, PlayerInfo[playerid][RegisterIP], 16);

    	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO accounts (Username, Password, RegisterIP, RegisterDate) VALUES('%e','%e','%e', %d)", GetName(playerid), escapepass, PlayerInfo[playerid][RegisterIP], getdate());
		mysql_tquery(SQL_CONNECTION, query, "GetAccID", "i", playerid);

		Account_Reset(playerid);
		HandlePlayerRegister(playerid);
	}
    return 1;
}


Dialog:LOGIN_MENU(playerid, response, listitem, inputtext[])
{
	if(!response)
	{ 
		SendClientMessage(playerid, COLOR_RED, "SERVER: Вие решихте да излезете от сървъра.");
		KickPlayer(playerid);
	}
    if(response)
    {
        new query[256], escapepass[129];
        WP_Hash(escapepass, sizeof(escapepass), inputtext);

		Account_Reset(playerid);

		mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT * FROM accounts WHERE Username = '%e' AND Password = '%e' LIMIT 1", GetName(playerid), escapepass);
    	mysql_tquery(SQL_CONNECTION, query, "Login", "i", playerid);

	}
    return 1;
}

forward GetAccID(playerid);
public GetAccID(playerid)
{
	PlayerInfo[playerid][SQLID] = cache_insert_id();
	return 1;
}

forward Login(playerid); //Проблем при Load-ване!
public Login(playerid)
{
    if(cache_num_rows())
    {
        PlayerInfo[playerid][SQLID] = cache_get_field_content_int(0, "id", SQL_CONNECTION);
        PlayerInfo[playerid][Admin] = cache_get_field_content_int(0, "Admin", SQL_CONNECTION);
		PlayerInfo[playerid][Faction] = cache_get_field_content_int(0, "Faction", SQL_CONNECTION);
		PlayerInfo[playerid][FactionRank] = cache_get_field_content_int(0, "FactionRank", SQL_CONNECTION);
		PlayerInfo[playerid][Cash] = cache_get_field_content_int(0, "Cash", SQL_CONNECTION);
		PlayerInfo[playerid][Bank] = cache_get_field_content_int(0, "Bank", SQL_CONNECTION);
		PlayerInfo[playerid][Health] = cache_get_field_content_float(0, "Health", SQL_CONNECTION);
		PlayerInfo[playerid][Armour] = cache_get_field_content_float(0, "Armour", SQL_CONNECTION);
		PlayerInfo[playerid][Skin] = cache_get_field_content_int(0, "Skin", SQL_CONNECTION);
		PlayerInfo[playerid][Level] = cache_get_field_content_int(0, "Level", SQL_CONNECTION);
		PlayerInfo[playerid][X] = cache_get_field_content_float(0, "X", SQL_CONNECTION);
		PlayerInfo[playerid][Y] = cache_get_field_content_float(0, "Y", SQL_CONNECTION);
		PlayerInfo[playerid][Z] = cache_get_field_content_float(0, "Z", SQL_CONNECTION);
		PlayerInfo[playerid][Angle] = cache_get_field_content_float(0, "Angle", SQL_CONNECTION);
		PlayerInfo[playerid][Gender] = cache_get_field_content_int(0, "Gender", SQL_CONNECTION);
		PlayerInfo[playerid][Age] = cache_get_field_content_int(0, "Age", SQL_CONNECTION);
		PlayerInfo[playerid][VirtualWorld] = cache_get_field_content_int(0, "VirtualWorld", SQL_CONNECTION);
		PlayerInfo[playerid][Interior] = cache_get_field_content_int(0, "Interior", SQL_CONNECTION);
        format(PlayerInfo[playerid][Name], 32, "%s", GetName(playerid));
        printf("%s: Logged in.", PlayerInfo[playerid][Name]);
		HandlePlayerLogin(playerid);
    }
    else // Login
    {
        if(PlayerTemp[playerid][LoginAttempt] < 2)
        {
            Login_Dialog(playerid);
            SendClientMessage(playerid, COLOR_ORANGERED, "Грешна парола!");
            PlayerTemp[playerid][LoginAttempt] += 1;
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "SERVER: Вие бяхте KICKED [Reason: Твърде много грешни опити за вход]");
            KickPlayer(playerid);
        }
    }
    return 1;
}

Account_Save(playerid)
{
	if(PlayerTemp[playerid][loggedIn])
	{
		new query[3000];
		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Accounts SET Faction = %i, FactionRank = %i, Cash = %i, \
		Bank = %i, Health = %f, Armour = %f, Skin = %i, Level = %i, Gender = %i, Age = %i \
		WHERE id = %d LIMIT 1",
		PlayerInfo[playerid][Faction],
		PlayerInfo[playerid][FactionRank],
		PlayerInfo[playerid][Cash],
		PlayerInfo[playerid][Bank],
		PlayerInfo[playerid][Health],
		PlayerInfo[playerid][Armour],
		PlayerInfo[playerid][Skin],
		PlayerInfo[playerid][Level],
		PlayerInfo[playerid][Gender],
		PlayerInfo[playerid][Age],
		PlayerInfo[playerid][SQLID]);

		mysql_tquery(SQL_CONNECTION, query);
		//printf("%s", query);
			
		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Accounts SET Admin = %i WHERE id = %d LIMIT 1",
		
			PlayerInfo[playerid][Admin],
			PlayerInfo[playerid][SQLID]);
			
		mysql_tquery(SQL_CONNECTION, query, "", "");

		Position_Save(playerid);
	    Weapons_Save(playerid);

	}
	return 1;
}

stock GivePlayerGun(player, WeaponID, Ammo)
{

    Weapon[player][GetWeaponSlot(WeaponID)] = WeaponID;
	WeaponAmmo[player][GetWeaponSlot(WeaponID)] = Ammo;
		
    UpdatePlayerWeapons(player);	
	return 1;
}


stock ClearPlayerWeapons(playerid)
{
	ResetPlayerWeapons(playerid);
	Weapon[playerid][1] = 0;
	WeaponAmmo[playerid][1] = 0;
	Weapon[playerid][2] = 0;
	WeaponAmmo[playerid][2] = 0;
	Weapon[playerid][3] = 0;
	WeaponAmmo[playerid][3] = 0;
	Weapon[playerid][4] = 0;
	WeaponAmmo[playerid][4] = 0;
	Weapon[playerid][5] = 0;
	WeaponAmmo[playerid][5] = 0;
	Weapon[playerid][6] = 0;
	WeaponAmmo[playerid][6] = 0;
	Weapon[playerid][7] = 0;
	WeaponAmmo[playerid][7] = 0;
	Weapon[playerid][8] = 0;
	WeaponAmmo[playerid][8] = 0;
	Weapon[playerid][9] = 0;
	WeaponAmmo[playerid][9] = 0;
	Weapon[playerid][10] = 0;
	WeaponAmmo[playerid][10] = 0;
	Weapon[playerid][11] = 0;
	WeaponAmmo[playerid][11] = 0;
	Weapon[playerid][12] = 0;
	WeaponAmmo[playerid][12] = 0;
	return 1;
}

UpdatePlayerWeapons(playerid)
{
	new Holding;
	Holding = GetPlayerWeapon(playerid);
	ResetPlayerWeapons(playerid);
	for(new w = 1; w < 13; w++)
	{
		if(WeaponAmmo[playerid][w] == 0) Weapon[playerid][w] = 0;
		if(Weapon[playerid][w] > 0) GivePlayerWeapon(playerid,Weapon[playerid][w],WeaponAmmo[playerid][w]);
	}
    SetPlayerArmedWeapon(playerid, Holding);
	return 1;
}

stock GetWeaponIDFromName(str[])
{
    for(new i = 0; i < 48; i++)
	{
        if (i == 19 || i == 20 || i == 21) continue;
        if (strfind(WeaponNameList[i], str, true) != -1)
		{
            return i;
        }
    }
    return -1;
}

Position_Save(playerid)
{
	new query[400];
	GetPlayerPos(playerid, PlayerInfo[playerid][X], PlayerInfo[playerid][Y], PlayerInfo[playerid][Z]);
	GetPlayerFacingAngle(playerid, PlayerInfo[playerid][Angle]);

	mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Accounts SET X = %f, Y = %f, Z = %f, Angle = %f, Interior = %d, VirtualWorld = %d WHERE id = %d LIMIT 1",

			PlayerInfo[playerid][X],
			PlayerInfo[playerid][Y],
			PlayerInfo[playerid][Z],
			PlayerInfo[playerid][Angle],
			GetPlayerInterior(playerid),
			GetPlayerVirtualWorld(playerid),

			PlayerInfo[playerid][SQLID]);

	mysql_tquery(SQL_CONNECTION, query, "", "");
}

Weapons_Save(playerid)
{
	new weap[104],query[200];
    for(new x = 1; x < 13; x++)
    {
    	new weapna, weapam, str[18];
    	GetPlayerWeaponData(playerid, x, weapna, weapam);
    	if(weapam == 0) 
		{
			Weapon[playerid][x] = 0;
			WeaponAmmo[playerid][x] = 0;
		}
    	format(str, sizeof(str), "%d,%d,", Weapon[playerid][x], WeaponAmmo[playerid][x]);
        strcat(weap, str);
    }
    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Accounts SET Weapons = '%e' WHERE id = %d LIMIT 1", weap, PlayerInfo[playerid][SQLID]);	
	mysql_tquery(SQL_CONNECTION, query);
}

Account_Reset(playerid)
{
	for(new i; pInfo:i < pInfo; i++)
	{
    	PlayerInfo[playerid][pInfo:i] = 0;
		//printf("%s :: %d", pInfo:i, PlayerInfo[playerid][pInfo:i]);
	}

	for(new i; ptInfo:i < ptInfo; i++)
	{
		PlayerTemp[playerid][ptInfo:i] = 0;
	}

	ClearPlayerWeapons(playerid);
	return 1;
}

stock GetFactionName(factionid)
{
	new factionName[64];
	format(factionName, sizeof(factionName), FactionInfo[factionid][Name]);
	return factionName;
}

stock GetPlayerFactionName(playerid)
{
	new name[64];
	format(name, sizeof(name), GetFactionName(PlayerInfo[playerid][Faction]));
	return name;
}

stock GetFactionRankName(factionid, rank)
{
	new rankName[32];
	switch(rank)
	{
		case 1:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank1]);
		}
		case 2:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank2]);
		}
		case 3:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank3]);
		}
		case 4:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank4]);
		}
		case 5:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank5]);
		}
		case 6:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank6]);
		}
		case 7:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank7]);
		}
		case 8:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank8]);
		}
		case 9:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank9]);
		}
		case 10:
		{
			format(rankName, sizeof(rankName), FactionInfo[factionid][Rank10]);
		}
	}
	return rankName;
}

stock GetPlayerFactionRankName(playerid)
{
	new factionid = PlayerInfo[playerid][Faction];
	new rank = PlayerInfo[playerid][FactionRank];
	return GetFactionRankName(factionid, rank);
}

stock SetPlayerToSpawnPos(playerid)
{
	SetPlayerPos(playerid, PlayerInfo[playerid][X], PlayerInfo[playerid][Y], PlayerInfo[playerid][Z]);
	SetPlayerFacingAngle(playerid, PlayerInfo[playerid][Angle]);
	SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][VirtualWorld]);
	SetPlayerInterior(playerid, PlayerInfo[playerid][Interior]);
}

stock HasDocuments(playerid)
{
	if(PlayerInfo[playerid][Gender] == GENDER_NONE)
	{
		return false;
	}
	return true;
}

forward PlayerSpawnIn(playerid);
public PlayerSpawnIn(playerid)
{
	TogglePlayerSpectating(playerid, false);
	SetSpawnInfo(playerid, NO_TEAM, PlayerInfo[playerid][Skin], PlayerInfo[playerid][X], PlayerInfo[playerid][Y], PlayerInfo[playerid][Z], 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	if(!HasDocuments(playerid))
	{
		SendClientMessage(playerid,COLOR_LIGHTGREEN,"SERVER: Сега трябва да си изкарате лична карта от жълтата иконка.");
		GameTextForPlayer(playerid, "~w~Welcome to~n~~y~New Reality Roleplay", 3100, 1);
		SetPlayerPos(playerid,231.5891,2348.4021,1017.1257);
		SetPlayerFacingAngle(playerid, 89.9059);
		SetPlayerInterior(playerid,HALL_INTERIOR);
		SetPlayerVirtualWorld(playerid,HALL_VIRTUAL_WORLD);
		return 1;
	}
	
	SetPlayerHealth(playerid, PlayerInfo[playerid][Health]);
	SetPlayerArmour(playerid, PlayerInfo[playerid][Armour]);
	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	SetPlayerScore(playerid, PlayerInfo[playerid][Level]);
	SetPlayerToSpawnPos(playerid);
	UpdatePlayerWeapons(playerid);
	return 1;
}

stock PlayerTextDrawsCreate(playerid)
{
	MessageInfo = CreatePlayerTextDraw(playerid, 324.333160, 139.377838, " ");
	PlayerTextDrawLetterSize(playerid, MessageInfo, 0.468665, 2.562372);
	PlayerTextDrawAlignment(playerid, MessageInfo,  2);
	PlayerTextDrawColor(playerid, MessageInfo, -1);
	PlayerTextDrawSetShadow(playerid, MessageInfo, 0);
	PlayerTextDrawSetOutline(playerid, MessageInfo, -1);
	PlayerTextDrawBackgroundColor(playerid, MessageInfo, 255);
	PlayerTextDrawFont(playerid, MessageInfo, 2);
	PlayerTextDrawSetProportional(playerid, MessageInfo, 1);

	PlayerLocation = CreatePlayerTextDraw(playerid, 633.000000, 426.000000, "RED COUNTY");
	PlayerTextDrawFont(playerid, PlayerLocation, 2);
	PlayerTextDrawLetterSize(playerid, PlayerLocation, 0.283332, 1.650000);
	PlayerTextDrawSetOutline(playerid, PlayerLocation, 1);
	PlayerTextDrawSetShadow(playerid, PlayerLocation, 1);
	PlayerTextDrawAlignment(playerid, PlayerLocation, 3);
	PlayerTextDrawColor(playerid, PlayerLocation, -1);
	PlayerTextDrawBackgroundColor(playerid, PlayerLocation, 255);
	PlayerTextDrawSetProportional(playerid, PlayerLocation, 1);

	VehMeter = CreatePlayerTextDraw(playerid, 530.000000, 371.000000, "SPEED: 100 KM/H~n~FUEL: 100");
	PlayerTextDrawFont(playerid, VehMeter, 2);
	PlayerTextDrawLetterSize(playerid, VehMeter, 0.179166, 1.550000);
	PlayerTextDrawSetOutline(playerid, VehMeter, 1);
	PlayerTextDrawSetShadow(playerid, VehMeter, 1);
	PlayerTextDrawAlignment(playerid, VehMeter, 1);
	PlayerTextDrawColor(playerid, VehMeter, -1);
	PlayerTextDrawBackgroundColor(playerid, VehMeter, 255);
	PlayerTextDrawBoxColor(playerid, VehMeter, 0);
	PlayerTextDrawUseBox(playerid, VehMeter, 1);
	PlayerTextDrawSetProportional(playerid, VehMeter, 1);
	PlayerTextDrawSetSelectable(playerid, VehMeter, 0);
}

stock ServerTextdrawsCreate()
{
	//Textdraws
	txtAnimHelper = TextDrawCreate(431.0,370.0,"~b~~k~~PED_LOCK_TARGET~ ~w~pentru a oprii animatia");
	TextDrawAlignment(txtAnimHelper,0);
	TextDrawBackgroundColor(txtAnimHelper,0x000000FF);
	TextDrawFont(txtAnimHelper,2);
	TextDrawLetterSize(txtAnimHelper,0.299999,1.1);
	TextDrawColor(txtAnimHelper,COLOR_WHITE);
	TextDrawSetOutline(txtAnimHelper,1);
	TextDrawSetProportional(txtAnimHelper,1);
	TextDrawSetShadow(txtAnimHelper,1);

	PublicTD[0] = TextDrawCreate(579.000000, 16.000000, "12:33:40");
	TextDrawFont(PublicTD[0], 2);
	TextDrawLetterSize(PublicTD[0], 0.316665, 1.899999);
	TextDrawTextSize(PublicTD[0], 400.000000, 17.000000);
	TextDrawSetOutline(PublicTD[0], 1);
	TextDrawSetShadow(PublicTD[0], 4);
	TextDrawAlignment(PublicTD[0], 2);
	TextDrawColor(PublicTD[0], -24);
	TextDrawBackgroundColor(PublicTD[0], 255);
	TextDrawBoxColor(PublicTD[0], 50);
	TextDrawUseBox(PublicTD[0], 0);
	TextDrawSetProportional(PublicTD[0], 1);
	TextDrawSetSelectable(PublicTD[0], 0);

	PublicTD[1] = TextDrawCreate(31.000000, 429.000000, SERVER_SITE);
	TextDrawFont(PublicTD[1], 2);
	TextDrawLetterSize(PublicTD[1], 0.187498, 1.399999);
	TextDrawTextSize(PublicTD[1], 400.000000, 17.000000);
	TextDrawSetOutline(PublicTD[1], 1);
	TextDrawSetShadow(PublicTD[1], 4);
	TextDrawAlignment(PublicTD[1], 1);
	TextDrawColor(PublicTD[1], -48);
	TextDrawBackgroundColor(PublicTD[1], 255);
	TextDrawBoxColor(PublicTD[1], 50);
	TextDrawUseBox(PublicTD[1], 0);
	TextDrawSetProportional(PublicTD[1], 1);
	TextDrawSetSelectable(PublicTD[1], 0);
}

stock SECONDS(seconds)
{
	new ms = seconds*1000;
	return ms;
}

stock LoadPickupsAnd3Texts()
{
	cityHall = CreateDynamicPickup(1239, 1, 226.8523, 2348.3042, 1017.1298, HALL_VIRTUAL_WORLD , HALL_INTERIOR);

	Create3DTextLabel("{FFFFFF}Натисни {FFFF00}ENTER {FFFFFF} за да излезеш",0xFFFFFFFF, 231.5891, 2348.4021, 1017.1257, 12.0, HALL_VIRTUAL_WORLD, HALL_INTERIOR); //CITY HALL
	Create3DTextLabel("{FFFF00}Кметство\n{FFFFFF}Натисни {FFFF00}ENTER {FFFFFF} за да влезеш",0xFFFFFFFF, 2269.7676,-74.6360,26.7724, 12.0, 0, 0); //CITY HALL
}

stock SendMessageScreenText(playerid, text[])
{
	PlayerTextDrawSetString(playerid, MessageInfo, text);
	PlayerTextDrawShow(playerid, MessageInfo);

	SetTimerEx("HideScreenMsg", SECONDS(6), false, "i", playerid);
}

stock IsPlayerNear(playerid, Float: X_Coords, Float: Y_Coords, Float: Z_Coords, VW, Int)
{
	if(IsPlayerInRangeOfPoint(playerid, 2.0, X_Coords, Y_Coords, Z_Coords))
	{
		if(GetPlayerVirtualWorld(playerid) == VW && GetPlayerInterior(playerid) == Int)
		{
			return true;
		}
	}
	return false;
}

stock SendErrorMesssage(playerid, text[])
{
	SendClientMessage(playerid, COLOR_ERROR1, text);
	return 1;
}

stock ButtonEnterBuilding(playerid)
{
	if(IsPlayerNear(playerid, 2269.7676,-74.6360,26.7724, 0, 0))
	{
		if(!HasDocuments(playerid)) return SendErrorMesssage(playerid, "Ще можеш да излезеш само, след като си вземеш документи за самоличност!");
		SetPlayerPos(playerid, 231.5891, 2348.4021, 1017.1257);
		SetPlayerVirtualWorld(playerid, HALL_VIRTUAL_WORLD);
		SetPlayerInterior(playerid, HALL_INTERIOR);
	}
	return 1;
}

stock ButtonExitBuilding(playerid)
{
	if(IsPlayerNear(playerid, 231.5891, 2348.4021, 1017.1257, HALL_VIRTUAL_WORLD, HALL_INTERIOR))
	{
		SetPlayerPos(playerid, 2269.7676,-74.6360,26.7724);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
	}
	return 1;
}

stock SendNotEnoughAdminMsg(playerid)
{
	SendClientMessage(playerid, COLOR_ERROR1, "Нямаш достатъчно права за да ползваш командата!");
	return 1;
}

stock SendMessageNotValidPlayer(playerid)
{
	SendClientMessage(playerid, COLOR_ERROR1, "Няма онлайн играч с такова ID!");
	return 1;
}

stock GetAdminName(admin_lvl)
{
	new adminName[32];
	switch(admin_lvl)
	{
		case 0:
		{
			format(adminName, sizeof(adminName), "Not admin");
		}
		case 1:
		{
			format(adminName, sizeof(adminName), "Helper");
		}
		case 2:
		{
			format(adminName, sizeof(adminName), "Administrator");
		}
		case 3:
		{
			format(adminName, sizeof(adminName), "Master Administrator");
		}
		case 4:
		{
			format(adminName, sizeof(adminName), "Manage");
		}
		case 5:
		{
			format(adminName, sizeof(adminName), "Owner");
		}
		case 6:
		{
			format(adminName, sizeof(adminName), "Scripter");
		}
	}
	return adminName;
}

stock TurnEngine(vehicle, on)
{
	if(on)
	{
		ToggleEngine(vehicle, VEHICLE_PARAMS_ON);
		engineON[vehicle] = true;
	}
	else
	{
		ToggleEngine(vehicle, VEHICLE_PARAMS_OFF);
		engineON[vehicle] = false;
	}
}

stock ToggleEngine(vehicleid, toggle)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, toggle, lights, alarm, doors, bonnet, boot, objective);
}

stock ToggleAlarm(vehicleid, toggle)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, lights, toggle, doors, bonnet, boot, objective);
}

stock ToggleBonnet(vehicleid, toggle)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, toggle, boot, objective);
}

stock ToggleLights(vehicleid, toggle)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, toggle, alarm, doors, bonnet, boot, objective);
}

stock ToggleBoot(vehicleid, toggle)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, toggle, objective);
}

stock GetVehicleKmh(vehicleid)
{
	new Float: x, Float: y, Float: z, vel;
	GetVehicleVelocity(vehicleid, x, y, z);
	vel = floatround(floatsqroot(x *x + y *y + z *z) *180);
	return vel;
}

stock GetVehicleFuel(vehicleid)
{
	return vehFuel[vehicleid];
}

stock UpdatePlayerTextDraws(playerid)
{
	new str[128];
	format(str, sizeof(str), "%s", GetPlayerZone(playerid));
    PlayerTextDrawSetString(playerid, PlayerLocation, str);

	new vehicle = GetPlayerVehicleID(playerid);
	format(str, sizeof(str), "~b~SPEED: %d KM/H~n~FUEL: %d", GetVehicleKmh(vehicle), GetVehicleFuel(vehicle));
    PlayerTextDrawSetString(playerid, VehMeter, str);
}

stock SetServerVars()
{
	for(new i=0; i<MAX_VEHICLES; i++)
	{
		vehFuel[i] = 100;
	}
}

stock IsPlayerNearATM(playerid)
{
	for(new i = 0; i < sizeof(AtmObjectID); i++)
	{
		new Float:oX, Float:oY, Float:oZ;
		GetDynamicObjectPos(AtmObjectID[i], oX, oY, oZ);
		if(IsPlayerInRangeOfPoint(playerid, 1.75, oX, oY, oZ)) return AtmObjectID[i];
	}
	return false;
}

stock ShowMessage(playerid, caption[], info[], button[])
{
	Dialog_Show(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, caption, info, button, "");
	return true;
}

Dialog:BankMenu(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new atm_str[1024];
		if(strcmp("Deposit",inputtext,true) == 0)
		{
			if(PlayerInfo[playerid][Cash] <= 0)
			{
				SendErrorMesssage(playerid, "Нямаш никакви пари, които да депозитираш.");
			}
			else
			{
				new depositBody[128];
				format(depositBody,128,"{FFFFFF}Account: %s\nCurrent Balance: {3D9140}$%s{FFFFFF}\n\nPlease Enter The Amount To Deposit:",GetRoleplayName(playerid),FormatCash(PlayerInfo[playerid][Bank]));
				Dialog_Show(playerid,BankDeposit,DIALOG_STYLE_INPUT,"Red County Banking - Deposit",depositBody,"OK", "");
			}
			PlayerTemp[playerid][UsingATM] = false;
		}

		else if(strcmp("Withdraw",inputtext,true) == 0)
		{
			if(!PlayerTemp[playerid][UsingATM]) format(atm_str, sizeof(atm_str),"{FFFFFF}Account: %s\nCurrent Balance: {3D9140}$%s{FFFFFF}\nWithdraw Limit: {3D9140}$%s{FFFFFF}\n\nPlease Enter The Amount To Withdraw:",GetRoleplayName(playerid),FormatCash(PlayerInfo[playerid][Bank]),FormatCash(PlayerInfo[playerid][Bank]));
			else format(atm_str, sizeof(atm_str),"{FFFFFF}Account: %s\nCurrent Balance: {3D9140}$%s{FFFFFF}\nWithdraw Limit: {3D9140}$50,000{FFFFFF}\n\nPlease Enter The Amount To Withdraw:",GetRoleplayName(playerid),FormatCash(PlayerInfo[playerid][Bank]));

			Dialog_Show(playerid,BankWithdraw,DIALOG_STYLE_INPUT,"Red County Banking - Withdraw",atm_str,"Enter","Cancel");
		}

		else if(strcmp("Transfer",inputtext,true) == 0)
		{
			atm_str[0] = EOS;

			new playersCount = 0;
			foreach (Player, i)
			{
				if(PlayerTemp[playerid][loggedIn] && i != playerid)
				{
					strcat(atm_str,GetName(i));
					strcat(atm_str,"\n");
					playersCount++;
				}
			}
			if(playersCount > 0) Dialog_Show(playerid,BankTransfer1,DIALOG_STYLE_LIST,"Red County Banking - Transfer - (( Select Player To Receive ))",atm_str,"Next","Cancel");
			else ShowMessage(playerid,"Red County Banking - Transfer","Sorry, There Is Nobody To Transfer Your Money To.", "OK");
		}

		else if(strcmp("Balance",inputtext,true) == 0)
		{
			format(atm_str, sizeof(atm_str),"{FFFFFF}Account: %s\n\nCurrent Balance: {3D9140}$%s",GetRoleplayName(playerid),FormatCash(PlayerInfo[playerid][Bank]));
			ShowMessage(playerid,"Red County Banking - Balance",atm_str,"OK");
			PlayerTemp[playerid][UsingATM] = false;
		}

		else if(strcmp("Deposit ALL",inputtext,true) == 0)
		{
			if(PlayerInfo[playerid][Cash] < 1) return SendErrorMesssage(playerid, "Нямаш никакви пари, които да депозитираш.");


			format(atm_str, sizeof(atm_str), "{FFFFFF}BANK STATEMENT - %s @ %s\nOld Balance: {EAEAAE}$%s{FFFFFF}\nDeposit: {EAEAAE}$%s{FFFFFF}\n\nNew Balance: {3D9140}$%s{FFFFFF}",GetRoleplayName(playerid),GetTimeString(),FormatCash(PlayerInfo[playerid][Bank]),FormatCash(PlayerInfo[playerid][Cash]),FormatCash(PlayerInfo[playerid][Bank]+PlayerInfo[playerid][Cash]));

			PlayerInfo[playerid][Bank] += PlayerInfo[playerid][Cash];
			format(atm_str, sizeof(atm_str), "[%s] %s(%i) deposits all ($%i).", GetServerTimeString(), GetRoleplayName(playerid), playerid, PlayerInfo[playerid][Cash]);
			AddToLog("cash", atm_str);
			GivePlayerCash(playerid, -PlayerInfo[playerid][Cash]);

			ShowMessage(playerid,"Red County Banking - Deposit Statement", atm_str, "Ok");
		}
		else if(strcmp("Deposit HALF",inputtext,true) == 0)
		{
			if(PlayerInfo[playerid][Cash] < 2) return SendErrorMesssage(playerid, "Нямаш никакви пари, които да депозитираш.");


			new deposit = PlayerInfo[playerid][Cash] / 2;
			format(atm_str, sizeof(atm_str), "{FFFFFF}BANK STATEMENT - %s @ %s\nOld Balance: {EAEAAE}$%s{FFFFFF}\nDeposit: {EAEAAE}$%s{FFFFFF}\n\nNew Balance: {3D9140}$%s{FFFFFF}",GetRoleplayName(playerid),GetTimeString(),FormatCash(PlayerInfo[playerid][Bank]),FormatCash(deposit),FormatCash(PlayerInfo[playerid][Bank]+deposit));
			GivePlayerCash(playerid, -deposit);
			PlayerInfo[playerid][Bank] += deposit;
			ShowMessage(playerid,"Red County Banking - Deposit Statement", atm_str, "Ok");
			format(atm_str, sizeof(atm_str), "[%s] %s(%i) deposits half ($%i) to bank.", GetServerTimeString(), GetRoleplayName(playerid), playerid, deposit);
			AddToLog("cash", atm_str);
		}
		else if(strcmp("Withdraw ALL",inputtext,true) == 0)
		{
			if(PlayerInfo[playerid][Bank] < 1) return SendErrorMesssage(playerid, "You don't have any cash to withdraw.");
			if(PlayerTemp[playerid][UsingATM] && PlayerInfo[playerid][Bank] > 50000) return SendErrorMesssage(playerid, "The maximum you can withdraw from an ATM is $50,000.");


			format(atm_str, sizeof(atm_str), "{FFFFFF}BANK STATEMENT - %s @ %s\nOld Balance: {EAEAAE}$%s{FFFFFF}\nWithdraw: {EAEAAE}$%s{FFFFFF}\n\nNew Balance: {3D9140}$0{FFFFFF}",GetRoleplayName(playerid),GetTimeString(),FormatCash(PlayerInfo[playerid][Bank]),FormatCash(PlayerInfo[playerid][Bank]));

			GivePlayerCash(playerid, PlayerInfo[playerid][Bank]);
			format(atm_str, sizeof(atm_str), "[%s] %s(%i) withdraws all ($%i) from bank.", GetServerTimeString(), GetRoleplayName(playerid), playerid, PlayerInfo[playerid][Bank]);
			AddToLog("cash", atm_str);
			PlayerInfo[playerid][Bank] = 0;

			ShowMessage(playerid,"Red County Banking - Withdraw Statement", atm_str, "Ok");
		}
		else if(strcmp("Withdraw HALF",inputtext,true) == 0)
		{
			if(PlayerInfo[playerid][Bank] < 2) return SendErrorMesssage(playerid, "You don't have any cash to withdraw.");
			if(PlayerTemp[playerid][UsingATM] && PlayerInfo[playerid][Bank] > 50000) return SendErrorMesssage(playerid, "The maximum you can withdraw from an ATM is $50,000.");


			new withdraw = PlayerInfo[playerid][Bank] / 2;
			format(atm_str, sizeof(atm_str), "{FFFFFF}BANK STATEMENT - %s @ %s\nOld Balance: {EAEAAE}$%s{FFFFFF}\nWithdraw: {EAEAAE}$%s{FFFFFF}\n\nNew Balance: {3D9140}$%s{FFFFFF}",GetRoleplayName(playerid),GetTimeString(),FormatCash(PlayerInfo[playerid][Bank]),FormatCash(withdraw),FormatCash(PlayerInfo[playerid][Bank]-withdraw));

			GivePlayerCash(playerid, withdraw);
			PlayerInfo[playerid][Bank] -= withdraw;

			ShowMessage(playerid,"Red County Banking - Withdraw Statement", atm_str, "Ok");

			format(atm_str, sizeof(atm_str), "[%s] %s(%i) withdraws half ($%i) from bank.", GetServerTimeString(), GetRoleplayName(playerid), playerid, withdraw);
			AddToLog("cash", atm_str);
		}
	}
	return 1;
}

CMD:atm(playerid, params[])
{
	new atm = IsPlayerNearATM(playerid);
	if(atm == 0) return SendErrorMesssage(playerid,"Ти не си близо до банкомат!");
	OnePlayAnim(playerid, "ped", "ATM", 3.5, 0, 0, 0, 0, 0);
	PlayerTemp[playerid][UsingATM] = true;
	Dialog_Show(playerid,BankMenu,DIALOG_STYLE_LIST,"{3D9140}Red County Banking {FFFFFF}(ATM)","Balance\nWithdraw\nWithdraw ALL\nWithdraw HALF","Select","Cancel");
	return CMD_SUCCESS;
}

CMD:gotocor(playerid, params[])
{
	if (PlayerInfo[playerid][Admin] < 5) return SendNotEnoughAdminMsg(playerid);
	new Float: Coor_X, Float: Coor_Y, Float: Coor_Z;
    if(sscanf(params, "fff", Coor_X, Coor_Y, Coor_Z)) return SendClientMessage(playerid, COLOR_WHITE, "Използвай: /gotocor [x] [y] [z]");
	SendClientMessage(playerid, COLOR_ADMIN, "Ти се телепортира успешно до избраните от теб координати!");
	SetPlayerPos(playerid, Coor_X, Coor_Y, Coor_Z);
    return CMD_SUCCESS;
}

CMD:createveh(playerid, params[])
{
	if (PlayerInfo[playerid][Admin] < 2) return SendNotEnoughAdminMsg(playerid);
	new model, color1, color2;
    if(sscanf(params, "ddd", model, color1, color2)) return SendClientMessage(playerid, COLOR_WHITE, "Използвай: /createveh [model] [color 1] [color 2]");
	if(model < 400 || model > 611)
	{
		SendErrorMesssage(playerid, "Невалидно ID за превозно средство!");
		return 1;
	}
	if(color1 < 0 || color1 > 255)
	{
		SendErrorMesssage(playerid, "Невалиден цвят 1 за превозно средство!");
		return 1;
	}
	if(color2 < 0 || color2 > 255)
	{
		SendErrorMesssage(playerid, "Невалиден цвят 2 за превозно средство!");
		return 1;
	}
	if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0)
	{
		SendErrorMesssage(playerid, "Трябва да си извън интериор и virtual world за да ползваш командата!");
		return 1;
	}
	new Float:fX, Float:fY, Float:fZ, Float:fAngle, vehicleid;
	GetPlayerPos(playerid, fX, fY, fZ);
	GetPlayerFacingAngle(playerid, fAngle);
    vehicleid = CreateVehicle(model, fX, fY, fZ, fAngle, color1, color2, 300);
	TurnEngine(vehicleid, true);
	new cmd_message[128];
	format(cmd_message, sizeof(cmd_message), "Ти създаде ново превозно средство с ID: %d и Model: %d", vehicleid, model);
	SendClientMessage(playerid, COLOR_WHITE, cmd_message);
    return CMD_SUCCESS;
}

CMD:makeadmin(playerid, params[])
{
	new giveplayerid, cmd_message[128], option1;
	if (!IsPlayerAdmin(playerid) && PlayerInfo[playerid][Admin] != 6) return SendNotEnoughAdminMsg(playerid);
	if (sscanf(params, "ud", giveplayerid, option1)) return SendClientMessage(playerid, COLOR_WHITE, "Използвай: /makeadmin [playerid] [level]");
	if (giveplayerid == INVALID_PLAYER_ID || !IsPlayerConnected(giveplayerid)) return SendMessageNotValidPlayer(playerid);
	if (option1 < 1 || option1 > 6) return SendErrorMesssage(playerid, "Трябва да въведете ниво на администратор между 1 и 6");
	PlayerInfo[giveplayerid][Admin] = option1;
	format(cmd_message, sizeof(cmd_message), "Поздравления на %s! Той беше назначен от %s за %s(%d)",GetName(giveplayerid), GetName(playerid),
		GetAdminName(option1), option1);
	SendClientMessageToAll(COLOR_ADMIN, cmd_message);
    return CMD_SUCCESS;
}

CMD:help(playerid, params[])
{
	if(isnull(params))
	{
		SendClientMessage(playerid, COLOR_LIGHTGREEN, "New Reality Roleplay Help - Usage: /Help [Section]");
		SendClientMessage(playerid, COLOR_WHITE, "Sections: General, Chats, Faction, Bizz, House, Motel, Furniture, Vehicle, Job, Fish, Phone, Crate, Donator, Bank, Helper");
		return true;
	}

	if(strcmp("General", params, true) == 0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"General Commands: /kill /me /do /pay /report /animlist /enter /exit /admins /ip /time (/afk /back /isafk) /advert /buyclothes /stats /give");
		SendClientMessage(playerid,COLOR_YELLOW,"/buylevel /eject /buy /buyfood /bank /writenote /inventory /useammo /drink /buyticket /bet /buyweaponskill /achievements /viewdonators");
		SendClientMessage(playerid,COLOR_YELLOW,"/pm  /forum /padvert /sell /cancelsell /phoneinfo /speedo /attempt /showkeys /ame /fshake /appearance /version(/uptime)");
		SendClientMessage(playerid,COLOR_YELLOW,"/describe /togshoutanim /age /shake /kiss /factiononline /changespawn /helpers /myadminrecord /boombox /boomboxid");
		SendClientMessage(playerid,COLOR_YELLOW,"/assistance /cancelassistance /canceltaxi /frisk /lastonline /masteraccount(/ma) /characters");
	}
	return CMD_SUCCESS;
}

CMD:getid(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE ,"Използвай: /getid [part/full name of player]");
	if(strlen(params) < 3) return SendErrorMesssage(playerid, "Имената са от поне 3 символа!");

	new cmd_message[128];
	new count = 0;
	foreach (Player, i)
	{
		if(strfind(GetName(i), params, true) != -1)
		{
			count ++;
			format(cmd_message, sizeof(cmd_message), "%s - ID %i", GetName(i), i);
			SendClientMessage(playerid, COLOR_WHITE, cmd_message);
		}
	}
	if(count == 0) SendClientMessage(playerid, COLOR_GRAY, "Няма открити играчи с това име!");
	return true;
}
CMD:id(playerid, params[]) return cmd_getid(playerid, params);

CMD:kill(playerid, params[])
{
	SetPlayerHealthEx(playerid, 0.0);
	SetPlayerArmourEx(playerid, 0.0);
	SetPlayerChatBubble(playerid, "(( Player used /kill ))", COLOR_ORANGE, 15.0, 5000);
	new cmd_message[128];
	format(cmd_message, sizeof(cmd_message),"[Death] %s has used /kill", GetName(playerid));
	SendAdminsMessage(1, COLOR_ADMIN, cmd_message);
	return CMD_SUCCESS;
}

CMD:me(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Използвай: /me [action]");
	new Float:radius = 5.0, cmd_message[128];
	format(cmd_message, sizeof(cmd_message),"%s %s", GetRoleplayName(playerid), params);
	ProxDetector(radius, playerid, cmd_message, COLOR_EMOTE, COLOR_EMOTE, COLOR_EMOTE, COLOR_EMOTE, COLOR_EMOTE);
	return true;
}

CMD:do(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_WHITE, "Използвай: /do [action]");
	new Float:radius = 5.0, cmd_message[128];
	format(cmd_message, sizeof(cmd_message), "%s ((%s))", params, GetRoleplayName(playerid));
	ProxDetector(radius, playerid, cmd_message, COLOR_EMOTE, COLOR_EMOTE, COLOR_EMOTE, COLOR_EMOTE, COLOR_EMOTE);
	return true;
}