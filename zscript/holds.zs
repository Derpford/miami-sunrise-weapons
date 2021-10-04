class HoldPoint : Actor
{
	// An object that you have to stand next to for a bit to activate.
	double CapRadius;
	double CapMax;
	double CapCharge;
	double CapDecay;
	double Cap;
	int CapDrops;
	string CapReward;

	Property CapRadius: CapRadius;
	Property CapCharge: CapCharge, CapDecay;
	Property CapMax: CapMax;
	Property CapReward: CapReward, CapDrops;

	// May also come with cover.
	int Barriers;
	int BarrierMinHeight, BarrierMaxHeight;
	Property Barriers : Barriers;
	Property BarrierHeight : BarrierMinHeight, BarrierMaxHeight;


	default
	{
		HoldPoint.CapRadius 128.;
		HoldPoint.CapCharge 1.,.5;
		HoldPoint.CapMax 70.;
		HoldPoint.Barriers 1;
		HoldPoint.BarrierHeight 3,5;

	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		// Spawn some barriers.
		for(int i = random(0,Barriers); i > 0; i--)
		{
			double ang = frandom(0,360);
			Vector3 spawnpos = Vec3Angle(CapRadius,ang);
			let it = Barrier(Spawn("Barrier",spawnpos));
			if(it)
			{ 
				it.angle = ang; 
				it.barrierheight = random(BarrierMinHeight,BarrierMaxHeight);
				it.master = self;
				it.needMaster = true;
			}
		}
	}

	override void Tick()
	{
		string col = "HoldSparkle";
		let it = ThinkerIterator.Create("PlayerPawn");
		int count = 0;
		Actor plr;

		while(plr = Actor(it.next()))
		{
			//console.printf("Counted a player!");
			if(!CheckIfCloser(plr,CapRadius)) { continue; }
			// We can check player details here, but for now, just increment the capture level.
			count++;
		}
		if(count > 0)
		{
			col = "CapSparkle";
			for(int i = 0; i < count; i++)
			{
				Cap = clamp(0,Cap+CapCharge,CapMax);
			}
		}
		else
		{
			Cap = clamp(0,Cap-CapDecay,Cap);
		}

		for(int i = 0; i < 360; i+=10)
		{
			double ang = (i+GetAge())%360;
			A_SpawnItemEX(col,ceil(CapRadius),zofs:16,angle:ang);
			if(cap > 0)
			{
				A_SpawnItemEX(col, ceil((Cap/CapMax) * CapRadius),zofs:16,angle:ang);
			}
		}

		if(Cap >= CapMax)
		{
			for(int i = 0; i < CapDrops; i++)
			{
				A_SpawnItemEX(CapReward,xvel:frandom(-2,2),yvel:frandom(-2,2),zvel:frandom(4,8));
			}
			Die(self,self,0,"MDK");
		}


		Super.Tick();

	}
}

class HoldSparkle : Actor
{
	default
	{
		+NOINTERACTION;
		+BRIGHT;
		RenderStyle "AddStencil";
		StencilColor "FF2193";
	}

	states
	{
		Spawn:
			PUFF A 2;
			Stop;
	}
}

class CapSparkle : Actor
{
	default
	{
		+NOINTERACTION;
		+BRIGHT;
		RenderStyle "AddStencil";
		StencilColor "FFE521";
	}

	states
	{
		Spawn:
			PUFF A 2;
			Stop;
	}
}

class HardLight : Actor
{
	// A piece of a hardlight object.
	default
	{
		+NOGRAVITY;
		+BRIGHT;
		//+SOLID;
		+WALLSPRITE;
		+SHOOTABLE;
		BloodType "EMTrail";
		Health 20;
		Radius 3;
		Height 10;
		RenderStyle "AddStencil";
		StencilColor "08E2FF";
	}

	override int DamageMobj(Actor inf, Actor src, int dmg, Name mod, int flags, double ang)
	{
		//master.DamageMobj(inf,src,dmg,mod,flags,ang);
		//console.printf("Damaged owner for "..(dmg/2));
		A_DamageMaster(dmg/2);
		return super.DamageMobj(inf,src,dmg,mod,flags,ang);
	}

	states
	{
		Spawn:
			PUFF A 0;
			PUFF A 0
			{
				if(frandom(0,1)<0.001)
				{
					return ResolveState("Spawn3");
				}
				if(frandom(0,1)<0.001)
				{
					return ResolveState("Spawn4");
				}
				else
				{
					return ResolveState("Spawn2");
				}

			}
		Spawn2:
			PUFF A 1;
			Stop;
		Spawn3:
			PUFF C 1;
			Stop;
		Spawn4:
			PUFF D 1;
			Stop;
		Death:
			PUFF ABCD 2;
			Stop;
	}
}

class HardLightTop : HardLight
{
	// The top row of hardlight, with a lower profile.
	default
	{
		Height 2;
		//StencilColor "FFFFFF";// for testing
	}
}

class Barrier : Actor
{
	// A hardlight barrier.
	int width;
	int barrierheight;
	bool needMaster;
	Property Size : width, barrierheight;

	//Array< Array<Actor> > chunks;

	default
	{
		+SHOOTABLE;
		+DONTTHRUST;
		+WALLSPRITE;
		BloodType "EMTrail";
		Height 3;
		Radius 6;
		Barrier.Size 5,3;
		Health 100;
	}

	virtual void SpawnLight()
	{
		double gap = 10; // How far apart are the dots?
		double offset = -((width-1)*gap)/2.; // How far on the XY axis is the edge?

		for(int i = 0; i < barrierheight; i++)
		{
			//Array<HardLight> row;
			for(int j = 0; j < width; j++)
			{
				Vector3 spawnpos = Vec3Angle(offset+(gap*j),angle+90,(gap/2.)+(gap*i));
				Actor it;
				if( i == barrierheight-1 )
				{
					it = Spawn("HardLightTop",spawnpos);
				}
				else
				{
					it = Spawn("HardLight",spawnpos);
				}
				it.angle = angle;
				it.master = self;
				//row.push(it);
			}
			//chunks.push(row);
		}
	}
	override void Tick()
	{
		Super.tick();
		if(needMaster && !master)
		{
			// Owner disappeared.
			Die(self,self,0,"MDK");
		}

		if(health < 1)
		{
			// We ate too much damage.
			Die(self,self,0,"MDK");
		}
		// Spawn a whole bunch of HardLight.
		// Track it via the array.
		SpawnLight();
	}

	states
	{
		Spawn:
			BARR A -1;
			Stop;
	}
}

class BarrierSpawner : Inventory
{
	// A pocket barrier device. Mostly for debugging.
	default
	{
		+Inventory.INVBAR;
		Inventory.Icon "BON2A0";
	}

	override bool Use(bool pickup)
	{
		owner.A_SpawnItemEX("Barrier",xofs:32);
		return false;
	}
}

class MedPack : HoldPoint replaces Medikit
{
	// A pack of stim injectors.

	default
	{
		HoldPoint.CapReward "Stimpack", 3;
		HoldPoint.CapMax 50;
		HoldPoint.CapRadius 64;
		HoldPoint.CapCharge 1., 2.;
		HoldPoint.Barriers 0;
	}

	states
	{
		Spawn:
			MEDI A -1;
			Stop;
	}
}