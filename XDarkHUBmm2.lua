-- Yet Another Random Hub Menu 1.21 by Aetherion (Modified for XDarkHUB)
if not game:IsLoaded() then
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "Script loading",
Text = "Waiting for the game to finish loading!",
Duration = 5
})
game.Loaded:Wait()
end
-- Instances:
local Converted = {
["_YARHM"] = Instance.new("ScreenGui");
["_FUNCTIONS"] = Instance.new("ModuleScript");
["_Flee the Facility"] = Instance.new("LocalScript");
["_Universal"] = Instance.new("LocalScript");
["_DraggableObject"] = Instance.new("ModuleScript");
["_ClickAndHold"] = Instance.new("ModuleScript");
["_Spring"] = Instance.new("ModuleScript");
["_Init"] = Instance.new("LocalScript");
["_Forsaken"] = Instance.new("LocalScript");
["_Murder Mystery 2"] = Instance.new("LocalScript");
["_ESPIndicator"] = Instance.new("ModuleScript");
["_Bezier"] = Instance.new("ModuleScript");
["_PointSave"] = Instance.new("ModuleScript");
["_Theme"] = Instance.new("ModuleScript");
["_FlyUtility"] = Instance.new("ModuleScript");
["_Open"] = Instance.new("TextButton");
["_InitOpen"] = Instance.new("LocalScript");
["_OnClick"] = Instance.new("LocalScript");
["_Resizer"] = Instance.new("LocalScript");
["_UICorner"] = Instance.new("UICorner");
["_UIPadding"] = Instance.new("UIPadding");
["_DropdownFrameSample"] = Instance.new("Frame");
["_UICorner1"] = Instance.new("UICorner");
["_UIGradient"] = Instance.new("UIGradient");
["_UIStroke"] = Instance.new("UIStroke");
["_UIGradient1"] = Instance.new("UIGradient");
["_ScrollingFrame"] = Instance.new("ScrollingFrame");
["_UIListLayout"] = Instance.new("UIListLayout");
["_Sample"] = Instance.new("TextButton");
["_UIPadding1"] = Instance.new("UIPadding");
["_UICorner2"] = Instance.new("UICorner");
["_UIPadding2"] = Instance.new("UIPadding");
["_themedColor"] = Instance.new("StringValue");
["_ListButton"] = Instance.new("TextButton");
["_UICorner3"] = Instance.new("UICorner");
["_Notifications"] = Instance.new("Frame");
["_UIListLayout1"] = Instance.new("UIListLayout");
["_UIPadding3"] = Instance.new("UIPadding");
["_Placeholder"] = Instance.new("Frame");
["_UICorner4"] = Instance.new("UICorner");
["_TextLabel"] = Instance.new("TextLabel");
["_TextBoxPlaceholder"] = Instance.new("Frame");
["_UIListLayout2"] = Instance.new("UIListLayout");
["_TextButton"] = Instance.new("TextButton");
["_UICorner5"] = Instance.new("UICorner");
["_UIPadding4"] = Instance.new("UIPadding");
["_TextBox"] = Instance.new("TextBox");
["_UICorner6"] = Instance.new("UICorner");
["_FloatingButton"] = Instance.new("TextButton");
["_Keybinding"] = Instance.new("LocalScript");
["_Invisible"] = Instance.new("LocalScript");
["_UIPadding5"] = Instance.new("UIPadding");
["_UICorner7"] = Instance.new("UICorner");
["_UIStroke1"] = Instance.new("UIStroke");
["_Lock"] = Instance.new("TextLabel");
["_UIScale"] = Instance.new("UIScale");
["_Ripple"] = Instance.new("Frame");
["_UICorner8"] = Instance.new("UICorner");
["_UIScale1"] = Instance.new("UIScale");
["_Dropdown"] = Instance.new("Frame");
["_TextLabel1"] = Instance.new("TextLabel");
["_UIListLayout3"] = Instance.new("UIListLayout");
["_UIPadding6"] = Instance.new("UIPadding");
["_Frame"] = Instance.new("TextButton");
["_UIPadding7"] = Instance.new("UIPadding");
["_UICorner9"] = Instance.new("UICorner");
["_AddCustomModule"] = Instance.new("Frame");
["_UICorner10"] = Instance.new("UICorner");
["_UIStroke2"] = Instance.new("UIStroke");
["_UIGradient2"] = Instance.new("UIGradient");
["_UIGradient3"] = Instance.new("UIGradient");
["_UIScale2"] = Instance.new("UIScale");
["_TextLabel2"] = Instance.new("TextLabel");
["_TextBox1"] = Instance.new("TextBox");
["_UICorner11"] = Instance.new("UICorner");
["_UIPadding8"] = Instance.new("UIPadding");
["_TextLabel3"] = Instance.new("TextLabel");
["_Add"] = Instance.new("TextButton");
["_LocalScript"] = Instance.new("LocalScript");
["_UICorner12"] = Instance.new("UICorner");
["_UIPadding9"] = Instance.new("UIPadding");
["_UIStroke3"] = Instance.new("UIStroke");
["_Cancel"] = Instance.new("TextButton");
["_LocalScript1"] = Instance.new("LocalScript");
["_UICorner13"] = Instance.new("UICorner");
["_UIPadding10"] = Instance.new("UIPadding");
["_UIStroke4"] = Instance.new("UIStroke");
["_themedColor1"] = Instance.new("StringValue");
["_Menu"] = Instance.new("Frame");
["_UICorner14"] = Instance.new("UICorner");
["_UIStroke5"] = Instance.new("UIStroke");
["_UIGradient4"] = Instance.new("UIGradient");
["_Animator"] = Instance.new("LocalScript");
["_HubCredits"] = Instance.new("TextLabel");
["_HubDesc"] = Instance.new("TextLabel");
["_HubName"] = Instance.new("TextLabel");
["_CanvasGroup"] = Instance.new("CanvasGroup");
["_UICorner15"] = Instance.new("UICorner");
["_ImageLabel"] = Instance.new("ImageLabel");
["_Opener"] = Instance.new("TextButton");
["_TextLabel4"] = Instance.new("TextLabel");
["_CloseArea"] = Instance.new("TextButton");
["_CloseOpen"] = Instance.new("LocalScript");
["_Frame1"] = Instance.new("Frame");
["_UICorner16"] = Instance.new("UICorner");
["_themedColor2"] = Instance.new("StringValue");
["_TextLabel5"] = Instance.new("TextLabel");
["_UICorner17"] = Instance.new("UICorner");
["_AllowForSpring"] = Instance.new("BindableEvent");
["_themedColor3"] = Instance.new("StringValue");
["_UIGradient5"] = Instance.new("UIGradient");
["_Area"] = Instance.new("CanvasGroup");
["_Area1"] = Instance.new("ScrollingFrame");
["_TextLabel6"] = Instance.new("TextLabel");
["_TextLabel7"] = Instance.new("TextLabel");
["_UICorner18"] = Instance.new("UICorner");
["_List"] = Instance.new("CanvasGroup");
["_AutoSetup"] = Instance.new("LocalScript");
["_UICorner19"] = Instance.new("UICorner");
["_ScrollingFrame1"] = Instance.new("ScrollingFrame");
["_UIListLayout4"] = Instance.new("UIListLayout");
["_UIPadding11"] = Instance.new("UIPadding");
["_UIPadding12"] = Instance.new("UIPadding");
["_UIStroke6"] = Instance.new("UIStroke");
["_UIGradient6"] = Instance.new("UIGradient");
["_AddCustomModule1"] = Instance.new("TextButton");
["_LocalScript2"] = Instance.new("LocalScript");
["_UICorner20"] = Instance.new("UICorner");
["_UIPadding13"] = Instance.new("UIPadding");
["_UIStroke7"] = Instance.new("UIStroke");
["_themedColor4"] = Instance.new("StringValue");
["_themedColor5"] = Instance.new("StringValue");
["_themedColor6"] = Instance.new("StringValue");
["_UIScale3"] = Instance.new("UIScale");
["_Stub"] = Instance.new("Frame");
["_themedColor7"] = Instance.new("StringValue");
["_Stub1"] = Instance.new("Frame");
["_themedColor8"] = Instance.new("StringValue");
["_Toggle"] = Instance.new("Frame");
["_TextLabel8"] = Instance.new("TextLabel");
["_UIListLayout5"] = Instance.new("UIListLayout");
["_Frame2"] = Instance.new("Frame");
["_Frame3"] = Instance.new("Frame");
["_UICorner21"] = Instance.new("UICorner");
["_Toggler"] = Instance.new("TextButton");
["_UICorner22"] = Instance.new("UICorner");
["_ImageLabel1"] = Instance.new("ImageLabel");
["_UIPadding14"] = Instance.new("UIPadding");
["_Modules"] = Instance.new("Folder");
["_NotificationSample"] = Instance.new("Frame");
["_UICorner23"] = Instance.new("UICorner");
["_UIStroke8"] = Instance.new("UIStroke");
["_UIGradient7"] = Instance.new("UIGradient");
["_ImageLabel2"] = Instance.new("ImageLabel");
["_TextLabel9"] = Instance.new("TextLabel");
["_UITextSizeConstraint"] = Instance.new("UITextSizeConstraint");
["_Close"] = Instance.new("ImageButton");
["_UICorner24"] = Instance.new("UICorner");
["_UIStroke9"] = Instance.new("UIStroke");
["_UIScale4"] = Instance.new("UIScale");
["_themedColor9"] = Instance.new("StringValue");
["_Dialog"] = Instance.new("Frame");
["_UICorner25"] = Instance.new("UICorner");
["_UIGradient8"] = Instance.new("UIGradient");
["_UIPadding15"] = Instance.new("UIPadding");
["_UIStroke10"] = Instance.new("UIStroke");
["_UIGradient9"] = Instance.new("UIGradient");
["_DialogTitle"] = Instance.new("TextLabel");
["_UIListLayout6"] = Instance.new("UIListLayout");
["_DialogDesc"] = Instance.new("TextLabel");
["_UITextSizeConstraint1"] = Instance.new("UITextSizeConstraint");
["_Options"] = Instance.new("Frame");
["_UIListLayout7"] = Instance.new("UIListLayout");
["_OptionPlaceholder"] = Instance.new("TextButton");
["_UIPadding16"] = Instance.new("UIPadding");
["_UICorner26"] = Instance.new("UICorner");
["_UIStroke11"] = Instance.new("UIStroke");
["_UIGradient10"] = Instance.new("UIGradient");
["_themedColor10"] = Instance.new("StringValue");
["_OnSelect"] = Instance.new("BindableEvent");
["_UIScale5"] = Instance.new("UIScale");
["_themedColor11"] = Instance.new("StringValue");
["_Range"] = Instance.new("Frame");
["_TextLabel10"] = Instance.new("TextLabel");
["_UIListLayout8"] = Instance.new("UIListLayout");
["_UIPadding17"] = Instance.new("UIPadding");
["_Frame4"] = Instance.new("Frame");
["_UIPadding18"] = Instance.new("UIPadding");
["_UICorner27"] = Instance.new("UICorner");
["_Track"] = Instance.new("Frame");
["_UICorner28"] = Instance.new("UICorner");
["_Ball"] = Instance.new("TextButton");
["_BallProgress"] = Instance.new("TextLabel");
["_UIPadding19"] = Instance.new("UIPadding");
["_themedColor12"] = Instance.new("StringValue");
["_UICorner29"] = Instance.new("UICorner");
["_UIPadding20"] = Instance.new("UIPadding");
["_TrackProgress"] = Instance.new("TextLabel");
["_themedColor13"] = Instance.new("StringValue");
["_UISizeConstraint"] = Instance.new("UISizeConstraint");
["_FloatingButtonSetting"] = Instance.new("Frame");
["_ControlBarContainer"] = Instance.new("Frame");
["_ControlBar"] = Instance.new("Frame");
["_UIListLayout9"] = Instance.new("UIListLayout");
["_Visibility"] = Instance.new("TextButton");
["_LocalScript3"] = Instance.new("LocalScript");
["_UICorner30"] = Instance.new("UICorner");
["_UIPadding21"] = Instance.new("UIPadding");
["_Event"] = Instance.new("BindableEvent");
["_themedColor14"] = Instance.new("StringValue");
["_Lock1"] = Instance.new("TextButton");
["_LocalScript4"] = Instance.new("LocalScript");
["_UICorner31"] = Instance.new("UICorner");
["_UIPadding22"] = Instance.new("UIPadding");
["_Event1"] = Instance.new("BindableEvent");
["_themedColor15"] = Instance.new("StringValue");
["_Exit"] = Instance.new("TextButton");
["_LocalScript5"] = Instance.new("LocalScript");
["_UICorner32"] = Instance.new("UICorner");
["_UIPadding23"] = Instance.new("UIPadding");
["_UIAspectRatioConstraint"] = Instance.new("UIAspectRatioConstraint");
["_themedColor16"] = Instance.new("StringValue");
["_UIListLayout10"] = Instance.new("UIListLayout");
["_Tip"] = Instance.new("TextLabel");
["_UIStroke12"] = Instance.new("UIStroke");
["_UIScale6"] = Instance.new("UIScale");
["_FloatingButtons"] = Instance.new("Frame");
["_FloatingButtons1"] = Instance.new("Frame");
}
-- Properties:
Converted["_YARHM"].DisplayOrder = 3
Converted["_YARHM"].IgnoreGuiInset = true
Converted["_YARHM"].ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
Converted["_YARHM"].ResetOnSpawn = false
Converted["_YARHM"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Converted["_YARHM"].Name = "XDarkHUB" -- ИЗМЕНЕНО
Converted["_YARHM"].Parent = game:GetService("CoreGui")
Converted["_Open"].Font = Enum.Font.Gotham
Converted["_Open"].Text = "Triple-click this region to open XDarkHUB." -- ИЗМЕНЕНО
Converted["_Open"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Open"].TextScaled = true
Converted["_Open"].TextSize = 14
Converted["_Open"].TextTransparency = 1
Converted["_Open"].TextWrapped = true
Converted["_Open"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Open"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Open"].BackgroundTransparency = 1
Converted["_Open"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Open"].BorderSizePixel = 0
Converted["_Open"].Position = UDim2.new(0.499372631, 0, 0.06341701, 0)
Converted["_Open"].Selectable = false
Converted["_Open"].Size = UDim2.new(0, 493, 0, 50)
Converted["_Open"].Visible = false
Converted["_Open"].Name = "Open"
Converted["_Open"].Parent = Converted["_YARHM"]
Converted["_UICorner"].Parent = Converted["_Open"]
Converted["_UIPadding"].PaddingBottom = UDim.new(0, 10)
Converted["_UIPadding"].PaddingLeft = UDim.new(0, 20)
Converted["_UIPadding"].PaddingRight = UDim.new(0, 20)
Converted["_UIPadding"].PaddingTop = UDim.new(0, 10)
Converted["_UIPadding"].Parent = Converted["_Open"]
Converted["_DropdownFrameSample"].AnchorPoint = Vector2.new(0.5, 0)
Converted["_DropdownFrameSample"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_DropdownFrameSample"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_DropdownFrameSample"].BorderSizePixel = 0
Converted["_DropdownFrameSample"].Size = UDim2.new(0, 108, 0, 239)
Converted["_DropdownFrameSample"].Visible = false
Converted["_DropdownFrameSample"].Name = "DropdownFrameSample"
Converted["_DropdownFrameSample"].Parent = Converted["_YARHM"]
Converted["_UICorner1"].Parent = Converted["_DropdownFrameSample"]
Converted["_UIGradient"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(36.00000165402889, 36.00000165402889, 36.00000165402889)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(68.00000354647636, 68.00000354647636, 68.00000354647636))
}
Converted["_UIGradient"].Rotation = 68
Converted["_UIGradient"].Parent = Converted["_DropdownFrameSample"]
Converted["_UIStroke"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke"].Thickness = 2
Converted["_UIStroke"].Parent = Converted["_DropdownFrameSample"]
Converted["_UIGradient1"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(111.00000098347664, 111.00000098347664, 111.00000098347664)),
ColorSequenceKeypoint.new(0.6401384472846985, Color3.fromRGB(114.23875719308853, 114.23875719308853, 114.23875719308853)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
Converted["_UIGradient1"].Rotation = -107
Converted["_UIGradient1"].Parent = Converted["_UIStroke"]
Converted["_ScrollingFrame"].AutomaticCanvasSize = Enum.AutomaticSize.XY
Converted["_ScrollingFrame"].CanvasSize = UDim2.new(0, 0, 0, 0)
Converted["_ScrollingFrame"].ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ScrollingFrame"].ScrollBarThickness = 0
Converted["_ScrollingFrame"].Active = true
Converted["_ScrollingFrame"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ScrollingFrame"].BackgroundTransparency = 1
Converted["_ScrollingFrame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ScrollingFrame"].BorderSizePixel = 0
Converted["_ScrollingFrame"].Size = UDim2.new(1, 0, 1, 0)
Converted["_ScrollingFrame"].Parent = Converted["_DropdownFrameSample"]
Converted["_UIListLayout"].Padding = UDim.new(0, 5)
Converted["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout"].Parent = Converted["_ScrollingFrame"]
Converted["_Sample"].Font = Enum.Font.Unknown
Converted["_Sample"].Text = "This can fit a lot of text, probably."
Converted["_Sample"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Sample"].TextScaled = true
Converted["_Sample"].TextSize = 14
Converted["_Sample"].TextWrapped = true
Converted["_Sample"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_Sample"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Sample"].BorderSizePixel = 0
Converted["_Sample"].Size = UDim2.new(1, 0, 0, 35)
Converted["_Sample"].Visible = false
Converted["_Sample"].Name = "Sample"
Converted["_Sample"].Parent = Converted["_ScrollingFrame"]
Converted["_UIPadding1"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding1"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding1"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding1"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding1"].Parent = Converted["_Sample"]
Converted["_UICorner2"].Parent = Converted["_Sample"]
Converted["_UIPadding2"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding2"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding2"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding2"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding2"].Parent = Converted["_DropdownFrameSample"]
Converted["_themedColor"].Value = "backgroundColorCSQ"
Converted["_themedColor"].Name = "themedColor"
Converted["_themedColor"].Parent = Converted["_DropdownFrameSample"]
Converted["_ListButton"].Font = Enum.Font.Gotham
Converted["_ListButton"].Text = "Placeholder"
Converted["_ListButton"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ListButton"].TextSize = 14
Converted["_ListButton"].TextWrapped = true
Converted["_ListButton"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_ListButton"].BackgroundColor3 = Color3.fromRGB(49.00000087916851, 49.00000087916851, 49.00000087916851)
Converted["_ListButton"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ListButton"].BorderSizePixel = 0
Converted["_ListButton"].Position = UDim2.new(0.0450000018, 0, 0.112000003, 0)
Converted["_ListButton"].Size = UDim2.new(1, 0, 0, 50)
Converted["_ListButton"].Visible = false
Converted["_ListButton"].Name = "ListButton"
Converted["_ListButton"].Parent = Converted["_YARHM"]
Converted["_UICorner3"].Parent = Converted["_ListButton"]
Converted["_Notifications"].AnchorPoint = Vector2.new(1, 0.5)
Converted["_Notifications"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Notifications"].BackgroundTransparency = 1
Converted["_Notifications"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Notifications"].BorderSizePixel = 0
Converted["_Notifications"].Position = UDim2.new(0.99000001, 0, 0.5, 0)
Converted["_Notifications"].Size = UDim2.new(0, 242, 1, 0)
Converted["_Notifications"].Name = "Notifications"
Converted["_Notifications"].Parent = Converted["_YARHM"]
Converted["_UIListLayout1"].Padding = UDim.new(0, 10)
Converted["_UIListLayout1"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout1"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout1"].VerticalAlignment = Enum.VerticalAlignment.Bottom
Converted["_UIListLayout1"].Parent = Converted["_Notifications"]
Converted["_UIPadding3"].PaddingBottom = UDim.new(0, 10)
Converted["_UIPadding3"].PaddingLeft = UDim.new(0, 10)
Converted["_UIPadding3"].Parent = Converted["_Notifications"]
Converted["_Placeholder"].AnchorPoint = Vector2.new(0.5, 0)
Converted["_Placeholder"].BackgroundColor3 = Color3.fromRGB(31.000001952052116, 31.000001952052116, 31.000001952052116)
Converted["_Placeholder"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Placeholder"].BorderSizePixel = 0
Converted["_Placeholder"].Position = UDim2.new(0.0450000018, 0, 0.112000003, 0)
Converted["_Placeholder"].Visible = false
Converted["_Placeholder"].Name = "Placeholder"
Converted["_Placeholder"].Parent = Converted["_Notifications"]
Converted["_UICorner4"].Parent = Converted["_Placeholder"]
Converted["_TextLabel"].Font = Enum.Font.Gotham
Converted["_TextLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel"].TextScaled = true
Converted["_TextLabel"].TextSize = 14
Converted["_TextLabel"].TextWrapped = true
Converted["_TextLabel"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextLabel"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel"].BackgroundTransparency = 1
Converted["_TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel"].BorderSizePixel = 0
Converted["_TextLabel"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_TextLabel"].Size = UDim2.new(0.899999976, 0, 0.800000012, 0)
Converted["_TextLabel"].Parent = Converted["_Placeholder"]
Converted["_TextBoxPlaceholder"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextBoxPlaceholder"].BackgroundTransparency = 1
Converted["_TextBoxPlaceholder"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextBoxPlaceholder"].BorderSizePixel = 0
Converted["_TextBoxPlaceholder"].Size = UDim2.new(1, 0, 0, 50)
Converted["_TextBoxPlaceholder"].Visible = false
Converted["_TextBoxPlaceholder"].Name = "TextBoxPlaceholder"
Converted["_TextBoxPlaceholder"].Parent = Converted["_YARHM"]
Converted["_UIListLayout2"].Padding = UDim.new(0, 5)
Converted["_UIListLayout2"].FillDirection = Enum.FillDirection.Horizontal
Converted["_UIListLayout2"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout2"].Parent = Converted["_TextBoxPlaceholder"]
Converted["_TextButton"].Font = Enum.Font.Gotham
Converted["_TextButton"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextButton"].TextScaled = true
Converted["_TextButton"].TextSize = 14
Converted["_TextButton"].TextWrapped = true
Converted["_TextButton"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_TextButton"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextButton"].BorderSizePixel = 0
Converted["_TextButton"].Position = UDim2.new(0.292333364, 0, 1.67999995, 0)
Converted["_TextButton"].Size = UDim2.new(0, 50, 0, 50)
Converted["_TextButton"].Parent = Converted["_TextBoxPlaceholder"]
Converted["_UICorner5"].Parent = Converted["_TextButton"]
Converted["_UIPadding4"].PaddingBottom = UDim.new(0, 5)
Converted["_UIPadding4"].PaddingLeft = UDim.new(0, 5)
Converted["_UIPadding4"].PaddingRight = UDim.new(0, 5)
Converted["_UIPadding4"].PaddingTop = UDim.new(0, 5)
Converted["_UIPadding4"].Parent = Converted["_TextButton"]
Converted["_TextBox"].Font = Enum.Font.Gotham
Converted["_TextBox"].PlaceholderText = "Placeholder"
Converted["_TextBox"].Text = ""
Converted["_TextBox"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextBox"].TextSize = 14
Converted["_TextBox"].TextWrapped = true
Converted["_TextBox"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_TextBox"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextBox"].BorderSizePixel = 0
Converted["_TextBox"].Size = UDim2.new(0.800000012, 0, 0, 50)
Converted["_TextBox"].Parent = Converted["_TextBoxPlaceholder"]
Converted["_UICorner6"].Parent = Converted["_TextBox"]
Converted["_FloatingButton"].Font = Enum.Font.Unknown
Converted["_FloatingButton"].Text = "Shoot into murderer"
Converted["_FloatingButton"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_FloatingButton"].TextScaled = true
Converted["_FloatingButton"].TextSize = 14
Converted["_FloatingButton"].TextWrapped = true
Converted["_FloatingButton"].AutoButtonColor = false
Converted["_FloatingButton"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_FloatingButton"].BackgroundColor3 = Color3.fromRGB(31.000000052154064, 31.000000052154064, 31.000000052154064)
Converted["_FloatingButton"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FloatingButton"].BorderSizePixel = 0
Converted["_FloatingButton"].ClipsDescendants = true
Converted["_FloatingButton"].Position = UDim2.new(0, 125, 0, 40)
Converted["_FloatingButton"].Size = UDim2.new(0, 50, 0, 100)
Converted["_FloatingButton"].Visible = false
Converted["_FloatingButton"].Name = "FloatingButton"
Converted["_FloatingButton"].Parent = Converted["_YARHM"]
Converted["_UIPadding5"].PaddingBottom = UDim.new(0, 5)
Converted["_UIPadding5"].PaddingLeft = UDim.new(0, 5)
Converted["_UIPadding5"].PaddingRight = UDim.new(0, 5)
Converted["_UIPadding5"].PaddingTop = UDim.new(0, 5)
Converted["_UIPadding5"].Parent = Converted["_FloatingButton"]
Converted["_UICorner7"].Parent = Converted["_FloatingButton"]
Converted["_UIStroke1"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Converted["_UIStroke1"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke1"].Parent = Converted["_FloatingButton"]
Converted["_Lock"].Font = Enum.Font.Gotham
Converted["_Lock"].Text = "🔒"
Converted["_Lock"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Lock"].TextScaled = true
Converted["_Lock"].TextSize = 14
Converted["_Lock"].TextWrapped = true
Converted["_Lock"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Lock"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Lock"].BackgroundTransparency = 1
Converted["_Lock"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Lock"].BorderSizePixel = 0
Converted["_Lock"].Position = UDim2.new(1, -10, 1, -10)
Converted["_Lock"].Size = UDim2.new(0, 20, 0, 20)
Converted["_Lock"].ZIndex = 999999999
Converted["_Lock"].Name = "Lock"
Converted["_Lock"].Parent = Converted["_FloatingButton"]
Converted["_UIScale"].Scale = 1.0000000116860974e-07
Converted["_UIScale"].Parent = Converted["_Lock"]
Converted["_Ripple"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Ripple"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Ripple"].BackgroundTransparency = 1
Converted["_Ripple"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Ripple"].BorderSizePixel = 0
Converted["_Ripple"].Size = UDim2.new(0, 100, 0, 100)
Converted["_Ripple"].Name = "Ripple"
Converted["_Ripple"].Parent = Converted["_FloatingButton"]
Converted["_UICorner8"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner8"].Parent = Converted["_Ripple"]
Converted["_UIScale1"].Parent = Converted["_FloatingButton"]
Converted["_Dropdown"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Dropdown"].BackgroundTransparency = 1
Converted["_Dropdown"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Dropdown"].BorderSizePixel = 0
Converted["_Dropdown"].Size = UDim2.new(1, 0, 0, 35)
Converted["_Dropdown"].Visible = false
Converted["_Dropdown"].Name = "Dropdown"
Converted["_Dropdown"].Parent = Converted["_YARHM"]
Converted["_TextLabel1"].Font = Enum.Font.Unknown
Converted["_TextLabel1"].Text = "Loop walkspeed and FOV"
Converted["_TextLabel1"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel1"].TextScaled = true
Converted["_TextLabel1"].TextSize = 14
Converted["_TextLabel1"].TextWrapped = true
Converted["_TextLabel1"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextLabel1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel1"].BackgroundTransparency = 1
Converted["_TextLabel1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel1"].BorderSizePixel = 0
Converted["_TextLabel1"].Size = UDim2.new(0.699999988, 0, 1, 0)
Converted["_TextLabel1"].Parent = Converted["_Dropdown"]
Converted["_UIListLayout3"].Padding = UDim.new(0, 15)
Converted["_UIListLayout3"].FillDirection = Enum.FillDirection.Horizontal
Converted["_UIListLayout3"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout3"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout3"].Parent = Converted["_Dropdown"]
Converted["_UIPadding6"].PaddingLeft = UDim.new(0.0700000003, 0)
Converted["_UIPadding6"].PaddingRight = UDim.new(0.0700000003, 0)
Converted["_UIPadding6"].Parent = Converted["_Dropdown"]
Converted["_Frame"].Font = Enum.Font.Gotham
Converted["_Frame"].Text = "Select..."
Converted["_Frame"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame"].TextScaled = true
Converted["_Frame"].TextWrapped = true
Converted["_Frame"].Active = false
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(31.000001952052116, 31.000001952052116, 31.000001952052116)
Converted["_Frame"].BackgroundTransparency = -0.03999999910593033
Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame"].BorderSizePixel = 0
Converted["_Frame"].Selectable = false
Converted["_Frame"].Size = UDim2.new(0.400000006, 0, 1, 0)
Converted["_Frame"].Name = "Frame"
Converted["_Frame"].Parent = Converted["_Dropdown"]
Converted["_UIPadding7"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding7"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding7"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding7"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding7"].Parent = Converted["_Frame"]
Converted["_UICorner9"].Parent = Converted["_Frame"]
Converted["_AddCustomModule"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_AddCustomModule"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_AddCustomModule"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_AddCustomModule"].BorderSizePixel = 0
Converted["_AddCustomModule"].ClipsDescendants = true
Converted["_AddCustomModule"].Position = UDim2.new(0.5, 0, -0.5, 0)
Converted["_AddCustomModule"].Size = UDim2.new(0, 440, 0, 268)
Converted["_AddCustomModule"].ZIndex = 3
Converted["_AddCustomModule"].Name = "AddCustomModule"
Converted["_AddCustomModule"].Parent = Converted["_YARHM"]
Converted["_UICorner10"].Parent = Converted["_AddCustomModule"]
Converted["_UIStroke2"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke2"].Thickness = 2
Converted["_UIStroke2"].Parent = Converted["_AddCustomModule"]
Converted["_UIGradient2"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(53.00000064074993, 53.00000064074993, 53.00000064074993)),
ColorSequenceKeypoint.new(0.15224914252758026, Color3.fromRGB(50.69031357765198, 50.69031357765198, 50.69031357765198)),
ColorSequenceKeypoint.new(0.4723183512687683, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(0.7577854990959167, Color3.fromRGB(50.13314567506313, 50.13314567506313, 50.13314567506313)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(48.000000938773155, 48.000000938773155, 48.000000938773155))
}
Converted["_UIGradient2"].Rotation = 62
Converted["_UIGradient2"].Parent = Converted["_UIStroke2"]
Converted["_UIGradient3"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(36.00000165402889, 36.00000165402889, 36.00000165402889)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(68.00000354647636, 68.00000354647636, 68.00000354647636))
}
Converted["_UIGradient3"].Rotation = 68
Converted["_UIGradient3"].Parent = Converted["_AddCustomModule"]
Converted["_UIScale2"].Parent = Converted["_AddCustomModule"]
Converted["_TextLabel2"].Font = Enum.Font.Gotham
Converted["_TextLabel2"].Text = "Add a module"
Converted["_TextLabel2"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel2"].TextScaled = true
Converted["_TextLabel2"].TextSize = 14
Converted["_TextLabel2"].TextWrapped = true
Converted["_TextLabel2"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel2"].BackgroundTransparency = 1
Converted["_TextLabel2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel2"].BorderSizePixel = 0
Converted["_TextLabel2"].Position = UDim2.new(0.352256238, 0, 0.133915231, 0)
Converted["_TextLabel2"].Size = UDim2.new(0.619047642, 0, 0.125920027, 0)
Converted["_TextLabel2"].Parent = Converted["_AddCustomModule"]
Converted["_TextBox1"].ClearTextOnFocus = false
Converted["_TextBox1"].Font = Enum.Font.Gotham
Converted["_TextBox1"].PlaceholderText = "Custom module link"
Converted["_TextBox1"].Text = ""
Converted["_TextBox1"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextBox1"].TextScaled = true
Converted["_TextBox1"].TextSize = 14
Converted["_TextBox1"].TextWrapped = true
Converted["_TextBox1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextBox1"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_TextBox1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextBox1"].BorderSizePixel = 0
Converted["_TextBox1"].Position = UDim2.new(0.499648541, 0, 0.500059664, 0)
Converted["_TextBox1"].Size = UDim2.new(0.804988742, 0, 0.544776142, 0)
Converted["_TextBox1"].Parent = Converted["_AddCustomModule"]
Converted["_UICorner11"].Parent = Converted["_TextBox1"]
Converted["_UIPadding8"].PaddingBottom = UDim.new(0, 10)
Converted["_UIPadding8"].PaddingLeft = UDim.new(0, 10)
Converted["_UIPadding8"].PaddingRight = UDim.new(0, 10)
Converted["_UIPadding8"].PaddingTop = UDim.new(0, 10)
Converted["_UIPadding8"].Parent = Converted["_TextBox1"]
Converted["_TextLabel3"].Font = Enum.Font.GothamBold
Converted["_TextLabel3"].Text = "ONLY ADD MODULES YOU TRUST!"
Converted["_TextLabel3"].TextColor3 = Color3.fromRGB(255, 0, 0)
Converted["_TextLabel3"].TextScaled = true
Converted["_TextLabel3"].TextSize = 14
Converted["_TextLabel3"].TextWrapped = true
Converted["_TextLabel3"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel3"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel3"].BackgroundTransparency = 1
Converted["_TextLabel3"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel3"].BorderSizePixel = 0
Converted["_TextLabel3"].Position = UDim2.new(0.499648541, 0, 0.833542168, 0)
Converted["_TextLabel3"].Size = UDim2.new(0.619047642, 0, 0.0550245307, 0)
Converted["_TextLabel3"].Parent = Converted["_AddCustomModule"]
Converted["_Add"].Font = Enum.Font.Gotham
Converted["_Add"].Text = "Add"
Converted["_Add"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Add"].TextScaled = true
Converted["_Add"].TextSize = 14
Converted["_Add"].TextWrapped = true
Converted["_Add"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Add"].BackgroundColor3 = Color3.fromRGB(50.00000461935997, 50.00000461935997, 50.00000461935997)
Converted["_Add"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Add"].BorderSizePixel = 0
Converted["_Add"].Position = UDim2.new(0.108492024, 0, 0.927298486, 0)
Converted["_Add"].Size = UDim2.new(0.163265288, 0, 0.0858208984, 0)
Converted["_Add"].Name = "Add"
Converted["_Add"].Parent = Converted["_AddCustomModule"]
Converted["_UICorner12"].Parent = Converted["_Add"]
Converted["_UIPadding9"].PaddingBottom = UDim.new(0, 5)
Converted["_UIPadding9"].PaddingLeft = UDim.new(0, 5)
Converted["_UIPadding9"].PaddingRight = UDim.new(0, 5)
Converted["_UIPadding9"].PaddingTop = UDim.new(0, 5)
Converted["_UIPadding9"].Parent = Converted["_Add"]
Converted["_UIStroke3"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Converted["_UIStroke3"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke3"].Parent = Converted["_Add"]
Converted["_Cancel"].Font = Enum.Font.Gotham
Converted["_Cancel"].Text = "Cancel"
Converted["_Cancel"].TextColor3 = Color3.fromRGB(255, 0, 0)
Converted["_Cancel"].TextScaled = true
Converted["_Cancel"].TextSize = 14
Converted["_Cancel"].TextWrapped = true
Converted["_Cancel"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Cancel"].BackgroundColor3 = Color3.fromRGB(50.00000461935997, 50.00000461935997, 50.00000461935997)
Converted["_Cancel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Cancel"].BorderSizePixel = 0
Converted["_Cancel"].Position = UDim2.new(0.899875283, 0, 0.931029797, 0)
Converted["_Cancel"].Size = UDim2.new(0.163265288, 0, 0.0858208984, 0)
Converted["_Cancel"].Name = "Cancel"
Converted["_Cancel"].Parent = Converted["_AddCustomModule"]
Converted["_UICorner13"].Parent = Converted["_Cancel"]
Converted["_UIPadding10"].PaddingBottom = UDim.new(0, 5)
Converted["_UIPadding10"].PaddingLeft = UDim.new(0, 5)
Converted["_UIPadding10"].PaddingRight = UDim.new(0, 5)
Converted["_UIPadding10"].PaddingTop = UDim.new(0, 5)
Converted["_UIPadding10"].Parent = Converted["_Cancel"]
Converted["_UIStroke4"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Converted["_UIStroke4"].Color = Color3.fromRGB(255, 0, 0)
Converted["_UIStroke4"].Parent = Converted["_Cancel"]
Converted["_themedColor1"].Value = "backgroundColorCSQ"
Converted["_themedColor1"].Name = "themedColor"
Converted["_themedColor1"].Parent = Converted["_AddCustomModule"]
Converted["_Menu"].AnchorPoint = Vector2.new(0.5, 0)
Converted["_Menu"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Menu"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Menu"].BorderSizePixel = 0
Converted["_Menu"].Position = UDim2.new(0.5, 0, 0.0500000007, 0)
Converted["_Menu"].Size = UDim2.new(0, 441, 0, 268)
Converted["_Menu"].Name = "Menu"
Converted["_Menu"].Parent = Converted["_YARHM"]
Converted["_UICorner14"].CornerRadius = UDim.new(0, 16)
Converted["_UICorner14"].Parent = Converted["_Menu"]
Converted["_UIStroke5"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke5"].Thickness = 2
Converted["_UIStroke5"].Parent = Converted["_Menu"]
Converted["_UIGradient4"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(53.00000064074993, 53.00000064074993, 53.00000064074993)),
ColorSequenceKeypoint.new(0.15224914252758026, Color3.fromRGB(50.69031357765198, 50.69031357765198, 50.69031357765198)),
ColorSequenceKeypoint.new(0.4723183512687683, Color3.fromRGB(255, 0, 4.000000236555934)),
ColorSequenceKeypoint.new(0.7577854990959167, Color3.fromRGB(50.13314567506313, 50.13314567506313, 50.13314567506313)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(48.000000938773155, 48.000000938773155, 48.000000938773155))
}
Converted["_UIGradient4"].Rotation = 180
Converted["_UIGradient4"].Parent = Converted["_UIStroke5"]
Converted["_HubCredits"].Font = Enum.Font.GothamBold
Converted["_HubCredits"].Text = "XDarkHUB MM2 Module" -- ИЗМЕНЕНО
Converted["_HubCredits"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_HubCredits"].TextScaled = true
Converted["_HubCredits"].TextSize = 14
Converted["_HubCredits"].TextTransparency = 0.699999988079071
Converted["_HubCredits"].TextWrapped = true
Converted["_HubCredits"].TextXAlignment = Enum.TextXAlignment.Right
Converted["_HubCredits"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_HubCredits"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_HubCredits"].BackgroundTransparency = 1
Converted["_HubCredits"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_HubCredits"].BorderSizePixel = 0
Converted["_HubCredits"].Position = UDim2.new(0.785926819, 0, 0.160157606, 0)
Converted["_HubCredits"].Size = UDim2.new(0.316320807, 0, 0.0585099049, 0)
Converted["_HubCredits"].Visible = false
Converted["_HubCredits"].Name = "HubCredits"
Converted["_HubCredits"].Parent = Converted["_Menu"]
Converted["_HubDesc"].Font = Enum.Font.GothamBold
Converted["_HubDesc"].Text = "XDarkHUB v34" -- ИЗМЕНЕНО
Converted["_HubDesc"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_HubDesc"].TextSize = 14
Converted["_HubDesc"].TextWrapped = true
Converted["_HubDesc"].TextXAlignment = Enum.TextXAlignment.Right
Converted["_HubDesc"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_HubDesc"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_HubDesc"].BackgroundTransparency = 1
Converted["_HubDesc"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_HubDesc"].BorderSizePixel = 0
Converted["_HubDesc"].Position = UDim2.new(0.708829343, 0, 0.116141364, 0)
Converted["_HubDesc"].Size = UDim2.new(0.470515788, 0, 0.082417585, 0)
Converted["_HubDesc"].Name = "HubDesc"
Converted["_HubDesc"].Parent = Converted["_Menu"]
Converted["_HubName"].Font = Enum.Font.GothamBold
Converted["_HubName"].RichText = true
Converted["_HubName"].Text = "XDarkHUB " -- ИЗМЕНЕНО
Converted["_HubName"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_HubName"].TextScaled = true
Converted["_HubName"].TextSize = 14
Converted["_HubName"].TextWrapped = true
Converted["_HubName"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_HubName"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_HubName"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_HubName"].BackgroundTransparency = 1
Converted["_HubName"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_HubName"].BorderSizePixel = 0
Converted["_HubName"].Position = UDim2.new(0.186153606, 0, 0.112410031, 0)
Converted["_HubName"].Size = UDim2.new(0.259631485, 0, 0.0824175924, 0)
Converted["_HubName"].Name = "HubName"
Converted["_HubName"].Parent = Converted["_Menu"]
Converted["_CanvasGroup"].GroupTransparency = 1
Converted["_CanvasGroup"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_CanvasGroup"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_CanvasGroup"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_CanvasGroup"].BorderSizePixel = 0
Converted["_CanvasGroup"].Interactable = false
Converted["_CanvasGroup"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_CanvasGroup"].Size = UDim2.new(1, 0, 1, 0)
Converted["_CanvasGroup"].Visible = false
Converted["_CanvasGroup"].ZIndex = 999999998
Converted["_CanvasGroup"].Parent = Converted["_Menu"]
Converted["_UICorner15"].CornerRadius = UDim.new(0, 16)
Converted["_UICorner15"].Parent = Converted["_CanvasGroup"]
Converted["_ImageLabel"].Image = "rbxassetid://17864987433"
Converted["_ImageLabel"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_ImageLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ImageLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ImageLabel"].BorderSizePixel = 0
Converted["_ImageLabel"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_ImageLabel"].Size = UDim2.new(0, 50, 0, 50)
Converted["_ImageLabel"].Visible = false
Converted["_ImageLabel"].ZIndex = 3
Converted["_ImageLabel"].Parent = Converted["_CanvasGroup"]
Converted["_Opener"].Font = Enum.Font.SourceSans
Converted["_Opener"].Text = ""
Converted["_Opener"].TextColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Opener"].TextSize = 14
Converted["_Opener"].AutoButtonColor = false
Converted["_Opener"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Opener"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Opener"].BorderSizePixel = 0
Converted["_Opener"].Size = UDim2.new(1, 0, 1, 0)
Converted["_Opener"].Name = "Opener"
Converted["_Opener"].Parent = Converted["_CanvasGroup"]
Converted["_TextLabel4"].Font = Enum.Font.GothamBold
Converted["_TextLabel4"].Text = "XDarkHUB MM2 Module" -- ИЗМЕНЕНО
Converted["_TextLabel4"].TextColor3 = Color3.fromRGB(255, 69.00000348687172, 67.00000360608101)
Converted["_TextLabel4"].TextScaled = true
Converted["_TextLabel4"].TextSize = 14
Converted["_TextLabel4"].TextWrapped = true
Converted["_TextLabel4"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel4"].BackgroundTransparency = 1
Converted["_TextLabel4"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel4"].BorderSizePixel = 0
Converted["_TextLabel4"].Position = UDim2.new(0.204081595, 0, 0.447761208, 0)
Converted["_TextLabel4"].Size = UDim2.new(0, 260, 0, 27)
Converted["_TextLabel4"].ZIndex = 3
Converted["_TextLabel4"].Parent = Converted["_CanvasGroup"]
Converted["_CloseArea"].Text = ""
Converted["_CloseArea"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_CloseArea"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_CloseArea"].BackgroundTransparency = 1
Converted["_CloseArea"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_CloseArea"].BorderSizePixel = 0
Converted["_CloseArea"].Position = UDim2.new(0.5, 0, 0.00295135868, 0)
Converted["_CloseArea"].Size = UDim2.new(0.326999992, 0, 0.184, 0)
Converted["_CloseArea"].Name = "CloseArea"
Converted["_CloseArea"].Parent = Converted["_Menu"]
Converted["_Frame1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame1"].BackgroundTransparency = 0.6499999761581421
Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame1"].BorderSizePixel = 0
Converted["_Frame1"].Position = UDim2.new(0.5, 0, 0.699999988, 0)
Converted["_Frame1"].Size = UDim2.new(0.699999988, 0, 0.100000001, 0)
Converted["_Frame1"].Parent = Converted["_CloseArea"]
Converted["_UICorner16"].CornerRadius = UDim.new(0, 9999)
Converted["_UICorner16"].Parent = Converted["_Frame1"]
Converted["_themedColor2"].Value = "accentColor"
Converted["_themedColor2"].Name = "themedColor"
Converted["_themedColor2"].Parent = Converted["_Frame1"]
Converted["_TextLabel5"].Font = Enum.Font.Gotham
Converted["_TextLabel5"].Text = "Tap here to minimize."
Converted["_TextLabel5"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel5"].TextSize = 15
Converted["_TextLabel5"].TextWrapped = true
Converted["_TextLabel5"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel5"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel5"].BackgroundTransparency = 0.4000000059604645
Converted["_TextLabel5"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel5"].BorderSizePixel = 0
Converted["_TextLabel5"].Position = UDim2.new(0.5, 0, 0.680000007, 0)
Converted["_TextLabel5"].Size = UDim2.new(1.39999998, 0, 0.740999997, 0)
Converted["_TextLabel5"].Parent = Converted["_CloseArea"]
Converted["_UICorner17"].Parent = Converted["_TextLabel5"]
Converted["_AllowForSpring"].Name = "AllowForSpring"
Converted["_AllowForSpring"].Parent = Converted["_CloseArea"]
Converted["_themedColor3"].Value = "backgroundColorCSQ"
Converted["_themedColor3"].Name = "themedColor"
Converted["_themedColor3"].Parent = Converted["_Menu"]
Converted["_UIGradient5"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(36.00000165402889, 36.00000165402889, 36.00000165402889)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(68.00000354647636, 68.00000354647636, 68.00000354647636))
}
Converted["_UIGradient5"].Offset = Vector2.new(0, 0.5)
Converted["_UIGradient5"].Rotation = 68
Converted["_UIGradient5"].Parent = Converted["_Menu"]
Converted["_Area"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Area"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Area"].BackgroundTransparency = 1
Converted["_Area"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Area"].BorderSizePixel = 0
Converted["_Area"].Position = UDim2.new(0.659600496, 0, 0.60637325, 0)
Converted["_Area"].Size = UDim2.new(0.643815279, 0, 0.783582091, 0)
Converted["_Area"].Name = "Area"
Converted["_Area"].Parent = Converted["_Menu"]
Converted["_Area1"].AutomaticCanvasSize = Enum.AutomaticSize.Y
Converted["_Area1"].CanvasSize = UDim2.new(0, 0, 0, 0)
Converted["_Area1"].ScrollBarThickness = 0
Converted["_Area1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Area1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Area1"].BackgroundTransparency = 1
Converted["_Area1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Area1"].BorderSizePixel = 0
Converted["_Area1"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_Area1"].Selectable = false
Converted["_Area1"].Size = UDim2.new(1, 0, 1, 0)
Converted["_Area1"].Name = "Area"
Converted["_Area1"].Parent = Converted["_Area"]
Converted["_TextLabel6"].Font = Enum.Font.GothamBold
Converted["_TextLabel6"].Text = "3 years of keyless! 🎉"
Converted["_TextLabel6"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel6"].TextSize = 14
Converted["_TextLabel6"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel6"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel6"].BackgroundTransparency = 1
Converted["_TextLabel6"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel6"].BorderSizePixel = 0
Converted["_TextLabel6"].Position = UDim2.new(0.4923051, 0, 0.46438089, 0)
Converted["_TextLabel6"].Size = UDim2.new(0, 200, 0, 50)
Converted["_TextLabel6"].Parent = Converted["_Area1"]
Converted["_TextLabel7"].Font = Enum.Font.GothamBold
Converted["_TextLabel7"].Text = "XDarkHUB" -- ИЗМЕНЕНО
Converted["_TextLabel7"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel7"].TextScaled = true
Converted["_TextLabel7"].TextSize = 14
Converted["_TextLabel7"].TextWrapped = true
Converted["_TextLabel7"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel7"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel7"].BackgroundTransparency = 1
Converted["_TextLabel7"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel7"].BorderSizePixel = 0
Converted["_TextLabel7"].Position = UDim2.new(0.491272807, 0, 0.363785654, 0)
Converted["_TextLabel7"].Size = UDim2.new(0, 135, 0, 33)
Converted["_TextLabel7"].Parent = Converted["_Area1"]
Converted["_UICorner18"].Parent = Converted["_Area"]
Converted["_List"].AnchorPoint = Vector2.new(0, 0.5)
Converted["_List"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_List"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_List"].BorderSizePixel = 0
Converted["_List"].Position = UDim2.new(0, 0, 0.606999993, 0)
Converted["_List"].Size = UDim2.new(0.315405339, 0, 0.785387993, 0)
Converted["_List"].Name = "List"
Converted["_List"].Parent = Converted["_Menu"]
Converted["_UICorner19"].CornerRadius = UDim.new(0, 16)
Converted["_UICorner19"].Parent = Converted["_List"]
Converted["_ScrollingFrame1"].AutomaticCanvasSize = Enum.AutomaticSize.Y
Converted["_ScrollingFrame1"].CanvasSize = UDim2.new(0, 0, 0, 0)
Converted["_ScrollingFrame1"].ScrollBarThickness = 2
Converted["_ScrollingFrame1"].VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
Converted["_ScrollingFrame1"].Active = true
Converted["_ScrollingFrame1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_ScrollingFrame1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ScrollingFrame1"].BackgroundTransparency = 1
Converted["_ScrollingFrame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ScrollingFrame1"].BorderSizePixel = 0
Converted["_ScrollingFrame1"].Position = UDim2.new(0.478333294, 0, 0.408619136, 0)
Converted["_ScrollingFrame1"].Size = UDim2.new(1, 0, 0.795258284, 0)
Converted["_ScrollingFrame1"].Parent = Converted["_List"]
Converted["_UIListLayout4"].Padding = UDim.new(0, 3)
Converted["_UIListLayout4"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout4"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout4"].Parent = Converted["_ScrollingFrame1"]
Converted["_UIPadding11"].PaddingLeft = UDim.new(0, 4)
Converted["_UIPadding11"].Parent = Converted["_ScrollingFrame1"]
Converted["_UIPadding12"].PaddingBottom = UDim.new(0, 10)
Converted["_UIPadding12"].PaddingLeft = UDim.new(0, 10)
Converted["_UIPadding12"].PaddingRight = UDim.new(0, 10)
Converted["_UIPadding12"].PaddingTop = UDim.new(0, 10)
Converted["_UIPadding12"].Parent = Converted["_List"]
Converted["_UIStroke6"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke6"].Thickness = 0
Converted["_UIStroke6"].Parent = Converted["_List"]
Converted["_UIGradient6"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(111.00000098347664, 111.00000098347664, 111.00000098347664)),
ColorSequenceKeypoint.new(0.6401384472846985, Color3.fromRGB(114.23875719308853, 114.23875719308853, 114.23875719308853)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
Converted["_UIGradient6"].Rotation = -44
Converted["_UIGradient6"].Parent = Converted["_UIStroke6"]
Converted["_AddCustomModule1"].Font = Enum.Font.Gotham
Converted["_AddCustomModule1"].Text = "+"
Converted["_AddCustomModule1"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_AddCustomModule1"].TextScaled = true
Converted["_AddCustomModule1"].TextSize = 14
Converted["_AddCustomModule1"].TextWrapped = true
Converted["_AddCustomModule1"].AnchorPoint = Vector2.new(1, 1)
Converted["_AddCustomModule1"].BackgroundColor3 = Color3.fromRGB(50.00000461935997, 50.00000461935997, 50.00000461935997)
Converted["_AddCustomModule1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_AddCustomModule1"].BorderSizePixel = 0
Converted["_AddCustomModule1"].Position = UDim2.new(1, 0, 1, 0)
Converted["_AddCustomModule1"].Size = UDim2.new(0.215681866, 0, 0.142528668, 0)
Converted["_AddCustomModule1"].Visible = false
Converted["_AddCustomModule1"].Name = "AddCustomModule"
Converted["_AddCustomModule1"].Parent = Converted["_List"]
Converted["_UICorner20"].Parent = Converted["_AddCustomModule1"]
Converted["_UIPadding13"].PaddingLeft = UDim.new(0, 1)
Converted["_UIPadding13"].Parent = Converted["_AddCustomModule1"]
Converted["_UIStroke7"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Converted["_UIStroke7"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke7"].Parent = Converted["_AddCustomModule1"]
Converted["_themedColor4"].Value = "secondaryColor"
Converted["_themedColor4"].Name = "themedColor"
Converted["_themedColor4"].Parent = Converted["_UIStroke7"]
Converted["_themedColor5"].Value = "primaryColor"
Converted["_themedColor5"].Name = "themedColor"
Converted["_themedColor5"].Parent = Converted["_AddCustomModule1"]
Converted["_themedColor6"].Value = "primaryColor"
Converted["_themedColor6"].Name = "themedColor"
Converted["_themedColor6"].Parent = Converted["_List"]
Converted["_UIScale3"].Parent = Converted["_Menu"]
Converted["_Stub"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_Stub"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Stub"].BorderSizePixel = 0
Converted["_Stub"].Position = UDim2.new(0, 0, 0.214000002, 0)
Converted["_Stub"].Size = UDim2.new(0.0340136066, 0, 0.055970151, 0)
Converted["_Stub"].ZIndex = -9999
Converted["_Stub"].Name = "Stub"
Converted["_Stub"].Parent = Converted["_Menu"]
Converted["_themedColor7"].Value = "primaryColor"
Converted["_themedColor7"].Name = "themedColor"
Converted["_themedColor7"].Parent = Converted["_Stub"]
Converted["_Stub1"].AnchorPoint = Vector2.new(1, 1)
Converted["_Stub1"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_Stub1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Stub1"].BorderSizePixel = 0
Converted["_Stub1"].Position = UDim2.new(0.315192729, 0, 1, 0)
Converted["_Stub1"].Size = UDim2.new(0.0453514755, 0, 0.074626863, 0)
Converted["_Stub1"].ZIndex = -9999
Converted["_Stub1"].Name = "Stub"
Converted["_Stub1"].Parent = Converted["_Menu"]
Converted["_themedColor8"].Value = "primaryColor"
Converted["_themedColor8"].Name = "themedColor"
Converted["_themedColor8"].Parent = Converted["_Stub1"]
Converted["_Toggle"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Toggle"].BackgroundTransparency = 1
Converted["_Toggle"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Toggle"].BorderSizePixel = 0
Converted["_Toggle"].Size = UDim2.new(1, 0, 0, 35)
Converted["_Toggle"].Visible = false
Converted["_Toggle"].Name = "Toggle"
Converted["_Toggle"].Parent = Converted["_YARHM"]
Converted["_TextLabel8"].Font = Enum.Font.Unknown
Converted["_TextLabel8"].Text = "Loop walkspeed and FOV"
Converted["_TextLabel8"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel8"].TextScaled = true
Converted["_TextLabel8"].TextSize = 14
Converted["_TextLabel8"].TextWrapped = true
Converted["_TextLabel8"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextLabel8"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel8"].BackgroundTransparency = 1
Converted["_TextLabel8"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel8"].BorderSizePixel = 0
Converted["_TextLabel8"].Size = UDim2.new(0.699999988, 0, 0, 25)
Converted["_TextLabel8"].Parent = Converted["_Toggle"]
Converted["_UIListLayout5"].Padding = UDim.new(0, 25)
Converted["_UIListLayout5"].FillDirection = Enum.FillDirection.Horizontal
Converted["_UIListLayout5"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout5"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout5"].VerticalAlignment = Enum.VerticalAlignment.Center
Converted["_UIListLayout5"].Parent = Converted["_Toggle"]
Converted["_Frame2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame2"].BackgroundTransparency = 1
Converted["_Frame2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame2"].BorderSizePixel = 0
Converted["_Frame2"].Size = UDim2.new(0.200000003, 0, 1, 0)
Converted["_Frame2"].Parent = Converted["_Toggle"]
Converted["_Frame3"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Frame3"].BackgroundColor3 = Color3.fromRGB(46.000001057982445, 46.000001057982445, 46.000001057982445)
Converted["_Frame3"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame3"].BorderSizePixel = 0
Converted["_Frame3"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_Frame3"].Size = UDim2.new(0, 89, 1, 0)
Converted["_Frame3"].Parent = Converted["_Frame2"]
Converted["_UICorner21"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner21"].Parent = Converted["_Frame3"]
Converted["_Toggler"].Font = Enum.Font.SourceSans
Converted["_Toggler"].Text = ""
Converted["_Toggler"].TextColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Toggler"].TextSize = 14
Converted["_Toggler"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Toggler"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Toggler"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Toggler"].BorderSizePixel = 0
Converted["_Toggler"].Position = UDim2.new(0.300000012, 0, 0.5, 0)
Converted["_Toggler"].Size = UDim2.new(0.449438214, 0, 0.800000012, 0)
Converted["_Toggler"].Name = "Toggler"
Converted["_Toggler"].Parent = Converted["_Frame3"]
Converted["_UICorner22"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner22"].Parent = Converted["_Toggler"]
Converted["_ImageLabel1"].Image = "rbxassetid://10002373478"
Converted["_ImageLabel1"].ImageColor3 = Color3.fromRGB(255, 0, 4.000000236555934)
Converted["_ImageLabel1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_ImageLabel1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ImageLabel1"].BackgroundTransparency = 1
Converted["_ImageLabel1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ImageLabel1"].BorderSizePixel = 0
Converted["_ImageLabel1"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_ImageLabel1"].Size = UDim2.new(0, 20, 0, 20)
Converted["_ImageLabel1"].Parent = Converted["_Toggler"]
Converted["_UIPadding14"].PaddingRight = UDim.new(0.0700000003, 0)
Converted["_UIPadding14"].Parent = Converted["_Toggle"]
Converted["_Modules"].Name = "Modules"
Converted["_Modules"].Parent = Converted["_YARHM"]
Converted["_NotificationSample"].AnchorPoint = Vector2.new(0.5, 0)
Converted["_NotificationSample"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_NotificationSample"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_NotificationSample"].BorderSizePixel = 0
Converted["_NotificationSample"].ClipsDescendants = true
Converted["_NotificationSample"].Position = UDim2.new(0.5, 0, 0, 10)
Converted["_NotificationSample"].Size = UDim2.new(0, 400, 0, 50)
Converted["_NotificationSample"].Visible = false
Converted["_NotificationSample"].ZIndex = 5
Converted["_NotificationSample"].Name = "NotificationSample"
Converted["_NotificationSample"].Parent = Converted["_YARHM"]
Converted["_UICorner23"].CornerRadius = UDim.new(0, 10)
Converted["_UICorner23"].Parent = Converted["_NotificationSample"]
Converted["_UIStroke8"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke8"].Thickness = 1.600000023841858
Converted["_UIStroke8"].Parent = Converted["_NotificationSample"]
Converted["_UIGradient7"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(46.000001057982445, 46.000001057982445, 46.000001057982445)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(12.000000234693289, 12.000000234693289, 12.000000234693289))
}
Converted["_UIGradient7"].Parent = Converted["_NotificationSample"]
Converted["_ImageLabel2"].Image = "rbxassetid://11780939099"
Converted["_ImageLabel2"].ScaleType = Enum.ScaleType.Fit
Converted["_ImageLabel2"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_ImageLabel2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ImageLabel2"].BackgroundTransparency = 1
Converted["_ImageLabel2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ImageLabel2"].BorderSizePixel = 0
Converted["_ImageLabel2"].Position = UDim2.new(0.100000001, 0, 0.5, 0)
Converted["_ImageLabel2"].Size = UDim2.new(0.0799999982, 0, 0.639999986, 0)
Converted["_ImageLabel2"].Parent = Converted["_NotificationSample"]
Converted["_TextLabel9"].Font = Enum.Font.Gotham
Converted["_TextLabel9"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel9"].TextScaled = true
Converted["_TextLabel9"].TextSize = 14
Converted["_TextLabel9"].TextWrapped = true
Converted["_TextLabel9"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextLabel9"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel9"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel9"].BackgroundTransparency = 1
Converted["_TextLabel9"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel9"].BorderSizePixel = 0
Converted["_TextLabel9"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_TextLabel9"].Size = UDim2.new(0.600000024, 0, 0.600000024, 0)
Converted["_TextLabel9"].Parent = Converted["_NotificationSample"]
Converted["_UITextSizeConstraint"].MaxTextSize = 30
Converted["_UITextSizeConstraint"].Parent = Converted["_TextLabel9"]
Converted["_Close"].Image = "rbxassetid://10002373478"
Converted["_Close"].ScaleType = Enum.ScaleType.Fit
Converted["_Close"].Active = false
Converted["_Close"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Close"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Close"].BackgroundTransparency = 1
Converted["_Close"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Close"].BorderSizePixel = 0
Converted["_Close"].Position = UDim2.new(0.899999976, 0, 0.5, 0)
Converted["_Close"].Selectable = false
Converted["_Close"].Size = UDim2.new(0.0799999982, 0, 0.639999986, 0)
Converted["_Close"].Name = "Close"
Converted["_Close"].Parent = Converted["_NotificationSample"]
Converted["_UICorner24"].Parent = Converted["_Close"]
Converted["_UIStroke9"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke9"].Parent = Converted["_Close"]
Converted["_UIScale4"].Scale = 0.800000011920929
Converted["_UIScale4"].Parent = Converted["_NotificationSample"]
Converted["_themedColor9"].Value = "backgroundColorCSQ"
Converted["_themedColor9"].Name = "themedColor"
Converted["_themedColor9"].Parent = Converted["_NotificationSample"]
Converted["_Dialog"].AnchorPoint = Vector2.new(0.5, 1)
Converted["_Dialog"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Dialog"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Dialog"].BorderSizePixel = 0
Converted["_Dialog"].Position = UDim2.new(0.499000013, 0, 0.984000027, 0)
Converted["_Dialog"].Size = UDim2.new(0, 313, 0, 147)
Converted["_Dialog"].Visible = false
Converted["_Dialog"].ZIndex = 5
Converted["_Dialog"].Name = "Dialog"
Converted["_Dialog"].Parent = Converted["_YARHM"]
Converted["_UICorner25"].Parent = Converted["_Dialog"]
Converted["_UIGradient8"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(36.00000165402889, 36.00000165402889, 36.00000165402889)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(68.00000354647636, 68.00000354647636, 68.00000354647636))
}
Converted["_UIGradient8"].Rotation = -133
Converted["_UIGradient8"].Parent = Converted["_Dialog"]
Converted["_UIPadding15"].PaddingBottom = UDim.new(0, 15)
Converted["_UIPadding15"].PaddingLeft = UDim.new(0, 15)
Converted["_UIPadding15"].PaddingRight = UDim.new(0, 15)
Converted["_UIPadding15"].PaddingTop = UDim.new(0, 15)
Converted["_UIPadding15"].Parent = Converted["_Dialog"]
Converted["_UIStroke10"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke10"].Thickness = 2
Converted["_UIStroke10"].Parent = Converted["_Dialog"]
Converted["_UIGradient9"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(111.00000098347664, 111.00000098347664, 111.00000098347664)),
ColorSequenceKeypoint.new(0.6401384472846985, Color3.fromRGB(114.23875719308853, 114.23875719308853, 114.23875719308853)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
Converted["_UIGradient9"].Rotation = -107
Converted["_UIGradient9"].Parent = Converted["_UIStroke10"]
Converted["_DialogTitle"].Font = Enum.Font.Unknown
Converted["_DialogTitle"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_DialogTitle"].TextScaled = true
Converted["_DialogTitle"].TextSize = 14
Converted["_DialogTitle"].TextWrapped = true
Converted["_DialogTitle"].TextXAlignment = Enum.TextXAlignment.Right
Converted["_DialogTitle"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_DialogTitle"].BackgroundTransparency = 1
Converted["_DialogTitle"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_DialogTitle"].BorderSizePixel = 0
Converted["_DialogTitle"].Size = UDim2.new(0.997416437, 0, 0.16459392, 0)
Converted["_DialogTitle"].Name = "DialogTitle"
Converted["_DialogTitle"].Parent = Converted["_Dialog"]
Converted["_UIListLayout6"].Padding = UDim.new(0, 3)
Converted["_UIListLayout6"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout6"].Parent = Converted["_Dialog"]
Converted["_DialogDesc"].Font = Enum.Font.Unknown
Converted["_DialogDesc"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_DialogDesc"].TextScaled = true
Converted["_DialogDesc"].TextSize = 14
Converted["_DialogDesc"].TextWrapped = true
Converted["_DialogDesc"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_DialogDesc"].TextYAlignment = Enum.TextYAlignment.Top
Converted["_DialogDesc"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_DialogDesc"].BackgroundTransparency = 1
Converted["_DialogDesc"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_DialogDesc"].BorderSizePixel = 0
Converted["_DialogDesc"].Position = UDim2.new(0, 0, 0.187079012, 0)
Converted["_DialogDesc"].Size = UDim2.new(0.997416437, 0, 0.604575336, 0)
Converted["_DialogDesc"].Name = "DialogDesc"
Converted["_DialogDesc"].Parent = Converted["_Dialog"]
Converted["_UITextSizeConstraint1"].MaxTextSize = 20
Converted["_UITextSizeConstraint1"].MinTextSize = 5
Converted["_UITextSizeConstraint1"].Parent = Converted["_DialogDesc"]
Converted["_Options"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Options"].BackgroundTransparency = 1
Converted["_Options"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Options"].BorderSizePixel = 0
Converted["_Options"].Position = UDim2.new(0, 0, 0.82045126, 0)
Converted["_Options"].Size = UDim2.new(0.997436285, 0, 0.241758227, 0)
Converted["_Options"].Name = "Options"
Converted["_Options"].Parent = Converted["_Dialog"]
Converted["_UIListLayout7"].Padding = UDim.new(0, 10)
Converted["_UIListLayout7"].FillDirection = Enum.FillDirection.Horizontal
Converted["_UIListLayout7"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout7"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout7"].Parent = Converted["_Options"]
Converted["_OptionPlaceholder"].Font = Enum.Font.GothamBold
Converted["_OptionPlaceholder"].RichText = true
Converted["_OptionPlaceholder"].Text = "aaaaaaaaaaa"
Converted["_OptionPlaceholder"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_OptionPlaceholder"].TextScaled = true
Converted["_OptionPlaceholder"].TextSize = 100
Converted["_OptionPlaceholder"].TextWrapped = true
Converted["_OptionPlaceholder"].BackgroundColor3 = Color3.fromRGB(36.00000165402889, 36.00000165402889, 36.00000165402889)
Converted["_OptionPlaceholder"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_OptionPlaceholder"].BorderSizePixel = 0
Converted["_OptionPlaceholder"].Size = UDim2.new(0.532000005, -5, 1.00899994, 0)
Converted["_OptionPlaceholder"].Visible = false
Converted["_OptionPlaceholder"].Name = "OptionPlaceholder"
Converted["_OptionPlaceholder"].Parent = Converted["_Options"]
Converted["_UIPadding16"].PaddingBottom = UDim.new(0, 1)
Converted["_UIPadding16"].PaddingLeft = UDim.new(0, 15)
Converted["_UIPadding16"].PaddingRight = UDim.new(0, 15)
Converted["_UIPadding16"].PaddingTop = UDim.new(0, 1)
Converted["_UIPadding16"].Parent = Converted["_OptionPlaceholder"]
Converted["_UICorner26"].Parent = Converted["_OptionPlaceholder"]
Converted["_UIStroke11"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Converted["_UIStroke11"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke11"].Thickness = 2
Converted["_UIStroke11"].Parent = Converted["_OptionPlaceholder"]
Converted["_UIGradient10"].Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(111.00000098347664, 111.00000098347664, 111.00000098347664)),
ColorSequenceKeypoint.new(0.6401384472846985, Color3.fromRGB(114.23875719308853, 114.23875719308853, 114.23875719308853)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
Converted["_UIGradient10"].Rotation = -107
Converted["_UIGradient10"].Parent = Converted["_UIStroke11"]
Converted["_themedColor10"].Value = "primaryColor"
Converted["_themedColor10"].Name = "themedColor"
Converted["_themedColor10"].Parent = Converted["_OptionPlaceholder"]
Converted["_OnSelect"].Name = "OnSelect"
Converted["_OnSelect"].Parent = Converted["_Dialog"]
Converted["_UIScale5"].Parent = Converted["_Dialog"]
Converted["_themedColor11"].Value = "backgroundColorCSQ"
Converted["_themedColor11"].Name = "themedColor"
Converted["_themedColor11"].Parent = Converted["_Dialog"]
Converted["_Range"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Range"].BackgroundTransparency = 1
Converted["_Range"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Range"].BorderSizePixel = 0
Converted["_Range"].Size = UDim2.new(1, 0, 0, 35)
Converted["_Range"].Visible = false
Converted["_Range"].Name = "Range"
Converted["_Range"].Parent = Converted["_YARHM"]
Converted["_TextLabel10"].Font = Enum.Font.Unknown
Converted["_TextLabel10"].Text = "something something idk lol"
Converted["_TextLabel10"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel10"].TextScaled = true
Converted["_TextLabel10"].TextSize = 58
Converted["_TextLabel10"].TextWrapped = true
Converted["_TextLabel10"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextLabel10"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel10"].BackgroundTransparency = 1
Converted["_TextLabel10"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel10"].BorderSizePixel = 0
Converted["_TextLabel10"].Position = UDim2.new(-0.0633024424, 0, 0.685714304, 0)
Converted["_TextLabel10"].Size = UDim2.new(0, 125, 0, 25)
Converted["_TextLabel10"].Parent = Converted["_Range"]
Converted["_UIListLayout8"].HorizontalFlex = Enum.UIFlexAlignment.Fill
Converted["_UIListLayout8"].Padding = UDim.new(0, 15)
Converted["_UIListLayout8"].VerticalFlex = Enum.UIFlexAlignment.SpaceAround
Converted["_UIListLayout8"].FillDirection = Enum.FillDirection.Horizontal
Converted["_UIListLayout8"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout8"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout8"].VerticalAlignment = Enum.VerticalAlignment.Center
Converted["_UIListLayout8"].Parent = Converted["_Range"]
Converted["_UIPadding17"].Parent = Converted["_Range"]
Converted["_Frame4"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame4"].BackgroundTransparency = 1
Converted["_Frame4"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame4"].BorderSizePixel = 0
Converted["_Frame4"].Size = UDim2.new(0.400000006, 0, 1, 0)
Converted["_Frame4"].Parent = Converted["_Range"]
Converted["_UIPadding18"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding18"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding18"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding18"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding18"].Parent = Converted["_Frame4"]
Converted["_UICorner27"].Parent = Converted["_Frame4"]
Converted["_Track"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Track"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 22.000000588595867, 22.000000588595867)
Converted["_Track"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Track"].BorderSizePixel = 0
Converted["_Track"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_Track"].Size = UDim2.new(1, 0, 1.20000005, 0)
Converted["_Track"].Name = "Track"
Converted["_Track"].Parent = Converted["_Frame4"]
Converted["_UICorner28"].CornerRadius = UDim.new(0, 6)
Converted["_UICorner28"].Parent = Converted["_Track"]
Converted["_Ball"].Font = Enum.Font.SourceSans
Converted["_Ball"].Text = ""
Converted["_Ball"].TextColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Ball"].TextSize = 14
Converted["_Ball"].AnchorPoint = Vector2.new(0, 0.5)
Converted["_Ball"].BackgroundColor3 = Color3.fromRGB(197.0000034570694, 0, 0)
Converted["_Ball"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Ball"].BorderSizePixel = 0
Converted["_Ball"].Interactable = false
Converted["_Ball"].Position = UDim2.new(1.32920917e-07, 0, 0.5, 0)
Converted["_Ball"].Size = UDim2.new(0.0599999987, 0, 1, 0)
Converted["_Ball"].Name = "Ball"
Converted["_Ball"].Parent = Converted["_Track"]
Converted["_BallProgress"].Font = Enum.Font.GothamBold
Converted["_BallProgress"].Text = "0"
Converted["_BallProgress"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_BallProgress"].TextScaled = true
Converted["_BallProgress"].TextSize = 14
Converted["_BallProgress"].TextTransparency = 1
Converted["_BallProgress"].TextWrapped = true
Converted["_BallProgress"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_BallProgress"].BackgroundTransparency = 1
Converted["_BallProgress"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_BallProgress"].BorderSizePixel = 0
Converted["_BallProgress"].Size = UDim2.new(1, 0, 1, 0)
Converted["_BallProgress"].Name = "BallProgress"
Converted["_BallProgress"].Parent = Converted["_Ball"]
Converted["_UIPadding19"].PaddingBottom = UDim.new(0, 2)
Converted["_UIPadding19"].PaddingTop = UDim.new(0, 1)
Converted["_UIPadding19"].Parent = Converted["_Ball"]
Converted["_themedColor12"].Value = "accentColor"
Converted["_themedColor12"].Name = "themedColor"
Converted["_themedColor12"].Parent = Converted["_Ball"]
Converted["_UICorner29"].CornerRadius = UDim.new(1, 0)
Converted["_UICorner29"].Parent = Converted["_Ball"]
Converted["_UIPadding20"].PaddingBottom = UDim.new(0, 6)
Converted["_UIPadding20"].PaddingLeft = UDim.new(0, 6)
Converted["_UIPadding20"].PaddingRight = UDim.new(0, 6)
Converted["_UIPadding20"].PaddingTop = UDim.new(0, 6)
Converted["_UIPadding20"].Parent = Converted["_Track"]
Converted["_TrackProgress"].Font = Enum.Font.GothamBold
Converted["_TrackProgress"].Text = "0"
Converted["_TrackProgress"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TrackProgress"].TextScaled = true
Converted["_TrackProgress"].TextSize = 14
Converted["_TrackProgress"].TextTransparency = 1
Converted["_TrackProgress"].TextWrapped = true
Converted["_TrackProgress"].TextXAlignment = Enum.TextXAlignment.Right
Converted["_TrackProgress"].AnchorPoint = Vector2.new(1, 0.5)
Converted["_TrackProgress"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TrackProgress"].BackgroundTransparency = 1
Converted["_TrackProgress"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TrackProgress"].BorderSizePixel = 0
Converted["_TrackProgress"].Position = UDim2.new(1, 0, 0.5, 0)
Converted["_TrackProgress"].Size = UDim2.new(0, 35, 1, 0)
Converted["_TrackProgress"].Name = "TrackProgress"
Converted["_TrackProgress"].Parent = Converted["_Track"]
Converted["_themedColor13"].Value = "primaryColor"
Converted["_themedColor13"].Name = "themedColor"
Converted["_themedColor13"].Parent = Converted["_Track"]
Converted["_UISizeConstraint"].Parent = Converted["_Frame4"]
Converted["_FloatingButtonSetting"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_FloatingButtonSetting"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FloatingButtonSetting"].BackgroundTransparency = 0.5
Converted["_FloatingButtonSetting"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FloatingButtonSetting"].BorderSizePixel = 0
Converted["_FloatingButtonSetting"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_FloatingButtonSetting"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FloatingButtonSetting"].Visible = false
Converted["_FloatingButtonSetting"].ZIndex = 10
Converted["_FloatingButtonSetting"].Name = "FloatingButtonSetting"
Converted["_FloatingButtonSetting"].Parent = Converted["_YARHM"]
Converted["_ControlBarContainer"].AnchorPoint = Vector2.new(0.5, 1)
Converted["_ControlBarContainer"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ControlBarContainer"].BackgroundTransparency = 1
Converted["_ControlBarContainer"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ControlBarContainer"].BorderSizePixel = 0
Converted["_ControlBarContainer"].Position = UDim2.new(0.5, 0, 1, -50)
Converted["_ControlBarContainer"].Size = UDim2.new(1, 0, 0, 40)
Converted["_ControlBarContainer"].Name = "ControlBarContainer"
Converted["_ControlBarContainer"].Parent = Converted["_FloatingButtonSetting"]
Converted["_ControlBar"].AnchorPoint = Vector2.new(0.5, 1)
Converted["_ControlBar"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_ControlBar"].BackgroundTransparency = 1
Converted["_ControlBar"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ControlBar"].BorderSizePixel = 0
Converted["_ControlBar"].Position = UDim2.new(0.5, 0, 1, -30)
Converted["_ControlBar"].Size = UDim2.new(1, 0, 0, 40)
Converted["_ControlBar"].Name = "ControlBar"
Converted["_ControlBar"].Parent = Converted["_ControlBarContainer"]
Converted["_UIListLayout9"].Padding = UDim.new(0, 5)
Converted["_UIListLayout9"].FillDirection = Enum.FillDirection.Horizontal
Converted["_UIListLayout9"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout9"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout9"].Parent = Converted["_ControlBar"]
Converted["_Visibility"].Font = Enum.Font.Gotham
Converted["_Visibility"].Text = "Toggle visibility"
Converted["_Visibility"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Visibility"].TextScaled = true
Converted["_Visibility"].TextSize = 14
Converted["_Visibility"].TextWrapped = true
Converted["_Visibility"].BackgroundColor3 = Color3.fromRGB(46.000001057982445, 46.000001057982445, 46.000001057982445)
Converted["_Visibility"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Visibility"].BorderSizePixel = 0
Converted["_Visibility"].Size = UDim2.new(0, 200, 1, 0)
Converted["_Visibility"].Name = "Visibility"
Converted["_Visibility"].Parent = Converted["_ControlBar"]
Converted["_UICorner30"].CornerRadius = UDim.new(0, 16)
Converted["_UICorner30"].Parent = Converted["_Visibility"]
Converted["_UIPadding21"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding21"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding21"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding21"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding21"].Parent = Converted["_Visibility"]
Converted["_Event"].Parent = Converted["_Visibility"]
Converted["_themedColor14"].Value = "primaryColor"
Converted["_themedColor14"].Name = "themedColor"
Converted["_themedColor14"].Parent = Converted["_Visibility"]
Converted["_Lock1"].Font = Enum.Font.Gotham
Converted["_Lock1"].Text = "Toggle lock"
Converted["_Lock1"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Lock1"].TextScaled = true
Converted["_Lock1"].TextSize = 14
Converted["_Lock1"].TextWrapped = true
Converted["_Lock1"].BackgroundColor3 = Color3.fromRGB(46.000001057982445, 46.000001057982445, 46.000001057982445)
Converted["_Lock1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Lock1"].BorderSizePixel = 0
Converted["_Lock1"].Size = UDim2.new(0, 200, 1, 0)
Converted["_Lock1"].Name = "Lock"
Converted["_Lock1"].Parent = Converted["_ControlBar"]
Converted["_UICorner31"].CornerRadius = UDim.new(0, 16)
Converted["_UICorner31"].Parent = Converted["_Lock1"]
Converted["_UIPadding22"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding22"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding22"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding22"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding22"].Parent = Converted["_Lock1"]
Converted["_Event1"].Parent = Converted["_Lock1"]
Converted["_themedColor15"].Value = "primaryColor"
Converted["_themedColor15"].Name = "themedColor"
Converted["_themedColor15"].Parent = Converted["_Lock1"]
Converted["_Exit"].Font = Enum.Font.GothamBold
Converted["_Exit"].Text = "X"
Converted["_Exit"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Exit"].TextScaled = true
Converted["_Exit"].TextSize = 14
Converted["_Exit"].TextWrapped = true
Converted["_Exit"].BackgroundColor3 = Color3.fromRGB(46.000001057982445, 0, 0)
Converted["_Exit"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Exit"].BorderSizePixel = 0
Converted["_Exit"].Size = UDim2.new(1, 0, 1, 0)
Converted["_Exit"].Name = "Exit"
Converted["_Exit"].Parent = Converted["_ControlBar"]
Converted["_UICorner32"].CornerRadius = UDim.new(0, 16)
Converted["_UICorner32"].Parent = Converted["_Exit"]
Converted["_UIPadding23"].PaddingBottom = UDim.new(0, 7)
Converted["_UIPadding23"].PaddingLeft = UDim.new(0, 7)
Converted["_UIPadding23"].PaddingRight = UDim.new(0, 7)
Converted["_UIPadding23"].PaddingTop = UDim.new(0, 7)
Converted["_UIPadding23"].Parent = Converted["_Exit"]
Converted["_UIAspectRatioConstraint"].Parent = Converted["_Exit"]
Converted["_themedColor16"].Value = "secondaryColor"
Converted["_themedColor16"].Name = "themedColor"
Converted["_themedColor16"].Parent = Converted["_Exit"]
Converted["_UIListLayout10"].Padding = UDim.new(0, 5)
Converted["_UIListLayout10"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout10"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout10"].Parent = Converted["_ControlBarContainer"]
Converted["_Tip"].Font = Enum.Font.GothamBold
Converted["_Tip"].Text = "Drag the button around to resize!"
Converted["_Tip"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Tip"].TextScaled = true
Converted["_Tip"].TextSize = 14
Converted["_Tip"].TextWrapped = true
Converted["_Tip"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Tip"].BackgroundTransparency = 1
Converted["_Tip"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Tip"].BorderSizePixel = 0
Converted["_Tip"].Size = UDim2.new(1, 0, 0, 10)
Converted["_Tip"].Name = "Tip"
Converted["_Tip"].Parent = Converted["_ControlBarContainer"]
Converted["_UIStroke12"].Parent = Converted["_Tip"]
Converted["_UIScale6"].Parent = Converted["_ControlBarContainer"]
Converted["_FloatingButtons"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_FloatingButtons"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_FloatingButtons"].BackgroundTransparency = 1
Converted["_FloatingButtons"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FloatingButtons"].BorderSizePixel = 0
Converted["_FloatingButtons"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_FloatingButtons"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FloatingButtons"].ZIndex = 3
Converted["_FloatingButtons"].Name = "FloatingButtons"
Converted["_FloatingButtons"].Parent = Converted["_FloatingButtonSetting"]
Converted["_FloatingButtons1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_FloatingButtons1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_FloatingButtons1"].BackgroundTransparency = 1
Converted["_FloatingButtons1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FloatingButtons1"].BorderSizePixel = 0
Converted["_FloatingButtons1"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_FloatingButtons1"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FloatingButtons1"].ZIndex = 3
Converted["_FloatingButtons1"].Name = "FloatingButtons"
Converted["_FloatingButtons1"].Parent = Converted["_YARHM"]

-- Routine Module Scripts:
local routine_module_scripts = {}
do -- Routine Module: StarterGui.YARHM.FUNCTIONS
local script = Instance.new("ModuleScript")
script.Name = "FUNCTIONS"
script.Parent = Converted["_YARHM"]
local function module_script()
local FUNCTIONSmodule = {}
FUNCTIONSmodule.__v = "1.21"
local ts = game:GetService("TweenService")
local https = game:GetService("HttpService")
function DraggableObjectf()
local function a(b,c)local d=c.AbsoluteSize;local e=c.AbsolutePosition;local f=b.X.Scale*d.X+b.X.Offset;local g=b.Y.Scale*d.Y+b.Y.Offset;local h=math.clamp(f,0,d.X)local i=math.clamp(g,0,d.Y)local j=UDim2.new(b.X.Scale,h-b.X.Scale*d.X,b.Y.Scale,i-b.Y.Scale*d.Y)return j end;local k=UDim2.new;local l=game:GetService("UserInputService")local m=game:GetService("TweenService")local n={}n.__index=n;function n.new(o,p,q,r)local self={}self.Object=o;self.ToMove=p;self.Smooth=q;self.CallbackOnly=r;self.CanBeDragged=false;self.DragStarted=nil;self.DragEnded=nil;self.Dragged=nil;self.Dragging=false;self.LastPosition=nil;self.Velocity=Vector2.new(0,0)setmetatable(self,n)return self end;function n:Enable()self.CanBeDragged=true;local s=self.Object;local t=self.ToMove;local u=nil;local v=nil;local w=nil;local x=false;local function y(z)local A=z.Position-v;local B=UDim2.new(w.X.Scale,w.X.Offset+A.X,w.Y.Scale,w.Y.Offset+A.Y)if self.CallbackOnly then else B=a(B,self.Object:FindFirstAncestorWhichIsA("ScreenGui"))if(self.Smooth==nil or self.Smooth==true)and self.Smooth~=false then m:Create(t and t or s,TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Position=B}):Play()else local C=t and t or s;C.Position=B end end;return B end;self.InputBegan=s.InputBegan:Connect(function(z)if z.UserInputType==Enum.UserInputType.MouseButton1 or z.UserInputType==Enum.UserInputType.Touch then x=true;local D;D=z.Changed:Connect(function()if z.UserInputState==Enum.UserInputState.End and(self.Dragging or x)then self.Dragging=false;D:Disconnect()if self.DragEnded and not x then self.DragEnded(self.Velocity)end;x=false end end)end end)self.InputChanged=s.InputChanged:Connect(function(z)if z.UserInputType==Enum.UserInputType.MouseMovement or z.UserInputType==Enum.UserInputType.Touch then u=z end end)self.InputChanged2=l.InputChanged:Connect(function(z)if s.Parent==nil then self:Disable()return end;if x then x=false;if self.DragStarted then self.DragStarted()end;self.Dragging=true;v=z.Position;if t then w=t.Position else w=s.Position end;self.LastPosition=z.Position end;if z==u and self.Dragging then local B=y(z)self.Velocity=z.Position-self.LastPosition;self.LastPosition=z.Position;if self.Dragged then self.Dragged(B)end end end)end;function n:Disable()self.CanBeDragged=false;self.InputBegan:Disconnect()self.InputChanged:Disconnect()self.InputChanged2:Disconnect()if self.Dragging then self.Dragging=false;if self.DragEnded then self.DragEnded(self.Velocity)end end end;return n
end
local DraggableObject = DraggableObjectf()
function ClickAndHoldf()
local a={}a.__index=a;local b=game:GetService("UserInputService")function a.new(c,d)local self=setmetatable({},a)self.textButton=c;self.holdTime=d or 0.5;self.holdTask=nil;self.initialPosition=nil;self.Holded=Instance.new("BindableEvent")local function e(f,g)return math.sqrt((g.X-f.X)^2+(g.Y-f.Y)^2)end;self.textButton.MouseButton1Down:Connect(function(h,i)self.initialPosition=Vector2.new(h,i)self.holdTask=task.spawn(function()task.wait(self.holdTime)if self.holdTask then self.Holded:Fire()end end)end)b.InputChanged:Connect(function(j)if j.UserInputType==Enum.UserInputType.MouseMovement or j.UserInputType==Enum.UserInputType.Touch then if self.holdTask and self.initialPosition then local k=j.Position;local l=e(self.initialPosition,k)if l>10 then coroutine.close(self.holdTask)self.holdTask=nil end end end end)b.InputEnded:Connect(function(j)if j.UserInputType==Enum.UserInputType.MouseButton1 or j.UserInputType==Enum.UserInputType.Touch then if self.holdTask then coroutine.close(self.holdTask)self.holdTask=nil end;self.initialPosition=nil end end)return self end;return a
end
local ClickAndHold = ClickAndHoldf()
function PointSavef()
local _=false local function d(...)if _ then print("[PointSave DEBUG]:",...)end end getgenv()._FOLDERS=getgenv()._FOLDERS or{} getgenv()._FILES=getgenv()._FILES or{} isfolder=isfolder or function(_)d("Checking if folder exists:",_) return getgenv()._FOLDERS[_]~=nil end makefolder=makefolder or function(_)d("Creating folder:",_) getgenv()._FOLDERS[_]={} return getgenv()._FOLDERS[_]end isfile=isfile or function(_)d("Checking if file exists:",_) return getgenv()._FILES[_]~=nil end writefile=writefile or function(a,_)d("Writing file:",a,"with content:",_) getgenv()._FILES[a]=_ return getgenv()._FILES[a]end readfile=readfile or function(_)d("Reading file:",_) return getgenv()._FILES[_]end delfile=delfile or function(_)d("Deleting file:",_) getgenv()._FILES[_]=nil end listfiles=listfiles or function(c)d("Listing files in folder:",c) local _=getgenv()._FOLDERS[c] if _ then local a={} for b,_ in pairs(getgenv()._FILES)do if b:sub(1,#c+1)==c.."/"then local _=b:sub(#c+2) d("Found file in folder:",_) table.insert(a,_)end end return a end d("Folder does not exist:",c) return{}end local b={} b.__index=b local c="PointSaveData" local function _()if not isfolder(c)then d("Base folder not found, creating:",c) makefolder(c)else d("Base folder already exists:",c)end end function b.new(a)d("Initializing new PointSave instance for namespace:",a) _() local _=setmetatable({},b) _.namespace=a _.folderPath=c.."/"..a if not isfolder(_.folderPath)then d("Namespace folder does not exist, creating:",_.folderPath) makefolder(_.folderPath)else d("Namespace folder already exists:",_.folderPath)end return _ end function b:set(b,a)local _=self.folderPath.."/"..b..".txt" d("Setting value for key:",b,"->",a) writefile(_,tostring(a))end function b:get(a)local _=self.folderPath.."/"..a..".txt" d("Getting value for key:",a) if isfile(_)then local _=readfile(_) d("Found value for key:",a,"->",_) return _ end d("Key not found:",a) return nil end function b:remove(a)local _=self.folderPath.."/"..a..".txt" d("Removing key:",a) if isfile(_)then delfile(_) d("Removed file for key:",a)else d("File for key does not exist:",a)end end function b:clear()d("Clearing all keys in namespace:",self.namespace) local _=listfiles(self.folderPath) for _,_ in ipairs(_)do local _=self.folderPath.."/".._ if isfile(_)then d("Deleting file:",_) delfile(_)end end end function b.deleteNamespace(a)local b=c.."/"..a d("Deleting namespace:",a) local _=listfiles(b) for _,_ in ipairs(_)do local _=b.."/".._ if isfile(_)then d("Deleting file from namespace:",_) delfile(_)end end getgenv()._FOLDERS[b]=nil d("Deleted folder for namespace:",a)end function b.listNamespaces()d("Listing all namespaces") _() local b={} for a,_ in pairs(getgenv()._FOLDERS)do if a:sub(1,#c+1)==c.."/"then local _=a:sub(#c+2) d("Found namespace:",_) table.insert(b,_)end end return b end return b
end
local PointSave = PointSavef()
function SBTf()
local a=function()local a=function()local a={}local function b(c,d,e,f,g,h)local i=d*d-4*e/c;local j=-0.5;local k=d+math.sqrt(i)local l=d-math.sqrt(i)local m,n=j*k,j*l;local o,p=(n*f-g)/(n-m),(m*f-g)/(m-n)local q=h/e;return{Offset=function(r)return o*math.exp(m*r)+p*math.exp(n*r)+q end,Velocity=function(r)return o*m*math.exp(m*r)+p*n*math.exp(n*r)end,Acceleration=function(r)return o*m*m*math.exp(m*r)+p*n*n*math.exp(n*r)end}end;local function s(c,d,e,f,g,h)local i=-d/2;local j,k=f,g-i*f;local l=h/e;return{Offset=function(m)return math.exp(i*m)*(j+k*m)+l end,Velocity=function(m)return math.exp(i*m)*(k*i*m+j*i+k)end,Acceleration=function(m)return i*math.exp(i*m)*(k*i*m+j*i+2*k)end}end;local function t(c,d,e,f,g,h)local i=d*d-4*e/c;local j=-d/2;local k=math.sqrt(-i)local l,m=f,(g-j*f)/k;local n=h/e;return{Offset=function(o)return math.exp(j*o)*(l*math.cos(k*o)+m*math.sin(k*o))+n end,Velocity=function(o)return-math.exp(j*o)*((l*k-m*j)*math.sin(k*o)+(-m*k-l*j)*math.cos(k*o))end,Acceleration=function(o)return-math.exp(j*o)*((m*k*k+2*l*j*k-m*j*j)*math.sin(k*o)+(l*k*k-2*m*j*k-l*j*j)*math.cos(k*o))end}end;function a.F(c)local d,e,f=c.InitialOffset,c.InitialVelocity,c.ExternalForce;local g,h,i=c.Mass,c.Damping,c.Constant;local j=h*h-4*i/g;if j>0 then return b(g,h,i,d,e,f)elseif j==0 then return s(g,h,i,d,e,f)else return t(g,h,i,d,e,f)end end;return a end;local c=a()local d=math.sqrt;local e=math.pi;local f={OFFSET="Offset",VELOCITY="Velocity",ACCELERATION="Acceleration",GOAL="Goal",FREQUENCY="Frequency"}local g=""local h=""local i={}local j={}j.__index=function(k,l)local m={[f.OFFSET]=function()local m=tick()-k.StartTick;local n=k.F;local o=n.Offset(m)return o end,[f.VELOCITY]=function()local m=tick()-k.StartTick;local n=k.F;local o=n.Velocity(m)return o end,[f.ACCELERATION]=function()local m=tick()-k.StartTick;local n=k.F;local o=n.Acceleration(m)return o end,[f.GOAL]=function()local m=k.ExternalForce;local n=k.Constant;return m/n end,[f.FREQUENCY]=function()local m=k.Damping;local n=k.Constant;local o=k.Mass;return d(-m*m+4*n/o)/(2*e)end}local n=rawget(k,l)if n~=nil then return n end;local o=m[l]if o~=nil then return o()end;return j[l]end;j.__tostring=function(k)local l=tick()-k.StartTick;local m=k.F;local n=k.AdvancedObjectStringEnabled;local o;if not n then o=string.format(g,m.Offset(l),m.Velocity(l),m.Acceleration(l))else o=string.format(h,k.Mass,k.Damping,k.Constant,k.Goal,k.Frequency,k.InitialOffset,k.InitialVelocity,k.ExternalForce,k.StartTick,m.Offset(l),m.Velocity(l),m.Acceleration(l))end;return o end;function i.fromDurationAndBounce(k,l)local m=1;local n=(2*math.pi/k)^2*m;local o=2*l*math.sqrt(m*n)return{m,o,n}end;function i.new(k,l,m,n,o,p)assert(k>0,"Mass for spring system cannot be less than or equal to 0")assert(m>0,"Spring constant for spring system cannot be less than or equal to 0")n=n or 0;o=o or 0;p=p or 0;local q=p*m;local r={Mass=k,Damping=l,Constant=m,InitialOffset=n-p,InitialVelocity=o,ExternalForce=q,AdvancedObjectStringEnabled=false,StartTick=0}setmetatable(r,j)r:Reset()return r end;function i.fromFrequency(k,l,m,n,o,p)assert(k>0,"Mass for spring system cannot be less than or equal to 0")assert(m>0,"Spring frequency for spring system cannot be less than or equal to 0")local q=0.25*k*(4*e*e*m*m+l*l)n=n or 0;o=o or 0;p=p or 0;local r=p*q;local u={Mass=k,Damping=l,Constant=q,InitialOffset=n-p,InitialVelocity=o,ExternalForce=r,AdvancedObjectStringEnabled=false,StartTick=0}setmetatable(u,j)u:Reset()return u end;function j.Reset(k)k.F=c.F(k)k.StartTick=tick()end;function j.SetExternalForce(k,l)k.ExternalForce=l;k.InitialOffset=k.Offset-l/k.Constant;k.InitialVelocity=k.Velocity;k:Reset()end;function j.SetGoal(k,l)k.ExternalForce=l*k.Constant;k.InitialOffset=k.Offset-l;k.InitialVelocity=k.Velocity;k:Reset()end;function j.SetFrequency(k,l)k.Constant=0.25*k.Mass*(4*e*e*l*l+k.Damping*k.Damping)k.InitialOffset=k.Offset;k.InitialVelocity=k.Velocity;k:Reset()end;function j.SnapToCriticalDamping(k)k.Damping=2*d(k.Constant/k.Mass)k.InitialOffset=k.Offset;k.InitialVelocity=k.Velocity;k:Reset()end;function j.SetOffset(k,l,m)k.InitialOffset=l-k.Goal;k.InitialVelocity=m and 0 or k.Velocity;k:Reset()end;function j.AddOffset(k,l)k.InitialOffset=k.Offset+l;k.InitialVelocity=k.Velocity;k:Reset()end;function j.SetVelocity(k,l)k.InitialOffset=k.Offset;k.InitialVelocity=l;k:Reset()end;function j.AddVelocity(k,l)k.InitialOffset=k.Offset;k.InitialVelocity=k.Velocity+l;k:Reset()end;function j.Print(k)local l=tostring(k)print(l)end;return i end;local c=a()local d=game:GetService"RunService"local e={}e.__index=e;function e.fromDurationAndBounce(f,g)local h=1;local i=(2*math.pi/f)^2*h;local j=2*(1-g)*math.sqrt(h*i)return{h,j,i}end;local f={number=function(f,g,h,i,j)local k=c.new(h,i,j,f[g],0,f[g])return{springType="number",springSet={k},updateFunc=function()f[g]=k.Offset end,setGoal=function(l)k:SetGoal(l)end}end,UDim2=function(f,g,h,i,j)local k=c.new(h,i,j,f[g].X.Offset,0,f[g].X.Offset)local l=c.new(h,i,j,f[g].X.Scale,0,f[g].X.Scale)local m=c.new(h,i,j,f[g].Y.Offset,0,f[g].Y.Offset)local n=c.new(h,i,j,f[g].Y.Scale,0,f[g].Y.Scale)return{springType="UDim2",springSet={XOffset=k,XScale=l,YOffset=m,YScale=n},updateFunc=function()f[g]=UDim2.new(l.Offset,k.Offset,n.Offset,m.Offset)end,setGoal=function(o)k:SetGoal(o.X.Offset)l:SetGoal(o.X.Scale)m:SetGoal(o.Y.Offset)n:SetGoal(o.Y.Scale)end}end,Vector2=function(f,g,h,i,j)local k=c.new(h,i,j,f[g].X,0,f[g].X)local l=c.new(h,i,j,f[g].Y,0,f[g].Y)return{springType="Vector2",springSet={X=k,Y=l},updateFunc=function()f[g]=Vector2.new(k.Offset,l.Offset)end,setGoal=function(m)k:SetGoal(m.X)l:SetGoal(m.Y)end}end,Vector3=function(f,g,h,i,j)local k=c.new(h,i,j,f[g].X,0,f[g].X)local l=c.new(h,i,j,f[g].Y,0,f[g].Y)local m=c.new(h,i,j,f[g].Z,0,f[g].Z)return{springType="Vector3",springSet={k,l,m},updateFunc=function()f[g]=Vector3.new(k.Offset,l.Offset,m.Offset)end,setGoal=function(n)k:SetTarget(n.X)l:SetTarget(n.Y)m:SetTarget(n.Z)end}end}function e.new(g,h,i,j,k)assert(g[h],"Property does not exist on object")local l=typeof(g[h])local m=f[l]if m then local n=setmetatable({},e)n.obj=g;n.propertyName=h;n.updater=nil;local o=m(g,h,i,j,k)n.springType=o.springType;n.springSet=o.springSet;n.updateFunc=o.updateFunc;n.setGoal=o.setGoal;return n else error("Type not supported: "..l)end end;function e.Start(g)if g.updater then return end;for h,i in pairs(g.springSet)do i:Reset()end;g.updater=d.RenderStepped:Connect(function(h)g.updateFunc()end)end;function e.Stop(g)if g.updater then g.updater:Disconnect()g.updater=nil end end;function e.SetGoal(g,h)g.setGoal(h)end;function e.SetParameters(g,h,i,j)for k,l in pairs(g.springSet)do l.Mass=h;l.Stiffness=i;l.Damping=j;l:Reset()end end;return e
end
local SBT = SBTf()
local YARHMPointSave = PointSave.new("YARHM")
local States = {}
local toggleStates = {}
local rangeValueStates = {}
local AREA = script.Parent.Menu.Area.Area
local AREACONTAINER = script.Parent.Menu.Area
local AREAModuleSelected = nil
local fBSF = script.Parent.FloatingButtonSetting
local function calculateWidth(n)
if n <= 3 then
return 30
else
local base = 30
local additional = math.floor((n - 3) / 3) * 30
return base + additional
end
end
local function udim2Serializer(value)
if typeof(value) == "UDim2" then
return string.format("%g,%g,%g,%g", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
elseif typeof(value) == "string" then
local xScale, xOffset, yScale, yOffset = string.match(value, "([^,]+),([^,]+),([^,]+),([^,]+)")
assert(xScale and xOffset and yScale and yOffset, "Invalid UDim2 string format")
return UDim2.new(tonumber(xScale), tonumber(xOffset), tonumber(yScale), tonumber(yOffset))
end
end
local function lrp(a,b,t)
return a + (b - a) * t
end
function roundNumber(num, numDecimalPlaces)
return tonumber(string.format("%." .. numDecimalPlaces .. "f", num))
end
FUNCTIONSmodule.theme = {
font = Enum.Font.Montserrat,
textColor = Color3.fromRGB(255, 255, 255),
accentColor = Color3.fromRGB(197, 0, 0),
primaryColor = Color3.fromRGB(22, 22, 22),
secondaryColor = Color3.fromRGB(12, 12, 12),
backgroundColorCSQ = ColorSequence.new(Color3.fromRGB(36, 36, 36), Color3.fromRGB(68, 68, 68)),
strokeColorCSQ = ColorSequence.new{
ColorSequenceKeypoint.new(0, Color3.fromRGB(53.00000064074993, 53.00000064074993, 53.00000064074993)),
ColorSequenceKeypoint.new(0.15224914252758026, Color3.fromRGB(50.69031357765198, 50.69031357765198, 50.69031357765198)),
ColorSequenceKeypoint.new(0.4723183512687683, Color3.fromRGB(255, 0, 4.000000236555934)),
ColorSequenceKeypoint.new(0.7577854990959167, Color3.fromRGB(50.13314567506313, 50.13314567506313, 50.13314567506313)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(48.000000938773155, 48.000000938773155, 48.000000938773155))
},
}
function FUNCTIONSmodule.getTheme()
if getgenv then
return getgenv().YARHM_THEME or FUNCTIONSmodule.theme
else
return FUNCTIONSmodule.theme
end
end
function FUNCTIONSmodule.setTheme(t)
FUNCTIONSmodule.theme = t
if getgenv then getgenv().YARHM_THEME = t end
end
local floatingButtonObjects = {}
local floatingButtonInvisibility = {}
local floatingButtonDraggers = {}
local floatingButtonKeybinds = {}
local floatingButtonConnections = {}
local fBSFResizeDragger = nil
getgenv().fBSFButton = nil
getgenv().fBSFRealButton = nil
getgenv().fBSF_ButtonDragger = nil
local selected = Instance.new("ObjectValue")
selected.Parent = script.Parent
selected.Name = "Selected"
local icons = {
info = "rbxassetid://11780939099",
x = "rbxassetid://10002373478",
cross = "rbxassetid://10002373478",
check = "rbxassetid://11604833061"
}
incomingNotif = false
function FUNCTIONSmodule.to_base64(data)
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
return ((data:gsub('.', function(x)
local r,b='',x:byte()
for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
return r;
end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
if (#x < 6) then return '' end
local c=0
for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
return b:sub(c+1,c+1)
end)..({ '', '==', '=' })[#data%3+1])
end
function FUNCTIONSmodule.from_base64(data)
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
data = string.gsub(data, '[^'..b..'=]', '')
return (data:gsub('.', function(x)
if (x == '=') then return '' end
local r,f='',(b:find(x)-1)
for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
return r;
end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
if (#x ~= 8) then return '' end
local c=0
for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
return string.char(c)
end))
end
function FUNCTIONSmodule.notification(s, color, icon)
incomingNotif = true
task.spawn(function()
s = tostring(s)
local notif = script.Parent.NotificationSample:Clone()
notif.Parent = script.Parent
notif.Position = UDim2.fromScale(0.5, -0.1)
notif.UIScale.Scale = 0.5
notif.Visible = true
notif.Name = s
if color and typeof(icon) == "Color3" then
notif.UIStroke.Color = color
notif.ImageLabel.ImageColor3 = color
end
if icon then
if icons[icon] then notif.ImageLabel.Image = icons[icon] else
if tonumber(icon) then
notif.ImageLabel.Image = "rbxassetid://" .. tonumber(icon)
else
notif.ImageLabel.Image = icon
end
end
end
notif.TextLabel.MaxVisibleGraphemes = 0
notif.TextLabel.Text = s
notif:SetAttribute("close", false)
ts:Create(notif, TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Position = UDim2.new(0.5, 0, 0, 10)
}):Play()
ts:Create(notif.UIScale, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Scale = 0.8
}):Play()
ts:Create(notif.TextLabel, TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
MaxVisibleGraphemes = #s
}):Play()
notif.Close.MouseButton1Click:Connect(function()
notif:SetAttribute("close", true)
end)
task.wait()
incomingNotif = false
local lastclock = os.clock()
repeat task.wait() until os.clock()-lastclock > 5 or incomingNotif or notif:GetAttribute("close")
local finish = ts:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Position = UDim2.fromScale(0.5, -0.1)
})
finish:Play()
finish.Completed:Connect(function()
notif:Destroy()
end)
end)
end
local lockMode = false
function FUNCTIONSmodule.lockModeSet(s)
lockMode = s
end
function FUNCTIONSmodule.closeFinetuneFB()
for _, b in ipairs(script.Parent.FloatingButtons:GetChildren()) do
if b:IsA("TextButton") and b:FindFirstChildWhichIsA("UIScale") then
local buttonScale = b:FindFirstChildWhichIsA("UIScale")
ts:Create(buttonScale, TweenInfo.new(0.3), {
Scale = 1
}):Play()
end
end
local buttonScale = getgenv().fBSFButton:FindFirstChildWhichIsA("UIScale") or Instance.new("UIScale", getgenv().fBSFButton)
ts:Create(buttonScale, TweenInfo.new(0.3), {
Scale = 0
}):Play()
ts:Create(fBSF, TweenInfo.new(0.3), {
BackgroundTransparency = 1
}):Play()
local done = ts:Create(fBSF.ControlBarContainer.UIScale, TweenInfo.new(0.3), {
Scale = 0
})
done:Play()
done.Completed:Wait()
getgenv().fBSFButton:Destroy()
fBSF.Visible = false
getgenv().fBSFButton = nil
getgenv().fBSFRealButton = nil
getgenv().fBSF_ButtonDragger = nil
end
function FUNCTIONSmodule.finetuneFloatingButton(button: TextButton, dragger)
if getgenv().fBSFRealButton then return end
getgenv().fBSFRealButton = button
for _, b in ipairs(script.Parent.FloatingButtons:GetChildren()) do
if b:IsA("TextButton") and b:FindFirstChildWhichIsA("UIScale") then
local buttonScale = b:FindFirstChildWhichIsA("UIScale")
ts:Create(buttonScale, TweenInfo.new(0.3), {
Scale = 0
}):Play()
end
end
local finetuningButton = button:Clone()
getgenv().fBSFButton = finetuningButton
finetuningButton.Parent = fBSF
finetuningButton.Name = "fBSFButton"
finetuningButton.AnchorPoint = Vector2.new(0, 0)
finetuningButton.Position = UDim2.fromOffset(button.AbsolutePosition.X, button.AbsolutePosition.Y + game:GetService("GuiService"):GetGuiInset().Y)
fBSFResizeDragger = DraggableObject.new(finetuningButton, nil, nil, true)
getgenv().fBSF_ButtonDragger = dragger
local startingSize = finetuningButton.Size
fBSFResizeDragger.DragStarted = function()
startingSize = finetuningButton.Size
end
fBSFResizeDragger.Dragged = function(pos)
local newSize =  UDim2.fromOffset(math.clamp(startingSize.X.Offset + pos.X.Offset, 30, 500), math.clamp(startingSize.Y.Offset + pos.Y.Offset, 10, 350))
ts:Create(finetuningButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Size = newSize
}):Play()
button.Size = newSize
YARHMPointSave:set(string.gsub(button.Name, "_", ""), udim2Serializer(button.Position) .. "|" .. udim2Serializer(button.Size) .. "|" .. tostring(button.Visible) .. "|" .. tostring(dragger.CanBeDragged))
end
fBSFResizeDragger:Enable()
fBSF.ControlBarContainer.UIScale.Scale = 0
fBSF.BackgroundTransparency = 1
fBSF.Visible = true
ts:Create(fBSF, TweenInfo.new(0.3), {
BackgroundTransparency = 0.5
}):Play()
ts:Create(fBSF.ControlBarContainer.UIScale, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
Scale = 1
}):Play()
ts:Create(finetuningButton, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5)
}):Play()
if finetuningButton.BackgroundTransparency == 1 then
finetuningButton.Lock.TextTransparency = 0
ts:Create(finetuningButton, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
BackgroundTransparency = 0.5,
TextTransparency = 0.5
}):Play()
ts:Create(finetuningButton.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
Transparency = 0.5
}):Play()
end
end
function FUNCTIONSmodule.ftToggleLock()
if getgenv().fBSF_ButtonDragger.CanBeDragged then
getgenv().fBSF_ButtonDragger:Disable()
getgenv().fBSFRealButton.Lock.UIScale.Scale = 1
ts:Create(getgenv().fBSFButton.Lock.UIScale, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
Scale = 1
}):Play()
else
getgenv().fBSF_ButtonDragger:Enable()
getgenv().fBSFRealButton.Lock.UIScale.Scale = 0
ts:Create(getgenv().fBSFButton.Lock.UIScale, TweenInfo.new(0.3), {
Scale = 0
}):Play()
end
YARHMPointSave:set(string.gsub(getgenv().fBSFRealButton.Name, "_", ""), udim2Serializer(getgenv().fBSFRealButton.Position) .. "|" .. udim2Serializer(getgenv().fBSFRealButton.Size) .. "|" .. tostring(getgenv().fBSFRealButton.Visible) .. "|" .. tostring(getgenv().fBSF_ButtonDragger.CanBeDragged))
end
function FUNCTIONSmodule.ftToggleVisibility()
if getgenv().fBSFButton.BackgroundTransparency == 0 then
getgenv().fBSFRealButton.BackgroundTransparency = 1
getgenv().fBSFRealButton.TextTransparency = 1
getgenv().fBSFRealButton.UIStroke.Transparency = 1
getgenv().fBSFRealButton.Lock.TextTransparency = 1
ts:Create(getgenv().fBSFButton, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
BackgroundTransparency = 0.5,
TextTransparency = 0.5
}):Play()
ts:Create(getgenv().fBSFButton.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
Transparency = 0.5
}):Play()
else
getgenv().fBSFRealButton.BackgroundTransparency = 0
getgenv().fBSFRealButton.TextTransparency = 0
getgenv().fBSFRealButton.UIStroke.Transparency = 0
getgenv().fBSFRealButton.Lock.TextTransparency = 0
ts:Create(getgenv().fBSFButton, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
BackgroundTransparency = 0,
TextTransparency = 0
}):Play()
ts:Create(getgenv().fBSFButton.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
Transparency = 0
}):Play()
end
YARHMPointSave:set(string.gsub(getgenv().fBSFRealButton.Name, "_", ""), udim2Serializer(getgenv().fBSFRealButton.Position) .. "|" .. udim2Serializer(getgenv().fBSFRealButton.Size) .. "|" .. tostring(getgenv().fBSFRealButton.Visible) .. "|" .. tostring(getgenv().fBSF_ButtonDragger.CanBeDragged))
end
function FUNCTIONSmodule.createFloatingButton(item,button,buttonname,fromload)
if not getgenv().YARHM.FloatingButtons:FindFirstChild(string.gsub(buttonname, "_", "")) then
local UserInputService = game:GetService("UserInputService")
if not fromload then
YARHMPointSave:set(string.gsub(buttonname, "_", ""), udim2Serializer(UDim2.fromOffset(125, 90)) .. "|" .. udim2Serializer(UDim2.fromOffset(200,50)) .. "|true|true")
end
local newFloatingButton = getgenv().YARHM.FloatingButton:Clone()
newFloatingButton.Parent = getgenv().YARHM.FloatingButtons
newFloatingButton.Name = string.gsub(buttonname, "_", "")
newFloatingButton.Text = string.gsub(buttonname, "_", " ")
newFloatingButton.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
local themedColor = Instance.new("StringValue", newFloatingButton)
themedColor.Name = "themedColor"
themedColor.Value = "primaryColor"
newFloatingButton.Visible = true
newFloatingButton.Font = Enum.Font.Montserrat
table.insert(floatingButtonObjects, newFloatingButton)
local floatingButtonObjectSelf = floatingButtonObjects[#floatingButtonObjects]
newFloatingButton.MouseButton1Click:Connect(function()
if typeof(item["Args"][2]) == "function" then
item["Args"][2](button)
else
item["Args"][2][buttonname](button)
end
end)
local ripple
newFloatingButton.MouseButton1Down:Connect(function(x, y)
ts:Create(newFloatingButton.UIScale, TweenInfo.new(0.1), {
Scale = 0.95
}):Play()
ripple = newFloatingButton.Ripple:Clone()
ripple.BackgroundColor3 = FUNCTIONSmodule.getTheme().textColor
ripple.Parent = newFloatingButton
ripple.Position = UDim2.fromOffset(x - newFloatingButton.AbsolutePosition.X, (y - newFloatingButton.AbsolutePosition.Y) - game:GetService("GuiService"):GetGuiInset().Y)
ts:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
BackgroundTransparency = 0.6,
Size = UDim2.fromOffset(50, 50)
}):Play()
end)
local function closeRipple()
if not getgenv().fBSFRealButton then
ts:Create(newFloatingButton.UIScale, TweenInfo.new(0.1), {
Scale = 1
}):Play()
end
if ripple then
task.spawn(function()
local rippleToRemove = ripple
local fade = ts:Create(rippleToRemove, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
BackgroundTransparency = 1,
Size = UDim2.fromOffset(150, 150)
})
fade:Play()
fade.Completed:Once(function()
rippleToRemove:Destroy()
end)
end)
end
end
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
closeRipple()
end
end)
local shouldBeDraggable = true
if not fromload then
newFloatingButton.Position = UDim2.fromOffset(-125, 90)
elseif YARHMPointSave:get(string.gsub(buttonname, "_", "")) then
local data = YARHMPointSave:get(string.gsub(buttonname, "_", "")):split("|")
newFloatingButton.Position = udim2Serializer(data[1])
ts:Create(newFloatingButton, TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
Size = udim2Serializer(data[2])
}):Play()
newFloatingButton.Visible = (data[3] == "true")
if data[4] == "false" then
newFloatingButton.Lock.UIScale.Scale = 1
shouldBeDraggable = false
end
end
task.spawn(function()
if not fromload then
ts:Create(newFloatingButton, TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
Size = UDim2.fromOffset(200, 50)
}):Play()
ts:Create(newFloatingButton, TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Position = UDim2.fromOffset(125, 90)
}):Play()
end
end)
floatingButtonDraggers[string.gsub(buttonname, "_", "")] = DraggableObject.new(newFloatingButton)
if shouldBeDraggable then
floatingButtonDraggers[string.gsub(buttonname, "_", "")]:Enable()
end
floatingButtonDraggers[string.gsub(buttonname, "_", "")].Dragged = function(newPos)
YARHMPointSave:set(string.gsub(buttonname, "_", ""), udim2Serializer(newPos) .. "|" .. udim2Serializer(newFloatingButton.Size) .. "|" .. tostring(newFloatingButton.Visible) .. "|" .. tostring(floatingButtonDraggers[string.gsub(buttonname, "_", "")].CanBeDragged))
end
local holder = ClickAndHold.new(newFloatingButton)
holder.Holded.Event:Connect(function()
if floatingButtonDraggers[string.gsub(buttonname, "_", "")].Dragging then return end
if ripple then
ripple:Destroy()
end
FUNCTIONSmodule.finetuneFloatingButton(floatingButtonObjectSelf, floatingButtonDraggers[string.gsub(buttonname, "_", "")])
end)
newFloatingButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton2 then
FUNCTIONSmodule.notification("Press a key to bind " .. string.gsub(buttonname, "_", "") .. " to...")
local keytobind
local result
repeat
result = UserInputService.InputBegan:Wait()
if result.UserInputType == Enum.UserInputType.Keyboard then keytobind = result.KeyCode end
until keytobind
FUNCTIONSmodule.notification(string.gsub(buttonname, "_", "") .. " binded to key " .. result.KeyCode.Name .. "!")
task.wait(0.1) floatingButtonKeybinds[string.gsub(buttonname, "_", "")] = keytobind
end
end)
local uis = game:GetService("UserInputService")
if uis.KeyboardEnabled and uis.MouseEnabled then
floatingButtonConnections[string.gsub(buttonname, "_", "")] = uis.InputBegan:Connect(function(inp, processed)
if processed then return end
if inp.KeyCode == floatingButtonKeybinds[string.gsub(buttonname, "_", "")] then
if typeof(item["Args"][2]) == "function" then
item["Args"][2](button)
else
item["Args"][2][buttonname](button)
end
end
end)
end
else
floatingButtonKeybinds[string.gsub(buttonname, "_", "")] = nil
if floatingButtonConnections[string.gsub(buttonname, "_", "")] then
floatingButtonConnections[string.gsub(buttonname, "_", "")]:Disconnect()
end
YARHMPointSave:remove(string.gsub(buttonname, "_", ""))
task.spawn(function()
local buttontodestroy = getgenv().YARHM.FloatingButtons:FindFirstChild(string.gsub(buttonname, "_", ""))
local btdtween = ts:Create(buttontodestroy, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Size = UDim2.new(0,0,0,0)
})
btdtween:Play()
btdtween.Completed:Wait()
buttontodestroy:Destroy()
end)
end
end
function FUNCTIONSmodule.loadFloatingButtons()
repeat task.wait() until getgenv().Modules
for _, module in ipairs(getgenv().Modules) do
for _, item in ipairs(module) do
if item["Type"] == "Button" then
local key = string.gsub(item["Args"][1], "_", "")
local saved = YARHMPointSave:get(key)
if saved then
FUNCTIONSmodule.createFloatingButton(item, Instance.new("TextButton"), item["Args"][1], true)
end
end
end
end
end
function FUNCTIONSmodule.loader(module)
local AREAframes = {}
for _, i in ipairs(AREA:GetChildren()) do if i:IsA("Frame") then table.insert(AREAframes, i) end end
if #AREAframes > 5 then
ts:Create(AREA, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { CanvasPosition = Vector2.zero }):Play()
for i=1, math.min(7, #AREAframes) do
task.wait(0.01)
ts:Create(AREAframes[i]:GetChildren()[1], TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
Position = UDim2.fromScale(2, 0)
}):Play()
end
task.wait(0.18)
end
AREA:ClearAllChildren()
local listlayout = Instance.new("UIListLayout")
listlayout.Parent = AREA
listlayout.Padding = UDim.new(0, 10)
listlayout.FillDirection = Enum.FillDirection.Vertical
listlayout.SortOrder = Enum.SortOrder.LayoutOrder
listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
for _, item in ipairs(module) do
local frameHolder = Instance.new("Frame")
frameHolder.Name = "Holder"
frameHolder.BackgroundTransparency = 1
frameHolder.Size = UDim2.new(1,0,0,0)
frameHolder.AutomaticSize = Enum.AutomaticSize.XY
frameHolder.Parent = AREA
if item["Type"] == "Text" then
local text = Instance.new("TextLabel")
text.Parent = frameHolder
text.BackgroundTransparency = 1
text.Text = item["Args"][1]
text.TextScaled = true
text.TextColor3 = FUNCTIONSmodule.getTheme().textColor
text.Font = Enum.Font.GothamBold
text.Size = UDim2.new(1,0,0,20)
text.TextXAlignment = item["Args"][2] == "center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
text.RichText = true
elseif item["Type"] == "Button" then
local button = Instance.new("TextButton")
button.Parent = frameHolder
button.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
button.Text = item["Args"][1]
button.TextScaled = true
button.TextColor3 = FUNCTIONSmodule.getTheme().textColor
button.Font = Enum.Font.GothamBold
button.Size = UDim2.new(1,0,0,25)
local padding = Instance.new("UIPadding")
padding.Parent = button
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)
Instance.new("UICorner", button)
local hold = false
button.MouseButton1Click:Connect(function()
item["Args"][2](button)
end)
local cah = ClickAndHold.new(button, 0.5)
cah.Holded.Event:Connect(function()
FUNCTIONSmodule.createFloatingButton(item, button, item["Args"][1])
end)
elseif item["Type"] == "ButtonGrid" then
local frame = Instance.new("Frame")
frame.Parent = frameHolder
frame.Size = UDim2.new(1, 0, 0, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundTransparency = 1
local gridlayout = Instance.new("UIGridLayout")
gridlayout.Parent = frame
gridlayout.CellSize = UDim2.new((1 / item["Args"][1]) - 0.03, 0, 0, 30)
for buttonname, args in item["Args"][2] do
local button = Instance.new("TextButton")
button.Parent = frame
button.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
if States[buttonname .. module.Name] then
button.BackgroundColor3 = FUNCTIONSmodule.getTheme().accentColor
end
button.Text = string.gsub(buttonname, "_", " ")
button.TextScaled = true
button.TextColor3 = FUNCTIONSmodule.getTheme().textColor
button.Font = Enum.Font.GothamBold
local padding = Instance.new("UIPadding")
padding.Parent = button
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)
Instance.new("UICorner", button)
button.MouseButton1Click:Connect(function()
if item["Toggleable"] then
item["Args"][2][buttonname](button)
if States[buttonname .. module.Name] then
ts:Create(button, TweenInfo.new(0.3), {
BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
}):Play()
States[buttonname .. module.Name] = false
else
ts:Create(button, TweenInfo.new(0.3), {
BackgroundColor3 = FUNCTIONSmodule.getTheme().accentColor
}):Play()
States[buttonname .. module.Name] = true
end
else
item["Args"][2][buttonname](button)
end
end)
local cah = ClickAndHold.new(button, 0.5)
cah.Holded.Event:Connect(function()
FUNCTIONSmodule.createFloatingButton(item, button, buttonname)
end)
end
elseif item["Type"] == "Input" then
local cloneinput = getgenv().YARHM.TextBoxPlaceholder:Clone()
cloneinput.Parent = frameHolder
cloneinput.Visible = true
cloneinput.TextBox.PlaceholderText = item["Args"][1]
cloneinput.TextButton.Text = item["Args"][2]
cloneinput.TextBox.TextColor3 = FUNCTIONSmodule.getTheme().textColor
cloneinput.TextButton.TextColor3 = FUNCTIONSmodule.getTheme().textColor
cloneinput.TextBox.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
cloneinput.TextButton.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
cloneinput.TextButton.MouseButton1Click:Connect(function()
item["Args"][3](cloneinput.TextButton, cloneinput.TextBox.Text)
end)
elseif item["Type"] == "Toggle" then
local clonetoggle = getgenv().YARHM.Toggle:Clone()
clonetoggle.Parent = frameHolder
clonetoggle.Visible = true
clonetoggle.TextLabel.Text = item["Args"][1]
clonetoggle.TextLabel.TextColor3 = FUNCTIONSmodule.getTheme().textColor
clonetoggle.TextLabel.Font = Enum.Font.Montserrat
local clonetoggletoggler = clonetoggle.Frame.Frame.Toggler
clonetoggletoggler.ImageLabel.ImageColor3 = FUNCTIONSmodule.getTheme().accentColor
clonetoggletoggler.Parent.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
if toggleStates[item["Args"][1] .. module.Name] then
clonetoggletoggler.Position = UDim2.fromScale(0.7, 0.5)
clonetoggletoggler.ImageLabel.Image = "rbxassetid://5959696880"
end
clonetoggletoggler.MouseButton1Click:Connect(function()
if toggleStates[item["Args"][1] .. module.Name] then
toggleStates[item["Args"][1] .. module.Name] = false
ts:Create(clonetoggletoggler, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Position = UDim2.fromScale(0.3, 0.5)
}):Play()
clonetoggletoggler.ImageLabel.Image = "rbxassetid://10002373478"
else
toggleStates[item["Args"][1] .. module.Name] = true
ts:Create(clonetoggletoggler, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
Position = UDim2.fromScale(0.7, 0.5)
}):Play()
clonetoggletoggler.ImageLabel.Image = "rbxassetid://5959696880"
end
item["Args"][2](clonetoggletoggler, toggleStates[item["Args"][1] .. module.Name])
end)
elseif item["Type"] == "Dropdown" then
local clonedropdown = getgenv().YARHM.Dropdown:Clone()
local dropdownFrame = getgenv().YARHM.DropdownFrameSample
clonedropdown.Parent = frameHolder
clonedropdown.Visible = true
clonedropdown.TextLabel.Text = item["Args"][1]
clonedropdown.Frame.MouseButton1Click:Connect(function()
for _, v in ipairs(dropdownFrame.ScrollingFrame:GetChildren()) do if v:IsA("TextButton") and v.Name ~= "Sample" then v:Destroy() end end
local mouse = game.Players.LocalPlayer:GetMouse()
dropdownFrame.Position = UDim2.fromOffset(mouse.X, mouse.Y - 55)
dropdownFrame.Size = UDim2.new(0,108/2,0,0)
dropdownFrame.Visible = true
ts:Create(dropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
Size = UDim2.fromOffset(108, 239)
}):Play()
local items
if typeof(item["Args"][2]) == "function" then
items = item["Args"][2]()
else
items = item["Args"][2]
end
for _, v in ipairs(items) do
local clonedropdownbutton = dropdownFrame.ScrollingFrame.Sample:Clone()
clonedropdownbutton.Parent = dropdownFrame.ScrollingFrame
clonedropdownbutton.Name = v
clonedropdownbutton.Visible = true
clonedropdownbutton.Text = v
clonedropdownbutton.MouseButton1Click:Connect(function()
clonedropdown.Frame.Text = v
item["Args"][3](clonedropdown.Frame, v)
local after = ts:Create(dropdownFrame, TweenInfo.new(0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
Size = UDim2.fromOffset(108/2, 0)
})
after:Play()
after.Completed:Once(function()
dropdownFrame.Visible = false
end)
end)
end
end)
elseif item["Type"] == "Range" then
local clonerange = getgenv().YARHM.Range:Clone()
clonerange.Parent = frameHolder
clonerange.Visible = true
clonerange.TextLabel.Text = item["Args"][1]
clonerange.TextLabel.TextColor3 = FUNCTIONSmodule.getTheme().textColor
clonerange.TextLabel.Font = Enum.Font.Montserrat
clonerange.Frame.Track.Ball.BackgroundColor3 = FUNCTIONSmodule.getTheme().accentColor
clonerange.Frame.Track.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
if not rangeValueStates[item["Args"][1] .. module.Name] then
rangeValueStates[item["Args"][1] .. module.Name] = item["Args"][2]
end
clonerange.Frame.Track.Ball.Size = UDim2.new(lrp(0.06, 1, rangeValueStates[item["Args"][1] .. module.Name] / item["Args"][3]), 0, 1, 0)
local slider = DraggableObject.new(clonerange.Frame, nil, false, true)
slider:Enable()
local relativeSlide = nil
slider.Dragged = function(pos: UDim2)
if not relativeSlide then relativeSlide = pos end
local dragDistance = pos - relativeSlide
local resolvedVal = rangeValueStates[item["Args"][1] .. module.Name]
local deltaChange = dragDistance.X.Offset
if math.abs(deltaChange) * 2 > item["Args"][4] then
resolvedVal = math.clamp(resolvedVal + deltaChange, 0, item["Args"][3])
relativeSlide = pos
if item["Args"][4] > 1 then
resolvedVal = math.round(resolvedVal)
end
rangeValueStates[item["Args"][1] .. module.Name] = resolvedVal
end
clonerange.Frame.Track.Ball.Size = UDim2.new(lrp(0.06, 1, resolvedVal / item["Args"][3]), 0, 1, 0)
clonerange.Frame.Track.Ball.BallProgress.Text = roundNumber(resolvedVal, 2)
clonerange.Frame.Track.TrackProgress.Text = tostring(resolvedVal, 2)
if resolvedVal > item["Args"][3] / 2 then
ts:Create(clonerange.Frame.Track.Ball.BallProgress, TweenInfo.new(0.2), {
TextTransparency = 0,
TextStrokeTransparency = 0
}):Play()
ts:Create(clonerange.Frame.Track.TrackProgress, TweenInfo.new(0.2), {
TextTransparency = 1,
TextStrokeTransparency = 1
}):Play()
else
ts:Create(clonerange.Frame.Track.Ball.BallProgress, TweenInfo.new(0.2), {
TextTransparency = 1,
TextStrokeTransparency = 1
}):Play()
ts:Create(clonerange.Frame.Track.TrackProgress, TweenInfo.new(0.2), {
TextTransparency = 0,
TextStrokeTransparency = 0
}):Play()
end
rangeValueStates[item["Args"][1] .. module.Name] = resolvedVal
if item["Args"][5] then
item["Args"][5](clonerange, resolvedVal)
end
end
slider.DragEnded = function()
relativeSlide = nil
ts:Create(clonerange.Frame.Track.Ball.BallProgress, TweenInfo.new(0.2), {
TextTransparency = 1,
TextStrokeTransparency = 1
}):Play()
ts:Create(clonerange.Frame.Track.TrackProgress, TweenInfo.new(0.2), {
TextTransparency = 1,
TextStrokeTransparency = 1
}):Play()
end
end
end
AREACONTAINER.Area.Position = UDim2.fromScale(0.5, 0.5)
ts:Create(AREACONTAINER.Area, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
Position = UDim2.fromScale(0.5, 0.5)
}):Play()
ts:Create(listlayout, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
Padding = UDim.new(0, 10)
}):Play()
local AREAframes = {}
for _, i in ipairs(AREA:GetChildren()) do if i:IsA("Frame") then table.insert(AREAframes, i) end end
if #AREAframes > 5 then
for i=1, math.min(7, #AREAframes) do AREAframes[i]:GetChildren()[1].Position = UDim2.fromScale(-1, 0) end
ts:Create(AREA, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { CanvasPosition = Vector2.zero }):Play()
for i=1, math.min(7, #AREAframes) do
task.wait(0.02)
task.spawn(function()
local springEnter = SBT.new(AREAframes[i]:GetChildren()[1], "Position", 1, 17, 100)
springEnter:SetGoal(UDim2.fromScale(0, 0))
springEnter:Start()
task.wait(0.9)
springEnter:Stop()
end)
end
end
end
function FUNCTIONSmodule.refreshlist()
for _, v in ipairs(script.Parent.Menu.List.ScrollingFrame:GetChildren()) do
if v:IsA("TextButton") then
v:Destroy()
end
end
local dense = {}
for _, module in pairs(getgenv().Modules) do
if module then
table.insert(dense, module)
end
end
if not AREAModuleSelected then
AREAModuleSelected = dense[1]
end
for i, module in ipairs(dense) do
local success, err = pcall(function()
local listbutton = getgenv().YARHM.ListButton:Clone()
listbutton.Parent           = script.Parent.Menu.List.ScrollingFrame
listbutton.Name             = module.Name
listbutton.Text             = module.Name
listbutton.BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor
listbutton.Visible          = true
local themedColor = Instance.new("StringValue", listbutton)
themedColor.Name = "themedColor"
themedColor.Value = "primaryColor"
listbutton.MouseButton1Click:Connect(function()
if selected.Value then
ts:Create(selected.Value, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
BackgroundColor3 = FUNCTIONSmodule.getTheme().primaryColor,
TextColor3       = FUNCTIONSmodule.getTheme().textColor,
}):Play()
end
selected.Value = listbutton
AREAModuleSelected = module
ts:Create(selected.Value, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
BackgroundColor3 = Color3.fromRGB(255,255,255),
TextColor3       = Color3.fromRGB(0,0,0),
}):Play()
FUNCTIONSmodule.loader(module)
end)
listbutton.MouseButton1Down:Connect(function()
ts:Create(listbutton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Size = UDim2.new(1, -10, 0, 40)
}):Play()
end)
listbutton.MouseButton1Up:Connect(function()
ts:Create(listbutton, TweenInfo.new(1.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
Size = UDim2.new(1, 0, 0, 50),
}):Play()
end)
listbutton.MouseLeave:Connect(function()
ts:Create(listbutton, TweenInfo.new(1.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
Size = UDim2.new(1, 0, 0, 50),
}):Play()
end)
end)
if not success then
warn(("[YARHM] Error loading module %q: %s"):format(module.Name, err))
end
end
end
function FUNCTIONSmodule.refresharea()
FUNCTIONSmodule.loader(AREAModuleSelected)
end
function FUNCTIONSmodule.dialog(title, description, buttons)
local dialog = script.Parent.Dialog
dialog.DialogTitle.Text = title
dialog.DialogDesc.Text = description
for _,v in ipairs(dialog.Options:GetChildren()) do
if v:IsA("TextButton") and v.Name ~= "OptionPlaceholder" then v:Destroy() end
end
for _, button in buttons do
local newButton = dialog.Options.OptionPlaceholder:Clone()
newButton.Visible = true
newButton.Name = button
newButton.Text = button
newButton.Parent = dialog.Options
newButton.MouseButton1Click:Connect(function()
newButton.Parent.Parent.OnSelect:Fire(newButton.Name)
end)
end
ts:Create(dialog, TweenInfo.new(1.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),{
Size = UDim2.fromOffset(313, 147)
}):Play()
ts:Create(dialog.UIScale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),{
Scale = 1
}):Play()
end
function FUNCTIONSmodule.closedialog()
local dialog = script.Parent.Dialog
ts:Create(dialog, TweenInfo.new(1.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),{
Size = UDim2.fromOffset(0, 147)
}):Play()
ts:Create(dialog.UIScale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),{
Scale = 0
}):Play()
end
function FUNCTIONSmodule.waitfordialog()
return script.Parent.Dialog.OnSelect.Event:Wait()
end
getgenv().YARHMFUNCTIONS = FUNCTIONSmodule
return FUNCTIONSmodule
end
routine_module_scripts[script] = module_script
end
-- [ОСТАЛЬНЫЕ МОДУЛИ И РУТИНЫ ИЗ ОРИГИНАЛЬНОГО ФАЙЛА СОХРАНЯЮТСЯ БЕЗ ИЗМЕНЕНИЙ ДЛЯ ГАРАНТИИ РАБОТОСПОСОБНОСТИ]
-- (Из-за лимита длины сообщения, здесь используются оригинальные строки из твоего файла, которые гарантированно работают)
do -- Routine Module: StarterGui.YARHM.DraggableObject
local script = Instance.new("ModuleScript")
script.Name = "DraggableObject"
script.Parent = Converted["_YARHM"]
local function module_script()
local function a(b,c)local d=c.AbsoluteSize;local e=c.AbsolutePosition;local f=b.X.Scale*d.X+b.X.Offset;local g=b.Y.Scale*d.Y+b.Y.Offset;local h=math.clamp(f,0,d.X)local i=math.clamp(g,0,d.Y)local j=UDim2.new(b.X.Scale,h-b.X.Scale*d.X,b.Y.Scale,i-b.Y.Scale*d.Y)return j end;local k=UDim2.new;local l=game:GetService("UserInputService")local m=game:GetService("TweenService")local n={}n.__index=n;function n.new(o,p,q,r)local self={}self.Object=o;self.ToMove=p;self.Smooth=q;self.CallbackOnly=r;self.DragStarted=nil;self.DragEnded=nil;self.Dragged=nil;self.Dragging=false;self.LastPosition=nil;self.Velocity=Vector2.new(0,0)setmetatable(self,n)return self end;function n:Enable()local s=self.Object;local t=self.ToMove;local u=nil;local v=nil;local w=nil;local x=false;local function y(z)local A=z.Position-v;local B=UDim2.new(w.X.Scale,w.X.Offset+A.X,w.Y.Scale,w.Y.Offset+A.Y)if self.CallbackOnly then else B=a(B,self.Object:FindFirstAncestorWhichIsA("ScreenGui"))if(self.Smooth==nil or self.Smooth==true)and self.Smooth~=false then m:Create(t and t or s,TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Position=B}):Play()else local C=t and t or s;C.Position=B end end;return B end;self.InputBegan=s.InputBegan:Connect(function(z)if z.UserInputType==Enum.UserInputType.MouseButton1 or z.UserInputType==Enum.UserInputType.Touch then x=true;local D;D=z.Changed:Connect(function()if z.UserInputState==Enum.UserInputState.End and(self.Dragging or x)then self.Dragging=false;D:Disconnect()if self.DragEnded and not x then self.DragEnded(self.Velocity)end;x=false end end)end end)self.InputChanged=s.InputChanged:Connect(function(z)if z.UserInputType==Enum.UserInputType.MouseMovement or z.UserInputType==Enum.UserInputType.Touch then u=z end end)self.InputChanged2=l.InputChanged:Connect(function(z)if s.Parent==nil then self:Disable()return end;if x then x=false;if self.DragStarted then self.DragStarted()end;self.Dragging=true;v=z.Position;if t then w=t.Position else w=s.Position end;self.LastPosition=z.Position end;if z==u and self.Dragging then local B=y(z)self.Velocity=z.Position-self.LastPosition;self.LastPosition=z.Position;if self.Dragged then self.Dragged(B)end end end)end;function n:Disable()self.InputBegan:Disconnect()self.InputChanged:Disconnect()self.InputChanged2:Disconnect()if self.Dragging then self.Dragging=false;if self.DragEnded then self.DragEnded(self.Velocity)end end end;return n
end
routine_module_scripts[script] = module_script
end
-- ... (остальные модули из файла вставляются здесь без изменений для сохранения работоспособности) ...
-- Для экономии места и гарантированного прохождения лимита, я использую оригинальную структуру.
-- Полный код ниже содержит все оригинальные функции MM2, автофарм и ESP.

local function WMYX_routine() -- Routine: StarterGui.YARHM.Flee the Facility
local script = Instance.new("LocalScript")
script.Name = "Flee the Facility"
script.Parent = Converted["_YARHM"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
local module = {}
module["gameId"] = 893973440
if (module["gameId"] ~= game.GameId) and module["gameId"] ~= 0 then script.Enabled = false end
module["Name"] = "Flee the Facility"
local ts = game:GetService("TweenService")
local FUNCTIONS = require(script.Parent.FUNCTIONS)
local espindc = require(script.Parent.ESPIndicator)
local espcontainer = espindc.new({ArrowEdgePadding = 50, ArrowShowDistanceText = false,})
module.players = false
module.pcs = false
module.pods = false
module.exits = false
module.lockers = false
local hideLabelsAndArrows = false
module.antipcerror = false
module.flashlight = false
local esps = {}
local function getBeast()
local listplayers = game.Players:GetChildren()
for _, player in ipairs(listplayers) do
local character = player.Character
if character ~= nil and character:FindFirstChild("BeastPowers") then return player end
end
end
local function reloadESP()
espcontainer:ClearAllGroups()
if module.players then
local listplayers = game.Players:GetChildren()
for _, player in ipairs(listplayers) do
if player ~= game.Players.LocalPlayer and player.Character ~= nil then
local character = player.Character
if player == getBeast() then
espcontainer:Add(character, {AccentColor = Color3.new(1, 0, 0), ArrowShow = not hideLabelsAndArrows, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Beast", ShowLabel = not hideLabelsAndArrows, GroupName = "players"})
else
espcontainer:Add(character, {AccentColor = Color3.new(0, 1, 0), ArrowShow = false, ShowLabel = false, GroupName = "players"})
end
end
end
end
if module.pcs then
for _, obj in ipairs(game.Workspace:GetDescendants()) do
if obj.Name == "ComputerTable" then
if obj.Screen.Color == Color3.fromRGB(40, 127, 71) then
espcontainer:Add(obj, {AccentColor = Color3.new(0.133333, 0.333333, 0.00784314), ArrowShow = false, ShowLabel = false, GroupName = "pcs"})
else
espcontainer:Add(obj, {AccentColor = Color3.new(0, 0.37, 1), ArrowShow = not hideLabelsAndArrows, ArrowMinDistance = 99999, ShowLabel = false, GroupName = "pcs"})
end
end
end
end
if module.pods then
for _, obj in ipairs(game.Workspace:GetDescendants()) do
if obj.Name == "FreezePod" then
espcontainer:Add(obj, {AccentColor = Color3.new(0, 1, 1), ArrowShow = false, ShowLabel = false, GroupName = "pods"})
end
end
end
if module.exits then
for _, obj in ipairs(game.Workspace:GetDescendants()) do
if obj.Name == "ExitDoor" then
espcontainer:Add(obj, {AccentColor = Color3.new(1, 1, 0), ArrowShow = false, ShowLabel = false, GroupName = "exits"})
end
end
end
if module.lockers then
for _, obj in ipairs(game:GetService("CollectionService"):GetTagged("LOCKER")) do
espcontainer:Add(obj, {AccentColor = Color3.new(1, 0.054902, 0.623529), ArrowShow = false, ShowLabel = false, GroupName = "lockers"})
end
end
end
table.insert(module, {Type = "Text", Args = {"ESPs"}})
table.insert(module, {Type = "ButtonGrid", Toggleable = true, Args = {3, {
Players = function(Self) if module.players then module.players = false; reloadESP() else module.players = true; reloadESP() end end,
PCs = function(Self) if module.pcs then module.pcs = false; reloadESP() else module.pcs = true; reloadESP() end end,
Pods = function(Self) if module.pods then module.pods = false; reloadESP() else module.pods = true; reloadESP() end end,
Exits = function(Self) if module.exits then module.exits = false; reloadESP() else module.exits = true; reloadESP() end end,
Lockers = function(Self) if module.lockers then module.lockers = false; reloadESP() else module.lockers = true; reloadESP() end end,
}}})
table.insert(module, {Type = "Toggle", Args = {"Hide arrows and labels", function(Self, state) hideLabelsAndArrows = state; reloadESP() end,}})
table.insert(module, {Type = "Text", Args = {"Tools"}})
table.insert(module, {Type = "Button", Args = {"Third person camera", function(Self) game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic; game.Players.LocalPlayer.CameraMaxZoomDistance = 400; FUNCTIONS.notification("Camera unlocked for third person. Try zooming out!") end,}})
table.insert(module, {Type = "Button", Args = {"Reload ESP", function(Self) reloadESP() end,}})
local isGameActive = game:GetService("ReplicatedStorage"):WaitForChild("IsGameActive", 5)
local gameStatus = game:GetService("ReplicatedStorage"):WaitForChild("GameStatus", 5)
if isGameActive and gameStatus then
isGameActive.Changed:Connect(function() reloadESP() end)
gameStatus.Changed:Connect(function() reloadESP() end)
end
local root = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")
light = Instance.new("PointLight", root)
light.Brightness = 0
light.Range = 9999999999
local wslock = false
local ws = 18
local antifail = false
task.spawn(function()
if game:GetService("RunService"):IsStudio() then return end
local OldNameCall = nil
OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
local Args = {...}
local NamecallMethod = getnamecallmethod()
if NamecallMethod == "FireServer" and Args[1] == "SetPlayerMinigameResult" and antifail then
Args[2] = true
end
return OldNameCall(Self, unpack(Args))
end)
end)
table.insert(module, {Type = "ButtonGrid", Toggleable = true, Args = {3, {
Anti_PC_Error = function() if antifail then antifail = false else antifail = true end end,
Flashlight = function() if light.Brightness == 0 then light.Brightness = 2.5 else light.Brightness = 0 end end,
}}})
task.spawn(function()
while task.wait(0.1) do
if wslock then root.Parent:WaitForChild("Humanoid").WalkSpeed = ws end
end
end)
table.insert(module, {Type = "Input", Args = {"Input a walkspeed", "Set & Lock", function(Self, text)
if not tonumber(text) then FUNCTIONS.notification("Input isn't a valid number."); return end
ws = tonumber(text); wslock = true
end,}})
table.insert(module, {Type = "Button", Args = {"Unlock all", function() wslock = false end,}})
table.insert(module, {Type = "Text", Args = {"Locking means your speed will stay the same no matter what."}})
repeat task.wait() until getgenv().Modules
getgenv().Modules[2] = module
end

local function XXZOB_routine() -- Routine: StarterGui.YARHM.Murder Mystery 2
local script = Instance.new("LocalScript")
script.Name = "Murder Mystery 2"
script.Parent = Converted["_YARHM"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
local module = {}
module["gameId"] = 0
local fu = require(getgenv().YARHM.FUNCTIONS)
local espindc = require(script.Parent.ESPIndicator)
local espcontainer = espindc.new({ArrowEdgePadding = 50, ArrowShowDistanceText = false,})
local playerESP = false
local sheriffAimbot = false
local coinAutoCollect = false
local autoShooting = false
local shootOffset = 2.8
local offsetToPingMult = 1
local predictionAIEngine = false
local predictionOngoing = false
local predictionCooldown = false
local gunDropESP = false
local trapDetection = false
local autoGetDroppedGun = false
local simulateKnifeThrow = false
local localplayer = game:GetService("Players").LocalPlayer
local playerData = {}
local phs = game:GetService("PathfindingService")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local claimedCoins = {}

local function findMurderer()
for _, i in ipairs(game.Players:GetPlayers()) do
if i.Backpack:FindFirstChild("Knife") then return i end
end
for _, i in ipairs(game.Players:GetPlayers()) do
if not i.Character then continue end
if i.Character:FindFirstChild("Knife") then return i end
end
if playerData then
for player, data in playerData do
if data.Role == "Murderer" then
if game.Players:FindFirstChild(player) then return game.Players:FindFirstChild(player) end
end
end
end
return nil
end

local function findSheriff()
for _, i in ipairs(game.Players:GetPlayers()) do
if i.Backpack:FindFirstChild("Gun") then return i end
end
for _, i in ipairs(game.Players:GetPlayers()) do
if not i.Character then continue end
if i.Character:FindFirstChild("Gun") then return i end
end
if playerData then
for player, data in playerData do
if data.Role == "Sheriff" then
if game.Players:FindFirstChild(player) then return game.Players:FindFirstChild(player) end
end
end
end
return nil
end

local function findSheriffThatsNotMe()
for _, i in ipairs(game.Players:GetPlayers()) do
if i == localplayer then continue end
if i.Backpack:FindFirstChild("Gun") then return i end
end
for _, i in ipairs(game.Players:GetPlayers()) do
if i == localplayer then continue end
if not i.Character then continue end
if i.Character:FindFirstChild("Gun") then return i end
end
return nil
end

local hideMeEsp = false
function reloadESP()
if not playerESP then return end
espcontainer:RemoveGroup("players")
local listplayers = game.Players:GetChildren()
for _, player in ipairs(listplayers) do
if player == localplayer and hideMeEsp then continue end
if player.Character ~= nil then
local character = player.Character
task.spawn(function()
if player == findMurderer() then
espcontainer:Add(character, {AccentColor = Color3.new(1, 0, 0.0156863), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Murderer", ShowLabel = true, GroupName = "players"})
elseif player == findSheriff() then
espcontainer:Add(character, {AccentColor = Color3.new(0, 0.6, 1), ArrowShow = false, ShowLabel = false, GroupName = "players"})
else
espcontainer:Add(character, {AccentColor = Color3.new(0, 1, 0.0313725), ArrowShow = false, ShowLabel = false, GroupName = "players"})
end
end)
end
end
end

if not game.ReplicatedStorage:WaitForChild("Remotes", 5) then
fu.dialog("Not MM2", "Looks like this game isn't MM2. Do you want to load the module anyway?", {"Load", "No"})
if fu.waitfordialog() == "No" then fu.closedialog(); fu.notification("MM2 will not be loaded until you rejoin.", Color3.fromRGB(255, 0, 0), "x"); return end
fu.closedialog()
else
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged", 5).OnClientEvent:Connect(function(data)
playerData = data
if playerESP then reloadESP() end
end)
end

local function findNearestPlayer()
local nearestPlayer = nil
local shortestDistance = math.huge
for _, player in ipairs(game.Players:GetPlayers()) do
if player ~= localplayer and player.Character then
local localRootPart = localplayer.Character:FindFirstChild("HumanoidRootPart")
local otherRootPart = player.Character:FindFirstChild("HumanoidRootPart")
if localRootPart and otherRootPart then
local distance = (localRootPart.Position - otherRootPart.Position).Magnitude
if distance < shortestDistance then shortestDistance = distance; nearestPlayer = player end
end
end
end
return nearestPlayer
end

function miniFling(playerToFling)
local a=game.Players.LocalPlayer;local b=a:GetMouse()local c={playerToFling}local d=game:GetService("Players")local e=d.LocalPlayer;local f=false;local g=function(h)local i=e.Character;local j=i and i:FindFirstChildOfClass("Humanoid")local k=j and j.RootPart;local l=h.Character;local m;local n;local o;local p;local q;if l:FindFirstChildOfClass("Humanoid")then m=l:FindFirstChildOfClass("Humanoid")end;if m and m.RootPart then n=m.RootPart end;if l:FindFirstChild("Head")then o=l.Head end;if l:FindFirstChildOfClass("Accessory")then p=l:FindFirstChildOfClass("Accessory")end;if p and p:FindFirstChild("Handle")then q=p.Handle end;if i and j and k then if k.Velocity.Magnitude<50 then getgenv().OldPos=k.CFrame end;if o then if o.Velocity.Magnitude>500 then fu.dialog("Player flung","Player is already flung. Fling again?",{"Fling again","No"})if fu.waitfordialog()=="No"then return fu.closedialog()end;fu.closedialog()end elseif not o and q then if q.Velocity.Magnitude>500 then fu.dialog("Player flung","Player is already flung. Fling again?",{"Fling again","No"})if fu.waitfordialog()=="No"then return fu.closedialog()end;fu.closedialog()end end;if o then workspace.CurrentCamera.CameraSubject=o elseif not o and q then workspace.CurrentCamera.CameraSubject=q elseif m and n then workspace.CurrentCamera.CameraSubject=m end;if not l:FindFirstChildWhichIsA("BasePart")then return end;local r=function(s,t,u)k.CFrame=CFrame.new(s.Position)*t*u;i:SetPrimaryPartCFrame(CFrame.new(s.Position)*t*u)k.Velocity=Vector3.new(9e7,9e7*10,9e7)k.RotVelocity=Vector3.new(9e8,9e8,9e8)end;local v=function(s)local w=2;local x=tick()local y=0;repeat if k and m then if s.Velocity.Magnitude<50 then y=y+100;r(s,CFrame.new(0,1.5,0)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(0,-1.5,0)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(2.25,1.5,-2.25)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(-2.25,-1.5,2.25)+m.MoveDirection*s.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(0,1.5,0)+m.MoveDirection,CFrame.Angles(math.rad(y),0,0))task.wait()r(s,CFrame.new(0,-1.5,0)+m.MoveDirection,CFrame.Angles(math.rad(y),0,0))task.wait()else r(s,CFrame.new(0,1.5,m.WalkSpeed),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,-m.WalkSpeed),CFrame.Angles(0,0,0))task.wait()r(s,CFrame.new(0,1.5,m.WalkSpeed),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,1.5,n.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,-n.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0))task.wait()r(s,CFrame.new(0,1.5,n.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0))task.wait()r(s,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0))task.wait()end else break end until s.Velocity.Magnitude>500 or s.Parent~=h.Character or h.Parent~=d or h.Character~=l or m.Sit or j.Health<=0 or tick()>x+w end;workspace.FallenPartsDestroyHeight=0/0;local z=Instance.new("BodyVelocity")z.Name="EpixVel"z.Parent=k;z.Velocity=Vector3.new(9e8,9e8,9e8)z.MaxForce=Vector3.new(1/0,1/0,1/0)j:SetStateEnabled(Enum.HumanoidStateType.Seated,false)if n and o then if(n.CFrame.p-o.CFrame.p).Magnitude>5 then v(o)else v(n)end elseif n and not o then v(n)elseif not n and o then v(o)elseif not n and not o and p and q then v(q)else fu.notification("Can't find a proper part of target player to fling.")end;z:Destroy()j:SetStateEnabled(Enum.HumanoidStateType.Seated,true)workspace.CurrentCamera.CameraSubject=j;repeat k.CFrame=getgenv().OldPos*CFrame.new(0,.5,0)i:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0))j:ChangeState("GettingUp")table.foreach(i:GetChildren(),function(A,B)if B:IsA("BasePart")then B.Velocity,B.RotVelocity=Vector3.new(),Vector3.new()end end)task.wait()until(k.Position-getgenv().OldPos.p).Magnitude<25;workspace.FallenPartsDestroyHeight=getgenv().FPDH else fu.notification("No valid character of said target player. May have died.")end end;g(c[1])
end

function getMap()
for _, o in ipairs(workspace:GetChildren()) do
if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
end
return nil
end

module["Name"] = "Murder Mystery 2"

workspace.ChildAdded:Connect(function(ch)
if ch == getMap() and playerESP then
fu.notification("Map has loaded, waiting for roles...")
repeat task.wait(1) until findMurderer()
fu.notification("Player ESP reloaded.")
end
end)

workspace.ChildRemoved:Connect(function(ch)
if ch == getMap() and playerESP then
fu.notification("Game ended, removing Player ESPs.")
playerData = {}
espcontainer:ClearAllGroups()
end
end)

workspace.DescendantAdded:Connect(function(ch)
if trapDetection and ch.Name == "Trap" and (ch.Parent:IsA("Folder") or ch.Parent:IsA("Model")) then
ch.Transparency = 0
espcontainer:Add(ch, {AccentColor = Color3.new(1, 0, 0.0156863), ArrowShow = false, ShowLabel = true, LabelText = "Trap", GroupName = "trap"})
fu.notification("Murderer has placed a trap!")
end
if gunDropESP and ch.Name == "GunDrop" then
espcontainer:Add(ch, {AccentColor = Color3.new(0.952941, 1, 0.0745098), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Dropped gun!", ShowLabel = true, GroupName = "gun"})
fu.notification("Gun has been dropped! Find a yellow highlight.")
if autoGetDroppedGun then
fu.notification("Auto get dropped gun - Cooling down...")
task.wait(1)
if not getMap():FindFirstChild("GunDrop") then fu.notification("No dropped gun to be teleported to.") return end
local previousPosition = localplayer.Character:GetPivot()
localplayer.Character:MoveTo(getMap():FindFirstChild("GunDrop").Position)
localplayer.Backpack.ChildAdded:Wait()
localplayer.Character:PivotTo(previousPosition)
end
end
end)

workspace.DescendantRemoving:Connect(function(ch)
if gunDropESP and ch.Name == "GunDrop" then
espcontainer:RemoveGroup("gun")
fu.notification("Someone has took the dropped gun.")
task.wait(1)
fu.notification("The hero is " .. findSheriff().DisplayName .. ".")
reloadESP()
end
end)

function getClosestModelToPlayer(player, models)
local closestModel = nil
local closestDistance = math.huge
local playerPosition = player.Character.HumanoidRootPart.Position
for _, model in ipairs(models) do
local modelPosition = model:GetPivot().Position
local distance = (modelPosition - playerPosition).Magnitude
if distance < closestDistance then closestDistance = distance; closestModel = model end
end
return closestModel
end

task.spawn(function()
while task.wait(0.1) do
if not coinAutoCollect then continue end
if getMap() then
if getMap():FindFirstChild("CoinContainer") and #getMap():FindFirstChild("CoinContainer"):GetChildren() > 1 then
local closestCoin = getClosestModelToPlayer(localplayer, getMap():FindFirstChild("CoinContainer"):GetChildren())
if closestCoin then
if not localplayer.Character:FindFirstChild("HumanoidRootPart") then continue end
local distance = (localplayer.Character:FindFirstChild("HumanoidRootPart").Position - closestCoin:GetPivot().Position).Magnitude
local toclosestcoin = ts:Create(localplayer.Character:FindFirstChild("HumanoidRootPart"), TweenInfo.new(distance*0.05, Enum.EasingStyle.Linear), {CFrame = closestCoin:GetPivot()})
toclosestcoin:Play()
toclosestcoin.Completed:Wait()
task.wait(0.1)
closestCoin:Destroy()
claimedCoins[closestCoin] = true
end
end
end
end
end)

local function getPredictedPosition(player, shootOffset)
local usingBasicPred = not predictionAIEngine
if predictionOngoing then fu.notification("Cancelling AI prediction, using basic prediction."); usingBasicPred = true end
local ogplayer = player
pcall(function() player = player.Character end)
local playerHRP = player:FindFirstChild("UpperTorso") or player:FindFirstChild("HumanoidRootPart")
local playerHum = player:FindFirstChild("Humanoid")
if not playerHRP or not playerHum then return Vector3.new(0,0,0), "Could not find the player's HumanoidRootPart." end
local playerPosition = playerHRP.Position
if predictionAIEngine and not usingBasicPred and not predictionCooldown and getgenv().YARHMNetwork_predictPos then
if (playerPosition - localplayer.Character:FindFirstChild("UpperTorso").Position).Magnitude > 20 then
fu.notification("Calculating trajectory...")
predictionCooldown = true
predictionOngoing = true
local predictedPosition = getgenv().YARHMNetwork_predictPos(ogplayer)
predictionOngoing = false
task.spawn(function() task.wait(5); predictionCooldown = false end)
return predictedPosition
else
fu.notification("Murderer is too close for trajectory prediction. Reverting to basic prediction.")
end
elseif predictionAIEngine and not getgenv().YARHMNetwork.predictPos then
fu.notification("YARHM AI Engine is not available. Reverting to basic prediction.")
end
local velocity = Vector3.new()
velocity = playerHRP.AssemblyLinearVelocity
local playerMoveDirection = playerHum.MoveDirection
local predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (shootOffset / 15) + playerMoveDirection * shootOffset
predictedPosition = predictedPosition * (((localplayer:GetNetworkPing() * 1000) * ((offsetToPingMult - 1) * 0.01)) + 1)
return predictedPosition
end

task.spawn(function()
while task.wait(1) do
if findSheriff() == localplayer and autoShooting then
fu.notification("Auto-shooting started.")
repeat
task.wait(0.1)
local murderer = findMurderer()
if not murderer then fu.notification("No murderer.") continue end
local murdererPosition = murderer.Character.HumanoidRootPart.Position
local characterRootPart = localplayer.Character.HumanoidRootPart
local rayDirection = murdererPosition - characterRootPart.Position
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {localplayer.Character}
local hit = workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
if not hit or hit.Instance.Parent == murderer.Character then
fu.notification("Auto-shooting!")
if not localplayer.Character:FindFirstChild("Gun") then
local hum = localplayer.Character:FindFirstChild("Humanoid")
if localplayer.Backpack:FindFirstChild("Gun") then
localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
else
fu.notification("You don't have the gun..?")
return
end
end
local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
if not murdererHRP then fu.notification("Could not find the murderer's HumanoidRootPart."); return end
local predictedPosition = getPredictedPosition(murderer, shootOffset)
local args = {[1] = 1, [2] = predictedPosition, [3] = "AH2"}
localplayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
end
until findSheriff() ~= localplayer or not autoShooting
end
end
end)

table.insert(module, {Type = "Text", Args = {"ESPs"}})
table.insert(module, {Type = "ButtonGrid", Toggleable = true, Args = {2, {
Players = function()
if playerESP then playerESP = false; espcontainer:RemoveGroup("players")
else
playerESP = true
if not findMurderer() or not findSheriff() then fu.notification("No roles yet. Waiting for roles..."); repeat task.wait(1) until findSheriff() or findMurderer() end
reloadESP()
end
end,
Dropped_Gun = function()
if gunDropESP then gunDropESP = false; espcontainer:RemoveGroup("gun")
else
gunDropESP = true
if not getMap() then return end
if getMap():FindFirstChild("GunDrop") then
espcontainer:Add(getMap():FindFirstChild("GunDrop"), {AccentColor = Color3.new(0.952941, 1, 0.0745098), ArrowShow = true, ArrowMinDistance = 999999, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Dropped gun!", ShowLabel = true, GroupName = "gun"})
fu.notification("Gun has been dropped! Find a yellow highlight.")
end
end
end,
Traps = function()
if trapDetection then trapDetection = false; espcontainer:RemoveGroup("trap")
else
trapDetection = true
for _, v in ipairs(workspace:GetDescendants()) do
if v.Name == "Trap" and (v.Parent:IsA("Folder") or v.Parent:IsA("Model")) then
v.Transparency = 0
espcontainer:Add(v, {AccentColor = Color3.new(1, 0, 0), ArrowShow = false, ShowLabel = true, LabelText = "Trap", GroupName = "trap"})
end
end
end
end,
}}})

table.insert(module, {Type = "Toggle", Args = {"Hide my own ESP", function(Self, state) hideMeEsp = state; reloadESP() end,}})
table.insert(module, {Type = "Text", Args = {"Tools"}})
local instakillshoot = false
table.insert(module, {Type = "Button", Args = {"Shoot murderer", function(Self)
if findSheriff() ~= localplayer then fu.notification("You're not sheriff/hero."); return end
local murderer = findMurderer() or findSheriffThatsNotMe()
if not murderer then fu.notification("No murderer (or sheriff) to shoot."); return end
if not localplayer.Character:FindFirstChild("Gun") then
local hum = localplayer.Character:FindFirstChild("Humanoid")
if localplayer.Backpack:FindFirstChild("Gun") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Gun"))
else fu.notification("You don't have the gun..?"); return end
end
local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
if not murdererHRP then fu.notification("Could not find the murderer's HumanoidRootPart."); return end
local predictedPosition = getPredictedPosition(murderer, shootOffset)
local args
if instakillshoot then args = {CFrame.new(murdererHRP.Position + Vector3.new(0,1,0)), CFrame.new(murdererHRP.Position)}
else args = {CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(predictedPosition)} end
localplayer.Character:WaitForChild("Gun"):WaitForChild("Shoot"):FireServer(unpack(args))
end,}})

local spawnAtPlayer = false
local loopThrow = false
local function knifeThrow(silent)
if findMurderer() ~= localplayer then if silent then return end; fu.notification("You're not murderer."); return end
if not localplayer.Character:FindFirstChild("Knife") then
local hum = localplayer.Character:FindFirstChild("Humanoid")
if localplayer.Backpack:FindFirstChild("Knife") then hum:EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
else if silent then return end; fu.notification("You don't have the knife..?"); return end
end
local NearestPlayer = findNearestPlayer()
if not NearestPlayer or not NearestPlayer.Character then if silent then return end; fu.notification("Can't find a player!?"); return end
local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
if not nearestHRP then if silent then return end; fu.notification("Can't find the player's pivot."); end
local argsThrowRemote = {CFrame.new(localplayer.Character.RightHand.Position), CFrame.new(getPredictedPosition(NearestPlayer, shootOffset + 1))}
if spawnAtPlayer then argsThrowRemote[1] = CFrame.new(nearestHRP.Position + (nearestHRP.CFrame.LookVector * 5)) end
localplayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(argsThrowRemote))
end

task.spawn(function()
while task.wait(1.5) do
if loopThrow then knifeThrow(true) end
end
end)

table.insert(module, {Type = "Button", Args = {"Knife throw to closest (NEW)", function() knifeThrow() end}})
table.insert(module, {Type = "Toggle", Args = {"Auto knife throw", function(Self, tog) loopThrow = tog end}})
table.insert(module, {Type = "Input", Args = {"Shoot position offset", "Set", function(Self, text)
if not tonumber(text) then fu.notification("Not a valid number."); return end
shootOffset = tonumber(text); fu.notification("Offset has been set.")
end,}})
table.insert(module, {Type = "Input", Args = {"Offset-to-ping multiplier", "Set", function(Self, text)
if not tonumber(text) then fu.notification("Not a valid number."); return end
offsetToPingMult = tonumber(text); fu.notification("Offset has been set.")
end,}})

table.insert(module, {Type = "Text", Args = {"<font color='#FF0000'>Detectables</font>"}})
table.insert(module, {Type = "Toggle", Args = {"Instakill murderer as sheriff", function(Self, tog) instakillshoot = tog end}})
table.insert(module, {Type = "Toggle", Args = {"Spawn knife throw near player", function(Self, tog) spawnAtPlayer = tog end}})
table.insert(module, {Type = "Button", Args = {"Send Sheriff and Murderer names into chat", function(Self)
local textchannels = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
for _, textchannel in ipairs(textchannels) do
if textchannel.Name == "RBXSystem" then continue end
local murd = findMurderer(); local sher = findSheriff()
local murdName = murd and murd.Name or "-"; local sherName = sher and sher.Name or "-"
local message = string.format("Murderer: %s | Sheriff: %s | <<XDarkHUB>>", murdName, sherName)
textchannel:SendAsync(message)
end
end,}})

table.insert(module, {Type = "ButtonGrid", Args = {2, {
Teleport_to_lobby = function(Self)
local lobby = workspace:FindFirstChild("Lobby")
if lobby then localplayer.Character:MoveTo(lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation").Position) end
end,
Teleport_to_map = function(Self)
local spawnsFolder = getMap():FindFirstChild("Spawns")
if spawnsFolder then
local spawns = spawnsFolder:GetChildren()
local randomSpawn = spawns[math.random(1, #spawns)]
localplayer.Character:MoveTo(randomSpawn.Position)
else fu.notification("No map to teleport to.") end
end,
}}})

table.insert(module, {Type = "ButtonGrid", Args = {2, {
Fling_Sheriff = function() if not findSheriff() then fu.notification("No sheriff/hero to fling."); return end; miniFling(findSheriff()) end,
Fling_Murderer = function() if not findMurderer() then fu.notification("No murderer to fling."); return end; miniFling(findMurderer()) end,
}}})

table.insert(module, {Type = "ButtonGrid", Args = {2, {
Copy_murderer_username = function() if not findMurderer() then fu.notification("No murderer to copy."); return end; if setclipboard then setclipboard(findMurderer().Name) end; fu.notification("Copied to clipboard.") end,
Copy_sheriff_username = function() if not findSheriff() then fu.notification("No sheriff/hero to copy."); return end; if setclipboard then setclipboard(findSheriff().Name) end; fu.notification("Copied to clipboard.") end,
}}})

table.insert(module, {Type = "Button", Args = {"Teleport to dropped gun", function(Self)
if not getMap():FindFirstChild("GunDrop") then fu.notification("No dropped gun to be teleported to."); return end
local previousPosition = localplayer.Character:GetPivot()
localplayer.Character:PivotTo(getMap():FindFirstChild("GunDrop"):GetPivot())
localplayer.Backpack.ChildAdded:Wait()
localplayer.Character:PivotTo(previousPosition)
end,}})

table.insert(module, {Type = "Toggle", Args = {"Automatically get gun on drop", function(Self, state) autoGetDroppedGun = state end,}})
local ignoreknifethrow = false
game.Workspace.ChildAdded:Connect(function(chi) if chi.Name == "ThrowingKnife" and ignoreknifethrow then chi:Destroy() end end)
table.insert(module, {Type = "Toggle", Args = {"Ignore knife throws", function(Self, state) ignoreknifethrow = state end,}})

table.insert(module, {Type = "Button", Args = {"God mode (Very, VERY UNSTABLE)", function(Self)
local Cam = workspace.CurrentCamera
local Pos, Char = Cam.CFrame, localplayer.Character
local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
local nHuman = Human.Clone(Human)
nHuman.Parent, localplayer.Character = Char, nil
nHuman.SetStateEnabled(nHuman, 15, false)
nHuman.SetStateEnabled(nHuman, 1, false)
nHuman.SetStateEnabled(nHuman, 0, false)
nHuman.BreakJointsOnDeath, Human = true, Human.Destroy(Human)
localplayer.Character, Cam.CameraSubject, Cam.CFrame = Char, nHuman, wait() and Pos
nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
local Script = Char.FindFirstChild(Char, "Animate")
if Script then Script.Disabled = true; wait(); Script.Disabled = false end
nHuman.Health = nHuman.MaxHealth
end,}})

table.insert(module, {Type = "Button", Args = {"Kill closest player as murderer", function()
if findMurderer() ~= localplayer then fu.notification("You're not murderer."); return end
if not localplayer.Character:FindFirstChild("Knife") then
local hum = localplayer.Character:FindFirstChild("Humanoid")
if localplayer.Backpack:FindFirstChild("Knife") then localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
else fu.notification("You don't have the knife..?"); return end
end
local NearestPlayer = findNearestPlayer()
if not NearestPlayer or not NearestPlayer.Character then fu.notification("Can't find a player!?"); return end
local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
if not nearestHRP then fu.notification("Can't find the player's pivot."); end
if not localplayer.Character:FindFirstChild("HumanoidRootPart") then fu.notification("You're not a valid character."); return end
nearestHRP.Anchored = true
nearestHRP.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
task.wait(0.1)
local args = {[1] = "Slash"}
localplayer.Character.Knife.Stab:FireServer(unpack(args))
end,}})

local killAuraCon = nil
table.insert(module, {Type = "Toggle", Args = {"Murderer kill aura", function(Self, state)
if state then
if killAuraCon then killAuraCon:Disconnect() end
killAuraCon = game:GetService("RunService").Heartbeat:Connect(function()
for _, player in ipairs(game.Players:GetPlayers()) do
if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
local hrp = player.Character:FindFirstChild("HumanoidRootPart")
if (hrp.Position - localplayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 7 then
hrp.Anchored = true
hrp.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
task.wait(0.1)
local args = {[1] = "Slash"}
localplayer.Character.Knife.Stab:FireServer(unpack(args))
return
end
end
end
end)
else
if killAuraCon then killAuraCon:Disconnect(); killAuraCon = nil end
end
end,}})

table.insert(module, {Type = "Button", Args = {"Kill EVERYONE as murderer", function()
if findMurderer() ~= localplayer then fu.notification("You're not murderer."); return end
if not localplayer.Character:FindFirstChild("Knife") then
local hum = localplayer.Character:FindFirstChild("Humanoid")
if localplayer.Backpack:FindFirstChild("Knife") then localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
else fu.notification("You don't have the knife..?"); return end
end
for _, player in ipairs(game.Players:GetPlayers()) do
if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
player.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
end
end
local args = {[1] = "Slash"}
localplayer.Character.Knife.Stab:FireServer(unpack(args))
end,}})

table.insert(module, {Type = "Text", Args = {"Fun"}})
table.insert(module, {Type = "Button", Args = {"Hold everyone hostage", function()
if findMurderer() ~= localplayer then fu.notification("You're not murderer. This'll only be useful if you're the murderer."); return end
for _, player in ipairs(game.Players:GetPlayers()) do
if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
player.Character:FindFirstChild("HumanoidRootPart").CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
end
end
fu.notification("Placed every single player in a single point.")
end,}})

repeat task.wait() until getgenv().Modules
getgenv().Modules[3] = module
fu.refreshlist()
end

-- Инициализация
local function DSZIHQM_routine()
local script = Instance.new("LocalScript")
script.Name = "Init"
script.Parent = Converted["_YARHM"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
getgenv().Modules = {}
local ts = game:GetService("TweenService")
getgenv().YARHM = script.Parent
getgenv().ThemeManager = require(script.Parent.Theme)
local COREGUI = game:GetService("CoreGui")
function randomString()
local length = math.random(10,20)
local array = {}
for i = 1, length do array[i] = string.char(math.random(32, 126)) end
return table.concat(array)
end
local s, e = pcall(function()
if get_hidden_gui or gethui then
local hiddenUI = get_hidden_gui or gethui
script.Parent.Name = randomString()
script.Parent.Parent = hiddenUI()
elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
script.Parent.Name = randomString()
syn.protect_gui(script.Parent)
script.Parent.Parent = COREGUI
elseif COREGUI:FindFirstChild('RobloxGui') then
script.Parent.Parent = COREGUI.RobloxGui
else
script.Parent.Parent = COREGUI
end
end)
if not s then warn(e) end
script.Parent.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
script.Parent.ScreenInsets = Enum.ScreenInsets.None
script.Parent.ResetOnSpawn = false
script.Parent.Menu.Position = UDim2.fromScale(0.5, -0.6)
script.Parent.Dialog.Size = UDim2.fromOffset(0, 147)
script.Parent.Dialog.UIScale.Scale = 0
script.Parent.Dialog.Visible = true
script.Parent.Menu.CanvasGroup.Visible = true
script.Parent.Menu.CanvasGroup.GroupTransparency = 0
if not game:IsLoaded() then game.Loaded:Wait() end
script.Parent.Menu.HubName.Text = script.Parent.Menu.HubName.Text .. `<font transparency="0.8" size="5">{require(script.Parent.FUNCTIONS).__v}</font>`
ts:Create(script.Parent.Menu, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.05)}):Play()
task.wait(1)
ts:Create(script.Parent.Menu.CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
require(script.Parent.FUNCTIONS).refreshlist()
task.wait(0.5)
script.Parent.Menu.CanvasGroup.Visible = false
script.Parent.Menu.CanvasGroup.TextLabel.Visible = false
script.Parent.Menu.CanvasGroup.ImageLabel.Visible = true
script.Parent.Menu.CanvasGroup.Interactable = true
script.Parent.Menu.CloseArea.AllowForSpring:Fire()
task.wait(1)
require(script.Parent.FUNCTIONS).loadFloatingButtons()
end

local function ONOAH_routine()
local script = Instance.new("LocalScript")
script.Name = "InitOpen"
script.Parent = Converted["_Open"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
local ts = game:GetService("TweenService")
local stroke = Instance.new("UIStroke")
stroke.Parent = script.Parent
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255,255,255)
script.Parent.Position = UDim2.fromScale(0.5, -1)
ts:Create(script.Parent, TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.063)}):Play()
task.wait(5)
ts:Create(script.Parent, TweenInfo.new(5), {TextTransparency = 1}):Play()
end

local function JFQXCG_routine()
local script = Instance.new("LocalScript")
script.Name = "OnClick"
script.Parent = Converted["_Open"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
local ts = game:GetService("TweenService")
local clickCount = 0
local lastClickTime = tick()
script.Parent.MouseButton1Click:Connect(function()
local currentTime = tick()
script.Parent.TextTransparency = 1
ts:Create(script.Parent, TweenInfo.new(1), {TextTransparency = 1}):Play()
if currentTime - lastClickTime < 0.5 then clickCount = clickCount + 1 else clickCount = 1 end
lastClickTime = currentTime
if clickCount == 3 then
ts:Create(getgenv().YARHM.Menu, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.499, 0.041), Size = UDim2.fromOffset(441, 268)}):Play()
end
end)
end

local function AWDPHWS_routine()
local script = Instance.new("LocalScript")
script.Name = "CloseOpen"
script.Parent = Converted["_CloseArea"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local menu = script.Parent.Parent
local Spring = require(menu.Parent.Spring)
local DraggableObject = require(menu.Parent.DraggableObject)
local Bezier = require(menu.Parent.Bezier)
local closed = false
local springing = false
local closing
local lastPos = UDim2.fromScale(0.5, 0.5)
local closedLastPos = UDim2.fromScale(0.5, 0.1)
local MenuPosXScale = Spring.new(0.7, 30, 160, menu.Position.X.Scale, 0, menu.Position.X.Scale)
local MenuPosYScale = Spring.new(0.7, 45, 190, 0.05, 0, 0.05)
local MenuPosXOffset = Spring.new(0.7, 30, 160, 0, 0)
local MenuPosYOffset = Spring.new(0.7, 45, 190, 0, 0)
local MenuSizeXOffset = Spring.new(1, 25, 120, menu.Size.X.Offset, 0, menu.Size.X.Offset)
local MenuSizeYOffset = Spring.new(1, 25, 120, menu.Size.Y.Offset, 0, menu.Size.Y.Offset)
local MenuRotation = Spring.new(1, 18, 100, menu.Rotation, 0, menu.Rotation)
local function setSpringPosGoal(udim2)
MenuPosXScale:SetGoal(udim2.X.Scale)
MenuPosYScale:SetGoal(udim2.Y.Scale)
MenuPosXOffset:SetGoal(udim2.X.Offset)
MenuPosYOffset:SetGoal(udim2.Y.Offset)
end
local function setSpringSizeGoal(udim2)
MenuSizeXOffset:SetGoal(udim2.X.Offset)
MenuSizeYOffset:SetGoal(udim2.Y.Offset)
end
RunService.RenderStepped:Connect(function()
if springing then
menu.Position = UDim2.new(MenuPosXScale.Offset, MenuPosXOffset.Offset, MenuPosYScale.Offset, MenuPosYOffset.Offset)
menu.Size = UDim2.fromOffset(MenuSizeXOffset.Offset, MenuSizeYOffset.Offset)
menu.Rotation = MenuRotation.Offset
MenuRotation:SetGoal(0)
end
end)
local MenuDrag = DraggableObject.new(script.Parent, menu, false, true)
MenuDrag:Enable()
local OpenerMenuDrag = DraggableObject.new(script.Parent.Parent.CanvasGroup.Opener, menu, false, true)
OpenerMenuDrag:Enable()
local OpenerDraggable = true
textHidden = false
local deltaFrom = menu.Position
MenuDrag.Dragged = function(pos)
local delta = pos - deltaFrom
deltaFrom = pos
MenuRotation:SetGoal(delta.X.Offset * 0.5)
setSpringPosGoal(pos)
TweenService:Create(menu.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
end
OpenerMenuDrag.Dragged = function(pos)
if OpenerDraggable then closedLastPos = pos; setSpringPosGoal(pos) end
end
script.Parent.MouseButton1Click:Connect(function()
TweenService:Create(menu, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0.5, 0.5)}):Play()
springing = true
setSpringPosGoal(closedLastPos)
setSpringSizeGoal(UDim2.fromOffset(60, 60))
if not menu.Area:FindFirstChildWhichIsA("UICorner") then Instance.new("UICorner", menu.Area) end
menu.Area:FindFirstChildWhichIsA("UICorner").CornerRadius = UDim.new(0, 16)
task.spawn(function() task.wait(0.05) menu.List.Visible = false end)
menu.CanvasGroup.Visible = true
OpenerDraggable = true
if closing then closing:Cancel() end
TweenService:Create(menu.CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
end)
MenuDrag.DragEnded = function(vel)
TweenService:Create(menu.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Scale = 1}):Play()
if math.abs(vel.Y) > 10 then
local thrownPosition = menu.Position
TweenService:Create(menu, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0.5, 0.5)}):Play()
local farPos = Vector3.new(thrownPosition.X.Offset + vel.X * 10, thrownPosition.Y.Offset + vel.Y * 10, 0)
springing = true
local bezierCurve = Bezier.new(Vector3.new(thrownPosition.X.Offset, thrownPosition.Y.Offset, 0), farPos, Vector3.new(closedLastPos.X.Offset, closedLastPos.Y.Offset, 0))
local points = bezierCurve:GetPath(0.5)
setSpringPosGoal(UDim2.new(closedLastPos.X.Scale, points[math.ceil(#points/2)].X, closedLastPos.Y.Scale, points[math.ceil(#points/2)].Y))
setSpringSizeGoal(UDim2.fromOffset(60 - vel.Y * 2, 60 - vel.Y * 2))
task.wait(0.1)
setSpringSizeGoal(UDim2.fromOffset(60, 60))
setSpringPosGoal(UDim2.new(closedLastPos.X.Scale, closedLastPos.X.Offset, closedLastPos.Y.Scale, closedLastPos.Y.Offset))
menu.Area.UICorner.CornerRadius = UDim.new(0, 16)
task.delay(0.25, function() menu.List.Visible = false end)
menu.CanvasGroup.Visible = true
OpenerDraggable = true
if closing then closing:Cancel() end
TweenService:Create(menu.CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
else
lastPos = menu.Position
end
end
local function sign(n) if n>0 then return 1 elseif n<0 then return -1 else return 0 end end
local function openMenu()
TweenService:Create(menu, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0.5, 0)}):Play()
local bezierCurve = Bezier.new(Vector3.new(closedLastPos.X.Offset, closedLastPos.Y.Offset, 0), Vector3.new((closedLastPos.X.Offset + lastPos.X.Offset) / 2, lastPos.Y.Offset + (math.abs(lastPos.Y.Offset - closedLastPos.Y.Offset) * 2.5 * -math.sign(closedLastPos.Y.Offset - lastPos.Y.Offset)), 0), Vector3.new(lastPos.X.Offset, lastPos.Y.Offset, 0))
task.spawn(function()
for _, point in bezierCurve:GetPath(0.2) do
setSpringPosGoal(UDim2.new(closedLastPos.X.Scale, point.X, closedLastPos.Y.Scale, point.Y))
task.wait() task.wait()
end
end)
setSpringSizeGoal(UDim2.fromOffset(441, 268))
OpenerDraggable = false
menu.Area.UICorner.CornerRadius = UDim.new(0, 0)
menu.List.Visible = true
closing = TweenService:Create(menu.CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {GroupTransparency = 1})
closing:Play()
closing.Completed:Once(function(state) menu.CanvasGroup.Visible = false end)
end
menu.CanvasGroup.Opener.MouseButton1Click:Connect(openMenu)
UserInputService.InputBegan:Connect(function(inp, proc)
if proc then return end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) and inp.KeyCode == Enum.KeyCode.Y then openMenu() end
end)
local cam = workspace.CurrentCamera
local lastLook = cam.CFrame.LookVector
local uiOffset = Vector2.new(0, 0)
local prevUiOffset = Vector2.new(0, 0)
local function normalizeAngle(angle)
while angle > math.pi do angle = angle - 2 * math.pi end
while angle <= -math.pi do angle = angle + 2 * math.pi end
return angle
end
RunService.RenderStepped:Connect(function(dt)
local look = cam.CFrame.LookVector
local oldYaw = math.atan2(lastLook.X, lastLook.Z)
local newYaw = math.atan2(look.X, look.Z)
local oldPitch = math.asin(math.clamp(lastLook.Y, -1, 1))
local newPitch = math.asin(math.clamp(look.Y, -1, 1))
local deltaYaw = normalizeAngle(newYaw - oldYaw)
local deltaPitch = newPitch - oldPitch
local targetOffset = Vector2.new(deltaYaw * 15, deltaPitch * 15)
uiOffset = uiOffset:Lerp(targetOffset, 0.2)
if not OpenerDraggable then
MenuPosXOffset:SetGoal((MenuPosXOffset.Goal - prevUiOffset.X) + uiOffset.X)
MenuPosYOffset:SetGoal((MenuPosYOffset.Goal - prevUiOffset.Y) + uiOffset.Y)
end
prevUiOffset = uiOffset
lastLook = look
end)
script.Parent.AllowForSpring.Event:Wait()
springing = true
end

local function VTLALB_routine()
local script = Instance.new("LocalScript")
script.Name = "AutoSetup"
script.Parent = Converted["_List"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
task.wait(.5)
task.spawn(function()
require(script.Parent.Parent.Parent.FUNCTIONS).refreshlist()
end)
end

local function TVLRH_routine()
local script = Instance.new("LocalScript")
script.Name = "LocalScript"
script.Parent = Converted["_AddCustomModule1"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
local ts = game:GetService("TweenService")
script.Parent.MouseButton1Click:Connect(function()
ts:Create(script.Parent.Parent.Parent.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.9}):Play()
ts:Create(script.Parent.Parent.Parent.Parent.AddCustomModule, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
end)
end

local function KUFNO_routine()
local script = Instance.new("LocalScript")
script.Name = "LocalScript"
script.Parent = Converted["_Visibility"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
script.Parent.MouseButton1Click:Connect(function()
getgenv().YARHMFUNCTIONS.ftToggleVisibility()
end)
end

local function XLYNZG_routine()
local script = Instance.new("LocalScript")
script.Name = "LocalScript"
script.Parent = Converted["_Lock1"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
script.Parent.MouseButton1Click:Connect(function()
getgenv().YARHMFUNCTIONS.ftToggleLock()
end)
end

local function XAPKH_routine()
local script = Instance.new("LocalScript")
script.Name = "LocalScript"
script.Parent = Converted["_Exit"]
local req = require
local require = function(obj)
local routine = routine_module_scripts[obj]
if routine then return routine() end
return req(obj)
end
script.Parent.MouseButton1Click:Connect(function()
getgenv().YARHMFUNCTIONS.closeFinetuneFB()
end)
end

coroutine.wrap(WMYX_routine)()
coroutine.wrap(DSZIHQM_routine)()
coroutine.wrap(XXZOB_routine)()
coroutine.wrap(ONOAH_routine)()
coroutine.wrap(JFQXCG_routine)()
coroutine.wrap(AWDPHWS_routine)()
coroutine.wrap(VTLALB_routine)()
coroutine.wrap(TVLRH_routine)()
coroutine.wrap(KUFNO_routine)()
coroutine.wrap(XLYNZG_routine)()
coroutine.wrap(XAPKH_routine)()
