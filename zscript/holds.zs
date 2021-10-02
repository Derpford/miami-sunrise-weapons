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
		+SOLID;
		// TODO: Shootable?
		Radius 4;
		RenderStyle "AddStencil";
		StencilColor "08E2FF";
	}

	states
	{
		Spawn:
			PUFF A 2;
			Stop;
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
		Barrier.Size 5,5;
	}

	override void Tick()
	{
		Super.tick();
		if(needMaster && !master)
		{
			// Owner disappeared.
			Die(self,self,0,"MDK");
		}
		// Spawn a whole bunch of HardLight.
		// Track it via the array.

		double offset = -(width/2.); // How far on the XY axis is the edge?
		double gap = 8; // How far apart are the dots?

		for(int i = 0; i < barrierheight; i++)
		{
			//Array<HardLight> row;
			for(int j = 0; j < width; j++)
			{
				Vector3 spawnpos = Vec3Angle(offset+(gap*j),angle+90,gap*(i+1));
				Spawn("HardLight",spawnpos);
				//row.push(it);
			}
			//chunks.push(row);
		}
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