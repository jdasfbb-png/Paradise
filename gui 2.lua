local SynUI = {}
SynUI.__index = SynUI
local Services = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        rawset(t, k, s)
        return s
    end
})
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local Players = Services.Players
local CoreGui = Services.CoreGui
local Stats = Services.Stats
local HttpService = Services.HttpService
local LocalPlayer = Players.LocalPlayer
local function initConfig()
    if isfolder and not isfolder("paradiseui") then
        if makefolder then
            pcall(makefolder, "paradiseui")
        end
        if writefile then
            local initial = {
                MainWindow = {0.5, 0, 0.5, 0},
                KeybindsHUD = {0, 16, 0.4, 0},
                Watermark = {0, 16, 0, 16}
            }
            pcall(function()
                writefile("paradiseui/setting.json", HttpService:JSONEncode(initial))
            end)
        end
    end
end
local function loadSettings()
    initConfig()
    if isfile and isfile("paradiseui/setting.json") and readfile then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("paradiseui/setting.json"))
        end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return {}
end
local savedSettings = loadSettings()
local function saveSettings()
    initConfig()
    if writefile then
        pcall(function()
            writefile("paradiseui/setting.json", HttpService:JSONEncode(savedSettings))
        end)
    end
end
SynUI.Theme = {
    Background = Color3.fromRGB(18, 14, 17),
    Sidebar = Color3.fromRGB(14, 11, 13),
    Card = Color3.fromRGB(24, 18, 22),
    CardStroke = Color3.fromRGB(56, 36, 44),
    CardStrokeHover = Color3.fromRGB(85, 48, 60),
    Item = Color3.fromRGB(30, 23, 28),
    ItemHover = Color3.fromRGB(38, 29, 35),
    ItemStroke = Color3.fromRGB(58, 40, 48),
    ItemActive = Color3.fromRGB(75, 48, 58),
    Accent = Color3.fromRGB(245, 185, 195),
    AccentDark = Color3.fromRGB(180, 50, 70),
    Text = Color3.fromRGB(240, 235, 240),
    TextDim = Color3.fromRGB(155, 142, 148),
    Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
    FontBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold),
    FontSemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
    Corner = 6
}
local Theme = SynUI.Theme
local function Tween(obj, info, props)
    local tween = TweenService:Create(obj, TweenInfo.new(table.unpack(info)), props)
    tween:Play()
    return tween
end
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or Theme.Corner)
    c.Parent = parent
    return c
end
local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.CardStroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end
local function MakeDraggable(dragHandle, frameToMove, saveKey)
    local dragging = false
    local dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                    if saveKey then
                        savedSettings[saveKey] = {
                            frameToMove.Position.X.Scale,
                            frameToMove.Position.X.Offset,
                            frameToMove.Position.Y.Scale,
                            frameToMove.Position.Y.Offset
                        }
                        saveSettings()
                    end
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frameToMove.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end
local function GetGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    local ok, res = pcall(function() return CoreGui end)
    if ok and res then return res end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        return LocalPlayer.PlayerGui
    end
    return CoreGui
end
function SynUI:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "syn"
    local WindowSize = config.Size or UDim2.new(0, 600, 0, 410)
    local ToggleKey = config.ToggleKey or Enum.KeyCode.Insert
    local guiParent = GetGuiParent()
    for _, child in ipairs(guiParent:GetChildren()) do
        if child.Name == "SynUI_Window" or child.Name == "SynWatermark" or child.Name == "SynKeybinds" then
            child:Destroy()
        end
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SynUI_Window"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    ScreenGui.Parent = guiParent
    local Main = Instance.new("Frame")
    Main.Name = "MainWindow"
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    if savedSettings.MainWindow and type(savedSettings.MainWindow) == "table" and #savedSettings.MainWindow >= 4 then
        local p = savedSettings.MainWindow
        Main.Position = UDim2.new(p[1], p[2], p[3], p[4])
    else
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    Main.Size = WindowSize
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Corner(Main, 8)
    Stroke(Main, Theme.CardStroke, 1.2)
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Parent = Main
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.Size = UDim2.new(1, 40, 1, 40)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857472"
    Glow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Glow.ImageTransparency = 0.4
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24, 24, 276, 276)
    Glow.ZIndex = 0
    local DragBar = Instance.new("Frame")
    DragBar.Name = "DragBar"
    DragBar.Parent = Main
    DragBar.BackgroundTransparency = 1
    DragBar.Size = UDim2.new(1, 0, 0, 36)
    MakeDraggable(DragBar, Main, "MainWindow")
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Corner(Sidebar, 8)
    local SideCover = Instance.new("Frame")
    SideCover.Name = "SideCover"
    SideCover.Parent = Sidebar
    SideCover.AnchorPoint = Vector2.new(1, 0)
    SideCover.Position = UDim2.new(1, 0, 0, 0)
    SideCover.Size = UDim2.new(0, 8, 1, 0)
    SideCover.BackgroundColor3 = Theme.Sidebar
    SideCover.BorderSizePixel = 0
    local SideSeparator = Instance.new("Frame")
    SideSeparator.Name = "SideSeparator"
    SideSeparator.Parent = Main
    SideSeparator.Position = UDim2.new(0, 140, 0, 0)
    SideSeparator.Size = UDim2.new(0, 1, 1, 0)
    SideSeparator.BackgroundColor3 = Theme.CardStroke
    SideSeparator.BorderSizePixel = 0
    local TitleArea = Instance.new("Frame")
    TitleArea.Name = "TitleArea"
    TitleArea.Parent = Sidebar
    TitleArea.BackgroundTransparency = 1
    TitleArea.Size = UDim2.new(1, 0, 0, 50)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = TitleArea
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 18, 0, 14)
    TitleLabel.Size = UDim2.new(1, -20, 0, 24)
    TitleLabel.FontFace = Theme.FontBold
    TitleLabel.Text = TitleText
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local TitleDot = Instance.new("Frame")
    TitleDot.Name = "TitleDot"
    TitleDot.Parent = TitleArea
    TitleDot.AnchorPoint = Vector2.new(0, 0.5)
    TitleDot.Position = UDim2.new(0, 18 + TitleLabel.TextBounds.X + 4, 0, 26)
    TitleDot.Size = UDim2.new(0, 6, 0, 6)
    TitleDot.BackgroundColor3 = Theme.Accent
    Corner(TitleDot, 3)
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabNavigationList"
    TabList.Parent = Sidebar
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.Position = UDim2.new(0, 0, 0, 55)
    TabList.Size = UDim2.new(1, 0, 1, -65)
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.ScrollBarThickness = 0
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabList
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    local TabListPadding = Instance.new("UIPadding")
    TabListPadding.Parent = TabList
    TabListPadding.PaddingLeft = UDim.new(0, 8)
    TabListPadding.PaddingRight = UDim.new(0, 8)
    TabListPadding.PaddingTop = UDim.new(0, 4)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = Main
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 145, 0, 10)
    ContentContainer.Size = UDim2.new(1, -155, 1, -20)
    ContentContainer.ClipsDescendants = true
    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,
        ContentContainer = ContentContainer,
        TabList = TabList,
        Tabs = {},
        CurrentTab = nil,
        Keybinds = {},
        Popups = {},
        Enabled = true
    }
    function Window:Toggle()
        self.Enabled = not self.Enabled
        ScreenGui.Enabled = self.Enabled
    end
    function Window:Destroy()
        ScreenGui:Destroy()
        if self.WatermarkGui then self.WatermarkGui:Destroy() end
        if self.KeybindsGui then self.KeybindsGui:Destroy() end
    end
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            Window:Toggle()
        end
    end)
    function Window:CreateTab(tabName, iconId)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabButton_" .. tabName
        TabBtn.Parent = TabList
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        Corner(TabBtn, 6)
        local Pill = Instance.new("Frame")
        Pill.Name = "ActivePill"
        Pill.Parent = TabBtn
        Pill.AnchorPoint = Vector2.new(0, 0.5)
        Pill.Position = UDim2.new(0, -4, 0.5, 0)
        Pill.Size = UDim2.new(0, 3, 0, 18)
        Pill.BackgroundColor3 = Theme.Accent
        Pill.Visible = false
        Corner(Pill, 2)
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "TabIcon"
        Icon.Parent = TabBtn
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 12, 0.5, -9)
        Icon.Size = UDim2.new(0, 18, 0, 18)
        Icon.Image = iconId or "rbxassetid://10734975692"
        Icon.ImageColor3 = Theme.TextDim
        local Label = Instance.new("TextLabel")
        Label.Name = "TabLabel"
        Label.Parent = TabBtn
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 38, 0, 0)
        Label.Size = UDim2.new(1, -40, 1, 0)
        Label.FontFace = Theme.FontMedium or Theme.Font
        Label.Text = tabName
        Label.TextColor3 = Theme.TextDim
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local TabView = Instance.new("Frame")
        TabView.Name = "TabView_" .. tabName
        TabView.Parent = ContentContainer
        TabView.BackgroundTransparency = 1
        TabView.Size = UDim2.new(1, 0, 1, 0)
        TabView.Visible = false
        local LeftCol = Instance.new("ScrollingFrame")
        LeftCol.Name = "LeftColumn"
        LeftCol.Parent = TabView
        LeftCol.BackgroundTransparency = 1
        LeftCol.BorderSizePixel = 0
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        LeftCol.Size = UDim2.new(0.5, -6, 1, 0)
        LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftCol.ScrollBarThickness = 2
        LeftCol.ScrollBarImageColor3 = Theme.CardStroke
        LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Parent = LeftCol
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        local RightCol = Instance.new("ScrollingFrame")
        RightCol.Name = "RightColumn"
        RightCol.Parent = TabView
        RightCol.BackgroundTransparency = 1
        RightCol.BorderSizePixel = 0
        RightCol.Position = UDim2.new(0.5, 6, 0, 0)
        RightCol.Size = UDim2.new(0.5, -6, 1, 0)
        RightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightCol.ScrollBarThickness = 2
        RightCol.ScrollBarImageColor3 = Theme.CardStroke
        RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Parent = RightCol
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)
        local Tab = {
            Name = tabName,
            Button = TabBtn,
            View = TabView,
            LeftColumn = LeftCol,
            RightColumn = RightCol
        }
        local function Select()
            if Window.CurrentTab == Tab then return end
            if Window.CurrentTab then
                local old = Window.CurrentTab
                old.View.Visible = false
                Tween(old.Button, {0.15, "Quad", "Out"}, {BackgroundTransparency = 1})
                old.Button.ActivePill.Visible = false
                old.Button.TabIcon.ImageColor3 = Theme.TextDim
                old.Button.TabLabel.TextColor3 = Theme.TextDim
            end
            Window.CurrentTab = Tab
            Tab.View.Visible = true
            Tween(Tab.Button, {0.15, "Quad", "Out"}, {
                BackgroundColor3 = Theme.ItemActive,
                BackgroundTransparency = 0.5
            })
            Tab.Button.ActivePill.Visible = true
            Tab.Button.TabIcon.ImageColor3 = Theme.Text
            Tab.Button.TabLabel.TextColor3 = Theme.Text
        end
        TabBtn.MouseButton1Click:Connect(Select)
        TabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {0.15, "Quad", "Out"}, {
                    BackgroundColor3 = Theme.ItemHover,
                    BackgroundTransparency = 0.7
                })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {0.15, "Quad", "Out"}, {BackgroundTransparency = 1})
            end
        end)
        if #Window.Tabs == 0 then
            Select()
        end
        table.insert(Window.Tabs, Tab)
        function Tab:CreateSection(sectionTitle, side)
            local ParentCol = (side and side:lower() == "right") and RightCol or LeftCol
            local Card = Instance.new("Frame")
            Card.Name = "SectionCard_" .. sectionTitle
            Card.Parent = ParentCol
            Card.BackgroundColor3 = Theme.Card
            Card.BorderSizePixel = 0
            Card.Size = UDim2.new(1, -4, 0, 0)
            Card.AutomaticSize = Enum.AutomaticSize.Y
            Corner(Card, 6)
            Stroke(Card, Theme.CardStroke, 1)
            local CardPadding = Instance.new("UIPadding")
            CardPadding.Parent = Card
            CardPadding.PaddingBottom = UDim.new(0, 10)
            CardPadding.PaddingLeft = UDim.new(0, 12)
            CardPadding.PaddingRight = UDim.new(0, 12)
            CardPadding.PaddingTop = UDim.new(0, 10)
            local Header = Instance.new("Frame")
            Header.Name = "CardHeader"
            Header.Parent = Card
            Header.BackgroundTransparency = 1
            Header.Size = UDim2.new(1, 0, 0, 22)
            local Title = Instance.new("TextLabel")
            Title.Name = "CardTitle"
            Title.Parent = Header
            Title.BackgroundTransparency = 1
            Title.Size = UDim2.new(1, 0, 1, 0)
            Title.FontFace = Theme.FontSemiBold
            Title.Text = sectionTitle
            Title.TextColor3 = Theme.Text
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left
            local HeaderLine = Instance.new("Frame")
            HeaderLine.Name = "HeaderLine"
            HeaderLine.Parent = Card
            HeaderLine.Position = UDim2.new(0, 0, 0, 24)
            HeaderLine.Size = UDim2.new(1, 0, 0, 1)
            HeaderLine.BackgroundColor3 = Theme.CardStroke
            HeaderLine.BorderSizePixel = 0
            local Items = Instance.new("Frame")
            Items.Name = "ItemsContainer"
            Items.Parent = Card
            Items.BackgroundTransparency = 1
            Items.Position = UDim2.new(0, 0, 0, 30)
            Items.Size = UDim2.new(1, 0, 0, 0)
            Items.AutomaticSize = Enum.AutomaticSize.Y
            local ItemsLayout = Instance.new("UIListLayout")
            ItemsLayout.Parent = Items
            ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemsLayout.Padding = UDim.new(0, 6)
            local Section = {
                Card = Card,
                Items = Items
            }
            function Section:CreateToggle(opt)
                opt = opt or {}
                local Name = opt.Name or "Toggle"
                local State = opt.Default or false
                local Callback = opt.Callback or function() end
                local Row = Instance.new("TextButton")
                Row.Name = "Toggle_" .. Name
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, 26)
                Row.Text = ""
                Row.AutoButtonColor = false
                local Box = Instance.new("Frame")
                Box.Name = "Box"
                Box.Parent = Row
                Box.Position = UDim2.new(0, 0, 0.5, -9)
                Box.Size = UDim2.new(0, 18, 0, 18)
                Box.BackgroundColor3 = State and Theme.Accent or Theme.Item
                Corner(Box, 4)
                local BoxStroke = Stroke(Box, State and Theme.Accent or Theme.ItemStroke, 1)
                local Check = Instance.new("ImageLabel")
                Check.Name = "Checkmark"
                Check.Parent = Box
                Check.AnchorPoint = Vector2.new(0.5, 0.5)
                Check.Position = UDim2.new(0.5, 0, 0.5, 0)
                Check.Size = UDim2.new(0, 12, 0, 12)
                Check.BackgroundTransparency = 1
                Check.Image = "rbxassetid://6031094667"
                Check.ImageColor3 = Theme.Background
                Check.ImageTransparency = State and 0 or 1
                local Txt = Instance.new("TextLabel")
                Txt.Name = "ToggleLabel"
                Txt.Parent = Row
                Txt.BackgroundTransparency = 1
                Txt.Position = UDim2.new(0, 28, 0, 0)
                Txt.Size = UDim2.new(1, -28, 1, 0)
                Txt.FontFace = Theme.Font
                Txt.Text = Name
                Txt.TextColor3 = Theme.Text
                Txt.TextSize = 13
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                local function SetState(val)
                    State = val
                    Tween(Box, {0.15, "Quad", "Out"}, {
                        BackgroundColor3 = State and Theme.Accent or Theme.Item
                    })
                    Tween(BoxStroke, {0.15, "Quad", "Out"}, {
                        Color = State and Theme.Accent or Theme.ItemStroke
                    })
                    Tween(Check, {0.15, "Quad", "Out"}, {
                        ImageTransparency = State and 0 or 1
                    })
                    pcall(Callback, State)
                end
                Row.MouseButton1Click:Connect(function()
                    SetState(not State)
                end)
                function Row:CreateKeybind(kbOpt)
                    kbOpt = kbOpt or {}
                    local BindKey = kbOpt.Default or Enum.KeyCode.Unknown
                    local KbCallback = kbOpt.Callback or function() end
                    local Badge = Instance.new("TextButton")
                    Badge.Name = "InlineKeybind"
                    Badge.Parent = Row
                    Badge.AnchorPoint = Vector2.new(1, 0.5)
                    Badge.Position = UDim2.new(1, 0, 0.5, 0)
                    Badge.Size = UDim2.new(0, 38, 0, 18)
                    Badge.BackgroundColor3 = Theme.Item
                    Badge.Text = BindKey == Enum.KeyCode.Unknown and "-" or BindKey.Name
                    Badge.TextColor3 = Theme.TextDim
                    Badge.TextSize = 11
                    Badge.FontFace = Theme.Font
                    Corner(Badge, 3)
                    Stroke(Badge, Theme.ItemStroke, 1)
                    local listening = false
                    Badge.MouseButton1Click:Connect(function()
                        listening = true
                        Badge.Text = "..."
                        Badge.TextColor3 = Theme.Accent
                    end)
                    UserInputService.InputBegan:Connect(function(inp, gpe)
                        if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            if inp.KeyCode == Enum.KeyCode.Escape then
                                BindKey = Enum.KeyCode.Unknown
                                Badge.Text = "-"
                            else
                                BindKey = inp.KeyCode
                                Badge.Text = BindKey.Name
                            end
                            Badge.TextColor3 = Theme.TextDim
                        elseif not gpe and BindKey ~= Enum.KeyCode.Unknown and inp.KeyCode == BindKey then
                            SetState(not State)
                            pcall(KbCallback, State)
                        end
                    end)
                    return Badge
                end
                return Row
            end
            function Section:CreateSlider(opt)
                opt = opt or {}
                local Name = opt.Name or "Slider"
                local Min = opt.Min or 0
                local Max = opt.Max or 100
                local Val = opt.Default or Min
                local Decimals = opt.Decimals or 0
                local Suffix = opt.Suffix or ""
                local Callback = opt.Callback or function() end
                local Row = Instance.new("Frame")
                Row.Name = "Slider_" .. Name
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, 42)
                local TopLabel = Instance.new("TextLabel")
                TopLabel.Name = "SliderTitle"
                TopLabel.Parent = Row
                TopLabel.BackgroundTransparency = 1
                TopLabel.Size = UDim2.new(0.7, 0, 0, 18)
                TopLabel.FontFace = Theme.Font
                TopLabel.Text = Name
                TopLabel.TextColor3 = Theme.Text
                TopLabel.TextSize = 13
                TopLabel.TextXAlignment = Enum.TextXAlignment.Left
                local ValLabel = Instance.new("TextLabel")
                ValLabel.Name = "SliderValue"
                ValLabel.Parent = Row
                ValLabel.BackgroundTransparency = 1
                ValLabel.Position = UDim2.new(0.7, 0, 0, 0)
                ValLabel.Size = UDim2.new(0.3, 0, 0, 18)
                ValLabel.FontFace = Theme.Font
                ValLabel.Text = string.format("%." .. Decimals .. "f", Val) .. Suffix
                ValLabel.TextColor3 = Theme.TextDim
                ValLabel.TextSize = 12
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                local Track = Instance.new("TextButton")
                Track.Name = "SliderTrack"
                Track.Parent = Row
                Track.Position = UDim2.new(0, 0, 0, 24)
                Track.Size = UDim2.new(1, 0, 0, 8)
                Track.BackgroundColor3 = Theme.Item
                Track.Text = ""
                Track.AutoButtonColor = false
                Corner(Track, 4)
                Stroke(Track, Theme.ItemStroke, 1)
                local Fill = Instance.new("Frame")
                Fill.Name = "SliderFill"
                Fill.Parent = Track
                Fill.Size = UDim2.new((Val - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Corner(Fill, 4)
                local dragging = false
                local function UpdateFromX(x)
                    local pct = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Val = Min + (Max - Min) * pct
                    if Decimals == 0 then
                        Val = math.floor(Val + 0.5)
                    else
                        Val = tonumber(string.format("%." .. Decimals .. "f", Val))
                    end
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    ValLabel.Text = string.format("%." .. Decimals .. "f", Val) .. Suffix
                    pcall(Callback, Val)
                end
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateFromX(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromX(input.Position.X)
                    end
                end)
                return Row
            end
            function Section:CreateDropdown(opt)
                opt = opt or {}
                local Name = opt.Name or "Dropdown"
                local ItemsList = opt.Items or {}
                local Multi = opt.Multi or false
                local Callback = opt.Callback or function() end
                local Selected = Multi and {} or (opt.Default or ItemsList[1] or "")
                if Multi and type(opt.Default) == "table" then
                    for _, v in ipairs(opt.Default) do Selected[v] = true end
                end
                local Row = Instance.new("Frame")
                Row.Name = "DropdownRow_" .. Name
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, 50)
                local Title = Instance.new("TextLabel")
                Title.Name = "DropdownTitle"
                Title.Parent = Row
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1, 0, 0, 18)
                Title.FontFace = Theme.Font
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left
                local Box = Instance.new("TextButton")
                Box.Name = "DropdownBtn"
                Box.Parent = Row
                Box.Position = UDim2.new(0, 0, 0, 20)
                Box.Size = UDim2.new(1, 0, 0, 26)
                Box.BackgroundColor3 = Theme.Item
                Box.Text = ""
                Box.AutoButtonColor = false
                Corner(Box, 4)
                Stroke(Box, Theme.ItemStroke, 1)
                local ValLabel = Instance.new("TextLabel")
                ValLabel.Name = "DropdownSelected"
                ValLabel.Parent = Box
                ValLabel.BackgroundTransparency = 1
                ValLabel.Position = UDim2.new(0, 10, 0, 0)
                ValLabel.Size = UDim2.new(1, -30, 1, 0)
                ValLabel.FontFace = Theme.Font
                ValLabel.TextColor3 = Theme.Text
                ValLabel.TextSize = 12
                ValLabel.TextXAlignment = Enum.TextXAlignment.Left
                local Arrow = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.Parent = Box
                Arrow.AnchorPoint = Vector2.new(1, 0.5)
                Arrow.Position = UDim2.new(1, -8, 0.5, 0)
                Arrow.Size = UDim2.new(0, 14, 0, 14)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = "rbxassetid://6034818372"
                Arrow.ImageColor3 = Theme.TextDim
                local function FormatSelected()
                    if Multi then
                        local count = 0
                        for _ in pairs(Selected) do count = count + 1 end
                        return count .. " Selected"
                    else
                        return tostring(Selected)
                    end
                end
                ValLabel.Text = FormatSelected()
                local Popup = Instance.new("Frame")
                Popup.Name = "DropdownPopup_" .. Name
                Popup.Parent = ScreenGui
                Popup.BackgroundColor3 = Theme.Card
                Popup.Size = UDim2.new(0, 180, 0, math.min(#ItemsList * 24 + 8, 140))
                Popup.Visible = false
                Popup.ZIndex = 50
                Corner(Popup, 6)
                Stroke(Popup, Theme.CardStroke, 1.2)
                local PopScroll = Instance.new("ScrollingFrame")
                PopScroll.Parent = Popup
                PopScroll.BackgroundTransparency = 1
                PopScroll.Size = UDim2.new(1, 0, 1, 0)
                PopScroll.ScrollBarThickness = 2
                PopScroll.ScrollBarImageColor3 = Theme.CardStroke
                PopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                local PopLayout = Instance.new("UIListLayout")
                PopLayout.Parent = PopScroll
                PopLayout.Padding = UDim.new(0, 2)
                local PopPad = Instance.new("UIPadding")
                PopPad.Parent = PopScroll
                PopPad.PaddingTop = UDim.new(0, 4)
                PopPad.PaddingBottom = UDim.new(0, 4)
                PopPad.PaddingLeft = UDim.new(0, 4)
                PopPad.PaddingRight = UDim.new(0, 4)
                local isOpen = false
                local function TogglePopup()
                    isOpen = not isOpen
                    if isOpen then
                        local pos = Box.AbsolutePosition
                        Popup.Position = UDim2.new(0, pos.X, 0, pos.Y + Box.AbsoluteSize.Y + 4)
                        Popup.Size = UDim2.new(0, Box.AbsoluteSize.X, 0, math.min(#ItemsList * 26 + 8, 140))
                        Popup.Visible = true
                        Tween(Arrow, {0.15, "Quad", "Out"}, {Rotation = 180})
                    else
                        Popup.Visible = false
                        Tween(Arrow, {0.15, "Quad", "Out"}, {Rotation = 0})
                    end
                end
                Box.MouseButton1Click:Connect(TogglePopup)
                for _, itm in ipairs(ItemsList) do
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Name = "Item_" .. tostring(itm)
                    ItemBtn.Parent = PopScroll
                    ItemBtn.BackgroundColor3 = Theme.Item
                    ItemBtn.BackgroundTransparency = 1
                    ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                    ItemBtn.FontFace = Theme.Font
                    ItemBtn.Text = "  " .. tostring(itm)
                    ItemBtn.TextColor3 = (Multi and Selected[itm]) and Theme.Accent or ((not Multi and Selected == itm) and Theme.Accent or Theme.TextDim)
                    ItemBtn.TextSize = 12
                    ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    ItemBtn.ZIndex = 51
                    Corner(ItemBtn, 4)
                    ItemBtn.MouseButton1Click:Connect(function()
                        if Multi then
                            Selected[itm] = not Selected[itm]
                            ItemBtn.TextColor3 = Selected[itm] and Theme.Accent or Theme.TextDim
                            ValLabel.Text = FormatSelected()
                            local active = {}
                            for k, v in pairs(Selected) do if v then table.insert(active, k) end end
                            pcall(Callback, active)
                        else
                            Selected = itm
                            for _, child in ipairs(PopScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child.TextColor3 = (child.Name == "Item_" .. tostring(itm)) and Theme.Accent or Theme.TextDim
                                end
                            end
                            ValLabel.Text = FormatSelected()
                            TogglePopup()
                            pcall(Callback, Selected)
                        end
                    end)
                end
                return Row
            end
            function Section:CreateColorPicker(opt)
                opt = opt or {}
                local Name = opt.Name or "Colorpicker"
                local Color = opt.Default or Color3.fromRGB(245, 185, 195)
                local Callback = opt.Callback or function() end
                local Row = Instance.new("Frame")
                Row.Name = "ColorRow_" .. Name
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, 26)
                local Title = Instance.new("TextLabel")
                Title.Name = "ColorTitle"
                Title.Parent = Row
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(0.7, 0, 1, 0)
                Title.FontFace = Theme.Font
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left
                local Swatch = Instance.new("TextButton")
                Swatch.Name = "Swatch"
                Swatch.Parent = Row
                Swatch.AnchorPoint = Vector2.new(1, 0.5)
                Swatch.Position = UDim2.new(1, 0, 0.5, 0)
                Swatch.Size = UDim2.new(0, 20, 0, 20)
                Swatch.BackgroundColor3 = Color
                Swatch.Text = ""
                Corner(Swatch, 10)
                Stroke(Swatch, Theme.ItemStroke, 1)
                local Popup = Instance.new("Frame")
                Popup.Name = "ColorPopup_" .. Name
                Popup.Parent = ScreenGui
                Popup.BackgroundColor3 = Theme.Card
                Popup.Size = UDim2.new(0, 140, 0, 60)
                Popup.Visible = false
                Popup.ZIndex = 60
                Corner(Popup, 6)
                Stroke(Popup, Theme.CardStroke, 1.2)
                local PresetGrid = Instance.new("UIGridLayout")
                PresetGrid.Parent = Popup
                PresetGrid.CellSize = UDim2.new(0, 20, 0, 20)
                PresetGrid.CellPadding = UDim2.new(0, 6, 0, 6)
                local PopPad = Instance.new("UIPadding")
                PopPad.Parent = Popup
                PopPad.PaddingTop = UDim.new(0, 8)
                PopPad.PaddingLeft = UDim.new(0, 8)
                local presets = {
                    Color3.fromRGB(245, 185, 195), Color3.fromRGB(180, 50, 70),
                    Color3.fromRGB(80, 20, 30), Color3.fromRGB(255, 60, 60),
                    Color3.fromRGB(60, 180, 255), Color3.fromRGB(80, 255, 140),
                    Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 255, 255)
                }
                for _, c in ipairs(presets) do
                    local PBtn = Instance.new("TextButton")
                    PBtn.Parent = Popup
                    PBtn.BackgroundColor3 = c
                    PBtn.Text = ""
                    PBtn.ZIndex = 61
                    Corner(PBtn, 4)
                    PBtn.MouseButton1Click:Connect(function()
                        Color = c
                        Swatch.BackgroundColor3 = Color
                        Popup.Visible = false
                        pcall(Callback, Color)
                    end)
                end
                local isOpen = false
                Swatch.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local pos = Swatch.AbsolutePosition
                        Popup.Position = UDim2.new(0, pos.X - 110, 0, pos.Y + 26)
                        Popup.Visible = true
                    else
                        Popup.Visible = false
                    end
                end)
                return Row
            end
            function Section:CreateKeybind(opt)
                opt = opt or {}
                local Name = opt.Name or "Keybind"
                local Key = opt.Default or Enum.KeyCode.Unknown
                local Callback = opt.Callback or function() end
                local Row = Instance.new("Frame")
                Row.Name = "KeybindRow_" .. Name
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, 26)
                local Title = Instance.new("TextLabel")
                Title.Name = "KeybindTitle"
                Title.Parent = Row
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(0.7, 0, 1, 0)
                Title.FontFace = Theme.Font
                Title.Text = Name
                Title.TextColor3 = Theme.Text
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left
                local Badge = Instance.new("TextButton")
                Badge.Name = "KeybindBadge"
                Badge.Parent = Row
                Badge.AnchorPoint = Vector2.new(1, 0.5)
                Badge.Position = UDim2.new(1, 0, 0.5, 0)
                Badge.Size = UDim2.new(0, 46, 0, 20)
                Badge.BackgroundColor3 = Theme.Item
                Badge.Text = Key == Enum.KeyCode.Unknown and "None" or Key.Name
                Badge.TextColor3 = Theme.TextDim
                Badge.TextSize = 11
                Badge.FontFace = Theme.Font
                Corner(Badge, 4)
                Stroke(Badge, Theme.ItemStroke, 1)
                local listening = false
                Badge.MouseButton1Click:Connect(function()
                    listening = true
                    Badge.Text = "..."
                    Badge.TextColor3 = Theme.Accent
                end)
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        if inp.KeyCode == Enum.KeyCode.Escape then
                            Key = Enum.KeyCode.Unknown
                            Badge.Text = "None"
                        else
                            Key = inp.KeyCode
                            Badge.Text = Key.Name
                        end
                        Badge.TextColor3 = Theme.TextDim
                    elseif not gpe and Key ~= Enum.KeyCode.Unknown and inp.KeyCode == Key then
                        pcall(Callback)
                    end
                end)
                return Row
            end
            function Section:CreateTextBox(opt)
                opt = opt or {}
                local Name = opt.Name or "Input"
                local Placeholder = opt.Placeholder or "Enter value..."
                local Callback = opt.Callback or function() end
                local Row = Instance.new("Frame")
                Row.Name = "TextBoxRow_" .. Name
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, (opt.NoTitle and 28 or 46))
                local BoxTop = 0
                if not opt.NoTitle then
                    local Title = Instance.new("TextLabel")
                    Title.Name = "BoxTitle"
                    Title.Parent = Row
                    Title.BackgroundTransparency = 1
                    Title.Size = UDim2.new(1, 0, 0, 16)
                    Title.FontFace = Theme.Font
                    Title.Text = Name
                    Title.TextColor3 = Theme.Text
                    Title.TextSize = 12
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    BoxTop = 18
                end
                local Box = Instance.new("TextBox")
                Box.Name = "InputBox"
                Box.Parent = Row
                Box.Position = UDim2.new(0, 0, 0, BoxTop)
                Box.Size = UDim2.new(1, 0, 0, 26)
                Box.BackgroundColor3 = Theme.Item
                Box.FontFace = Theme.Font
                Box.PlaceholderText = Placeholder
                Box.PlaceholderColor3 = Theme.TextDim
                Box.Text = opt.Default or ""
                Box.TextColor3 = Theme.Text
                Box.TextSize = 12
                Box.ClearTextOnFocus = false
                Corner(Box, 4)
                local BoxStroke = Stroke(Box, Theme.ItemStroke, 1)
                Box.Focused:Connect(function()
                    Tween(BoxStroke, {0.15, "Quad", "Out"}, {Color = Theme.Accent})
                end)
                Box.FocusLost:Connect(function(enter)
                    Tween(BoxStroke, {0.15, "Quad", "Out"}, {Color = Theme.ItemStroke})
                    pcall(Callback, Box.Text, enter)
                end)
                return Row
            end
            function Section:CreateButton(opt)
                opt = opt or {}
                local Name = opt.Name or "Button"
                local Callback = opt.Callback or function() end
                local Btn = Instance.new("TextButton")
                Btn.Name = "Button_" .. Name
                Btn.Parent = Items
                Btn.BackgroundColor3 = Theme.Item
                Btn.Size = UDim2.new(1, 0, 0, 26)
                Btn.FontFace = Theme.Font
                Btn.Text = Name
                Btn.TextColor3 = Theme.Text
                Btn.TextSize = 12
                Btn.AutoButtonColor = false
                Corner(Btn, 4)
                local BtnStroke = Stroke(Btn, Theme.ItemStroke, 1)
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {0.12, "Quad", "Out"}, {BackgroundColor3 = Theme.ItemHover})
                    Tween(BtnStroke, {0.12, "Quad", "Out"}, {Color = Theme.CardStrokeHover})
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {0.12, "Quad", "Out"}, {BackgroundColor3 = Theme.Item})
                    Tween(BtnStroke, {0.12, "Quad", "Out"}, {Color = Theme.ItemStroke})
                end)
                Btn.MouseButton1Click:Connect(function()
                    pcall(Callback)
                end)
                return Btn
            end
            function Section:CreateButtonPair(opt)
                opt = opt or {}
                local b1 = opt.Button1 or { Name = "Button 1", Callback = function() end }
                local b2 = opt.Button2 or { Name = "Button 2", Callback = function() end }
                local Row = Instance.new("Frame")
                Row.Name = "ButtonPairRow"
                Row.Parent = Items
                Row.BackgroundTransparency = 1
                Row.Size = UDim2.new(1, 0, 0, 26)
                local Btn1 = Instance.new("TextButton")
                Btn1.Name = "Btn1_" .. b1.Name
                Btn1.Parent = Row
                Btn1.Position = UDim2.new(0, 0, 0, 0)
                Btn1.Size = UDim2.new(0.5, -4, 1, 0)
                Btn1.BackgroundColor3 = Theme.Item
                Btn1.FontFace = Theme.Font
                Btn1.Text = b1.Name
                Btn1.TextColor3 = Theme.Text
                Btn1.TextSize = 12
                Btn1.AutoButtonColor = false
                Corner(Btn1, 4)
                Stroke(Btn1, Theme.ItemStroke, 1)
                Btn1.MouseButton1Click:Connect(b1.Callback or function() end)
                local Btn2 = Instance.new("TextButton")
                Btn2.Name = "Btn2_" .. b2.Name
                Btn2.Parent = Row
                Btn2.Position = UDim2.new(0.5, 4, 0, 0)
                Btn2.Size = UDim2.new(0.5, -4, 1, 0)
                Btn2.BackgroundColor3 = Theme.Item
                Btn2.FontFace = Theme.Font
                Btn2.Text = b2.Name
                Btn2.TextColor3 = Theme.Text
                Btn2.TextSize = 12
                Btn2.AutoButtonColor = false
                Corner(Btn2, 4)
                Stroke(Btn2, Theme.ItemStroke, 1)
                Btn2.MouseButton1Click:Connect(b2.Callback or function() end)
                return Row
            end
            function Section:CreateLabel(opt)
                local txt = type(opt) == "table" and (opt.Text or "Label") or tostring(opt)
                local Lbl = Instance.new("TextLabel")
                Lbl.Name = "Label"
                Lbl.Parent = Items
                Lbl.BackgroundTransparency = 1
                Lbl.Size = UDim2.new(1, 0, 0, 20)
                Lbl.FontFace = Theme.Font
                Lbl.Text = txt
                Lbl.TextColor3 = Theme.TextDim
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                return Lbl
            end
            return Section
        end
        return Tab
    end
    function Window:CreateWatermark(opt)
        opt = opt or {}
        local Tag = opt.Name or "syn"
        local Visible = opt.Visible ~= false
        local WmGui = Instance.new("ScreenGui")
        WmGui.Name = "SynWatermark"
        WmGui.ResetOnSpawn = false
        WmGui.Parent = guiParent
        local Frame = Instance.new("Frame")
        Frame.Name = "WatermarkFrame"
        Frame.Parent = WmGui
        if savedSettings.Watermark and type(savedSettings.Watermark) == "table" and #savedSettings.Watermark >= 4 then
            local p = savedSettings.Watermark
            Frame.Position = UDim2.new(p[1], p[2], p[3], p[4])
        else
            Frame.Position = UDim2.new(0, 16, 0, 16)
        end
        Frame.Size = UDim2.new(0, 260, 0, 26)
        Frame.BackgroundColor3 = Theme.Background
        Frame.BorderSizePixel = 0
        Frame.Visible = Visible
        Corner(Frame, 6)
        Stroke(Frame, Theme.CardStroke, 1)
        MakeDraggable(Frame, Frame, "Watermark")
        local TagBox = Instance.new("Frame")
        TagBox.Name = "TagBox"
        TagBox.Parent = Frame
        TagBox.Position = UDim2.new(0, 4, 0.5, -9)
        TagBox.Size = UDim2.new(0, 36, 0, 18)
        TagBox.BackgroundColor3 = Theme.Accent
        Corner(TagBox, 4)
        local TagLabel = Instance.new("TextLabel")
        TagLabel.Parent = TagBox
        TagLabel.BackgroundTransparency = 1
        TagLabel.Size = UDim2.new(1, 0, 1, 0)
        TagLabel.FontFace = Theme.FontBold
        TagLabel.Text = Tag
        TagLabel.TextColor3 = Theme.Background
        TagLabel.TextSize = 12
        local Details = Instance.new("TextLabel")
        Details.Name = "Details"
        Details.Parent = Frame
        Details.BackgroundTransparency = 1
        Details.Position = UDim2.new(0, 46, 0, 0)
        Details.Size = UDim2.new(1, -50, 1, 0)
        Details.FontFace = Theme.Font
        Details.TextColor3 = Theme.Text
        Details.TextSize = 12
        Details.TextXAlignment = Enum.TextXAlignment.Left
        local fps = 60
        local lastTime = os.clock()
        RunService.RenderStepped:Connect(function()
            local now = os.clock()
            fps = math.floor(1 / (now - lastTime))
            lastTime = now
        end)
        task.spawn(function()
            while Frame.Parent do
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local user = LocalPlayer and LocalPlayer.Name or "User"
                local timeStr = os.date("%H:%M")
                Details.Text = string.format("%s  |  %d ms  |  %d fps  |  %s", user, ping, fps, timeStr)
                Frame.Size = UDim2.new(0, 46 + Details.TextBounds.X + 12, 0, 26)
                task.wait(0.5)
            end
        end)
        local Watermark = {
            Gui = WmGui,
            Frame = Frame
        }
        function Watermark:SetVisible(v)
            Frame.Visible = v
        end
        function Watermark:Destroy()
            WmGui:Destroy()
        end
        Window.WatermarkGui = WmGui
        return Watermark
    end
    function Window:CreateKeybindsHUD(opt)
        opt = opt or {}
        local Visible = opt.Visible ~= false
        local KbGui = Instance.new("ScreenGui")
        KbGui.Name = "SynKeybinds"
        KbGui.ResetOnSpawn = false
        KbGui.Parent = guiParent
        local Frame = Instance.new("Frame")
        Frame.Name = "KeybindsHUDFrame"
        Frame.Parent = KbGui
        if savedSettings.KeybindsHUD and type(savedSettings.KeybindsHUD) == "table" and #savedSettings.KeybindsHUD >= 4 then
            local p = savedSettings.KeybindsHUD
            Frame.Position = UDim2.new(p[1], p[2], p[3], p[4])
        else
            Frame.Position = UDim2.new(0, 16, 0.4, 0)
        end
        Frame.Size = UDim2.new(0, 170, 0, 30)
        Frame.BackgroundColor3 = Theme.Card
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        Frame.Visible = Visible
        Corner(Frame, 6)
        Stroke(Frame, Theme.CardStroke, 1)
        MakeDraggable(Frame, Frame, "KeybindsHUD")
        local Title = Instance.new("TextLabel")
        Title.Parent = Frame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 6)
        Title.Size = UDim2.new(1, -20, 0, 16)
        Title.FontFace = Theme.FontBold
        Title.Text = "Keybinds"
        Title.TextColor3 = Theme.Text
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        local Line = Instance.new("Frame")
        Line.Parent = Frame
        Line.Position = UDim2.new(0, 0, 0, 26)
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.BackgroundColor3 = Theme.CardStroke
        Line.BorderSizePixel = 0
        local List = Instance.new("Frame")
        List.Name = "BindsList"
        List.Parent = Frame
        List.BackgroundTransparency = 1
        List.Position = UDim2.new(0, 10, 0, 30)
        List.Size = UDim2.new(1, -20, 0, 0)
        List.AutomaticSize = Enum.AutomaticSize.Y
        local Layout = Instance.new("UIListLayout")
        Layout.Parent = List
        Layout.Padding = UDim.new(0, 4)
        local Pad = Instance.new("UIPadding")
        Pad.Parent = List
        Pad.PaddingBottom = UDim.new(0, 6)
        local KeybindsHUD = {
            Gui = KbGui,
            Frame = Frame,
            List = List
        }
        function KeybindsHUD:SetVisible(v)
            Frame.Visible = v
        end
        function KeybindsHUD:Destroy()
            KbGui:Destroy()
        end
        Window.KeybindsGui = KbGui
        return KeybindsHUD
    end
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotificationContainer"
    NotifContainer.Parent = ScreenGui
    NotifContainer.AnchorPoint = Vector2.new(1, 1)
    NotifContainer.Position = UDim2.new(1, -20, 1, -20)
    NotifContainer.Size = UDim2.new(0, 260, 1, -40)
    NotifContainer.BackgroundTransparency = 1
    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.Parent = NotifContainer
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.Padding = UDim.new(0, 8)
    function Window:Notification(opt)
        opt = opt or {}
        local TitleText = opt.Title or "Notification"
        local BodyText = opt.Text or ""
        local Duration = opt.Duration or 3
        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Parent = NotifContainer
        Toast.BackgroundColor3 = Theme.Card
        Toast.Size = UDim2.new(1, 0, 0, 50)
        Toast.Transparency = 1
        Corner(Toast, 6)
        local ToastStroke = Stroke(Toast, Theme.CardStroke, 1)
        ToastStroke.Transparency = 1
        local NTitle = Instance.new("TextLabel")
        NTitle.Parent = Toast
        NTitle.BackgroundTransparency = 1
        NTitle.Position = UDim2.new(0, 12, 0, 6)
        NTitle.Size = UDim2.new(1, -24, 0, 16)
        NTitle.FontFace = Theme.FontBold
        NTitle.Text = TitleText
        NTitle.TextColor3 = Theme.Accent
        NTitle.TextSize = 13
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.TextTransparency = 1
        local NBody = Instance.new("TextLabel")
        NBody.Parent = Toast
        NBody.BackgroundTransparency = 1
        NBody.Position = UDim2.new(0, 12, 0, 24)
        NBody.Size = UDim2.new(1, -24, 0, 18)
        NBody.FontFace = Theme.Font
        NBody.Text = BodyText
        NBody.TextColor3 = Theme.Text
        NBody.TextSize = 12
        NBody.TextXAlignment = Enum.TextXAlignment.Left
        NBody.TextTransparency = 1
        Tween(Toast, {0.2, "Quad", "Out"}, {BackgroundTransparency = 0})
        Tween(ToastStroke, {0.2, "Quad", "Out"}, {Transparency = 0})
        Tween(NTitle, {0.2, "Quad", "Out"}, {TextTransparency = 0})
        Tween(NBody, {0.2, "Quad", "Out"}, {TextTransparency = 0})
        task.delay(Duration, function()
            Tween(Toast, {0.2, "Quad", "In"}, {BackgroundTransparency = 1})
            Tween(ToastStroke, {0.2, "Quad", "In"}, {Transparency = 1})
            Tween(NTitle, {0.2, "Quad", "In"}, {TextTransparency = 1})
            Tween(NBody, {0.2, "Quad", "In"}, {TextTransparency = 1})
            task.wait(0.25)
            Toast:Destroy()
        end)
    end
    return Window
end
return SynUI
