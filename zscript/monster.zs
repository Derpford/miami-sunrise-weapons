class MiamiMonster : Actor
{
	// Base class for Miami Sunrise enemies.

	double charge, chargemax;

	Property charge : chargemax;

	default
	{
		+MONSTER;
		MiamiMonster.charge 35.;
	}

	action void A_Charge(double amt = 1.)
	{
		invoker.charge += amt;
	}

	action bool A_ChargeReady()
	{
		return invoker.charge >= invoker.chargemax;
	}
}