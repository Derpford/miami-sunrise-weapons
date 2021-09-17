mixin class DampedSpringWep
{
	// Damped spring offset handling.
	// Does all your offsets for you while you wait.

	// Offset position and velocity.
	Vector3 offpos, offvel, offgoal;
	override void PostBeginPlay()
	{
		offpos = (0,128,1);
		offvel = (0,0,0);
		offgoal = (0,32,1);
	}
	// Z should default to 1 because it's a scale, not a position.

	// There are three ways to change the position of the weapon onscreen:
	// changing offvel adds velocity without changing position immediately.
	// changing offgoal gives a more permanent point to move toward.
	// changing offpos directly snaps the weapon to that point.

	action double damp(double x, double v, double xgoal, double vgoal)
	{
		// Takes current position and current velocity and gives
		// a new velocity.
		double dt = 1./35.;
		double stiffness = 1.9;
		double damping = 0.1;
		double g = xgoal;
		double q = vgoal;
		v = dt * stiffness * (g - x) + dt * damping * (q - v);
		return v;
	}

	action void A_OffSetGoal(Vector3 new)
	{
		invoker.offgoal = new;
	}

	action void A_OffsetKick(Vector3 vel, bool add = false)
	{
		if(add)
		{
			invoker.offvel += vel;
		}
		else
		{
			invoker.offvel = vel;
		}
	}

	action void A_OffsetVec(Vector3 new)
	{
		invoker.offpos = new;
	}

	action void A_OffsetTick()
	{
		let psp = invoker.owner.player.GetPSprite(PSP_WEAPON);

		psp.pivot.x = 0.5;
		psp.pivot.y = 0.5;

		invoker.offpos.x = invoker.offpos.x + invoker.offvel.x;
		invoker.offpos.y = invoker.offpos.y + invoker.offvel.y;
		invoker.offpos.z = invoker.offpos.z + invoker.offvel.z;

		invoker.offvel.x = damp(invoker.offpos.x,invoker.offvel.x,invoker.offgoal.x,0);
		invoker.offvel.y = damp(invoker.offpos.y,invoker.offvel.y,invoker.offgoal.y,0);
		invoker.offvel.z = damp(invoker.offpos.z,invoker.offvel.z,invoker.offgoal.z,0);

		//console.printf("Offsets: "..invoker.offpos);

		//A_WeaponOffset(invoker.offpos.x,invoker.offpos.y,WOF_INTERPOLATE);
		//A_OverlayScale(1,invoker.offpos.z);
		if(invoker.owner.player.readyweapon == invoker)
		{
			psp.x = invoker.offpos.x;
			psp.y = invoker.offpos.y;
			psp.scale.x = invoker.offpos.z;
			psp.scale.y = invoker.offpos.z;
		}
	}

	action void A_DampedRaise(int speed)
	{
		A_OffsetGoal((0,32,1));
		A_Raise(speed);
	}

	action void A_DampedLower(int speed)
	{
		A_OffsetGoal((0,128,1));
		A_Lower(speed);
	}
}