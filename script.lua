local StartClock = os.clock()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local GeneratorRemotes = Remotes:WaitForChild("Generator")
local SkillCheckEvent = GeneratorRemotes:WaitForChild("SkillCheckEvent")

local Round = Remotes:WaitForChild("Round")

local Cheat = {
    Library = loadstring(game:HttpGet(repo .. "Library.lua"))(),
    ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))(),
    SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))(),

    UIWindow = nil,

    Hooks = {},
    FunctionHooks = {},
    Signals = {},
    Drawings = {},
    Variables = {
        Player = nil,
        Character = nil,
        SkillcheckGUI = nil,
        LineGUI = nil,
        GoalGUI = nil,
    },
    DebugMode = getgenv().StartWithDebug,
    DebugOptions = getgenv().DebugOptions or {["LogWalkspeedChanges"] = true}
} do
    local Options = Cheat.Library.Options
    local Toggles = Cheat.Library.Toggles

    Cheat.Library.ForceCheckbox = false
    Cheat.Library.ShowToggleFrameInKeybinds = true

    function Cheat:LogOutput(log : string)
        if not Cheat.DebugMode then return end
        local Date = DateTime.now():ToLocalTime()
        print(` [{Date.Hour}:{Date.Minute}:{Date.Seconds}] {log}`)
    end

    function Cheat:LogWarn(log : string)
        if not Cheat.DebugMode then return end
        local Date = DateTime.now():ToLocalTime()
        warn(` [{Date.Hour}:{Date.Minute}:{Date.Seconds}] {log}`)
    end

    --// UI
    do
        Cheat.UIWindow = Cheat.Library:CreateWindow({
            Title = "Violence District",
            Footer = "zov goida (refactored)",
            NotifySide = "Right",
            ShowCustomCursor = true
        }); do
            Cheat.UIWindow:AddTab("Main", "user"); do
                local ESPGroupbox = Cheat.Library.Tabs["Main"]:AddLeftGroupbox("ESP", "eye"); do
                    ESPGroupbox:AddToggle("ESPEnabled", {
                        Text = "Enabled",
                        Default = false,
                    })
                    ESPGroupbox:AddLabel("ESP Bind"):AddKeyPicker("ESPBind", {
                        SyncToggleState = false,
                        Mode = 'Always',
                        Text = 'ESP Bind',
                        NoUI = false,
                    })

                    ESPGroupbox:AddDivider()

                    ESPGroupbox:AddToggle("ESPSurvivors", {
                        Text = "Survivors",
                        Default = false,
                    }):AddColorPicker("ESPSurvivors_Color", {
                        Default = Color3.new(0, 0, 1),
                        Title = "Survivors top text color",
                        Transparency = nil,
                    })
                    ESPGroupbox:AddToggle("ESPKiller", {
                        Text = "Killers",
                        Default = false,
                    }):AddColorPicker("ESPKiller_Color", {
                        Default = Color3.new(1, 0, 0),
                        Title = "Killer top text color",
                        Transparency = nil,
                    })
                    ESPGroupbox:AddToggle("ESPPallets", {
                        Text = "Pallets",
                        Default = false,
                    }):AddColorPicker("ESPPallets_Color", {
                        Default = Color3.new(0.745098, 0.494118, 0.137255),
                        Title = "Pallets top text color",
                        Transparency = nil,
                    })
                    ESPGroupbox:AddToggle("ESPWindows", {
                        Text = "Windows",
                        Default = false,
                    }):AddColorPicker("ESPWindows_Color", {
                        Default = Color3.new(0.25098, 0.615686, 0.913725),
                        Title = "Windows top text color",
                        Transparency = nil,
                    })
                    ESPGroupbox:AddToggle("ESPHooks", {
                        Text = "Hooks",
                        Default = false,
                    }):AddColorPicker("ESPHooks_Color", {
                        Default = Color3.new(0.854902, 0.298039, 0.298039),
                        Title = "Hooks top text color",
                        Transparency = nil,
                    })
                    ESPGroupbox:AddToggle("ESPGenerators", {
                        Text = "Generators",
                        Default = false,
                    }):AddColorPicker("ESPGenerators_TopTextColor", {
                        Default = Color3.new(1, 1, 1),
                        Title = "Generators top text color",
                    }):AddColorPicker("ESPGenerators_FullyRepairedColor", {
                        Default = Color3.new(0, 1, 0),
                        Title = "Full repair progress color"
                    }):AddColorPicker("ESPGenerators_NoRepairedColor", {
                        Default = Color3.new(1, 0, 0),
                        Title = "No repair progress color"
                    })
                    ESPGroupbox:AddToggle("ESPTeamFilter", {
                        Text = "Team Filter",
                        Default = false,
                    })
                end

                local SurvivorGroupbox = Cheat.Library.Tabs["Main"]:AddRightGroupbox("Survivor", "user"); do
                    SurvivorGroupbox:AddToggle("AutoGenerator", {
                        Text = "Auto Generator",
                        Enabled = false
                    })
                    SurvivorGroupbox:AddDropdown("AutoGeneratorMode", {
                        Text = "Mode",
                        Values = { "Perfect", "Neutral" },
                        Multi = false,
                        Default = 1
                    })

                    SurvivorGroupbox:AddDivider()

                    SurvivorGroupbox:AddToggle("WalkspeedMultiplier", {
                        Text = "Walkspeed Multiplier",
                        Default = false
                    })

                    SurvivorGroupbox:AddSlider("WalkspeedMultiplierAmount", {
                        Text = "Value",
                        Default = 1,
                        Min = 1,
                        Max = 5,
                        Rounding = 2,
                        Compact = true
                    })
                end
            end

            Cheat.UIWindow:AddTab("UI Settings", "settings"); do
                local MenuGroup = Cheat.Library.Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench"); do
                    MenuGroup:AddToggle("KeybindMenuOpen", {
	                    Default = Cheat.Library.KeybindFrame.Visible,
	                    Text = "Open Keybind Menu",
	                    Callback = function(value)
		                    Cheat.Library.KeybindFrame.Visible = value
	                    end,
                    })

                    MenuGroup:AddToggle("ShowCustomCursor", {
	                    Text = "Custom Cursor",
	                    Default = true,
	                    Callback = function(Value)
		                    Cheat.Library.ShowCustomCursor = Value
	                    end,
                    })
                    MenuGroup:AddDropdown("NotificationSide", {
                        Values = { "Left", "Right" },
                        Default = "Right",

                        Text = "Notification Side",

                        Callback = function(Value)
                            Cheat.Library:SetNotifySide(Value)
                        end,
                    })
                    MenuGroup:AddDropdown("DPIDropdown", {
                        Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
                        Default = "100%",

                        Text = "DPI Scale",

                        Callback = function(Value)
                            Value = Value:gsub("%%", "")
                            local DPI = tonumber(Value)

                            Cheat.Library:SetDPIScale(DPI)
                        end,
                    })
                    MenuGroup:AddDivider()
                    MenuGroup:AddLabel("Menu bind")
                        :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

                    MenuGroup:AddButton("Unload", function()
                        Cheat.Library:Unload()
                    end)

                    Cheat.Library.ToggleKeybind = Options.MenuKeybind
                    Cheat.ThemeManager:SetLibrary(Cheat.Library)
                    Cheat.SaveManager:SetLibrary(Cheat.Library)
                    Cheat.SaveManager:IgnoreThemeSettings()
                    Cheat.SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
                    Cheat.ThemeManager:SetFolder("zov_goida")
                    Cheat.SaveManager:SetFolder("zov_goida/violence_district")
                    Cheat.SaveManager:BuildConfigSection(Cheat.Library.Tabs["UI Settings"])
                    Cheat.ThemeManager:ApplyToTab(Cheat.Library.Tabs["UI Settings"])
                    Cheat.SaveManager:LoadAutoloadConfig()
                end
            end
        end
    end

    --// Metamethod hooks
    do
        Cheat.Hooks.__index = hookmetamethod(game, "__index", newcclosure(function(self, ind)
            --// autogenerator hook
            if not checkcaller() then
                if self == Cheat.Variables.LineGUI then
                    if Options.AutoGeneratorMode.Value == "Perfect" then
                        return 104 + Cheat.Variables.GoalGUI.Rotation
                    else
                        return 115 + Cheat.Variables.GoalGUI.Rotation
                    end
                end
            end

            return Cheat.Hooks.__index(self, ind)
        end))

        Cheat.Hooks.__newindex = hookmetamethod(game, "__newindex", newcclosure(function(self, ind, val)
            if not checkcaller() then
                if self == Cheat.Variables.Character:FindFirstChildWhichIsA("Humanoid") then
                    if ind == "WalkSpeed" and Cheat.DebugOptions.LogWalkspeedChanges then
                        Cheat:LogWarn(`{getcallingscript()} changed LocalPlayer's WalkSpeed`)
                    end
                end
            end
            return Cheat.Hooks.__newindex(self, ind, val)
        end))

        Cheat.Hooks.__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local Arguments = {...}
            local NamecallMethod = getnamecallmethod()
            local CallingScript = getcallingscript()

            if not checkcaller() then
                if Toggles.WalkspeedMultiplier.Value and self == Cheat.Variables.Character and Cheat.Variables.Player.Team.Name == "Survivors" then
                    if NamecallMethod == "GetAttribute" then
                        if Arguments[1] == "speedboost" then
                            return Options.WalkspeedMultiplierAmount.Value
                        end
                    end
                end
            end

            return Cheat.Hooks.__namecall(self, unpack(Arguments))
        end))
    end

    --// Function hooks
    do
        function Cheat:HookFunction(old : () -> (), new : () -> ()) : () -> ()
            local OldFunction; OldFunction = hookfunction(old, new)
            Cheat.FunctionHooks[#Cheat.FunctionHooks + 1] = OldFunction

            return OldFunction
        end

        function Cheat:RestoreFunction(old : () -> ())
            table.remove(Cheat.FunctionHooks, table.find(Cheat.FunctionHooks, old))
            restorefunction(old)
        end
    end

    --// Signals
    do
        function Cheat:CreateNewSignal(signal : RBXScriptSignal, callback : () -> any, id : string?)
            if (id and Cheat.Signals[id] ~= nil) then return end

            local Signal : RBXScriptConnection = signal:Connect(callback)
            Cheat.Signals[id or #Cheat.Signals + 1] = Signal
            return Signal
        end

        function Cheat:FindSignalById(id : string?) : RBXScriptConnection
            return Cheat.Signals[id]
        end
    end

    --// Auto Generator
    do
        local LastFilterGCResult = nil

        local function OnDescendantAdded(descendant : Instance)
            if (descendant and descendant.Parent == Cheat.Variables.Character and descendant.Name == "Skillcheck-gen") then
                task.wait(1)

                local FilterGCResult = filtergc("function", {
                    Upvalues = {
                        CollectionService,
                        Cheat.Variables.Player,
                        Cheat.Variables.SkillcheckGUI
                    }
                }, false)
                LastFilterGCResult = FilterGCResult

                for _, func in FilterGCResult do
                    if not isfunctionhooked(func) then
                        local OldFunction; OldFunction = Cheat:HookFunction(func, newcclosure(function(...)
                            if Toggles.AutoGenerator.Value then
                                return OldFunction("success")
                            end
                            return OldFunction(...)
                        end))
                    end
                end
            end
        end

        local function OnSkillCheckEvent()
            if Toggles.AutoGenerator.Value then
                task.delay(.7, function()
                    firesignal(UserInputService.InputBegan, {KeyCode = Enum.KeyCode.Space}, false)
                end)
            end
        end

        OnDescendantAdded(Cheat.Variables.Character and Cheat.Variables.Character:FindFirstChildWhichIsA("Skillcheck-gen"))
        Cheat:CreateNewSignal(Workspace.DescendantAdded, OnDescendantAdded, "AutoGeneratorSignal_OnDescendantAdded")
        Cheat:CreateNewSignal(SkillCheckEvent.OnClientEvent, OnSkillCheckEvent, "AutoGeneratorSignal_AutoSkillCheck")
    end

    --// ESP
    do
        --// Map objects handler
        local MapObjects = {
            ["Generators"] = {},
            ["Pallets"] = {},
            ["Windows"] = {},
            ["Hooks"] = {}
        }

        local function GetCurrentMapObjects()
            for _, v in Workspace.Map:GetDescendants() do
                if v.Name == 'Generator' then
                    table.insert(MapObjects.Generators, v)
                    continue
                end
                if v.Name == 'Window' then
                    table.insert(MapObjects.Windows, v)
                    continue
                end
                if v.Name == "Palletwrong" then
                    table.insert(MapObjects.Pallets, v)
                    continue
                end
                if v.Name == "PalletAlien" then
                    table.insert(MapObjects.Pallets, v)
                    continue
                end
                if v.Name == 'Hook' then
                    table.insert(MapObjects.Hooks, v)
                    continue
                end
            end
        end

        GetCurrentMapObjects()

        --// Player objects handler
        local PlayerObjects : {[any] : Player} = {}

        local function GetPlayerObjects()
            local Result = {}

            for _, player in Players:GetPlayers() do
                if player == Players.LocalPlayer then
                    continue
                end
                if not player.Character then
                    continue
                end

                local player_team_name = tostring(player.Team)
                if player_team_name == 'Spectator' then
                    continue
                end
                if
                    player_team_name == 'Killer'
                    and not Toggles.ESPKiller.Value
                then
                    continue
                end
                if
                    player_team_name == 'Survivors'
                    and not Toggles.ESPSurvivors.Value
                then
                    continue
                end
                if
                    Toggles.ESPTeamFilter.Value
                    and player_team_name == tostring(Cheat.Variables.Player.Team)
                then
                    continue
                end


                table.insert(Result, player)
            end

            PlayerObjects = Result
        end

        GetPlayerObjects()

        --// Drawing Handler
        local function DisableDrawingsForInstance(instance : Instance)
            if Cheat.Drawings[instance] then
                if type(Cheat.Drawings[instance]) == "table" then
                    for _, Drawing in Cheat.Drawings[instance] do
                        if typeof(Drawing) == "Instance" and Drawing:IsA("Highlight") then
                            Drawing.Enabled = false
                        else
                            Drawing.Visible = false
                        end
                    end
                else
                    if typeof(Cheat.Drawings[instance]) == "Instance" and Cheat.Drawings[instance]:IsA("Highlight") then Cheat.Drawings[instance].Enabled = false; return end
                    if isrenderobj(Cheat.Drawings[instance]) then Cheat.Drawings[instance].Visible = false end
                end
            end
        end

        local function ESP_Prerender_event()
            if not Toggles.ESPEnabled.Value or not Options.ESPBind:GetState() then
                for Instance, _ in Cheat.Drawings do
                    DisableDrawingsForInstance(Instance)
                end
                return
            end

            if not Workspace.Map:FindFirstChild("Antifling") then
                return
            end

            for MapObjectType, MapObjectList in MapObjects do
                if MapObjectType == "Generators" and #MapObjectList > 0 then
                    for _, Generator : Instance in MapObjectList do
                        local RepairProgress = Generator:GetAttribute("RepairProgress")
                        local DebugId = Generator:GetDebugId(16)

                        if not Toggles.ESPGenerators.Value or not Generator:FindFirstChild("HitBox") then
                            DisableDrawingsForInstance(Generator)
                            continue 
                        end

                        local RootPoint = Generator:FindFirstChild("HitBox")

                        local TopTextPoint, IsOnScreen = Workspace.CurrentCamera:WorldToViewportPoint(RootPoint.Position)
                        TopTextPoint = Vector2.new( TopTextPoint.X, TopTextPoint.Y )

                        if not Cheat.Drawings[Generator] then
                            local OnParentChangedSignal : RBXScriptConnection = nil

                            local function OnParentChanged()
                                if Generator.Parent == nil then
                                    if Cheat.Drawings[Generator] == nil then return end
                                    for _, Drawing in Cheat.Drawings[Generator] do
                                        Drawing:Destroy()
                                    end
                                    Cheat.Drawings[Generator] = nil
                                    OnParentChangedSignal:Disconnect()
                                end
                            end

                            OnParentChangedSignal = Cheat:CreateNewSignal(Generator:GetPropertyChangedSignal("Parent"), OnParentChanged, `{DebugId}_OnParentChanged`)

                            Cheat.Drawings[Generator] = {}; do
                                local GeneratorTopText = Drawing.new("Text"); do
                                    GeneratorTopText.Size = 18
                                    GeneratorTopText.Font = Drawing.Fonts.UI
                                    GeneratorTopText.Visible = false
                                    GeneratorTopText.Color = Options.ESPGenerators_TopTextColor.Value
                                    GeneratorTopText.Center = true
                                    GeneratorTopText.Text = "Generator"

                                    Cheat.Drawings[Generator].TopText = GeneratorTopText;
                                end

                                local GeneratorRepairProgress = Drawing.new("Text"); do
                                    GeneratorRepairProgress.Size = 18
                                    GeneratorRepairProgress.Font = Drawing.Fonts.UI
                                    GeneratorRepairProgress.Visible = false
                                    GeneratorRepairProgress.Color = Options.ESPGenerators_NoRepairedColor.Value
                                    GeneratorRepairProgress.Center = true

                                    Cheat.Drawings[Generator].RepairProgress = GeneratorRepairProgress;
                                end

                                local GeneratorHighlight = Instance.new("Highlight", Generator); do
                                    GeneratorHighlight.Enabled = true
                                    GeneratorHighlight.FillColor = Options.ESPGenerators_NoRepairedColor.Value
                                    GeneratorHighlight.FillTransparency = 0.5
                                    GeneratorHighlight.OutlineColor =
                                        Options.ESPGenerators_NoRepairedColor.Value
                                    GeneratorHighlight.OutlineTransparency = 0
                                    GeneratorHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                                    Cheat.Drawings[Generator].Highlight = GeneratorHighlight;
                                end
                            end
                        end

                        if not IsOnScreen then
                            DisableDrawingsForInstance(Generator)
                            continue
                        end

                        local GeneratorTopText = Cheat.Drawings[Generator].TopText;
                        local GeneratorRepairProgress = Cheat.Drawings[Generator].RepairProgress;
                        local GeneratorHighlight = Cheat.Drawings[Generator].Highlight;

                        GeneratorTopText.Visible = true
                        GeneratorRepairProgress.Visible = true
                        GeneratorHighlight.Enabled = true

                        GeneratorTopText.Position = TopTextPoint
                        GeneratorRepairProgress.Position = TopTextPoint + Vector2.new(0, 14)

                        GeneratorRepairProgress.Text = `{math.round(RepairProgress)}%`

                        local GeneratorProgressColor = Options.ESPGenerators_NoRepairedColor.Value:Lerp(
                            Options.ESPGenerators_FullyRepairedColor.Value,
                            RepairProgress / 100
                        )

                        GeneratorHighlight.FillColor = GeneratorProgressColor
                        GeneratorHighlight.OutlineColor = GeneratorProgressColor
                        GeneratorRepairProgress.Color = GeneratorProgressColor
                        GeneratorTopText.Color = Options.ESPGenerators_TopTextColor.Value
                    end
                elseif MapObjectType == "Pallets" and #MapObjectList > 0 then
                    for _, Pallet : Instance in MapObjectList do
                        local DebugId = Pallet:GetDebugId(16)

                        if not Toggles.ESPPallets.Value or not Pallet:FindFirstChild("HumanoidRootPart") then
                            DisableDrawingsForInstance(Pallet)
                            continue 
                        end

                        local RootPoint = Pallet:FindFirstChild("HumanoidRootPart")

                        local TopTextPoint, IsOnScreen = Workspace.CurrentCamera:WorldToViewportPoint(RootPoint.Position)
                        TopTextPoint = Vector2.new( TopTextPoint.X, TopTextPoint.Y )

                        if not Cheat.Drawings[Pallet] then
                            local OnParentChangedSignal : RBXScriptConnection = nil
                            local OnChildRemovedSignal : RBXScriptConnection = nil

                            local function OnParentChanged()
                                if Pallet.Parent == nil then
                                    if Cheat.Drawings[Pallet] == nil then return end
                                    for _, Drawing in Cheat.Drawings[Pallet] do
                                        Drawing:Destroy()
                                    end
                                    Cheat.Drawings[Pallet] = nil
                                    OnParentChangedSignal:Disconnect()
                                    OnChildRemovedSignal:Disconnect()
                                end
                            end

                            local function OnChildRemoved(child : Instance)
                                if child.Name == "HumanoidRootPart" then
                                    if Cheat.Drawings[Pallet] == nil then return end
                                    for _, Drawing in Cheat.Drawings[Pallet] do
                                        Drawing:Destroy()
                                    end
                                    Cheat.Drawings[child] = nil
                                    OnParentChangedSignal:Disconnect()
                                    OnChildRemovedSignal:Disconnect()
                                end
                            end

                            OnParentChangedSignal = Cheat:CreateNewSignal(Pallet:GetPropertyChangedSignal("Parent"), OnParentChanged, `{DebugId}_OnParentChanged`)
                            OnChildRemovedSignal = Cheat:CreateNewSignal(Pallet.ChildRemoved, OnChildRemoved)

                            Cheat.Drawings[Pallet] = {}; do
                                local PalletTopText = Drawing.new("Text"); do
                                    PalletTopText.Size = 18
                                    PalletTopText.Font = Drawing.Fonts.UI
                                    PalletTopText.Visible = false
                                    PalletTopText.Color = Options.ESPPallets_Color.Value
                                    PalletTopText.Center = true
                                    PalletTopText.Text = "Pallet"

                                    Cheat.Drawings[Pallet].TopText = PalletTopText;
                                end
                            end
                        end

                        if not IsOnScreen then
                            DisableDrawingsForInstance(Pallet)
                            continue
                        end

                        local PalletTopText = Cheat.Drawings[Pallet].TopText;

                        PalletTopText.Visible = true

                        PalletTopText.Position = TopTextPoint

                        PalletTopText.Color = Options.ESPPallets_Color.Value
                    end
                elseif MapObjectType == "Windows" and #MapObjectList > 0 then
                    for _, Window : Instance in MapObjectList do
                        local DebugId = Window:GetDebugId(16)

                        if not Toggles.ESPWindows.Value or not Window:FindFirstChild("inviswall") then
                            DisableDrawingsForInstance(Window)
                            continue 
                        end

                        local RootPoint = Window:FindFirstChild("inviswall")

                        local TopTextPoint, IsOnScreen = Workspace.CurrentCamera:WorldToViewportPoint(RootPoint.Position)
                        TopTextPoint = Vector2.new( TopTextPoint.X, TopTextPoint.Y )

                        if not Cheat.Drawings[Window] then
                            local OnParentChangedSignal : RBXScriptConnection = nil

                            local function OnParentChanged()
                                if Window.Parent == nil then
                                    if Cheat.Drawings[Window] == nil then return end
                                    for _, Drawing in Cheat.Drawings[Window] do
                                        Drawing:Destroy()
                                    end
                                    Cheat.Drawings[Window] = nil
                                    OnParentChangedSignal:Disconnect()
                                end
                            end

                            OnParentChangedSignal = Cheat:CreateNewSignal(Window:GetPropertyChangedSignal("Parent"), OnParentChanged, `{DebugId}_OnParentChanged`)

                            Cheat.Drawings[Window] = {}; do
                                local WindowTopText = Drawing.new("Text"); do
                                    WindowTopText.Size = 18
                                    WindowTopText.Font = Drawing.Fonts.UI
                                    WindowTopText.Visible = false
                                    WindowTopText.Color = Options.ESPWindows_Color.Value
                                    WindowTopText.Center = true
                                    WindowTopText.Text = "Window"

                                    Cheat.Drawings[Window].TopText = WindowTopText;
                                end
                            end
                        end

                        if not IsOnScreen then
                            DisableDrawingsForInstance(Window)
                            continue
                        end

                        local WindowTopText = Cheat.Drawings[Window].TopText;

                        WindowTopText.Visible = true

                        WindowTopText.Position = TopTextPoint

                        WindowTopText.Color = Options.ESPWindows_Color.Value
                    end
                elseif MapObjectType == "Hooks" and #MapObjectList > 0 then
                    for _, Hook : Instance in MapObjectList do
                        local DebugId = Hook:GetDebugId(16)

                        if not Toggles.ESPHooks.Value or not Hook:FindFirstChild("HookPoint") then
                            DisableDrawingsForInstance(Hook)
                            continue 
                        end

                        local RootPoint = Hook:FindFirstChild("HookPoint")

                        local TopTextPoint, IsOnScreen = Workspace.CurrentCamera:WorldToViewportPoint(RootPoint.Position)
                        TopTextPoint = Vector2.new( TopTextPoint.X, TopTextPoint.Y )

                        if not Cheat.Drawings[Hook] then
                            local OnParentChangedSignal : RBXScriptConnection = nil

                            local function OnParentChanged()
                                if Hook.Parent == nil then
                                    if Cheat.Drawings[Hook] == nil then return end
                                    for _, Drawing in Cheat.Drawings[Hook] do
                                        Drawing:Destroy()
                                    end
                                    Cheat.Drawings[Hook] = nil
                                    OnParentChangedSignal:Disconnect()
                                end
                            end

                            OnParentChangedSignal = Cheat:CreateNewSignal(Hook:GetPropertyChangedSignal("Parent"), OnParentChanged, `{DebugId}_OnParentChanged`)

                            Cheat.Drawings[Hook] = {}; do
                                local HookTopText = Drawing.new("Text"); do
                                    HookTopText.Size = 18
                                    HookTopText.Font = Drawing.Fonts.UI
                                    HookTopText.Visible = false
                                    HookTopText.Color = Options.ESPHooks_Color.Value
                                    HookTopText.Center = true
                                    HookTopText.Text = "Hook"

                                    Cheat.Drawings[Hook].TopText = HookTopText;
                                end
                            end
                        end

                        if not IsOnScreen then
                            DisableDrawingsForInstance(Hook)
                            continue
                        end

                        local HookTopText = Cheat.Drawings[Hook].TopText;

                        HookTopText.Visible = true

                        HookTopText.Position = TopTextPoint

                        HookTopText.Color = Options.ESPHooks_Color.Value
                    end
                end
            end

            for _, PlayerObject : Player in PlayerObjects do
                local DebugId = PlayerObject:GetDebugId(16)

                if not PlayerObject.Character 
                or not PlayerObject.Character:FindFirstChild("Head") 
                or not PlayerObject.Character:FindFirstChild("HumanoidRootPart")
                or tostring(PlayerObject.Team) == "Spectator" then
                    DisableDrawingsForInstance(PlayerObject)
                    continue
                end
                local Team = tostring(PlayerObject.Team)
                local TeamColor = (Team == "Survivors" and Options.ESPSurvivors_Color.Value or Options.ESPKiller_Color.Value)

                local TopPoint = PlayerObject.Character.Head.Position + Vector3.new(0, PlayerObject.Character.Head.Size.Y / 2, 0)

                local TopTextPoint, IsOnScreen = Workspace.CurrentCamera:WorldToViewportPoint(TopPoint)
                TopTextPoint = Vector2.new( TopTextPoint.X, TopTextPoint.Y )

                if not Cheat.Drawings[PlayerObject] then
                    local OnParentChangedSignal : RBXScriptConnection = nil
                    local OnCharacterRemovingSignal : RBXScriptConnection = nil

                    local function OnParentChanged()
                        if PlayerObject.Character.Parent == nil then
                            if Cheat.Drawings[PlayerObject] == nil then return end
                            for _, Drawing in Cheat.Drawings[PlayerObject] do
                                Drawing:Destroy()
                            end
                            Cheat.Drawings[PlayerObject] = nil
                            OnParentChangedSignal:Disconnect()
                            OnCharacterRemovingSignal:Disconnect()
                        end
                    end

                    local function OnCharacterRemoving()
                        if Cheat.Drawings[PlayerObject] == nil then return end
                        for _, Drawing in Cheat.Drawings[PlayerObject] do
                            Drawing:Destroy()
                        end
                        Cheat.Drawings[PlayerObject] = nil
                        OnParentChangedSignal:Disconnect()
                        OnCharacterRemovingSignal:Disconnect()
                    end

                    OnParentChangedSignal = Cheat:CreateNewSignal(PlayerObject.Character:GetPropertyChangedSignal("Parent"), OnParentChanged, `{DebugId}_OnParentChanged`)
                    OnCharacterRemovingSignal = Cheat:CreateNewSignal(PlayerObject.CharacterRemoving, OnCharacterRemoving, `{DebugId}_OnCharacterRemoving`)

                    Cheat.Drawings[PlayerObject] = {}; do
                        local PlayerObjectTopText = Drawing.new("Text"); do
                            PlayerObjectTopText.Size = 18
                            PlayerObjectTopText.Font = Drawing.Fonts.UI
                            PlayerObjectTopText.Visible = false
                            PlayerObjectTopText.Color = TeamColor
                            PlayerObjectTopText.Center = true
                            PlayerObjectTopText.Text = tostring(PlayerObject)

                            Cheat.Drawings[PlayerObject].TopText = PlayerObjectTopText;
                        end

                        local PlayerObjectHighlight = Instance.new("Highlight", PlayerObject.Character); do
                            PlayerObjectHighlight.Enabled = true
                            PlayerObjectHighlight.FillColor = TeamColor
                            PlayerObjectHighlight.OutlineColor = TeamColor
                            PlayerObjectHighlight.FillTransparency = 0.5
                            PlayerObjectHighlight.OutlineTransparency = 0

                            Cheat.Drawings[PlayerObject].Highlight = PlayerObjectHighlight
                        end
                    end
                end

                if not IsOnScreen then
                    DisableDrawingsForInstance(PlayerObject)
                    continue
                end

                local PlayerObjectTopText = Cheat.Drawings[PlayerObject].TopText
                local PlayerObjectHighlight = Cheat.Drawings[PlayerObject].Highlight

                PlayerObjectTopText.Visible = true
                PlayerObjectHighlight.Enabled = true
                
                PlayerObjectTopText.Color = TeamColor
                PlayerObjectHighlight.FillColor = TeamColor
                PlayerObjectHighlight.OutlineColor = TeamColor

                PlayerObjectTopText.Position = TopTextPoint
            end
        end

        Cheat:CreateNewSignal(Round.OnClientEvent, function()
            GetCurrentMapObjects()
            GetPlayerObjects()
        end)

        Cheat:CreateNewSignal(RunService.PreRender, ESP_Prerender_event, "ESPRender_Event")
    end

    --// Variables Handler
    do
        Cheat.Variables.Player = Players.LocalPlayer

        local function OnCharacterAdded(character : Model)
            if not character then return end
            Cheat.Variables.Character = character
            Cheat.Variables.SkillcheckGUI = Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('SkillCheckPromptGui'):WaitForChild('Check')
            Cheat.Variables.GoalGUI = Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check'):WaitForChild('Goal')
            Cheat.Variables.LineGUI = Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check'):WaitForChild('Line')
        end

        OnCharacterAdded(Players.LocalPlayer.Character)
        Cheat:CreateNewSignal(Players.LocalPlayer.CharacterAdded, OnCharacterAdded)
    end

    function Cheat:RestoreGame()
        --// restoring metamethods
        local rawMT = getrawmetatable(game)
        setreadonly(rawMT, false)

        rawMT.__index = Cheat.Hooks.__index
        rawMT.__newindex = Cheat.Hooks.__newindex
        rawMT.__namecall = Cheat.Hooks.__namecall

        setreadonly(rawMT, true)

        --// restoring functions
        for _, original in Cheat.FunctionHooks do
            Cheat:RestoreFunction(original)
        end

        --// disconnecting signals
        for _, signal in Cheat.Signals do
            signal:Disconnect()
        end

        --// removing all drawings
        for _, drawing_list in Cheat.Drawings do
            if isrenderobj(drawing_list) then
                drawing_list:Destroy()
                continue
            end
            for _, drawing in drawing_list do
                drawing:Destroy()
            end
        end
    end

    Cheat.Library:OnUnload(function()
        Cheat:RestoreGame()
    end)

    Cheat.Library:Notify({
        Title = "Successfully loaded",
        Description = `Successfully loaded in {string.format("%.1f", os.clock() - StartClock)} seconds`,
        Duration = 4
    })

    if Cheat.DebugMode then
        Cheat.Library:Notify({
            Title = "Debug mode",
            Description = `Loaded in Debug mode`,
            Duration = 4
        })
    end
end