#define MAX_WEAPONS				48

stock int Client_RemoveAllWeapons(int client, const char[] exclude = "", bool clearAmmo = false)
{
	int offset = Client_GetWeaponsOffset(client) - 4;
	
	int numWeaponsRemoved = 0;
	for (int i = 0; i < MAX_WEAPONS; i++) {
		offset += 4;
		
		int weapon = GetEntDataEnt2(client, offset);
		
		if (!Weapon_IsValid(weapon)) {
			continue;
		}
		
		if (exclude[0] != '\0' && Entity_ClassNameMatches(weapon, exclude)) {
			Client_SetActiveWeapon(client, weapon);
			continue;
		}
		
		if (clearAmmo) {
			Client_SetWeaponPlayerAmmoEx(client, weapon, 0, 0);
		}
		
		if (RemovePlayerItem(client, weapon)) {
			Entity_Kill(weapon);
		}
		
		numWeaponsRemoved++;
	}
	
	return numWeaponsRemoved;
}

stock bool Entity_IsPlayer(int entity)
{
	if (entity < 1 || entity > MaxClients) {
		return false;
	}

	return true;
}

stock bool Entity_Kill(int kenny, bool killChildren=false)
{
	if (Entity_IsPlayer(kenny)) {
		// Oh My God! They Killed Kenny!!
		ForcePlayerSuicide(kenny);
		return true;
	}

	if(killChildren){
		return AcceptEntityInput(kenny, "KillHierarchy");
	}
	else {
		return AcceptEntityInput(kenny, "Kill");
	}
}

stock bool Weapon_IsValid(int weapon)
{
	if (!IsValidEdict(weapon)) {
		return false;
	}
	return Entity_ClassNameMatches(weapon, "weapon_", true);
}

stock int Weapon_GetPrimaryAmmoType(int weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");
}

stock int Weapon_GetSecondaryAmmoType(int weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iSecondaryAmmoType");
}

stock int Entity_GetClassName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);
}

stock bool Entity_ClassNameMatches(int entity, const char[] className, bool partialMatch = false)
{
	char entity_className[64];
	Entity_GetClassName(entity, entity_className, sizeof(entity_className));
	
	if (partialMatch) {
		return (StrContains(entity_className, className) != -1);
	}
	
	return StrEqual(entity_className, className);
}

stock void Client_SetWeaponPlayerAmmoEx(int client, int weapon, int primaryAmmo = -1, int secondaryAmmo = -1)
{
	int offset_ammo = FindDataMapInfo(client, "m_iAmmo");
	
	if (primaryAmmo != -1) {
		int offset = offset_ammo + (Weapon_GetPrimaryAmmoType(weapon) * 4);
		SetEntData(client, offset, primaryAmmo, 4, true);
	}
	
	if (secondaryAmmo != -1) {
		int offset = offset_ammo + (Weapon_GetSecondaryAmmoType(weapon) * 4);
		SetEntData(client, offset, secondaryAmmo, 4, true);
	}
}

stock void Client_SetActiveWeapon(int client, int weapon)
{
	SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", weapon);
	ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
}

stock int Client_GetWeaponsOffset(int client)
{
	static int offset = -1;
	
	if (offset == -1) {
		offset = FindDataMapInfo(client, "m_hMyWeapons");
	}
	
	return offset;
}