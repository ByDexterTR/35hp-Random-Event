public Action Snowball_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	damage = 10000000.0;
	return Plugin_Changed;
}

public Action Snowball_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client))
	{
		CreateTimer(0.3, kartopuver, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action kartopuver(Handle timer, int client)
{
	GivePlayerItem(client, "weapon_snowball");
	RemovePlayerItem(client, GivePlayerItem(client, "weapon_awp"));
	FakeClientCommand(client, "use weapon_snowball");
	return Plugin_Stop;
}