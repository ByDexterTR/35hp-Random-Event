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

void SilahlariSil(int client)
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

stock int GivePlayerWeaponAndAmmo(int client, char[] weapon, int clip = -1, int ammo = -1)
{
	int weaponEnt = GivePlayerItem(client, weapon);
	if (weaponEnt != -1)
	{
		if (clip != -1)
			SetEntProp(weaponEnt, Prop_Send, "m_iClip1", clip);
		if (ammo != -1)
		{
			int iOffset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weaponEnt, Prop_Data, "m_iPrimaryAmmoType") * 4);
			SetEntData(client, iOffset, ammo, 4, true);
			if (GetEngineVersion() == Engine_CSGO)
			{
				SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
			}
		}
	}
	return weaponEnt;
} 