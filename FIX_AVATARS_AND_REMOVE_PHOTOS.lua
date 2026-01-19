--[[
    AJUSTAR AVATARES E REMOVER PASTA PHOTOS

    Este script vai:
    1. Remover a pasta "Photos" que está sendo gerada
    2. Ajustar avatares para 70x70 pixels
    3. Manter monitorando e removendo a pasta Photos
]]

local workspace = game:GetService("Workspace")

-- Tamanho dos avatares
local AVATAR_SIZE = 70

print("========================================")
print("🔧 AJUSTANDO AVATARES E LIMPANDO")
print("========================================")

-- Função para remover pasta Photos
local function removePhotosFolder()
    local photosFolder = workspace:FindFirstChild("Photos")
    if photosFolder then
        photosFolder:Destroy()
        print("🗑️  Pasta 'Photos' removida!")
        return true
    end
    return false
end

-- Função para ajustar avatares
local function adjustAvatars()
    local spacing = AVATAR_SIZE + 10

    for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
        local lb = workspace:FindFirstChild(lbName)
        if lb then
            local sg = lb:FindFirstChild("ScoreBlock") and lb.ScoreBlock:FindFirstChild("Leaderboard")
            if sg then
                local av = sg:FindFirstChild("Avatars")
                if av then
                    for i = 1, 10 do
                        local img = av:FindFirstChild("Avatar"..i)
                        if img and img:IsA("ImageLabel") then
                            img.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE)
                            img.Position = UDim2.new(0, 25, 0, 10 + (i-1) * spacing)
                            img.BackgroundTransparency = 1
                            img.BorderSizePixel = 0
                        end
                    end
                    print("✅ Avatares ajustados em " .. lbName .. " para " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE)
                end
            end
        end
    end
end

-- Remover pasta Photos inicial
removePhotosFolder()

-- Ajustar avatares
adjustAvatars()

-- Monitorar e remover pasta Photos se for criada novamente
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Photos" then
        warn("⚠️  Pasta 'Photos' foi criada novamente! Removendo...")
        task.wait(0.1)
        if child.Parent then
            child:Destroy()
            print("🗑️  Pasta 'Photos' removida automaticamente!")
        end
    end
end)

print("========================================")
print("✨ CONCLUÍDO!")
print("- Avatares: " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE .. " pixels")
print("- Pasta 'Photos' será removida automaticamente")
print("========================================")
print("⚠️  IMPORTANTE:")
print("1. File > Save (Ctrl+S)")
print("2. File > Publish to Roblox")
print("========================================")
