-- DebugLogExporter.client.lua
-- Pressione F2 para exportar logs do UIHandler

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Captura logs em tempo real
local capturedLogs = {}
local maxLogs = 200

LogService.MessageOut:Connect(function(message, messageType)
    -- Só captura logs que contêm UIHandler, PURCHASE, ou XP_GAIN
    if string.match(message, "%[UIHandler%]") or
       string.match(message, "%[PURCHASE%]") or
       string.match(message, "Boost") then

        local timestamp = os.date("%H:%M:%S")
        local logEntry = "[" .. timestamp .. "] " .. message

        table.insert(capturedLogs, logEntry)

        -- Mantém apenas os últimos maxLogs
        if #capturedLogs > maxLogs then
            table.remove(capturedLogs, 1)
        end
    end
end)

-- Cria GUI para mostrar logs
local function showLogsGui()
    -- Remove GUI antiga se existir
    local oldGui = playerGui:FindFirstChild("DebugLogsGui")
    if oldGui then
        oldGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugLogsGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Background escuro
    local background = Instance.new("Frame")
    background.Size = UDim2.new(0.8, 0, 0.8, 0)
    background.Position = UDim2.new(0.1, 0, 0.1, 0)
    background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    background.BorderSizePixel = 2
    background.BorderColor3 = Color3.fromRGB(255, 255, 0)
    background.Parent = screenGui

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "DEBUG LOGS - UIHandler & Purchases (Pressione F2 para fechar)"
    title.TextColor3 = Color3.fromRGB(255, 255, 0)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = background

    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 35)
    closeButton.Position = UDim2.new(1, -110, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "FECHAR (F2)"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = background

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- ScrollingFrame para os logs
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -90)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = background

    -- TextLabel com todos os logs
    local logsText = Instance.new("TextLabel")
    logsText.Size = UDim2.new(1, -20, 0, 0)
    logsText.Position = UDim2.new(0, 10, 0, 10)
    logsText.BackgroundTransparency = 1
    logsText.TextColor3 = Color3.fromRGB(0, 255, 0)
    logsText.TextSize = 14
    logsText.Font = Enum.Font.Code
    logsText.TextXAlignment = Enum.TextXAlignment.Left
    logsText.TextYAlignment = Enum.TextYAlignment.Top
    logsText.TextWrapped = true
    logsText.Parent = scrollFrame

    -- Monta o texto com todos os logs
    local fullText = ""
    if #capturedLogs == 0 then
        fullText = "[Nenhum log capturado ainda]\n\nClique nos botões e os logs aparecerão aqui!"
    else
        fullText = table.concat(capturedLogs, "\n")
    end

    logsText.Text = fullText

    -- Ajusta tamanho baseado no conteúdo
    local textBounds = game:GetService("TextService"):GetTextSize(
        fullText,
        logsText.TextSize,
        logsText.Font,
        Vector2.new(scrollFrame.AbsoluteSize.X - 40, math.huge)
    )

    logsText.Size = UDim2.new(1, -20, 0, math.max(textBounds.Y + 20, scrollFrame.AbsoluteSize.Y))
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logsText.AbsoluteSize.Y + 20)

    -- Instrução de cópia
    local copyHint = Instance.new("TextLabel")
    copyHint.Size = UDim2.new(1, -20, 0, 30)
    copyHint.Position = UDim2.new(0, 10, 1, -35)
    copyHint.BackgroundTransparency = 1
    copyHint.Text = "DICA: Use Ctrl+A para selecionar tudo, depois tire print e me mande!"
    copyHint.TextColor3 = Color3.fromRGB(255, 255, 100)
    copyHint.TextSize = 12
    copyHint.Font = Enum.Font.Gotham
    copyHint.Parent = background

    print("===== DEBUG LOGS EXPORTADOS =====")
    print(fullText)
    print("===== FIM DOS LOGS =====")
end

-- Bind F2 para mostrar/esconder logs
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F2 then
        local existingGui = playerGui:FindFirstChild("DebugLogsGui")
        if existingGui then
            existingGui:Destroy()
        else
            showLogsGui()
        end
    end
end)

print("[DebugLogExporter] Ready! Press F2 to export UIHandler logs")
