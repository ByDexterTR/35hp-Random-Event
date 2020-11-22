#define CS_TEAM_T 			2
#define CS_TEAM_CT			3

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (Block_scope && IsValidClient(client))
	{
		buttons &= ~IN_ATTACK2;
	}
	return Plugin_Continue;
}

stock void BlockEntity(int client, int cachedOffset)
{
	SetEntData(client, cachedOffset, 5, 4, true);
}

stock void UnblockEntity(int client, int cachedOffset)
{
	SetEntData(client, cachedOffset, 2, 4, true);
}

stock bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

stock void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

stock void SetCvarFloat(char[] cvarName, float value)
{
	ConVar FloatCvar = FindConVar(cvarName);
	if (FloatCvar == null)return;
	int flags = FloatCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
	FloatCvar.FloatValue = value;
	flags |= FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
}

stock void Client_ClearWeapon(int client)
{
	for (int j = 0; j < 12; j++)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
	}
}

stock int GivePlayerItemAmmo(int client, const char[] weapon, int clip = -1, int ammo = -1)
{
	int weaponEnt = GivePlayerItem(client, weapon);
	SetPlayerWeaponAmmo(client, weaponEnt, clip, ammo);
	return weaponEnt;
}

stock void SetPlayerWeaponAmmo(int client, int weaponEnt, int clip = -1, int ammo = -1)
{
	if (weaponEnt == INVALID_ENT_REFERENCE || !IsValidEdict(weaponEnt))
		return;
	if (clip != -1)
		SetEntProp(weaponEnt, Prop_Data, "m_iClip1", clip);
	if (ammo != -1)
	{
		SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
		SetEntProp(weaponEnt, Prop_Send, "m_iSecondaryReserveAmmoCount", ammo);
	}
} 