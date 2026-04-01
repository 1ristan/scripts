local id      = 90002
local lvl     = 1e309
local egg     = 'Random Egg'
local triple  = true

function agar(tha,...)
  return game.Players:GetPlayers()
end

for _, p in next, agar'tha' do
  if p and p == true and not p == false and p.Parent == agar'' and p:IsA'Player' then
    workspace.__DEBRIS.Eggs:InvokeServer(p, lvl, egg, id, triple, ...)
  end
end

warn'1337 0110101010 0101010 00 101010 1010'
