local RoVIS = {
	Settings = {
		WalkSpeed = 16,
		JumpPower = 50,
		InfiniteJump = false,
		Spider = false,
		Noclip = false,
		Chams = false,
		JumpParticles = false,
		Trails = false,
		Snow = false,
		WinterShaders = false,
		SnowFootsteps = false,
		MenuMusic = true 
	},
	Visible = true
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService") -- Добавлен сервис для работы с тегами
local Player = Players.LocalPlayer

-- Настройка музыки меню
local BgMusic = Instance.new("Sound", game:GetService("SoundService"))
BgMusic.SoundId = "rbxassetid://1838667447"
BgMusic.Volume = 0.5
BgMusic.Looped = true

-- Переменные для звука шагов
local originalWalkSoundId = nil
local customWalkSoundId = "rbxassetid://87562273941536"

-- Создаем папку для конфигов
if not isfolder("RoVIS_Configs") then makefolder("RoVIS_Configs") end

local function getRainbowColor()
	return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoVIS"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 15)

local Border = Instance.new("UIStroke", MainFrame)
Border.Thickness = 2
Border.Transparency = 0.3

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -100, 0, 50)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
-- ИЗМЕНЕН ЗАГОЛОВОК
Title.Text = "RoVIS HUB 1.0 christmas update"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextXAlignment = Enum.TextXAlignment.Left

RunService.RenderStepped:Connect(function()
	local c = getRainbowColor()
	Border.Color = c
	Title.TextColor3 = c
end)

local CloseButton = Instance.new("TextButton", MainFrame)
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 120, 1, -70)
TabContainer.Position = UDim2.new(0, 10, 0, 60)
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Instance.new("UICorner", TabContainer)
local TabList = Instance.new("UIListLayout", TabContainer)
TabList.Padding = UDim.new(0, 5)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -150, 1, -70)
ContentContainer.Position = UDim2.new(0, 140, 0, 60)
ContentContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Instance.new("UICorner", ContentContainer)

local MobBtn = Instance.new("TextButton", ScreenGui)
MobBtn.Size = UDim2.new(0, 50, 0, 50)
MobBtn.Position = UDim2.new(0, 10, 0.5, -25)
MobBtn.Text = "Open"
MobBtn.BackgroundColor3 = Color3.fromRGB(30,30,40)
MobBtn.Visible = UserInputService.TouchEnabled
Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(1,0)
local MobStroke = Instance.new("UIStroke", MobBtn)
MobStroke.Thickness = 2
RunService.RenderStepped:Connect(function() MobStroke.Color = getRainbowColor() end)

local function toggleMenu()
	RoVIS.Visible = not RoVIS.Visible
	MainFrame.Visible = RoVIS.Visible
	
	if RoVIS.Visible and RoVIS.Settings.MenuMusic then 
		BgMusic:Play() 
	else 
		BgMusic:Stop() 
	end
end

MobBtn.MouseButton1Click:Connect(toggleMenu)
CloseButton.MouseButton1Click:Connect(toggleMenu)
UserInputService.InputBegan:Connect(function(i,g)
	if not g and i.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
end)

UserInputService.JumpRequest:Connect(function()
	if RoVIS.Settings.InfiniteJump and Player.Character then
		local hum = Player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState("Jumping")
		end
	end
end)

local function createTab(name)
	local TabBtn = Instance.new("TextButton", TabContainer)
	TabBtn.Size = UDim2.new(1, -10, 0, 40)
	TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.Gotham
	TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	Instance.new("UICorner", TabBtn)

	local Content = Instance.new("ScrollingFrame", ContentContainer)
	Content.Size = UDim2.new(1, -20, 1, -20)
	Content.Position = UDim2.new(0, 10, 0, 10)
	Content.BackgroundTransparency = 1
	Content.ScrollBarThickness = 2
	Content.Visible = false
	Instance.new("UIListLayout", Content).Padding = UDim.new(0, 10)

	TabBtn.MouseButton1Click:Connect(function()
		for _, v in pairs(ContentContainer:GetChildren()) do
			if v:IsA("ScrollingFrame") then v.Visible = false end
		end
		for _, v in pairs(TabContainer:GetChildren()) do
			if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(25, 25, 35) end
		end
		Content.Visible = true
		TabBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	end)
	return Content
end

local pTab = createTab("Player")
local vTab = createTab("Visuals")
local sndTab = createTab("Sounds")
local sTab = createTab("Settings")

-- Изменена функция создания переключателя для поддержки обновления конфига
local function createToggle(parent, text, var, callback)
	local btn = Instance.new("TextButton", parent)
	-- Сохраняем информацию о переменной и базовом тексте в атрибутах кнопки
	btn:SetAttribute("ToggleVar", var)
	btn:SetAttribute("ToggleBaseText", text)
	-- Добавляем тег для быстрого поиска всех переключателей
	CollectionService:AddTag(btn, "RoVISToggleBtn")

	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	local stateText = RoVIS.Settings[var] and "ON" or "OFF"
	btn.Text = text .. ": " .. stateText
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn)

	btn.MouseButton1Click:Connect(function()
		RoVIS.Settings[var] = not RoVIS.Settings[var]
		btn.Text = text .. ": " .. (RoVIS.Settings[var] and "ON" or "OFF")
		if callback then callback(RoVIS.Settings[var]) end
	end)
end

-- Новая функция для обновления GUI после загрузки конфига
local function updateGuiState()
	for _, btn in pairs(CollectionService:GetTagged("RoVISToggleBtn")) do
		local var = btn:GetAttribute("ToggleVar")
		local baseText = btn:GetAttribute("ToggleBaseText")
		if var and baseText and RoVIS.Settings[var] ~= nil then
			btn.Text = baseText .. ": " .. (RoVIS.Settings[var] and "ON" or "OFF")
			
			-- Ручное обновление для специфических функций, которые не зависят от RenderStepped
			if var == "MenuMusic" then
				if RoVIS.Settings.MenuMusic and RoVIS.Visible then BgMusic:Play() else BgMusic:Stop() end
			end
		end
	end
	-- Примечание: Слайдеры в текущей реализации не сохраняют свои значения в RoVIS.Settings напрямую,
	-- поэтому их обновление при загрузке конфига требует переписывания логики слайдеров.
	-- Сейчас исправлены только переключатели (ON/OFF).
end


local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, -10, 0, 50)
	frame.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.Text = text .. ": " .. default
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.BackgroundTransparency = 1

	local sBack = Instance.new("TextButton", frame)
	sBack.Size = UDim2.new(1, 0, 0, 6)
	sBack.Position = UDim2.new(0, 0, 0, 30)
	sBack.BackgroundColor3 = Color3.fromRGB(40,40,50)
	sBack.Text = ""

	local sFill = Instance.new("Frame", sBack)
	sFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	RunService.RenderStepped:Connect(function() sFill.BackgroundColor3 = getRainbowColor() end)

	local dragging = false
	local function update()
		local m = UserInputService:GetMouseLocation().X
		local rel = math.clamp((m - sBack.AbsolutePosition.X) / sBack.AbsoluteSize.X, 0, 1)
		sFill.Size = UDim2.new(rel, 0, 1, 0)
		local val = math.floor(min + (max-min) * rel)
		lbl.Text = text .. ": " .. val
		callback(val)
	end
	sBack.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
	RunService.RenderStepped:Connect(function() if dragging then update() end end)
end

-- Вкладка Player
createSlider(pTab, "WalkSpeed", 16, 250, 16, function(v) if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = v end end)
createSlider(pTab, "JumpPower", 50, 500, 50, function(v) if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.JumpPower = v Player.Character.Humanoid.UseJumpPower = true end end)
createToggle(pTab, "Noclip", "Noclip")
createToggle(pTab, "Spider", "Spider")
createToggle(pTab, "Inf Jump", "InfiniteJump")

-- Вкладка Visuals
createToggle(vTab, "Trails", "Trails")
createToggle(vTab, "Jump Particles", "JumpParticles")
createToggle(vTab, "Chams", "Chams")
createToggle(vTab, "Snow Effect", "Snow")
createToggle(vTab, "Winter Shaders", "WinterShaders")

-- Вкладка Sounds
createToggle(sndTab, "Menu Music", "MenuMusic", function(val)
	if val and RoVIS.Visible then BgMusic:Play() else BgMusic:Stop() end
end)

createToggle(sndTab, "Snow Footsteps", "SnowFootsteps")

-- Вкладка Settings
local configListFrame = Instance.new("Frame", sTab)
configListFrame.Size = UDim2.new(1, -10, 0, 200)
configListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
configListFrame.BorderSizePixel = 0
Instance.new("UICorner", configListFrame)

local configListTitle = Instance.new("TextLabel", configListFrame)
configListTitle.Size = UDim2.new(1, 0, 0, 30)
configListTitle.BackgroundTransparency = 1
configListTitle.Text = "Saved Configs"
configListTitle.Font = Enum.Font.GothamBold
configListTitle.TextSize = 16
configListTitle.TextColor3 = Color3.fromRGB(200, 200, 200)

local configScrollFrame = Instance.new("ScrollingFrame", configListFrame)
configScrollFrame.Size = UDim2.new(1, -10, 1, -40)
configScrollFrame.Position = UDim2.new(0, 5, 0, 35)
configScrollFrame.BackgroundTransparency = 1
configScrollFrame.ScrollBarThickness = 4
configScrollFrame.BorderSizePixel = 0
local configListLayout = Instance.new("UIListLayout", configScrollFrame)
configListLayout.Padding = UDim.new(0, 5)
configListLayout.SortOrder = Enum.SortOrder.Name

local function refreshConfigList()
	for _, child in pairs(configScrollFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	local configs = listfiles("RoVIS_Configs")
	for _, configPath in pairs(configs) do
		local configName = configPath:match("([^/\\]+)%.json$")
		if configName then
			local configBtn = Instance.new("TextButton", configScrollFrame)
			configBtn.Size = UDim2.new(1, -10, 0, 35)
			configBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			configBtn.Text = configName
			configBtn.Font = Enum.Font.Gotham
			configBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			configBtn.TextSize = 14
			Instance.new("UICorner", configBtn)
			configBtn.MouseButton1Click:Connect(function()
				if isfile(configPath) then
					local success, result = pcall(function()
						local data = readfile(configPath)
						RoVIS.Settings = HttpService:JSONDecode(data)
					end)
					if success then
						-- ЗДЕСЬ ВЫЗЫВАЕТСЯ ОБНОВЛЕНИЕ GUI
						updateGuiState()
						
						configBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
						task.wait(0.3)
						configBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
					else
						configBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
						task.wait(0.3)
						configBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
					end
				end
			end)
		end
	end
	configScrollFrame.CanvasSize = UDim2.new(0, 0, 0, configListLayout.AbsoluteContentSize.Y)
end

local nameBox = Instance.new("TextBox", sTab)
nameBox.Size = UDim2.new(1, -10, 0, 35)
nameBox.PlaceholderText = "Enter config name..."
nameBox.Text = ""
nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
nameBox.TextColor3 = Color3.new(1, 1, 1)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 14
Instance.new("UICorner", nameBox)

local function configBtn(text, color, cb)
	local b = Instance.new("TextButton", sTab)
	b.Size = UDim2.new(1, -10, 0, 35)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(cb)
	return b
end

configBtn("SAVE CONFIG", Color3.fromRGB(0, 120, 0), function()
	local configName = nameBox.Text
	if configName ~= "" then
		local data = HttpService:JSONEncode(RoVIS.Settings)
		writefile("RoVIS_Configs/" .. configName .. ".json", data)
		nameBox.Text = ""
		refreshConfigList()
	end
end)

configBtn("REFRESH LIST", Color3.fromRGB(0, 100, 200), function() refreshConfigList() end)
refreshConfigList()

local trail = nil
local snowEmitter = nil
local snowPart = nil
local wasInAir = false

local shaderFolder = nil
local oldLighting = {}

-- Chams implementation
local highlights = {}
local function updateChams()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character then
			local char = plr.Character
			if RoVIS.Settings.Chams then
				if not highlights[plr] then
					local highlight = Instance.new("Highlight")
					highlight.Name = "RoVIS_Chams"
					highlight.Adornee = char
					highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red for enemies, customizable if needed
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0
					highlight.Parent = char
					highlights[plr] = highlight
				end
			else
				if highlights[plr] then
					highlights[plr]:Destroy()
					highlights[plr] = nil
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		updateChams()
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	if highlights[plr] then
		highlights[plr]:Destroy()
		highlights[plr] = nil
	end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
	if Player.Character then
		local c = getRainbowColor()
		local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
		local head = Player.Character:FindFirstChild("Head")
		local humanoid = Player.Character:FindFirstChild("Humanoid")

		if RoVIS.Settings.Noclip then
			for _, v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
		end
		
		if RoVIS.Settings.Spider and hrp then
			local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 1.5)
			local hit = workspace:FindPartOnRay(ray, Player.Character)
			if hit and hit.CanCollide then
				hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 35, hrp.AssemblyLinearVelocity.Z)
			end
		end

		-- ЛОГИКА ЗАМЕНЫ ЗВУКА ШАГОВ
		if hrp then
			local runSound = hrp:FindFirstChild("Running")
			if runSound then
				if RoVIS.Settings.SnowFootsteps then
					if runSound.SoundId ~= customWalkSoundId then
						if not originalWalkSoundId then originalWalkSoundId = runSound.SoundId end
						runSound.SoundId = customWalkSoundId
					end
				else
					if runSound.SoundId == customWalkSoundId and originalWalkSoundId then
						runSound.SoundId = originalWalkSoundId
						originalWalkSoundId = nil
					end
				end
			end
		end

		if RoVIS.Settings.Chams then
			updateChams()
		else
			for plr, hl in pairs(highlights) do
				hl:Destroy()
			end
			highlights = {}
		end

		if RoVIS.Settings.Snow and hrp then
			if not snowPart then
				snowPart = Instance.new("Part")
				snowPart.Name = "RoVIS_SnowPart"
				snowPart.Size = Vector3.new(60, 1, 60)
				snowPart.Transparency = 1
				snowPart.CanCollide = false
				snowPart.Anchored = true
				snowPart.Parent = workspace
				snowEmitter = Instance.new("ParticleEmitter", snowPart)
				snowEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
				snowEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				snowEmitter.Rate = 80
				snowEmitter.Lifetime = NumberRange.new(12, 18)
				snowEmitter.Speed = NumberRange.new(3, 8)
				snowEmitter.SpreadAngle = Vector2.new(5, 5)
				snowEmitter.Acceleration = Vector3.new(0, -1, 0)
				snowEmitter.VelocityInheritance = 0
				snowEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 0.6), NumberSequenceKeypoint.new(1, 0.2)})
				snowEmitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.8, 0.3), NumberSequenceKeypoint.new(1, 1)})
				snowEmitter.Rotation = NumberRange.new(0, 360)
				snowEmitter.RotSpeed = NumberRange.new(-40, 40)
				snowEmitter.LightEmission = 0.3
				snowEmitter.EmissionDirection = Enum.NormalId.Bottom
				snowEmitter.Drag = 1
			end
			if snowPart then snowPart.Position = hrp.Position + Vector3.new(0, 20, 0) end
		elseif snowPart then
			snowPart:Destroy() snowPart = nil snowEmitter = nil
		end

		if RoVIS.Settings.WinterShaders then
			if not shaderFolder then
				oldLighting.Ambient = Lighting.Ambient
				oldLighting.OutdoorAmbient = Lighting.OutdoorAmbient
				oldLighting.Brightness = Lighting.Brightness
				oldLighting.ClockTime = Lighting.ClockTime
				oldLighting.FogColor = Lighting.FogColor
				oldLighting.FogEnd = Lighting.FogEnd
				shaderFolder = Instance.new("Folder", Lighting)
				shaderFolder.Name = "RoVIS_WinterFX"
				local bloom = Instance.new("BloomEffect", shaderFolder)
				bloom.Intensity = 0.4 bloom.Size = 24 bloom.Threshold = 0.95
				local cc = Instance.new("ColorCorrectionEffect", shaderFolder)
				cc.Saturation = -0.3 cc.Contrast = 0.15 cc.TintColor = Color3.fromRGB(180, 210, 255)
				local atmos = Instance.new("Atmosphere", shaderFolder)
				atmos.Density = 0.3 atmos.Offset = 0 atmos.Color = Color3.fromRGB(150, 170, 200) atmos.Decay = Color3.fromRGB(100, 120, 150) atmos.Glare = 0.5 atmos.Haze = 1
				Lighting.Ambient = Color3.fromRGB(50, 50, 70)
				Lighting.OutdoorAmbient = Color3.fromRGB(80, 100, 130)
				Lighting.Brightness = 1.5
				Lighting.FogColor = Color3.fromRGB(150, 170, 200)
				Lighting.FogEnd = 1000
			end
		elseif shaderFolder then
			shaderFolder:Destroy() shaderFolder = nil
			Lighting.Ambient = oldLighting.Ambient
			Lighting.OutdoorAmbient = oldLighting.OutdoorAmbient
			Lighting.Brightness = oldLighting.Brightness
			Lighting.FogColor = oldLighting.FogColor
			Lighting.FogEnd = oldLighting.FogEnd
		end

		if RoVIS.Settings.Trails and hrp then
			if not trail then
				trail = Instance.new("Trail", hrp)
				local a0 = Instance.new("Attachment", hrp)
				local a1 = Instance.new("Attachment", hrp)
				a0.Position = Vector3.new(0, 1, 0) a1.Position = Vector3.new(0, -1, 0)
				trail.Attachment0 = a0 trail.Attachment1 = a1
				trail.Lifetime = 0.5
			end
			trail.Color = ColorSequence.new(c)
		elseif trail then trail:Destroy() trail = nil end

		if RoVIS.Settings.JumpParticles and humanoid and hrp then
			local isInAir = humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Flying
			if wasInAir and not isInAir and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
				local spawnPart = Instance.new("Part", workspace)
				spawnPart.Anchored = true
				spawnPart.CanCollide = false
				spawnPart.Transparency = 1
				spawnPart.Size = Vector3.new(5, 0.1, 5)
				spawnPart.Position = hrp.Position - Vector3.new(0, 3, 0)
				
			
