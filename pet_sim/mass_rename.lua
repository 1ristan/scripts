Name = "WeirdChamp"

for _, pet in pairs(workspace.__REMOTES.Core["Get Stats"]:InvokeServer().Save.Pets) do
    task.spawn(function()
        workspace.__REMOTES.Game.Rename:InvokeServer('Rename', pet.id, Name)
    end)
end
