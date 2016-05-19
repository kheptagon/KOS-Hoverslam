parameter radarOffset.							// The value of alt:radar when landed (on gear)

function avgMaxVertDecel {						// Maximum vertical deceleration possible (m/s^2)
	local srfspeed is ship:velocity:surface:mag.
	if srfspeed = 0
		return 0.
	local maxAccel is ship:availablethrust / ship:mass.
	local verticalComponent is -ship:verticalspeed / srfspeed.
	return maxAccel * (2 * verticalComponent + 1) / 3 - g. 		// verticalComponent is increased to account for the fact
}									// that the rocket points more directly downwards over time

clearscreen.
lock trueRadar to alt:radar - radarOffset.				// Offset radar to get distance from gear to ground
lock g to body:mu / body:radius^2.					// Gravity (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * avgMaxVertDecel()).	// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.				// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).			// Time until impact, used for landing gear

WAIT UNTIL ship:verticalspeed < -1.
	hudtext("Preparing for hoverslam...", 5, 2, 50, white, false).
	rcs on.
	brakes on.
	lock steering to srfretrograde.
	when impactTime < 3 then gear on.

WAIT UNTIL trueRadar < stopDist.
	hudtext("Performing hoverslam", 5, 2, 50, white, false).
	lock throttle to idealThrottle.

WAIT UNTIL ship:verticalspeed > -0.01.
	hudtext("Hoverslam completed. Stabilising...", 5, 2, 50, white, false).
	lock throttle to 0.
	lock steering to up.						// Use the RCS for stability
	wait 5.
	rcs off.
	hudtext("Done!", 5, 2, 50, white, false).
