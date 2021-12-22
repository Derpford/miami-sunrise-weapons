class CoilSniper : MiamiMonster replaces Revenant
{
	// A sneaky bastard with a coilgun. Agile and deadly.

	default
	{
		Height 48;
		Health 80;
		Speed 10;
		MiamiMonster.charge 60;
		MiamiMonster.range 800;
		MiamiMonster.bonus "Chems", 1, 2;
		MiamiMonster.sounds "weapons/coilc", "misc/i_pkup";
		MiamiMonster.wobble 0.4;
		SeeSound "ZSec/sight";
		PainSound "ZSec/pain";
		DeathSound "ZSec/death";
		ActiveSound "ZSec/active";
		Obituary "%o couldn't get to cover fast enough.";
	}

	action void A_FireCoil()
	{
		A_Discharge(60);
		A_StartSound("weapons/coilf",1);
		A_MiamiFire("EMCoilBolt");
		// No charge bonus. These guys suck at this.
	}

	states
	{
		Spawn:
			ZHRT ABCD 4
			{
				A_SetWanderTics();
				A_Wander();
			}
			Loop;

		See:
			ZHRT ABCD 3 A_Chase;
			Loop;

		Missile:
			ZHRT E 1 A_ChargeOrFire();
			Goto See;

		Charge:
			ZHRT E 1 
			{
				A_FaceTarget(45,45);
				A_Charge(1.5);
			}
			ZHRT E 1 A_ChargeOrFire();
			Loop;

		Fire:
			ZHRT E 2 A_FaceTarget(5,5);
			ZHRT F 3 A_FireCoil();
			ZHRT E 2;
			Goto See;

		Pain:
			ZHRT G 4 A_Pain();
			ZHRT DCB 4;
			Goto See;

		Death:
			ZHRT G 3 A_ScreamAndUnblock();
			ZHRT HI 3;
			ZHRT J 4 A_SetTics(random(4,8));
			ZHRT K 3;
			ZHRT L -1;
			Stop;

		XDeath:
			ZHRT OPQRSTUVW 3;
			ZHRT W -1;
			Stop;
	}
}