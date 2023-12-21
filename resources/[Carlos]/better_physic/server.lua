--TODO: combinations in air

-- dealing more damage when vehicle is hitting you

function slap()
	local speedX2, speedY2, speedZ2 = getElementVelocity(source)
	setElementVelocity(source, speedX2, speedY2, speedZ2+1.5)
end
addEvent("slap",true)
addEventHandler("slap",getRootElement(),slap)

-- little function that gets position in front of element
function getPositionInFrontOf(element)
	local x, y, z = getElementPosition( element )
	rz = 0
	if getElementType( element ) == "vehicle" then
		_, _, rz = getElementRotation( element )
	elseif getElementType( element ) == "player" then
		rz = getPedRotation( element )
	end
	rz = rz + ( rotation or 90 )
	return x + ( ( math.cos ( math.rad ( rz ) ) ) * ( distance or 4 ) ), y + ( ( math.sin ( math.rad ( rz ) ) ) * ( distance or 4 ) ), z, rz
end

-- car damage more realistic, now affects more on driver and passenger
addEventHandler ("onVehicleDamage", root,
	function(loss)
		local driver = getVehicleOccupant(source)
		if(driver) then
			-- makes the driver unconscious and not able to drive
			if(loss > 50) and (loss < 100) then
				setPedAnimation(driver, "ped", "CAR_dead_LHS", -1, true, false, true)
				setElementData(driver, "ableToDrive", 0)
			-- greater shock? make driver fly out the front window then
			elseif(loss >= 100) then
				local x, y, z = getPositionInFrontOf(source)
				local speedX, speedY, speedZ = getElementVelocity(source)
				setElementData(driver, "carSpeedX", speedX)
				setElementData(driver, "carSpeedY", speedY)
				setElementData(driver, "carSpeedZ", speedZ)
				local carHealth = getElementHealth(driver)
				-- just get the speed to calculate it with current health
				local sX = getElementData(driver, "carSpeedX")
				local sY = getElementData(driver, "carSpeedY")
				local sZ = getElementData(driver, "carSpeedZ")
				local actualspeed = (sX^2 + sY^2 + sZ^2)^(0.5)
				local kmh = actualspeed * 180
				-- boom die or survive
				setElementHealth(source, carHealth-(math.random(kmh/1.35)))
				removePedFromVehicle(driver) -- remove driver here
				local vx, vy, vz = getElementVelocity(driver)
				setElementVelocity(driver, vx, vy, vz+4.1) -- im not sure it does something ;p
				-- here the timer begins( waiting for the ground)
				checkingTimer = setTimer(function()
					-- this triggers when player fell on the ground
					if(isPedOnGround(driver)) then
						setPedAnimation(driver, "ped", "getup_front", -1, false, false, true)
						setTimer(setPedAnimation, 2000, 1, driver, false)
						local health = getElementHealth(driver)
						-- just get the speed to calculate it with current health
						local sX = getElementData(driver, "carSpeedX")
						local sY = getElementData(driver, "carSpeedY")
						local sZ = getElementData(driver, "carSpeedZ")
						local actualspeed = (sX^2 + sY^2 + sZ^2)^(0.5)
						local kmh = actualspeed * 180
						-- boom die or survive
						setElementHealth(driver, health-(math.random(kmh/1.35)))
						if(checkingTimer) then
							if(isTimer(checkingTimer)) then
								killTimer(checkingTimer)
							end
						end
					end
				end, 50, 0)
			end
		end
	end
)
