local AbilityHandler = {}

--//Services
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

--//Modules
local HitBoxHandler = require(game.ReplicatedStorage.Modules.Hitboxes)
local CharacterHandler = require(game.ReplicatedStorage.Modules.CharacterHandler)
local AudioHandler = require(game.ReplicatedStorage.Modules.AudioHandler)
local VFXHandler = require(game.ReplicatedStorage.Modules.VfxHandler)
local StateHandler = require(game.ReplicatedStorage.Modules.StateHandler)
local VelocityHandler = require(game.ReplicatedStorage.Modules.VelocityHandler)
local AnimationHandler = require(game.ReplicatedStorage.Modules.AnimationHandler)

--//Remotes
local PlayAnim = game.ReplicatedStorage.Remotes.PlayAnimation

local abilitiesFunction = {
	Dismantle = function(player)
		local hrp = player.Character.HumanoidRootPart
		local startPos = hrp.Position + (hrp.CFrame.LookVector * 10)
		local endPos = startPos + (hrp.CFrame.LookVector * 75)
		local dmg = CharacterHandler.ReturnAbilityStats("Thukuna", "Dismantle").Dmg
		
		local part = Instance.new("Part")
		part.Size = Vector3.new(6, 6, 6)
		part.Position = startPos
		part.Parent = workspace
		part.Transparency = 0.7
		part.Anchored = true
		part.BrickColor = BrickColor.random()
		part.CanCollide = false

		VFXHandler.StartVFX("Dismantle", 1.5, part)
		
		StateHandler.SetState(player.Character, "Stunned")
		task.delay(.2, function()
			StateHandler.SetState(player.Character, "Stunned")
		end)
		HitBoxHandler.Projectile(startPos, endPos, dmg, .5, .5, part)
		
		AudioHandler.PlayAudio("Voicelines", "Dismantle", hrp, 1)
		AudioHandler.PlayAudio("SoundEffects", "Dismantle", part, 1)
		VelocityHandler.Preset("Pushback", player.Character, player.Character, .3)
	end, 
	
	Cleave = function(player)
		local hrp = player.Character.HumanoidRootPart
		local startPos = hrp.Position + (hrp.CFrame.LookVector * 5)
		local dmg = CharacterHandler.ReturnAbilityStats("Thukuna", "Cleave").Dmg
		local grabTime = .15
		
		
		local part = Instance.new("Part")
		part.Size = Vector3.new(7, 6, 7)
		part.Position = startPos
		part.Parent = workspace
		part.Transparency = 0.7
		part.Anchored = true
		part.BrickColor = BrickColor.random()
		part.CanCollide = false
		
		Debris:AddItem(part, grabTime)
		local victim = HitBoxHandler.Grab(part, player.Character, grabTime)
		player.Character.Humanoid.WalkSpeed = 0
		player.Character.Humanoid.AutoRotate = false

		AudioHandler.PlayAudio("Voicelines", "Cleave", hrp, 1.5)
		PlayAnim:FireClient(player, "CleaveAttacker")
		
		task.delay(grabTime + .3, function()
			player.Character.Humanoid.WalkSpeed = 16
			player.Character.Humanoid.AutoRotate = true
		end)
		
		if victim == nil then return end 
		
		task.wait(grabTime)
		
		
		VelocityHandler.Preset("LeftThrow", player.Character, victim, .5)
		AudioHandler.PlayAudio("SoundEffects", "Cleave", victim, 1)
		VFXHandler.StartVFX("Cleave", .2, victim.HumanoidRootPart)
		
		victim.Humanoid:TakeDamage(dmg)
		
	end,
	
	JudgementCuts = function(player)
		local hrp = player.Character.HumanoidRootPart
		local startPos = hrp.Position + (hrp.CFrame.LookVector * 10)
		local dmg = CharacterHandler.ReturnAbilityStats("Vergal", "JudgementCuts").Dmg

		local part = Instance.new("Part")
		part.Size = Vector3.new(10, 10, 10)
		part.Position = startPos
		part.Parent = workspace
		part.Transparency = 0.7
		part.Anchored = true
		part.BrickColor = BrickColor.random()
		part.CanCollide = false
		
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
	
		local audio = game.ReplicatedStorage.Sounds.SoundEffects.Slices:Clone()
		audio.Parent = hrp
		audio.Looped = true
		audio:Play()
		
		Debris:AddItem(part, 1.8)
		Debris:AddItem(audio, 1.8)
		
		HitBoxHandler.HitDetection(part, 1.8, dmg, 0, .2)
		VFXHandler.StartVFX("Slashes", 1.8, attachment)
	end,
	
	RapidSlash = function(player: Player)
		local hrp = player.Character.HumanoidRootPart
		local dmg = CharacterHandler.ReturnAbilityStats("Vergal", "RapidSlash").Dmg

		local part = Instance.new("Part")
		part.Size = Vector3.new(5, 5, 30)
		part.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
		part.Parent = workspace
		part.Transparency = 0.7
		part.Anchored = true
		part.BrickColor = BrickColor.random()
		part.CanCollide = false
		
		local humanoid: Humanoid = player.Character.Humanoid
		humanoid.WalkSpeed = 0
		VelocityHandler.Preset("Dash", player.Character, nil, .3)
		
		task.wait(.6)
		humanoid.WalkSpeed = 16
		part:Destroy()
		
	end,
}

function AbilityHandler.ReturnAbilties()
	return abilitiesFunction
end


function AbilityHandler.Ability(player, abilityName)
	abilitiesFunction[abilityName](player)
end

return AbilityHandler
