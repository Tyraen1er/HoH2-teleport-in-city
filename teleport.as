namespace TeleportInCity
{
	bool registeredCommands = false;

	[Hook]
	void BaseGameModeConstructor(BaseGameMode@ baseGameMode)
	{
		if (!registeredCommands)
		{
			AddFunction("mypos", GetMyPosition);
			AddFunction("my_pos", GetMyPosition);
			registeredCommands = true;
		}
	}

	void GetMyPosition()
	{
		auto player = GetLocalPlayer();
		if (player is null)
		{
			print("Error: Player not found. Make sure you are loaded in a level/city.");
			return;
		}
		vec3 pos = player.m_unit.GetPosition();
		print("Character Coordinates -> X: " + pos.x + ", Y: " + pos.y + ", Z: " + pos.z);
	}

	[Hook]
	void GameModePostStart(AGameplayGameMode@ aGameplayGameMode)
	{
		if (g_inTown)
		{
			SpawnWaygates();
		}
	}

	void SpawnWaygates()
	{
		auto prod = Resources::GetUnitProducer("doodads/doors/teleport_beacon.unit");
		if (prod is null)
		{
			print("[TeleportInCity] Error: teleport_beacon.unit producer not found!");
			return;
		}

		array<vec2> portalCoords = {
			vec2(-771, -603),
			vec2(655, 327),
			vec2(-556, 257),
			vec2(-941, 407),
			vec2(-1168, 675),
			vec2(-834, -218)
		};

		print("[TeleportInCity] Spawning " + portalCoords.length() + " waygates in the city...");

		for (uint i = 0; i < portalCoords.length(); i++)
		{
			auto unit = prod.Produce(g_scene, xyz(portalCoords[i]));
			auto beacon = cast<TeleportBeacon>(unit.GetScriptBehavior());
			if (beacon !is null)
			{
				beacon.Reveal();
				beacon.NetActivate();
			}
		}
	}
}
