local StateModule = {}
local CharacterModule = require(game.ReplicatedStorage.Modules.CharacterHandler)

local StateTable = {
	Stunned = {},
	Invincible = {}
}

local States = {
	Stunned = function(character, bool)
		local humanoid = character.Humanoid
		if bool == true then
			humanoid.WalkSpeed = 0
		elseif bool == false then
			humanoid.WalkSpeed = 16
		end
	end,
	Invincible = function(character, bool)

	end,
}

function StateModule.LoadStates(character)
	for stateName, _ in pairs(StateTable) do
		StateTable[stateName][character] = false
	end
	character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(workspace) then
			StateModule.UnloadStates(character)
		end
	end)
end

function StateModule.UnloadStates(character)
	for stateName, _ in pairs(StateTable) do
		StateTable[stateName][character] = nil
	end
end

function StateModule.SetState(character, stateName)
	local stateCategory = StateTable[stateName]
	if stateCategory then
		local newStateValue = not stateCategory[character]
		stateCategory[character] = newStateValue
		local stateFunction = States[stateName]
		if stateFunction then
			stateFunction(character, newStateValue)
		end
	end
end

function StateModule.ReturnState(character, stateName)
	local stateCategory = StateTable[stateName]
	if stateCategory then
		return stateCategory[character]
	end
end

return StateModule