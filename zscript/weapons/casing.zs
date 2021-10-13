class CasingHands : Weapon
{
	// Act natural.
	// You can't select this weapon normally; it's selected for you at level start.

	default
	{
		// No flags to set.
	}

	states
	{
		Select:
			TNT1 A 1 A_Raise(256);
			Loop;

		Deselect:
			TNT1 A 1
			{
				// Sends the event that triggers the end of Casing Mode.
				invoker.owner.bNEVERTARGET = false;
				invoker.owner.player.cheats &= !CF_NOTARGET;
				EventHandler.SendNetworkEvent("CasingEnd");	
			}
		DesLoop:
			TNT1 A 1 A_Lower(256);
			Loop;

		Ready:
		Fire:
			TNT1 A 1 A_WeaponReady();
			Loop;
	}
}