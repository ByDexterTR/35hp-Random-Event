public Action Oitc_WeapnFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char weaponname[64];
	event.GetString("weapon", weaponname, sizeof(weaponname));
	if (IsValidClient(client) && StrEqual(weaponname, "weapon_deagle"))
	{
		CreateTimer(0.3, Sifirla, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Sifirla(Handle timer, int client)
{
	Client_ClearWeapon(client);
	EquipPlayerWeapon(client, GivePlayerItem(client, "weapon_knife"));
	return Plugin_Stop;
}

public Action Oitc_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (IsValidClient(client))
	{
		CreateTimer(0.4, Ver, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Ver(Handle timer, int client)
{
	Client_ClearWeapon(client);
	EquipPlayerWeapon(client, GivePlayerItemAmmo(client, "weapon_deagle", 1, 0));
	return Plugin_Stop;
}
