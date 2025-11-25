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

function Library:AddToRegistry(Instance, Properties)
    local Data = {
        Instance = Instance,
        Properties = Properties,
    }
    
    table.insert(Library.Registry, Data)
    Library.RegistryMap[Instance] = Data
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
    Config.Size = Config.Size or UDim2.new(0, 625, 0, 600)
    Config.Position = Config.Position or UDim2.new(0.47, 0, 0.5, 0)
    
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
        Size = Config.Size,
        Position = Config.Position,
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
    
    -- Title
    local TitleLabel = Library:Create('TextLabel', {
        Parent = Top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 1),
        Size = UDim2.new(0, 88, 0, 36),
        Font = Library.Font,
        Text = Config.Title,
        TextColor3 = Library.AccentColor,
        TextSize = 26,
    })
    
    -- Tab Container
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
    
    Library:Create('Frame', {
        Parent = Bottom,
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 625, 0, 17),
        Position = UDim2.new(0, 0, 0.03333, -1),
    })
    
    -- Bottom Labels
    local GameLabel = Library:Create('TextLabel', {
        Parent = Bottom,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 21, 0, -1),
        Size = UDim2.new(0, 200, 0, 36),
        Font = Library.Font,
        Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        TextColor3 = Library.AccentColor,
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local KeybindLabel = Library:Create('TextLabel', {
        Parent = Bottom,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 521, 0, -1),
        Size = UDim2.new(0, 100, 0, 36),
        Font = Library.Font,
        Text = "Menu: RShift",
        TextColor3 = Library.InactiveColor,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    
    Window.Main = Main
    Window.TabsFrame = TabsFrame
    Window.TabGradient = TabGradient
    Window.GameLabel = GameLabel
    Window.KeybindLabel = KeybindLabel
    
    function Window:AddTab(Name)
        local Tab = {
            Name = Name,
            Groupboxes = {},
            LeftSide = nil,
            RightSide = nil,
        }
        
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
        
        -- Left Groupbox Container
        local LeftContainer = Library:Create('Frame', {
            Name = 'Subtab_Left',
            Parent = Main,
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 301, 0, 509),
            Position = UDim2.new(0, 6, 0.07833, 0),
            Visible = #Window.Tabs == 0,
        })
        
        Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 4),
            Parent = LeftContainer,
        })
        
        Library:Create('UIStroke', {
            Color = Library.OutlineColor,
            Parent = LeftContainer,
        })
        
        -- Left Scrolling Frame
        local LeftScroll = Library:Create('ScrollingFrame', {
            Parent = LeftContainer,
            Active = true,
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
        })
        
        Library:Create('UIListLayout', {
            Parent = LeftScroll,
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        -- Right Containers (Top and Bottom)
        local RightTopContainer = Library:Create('Frame', {
            Name = 'Subtab_RightTop',
            Parent = Main,
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 303, 0, 250),
            Position = UDim2.new(0.52, -9, 0.07833, 0),
            Visible = #Window.Tabs == 0,
        })
        
        Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 4),
            Parent = RightTopContainer,
        })
        
        Library:Create('UIStroke', {
            Color = Library.OutlineColor,
            Parent = RightTopContainer,
        })
        
        local RightBottomContainer = Library:Create('Frame', {
            Name = 'Subtab_RightBottom',
            Parent = Main,
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 301, 0, 250),
            Position = UDim2.new(0.4992, 4, 0.50667, 2),
            Visible = #Window.Tabs == 0,
        })
        
        Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 4),
            Parent = RightBottomContainer,
        })
        
        Library:Create('UIStroke', {
            Color = Library.OutlineColor,
            Parent = RightBottomContainer,
        })
        
        Tab.LeftContainer = LeftContainer
        Tab.LeftScroll = LeftScroll
        Tab.RightTopContainer = RightTopContainer
        Tab.RightBottomContainer = RightBottomContainer
        Tab.TabButton = TabButton
        
        function Tab:Show()
            for _, OtherTab in pairs(Window.Tabs) do
                OtherTab:Hide()
            end
            
            LeftContainer.Visible = true
            RightTopContainer.Visible = true
            RightBottomContainer.Visible = true
            
            Window.CurrentTab = Tab
            
            -- Update tab indicator
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
            RightTopContainer.Visible = false
            RightBottomContainer.Visible = false
        end
        
        function Tab:AddLeftGroupbox(Name)
            return Tab:CreateGroupbox(Name, LeftScroll)
        end
        
        function Tab:AddRightGroupbox(Name)
            -- Alternate between top and bottom right containers
            local container = #Tab.Groupboxes % 2 == 0 and RightTopContainer or RightBottomContainer
            return Tab:CreateGroupbox(Name, container)
        end
        
        function Tab:CreateGroupbox(Name, Parent)
            local Groupbox = {
                Name = Name,
                Container = nil,
            }
            
            local GroupboxFrame = Library:Create('Frame', {
                Name = 'Groupbox_' .. Name,
                Parent = Parent,
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
            
            -- Top bar for groupbox
            local GroupboxTop = Library:Create('Frame', {
                Name = 'top',
                Parent = GroupboxFrame,
                BackgroundColor3 = Library.BackgroundColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 301, 0, 35),
            })
            
            Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 4),
                Parent = GroupboxTop,
            })
            
            Library:Create('UIStroke', {
                Color = Library.OutlineColor,
                Parent = GroupboxTop,
            })
            
            -- Bottom extension
            Library:Create('Frame', {
                Parent = GroupboxTop,
                BackgroundColor3 = Library.BackgroundColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 301, 0, 18),
                Position = UDim2.new(0, 0, 0.4869, 0),
            })
            
            local GroupboxLabel = Library:Create('TextLabel', {
                Parent = GroupboxTop,
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
            
            -- Container for elements
            local Container = Library:Create('ScrollingFrame', {
                Parent = GroupboxFrame,
                Active = true,
                BackgroundColor3 = Library.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.06876, 0),
                Size = UDim2.new(1, 0, 0.93, 0),
                ScrollBarImageTransparency = 1,
                CanvasSize = UDim2.new(0, 0, 0, 0),
            })
            
            Library:Create('UIListLayout', {
                Parent = Container,
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            Groupbox.Container = Container
            Groupbox.Frame = GroupboxFrame
            
            function Groupbox:Resize()
                local contentSize = 0
                for _, child in pairs(Container:GetChildren()) do
                    if not child:IsA('UIListLayout') and child.Visible then
                        contentSize = contentSize + child.Size.Y.Offset + 5
                    end
                end
                
                Container.CanvasSize = UDim2.new(0, 0, 0, contentSize)
                GroupboxFrame.Size = UDim2.new(0, 301, 0, math.min(contentSize + 50, 509))
            end
            
            function Groupbox:AddToggle(Idx, Info)
                local Toggle = {
                    Value = Info.Default or false,
                    Type = 'Toggle',
                    Callback = Info.Callback or function() end,
                }
                
                local ToggleFrame = Library:Create('TextLabel', {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 109, 0, 30),
                    Font = Library.Font,
                    Text = Info.Text or 'Toggle',
                    TextColor3 = Library.InactiveColor,
                    TextSize = 20,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local ToggleButton = Library:Create('ImageButton', {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.MainColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 15, 0, 15),
                    Position = UDim2.new(0.12844, -8, 0.34, 0),
                    AutoButtonColor = false,
                    ImageTransparency = 1,
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
                    
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
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
                    Size = UDim2.new(0, 280, 0, 25),
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
                    Size = UDim2.new(0, 280, 0, 30),
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
    
    -- Toggle menu visibility
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
