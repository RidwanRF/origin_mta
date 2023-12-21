connection = exports.oMysql:getDBConnection()

local lotteryTime = 60 * 60 * 24 * 7 -- 7 nap


addEventHandler("onResourceStart", resourceRoot, function()
   local tick = getTickCount()
   local loaded = 0
   dbQuery(function(query)
      local query, query_lines = dbPoll(query, 0)
      if query_lines > 0 then
         for k,v in pairs(query) do
            loadLotterys(v["id"])
            loaded = loaded + 1
         end
        	--outputDebugString("lotterys: "..loaded.." / "..query_lines.." loaded in "..(getTickCount()-tick).."ms!",0,255,153,51)
      end
   end,connection, "SELECT id FROM lottery")



   local luckyPed = createPed(luckyPedTable[1],luckyPedTable[2],luckyPedTable[3],luckyPedTable[4])
   setElementData(luckyPed, "ped:name", "Robertson")
   setElementData(luckyPed, "ped:prefix", "Ötöslottó")
   setElementData(luckyPed, "lucky:ped", true)
   setElementInterior(luckyPed, luckyPedTable[5])
   setElementDimension(luckyPed, luckyPedTable[6])
   setElementFrozen(luckyPed, true)

   for k, v in pairs(getElementsByType("player")) do 
		setElementData(v,"lotto_info",true)
	end
end)

function loadLotterys(id)
    dbQuery(function(query)
      local query, query_lines = dbPoll(query, 0);
      if query_lines > 0 then
         for k,v in pairs(query) do 
            setElementData(resourceRoot,"lotto_num1",v["num1"])
		   	setElementData(resourceRoot,"lotto_num2",v["num2"])
		   	setElementData(resourceRoot,"lotto_num3",v["num3"])
		   	setElementData(resourceRoot,"lotto_num4",v["num4"])
		   	setElementData(resourceRoot,"lotto_num5",v["num5"])
		   	setElementData(resourceRoot,"lotto_winnercode",v["winnercode"])
         end
      end
      --outputDebugString("Sikeresen betöltött a lottery rendszer",0,0,255,0)
    end,connection,"SELECT * FROM lottery WHERE id=?",id) 
end

function createLottoFive(player,cmd,num1,num2,num3,num4,num5)
	local num1 = 0
	local num2 = 0
	local num3 = 0
	local num4 = 0
	local num5 = 0
	if (num1) == 0 then
		num1 = math.random(1,90)
		num2 = math.random(1,90)
		if num2 == num1 then return end
		num3 = math.random(1,90)
		if num3 == num2 or num3 == num1 then return end
		num4 = math.random(1,90)
		if num4 == num2 or num4 == num1 or num4 == num3 then return end
		num5 = math.random(1,90)
		if num5 == num2 or num5 == num1 or num5 == num3 or num5 == num4 then return end

		setElementData(resourceRoot,"lotto_num1",num1)
   	setElementData(resourceRoot,"lotto_num2",num2)
   	setElementData(resourceRoot,"lotto_num3",num3)
   	setElementData(resourceRoot,"lotto_num4",num4)
   	setElementData(resourceRoot,"lotto_num5",num5)
   	setElementData(resourceRoot,"lotto_winnercode",getElementData(resourceRoot,"lotto_num1")..getElementData(resourceRoot,"lotto_num2")..getElementData(resourceRoot,"lotto_num3")..getElementData(resourceRoot,"lotto_num4")..getElementData(resourceRoot,"lotto_num5")) -- ez lesz a nyertes szelvények valueja
	end

	outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az ötöslottó nyerőszámai: #7cc576"..getElementData(resourceRoot,"lotto_num1").."#ffffff, #7cc576"..getElementData(resourceRoot,"lotto_num2").."#ffffff, #7cc576"..getElementData(resourceRoot,"lotto_num3").."#ffffff, #7cc576"..getElementData(resourceRoot,"lotto_num4").."#ffffff, #7cc576"..getElementData(resourceRoot,"lotto_num5"), getRootElement(), 255, 255, 255, true)
	dbExec(connection, "INSERT INTO lottery SET num1 = ?, num2 = ?, num3 = ?, num4 = ?, num5 = ?, winnercode = ?, created = ?", getElementData(resourceRoot,"lotto_num1"), getElementData(resourceRoot,"lotto_num2"), getElementData(resourceRoot,"lotto_num3"), getElementData(resourceRoot,"lotto_num4"), getElementData(resourceRoot,"lotto_num5"),getElementData(resourceRoot,"lotto_num1")..getElementData(resourceRoot,"lotto_num2")..getElementData(resourceRoot,"lotto_num3")..getElementData(resourceRoot,"lotto_num4")..getElementData(resourceRoot,"lotto_num5"), getRealTime().timestamp)
end
-- setTimer(createLottoFive(),lotteryTime,1)

function createLottoFiveAdmin(player)
	if getElementData(player,"user:admin") >= 8 then
		createLottoFive()
	end
end
addCommandHandler("createlottofive",createLottoFiveAdmin)

function lastLotto(player)
	local lottonum1 = getElementData(resourceRoot,"lotto_num1")
	local lottonum2 = getElementData(resourceRoot,"lotto_num2")
	local lottonum3 = getElementData(resourceRoot,"lotto_num3")
	local lottonum4 = getElementData(resourceRoot,"lotto_num4")
	local lottonum5 = getElementData(resourceRoot,"lotto_num5")
	local lottocode = getElementData(resourceRoot,"lotto_winnercode")

	outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az utolsó lottó nyerőszámai a következőek voltak: "..lottonum1..", "..lottonum2..", "..lottonum3..", "..lottonum4..", "..lottonum5.." "..lottocode, player, 255, 255, 255, true)
end
addCommandHandler("showlastlotto",lastLotto)

function sendInfoToChat()
	for k, v in pairs(getElementsByType("player")) do 
		if getElementData(v,"lotto_info") then
			outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az eheti ötöslottó nyerőszámai a következőek voltak: #7cc576"..(getElementData(resourceRoot,"lotto_num1") or 0).."#ffffff, #7cc576"..(getElementData(resourceRoot,"lotto_num2") or 0).."#ffffff, #7cc576"..(getElementData(resourceRoot,"lotto_num3") or 0).."#ffffff, #7cc576"..(getElementData(resourceRoot,"lotto_num4") or 0).."#ffffff, #7cc576"..(getElementData(resourceRoot,"lotto_num5") or 0), v, 255, 255, 255, true)
		end
	end
end
--setTimer(sendInfoToChat(), 300000, 1) -- 5 percenként mutatja.

function setInfoState(player)
	if getElementData(player,"lotto_info") then
		setElementData(player,"lotto_info",false)
		outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Sikeresen kikapcsoltad a lottó infót!", player, 255, 255, 255, true)
	else
		setElementData(player,"lotto_info",true)
		outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Sikeresen bekapcsoltad a lottó infót!", player, 255, 255, 255, true)
	end
end
addCommandHandler("lottoinfo",setInfoState)

function giveLottoPaper(player,value)
	if getElementData(player,"char:money") >= 500 then
		exports.oInventory:giveItem(player, 241, value, 1, 0)
		setElementData(player,"char:money",getElementData(player,"char:money") - 500)
		outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Sikeresen kitöltötted a lottót! (Inventory, iratok között találod!)", player, 255, 255, 255, true)
	else
		outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."Nincs elegendő pénzed!", player, 255, 255, 255, true)
	end
end
addEvent("giveLottoPaper",true)
addEventHandler("giveLottoPaper",getRootElement(),giveLottoPaper)