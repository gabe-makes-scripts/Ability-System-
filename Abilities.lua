local module = {}
local Characters = {}

function module.CharacterData(plr: Player)
	if not plr or not plr:IsA("Player") then warn("not valid player")  return nil end
	
	local data: character_data = {
		Character = plr.Character,
		Humanoid = plr.Character:WaitForChild("Humanoid"),
		Root = plr.Character:WaitForChild("HumanoidRootPart"),
		RightArm = plr.Character:WaitForChild("Right Arm"),
	}
	
	return data
end

function module.Ragdoll(character: Model, ragTime)
	if character:FindFirstChild("IsRagdoll") then
		local ragdoll: BoolValue = character:FindFirstChild("IsRagdoll")
		ragdoll.Value = true
		
		task.delay(ragTime, function()
			ragdoll.Value = false
		end)
	end
end

function module.Activate(data, ability)
	local character = Characters[data.Player]
	if not character then
		return
	end
	
	--print(character)
	--print(getmetatable(character))
	--print(character.Activate)
	
	character:Activate(ability, data)


end

function module.Punch(plr)
	local character = plr:GetAttribute("Character")
	local charmodule = require(script:FindFirstChild(character))
	if not charmodule then return end
	
	charmodule.Punch(plr)
end 

function module.spawn(player)
	local characterName = player:GetAttribute("Character")
	repeat
		characterName = player:GetAttribute("Character")
	until characterName

	local CharacterClass = require(script[characterName])

	Characters[player] = CharacterClass.new(player)

	local hum = player.Character:WaitForChild("Humanoid")
	hum:SetAttribute("BaseWalkSpeed", hum.WalkSpeed)

	if Characters[player].Spawn then
		Characters[player]:Spawn()
	end
end

export type character_data = {
	Character: Model,
	Humanoid: Humanoid,
	Root: Part,
	RightArm: Part
}

export type data = {
	HoldTime: number,
	Player: Player
}

return module
