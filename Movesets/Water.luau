-- config
local MAX_WATER = 100

local module = {}
module.__index = module

export type Water = {
	Player: Player,
	Character: Model,
	Humanoid: Humanoid,
	Root: BasePart,
	RightArm: BasePart,

	Abilities: {[string]: any},

	Activate: (self: Water, name: string, data: any) -> (),
}

function module.new(player: Player): Water
	local abilities = require(script.Parent)
	local charData: abilities.character_data = abilities.CharacterData(player) 
	
	local newAbilities = {}
	newAbilities.Abilities = {}
	newAbilities.Player = player
	newAbilities.Character = charData.Character
	newAbilities.Humanoid = charData.Humanoid
	newAbilities.Root = charData.Root
	newAbilities.RightArm = charData.RightArm
	
	for _, child in ipairs(script:GetChildren()) do
		if child:IsA("ModuleScript") then
			print("loading", child.Name)
			newAbilities.Abilities[child.Name] = require(child)
		end
	end
	
	setmetatable(newAbilities, module)
	return newAbilities
end

function module:Activate(name, data)
	local ability = self.Abilities[name]
	if ability then
		ability:Activate(self, data)
		print("activated water ability")
	end
end

return module
