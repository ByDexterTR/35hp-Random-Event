public Action Vampire_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (IsValidClient(client))
	{
		SetEntityHealth(client, GetClientHealth(client) + 10);
	}
}