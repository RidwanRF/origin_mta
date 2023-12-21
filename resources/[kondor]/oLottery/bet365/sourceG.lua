core = exports.oCore
color, r, g, b = core:getServerColor()
inventory = exports.oInventory
chat = exports.oChat

betLaptopTable = {2153, 954.94757080078, -1336.2227783203, 13.537890434265, 0, 0}


footballHungaryTeamA = {
	"Ferencvárosi TC",
	"Kecskeméti TE",
	"Paks",
	"Kisvárda",
	"Puskás Akadémia",
	"Zalaegerszeg",
}

footballHungaryTeamB = {
	"MOL Fehérvár FC",
	"Debreceni VSC",
	"Újpest",
	"Honvéd FC",
	"Vasas",
	"Mezőkövesd",
}

footballSpainTeamA = {
	"FC Barcelona",
	"Athletic Bilbao",
	"Atletico Madrid",
	"Real Sociedad",
	"Valencia",
	"Celta Vigo",
	"Girona",
	"Valladolid",
	"Sevilla",
	"Cadiz",
}

footballSpainTeamB = {
	"Real Madrid",
	"Betis",
	"Osusana",
	"Villareal",
	"Rayo Vallecano",
	"Mallorca",
	"Getafe",
	"Espanyol",
	"Almeria",
	"Elche",
}

function generateTeamA(nation)
	if nation == "hungary" then
		return footballHungaryTeamA[math.random(1,6)]
	elseif nation == "spain" then
		return footballSpainTeamA[math.random(1,10)]
	end
end

function generateTeamB(nation)
	if nation == "hungary" then
		return footballHungaryTeamB[math.random(1,6)]
	elseif nation == "spain" then
		return footballSpainTeamB[math.random(1,10)]
	end
end

function generateFullRandomTeam()
	local selectNum = math.random(1,4)
	if selectNum == 1 then
		return footballHungaryTeamA[math.random(1,6)]
	elseif selectNum == 2 then
		return footballSpainTeamA[math.random(1,10)]
	elseif selectNum == 3 then
		return footballHungaryTeamB[math.random(1,6)]
	elseif selectNum == 4 then
		return footballSpainTeamB[math.random(1,10)]
	end
end

vorNames = {
	"Michael",
	"Johnatan",
	"George",
	"Hudson",
	"Rob",
	"Robertson",
	"Jackson",
	"Ander",
	"Oliver",
	"Juan",
}

lastNames = {
	"Carlos",
	"Huan",
	"Big",
	"White",
	"Black",
	"Canton",
	"Kellt",
	"Jason",
	"McKennie",
	"Borss",
}

highOdds = {1.9, 2, 2.2}
lowOdds = {1.6, 1.7, 1.8}

function generateRandomOdds()
	local num = math.random(1,2)
	if num == 1 then
		return highOdds[math.random(1,3)]
	else
		return lowOdds[math.random(1,3)]
	end
end
