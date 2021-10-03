class MiamiMonster : Actor
{
	// Base class for Miami Sunrise enemies.

	double charge, chargemax;

	double range; // optimal range in map units

	Property charge : chargemax;
	Property range : range;

	default
	{
		MONSTER;
		MiamiMonster.charge 35.;
		MiamiMonster.range 512;
	}

	override void Tick()
	{
		Super.tick();
		//charge = clamp(0,charge-1,chargemax);

		if(target && Vec2To(target).length()<range)
		{
			bFRIGHTENED = true;
		}
		else
		{
			bFRIGHTENED = false;
		}
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

	action bool A_ChargeCheck(double amt)
	{
		return invoker.charge > amt;
	}

	action void A_ChargeOrFire(double min)
	{
		if(invoker.charge > min)
		{
			invoker.SetState(invoker.ResolveState("Fire"));
		}
		else
		{
			invoker.SetState(invoker.ResolveState("Charge"));
		}
	}
}