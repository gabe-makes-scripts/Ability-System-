--[[
made by gabe-makes-scripts on github
check out my youtube: https://www.youtube.com/@Ragadevelops

how to use: video coming soon!!

]]

--Varibles
local HitboxHandler = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local CharacterHandler = require(game.ReplicatedStorage.Modules.CharacterHandler)
local AudioHandler = require(game.ReplicatedStorage.Modules.AudioHandler)
local VFXHandler = require(game.ReplicatedStorage.Modules.VfxHandler)
local StateHandler = require(game.ReplicatedStorage.Modules.StateHandler) --get this from other project on github in order for this to work


--Logic
function HitboxHandler.Projectile(startPos: Vector3, endPos: Vector3, damage: number, stunTime: number, timeLasting: number, part: Part)
	part.Position = startPos

	local TweenInfoProjectile = TweenInfo.new(timeLasting, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local projectileTween = TweenService:Create(part, TweenInfoProjectile, {Position = endPos})

	projectileTween:Play()
	HitboxHandler.HitDetection(part, timeLasting, damage, stunTime, 5)

	Debris:AddItem(part, timeLasting)
end

function HitboxHandler.HitDetection(part: Part, timeLasted: number, damage: number, stunTime: number, hitDelay: number)
	local hitList = {}

	local heartbeat: RBXScriptConnection
	heartbeat = RunService.Heartbeat:Connect(function()
		local results = workspace:GetPartsInPart(part)
		for _, result in ipairs(results) do
			local character = result.Parent
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or hitList[character] then continue end

			hitList[character] = true

			if StateHandler.ReturnState(character, "Stunned") == true then
				continue
			end

			StateHandler.SetState(character, "Stunned")
			humanoid:TakeDamage(damage)

			task.delay(hitDelay or stunTime, function()
				hitList[character] = nil
			end)

			task.delay(stunTime, function()
				StateHandler.SetState(character, "Stunned")
			end)
		end
	end)

	task.delay(timeLasted, function()
		heartbeat:Disconnect()
	end)
end

function HitboxHandler.Grab(part: Part, attacker: Model, timeLasting: number)
	local results = workspace:GetPartsInPart(part)
	for _, result in ipairs(results) do
		local character = result.Parent
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then continue end
		if humanoid == attacker:FindFirstChildOfClass("Humanoid") then continue end

		if StateHandler.ReturnState(character, "Stunned") == true then return end

		StateHandler.SetState(character, "Stunned")
		humanoid.WalkSpeed = 0
		humanoid.PlatformStand = true

		character:PivotTo(attacker.PrimaryPart.CFrame * CFrame.new(0, 0, -3)) --tp victim infront of attacker

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = attacker:FindFirstChild("HumanoidRootPart")
		weld.Part1 = character:FindFirstChild("HumanoidRootPart")
		weld.Parent = attacker.HumanoidRootPart

		task.delay(timeLasting, function()
			StateHandler.SetState(character, "Stunned")
			humanoid.WalkSpeed = 16
			humanoid.PlatformStand = false
			weld:Destroy()
		end)

		return character
	end
	return nil
end

function HitboxHandler.DetectOnce(part: Part, attacker: Model, multHit: boolean)
	local results = workspace:GetPartsInPart(part)
	local hitTable = {}

	for _, result in ipairs(results) do
		local character = result.Parent
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then continue end
		if humanoid == attacker:FindFirstChildOfClass("Humanoid") then continue end -- skips over attacker

		if multHit then
			table.insert(hitTable, character)
		else
			return character 
		end
	end

	if multHit then
		return hitTable
	end
	return nil
end

return HitboxHandler