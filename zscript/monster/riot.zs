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
		DropItem "CreditCard", 192;
		DropItem "ShieldBonus", 128;
		Obituary "%o was read the riot act by a bootlicker.";
	}	

	action void A_RiotShot()
	{
		A_Discharge(70);
		A_StartSound("weapons/shotgf",1);
		for(int i = 0; i < 10; i++)
		{
			A_SpawnProjectile("EMPellet",angle:frandom(-4,4),flags:CMF_OFFSETPITCH,pitch:frandom(1,-3));
		}
	}

	override bool SpecialDeath()
	{
		return charge > 0;
	}

	states
	{
		Spawn:
			ASGZ AB 4 A_Look;
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
				A_StartSound("weapons/shotgc",1,CHANF_NOSTOP);
			}
			ASGZ E 1 A_ChargeOrFire();
			Goto See;

		Fire:
			ASGZ E 2 A_FaceTarget();
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