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

	override void OnRegister()
	{
	}

	override void WorldLoaded(WorldEvent e)
	{
		AssaultTimer = 90.;
		Assault = false;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if(Level.time < 5 && e.Thing.bISMONSTER)
		{
			Vector3 spawnpos = e.Thing.pos;
			e.Thing.FindFloorCeiling();
			if(e.Thing.ceilingpic == SkyFlatNum)
			{
				spawnpos.z = e.Thing.ceilingz - ( e.Thing.height + 8 ); // if it's under a skylight, it drops in
			}
			let spot = WaveSpot(e.Thing.Spawn("WaveSpot",spawnpos));
			spot.SpawnType = e.Thing.GetClassName();
		}
	}

	void SpawnWave()
	{
		let it = ThinkerIterator.Create("WaveSpot",Thinker.STAT_DEFAULT);
		WaveSpot spot;
		while(spot = WaveSpot(it.next()))
		{
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
				WaveTimer = 20.;
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
				AssaultTimer = 90.;
			}
			else
			{
				Assault = true;
				WaveTimer = 20.;
				SpawnWave();
				AssaultTimer = 60.;
			}
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		let mBigFont = BigFont;
		string timer = "NEXT WAVE : ";
		if(Assault) { timer = "!ASSAULT! : "; }
		string val = String.format("%.5s",""..AssaultTimer);
		Screen.DrawText(mBigFont,Font.CR_YELLOW,32,32,timer..val,DTA_ScaleX,2,DTA_ScaleY,2);
	}
}
