class EMGrenade : Actor
{
	// Bounces a couple times. Explodes on a timer. Throws shrapnel everywhere.

	int time; bool explode;
	int beeptime;
	int maxbeeptime;
	Property fuse : time, maxbeeptime;

	default
	{
		BounceType "Doom";
		Speed 25;
		BounceFactor 0.7;
		+MISSILE;
		+ALLOWBOUNCEONACTORS;
		+BOUNCEONACTORS;
		+BOUNCEAUTOOFFFLOORONLY;
		-BOUNCEAUTOOFF;
		BounceSound "ZSec/bounce";
		EMGrenade.fuse 105, 35;
	}

	override void Tick()
	{
		Super.tick();
		time--;
		beeptime--;
		if(beeptime < 1 && time > beeptime)
		{
			A_StartSound("misc/i_pkup",3);
			maxbeeptime = max(5,maxbeeptime*0.75);
			beeptime = maxbeeptime;
		}
		if(time < 1 && !InStateSequence(curstate,ResolveState("XDeath")))
		{
			SetState(ResolveState("XDeath"));
		}
	}

	action void A_Shrapnel()
	{
		A_StartSound("weapons/rocklx");
		invoker.A_Explode(128);
		for(int i = 0; i < 360; i+=10)
		{
			for(int j = random(2,4); j > 0; j--)
			{
				double xvel = 3 * j * random(2,4);
				double zvel = 3 * (4-j) * random(1,2);
				invoker.A_SpawnItemEX("EMShrapnel",zofs:4,xvel:xvel,zvel:zvel,angle:i);
			}
		}
	}

	states
	{
		Spawn:
			THR2 AB 4;
			Loop;

		Death:
			THR2 A 1 A_StartSound("Zsec/bounce");
		DeathLoop:
			THR2 AB 4;
			Loop;
		XDeath:
			PLSS A 1 A_Shrapnel();
			PLSS BCDE 1;
			Stop;
	}
}

class EMShrapnel : Actor
{
	default
	{
		PROJECTILE;
		DamageFunction 5+random(0,5);
		Speed 20;
		BounceType "Doom";
		BounceCount 4;
		BounceFactor 0.5;
		+BOUNCEAUTOOFFFLOORONLY;
		-BOUNCEAUTOOFF;
		-NOGRAVITY;
		RenderStyle "Add";
	}

	states
	{
		Spawn:
			PUFF A 1 Bright 
			{
				double xofs = -vel.x;
				double yofs = -vel.y;
				double zofs = -vel.z;
				//A_SpawnItemEX("ShredTrail");
				//A_SpawnItemEX("ShredTrail",xofs:xofs,yofs:yofs,zofs:zofs,flags:SXF_ABSOLUTEPOSITION);
				A_SpawnItemEX("ShredTrail",xofs:xofs*2,yofs:yofs*2,zofs:zofs*2,flags:SXF_ABSOLUTEPOSITION);
			}
			Loop;
		Death:
			PUFF BCDE 1;
			Stop;
	}
}

class GrenadeToss : Inventory
{
	default
	{
		+Inventory.INVBAR;
		Inventory.Amount 1;
		Inventory.MaxAmount 5;
		Inventory.Icon "THR2A0";
		Inventory.PickupMessage "Got a pulse grenade.";
	}

	override bool Use(bool pickup)
	{
		//A_SpawnProjectile("EMGrenade");
		let it = owner.Spawn("EMGrenade",owner.Vec3Angle(8,owner.angle,24));
		it.target = owner;
		it.Vel3DFromAngle(it.speed,owner.angle,owner.pitch-20);
		return true;
	}

	states
	{
		Spawn:
			THR2 A -1;
			Stop;
	}
}