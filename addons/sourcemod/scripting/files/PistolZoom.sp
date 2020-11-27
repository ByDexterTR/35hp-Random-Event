int PlayerZoomLevel[MAXPLAYERS] = 90;

public Action Pistolzoom_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client))
	{
		PlayerZoomLevel[client] -= 10;
		if (PlayerZoomLevel[client] < 10)
			PlayerZoomLevel[client] = 10;
		SetEntProp(client, Prop_Send, "m_iFOV", PlayerZoomLevel[client]);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", PlayerZoomLevel[client]);
	}
}

public Action Pistolzoom_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (IsValidClient(client))
	{
		PlayerZoomLevel[client] = 90;
		SetEntProp(client, Prop_Send, "m_iFOV", PlayerZoomLevel[client]);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", PlayerZoomLevel[client]);
	}
} 