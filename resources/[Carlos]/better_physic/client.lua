addEventHandler ("onClientPlayerDamage", getLocalPlayer(),
	function(attacker, weapon, bodypart, loss)
		if(attacker) then
			local type = getElementType(attacker)
			if(type == "vehicle") then

				local health = getElementHealth(getLocalPlayer())
				-- just get the speed to calculate it with current health
				local speedX, speedY, speedZ = getElementVelocity(attacker)

				local actualspeed = (speedX^2 + speedY^2 + speedZ^2)^(0.5)
				local kmh = actualspeed * 180
				-- as you see damage depends now from car(attacker) speed(it's calculated somehow)
				--setElementHealth(getLocalPlayer(), health-(math.random(kmh/1.35,kmh)))
				triggerServerEvent("slap",getLocalPlayer())
				cancelEvent()
			end
		end
	end
)

-- looking at more realistic
addEventHandler ("onClientRender", root,
	function()
		for k,v in ipairs ( getElementsByType ( "player" ) ) do
			--if isElementStreamedIn ( v ) then
				local rotcam = math.rad (360 - getPedCameraRotation (v))
				local xpos,ypos,zpos = getPedBonePosition (v, 8)
				local xlook,ylook,zlook = xpos - 300*math.sin(rotcam), ypos + 300*math.cos(rotcam), zpos
				setPedLookAt (v, xlook, ylook, zlook, -1)
			--end
		end
	end
)

--***************RAGDOLL PART****************

local ragdollEnabled = false;

addEventHandler( 'onClientRender', root,
	function()
	local a, b, c, d = getPedTask(localPlayer, "primary", 1)
		if a == "TASK_COMPLEX_IN_AIR_AND_LAND" and b == "TASK_SIMPLE_IN_AIR" then
			if ragdollEnabled == false then
				ragdollEnabled = true;
				addEventHandler('onClientPreRender', root, rotate);
				addEventHandler('onClientPreRender', root, eliminateProblems);
			end
		elseif a == "TASK_COMPLEX_IN_AIR_AND_LAND" and b == "TASK_SIMPLE_FALL" then -- m: TASK_SIMPLE_LAND, TASK_SIMPLE_GET_UP
			if ragdollEnabled == true then
				ragdollEnabled = false;
				setElementHealth(localPlayer, 0) -- kill
				--local x, y, z = getElementPosition(localPlayer)
				--setElementPosition(localPlayer, x, y, z+4)
				local x, y, z = getElementVelocity(localPlayer)
				removeEventHandler('onClientPreRender', root, rotate);
				removeEventHandler('onClientPreRender', root, eliminateProblems);
			end
		end
	end
)

-- just fixes rotation problems
function eliminateProblems()
	for k,v in ipairs ( getElementsByType ( "player" ) ) do
		if not isPedOnGround(v) then
			local a, b, c, d = getPedTask(v, "primary", 1)
			if a == "TASK_COMPLEX_IN_AIR_AND_LAND" and b == "TASK_SIMPLE_IN_AIR" then
				--if isElementStreamedIn ( v ) then
					local rx, ry, rz  = getElementRotation(v)
					setElementRotation(v, rx, 0, rz)
				--end
			end
		end
	end
end

-- our ragdoll imiation simple isn't it? ;) but effect is cool
function rotate()
	for k,v in ipairs ( getElementsByType ( "player" ) ) do
		if not isPedOnGround(v) then
			local a, b, c, d = getPedTask(v, "primary", 1)
			if a == "TASK_COMPLEX_IN_AIR_AND_LAND" and b == "TASK_SIMPLE_IN_AIR" then
				--if isElementStreamedIn ( v ) then
					local rx, ry, rz = getElementRotation(v);
					setElementRotation(v, rx + 6.4, ry, rz + math.random(1.1,1.4));
				--end
			end
		end
	end
end;
