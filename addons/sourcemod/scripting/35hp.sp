#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>
#include <store>

#pragma newdecls required
#pragma tabsize 0

int hpeventi, m_flNextSecondaryAttack = -1;

Handle hCvarPluginEnabled, bCvarPluginEnabled;

ConVar g_T_Kredi_Miktari, g_CT_Kredi_Miktari, g_Prefix, g_Tkrediver, g_CTkrediver;

char T_Kredi_Miktari[1024], CT_Kredi_Miktari[1024], text_prefix[64];

public Plugin myinfo = 
{
	name = "35hp Random Event", 
	author = "ByDexter", 
	description = "35hp haritalarında rastgele event yapar", 
	version = "1.1b", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("35hpevent.phrases.txt");
	RegAdminCmd("sm_hpwinner2", turwinkredisit, ADMFLAG_ROOT, "KULLANMAYIN! MILLETE KREDI ATAR / DONT USE!");
	RegAdminCmd("sm_hpwinner3", turwinkredisict, ADMFLAG_ROOT, "KULLANMAYIN! MILLETE KREDI ATAR / DONT USE!");
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	HookConVarChange(hCvarPluginEnabled = CreateConVar("sm_norecoil_enable", "0", "NoRecoil enabled", FCVAR_NOTIFY, true, 0.0, true, 1.0), OnConVarChanged);
	HookConVarChange(bCvarPluginEnabled = CreateConVar("sm_bunny_enable", "0", "Bunny enabled", FCVAR_NOTIFY, true, 0.0, true, 1.0), OnConVarChanged);
	g_Prefix = CreateConVar("35hp_prefix", "ByDexter", "PLUGIN PREFIX", FCVAR_NOTIFY);
	g_Tkrediver = CreateConVar("twin_credit_enable", "1", "T Give Credit Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_CTkrediver = CreateConVar("ctwin_credit_enable", "1", "CT Give Credit Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_T_Kredi_Miktari = CreateConVar("twin_credit", "20", "T WIN CREDIT", FCVAR_NOTIFY, true, 0.0, false);
	g_CT_Kredi_Miktari = CreateConVar("ctwin_credit", "20", "CT WIN CREDIT", FCVAR_NOTIFY, true, 0.0, false);
	AutoExecConfig(true, "35hp.event", "sourcemod");
}

public void OnMapStart()
{
	SetCvar("mp_freezetime", 3);
}

public void OnConfigsExecuted()
{
	g_Prefix.GetString(text_prefix, sizeof(text_prefix));
}

public Action turwinkredisit(int client, int args)
{
	if (g_Tkrediver.BoolValue)
	{
		g_T_Kredi_Miktari.GetString(T_Kredi_Miktari, sizeof(T_Kredi_Miktari));
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Twinprint", T_Kredi_Miktari);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && !IsFakeClient(i))
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + g_T_Kredi_Miktari.IntValue);
			}
		}
	}
}

public Action turwinkredisict(int client, int args)
{
	if (g_CTkrediver.BoolValue)
	{
		g_CT_Kredi_Miktari.GetString(CT_Kredi_Miktari, sizeof(CT_Kredi_Miktari));
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "CTwinprint", CT_Kredi_Miktari);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_CT && !IsFakeClient(i))
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + g_CT_Kredi_Miktari.IntValue);
			}
		}
	}
}

public Action OnPreThink(int client)
{
	SetNoScope(GetPlayerWeaponSlot(client, 0));
}

public void OnConVarChanged(Handle hConvar, const char[] chOldValue, const char[] chNewValue)
{
	UpdateConVars();
}

public void UpdateConVars()
{
	if (GetConVarBool(hCvarPluginEnabled))
	{
		SetConVarInt(FindConVar("weapon_accuracy_nospread"), 1);
		SetConVarInt(FindConVar("weapon_recoil_cooldown"), 0);
		SetConVarInt(FindConVar("weapon_recoil_decay1_exp"), 99999);
		SetConVarInt(FindConVar("weapon_recoil_decay2_exp"), 99999);
		SetConVarInt(FindConVar("weapon_recoil_decay2_lin"), 99999);
		SetConVarInt(FindConVar("weapon_recoil_scale"), 0);
		SetConVarInt(FindConVar("weapon_recoil_suppression_shots"), 500);
	}
	else
	{
		SetConVarInt(FindConVar("weapon_accuracy_nospread"), 0);
		SetConVarFloat(FindConVar("weapon_recoil_cooldown"), 0.55);
		SetConVarFloat(FindConVar("weapon_recoil_decay1_exp"), 3.5);
		SetConVarInt(FindConVar("weapon_recoil_decay2_exp"), 8);
		SetConVarInt(FindConVar("weapon_recoil_decay2_lin"), 18);
		SetConVarInt(FindConVar("weapon_recoil_scale"), 2);
		SetConVarInt(FindConVar("weapon_recoil_suppression_shots"), 4);
	}
	if (GetConVarBool(bCvarPluginEnabled))
	{
		SetConVarInt(FindConVar("sv_enablebunnyhopping"), 1);
		SetConVarInt(FindConVar("sv_autobunnyhopping"), 1);
		SetConVarInt(FindConVar("sv_airaccelerate"), 2000);
		SetConVarInt(FindConVar("sv_staminajumpcost"), 0);
		SetConVarInt(FindConVar("sv_staminalandcost"), 0);
		SetConVarInt(FindConVar("sv_staminamax"), 0);
	}
	else
	{
		SetConVarInt(FindConVar("sv_enablebunnyhopping"), 0);
		SetConVarInt(FindConVar("sv_autobunnyhopping"), 0);
		SetConVarInt(FindConVar("sv_airaccelerate"), 101);
		SetConVarFloat(FindConVar("sv_staminajumpcost"), 0.080);
		SetConVarFloat(FindConVar("sv_staminalandcost"), 0.050);
		SetConVarInt(FindConVar("sv_staminamax"), 80);
	}
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i) && !IsPlayerAlive(i))
	{
		if (!GetEntProp(i, Prop_Send, "m_iHealth", 35))
			SetEntProp(i, Prop_Send, "m_iHealth", 35);
		SilahlariSil(i);
	}
	CreateTimer(3.0, Basla, _, TIMER_FLAG_NO_MAPCHANGE);
	hpeventi = 0;
	hpeventi = GetRandomInt(1, 12);
	if (hpeventi == 1)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "SSGprint");
	}
	else if (hpeventi == 2)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Bhopprint");
	}
	else if (hpeventi == 3)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Spaceprint");
	}
	else if (hpeventi == 4)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Speedprint");
	}
	else if (hpeventi == 5)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Negevprint");
	}
	else if (hpeventi == 6)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Glockprint");
	}
	else if (hpeventi == 7)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Deagleprint");
	}
	else if (hpeventi == 8)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Dberettaprint");
	}
	else if (hpeventi == 9)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Awpprint");
	}
	else if (hpeventi == 10)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Normalprint");
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Codder");
	}
	else if (hpeventi == 11)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Taserprint");
	}
	else if (hpeventi == 12)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Shotgunprint");
	}
}

public Action Basla(Handle timer, any data)
{
	CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Goround");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (hpeventi == 1)
			{
				GivePlayerItem(i, "weapon_mag7");
				SetCvar("sv_infinite_ammo", 2);
				SetCvar("sm_bunny_enable", 1);
			}
			else if (hpeventi == 2)
			{
				GivePlayerItem(i, "weapon_usp_silencer");
				SetCvar("sv_infinite_ammo", 2);
				SetCvar("mp_damage_headshot_only", 1);
			}
			else if (hpeventi == 3)
			{
				GivePlayerItem(i, "weapon_negev");
				SetCvar("sv_infinite_ammo", 2);
				SetCvar("sm_norecoil_enable", 1);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 2.4);
			}
			else if (hpeventi == 4)
			{
				GivePlayerItem(i, "weapon_ssg08");
				SetCvar("sv_infinite_ammo", 2);
				SetCvar("sm_norecoil_enable", 1);
			}
			else if (hpeventi == 5)
			{
				GivePlayerItem(i, "weapon_ak47");
				SetCvar("sv_infinite_ammo", 2);
				SetEntProp(i, Prop_Send, "m_iHealth", 100);
			}
			else if (hpeventi == 6)
			{
				GivePlayerItem(i, "weapon_deagle");
				SetCvar("sv_infinite_ammo", 2);
			}
			else if (hpeventi == 7)
			{
				GivePlayerItem(i, "weapon_scar20");
				SetCvar("sv_infinite_ammo", 2);
				SDKHook(i, SDKHook_PreThink, OnPreThink);
			}
			else if (hpeventi == 8)
			{
				GivePlayerItem(i, "weapon_elite");
				SetCvar("sv_infinite_ammo", 2);
			}
			else if (hpeventi == 9)
			{
				GivePlayerItem(i, "weapon_awp");
				SetCvar("sv_infinite_ammo", 2);
				SetCvar("sm_norecoil_enable", 1)
			}
			else if (hpeventi == 10)
			{
				GivePlayerItem(i, "weapon_knife");
			}
			else if (hpeventi == 11)
			{
				GivePlayerItem(i, "weapon_taser");
				SetCvar("sv_infinite_ammo", 1);
			}
			else if (hpeventi == 12)
			{
				GivePlayerItem(i, "weapon_nova");
				SetCvar("sv_infinite_ammo", 2);
				SetCvar("sv_gravity", 350);
				SetEntProp(i, Prop_Send, "m_iHealth", 500);
			}
		}
	}
}

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SDKUnhook(i, SDKHook_PreThink, OnPreThink);
		}
	}
	if (GetConVarInt(FindConVar("sm_norecoil_enable"))  != 0)
		SetCvar("sm_norecoil_enable", 0);
	if (GetConVarInt(FindConVar("sm_norecoil_enable")) != 0)
		SetCvar("sv_infinite_ammo", 0);
	if (GetConVarInt(FindConVar("sm_norecoil_enable")) != 800)
		SetCvar("sv_gravity", 800);
	if (GetConVarInt(FindConVar("sm_bunny_enable")) != 0)
		SetCvar("sm_bunny_enable", 0);
	if (GetConVarInt(FindConVar("mp_damage_headshot_only")) != 0)
		SetCvar("mp_damage_headshot_only", 0);
	if (GetConVarInt(FindConVar("mp_freezetime")) != 3)
		SetCvar("mp_freezetime", 3);
	int WinningTeam = GetEventInt(event, "winner");
	ServerCommand("sm_hpwinner%d", WinningTeam);
}
/*
	void
*/
void SetNoScope(int weapon)
{
	if (IsValidEdict(weapon))
	{
		char classname[MAX_NAME_LENGTH];
		if (GetEdictClassname(weapon, classname, sizeof(classname))
			 || StrEqual(classname[7], "ssg08") || StrEqual(classname[7], "aug")
			 || StrEqual(classname[7], "sg550") || StrEqual(classname[7], "sg552")
			 || StrEqual(classname[7], "sg556") || StrEqual(classname[7], "awp")
			 || StrEqual(classname[7], "scar20") || StrEqual(classname[7], "g3sg1"))
		{
			SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
		}
	}
}
void SetCvar(char cvarName[64], int value)
{
	Handle IntCvar = FindConVar(cvarName);
	if (IntCvar)
	{
		int flags = GetConVarFlags(IntCvar);
		flags &= ~FCVAR_NOTIFY;
		SetConVarFlags(IntCvar, flags);
		SetConVarInt(IntCvar, value, false, false);
		flags |= FCVAR_NOTIFY;
		SetConVarFlags(IntCvar, flags);
	}
}
void SilahlariSil(int client)
{
	for (int j = 0; j < 5; j++)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
	}
}
/*
	35 HP Map Control
*/
public void OnAutoConfigsBuffered()
{
	CreateTimer(3.0, thirtyfivehpcontrol);
}

public Action thirtyfivehpcontrol(Handle timer)
{
	char filename[512];
	GetPluginFilename(INVALID_HANDLE, filename, sizeof(filename));
	char mapname[PLATFORM_MAX_PATH];
	GetCurrentMap(mapname, sizeof(mapname));
	if (StrContains(mapname, "35hp_", false) == -1)
	{
		ServerCommand("sm plugins unload %s", filename);
	}
	return Plugin_Stop;
}
