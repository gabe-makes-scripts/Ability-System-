local module = {}

local Debris = game:GetService("Debris")
local debug = true
local update_time = .15

local function createhitbox(Data: Data)
	
	if not Data.CFrame and not Data.Parent then return warn("not valid cframe") end	
	
	local size = Data.Size or Vector3.new(5, 5, 5)
	local cframe 
	
	if Data.Parent then
		cframe = Data.Parent.PrimaryPart.CFrame or Data.Parent.CFrame
	else
		cframe = Data.CFrame
	end

	
	local results = workspace:GetPartBoundsInBox(cframe, size)
	
	if debug == true then
		task.spawn(function()
			local part = Instance.new("Part")
			part.Transparency = .9
			part.BrickColor = BrickColor.Red()
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = cframe 
			part.Size = size
			part.CanQuery = false
			part.Parent = workspace.Hitboxes
			Debris:AddItem(part, .5)
		end)
	end
	
	return results
end

function module.Once(Data: Data)
	return createhitbox(Data)
end

function module.Start(Data: Data)
	local time = Data.Time or 3

	local hitbox = {}
	hitbox.Event = Instance.new("BindableEvent")

	local running = true

	task.delay(time, function()
		running = false
	end)

	task.spawn(function()
		while running do
			local results = createhitbox(Data)
			hitbox.Event:Fire(results)
			task.wait(Data.UpdateTime or update_time)
		end

		hitbox.Event:Destroy()
	end)

	return hitbox.Event
end

export type Data = {
	Size: Vector3,
	Time: number,
	Parent: Model,
	CFrame: CFrame?,
	UpdateTime: number,
}

return module
