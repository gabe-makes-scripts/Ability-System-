local VFX = {}
VFX.__index = VFX

local Assets = game:GetService("ReplicatedStorage").Assets.VFX
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")


function VFX.new(name: string)
	local template = Assets:FindFirstChild(name, true)
	assert(template, (`VFX "{name}" does not exist`))

	local self = setmetatable({}, VFX)

	self.Model = template:Clone()
	self.Model.Parent = workspace

	self.Playing = false
	self.Connection = nil
	self.Weld = nil

	return self
end


function VFX:Attach(part: BasePart)
	self.Model:PivotTo(part.CFrame)

	local primary = self.Model.PrimaryPart
	assert(primary, "VFX model needs a PrimaryPart.")

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = primary
	weld.Part1 = part
	weld.Parent = primary

	self.Weld = weld

	return self
end

function VFX:Pivot(cframe: CFrame)
	self.Model:PivotTo(cframe)
	return self
end


function VFX:Follow(part: BasePart)
	if self.Connection then
		self.Connection:Disconnect()
	end

	self.Connection = RunService.Heartbeat:Connect(function()
		self.Model.CFrame = part.CFrame
	end)

	return self
end


function VFX:Play()
	self.Playing = true

	for _, obj in ipairs(self.Model:GetDescendants()) do
		if obj:IsA("ParticleEmitter") then
			obj.Enabled = true

			local burst = obj:GetAttribute("Burst")
			if burst then
				obj:Emit(burst)
			end

		elseif obj:IsA("Beam") then
			obj.Enabled = true
		end
	end

	return self
end


function VFX:Scale(multiplier: number)
	for _, emitter in ipairs(self.Model:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local points = {}

		for _, kp in ipairs(emitter.Size.Keypoints) do
			points[#points + 1] = NumberSequenceKeypoint.new(
				kp.Time,
				kp.Value * multiplier,
				kp.Envelope
			)
		end

		emitter.Size = NumberSequence.new(points)
	end

	return self
end

function VFX:Stop(delayT: number?)
	delayT = delayT or 3

	self.Playing = false

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	for _, obj in ipairs(self.Model:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
			obj.Enabled = false
		end
	end

	Debris:AddItem(self.Model, delayT)

	return self
end

function VFX:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
	end

	self.Model:Destroy()
end

return VFX
