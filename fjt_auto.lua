lp = game.Players.LocalPlayer

fireproximityprompt = fireproximityprompt or function(o,a,s)
    if o:isA"ProximityPrompt"then a=a or 1
    local p=o.HoldDuration if s then o.HoldDuration=0
    end for i=1,a do o:InputHoldBegin()if not s then 
    wait(o.HoldDuration)end o:InputHoldEnd()end
    o.HoldDuration=p end
end

touch = function(part)
    if ffc(lp.Character, "Head") then
        firetouchinterest(part, lp.Character.Head, 1)
        firetouchinterest(part, lp.Character.Head, 0)
    end
end

wfc = function(part, str)
    return part:WaitForChild(str)
end

ffc = function(part, str, bool)
    return part:FindFirstChild(str, bool)
end

if not lp.Team then
    touch(ffc(workspace, "Entrance", true))
    repeat wait() until lp.Team ~= nil and ffc(lp,"leaderstats")
end

teamname = lp.Team.Name

rTycoon = function()
    local t = wfc(workspace.Tycoons, teamname)
    wfc(t, "Buttons")
    wfc(t, "Drops")
    wfc(t, "Purchased")
    return t
end

autopick = function()
    rTycoon().Drops.ChildAdded:connect(function(c)
        game.ReplicatedStorage.CollectFruit:fireServer(c)
    end)
end

returnMoney = function()
    return lp.leaderstats.Money.Value
end

function retrievecost(button)
    local t = button.ButtonLabel.CostLabel.Text
    if t == "FREE!" then return 0 else return tonumber((t:gsub(",",""))) end
end

uselessbuttons = {"JuiceSpeedUpgrade8","AutoCollect"}

function prestige()
    local statue = wfc(rTycoon().Purchased, "Golden Tree Statue")
    lp.Character.HumanoidRootPart.CFrame = statue.StatueBottom.CFrame
    wait(.1)
    repeat wait()
        if statue and ffc(ffc(statue, "StatueBottom"), "PrestigePrompt") then
            fireproximityprompt(statue.StatueBottom.PrestigePrompt)
        end
    until ffc(rTycoon().Purchased, "Golden Tree Statue") == nil
    wait(1)
    autopick()
end

function buy()
    local btns = rTycoon().Buttons
    
    local lowestbutton = {cost=9e18,name=""}
    
    for i, button in pairs(btns:children()) do
        if not table.find(uselessbuttons, button.Name) and retrievecost(button) < lowestbutton.cost then
            lowestbutton = {cost=retrievecost(button), name=button.Name}
        end
    end
    
    if returnMoney() >= lowestbutton.cost then
        local button = ffc(btns, lowestbutton.name)
        repeat wait() touch(button) until button.Parent ~= btns
        
        if lowestbutton.name == "Prestige" then
            prestige()
        end
    end
end


spawn(function() -- auto frenzy
    local osp = workspace.ObbyParts.ObbyStartPart
    while true do
        if osp.Color == Color3.new(1,0,0) then
            repeat wait() until osp.Color == Color3.new(0,1,0)
        end
        
        if not lp.Character.PrimaryPart then repeat wait() until lp.Character.PrimaryPart ~= nil end
        
        touch(workspace.ObbyParts.RealObbyStartPart)
        wait()
        touch(workspace.ObbyParts.VictoryPart)
        wait(1.5)
    end
end)

autopick()

for i,v in pairs(rTycoon().Drops:children()) do
    game.ReplicatedStorage.CollectFruit:fireServer(c)
end

wait(1)

if ffc(rTycoon().Purchased, "Golden Tree Statue") then
    prestige()
end

repeat
    local jb = ffc(rTycoon(),"StartJuiceMakerButton",true)
    local jp = jb.PromptAttachment.StartPrompt
    
    if lp.Character.PrimaryPart then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(jb.Position.X+2, 3,jb.Position.Z))
        fireproximityprompt(jp)
        buy()
    end
    wait(.1)
until 0==1
