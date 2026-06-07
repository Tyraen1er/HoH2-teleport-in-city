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

	int waygateCheckTime = 0;

	[Hook]
	void GameModeUpdate(BaseGameMode@ gm, int ms, GameInput& gameInput, MenuInput& menuInput)
	{
		if (!g_inTown)
			return;

		waygateCheckTime += ms;
		if (waygateCheckTime >= 500)
		{
			waygateCheckTime = 0;

			auto allBeacons = g_scene.FetchAllUnitsWithBehavior("TeleportBeacon");
			for (uint i = 0; i < allBeacons.length(); i++)
			{
				auto beacon = cast<TeleportBeacon>(allBeacons[i].GetScriptBehavior());
				if (beacon !is null)
				{
					if (beacon.m_unit.IsHidden() || !beacon.m_active)
					{
						beacon.Reveal();
						beacon.NetActivate();
					}
				}
			}
		}
	}

	void SpawnWaygates()
	{
		if (!Network::IsServer())
			return;

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
			vec2(-834, -218),
			vec2(-344, -500),
			vec2(723, -445)
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
