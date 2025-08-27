repeat
    task.wait()
until game:IsLoaded()

local START_TIME = os.clock()

local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager =
    loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = 'Violence District',
    Footer = 'zov goida',
    NotifySide = 'Right',
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab('Main', 'user'),
    ['UI Settings'] = Window:AddTab('UI Settings', 'settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('ESP', 'eye')

LeftGroupBox:AddToggle('ESPEnable', {
    Default = false,
    Text = 'ESP Enabled',
})
LeftGroupBox:AddLabel('ESP Bind'):AddKeyPicker('ESPKeybind', {
    SyncToggleState = false,
    Mode = 'Always',
    Text = 'ESP',
    NoUI = false,
})

Toggles.ESPEnable.Modes = { 'Toggle', 'Hold', 'Always' }

LeftGroupBox:AddToggle('ESPGenerators', {
    Default = false,
    Text = 'Generators',
})

LeftGroupBox:AddToggle('ESPPallets', {
    Default = false,
    Text = 'Pallets',
})

LeftGroupBox:AddToggle('ESPHooks', {
    Default = false,
    Text = 'Hooks',
})

LeftGroupBox:AddToggle('ESPWindows', {
    Default = false,
    Text = 'Windows',
})

LeftGroupBox:AddToggle('ESPSurvivors', {
    Default = false,
    Text = 'Survivors',
})

LeftGroupBox:AddToggle('ESPKiller', {
    Default = false,
    Text = 'Killer',
})

LeftGroupBox:AddToggle('ESPTeamFilter', {
    Default = false,
    Text = 'Team filter',
    Tooltip = "Will not display your teammates"
})


local RightGroupBox = Tabs.Main:AddLeftGroupbox('Survivor', 'user')

RightGroupBox:AddToggle('AutoGenerator', {
    Default = false,
    Text = 'Auto generator',
    --Tooltip = "Dev note: Disables SkillCheckEvent OnClientEvent"
})

RightGroupBox:AddDropdown('AutoGeneratorMode', {
    Text = "Mode",
    Values = { "Perfect", "Neutral" },
    Multi = false,
    Default = 1,
})

RightGroupBox:AddDivider()

RightGroupBox:AddToggle("NoHorizontalSlash", {
    Text = "No Horizontal slash",
    
})

RightGroupBox:AddDivider()

RightGroupBox:AddToggle("MultipleSurvivorSpeed", {
    Text = "Multiple Survivor speed",
    Default = false
})

RightGroupBox:AddSlider("MultipleSurvivorSpeedValue", {
    Compact = true,
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 2
})

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu', 'wrench')

MenuGroup:AddToggle('KeybindMenuOpen', {
    Default = Library.KeybindFrame.Visible,
    Text = 'Open Keybind Menu',
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})
MenuGroup:AddToggle('ShowCustomCursor', {
    Text = 'Custom Cursor',
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})
MenuGroup:AddDropdown('NotificationSide', {
    Values = { 'Left', 'Right' },
    Default = 'Right',

    Text = 'Notification Side',

    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})
MenuGroup:AddDropdown('DPIDropdown', {
    Values = { '50%', '75%', '100%', '125%', '150%', '175%', '200%' },
    Default = '100%',

    Text = 'DPI Scale',

    Callback = function(Value)
        Value = Value:gsub('%%', '')
        local DPI = tonumber(Value)

        Library:SetDPIScale(DPI)
    end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel('Menu bind'):AddKeyPicker(
    'MenuKeybind',
    { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' }
)

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('unnamed_script_hub')
SaveManager:SetFolder('unnamed_script_hub/violence_district')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

local services = setmetatable({}, {
    __index = function(self, ind)
        return game.GetService(game, ind)
    end,
})

local SetAttribute = game.SetAttribute
local FindFirstChild = game.FindFirstChild
local IsA = game.IsA

local WorldToViewportPoint =
    services.Workspace.CurrentCamera.WorldToViewportPoint
local Random_NEXTINT = Random.new().NextInteger
local Random_NEXTFLT = Random.new().NextNumber
local Random_OBJ = Random.new()

local Player = services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')
local SkillCheckGui = PlayerGui:WaitForChild('SkillCheckPromptGui')
    :WaitForChild('Check')
local SkillCheckGui_Line = SkillCheckGui:WaitForChild('Line')
local SkillCheckGui_Goal = SkillCheckGui:WaitForChild('Goal')
local SkillCheckEvent =
    services.ReplicatedStorage.Remotes.Generator:WaitForChild('SkillCheckEvent')
local SkillCheckResultEvent =
    services.ReplicatedStorage.Remotes.Generator:WaitForChild(
        'SkillCheckResultEvent'
    )

local modules = {}
do
    local __esp_data = { drawings = {}, signals = {}, map_objects = {} };
    local auto_generator_signal_on_descendant_added = nil;
    local auto_generator_signal_on_descendant_removing = nil;

    function modules:esp()
        local __ESP_FULL_COLOR = Color3.new(0, 1, 0)
        local __ESP_LOW_COLOR = Color3.new(1, 0, 0)

        local function esp_connect(signal, callback)
            __esp_data.signals[#__esp_data.signals + 1] =
                signal:Connect(callback)
        end

        if
            Toggles.ESPEnable.Value == false
            or Options.ESPKeybind:GetState() == false
        then
            for _, i in __esp_data.drawings do
                for _, v in i do
                    if typeof(v) == 'Instance' then
                        v.Enabled = false
                        continue
                    end
                    v.Visible = false
                end
            end
            return
        end

        if
            not services.Workspace
                :FindFirstChild('Map')
                :FindFirstChild('Antifling')
        then
            table.clear(__esp_data.map_objects)
            return
        end

        local function get_map_objects()
            debug.profilebegin('Get_Map_Objects')

            local result = {
                ['Generators'] = {},
                ['Windows'] = {},
                ['Pallets'] = {},
                ['Hooks'] = {},
            }

            for _, v in services.Workspace.Map:GetChildren() do
                if v.Name == 'Generator' then
                    table.insert(result.Generators, v)
                    continue
                end
                if v.Name == 'Window' or v:FindFirstChild('Window') then
                    table.insert(result.Windows, v)
                    continue
                end
                if
                    v.Name == 'Palletwrong' or v:FindFirstChild('Palletwrong')
                then
                    if
                        v.Name == 'Palletwrong'
                        and v:FindFirstChild('HumanoidRootPart')
                    then
                        table.insert(result.Pallets, v)
                        continue
                    end
                    if
                        v:FindFirstChild('Palletwrong')
                        and v:FindFirstChild('Palletwrong')
                            :FindFirstChild('HumanoidRootPart')
                    then
                        table.insert(
                            result.Pallets,
                            v:FindFirstChild('Palletwrong')
                        )
                        continue
                    end
                end
                if
                    v.Name == 'PalletAlien' or v:FindFirstChild('PalletAlien')
                then
                    if
                        v.Name == 'PalletAlien'
                        and v:FindFirstChild('HumanoidRootPart')
                    then
                        table.insert(result.Pallets, v)
                        continue
                    end
                    if
                        v:FindFirstChild('PalletAlien')
                        and v:FindFirstChild('PalletAlien')
                            :FindFirstChild('HumanoidRootPart')
                    then
                        table.insert(
                            result.Pallets,
                            v:FindFirstChild('PalletAlien')
                        )
                        continue
                    end
                end
                if v.Name == 'Hook' then
                    table.insert(result.Hooks, v)
                    continue
                end
            end

            debug.profileend()

            return result
        end

        local function disable_drawings(instance)
            if not __esp_data.drawings[instance] then
                return
            end
            for i, v in __esp_data.drawings[instance] do
                if typeof(v) == 'Instance' then
                    v.Enabled = false
                    continue
                end
                v.Visible = false
            end
        end

        if not __esp_data.signals['new_object_on_map'] then
            __esp_data.signals['new_object_on_map'] = services.Workspace.DescendantRemoving:Connect(function(descendant)
                if tostring(descendant) == "HumanoidRootPart" and (tostring(descendant.Parent) == "Palletwrong" or tostring(descendant.Parent) == "PalletAlien") then
                    disable_drawings(descendant)
                end
                if tostring(descendant) == "Antifling" then
                    --// clear drawings
                    for instance,drawings in __esp_data.drawings do
                        for _,drawing in drawings do
                            drawing:Destroy()
                        end
                        __esp_data.drawings[instance] = nil
                    end
                    --// clear map_objects ref
                    __esp_data.map_objects = {['Generators'] = {}, ['Windows'] = {}, ['Pallets'] = {}, ['Hooks'] = {}} --// i think luaugc will take it
                end
            end)
            __esp_data.signals['new_object_on_map_2'] = services.Workspace.DescendantAdded:Connect(function(descendant)
                --if tostring(descendant.Parent) == "Map" then warn(tostring(descendant)) end
                if tostring(descendant) == "Generator" then
                    --__esp_data.map_objects = get_map_objects()
                    table.insert(__esp_data.map_objects['Generators'], descendant)
                elseif tostring(descendant) == "Window" then
                    table.insert(__esp_data.map_objects['Windows'], descendant)
                elseif (tostring(descendant) == "Palletwrong" or tostring(descendant) == "PalletAlien") then
                    table.insert(__esp_data.map_objects['Pallets'], descendant)
                elseif tostring(descendant) == "Hook" then
                    table.insert(__esp_data.map_objects['Hooks'], descendant)
                end
            end)

            __esp_data.map_objects = get_map_objects()
        end

        local function get_player_objects()
            local result = {}

            for _, player in services.Players:GetPlayers() do
                if player == Player then
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
                    and player_team_name == tostring(Player.Team)
                then
                    continue
                end


                table.insert(result, player)
            end

            return result
        end

        local map_objects = __esp_data.map_objects
        local players_objects = get_player_objects()

        debug.profilebegin('ESP Render (Drawing library)')

        for type, map_object_list in map_objects do
            if #map_object_list == 0 then
                continue
            end

            if type == 'Generators' then
                for _, generator in map_object_list do
                    local repair_amount =
                        generator:GetAttribute('RepairProgress')

                    if not Toggles.ESPGenerators.Value or not generator:FindFirstChild("HitBox") then
                        disable_drawings(generator)
                        continue
                    end

                    local root_point = generator.HitBox
                    --local root_point_on_screen, is_on_screen = WorldToViewportPoint(services.Workspace.CurrentCamera, root_point.Position)
                    --root_point_on_screen = Vector2.new(root_point_on_screen.X, root_point_on_screen.Y)

                    local top_text_point, is_on_screen = WorldToViewportPoint(
                        services.Workspace.CurrentCamera,
                        root_point.Position
                    )
                    top_text_point =
                        Vector2.new(top_text_point.X, top_text_point.Y)

                    if not __esp_data.drawings[generator] then
                        __esp_data.drawings[generator] = {}

                        local function cleanup_drawings()
                            if generator.Parent == nil then
                                if __esp_data.drawings[generator] == nil then return end
                                for _, drawing in __esp_data.drawings[generator] do
                                    drawing:Destroy()
                                end
                            end
                        end
                        esp_connect(
                            generator:GetPropertyChangedSignal('Parent'),
                            cleanup_drawings
                        )

                        __esp_data.drawings[generator].generator_top_text =
                            Drawing.new('Text')
                        do
                            local generator_top_text =
                                __esp_data.drawings[generator].generator_top_text
                            generator_top_text.Size = 18
                            generator_top_text.Font = Drawing.Fonts.UI
                            generator_top_text.Visible = false
                            generator_top_text.Color = Color3.new(1, 1, 1)
                            generator_top_text.Center = true
                        end

                        __esp_data.drawings[generator].generator_repair_amount_text =
                            Drawing.new('Text')
                        do
                            local generator_repair_amount_text =
                                __esp_data.drawings[generator].generator_repair_amount_text
                            generator_repair_amount_text.Size = 18
                            generator_repair_amount_text.Font = Drawing.Fonts.UI
                            generator_repair_amount_text.Visible = false
                            generator_repair_amount_text.Color =
                                Color3.new(1, 0, 0)
                            generator_repair_amount_text.Center = true
                        end

                        __esp_data.drawings[generator].generator_highlight =
                            Instance.new('Highlight', generator)
                        do
                            local generator_highlight =
                                __esp_data.drawings[generator].generator_highlight
                            generator_highlight.Enabled = true
                            generator_highlight.FillColor = Color3.new(1, 0, 0)
                            generator_highlight.FillTransparency = 0.5
                            generator_highlight.OutlineColor =
                                Color3.new(1, 0, 0)
                            generator_highlight.OutlineTransparency = 0
                        end
                    end

                    local generator_top_text =
                        __esp_data.drawings[generator].generator_top_text
                    local generator_repair_amount_text =
                        __esp_data.drawings[generator].generator_repair_amount_text
                    local generator_highlight =
                        __esp_data.drawings[generator].generator_highlight

                    generator_top_text.Visible = is_on_screen
                        and Toggles.ESPGenerators.Value
                    generator_repair_amount_text.Visible = is_on_screen
                        and Toggles.ESPGenerators.Value

                    generator_top_text.Position = top_text_point
                    generator_top_text.Text = 'Generator'

                    generator_repair_amount_text.Position = top_text_point
                        + Vector2.new(0, 14)
                    generator_repair_amount_text.Text =
                        `{math.round(repair_amount)}%`

                    local color = __ESP_LOW_COLOR:Lerp(
                        __ESP_FULL_COLOR,
                        repair_amount / 100
                    )

                    generator_highlight.FillColor = color
                    generator_highlight.OutlineColor = color
                    generator_repair_amount_text.Color = color
                end
            elseif type == 'Windows' then
                for _, window in map_object_list do
                    if not Toggles.ESPWindows.Value then
                        disable_drawings(window)
                        continue
                    end

                    local root_point = window:FindFirstChild('inviswall')
                    if not root_point then
                        disable_drawings(window)
                        continue
                    end
                    --local root_point_on_screen, is_on_screen = WorldToViewportPoint(services.Workspace.CurrentCamera, root_point.Position)
                    --root_point_on_screen = Vector2.new(root_point_on_screen.X, root_point_on_screen.Y)

                    local top_text_point, is_on_screen = WorldToViewportPoint(
                        services.Workspace.CurrentCamera,
                        root_point.Position
                    )
                    top_text_point =
                        Vector2.new(top_text_point.X, top_text_point.Y)

                    if not __esp_data.drawings[window] then
                        __esp_data.drawings[window] = {}

                        local function cleanup_drawings()
                            if not __esp_data.drawings[window] then return end
                            if window.Parent == nil then
                                for _, drawing in __esp_data.drawings[window] do
                                    drawing:Destroy()
                                end
                            end
                        end
                        esp_connect(
                            window:GetPropertyChangedSignal('Parent'),
                            cleanup_drawings
                        )

                        __esp_data.drawings[window].window_text =
                            Drawing.new('Text')
                        do
                            local window_text =
                                __esp_data.drawings[window].window_text
                            window_text.Size = 18
                            window_text.Font = Drawing.Fonts.UI
                            window_text.Visible = false
                            window_text.Color =
                                Color3.new(0.25098, 0.615686, 0.913725)
                            window_text.Center = true
                            window_text.Text = 'Window'
                        end
                    end

                    local window_text = __esp_data.drawings[window].window_text

                    window_text.Visible = is_on_screen
                        and Toggles.ESPWindows.Value
                    window_text.Position = top_text_point
                end
            elseif type == 'Pallets' then
                for _, pallet in map_object_list do
                    if not Toggles.ESPPallets.Value or not pallet or not pallet:FindFirstChild("HumanoidRootPart") then
                        disable_drawings(pallet)
                        continue
                    end

                    local root_point = pallet.HumanoidRootPart
                    --local root_point_on_screen, is_on_screen = WorldToViewportPoint(services.Workspace.CurrentCamera, root_point.Position)
                    --root_point_on_screen = Vector2.new(root_point_on_screen.X, root_point_on_screen.Y)

                    local top_text_point, is_on_screen = WorldToViewportPoint(
                        services.Workspace.CurrentCamera,
                        root_point.Position
                    )
                    top_text_point =
                        Vector2.new(top_text_point.X, top_text_point.Y)

                    if not __esp_data.drawings[pallet] then
                        __esp_data.drawings[pallet] = {}

                        local function cleanup_drawings()
                            if pallet:WaitForChild("HumanoidRootPart").Parent == nil then
                                for _, drawing in __esp_data.drawings[pallet] do
                                    if typeof(drawing) == 'Instance' then
                                        drawing:Destroy()
                                    else
                                        drawing:Remove()
                                    end
                                end
                            end
                        end
                        esp_connect(
                            pallet:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal('Parent'),
                            cleanup_drawings
                        )

                        __esp_data.drawings[pallet].pallet_text =
                            Drawing.new('Text')
                        do
                            local pallet_text =
                                __esp_data.drawings[pallet].pallet_text
                            pallet_text.Size = 18
                            pallet_text.Font = Drawing.Fonts.UI
                            pallet_text.Visible = false
                            pallet_text.Color =
                                Color3.new(0.745098, 0.494118, 0.137255)
                            pallet_text.Center = true
                            pallet_text.Text = 'Pallet'
                        end
                    end

                    local pallet_text = __esp_data.drawings[pallet].pallet_text

                    pallet_text.Visible = is_on_screen
                        and Toggles.ESPPallets.Value
                    pallet_text.Position = top_text_point
                end
            elseif type == 'Hooks' then
                for _, hook in map_object_list do
                    if not Toggles.ESPHooks.Value then
                        disable_drawings(hook)
                        continue
                    end

                    local root_point = hook.HookPoint
                    --local root_point_on_screen, is_on_screen = WorldToViewportPoint(services.Workspace.CurrentCamera, root_point.Position)
                    --root_point_on_screen = Vector2.new(root_point_on_screen.X, root_point_on_screen.Y)

                    local top_text_point, is_on_screen = WorldToViewportPoint(
                        services.Workspace.CurrentCamera,
                        root_point.Position
                    )
                    top_text_point =
                        Vector2.new(top_text_point.X, top_text_point.Y)

                    if not __esp_data.drawings[hook] then
                        __esp_data.drawings[hook] = {}

                        local function cleanup_drawings()
                            if hook.Parent == nil then
                                if not __esp_data.drawings[hook] then return end
                                for _, drawing in __esp_data.drawings[hook] do
                                    drawing:Destroy()
                                end
                            end
                        end
                        esp_connect(
                            hook:GetPropertyChangedSignal('Parent'),
                            cleanup_drawings
                        )

                        __esp_data.drawings[hook].hook_text =
                            Drawing.new('Text')
                        do
                            local hook_text =
                                __esp_data.drawings[hook].hook_text
                            hook_text.Size = 18
                            hook_text.Font = Drawing.Fonts.UI
                            hook_text.Visible = false
                            hook_text.Color =
                                Color3.new(0.854902, 0.298039, 0.298039)
                            hook_text.Center = true
                            hook_text.Text = 'Hook'
                        end
                    end

                    local hook_text = __esp_data.drawings[hook].hook_text

                    hook_text.Visible = is_on_screen
                        and Toggles.ESPHooks.Value
                    hook_text.Position = top_text_point
                end
            end
        end

        for index, player_object in players_objects do
            if not player_object.Character or not player_object.Character:FindFirstChild("Head") or not player_object.Character:FindFirstChild("HumanoidRootPart") then
                disable_drawings(player_object)
                continue
            end
            local team_color = player_object.TeamColor.Color

            --local root_point = player_object.Character.HumanoidRootPart.Position
            local top_point = player_object.Character.Head.Position
                + Vector3.new(0, player_object.Character.Head.Size.Y / 2, 0)

            local top_text_point, is_on_screen = WorldToViewportPoint(
                services.Workspace.CurrentCamera,
                top_point
            )
            top_text_point = Vector2.new(top_text_point.X, top_text_point.Y)

            if not __esp_data.drawings[player_object] then
                __esp_data.drawings[player_object] = {}

                local function cleanup_drawings()
                    if player_object.Character:WaitForChild("HumanoidRootPart").Parent == nil then
                        for _, drawing in __esp_data.drawings[player_object] do
                            drawing:Destroy()
                        end
                    end
                end
                esp_connect(
                    player_object.Character:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal('Parent'),
                    cleanup_drawings
                )

                __esp_data.drawings[player_object].player_text =
                    Drawing.new('Text')
                do
                    local player_text =
                        __esp_data.drawings[player_object].player_text
                    player_text.Size = 18
                    player_text.Font = Drawing.Fonts.UI
                    player_text.Visible = false
                    player_text.Color = team_color
                    player_text.Center = true
                    player_text.Text = tostring(player_object)
                end

                __esp_data.drawings[player_object].player_highlight =
                    Instance.new('Highlight', player_object.Character)
                do
                    local player_highlight =
                        __esp_data.drawings[player_object].player_highlight
                    player_highlight.Enabled = true
                    player_highlight.FillColor = team_color
                    player_highlight.FillTransparency = 0.5
                    player_highlight.OutlineColor = team_color
                    player_highlight.OutlineTransparency = 0
                end
            end

            local player_text = __esp_data.drawings[player_object].player_text
            local player_highlight = __esp_data.drawings[player_object].player_highlight

            player_highlight.Enabled = true
            player_text.Visible = is_on_screen
            player_text.Position = top_text_point
        end

        debug.profileend()
    end

    function modules:auto_generator()
        --[[ stable version without Pefrect support (only Neutral)
		if not auto_generator_signal then
			local function onDescendantAdded(descendant)
				if descendant and descendant.Parent == Player.Character and descendant.Name == "Skillcheck-gen" then
					task.wait()
					for i, func in getgc() do
						if type(func) == "function" and not isexecutorclosure(func) and islclosure(func) then
							
							local _getupvalues = getupvalues(func)
							if (#_getupvalues == 11 and getupvalue(func, 1) == Player.Character:FindFirstChild("CheckInterractable")) then
								if not isfunctionhooked(func) then
									local old; old = hookfunction(func, function(...)
										if Toggles.AutoGenerator.Value then
											return
										end
										return old(...)
									end)
								end
							end
							
						end
					end
				end
			end

			onDescendantAdded(Player.Character:FindFirstChild("Skillcheck-gen"))
			auto_generator_signal = game.DescendantAdded:Connect(onDescendantAdded)
		end ]]
        -- unstable (can bug out/stop working) version with Perfect timing support
        -- i think its stable right now but idk
        if not auto_generator_signal_on_descendant_added then
            local current_result = nil

            local function onDescendantAdded(descendant)
                if
                    descendant
                    and descendant.Parent == Player.Character
                    and descendant.Name == 'Skillcheck-gen'
                then
                    task.wait(1)
                    local results = filtergc('function', {
                        Upvalues = {
                            services.CollectionService,
                            services.Players.LocalPlayer,
                            services.Players.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('SkillCheckPromptGui'):WaitForChild('Check')
                        }
                    }, false) -- why this shit works but getgc() manual filter dont...
                    current_result = results;
                    for i, func in results do
                        if not isfunctionhooked(func) then
                            warn(`      hooked function`)
                            local old
                            old = hookfunction(func, function(...)
                                if Toggles.AutoGenerator.Value then
                                    warn(`              auto generator - success`)
                                    old('success')
                                    return
                                end
                                return old(...)
                            end)
                        end
                    end
                end
            end

            local function onDescendantRemoving(descendant)
                if (descendant.Name == "Skillcheck-gen" and descendant.Parent == Player) then
                    for i,func in current_result do
                        if isfunctionhooked(func) then
                            warn(`restored function due to Skillcheck-gen deletion`)
                            restorefunction(func)
                        end
                    end
                end
            end

            onDescendantAdded(Player.Character:FindFirstChild('Skillcheck-gen'))
            auto_generator_signal_on_descendant_added =
                services.Workspace.DescendantAdded:Connect(onDescendantAdded)
            auto_generator_signal_on_descendant_removing = 
                services.Workspace.DescendantRemoving:Connect(onDescendantRemoving)
        end
    end
    modules:auto_generator()

    function modules:no_horizontal_slash()
        if Toggles.NoHorizontalSlash.Value then
            local ohString1 = "Crouchingserver"
            local ohBoolean2 = true

            game:GetService("ReplicatedStorage").Remotes.Mechanics.ChangeAttribute:FireServer(ohString1, ohBoolean2)
        end
    end

    function modules:cleanup()
        auto_generator_signal:Disconnect()
        for i, v in __esp_data do
            if i == 'drawings' then
                for i, draw in v do
                    draw:Destroy()
                end
            elseif i == 'signals' then
                for i, signal in v do
                    signal:Disconnect()
                end
            end
        end
    end
end

local hooks
hooks = { __old_mts = { __namecall = nil, __index = nil, __newindex = nil } }
do
    hooks.__old_mts.__index = hookmetamethod(
        game,
        '__index',
        newcclosure(function(self, ind)
            if not checkcaller() and Toggles.AutoGenerator.Value then
                if Player:FindFirstChild('PlayerGui') and Player:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui') and Player:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check') and Player:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check'):FindFirstChild('Line') and self == Player:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check'):FindFirstChild('Line') then
                    warn(`      {Options.AutoGeneratorMode.Value} ({typeof(Options.AutoGeneratorMode.Value)})`)
                    if Options.AutoGeneratorMode.Value == "Perfect" then
                        warn(`perfect autogenerator`)
                        return 104 + Player:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check'):FindFirstChild('Goal').Rotation
                    else
                        warn(`neutral autogenerator`)
                        return 115 + Player:FindFirstChild('PlayerGui'):FindFirstChild('SkillCheckPromptGui'):FindFirstChild('Check'):FindFirstChild('Goal').Rotation
                    end
                end
            end

            return hooks.__old_mts.__index(self, ind)
        end)
    )

    hooks.__old_mts.__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = {...}

        if not checkcaller() and tostring(self) == "ChangeAttribute" and Toggles.NoHorizontalSlash.Value then
            if args[1] == "Crouchingserver" then args[2] = true end
        end

        return hooks.__old_mts.__namecall(self, unpack(args))
    end))

    hooks.__old_mts.__newindex = hookmetamethod(game, "__newindex", newcclosure(function(self, ind, val)
        if not checkcaller() and Toggles.MultipleSurvivorSpeed.Value and Player.Character and self == Player.Character:FindFirstChild("Humanoid") and ind == "WalkSpeed" then
            return val * Options.MultipleSurvivorSpeedValue.Value
        end
        return hooks.__old_mts.__newindex(self, ind, val)
    end))
end

services.RunService.PreRender:Connect(function()
    modules:esp()
end)

Toggles.NoHorizontalSlash:OnChanged(function()
    modules:no_horizontal_slash()
end)

Toggles.MultipleSurvivorSpeed:OnChanged(function()
    Options.MultipleSurvivorSpeedValue:SetDisabled(not Toggles.MultipleSurvivorSpeed.Value)
end)
