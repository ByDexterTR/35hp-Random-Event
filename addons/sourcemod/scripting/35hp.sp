#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>
#include <store>
#include <smlib>

#pragma semicolon 1
#pragma newdecls required

#include "files/Globals.sp"
#include "files/Stocks.sp"
#include "files/Snowball.sp"
#include "files/Oitc.sp"
#include "files/PistolZoom.sp"

/* 
 * Thanks for the translation
 *
 * Tr & En - @me
 * Ru - github.com/Blueberryy / steamcommunity.com/id/ingmodsince2008/
 *
*/

public Plugin myinfo = 
{
	name = "35hp Random Event", 
	author = "ByDexter", 
	description = "35hp haritalarında rastgele event yapar", 
	version = "1.4b - OITC Fix", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("35hpevent.phrases.txt");
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	
	g_Offset_CollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_Offset_CollisionGroup == -1)
	{
		SetFailState("Unable to find offset for collision groups.");
	}
	
	g_NoRecoil = CreateConVar("sm_norecoil_enable", "0", "NoRecoil enabled", FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	g_NoRecoil.AddChangeHook(ConVarChanged);
	g_Bhop = CreateConVar("sm_bunny_enable", "0", "Bunny enabled", FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	g_Bhop.AddChangeHook(ConVarChanged);
	
	g_Prefix = CreateConVar("35hp_prefix", "ByDexter", "PLUGIN PREFIX", FCVAR_NOTIFY);
	g_Tkrediver = CreateConVar("twin_credit_enable", "0", "T Give Credit Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_CTkrediver = CreateConVar("ctwin_credit_enable", "0", "CT Give Credit Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	g_T_Kredi_Miktari = CreateConVar("twin_credit", "20", "T WIN CREDIT", FCVAR_NOTIFY, true, 0.0, false);
	g_CT_Kredi_Miktari = CreateConVar("ctwin_credit", "20", "CT WIN CREDIT", FCVAR_NOTIFY, true, 0.0, false);
	
	AutoExecConfig(true, "35hp", "ByDexter");
}

public void OnMapStart()
{
	char mapname[512];
	GetCurrentMap(mapname, sizeof(mapname));
	if (StrContains(mapname, "35hp_", false) == -1)
	{
		SetFailState("This 35hp event plugin only works on \"35hp_\" maps");
	}
	SetCvar("mp_freezetime", 3);
}

public void ConVarChanged(ConVar cvar, const char[] oldVal, const char[] newVal)
{
	if (cvar == g_NoRecoil)
	{
		if (g_NoRecoil.BoolValue)
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
	}
	if (cvar == g_Bhop)
	{
		if (g_Bhop.BoolValue)
		{
			SetConVarInt(FindConVar("sv_enablebunnyhopping"), 1);
			SetConVarInt(FindConVar("sv_autobunnyhopping"), 1);
			SetCvar("sv_airaccelerate", 2000);
			SetConVarInt(FindConVar("sv_staminajumpcost"), 0);
			SetConVarInt(FindConVar("sv_staminalandcost"), 0);
			SetConVarInt(FindConVar("sv_staminamax"), 0);
			SetConVarInt(FindConVar("sv_staminarecoveryrate"), 60);
		}
		else
		{
			SetConVarInt(FindConVar("sv_enablebunnyhopping"), 0);
			SetConVarInt(FindConVar("sv_autobunnyhopping"), 0);
			SetCvar("sv_airaccelerate", 101);
			SetConVarFloat(FindConVar("sv_staminajumpcost"), 0.080);
			SetConVarFloat(FindConVar("sv_staminalandcost"), 0.050);
			SetConVarInt(FindConVar("sv_staminamax"), 80);
			SetConVarInt(FindConVar("sv_staminarecoveryrate"), 60);
		}
	}
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			UnblockEntity(i, g_Offset_CollisionGroup);
			SetEntityHealth(i, 35);
			SilahlariSil(i);
		}
	}
	CreateTimer(3.0, Basla, _, TIMER_FLAG_NO_MAPCHANGE);
	hpeventi = GetRandomInt(1, 19);
	char text_prefix[64];
	g_Prefix.GetString(text_prefix, sizeof(text_prefix));
	if (hpeventi == 1)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_bunny_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "SSGprint");
	}
	else if (hpeventi == 2)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("mp_damage_headshot_only", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Bhopprint");
	}
	else if (hpeventi == 3)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_norecoil_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Spaceprint");
	}
	else if (hpeventi == 4)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_norecoil_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Speedprint");
	}
	else if (hpeventi == 5)
	{
		SetCvar("sv_infinite_ammo", 2);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Negevprint");
	}
	else if (hpeventi == 6)
	{
		SetCvar("sv_infinite_ammo", 2);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Glockprint");
	}
	else if (hpeventi == 7)
	{
		SetCvar("sv_infinite_ammo", 2);
		Block_scope = true;
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Deagleprint");
	}
	else if (hpeventi == 8)
	{
		SetCvar("sv_infinite_ammo", 2);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Dberettaprint");
	}
	else if (hpeventi == 9)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_norecoil_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Awpprint");
	}
	else if (hpeventi == 10)
	{
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Normalprint");
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Codder");
	}
	else if (hpeventi == 11)
	{
		SetCvar("sv_infinite_ammo", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Taserprint");
	}
	else if (hpeventi == 12)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sv_gravity", 350);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Shotgunprint");
	}
	else if (hpeventi == 13)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_norecoil_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Cz75print");
	}
	else if (hpeventi == 14)
	{
		SetCvar("sm_bunny_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Tavsanprint");
	}
	else if (hpeventi == 15)
	{
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_norecoil_enable", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Mac10print");
	}
	else if (hpeventi == 16)
	{
		SetCvar("sv_infinite_ammo", 2);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "P90print");
	}
	else if (hpeventi == 17)
	{
		HookEvent("weapon_fire", Snowball_WeaponFire);
		SetCvar("sv_infinite_ammo", 0);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Snowballprint");
	}
	else if (hpeventi == 18)
	{
		HookEvent("weapon_fire", Oitc_WeapnFire);
		HookEvent("player_death", Oitc_PlayerDeath);
		SetCvar("sv_infinite_ammo", 0);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Oitcprint");
	}
	else if (hpeventi == 19)
	{
		HookEvent("weapon_fire", Pistolzoom_WeaponFire);
		HookEvent("player_death", Pistolzoom_PlayerDeath);
		SetCvar("sv_infinite_ammo", 1);
		CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Pistolzoomprint");
	}
}

public Action Basla(Handle timer, any data)
{
	char text_prefix[64];
	g_Prefix.GetString(text_prefix, sizeof(text_prefix));
	CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Goround");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			SilahlariSil(i);
			if (hpeventi == 1)
			{
				GivePlayerItem(i, "weapon_mag7");
			}
			else if (hpeventi == 2)
			{
				GivePlayerItem(i, "weapon_usp_silencer");
			}
			else if (hpeventi == 3)
			{
				GivePlayerItem(i, "weapon_negev");
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 2.8);
			}
			else if (hpeventi == 4)
			{
				GivePlayerItem(i, "weapon_ssg08");
			}
			else if (hpeventi == 5)
			{
				GivePlayerItem(i, "weapon_ak47");
				SetEntityHealth(i, 100);
			}
			else if (hpeventi == 6)
			{
				GivePlayerItem(i, "weapon_deagle");
			}
			else if (hpeventi == 7)
			{
				GivePlayerItem(i, "weapon_scar20");
			}
			else if (hpeventi == 8)
			{
				GivePlayerItem(i, "weapon_elite");
			}
			else if (hpeventi == 9)
			{
				GivePlayerItem(i, "weapon_awp");
				GivePlayerItem(i, "weapon_knife");
			}
			else if (hpeventi == 10)
			{
				GivePlayerItem(i, "weapon_knife");
			}
			else if (hpeventi == 11)
			{
				GivePlayerItem(i, "weapon_taser");
			}
			else if (hpeventi == 12)
			{
				GivePlayerItem(i, "weapon_nova");
				SetEntityHealth(i, 500);
			}
			else if (hpeventi == 13)
			{
				GivePlayerItem(i, "weapon_cz75a");
			}
			else if (hpeventi == 14)
			{
				GivePlayerItem(i, "weapon_knife");
			}
			else if (hpeventi == 15)
			{
				GivePlayerItem(i, "weapon_mac10");
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 2.3);
			}
			else if (hpeventi == 16)
			{
				GivePlayerItem(i, "weapon_p90");
			}
			else if (hpeventi == 17)
			{
				BlockEntity(i, g_Offset_CollisionGroup);
				GivePlayerItem(i, "weapon_snowball");
				SDKHook(i, SDKHook_OnTakeDamage, Snowball_OnTakeDamage);
			}
			else if (hpeventi == 18)
			{
				GivePlayerWeaponAndAmmo(i, "weapon_deagle", 1, 0);
				SetEntityHealth(i, 10);
			}
			else if (hpeventi == 19)
			{
				GivePlayerItem(i, "weapon_tec9");
			}
		}
	}
	return Plugin_Stop;
}

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			SDKUnhook(i, SDKHook_OnTakeDamage, Snowball_OnTakeDamage);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SetEntProp(i, Prop_Send, "m_iFOV", 90);
			SetEntProp(i, Prop_Send, "m_iDefaultFOV", 90);
		}
	}
	if (Block_scope)Block_scope = false;
	if (GetConVarInt(FindConVar("sm_norecoil_enable")) != 0)SetCvar("sm_norecoil_enable", 0);
	if (GetConVarInt(FindConVar("sv_infinite_ammo")) != 0)SetCvar("sv_infinite_ammo", 0);
	if (GetConVarInt(FindConVar("sv_gravity")) != 800)SetCvar("sv_gravity", 800);
	if (GetConVarInt(FindConVar("sm_bunny_enable")) != 0)SetCvar("sm_bunny_enable", 0);
	if (GetConVarInt(FindConVar("mp_damage_headshot_only")) != 0)SetCvar("mp_damage_headshot_only", 0);
	if (GetConVarInt(FindConVar("mp_freezetime")) != 3)SetCvar("mp_freezetime", 3);
	if (hpeventi == 17) { UnhookEvent("weapon_fire", Snowball_WeaponFire); }
	if (hpeventi == 18) { UnhookEvent("weapon_fire", Oitc_WeapnFire); UnhookEvent("player_death", Oitc_PlayerDeath); }
	if (hpeventi == 19) { UnhookEvent("weapon_fire", Pistolzoom_WeaponFire); UnhookEvent("player_death", Pistolzoom_PlayerDeath); }
	if (g_CTkrediver.BoolValue || g_Tkrediver.BoolValue)
	{
		int WinningTeam = GetEventInt(event, "winner");
		if (WinningTeam == 2)
		{
			char text_prefix[64];
			g_Prefix.GetString(text_prefix, sizeof(text_prefix));
			CPrintToChatAll("{orchid}[%s] %t", text_prefix, "Twinprint", g_T_Kredi_Miktari.IntValue);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && GetClientTeam(i) == CS_TEAM_T)
				{
					Store_SetClientCredits(i, Store_GetClientCredits(i) + g_T_Kredi_Miktari.IntValue);
				}
			}
		}
		else if (WinningTeam == 3)
		{
			char text_prefix[64];
			g_Prefix.GetString(text_prefix, sizeof(text_prefix));
			CPrintToChatAll("{orchid}[%s] %t", text_prefix, "CTwinprint", g_CT_Kredi_Miktari.IntValue);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && GetClientTeam(i) == CS_TEAM_CT)
				{
					Store_SetClientCredits(i, Store_GetClientCredits(i) + g_CT_Kredi_Miktari.IntValue);
				}
			}
		}
	}
} 