addEventHandler("onDebugMessage", getRootElement(),
	function (message, level, file, line, r, g, b)
		local color
		if level == 1 then
			level = "[ERROR] "
			color = tocolor(215, 89, 89)
		elseif level == 2 then
			level = "[WARNING] "
			color = tocolor(255, 150, 0)
		elseif level == 3 then
			level = "[INFO] "
			color = tocolor(50, 179, 239)
		else
			level = "[INFO] "
			color = tocolor(r, g, b)
		end

		local time = getRealTime()
		local timeStr = "[" .. string.format("%02d:%02d:%02d", time.hour, time.minute, time.second) .. "]"

		if file and line then
			triggerLatentClientEvent("addDebugLine", resourceRoot, level .. file .. ":" .. line .. ", " .. message, color, timeStr)
		else
			triggerLatentClientEvent("addDebugLine", resourceRoot, level .. message, color, timeStr)
		end
	end
)

addEventHandler("onPlayerCommand", root, function(commandName)
	if commandName == "debug" or commandName == "debug" then

		if ((getElementData(source, "user:admin") or 0) >= 10) or getElementData(source, "aclLogin") then -- 10
			if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(source) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

			triggerClientEvent(source, "debug->ChangeState", source)
		else
			cancelEvent()
		end
	end
end)