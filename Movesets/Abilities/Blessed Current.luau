const WaterModule = require(script.Parent)
const VFX = require(game.ReplicatedStorage.Modules.Shared.VFX)
const HITBOX = require(game.ReplicatedStorage.Modules.Shared.Hitbox)
const DAMAGE = require(game.ReplicatedStorage.Modules.Server.Damage)

const Debris = game:GetService("Debris")


type water = WaterModule.Water


local ability = {}

--[[
	buff walkspeed
	damage + water status enemies
	animation somehow
	
]]


const DMG = 1 -- per tick/second
const LASTING_TIME = 5
const TOTAL_DAMAGE = DMG * LASTING_TIME

function ability:Activate(character: water, data)
	
	local cframe = character.Root.CFrame * CFrame.new(0, -2, -5) * CFrame.Angles(0, math.rad(270), 0)
	
	local current = VFX.new("Current")
	current:Pivot(cframe)
	current:Play()
	
	task.delay(LASTING_TIME, function() current:Destroy() end)
	
	-- buffs
	local caster = character.Player.Character
	local casterHit = false
	
	local hitboxData: HITBOX.Data = {Size = Vector3.new(81, 3, 48), CFrame = cframe, Time = LASTING_TIME}
	local hitboxEvent = HITBOX.Start(hitboxData)
	
	hitboxEvent.Event:Connect(function(hitTable)
		
		local alreadyHit = {}
		
		for _, hit: Part in hitTable do
			local hum = hit.Parent:FindFirstChild("Humanoid")
			if not hum then continue end
			
			local char = hum.Parent
			if alreadyHit[char] then continue end
			
			alreadyHit[char] = true			
			
			if char == caster then
				if not casterHit then
					casterHit = true
					hum.WalkSpeed += 15
					char:AddTag("LockedSpeed")
					task.delay(3, function()
						hum.WalkSpeed -= 5
						hum:RemoveTag("LockedSpeed")
					end)
					
					continue
				end
				
				continue
			end
			
			DAMAGE.Apply(hum, DMG, character.Player)
		end
	end)
end

return ability
