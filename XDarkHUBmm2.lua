local gui = Instance.new("ScreenGui")
gui.Name = "XDarkTest"
gui.ResetOnSpawn = false
pcall(function() gui.DisplayOrder = 999999 end)

local parent = nil
if gethui and type(gethui) == "function" then
    pcall(function() parent = gethui() end)
end
if not parent then
    parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
gui.Parent = parent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(235, 30, 60)
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "GUI РАБОТАЕТ"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBlack
label.Parent = frame

print("XDark GUI test OK")
