class BarrierThug : PistolThug replaces Demon
{
	// Some jerkoff who found a barrier unit.

	Actor shield;

	double shieldang;

	default
	{
		Health 35;
		Speed 8;
		Height 48;
		MiamiMonster.range 256;
		DropItem "EMPistol";
		DropItem "CashBundle", 128;
		DropItem "CreditCard", 128;
		SeeSound "shotguy/sight";
		AttackSound "shotguy/attack";
		PainSound "shotguy/pain";
		DeathSound "shotguy/death";
		ActiveSound "shotguy/active";	
		Obituary "%o got outflanked by some jerk with a Barrier.";
		Translation "128:159=#[0,255,0]";
		MiamiMonster.bonus "CreditCard", 1, 3;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Vector3 spawnpos = pos;
		spawnpos.z += 24;
		shield = Spawn("HoverBarrier",spawnpos);
		let it = HoverBarrier(shield);
		if(it) { it.master = self; it.needMaster = true; }
		shieldang = 0;
	}

	override void Tick()
	{
		super.Tick();
		if(shield) { shield.Warp(self,32,zofs:24,angle:shieldang); }
	}

	override bool SpecialDeath()
	{
		if(shield) { return true; }
		else { return false; }
	}

	states
	{
		See:
			MGPS ABCD 4 { A_Chase(flags:CHF_NORANDOMTURN); A_FaceTarget(5); }
			Loop;
		Charge:
			MGPS E 1
			{
				A_Charge(3);	
				A_FaceTarget(5,15);
				invoker.shieldang = 45;
				A_StartSound("weapons/plasmaf",1,CHANF_NOSTOP);
			}
			MGPS E 0
			{
				if(A_ChargeReady())
				{
					bMISSILEEVENMORE = true;
					A_StartSound("weapons/pisr",1);
					invoker.shieldang = 0;
					return ResolveState("See");
				}
				else 
				{
					return ResolveState(null);
				}
			}
			Loop;

		Fire:
			MGPS E 4 { A_FaceTarget(10,10); invoker.shieldang = 90; }
			MGPS F 3 A_PistolShot();
			MGPS E 3 A_SetTics(random(3,12));
			MGPS D 2
			{
				if(invoker.charge > 0 && frandom(0,1)>0.4)
				{
					return ResolveState("Fire");
				}
				else
				{
					bMISSILEEVENMORE = false;
					invoker.shieldang = 0;
					return ResolveState(null);
				}
			}
			Goto See;
	}

}

class HoverBarrier : Barrier
{
	// A barrier that doesn't fall and has its thingamajigs in the middle.
	default
	{
		+NOGRAVITY;
		Health 40;
		Barrier.Size 4,5;
		Height 6;
	}

	override void SpawnLight()
	{
		double gap = 10; // How far apart are the dots?
		double offset = -((width-1)*gap)/2.; // How far on the XY axis is the edge?

		for(int i = 0; i < barrierheight; i++)
		{
			//Array<HardLight> row;
			for(int j = 0; j < width; j++)
			{
				Vector3 spawnpos = Vec3Angle(offset+(gap*j),angle+90,(offset+(gap*i)));
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

	states
	{
		Spawn:
			BARR B -1;
			Stop;
	}
}