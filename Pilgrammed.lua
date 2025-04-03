local function LPH_NO_VIRTUALIZE(code)
    return code
end
LPH_JIT_MAX = LPH_NO_VIRTUALIZE

local devMode = true
local folderName = "Looma"
local callbackList = {}
local connectionList = {}
local movementCache = {Time = {}, Position = {}}

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NymeraAnHomie/Library/refs/heads/main/Bitchbot/Source.lua"))()
local hydroxide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/ohaux.lua"))()
local flags = library.Flags

LPH_JIT_MAX(function() -- Main Cheat
    local modules = {
    	networkClient = {},
        playerObject = {}
    }
    
    local network = modules.networkClient
	local playerObject = modules.playerObject
	
    local players = game:GetService("Players")
	local workspace = game:GetService("Workspace")
	local replicatedstorage = game:GetService("ReplicatedStorage")
	local lighting = game:GetService("Lighting")
    local runService = game:GetService("RunService")
    local userInputService = game:GetService("UserInputService")
    local httpService = game:GetService("HttpService")
    local teleportService = game:GetService("TeleportService")
    local localplayer = players.LocalPlayer
    local camera = workspace.CurrentCamera
    
	function network:send(name, ...)
	    local arguments = {...}
	    if name == "block" then
			replicatedstorage.Remotes.Block:FireServer(false)
			replicatedstorage.Remotes.Block:FireServer(true)
		elseif name == "roll" then
			replicatedstorage.Remotes.Roll:FireServer()
		elseif name == "slash" then
	 	   localplayer.Character:FindFirstChildOfClass("Tool"):Activate()
		elseif name == "heavy" then
			localplayer.Character:FindFirstChildOfClass("Tool").Slash:FireServer(2)
		end
	end
	
	function playerObject.applyModifications(client)
		if not client then return end
		
		if flags["movement_infinite_jump"] then
			client.ArmorStats.Jumps.Value = math.huge
			client.ArmorStats.DoubleJumpBoost.Value = 0.35
		else
			client.ArmorStats.Jumps.Value = 0
	   	 client.ArmorStats.DoubleJumpBoost.Value = 0
		end
		
		if flags["movement_walk_speed_enabled"] then
			client.ArmorStats.SpeedBoost.Value = flags["movement_walk_speed_amount"]
		else
			client.ArmorStats.SpeedBoost.Value = 0
		end
	end
	
	table.insert(connectionList, runService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
	    if flags["auto_parry_enabled"] then -- why tf doe this work best on 240ms
		    if math.floor(tick() / tonumber(flags["auto_parry_rate"])) ~= math.floor((tick() - 0.016) / tonumber(flags["auto_parry_rate"])) then
		        network:send("block")
		    end
		end
		
		if flags["auto_dodge_enabled"] then
			if flags["auto_dodge_mode"] == "Blatant" then
				network:send("roll")
			elseif flags["auto_dodge_mode"] == "Legit" then
			
			end
		end
	end)))
	
	callbackList["Misc Grab all Mirror"] = function()
		for i,v in pairs(workspace.Mirrors:GetDescendants()) do
		    if v:IsA("ProximityPrompt") then
		        localplayer.Character.HumanoidRootPart.CFrame = v.Parent.CFrame
		        task.wait(0.35)
		        fireproximityprompt(v, 1)
		        task.wait(0.35)
		    end
		end
	end
	
	local stillGoing = true
	task.spawn(LPH_NO_VIRTUALIZE(function()
	    while stillGoing do
	        task.wait(.55) -- you would not believe the lag
	
	        playerObject.applyModifications(localplayer)
	    end
	end))
	
	unloadCheat = function()
		library:Unload()
		for _, connection in ipairs(connectionList) do
	        connection:Disconnect()
		end
	end
end)()

LPH_NO_VIRTUALIZE(function() -- UI Creation
    local httpService = game:GetService("HttpService")
    
    if not isfolder(folderName) then
	    makefolder(folderName)
	end
	
	if not isfolder(folderName .. "/pilgrammed") then
	    makefolder(folderName .. "/pilgrammed")
	end
	
	if not isfolder(folderName .. "/pilgrammed/configs") then
	    makefolder(folderName .. "/pilgrammed/configs")
	end
	
	if not isfolder(folderName .. "/cache") then
	    makefolder(folderName .. "/cache")
	end
    
    local function getCallback(name)
	    return function(value)
	        if callbackList[name] then
	            callbackList[name](value)
	        end
	    end
	end

	local window = library:Window({Name = "Looma"})
	
	local main = window:Page({Name = "Main"})
	local visuals = window:Page({Name = "Visuals"})
	local teleport = window:Page({Name = "Teleport"})
	local misc = window:Page({Name = "Misc"})
	local settings = window:Page({Name = "Settings"})
	
	local autoparry, autododge = main:MultiSection({Sections = {"Auto Parry", "Auto Dodge"}, Zindex = 5, Side = "Left", Size = 300})
	
	local movement = misc:Section({Name = "Movement", Zindex = 5, Side = "Left", AutoSize = true})
	local tweaks = misc:Section({Name = "Tweaks", Zindex = 5, Side = "Right", AutoSize = true})
	
	autoparry:Toggle({Name = "Enabled", Flag = "auto_parry_enabled"})
	autoparry:Toggle({Name = "Ping Based", Flag = "auto_parry_ping_based"})
	autoparry:Slider({Name = "Rate", Flag = "auto_parry_rate", Suffix = "%", Default = 0.05, Min = 0, Max = 1, Decimals = 0.01})
	
	autododge:Toggle({Name = "Enabled", Flag = "auto_dodge_enabled"})
	autododge:List({Name = "Mode", Flag = "auto_dodge_mode", Options = {"Blatant", "Legit"}, Default = "Blatant"})
	
	movement:Toggle({Name = "Infinite Jump", Flag = "movement_infinite_jump"})
	movement:Toggle({Name = "Walk Speed", Flag = "movement_walk_speed_enabled"})
	movement:Slider({Name = "Current Speed", Flag = "movement_walk_speed_amount", Suffix = " Studs/Second", Default = 1.5, Min = 1, Max = 5, Decimals = 0.01})
	
	tweaks:Button({Name = "Grab all mirrors", Callback = getCallback("Misc Grab all Mirror") })
	
	local playerlist = settings:PlayerList({flag = "current_playerlist", path = folderName})
	local config = settings:Section({Name = "Configuration", Zindex = 5, Side = "Left", AutoSize = true})
	local cheatsettings = settings:Section({Name = "Interface", Zindex = 5, Side = "Right", AutoSize = true})
	
	local function getConfigNames()
	    local files = listfiles(folderName .. "/pilgrammed/configs")
	    local names = {}
	    for _, file in ipairs(files) do
	        table.insert(names, file:match("([^/\\]+)$"))
	    end
	    return names
	end
	
	local config_list = config:List({Name = "Config", Flag = "config_list", Options = getConfigNames()})
	config:Textbox({Flag = "config_name"})
	config:Button({Name = "Save", Callback = function()
	    if flags.config_name and flags.config_name ~= "" then
	        library:Notification((isfile(folderName .. "/pilgrammed/configs/" .. flags.config_name .. ".cfg") 
	        and "Overwrote Config: " or "Created Config: ") .. flags.config_name, 2, library.Accent)
	        
	        writefile(folderName .. "/pilgrammed/configs/" .. flags.config_name .. ".cfg", library:GetConfig())
	        config_list:Refresh(getConfigNames())
	    else
	        library:Notification("Config name cannot be empty", 2, library.Accent)
	    end
	end})
	
	config:Button({Name = "Load", Callback = function()
	    local file_path = folderName .. "/pilgrammed/configs/" .. flags.config_list
	    if isfile(file_path) then
	        library:LoadConfig(readfile(file_path))
			library:Notification("Loaded Config" .. flags.config_name, 2, library.Accent)
	    end
	end})
	config:Button({Name = "Refresh", Callback = function()
	    config_list:Refresh(getConfigNames())
	end})
	
    cheatsettings:Colorpicker({Name = "Menu Accent", Flag = "menu_accent", Default = library.Accent, Callback = function(rgb)
		library:ChangeAccent(rgb)
	end})
	cheatsettings:Keybind({Name = "Menu Bind", Flag = "menu_bind", UseKey = true, Default = library.UIKey, Callback = function(key)
		library.UIKey = key
    end})
    cheatsettings:Toggle({Name = "Keybind Lists", Flag = "menu_keybind_lists"})
    cheatsettings:Textbox({Name = "Custom Menu Name", Default = menuName, Callback = function(str)
	    window:UpdateTitle(tostring(str))
    end})
	cheatsettings:Button({Name = "Unload", Callback = unloadCheat})
end)()

do if game:GetService("UserInputService").TouchEnabled then
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local Outline = Instance.new("ImageButton")
	Outline.Name = "Outline"
	Outline.AnchorPoint = Vector2.new(0.5, 0.5)
	Outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Outline.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Outline.Position = UDim2.new(1, -32, 0, 10)
	Outline.Size = UDim2.new(0, 50, 0, 50)
	Outline.AutoButtonColor = false
	Outline.Image = "rbxassetid://10709781919"
	Outline.ImageTransparency = 0
	Outline.ZIndex = 2
	Outline.Parent = ScreenGui
	
	local Inline = Instance.new("Frame")
	Inline.Name = "Inline"
	Inline.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Inline.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Inline.BorderSizePixel = 0
	Inline.Position = UDim2.new(0, 1, 0, 1)
	Inline.Size = UDim2.new(1, -2, 1, -2)
	Inline.ZIndex = 1
	Inline.Parent = Outline
	
	local Accent = Instance.new("Frame")
	Accent.Name = "Accent"
	Accent.BorderColor3 = Color3.fromRGB(20, 20, 20)
	Accent.BorderSizePixel = 0
	Accent.Position = UDim2.new(0, 0, 0, 0)
	Accent.Size = UDim2.new(1, 0, 0, 1.5)
	Accent.ZIndex = 1
	Accent.Parent = Inline
	
	task.spawn(function() 
		while task.wait() do 
		    Outline.ImageColor3 = library.Accent
			Accent.BackgroundColor3 = library.Accent 
		end
	end)
	
	Outline.MouseButton1Click:Connect(function()
	    library:SetOpen(not library.Open)
	end)
end
end
