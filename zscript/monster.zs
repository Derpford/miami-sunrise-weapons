class MiamiMonster : Actor
{
	// Base class for Miami Sunrise enemies.

	double charge, chargemax;

	Property charge : chargemax;

	default
	{
		MONSTER;
		MiamiMonster.charge 35.;
	}

	override void Tick()
	{
		Super.tick();
		//charge = clamp(0,charge-1,chargemax);
	}

	action void A_Charge(double amt = 1.)
	{
		invoker.charge += amt;
	}

	action void A_Discharge(double amt = 1.)
	{
		invoker.charge -= amt;
	}

	action bool A_ChargeReady()
	{
		return invoker.charge >= invoker.chargemax;
	}
}