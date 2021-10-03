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

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		charge = 0;
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
		//console.printf("Charge: "..invoker.charge);
	}

	action void A_Discharge(double amt = 1.)
	{
		invoker.charge = clamp(0,invoker.charge-amt,invoker.charge);
	}

	action bool A_ChargeReady()
	{
		return invoker.charge >= invoker.chargemax;
	}

	action bool A_ChargeCheck(double amt = -1)
	{
		if(amt >= 0)
		{
			return invoker.charge > amt;
		}
		else
		{
			return invoker.charge > invoker.chargemax;
		}
	}

	action void A_ChargeOrFire(double min = -1)
	{
		if(A_ChargeCheck(min))
		{
			invoker.SetState(invoker.ResolveState("Fire"));
		}
		else
		{
			invoker.SetState(invoker.ResolveState("Charge"));
		}
	}
}