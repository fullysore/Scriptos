local TweenService = game:GetService('TweenService')
local TextService = game:GetService('TextService')
local CoreGui = game:GetService('CoreGui')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

local Toggles = {}
local Options = {}

getgenv().Toggles = Toggles
getgenv().Options = Options

local Library = {
    Registry = {},
    RegistryMap = {},
    
    FontColor = Color3.fromRGB(255, 255, 255),
    MainColor = Color3.fromRGB(8, 6, 9),
    BackgroundColor = Color3.fromRGB(10, 10, 10),
    AccentColor = Color3.fromRGB(70, 66, 141),
    OutlineColor = Color3.fromRGB(21, 21, 21),
    InactiveColor = Color3.fromRGB(91, 91, 91),
    
    Font = Enum.Font.PermanentMarker,
    
    OpenedFrames = {},
    Signals = {},
}

function Library:Create(Class, Properties)
    local Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    
    for Property, Value in next, Properties do
        Instance[Property] = Value
    end
    
    return Instance
end

function Library:MakeDraggable(Frame)
    local dragging, dragInput, dragStart, startPos
    
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:SafeCallback(func, ...)
    if not func then return end
    
    local success, err = pcall(func, ...)
    if not success then
        warn("Callback error:", err)
    end
end

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save()
    end
end

function Library:CreateWindow(Config)
    if type(Config) == 'string' then
        Config = { Title = Config }
    end
    
    Config.Title = Config.Title or "prove.wtf"
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
    }
    
    -- Create ScreenGui
    local ScreenGui = Library:Create('ScreenGui', {
        Name = 'ProveV2',
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    ProtectGui(ScreenGui)
    Library.ScreenGui = ScreenGui
    
    -- Main Frame
    local Main = Library:Create('Frame', {
        Name = 'Main',
        Parent = ScreenGui,
        BackgroundColor3 = Library.MainColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        ClipsDescendants = true,
        Size = UDim2.new(0, 625, 0, 600),
        Position = UDim2.new(0.47, 0, 0.5, 0),
    })
    
    Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 12),
        Parent = Main,
    })
    
    Library:MakeDraggable(Main)
    
    -- Top Bar
    local Top = Library:Create('Frame', {
        Name = 'top',
        Parent = Main,
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 625, 0, 41),
    })
    
    Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 10),
        Parent = Top,
    })
    
    Library:Create('UIStroke', {
        Color = Library.OutlineColor,
        Parent = Top,
    })
    
    -- Bottom extension for top bar
    Library:Create('Frame', {
        Parent = Top,
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 625, 0, 20),
        Position = UDim2.new(0, 0, 0.525, -1),
        ZIndex = 0,
    })
    
    -- Title Label
    Library:Create('TextLabel', {
        Parent = Top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 1),
        Size = UDim2.new(0, 88, 0, 36),
        Font = Library.Font,
        Text = Config.Title,
        TextColor3 = Library.AccentColor,
        TextSize = 26,
    })
    
    -- Tabs Container
    local TabsFrame = Library:Create('Frame', {
        Name = 'Tabs',
        Parent = Top,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 309, 0, 40),
        Position = UDim2.new(0.5056, 0, 0, 2),
    })
    
    Library:Create('UIListLayout', {
        Parent = TabsFrame,
        Padding = UDim.new(0, -20),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    -- Tab Indicator Gradient
    local TabGradient = Library:Create('Frame', {
        Name = 'gradient',
        Parent = Top,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(0, 334, 0, 7),
        ZIndex = 0,
    })
    
    Library:Create('UIGradient', {
        Parent = TabGradient,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.000, Library.AccentColor),
            ColorSequenceKeypoint.new(0.500, Library.BackgroundColor),
            ColorSequenceKeypoint.new(1.000, Library.BackgroundColor)
        },
    })
    
    -- Bottom Bar
    local Bottom = Library:Create('Frame', {
        Name = 'bottom',
        Parent = Main,
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 625, 0, 38),
        Position = UDim2.new(0, 0, 0, 562),
    })
    
    Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 12),
        Parent = Bottom,
    })
    
    Library:Create('UIStroke', {
        Color = Library.OutlineColor,
        Parent = Bottom,
    })
    
    -- Top extension for bottom bar
    Library:Create('Frame', {
        Parent = Bottom,
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 625, 0, 17),
        Position = UDim2.new(0, 0, 0.03333, -1),
    })
    
    -- Bottom Game Name Label
    Library:Create('TextLabel', {
        Parent = Bottom,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 21, 0, -1),
        Size = UDim2.new(0, 300, 0, 36),
        Font = Library.Font,
        Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        TextColor3 = Library.AccentColor,
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Bottom Keybind Label
    Library:Create('TextLabel', {
        Parent = Bottom,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 480, 0, -1),
        Size = UDim2.new(0, 130, 0, 36),
        Font = Library.Font,
        Text = "Menu: RShift",
        TextColor3 = Library.InactiveColor,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    
    Window.Main = Main
    Window.TabsFrame = TabsFrame
    Window.TabGradient = TabGradient
    
    function Window:AddTab(Name)
        local Tab = {
            Name = Name,
            Groupboxes = {},
        }
        
        -- Create Tab Button
        local TabButton = Library:Create('TextButton', {
            Name = Name,
            Parent = TabsFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 88, 0, 36),
            Font = Library.Font,
            Text = Name,
            TextColor3 = #Window.Tabs == 0 and Library.AccentColor or Library.InactiveColor,
            TextSize = 23,
            AutoButtonColor = false,
        })
        
        -- Left Side Container
        local LeftContainer = Library:Create('ScrollingFrame', {
            Name = 'Left_' .. Name,
            Parent = Main,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 6, 0.07833, 0),
            Size = UDim2.new(0, 301, 0, 509),
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = #Window.Tabs == 0,
        })
        
        Library:Create('UIListLayout', {
            Parent = LeftContainer,
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        -- Right Side Container
        local RightContainer = Library:Create('ScrollingFrame', {
            Name = 'Right_' .. Name,
            Parent = Main,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.52, -9, 0.07833, 0),
            Size = UDim2.new(0, 310, 0, 509),
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = #Window.Tabs == 0,
        })
        
        Library:Create('UIListLayout', {
            Parent = RightContainer,
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        Tab.LeftContainer = LeftContainer
        Tab.RightContainer = RightContainer
        Tab.TabButton = TabButton
        
        function Tab:Show()
            for _, OtherTab in pairs(Window.Tabs) do
                OtherTab:Hide()
            end
            
            LeftContainer.Visible = true
            RightContainer.Visible = true
            
            Window.CurrentTab = Tab
            
            -- Animate tab indicator
            local textBounds = TextService:GetTextSize(TabButton.Text, TabButton.TextSize, TabButton.Font, Vector2.new(math.huge, math.huge))
            local buttonAbsPos = TabButton.AbsolutePosition
            local buttonAbsSize = TabButton.AbsoluteSize
            local centerOffset = (buttonAbsSize.X - textBounds.X) / 2
            local textStart = buttonAbsPos.X + centerOffset
            local relativeX = textStart - Top.AbsolutePosition.X
            
            TweenService:Create(TabGradient, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, relativeX, 0, TabGradient.Position.Y.Offset),
                Size = UDim2.new(0, textBounds.X, 0, TabGradient.Size.Y.Offset)
            }):Play()
            
            task.wait(0.05)
            
            for _, OtherTab in pairs(Window.Tabs) do
                OtherTab.TabButton.TextColor3 = Library.InactiveColor
            end
            
            TabButton.TextColor3 = Library.AccentColor
        end
        
        function Tab:Hide()
            LeftContainer.Visible = false
            RightContainer.Visible = false
        end
        
        function Tab:AddLeftGroupbox(Name)
            return Tab:CreateGroupbox(Name, LeftContainer)
        end
        
        function Tab:AddRightGroupbox(Name)
            return Tab:CreateGroupbox(Name, RightContainer)
        end
        
        function Tab:CreateGroupbox(Name, ParentContainer)
            local Groupbox = {
                Name = Name,
            }
            
            -- Main Groupbox Frame
            local GroupboxFrame = Library:Create('Frame', {
                Name = 'Subtab',
                Parent = ParentContainer,
                BackgroundColor3 = Library.MainColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 301, 0, 100),
            })
            
            Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 4),
                Parent = GroupboxFrame,
            })
            
            Library:Create('UIStroke', {
                Color = Library.OutlineColor,
                Parent = GroupboxFrame,
            })
            
            -- Top Bar (must have)
            local TopBar = Library:Create('Frame', {
                Name = 'top',
                Parent = GroupboxFrame,
                BackgroundColor3 = Library.BackgroundColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 301, 0, 35),
                Position = UDim2.new(0, 0, 0, 0),
            })
            
            Library:Create('UIStroke', {
                Color = Library.OutlineColor,
                Parent = TopBar,
            })
            
            Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 4),
                Parent = TopBar,
            })
            
            -- Title Label
            Library:Create('TextLabel', {
                Parent = TopBar,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 0, 36),
                Position = UDim2.new(0, 0, 0, -3),
                Font = Library.Font,
                Text = Name,
                TextColor3 = Library.AccentColor,
                TextSize = 23,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2,
            })
            
            -- Bottom extension for top bar (must have)
            Library:Create('Frame', {
                Name = 'top',
                Parent = TopBar,
                BackgroundColor3 = Library.BackgroundColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 301, 0, 18),
                Position = UDim2.new(0, 0, 0.4869, 0),
            })
            
            -- ScrollingFrame for content
            local Container = Library:Create('ScrollingFrame', {
                Parent = GroupboxFrame,
                Active = true,
                BackgroundColor3 = Library.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.06876, 0),
                Size = UDim2.new(1, 0, 1, -35),
                ScrollBarImageTransparency = 1,
                CanvasSize = UDim2.new(0, 0, 0, 0),
            })
            
            Library:Create('UIListLayout', {
                Parent = Container,
                Padding = UDim.new(0, 0),
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            Groupbox.Container = Container
            Groupbox.Frame = GroupboxFrame
            
            function Groupbox:Resize()
                local contentSize = 0
                for _, child in pairs(Container:GetChildren()) do
                    if not child:IsA('UIListLayout') and child.Visible then
                        contentSize = contentSize + child.Size.Y.Offset
                    end
                end
                
                Container.CanvasSize = UDim2.new(0, 0, 0, contentSize)
                
                local Layout = ParentContainer:FindFirstChildOfClass('UIListLayout')
                if Layout then
                    ParentContainer.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
                end
            end
            
            function Groupbox:AddToggle(Idx, Info)
                local Toggle = {
                    Value = Info.Default or false,
                    Type = 'Toggle',
                    Callback = Info.Callback or function() end,
                }
                
                -- Toggle Frame (TextLabel with ImageButton)
                local ToggleLabel = Library:Create('TextLabel', {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 109, 0, 50),
                    Position = UDim2.new(0.00332, 3, 0, 0),
                    Font = Library.Font,
                    Text = Info.Text or 'Toggle',
                    TextColor3 = Library.InactiveColor,
                    TextSize = 20,
                })
                
                local ToggleButton = Library:Create('ImageButton', {
                    Parent = ToggleLabel,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ImageTransparency = 1,
                    BackgroundColor3 = Library.MainColor,
                    Size = UDim2.new(0, 15, 0, 15),
                    Position = UDim2.new(0.12844, -8, 0.34, 0),
                })
                
                Library:Create('UICorner', {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleButton,
                })
                
                Library:Create('UIStroke', {
                    Color = Library.OutlineColor,
                    Parent = ToggleButton,
                })
                
                function Toggle:SetValue(Value)
                    Toggle.Value = Value
                    
                    local textColor = Value and Color3.fromRGB(255, 255, 255) or Library.InactiveColor
                    local bgColor = Value and Library.AccentColor or Library.MainColor
                    
                    TweenService:Create(ToggleLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                        TextColor3 = textColor
                    }):Play()
                    
                    TweenService:Create(ToggleButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = bgColor
                    }):Play()
                    
                    Library:SafeCallback(Toggle.Callback, Value)
                end
                
                function Toggle:OnChanged(Func)
                    Toggle.Changed = Func
                    Func(Toggle.Value)
                end
                
                ToggleButton.MouseButton1Down:Connect(function()
                    Toggle:SetValue(not Toggle.Value)
                    Library:AttemptSave()
                end)
                
                Toggle:SetValue(Toggle.Value)
                Groupbox:Resize()
                
                Toggles[Idx] = Toggle
                return Toggle
            end
            
            function Groupbox:AddLabel(Text)
                local Label = Library:Create('TextLabel', {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 290, 0, 25),
                    Font = Library.Font,
                    Text = Text,
                    TextColor3 = Library.InactiveColor,
                    TextSize = 18,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                })
                
                Groupbox:Resize()
                
                return {
                    SetText = function(_, NewText)
                        Label.Text = NewText
                        Groupbox:Resize()
                    end
                }
            end
            
            function Groupbox:AddButton(Info)
                local Button = {
                    Callback = Info.Func or Info.Callback or function() end,
                }
                
                local ButtonFrame = Library:Create('TextButton', {
                    Parent = Container,
                    BackgroundColor3 = Library.BackgroundColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 290, 0, 35),
                    Font = Library.Font,
                    Text = Info.Text or 'Button',
                    TextColor3 = Library.FontColor,
                    TextSize = 18,
                    AutoButtonColor = false,
                })
                
                Library:Create('UICorner', {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ButtonFrame,
                })
                
                Library:Create('UIStroke', {
                    Color = Library.OutlineColor,
                    Parent = ButtonFrame,
                })
                
                ButtonFrame.MouseButton1Down:Connect(function()
                    Library:SafeCallback(Button.Callback)
                end)
                
                Groupbox:Resize()
                return Button
            end
            
            function Groupbox:AddDivider()
                local Divider = Library:Create('Frame', {
                    Parent = Container,
                    BackgroundColor3 = Library.OutlineColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 290, 0, 2),
                })
                
                Groupbox:Resize()
            end
            
            function Groupbox:AddBlank(Size)
                local Blank = Library:Create('Frame', {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 290, 0, Size or 10),
                })
                
                Groupbox:Resize()
            end
            
            table.insert(Tab.Groupboxes, Groupbox)
            Groupbox:Resize()
            
            return Groupbox
        end
        
        TabButton.MouseButton1Down:Connect(function()
            Tab:Show()
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Tab:Show()
        end
        
        return Tab
    end
    
    function Library:Toggle()
        Main.Visible = not Main.Visible
    end
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            Library:Toggle()
        end
    end)
    
    if Config.AutoShow ~= false then
        Main.Visible = true
    end
    
    return Window
end

function Library:Notify(Text, Duration)
    print("[Prove]", Text)
end

getgenv().Library = Library
return Library
