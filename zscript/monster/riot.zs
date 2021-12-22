class RiotCop : MiamiMonster replaces ShotgunGuy
{
	// A guy with a riotgun. Not actually a cop.

	default
	{
		Health 30;
		Height 48;
		Speed 6;
		MiamiMonster.Range 420;
		MiamiMonster.Charge 70;
		MiamiMonster.sounds "weapons/shotgc", "weapons/shotgr";
		SeeSound "shotguy/sight";
		AttackSound "shotguy/attack";
		PainSound "shotguy/pain";
		DeathSound "shotguy/death";
		ActiveSound "shotguy/active";	
		DropItem "EMShotgun";
		DropItem "CashBundle", 192;
		MiamiMonster.bonus "CreditCard", 2, 2;
		Obituary "%o was read the riot act by a bootlicker.";
	}	

	action void A_RiotShot()
	{
		A_Discharge(70);
		A_StartSound("weapons/shotgf",1);
		Vector3 spawnpos = Vec3Angle(8,angle,32);
		for(int i = 0; i < 10; i++)
		{
			A_MiamiFire("EMPellet",spawnpos,frandom(-4,4),frandom(1,-3));
		}
	}

	override bool SpecialDeath()
	{
		return charge > 0;
	}

	states
	{
		Spawn:
			ASGZ ABCD 4
			{
				A_SetWanderTics();
				A_Wander();
				A_Look();
			}
			Loop;

		See:
			ASGZ ABCD 3 A_Chase();
			Loop;

		Missile:
			ASGZ E 2 A_ChargeOrFire();
			Goto See;

		Charge:
			ASGZ E 1
			{
				A_Charge();
				A_FaceTarget(15,30);
				//A_StartSound("weapons/shotgc",1,CHANF_NOSTOP);
			}
			ASGZ E 1 A_ChargeOrFire();
			Goto See;

		Fire:
			ASGZ E 2 A_FaceTarget(5,10);
			ASGZ E 4 A_Pain();
			ASGZ F 3 A_RiotShot();
			ASGZ E 2;
			ASGZ G 3;
			Goto See;

		Pain:
			ASGZ G 4 A_Pain();
			ASGZ DC 3;
			Goto See;

		Death:
			ASGZ H 3;
			ASGZ I 6 A_ScreamAndUnblock();
			ASGZ JK 3 A_SetTics(random(2,4));
			ASGZ LMN 4;
			ASGZ N -1;
			Stop;

		XDeath:
			ASGZ OPQRSTUVW 4;
			ASGZ W -1;
			Stop;

	}
}

class RiotShieldCop : RiotCop replaces Spectre
{
	// The riot shield cop has scrounged up a shield.
	// It's hard to hold a shield and a shotgun at the same time, though...

	Actor shield;

	double shieldang;

	default
	{
		MiamiMonster.bonus "CreditCard", 2, 3;
		Obituary "%o got cornered by a pig.";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Vector3 spawnpos = pos;
		spawnpos.z += 24;
		shield = Spawn("HoverBarrier",spawnpos);
		let it = HoverBarrier(shield);
		if(it) { it.master = self; it.needMaster = true; }
		shieldang = 30;
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
			ASGZ ABCD 3 { A_Chase(flags:CHF_NORANDOMTURN); A_FaceTarget(5); }
			Loop;

		Charge:
			ASGZ E 1
			{
				A_Charge();
				A_FaceTarget(10,30);
				invoker.shieldang = 60;
				//A_StartSound("weapons/shotgc",1,CHANF_NOSTOP);
			}
			ASGZ E 1 A_ChargeOrFire();
			Goto See;

		Fire:
			ASGZ E 2 { A_FaceTarget(5,10); invoker.shieldang = 90; }
			ASGZ E 4 A_Pain();
			ASGZ F 3 A_RiotShot();
			ASGZ E 2;
			ASGZ G 3 { invoker.shieldang = 30; }
			Goto See;
	}
}