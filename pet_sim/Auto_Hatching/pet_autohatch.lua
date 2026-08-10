--[[
    Script developed by tar

    Information
    	DELETE_UI_UPDATER		- Stops UI Updates (No Lag)
    	COMBINE					- Automatically combine pets
    	TIER					- Egg Tier to purchase
    	WHITELIST				- Pets to not delete
    	TOTAL_EGGS_TO_OPEN		- Stops once it hits the desired amount of eggs to open
    	
    Notes
    	Auto Combine
    		- Be aware that if you use this script, your half rainbow half dark matter pets *can* get combined aswell.
    		- The script will not auto combine pets that are not whitelisted.
]]

local SETTINGS = {
	DELETE_UI_UPDATER	= false,
	TIER				= "Tier 1",
	TOTAL_EGGS_TO_OPEN	= 'inf',
	
	AUTO_COMBINE		= {
		ENABLED	= false,
		CONFIGS	= {
			GOLDEN		= true,
			RAINBOW		= true,
			DARK_MATTER = true
		}
	},
	
	WHITELIST			= {
		"Dominus Messor", "Dominus Frigidus", "Dominus Empyreus",	-- Tier 10
		"Mortuus", 													-- Tier 12
		"1NE", "ZER0",												-- Tier 14
		"Ame Damnee", "Domortuus",									-- Tier 15
		"C0RE", "C0RE SH0CK", "Cyborg Dominus",						-- Tier 16
		"Dominus Electric", "Dominus Huge",							-- Tier 17
		"Hydra", "Agony",											-- Tier 18
		"Randolph",													-- Christmas Tier 3 & 4
		"Giant Penguin"												-- Christmas Tier 4
	}
}

-- [[ DO NOT TOUCH THE CODE BELOW ]]

local LIB = {
	[77002]	= 'Festive Dragon',
	[9004]	= 'Wavy Cheeta',
	[7004]	= 'Dragon',
	[8004]	= 'Demon',
	[5004]	= 'Bat',
	[6004]	= 'Ladybug',
	[3004]	= 'Pig',
	[4004]	= 'Seal',
	[1004]	= 'Lamb',
	[2004]	= 'Mouse',
	[16012]	= 'Cyborg Dominus',
	[16009]	= 'Cyborg Demon',
	[77003]	= 'Snow Spike',
	[15005]	= 'Green Gummy Bear',
	[13007]	= 'Space Dragon',
	[10004]	= 'Electric Slime',
	[66002]	= 'Zombie Dog',
	[15006]	= 'Yellow Gummy Bear',
	[15008]	= 'Rainbow',
	[16002]	= 'Cyborg Dog',
	[12003]	= 'Angel',
	[13001]	= 'Alien',
	[15009]	= 'Dark Candy Corn',
	[17003]	= 'Dominus Noob',
	[66003]	= 'Spider',
	[12007]	= 'Mortuus',
	[12005]	= 'Ice Queen',
	[11004]	= 'Lava Watermelon',
	[76004]	= 'Festive Racoon',
	[66004]	= 'Pumpkin',
	[16006]	= 'Red Space Ranger',
	[16001]	= 'Cyborg Cat',
	[11002]	= 'Sherbert',
	[76001]	= 'Festive Cat',
	[66001]	= 'Zombie Cat',
	[79003]	= 'Giant Penguin',
	[15007]	= 'Cookie',
	[1001]	= 'Cat',
	[3001]	= 'Dalmatian',
	[2001]	= 'Brown Cat',
	[5001]	= 'Owl',
	[4001]	= 'Koala',
	[7001]	= 'Watermelon',
	[6001]	= 'Cheeta',
	[9001]	= 'Fantasy Dragon',
	[8001]	= 'Bomb',
	[66006]	= 'Ghostdeeri',
	[12004]	= 'Fire King',
	[90003]	= 'Red Snake',
	[78002]	= 'Gingerbread',
	[17006]	= 'Dominus Damnee',
	[10003]	= 'Lava Turtle',
	[15001]	= 'Candy Cane',
	[18002]	= 'Spike',
	[17009]	= 'Dominus Huge',
	[14005]	= 'Space Bear',
	[2005]	= 'White Bunny',
	[1005]	= 'Orange Cat',
	[10002]	= 'Lava Dalmatian',
	[8005]	= 'Cyclops',
	[9005]	= 'Wavy Tiger',
	[4005]	= 'Racoon',
	[3005]	= 'Panda',
	[13004]	= 'Space Cat',
	[5005]	= 'Bee',
	[18006]	= 'Agony',
	[18001]	= 'Aesthetic Cat',
	[13002]	= 'Puffer',
	[10001]	= 'Lava Zebra',
	[17007]	= 'Dominus Rainbow',
	[90001]	= 'BIG Maskot',
	[11005]	= 'Wavy Bee',
	[10006]	= 'Dominus Messor',
	[14004]	= 'Space Cyclops',
	[17001]	= 'Dominus Pumpkin',
	[12002]	= 'Reaper',
	[2002]	= 'White Cat',
	[3002]	= 'Bear',
	[4002]	= 'Crocodile',
	[5002]	= 'Monkey',
	[6002]	= 'Tiger',
	[7002]	= 'Yeti',
	[8002]	= 'Ghost',
	[9002]	= 'Cherry Bomb',
	[11006]	= 'Unicorn',
	[90010]	= 'Huge Cat',
	[15004]	= 'Green Lollipop',
	[16011]	= 'C0RE SH0CK',
	[90008]	= 'Noob',
	[1002]	= 'Dog',
	[12006]	= 'Immortuos',
	[90009]	= 'Love Cat',
	[14009]	= '1NE',
	[76002]	= 'Festive Dog',
	[90006]	= 'Dominus Partner',
	[90005]	= 'Wavy Snake',
	[16004]	= 'Cyborg',
	[90004]	= 'Purple Snake',
	[10008]	= 'Dominus Empyreus',
	[90002]	= 'Green Snake',
	[79002]	= 'Festive C0RE',
	[13003]	= 'Wooga',
	[79001]	= 'Festive Immortuos',
	[78005]	= 'Randolph',
	[78004]	= 'Festive Dominus',
	[12001]	= 'Tank',
	[78003]	= 'Reindeer',
	[78001]	= 'Festive Ame Damnee',
	[18004]	= 'Chimera',
	[77001]	= 'Festive Seal',
	[13005]	= 'Space Dog',
	[76003]	= 'Festive Bunny',
	[90007]	= 'Love Dog',
	[66010]	= 'Skeleton Ghost',
	[66009]	= 'Willow Wisp Green',
	[66008]	= 'Willow Wisp',
	[66007]	= 'Sorrow',
	[66005]	= 'Skeleton',
	[18005]	= 'Hydra',
	[77004]	= 'Ice Spike',
	[18003]	= 'Magic Fox',
	[17008]	= 'Dominus Electric',
	[17005]	= 'Dominus HeadStack',
	[13006]	= 'Space Bunny',
	[16005]	= 'Space Ranger',
	[17002]	= 'Dominus Cherry',
	[16010]	= 'C0RE',
	[16008]	= 'RoVer',
	[16007]	= 'Friendly Cyborg',
	[17004]	= 'Dominus Wavy',
	[14002]	= 'HeadStack',
	[16003]	= 'Computer',
	[15011]	= 'Domortuus',
	[15010]	= 'Ame Damnee',
	[15003]	= 'Red Lollipop',
	[15002]	= 'Candy Corn',
	[10007]	= 'Dominus Frigidus',
	[14008]	= 'ZER0',
	[6003]	= 'Zebra',
	[5003]	= 'Turtle',
	[4003]	= 'Platypus',
	[3003]	= 'Polar Bear',
	[2003]	= 'White Dog',
	[1003]	= 'Bunny',
	[14007]	= 'Dark Saturn',
	[10005]	= 'Electric Ghost',
	[14006]	= 'Saturn',
	[14003]	= 'Space Owl',
	[14001]	= 'Revurse',
	[11003]	= 'Robot',
	[11001]	= 'Zombie',
	[9003]	= 'Wavy Zebra',
	[8003]	= 'Cherry Monkey',
	[7003]	= 'Slime'
}

local TOTAL_PETS_PURCHASED = 0

if SETTINGS.DELETE_UI_UPDATER then
	game.Players.LocalPlayer.PlayerGui.Events:ClearAllChildren()
end

local IS_BLACKLISTED = function(id)
	return table.find(SETTINGS.WHITELIST, LIB[tonumber(id)]) == nil
end

local GET_STATS = function()
	return workspace.__REMOTES.Core["Get Stats"]:InvokeServer()
end

local COMBINE = function()
	local STATS = GET_STATS()

	for I, PET in pairs(GET_STATS().Save.Pets) do
		local TYPE = PET.n
		if not IS_BLACKLISTED(TYPE) and math.random(4) == 3 then
			if not (PET.g or PET.r or PET.dm) and SETTINGS.AUTO_COMBINE.CONFIGS.GOLDEN then
				task.spawn(function() workspace.__REMOTES.Game["Golden Pets"]:InvokeServer(PET.id) end)
			elseif PET.g and not (PET.r or PET.dm) and SETTINGS.AUTO_COMBINE.CONFIGS.RAINBOW then
				task.spawn(function() workspace.__REMOTES.Game["Rainbow Pets"]:InvokeServer(PET.id) end)
			elseif PET.r and not (PET.g or PET.dm) and SETTINGS.AUTO_COMBINE.CONFIGS.DARK_MATTER then
				task.spawn(function() workspace.__REMOTES.Game["Dark Matter Pets"]:InvokeServer(PET.id) end)
			end
		end
	end
end

repeat task.wait()
	local SAVE = GET_STATS().Save
	local N_PETS_TO_BUY = (SAVE.PetSlots - #SAVE.Pets)
	local DELETE_PETS_TABLE = {}
	local CONFIRMED = 0

	for I = 1, N_PETS_TO_BUY do 
		task.spawn(function()
			local SUCCESS, PET = workspace.__REMOTES.Game.Shop:InvokeServer("Buy", "Eggs", SETTINGS.TIER)

			if SUCCESS and PET and IS_BLACKLISTED(PET[1][1].n) then
				DELETE_PETS_TABLE[#DELETE_PETS_TABLE + 1] = PET[1][1].id
			end

			CONFIRMED = CONFIRMED + 1
		end)
	end

	repeat task.wait() until CONFIRMED == N_PETS_TO_BUY
	
	workspace.__REMOTES.Game.Inventory:InvokeServer("MultiDelete", DELETE_PETS_TABLE)
	
	if SETTINGS.AUTO_COMBINE.ENABLED then
		task.spawn(COMBINE)
	end
	
until (TOTAL_PETS_PURCHASED >= tonumber(SETTINGS.TOTAL_EGGS_TO_OPEN))
