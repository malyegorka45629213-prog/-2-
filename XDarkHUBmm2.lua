local URL = "СЮДА_СВОЮ_GITHUB_RAW_ССЫЛКУ_НА_НОВЫЙ_СКРИПТ"
local function banner(msg, col)
    local ok, g = pcall(function()
        local s = Instance.new("ScreenGui")
        if gethui then s.Parent = gethui() else s.Parent = game:GetService("CoreGui") end
        s.ResetOnSpawn = false
        local f = Instance.new("Frame", s)
        f.Size = UDim2.new(0, 700, 0, 130)
        f.Position = UDim2.new(0.5, -350, 0, 12)
        f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        f.BackgroundTransparency = 0.25
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        local t = Instance.new("TextLabel", f)
        t.Name = "Xtxt"
        t.Size = UDim2.new(1, -20, 1, -20)
        t.Position = UDim2.new(0, 10, 0, 10)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 16
        t.TextWrapped = true
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextYAlignment = Enum.TextYAlignment.Top
        t.ZIndex = 999999
        return s
    end)
    if ok and g then
        local t = g:FindFirstChild("Xtxt")
        if t then t.Text = msg; t.TextColor3 = col or Color3.fromRGB(255, 255, 255) end
    end
end
banner("качаю...")
local ok1, code = pcall(function() return game:HttpGet(URL) end)
if not ok1 or type(code) ~= "string" or #code < 100 then
    banner("НЕ скачалось:\n" .. tostring(code), Color3.fromRGB(255, 80, 80)); return
end
banner("скачано " .. #code .. " симв, компиляция...")
local fn, err = loadstring(code)
if not fn then
    banner("ОШИБКА КОМПИЛЯЦИИ:\n" .. tostring(err), Color3.fromRGB(255, 80, 80)); return
end
banner("запуск...")
local ok2, err2 = pcall(fn)
if not ok2 then
    banner("ОШИБКА ВЫПОЛНЕНИЯ:\n" .. tostring(err2), Color3.fromRGB(255, 80, 80)); return
end
banner("ГОТОВО ✓", Color3.fromRGB(80, 255, 120))
