class TankBarrier : Barrier
{
	// A barrier designed for tanks. Wider but not as tall.
	default
	{
		+NOGRAVITY;
		Barrier.Size 5, 3;
	}
}
class PlasmaTank : MiamiMonster replaces Arachnotron
{
	// An anti-personnel armored unit.	

	Array<Actor> shields;
	double shieldDist;
	double shieldHeight;

	default
	{
		Health 200;
		Height 64;
		Radius 32;
		Speed 12;
		PainChance 64;
		Mass 50;
		DropItem "YellowCredit";
		DropItem "BlueCredit";
		DropItem "Chems", 192;
		MiamiMonster.charge 50;
		MiamiMonster.bonus "Chems",3,4;
		// Doesn't have a range setting. This machine does not give a shit.
		MiamiMonster.sounds "weapons/gatlc","weapons/gatlr";
		Obituary "%o got steamrolled by a gatling tank.";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		shieldDist = 72;
		shieldHeight = 8;
		for(int i = 0; i < 360; i += 45)
		{
			Vector3 spawnpos = pos + AngleToVector(i,shieldDist);
			spawnpos.z += shieldHeight;
			Actor shield = Spawn("TankBarrier",spawnpos);
			let it = HoverBarrier(shield);
			if(it) { it.master = self; it.needMaster = true; }
			shields.push(shield);
		}
	}

	override void Tick()
	{
		super.Tick();
		for(int i = 0; i < shields.Size(); i++)
		{
			let shield = shields[i];
			if(shield)
			{
				shield.Warp(self,shieldDist,zofs:shieldHeight,angle:i*45);
			}
		}
	}

	action void A_GatlingShot(bool side = false)
	{
		A_Discharge(0.5);
		A_StartSound("weapons/gatlf");
		double offs = -16;
		if(side) { offs *= -1; }
		A_SpawnProjectile("GatlingShot",48,offs,angle:frandom(-5,5),flags:CMF_OFFSETPITCH,pitch:frandom(0,-3));
	}

	states
	{
		Spawn:
			ZPTK A 1 A_Look(); // Tanks idle instead of wandering.
			Loop;

		See:
			ZPTK ABC 3 A_Chase();
			Loop;

		Missile:
			ZPTK A 2 A_ChargeOrFire();
			Goto See;

		Charge:
			ZPTK DE 1
			{
				A_Charge();
			}
			ZPTK A 0 A_ChargeOrFire();
			Goto See;

		Fire:
			"####" A 3
			{
				if(shieldHeight > 1)
				{
					shieldHeight = shieldHeight / 2;
					return ResolveState(null);
				}
				else
				{
					PainChance = 255;
					return ResolveState("RealFire");
				}
			}
			Loop;
		RealFire:
			ZPTK A 0 A_FaceTarget(.5);
			ZPTK D 8 A_GatlingShot(); //Left side.
			ZPTK E 8 A_GatlingShot(true); //Right side.
			ZPTK A 0 A_MonsterRefire(80,"WindDown");
			Goto Fire;

		WindDown:
			"####" A 3
			{
				if(shieldHeight < 8)
				{
					shieldHeight = shieldHeight * 2;
					return ResolveState(null);
				}
				else
				{
					PainChance = 64;
					return ResolveState("See");
				}
			}
			Loop;

		Pain:
			ZPTK CBA 3 VelFromAngle(6,Normalize180(angle+180));
			ZPTK FG 4 A_Pain();
			ZPTK A 4 { shieldHeight = 8; }
			Goto See;

		Death:
			ZPTK FG 3;
			ZPTK H 4; //Left turret go boom
			ZPTK I 4; //Right turret go boom
			ZPTK JKLMNO random(3,4); // Tank falls apart.
			Stop;
	}
}