-- Get Player Information Example
-- This script demonstrates how to access player data

local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player then
    print("=== Player Information ===")
    print("Name: " .. player.Name)
    print("UserId: " .. player.UserId)
    print("AccountAge: " .. player.AccountAge)
    
    if player.Character then
        print("Character: " .. player.Character.Name)
        print("Position: " .. tostring(player.Character.PrimaryPart.Position))
    else
        print("Character: Not loaded")
    end
else
    print("ERROR: Player not found!")
end
