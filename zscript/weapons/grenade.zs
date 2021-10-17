class EMGrenade : Actor
{
	// Bounces a couple times. Explodes on a timer. Throws shrapnel everywhere.

	int time; bool explode;
	int beeptime;
	Property fuse : time, beeptime;

	default
	{
		BounceType "Doom";
		Speed 20;
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
		if(time % beeptime == 0)
		{
			A_StartSound("misc/i_pkup");
			beeptime = max(5,beeptime*0.9);
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
			PUFF A 1 Bright A_SpawnItemEX("ShredTrail");
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
		Inventory.Icon "GRNDA7A3";
		Inventory.PickupMessage "Got a pulse grenade.";
	}

	override bool Use(bool pickup)
	{
		owner.A_SpawnItemEX("EMGrenade",xvel:20,zvel:5);
		return true;
	}

	states
	{
		Spawn:
			GRND A -1;
			Stop;
	}
}