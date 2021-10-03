class MiamiHands : Weapon replaces Fist
{
	// Mostly just the fists but with bouncy hands.
	// Has impressive damage, though it's technically slower than the vanilla fists.
	mixin DampedSpringWep;

	default
	{
		Weapon.SlotNumber 1;
		+WEAPON.NOALERT;
	}

	override void DoEffect()
	{
		super.DoEffect();
		A_OffsetTick();
	}

	states
	{
		Select:
			FIST A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			FIST A 1 A_DampedLower(35);
			Loop;
		Ready:
			FIST A 1 A_WeaponReady();
			Loop;
		Fire:
			FIST B 1 A_OffsetKick((30,-8,-0.1));
			FIST C 1 A_CustomPunch(25+random(0,25),true,meleesound:"DSPUNCH");
			FIST C 5 A_OffsetKick((50,20,0));
			FIST C 2 A_OffsetKick((-10,40,0.1));
			FIST B 2;
			FIST A 9;
			Goto Ready;


	}

}