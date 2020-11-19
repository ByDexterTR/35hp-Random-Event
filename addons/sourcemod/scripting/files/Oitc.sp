public Action Oitc_WeapnFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char weaponname[64];
	event.GetString("weapon", weaponname, sizeof(weaponname));
	if (IsValidClient(client) && StrEqual(weaponname, "weapon_deagle"))
	{
		Client_RemoveAllWeapons(client);
		EquipPlayerWeapon(client, GivePlayerItem(client, "weapon_knife"));
	}
}

public Action Oitc_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (IsValidClient(client))
	{
		Client_RemoveAllWeapons(client);
		EquipPlayerWeapon(client, GivePlayerWeaponAndAmmo(client, "weapon_deagle", 1, 0));
	}
}