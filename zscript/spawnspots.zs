class WaveSpot : Actor
{
	// A spawn location for an enemy.
	string SpawnType;
	Property Spawn : SpawnType;
}

class WaveHandler : EventHandler
{
	// Handles the periodic spawning of new enemies.

	double WaveTimer;
	double AssaultTimer;
	bool Assault;
	int AssaultCount;
	Array<WaveSpot> spots;

	override void WorldLoaded(WorldEvent e)
	{
		AssaultTimer = 90.;
		Assault = false;
		AssaultCount = 0;
	}

	override void WorldThingDied(WorldEvent e)
	{
		if(!Assault && e.Thing.bISMONSTER && e.Thing.CountInv("SpawnedToken")<1)
		{
			Vector3 spawnpos = e.Thing.pos;
			e.Thing.FindFloorCeiling();
			if(e.Thing.ceilingpic == SkyFlatNum)
			{
				spawnpos.z = e.Thing.ceilingz - ( e.Thing.height + 8 ); // if it's under a skylight, it drops in
			}
			let spot = WaveSpot(e.Thing.Spawn("WaveSpot",spawnpos));
			spot.SpawnType = e.Thing.GetClassName();
			spots.push(spot);
		}
	}

	void SpawnWave()
	{
		if(spots.size()<1) { return; }
		WaveSpot spot;
		int numSpawns = 4+AssaultCount;
		{
			//if(frandom(0,1)<0.2) { continue; } // chance that a spawnspot will be skipped
			spot = spots[random(0,spots.size()-1)];
			bool sight = false; // Is this spot visible to a player?
			double dist = -1;
			Actor closestplr;
			for(int i = 0; i < players.size(); i++)
			{
				double newdist = dist;
				if(players[i].mo)
				{
					if(players[i].mo.CheckSight(spot))
					{
						sight = true;
					}
					newdist = spot.Vec2To(players[i].mo).length(); 
					//string plrname = players[i].mo.GetTag();
					//console.printf("Found MO "..plrname);
				}
				if(newdist<dist || dist == -1)
				{
					closestplr = players[i].mo;
					//console.printf("Set closest player "..i.." at "..newdist);
					dist = newdist;
				}
			}
			if(!sight)
			{
				let mon = spot.Spawn(spot.SpawnType,spot.pos);
				//console.printf("Player: "..closestplr);
				mon.target = closestplr;
				mon.PlayActiveSound();
				mon.SoundAlert(mon.target);
				mon.SetState(mon.ResolveState("See"));
				mon.A_GiveInventory("SpawnedToken");
				numSpawns--;
			}
		}
	}

	override void WorldTick()
	{
		double dt = 1./35.; // tick is always 1/35th second

		if(WaveTimer > 0)
		{
			WaveTimer -= dt; // WaveTimer is in seconds
		}
		else
		{
			if(Assault)
			{
				SpawnWave();
				WaveTimer = 10.;
			}
		}

		if(AssaultTimer > 0)
		{
			AssaultTimer -= dt;
		}
		else
		{
			if(Assault)
			{
				Assault = false;
				AssaultTimer = 120.;
				AssaultCount++;
			}
			else
			{
				Assault = true;
				WaveTimer = 10.;
				AssaultTimer = 90.;
			}
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		let mBigFont = BigFont;
		string timer = "NEXT WAVE : ";
		if(Assault) { timer = "!ASSAULT! : "; }
		string val = String.format("%.2f",AssaultTimer);
		Screen.DrawText(mBigFont,Font.CR_YELLOW,32,64,timer..val,DTA_ScaleX,2,DTA_ScaleY,2);
	}
}

class SpawnedToken : Inventory
{
	// Tracks if a monster was spawned by the wave system.
}