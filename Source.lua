local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local FruitModule = require(script:WaitForChild("FruitModule"))
local RequestSpawn = ReplicatedStorage:WaitForChild("RequestSpawnFruit")

local PREFAB_FOLDER = ServerStorage:WaitForChild("Prefabs") -- contiene Fruit_Apple, etc.
local ACTIVE_FRUITS = workspace:FindFirstChild("FruitsFolder") or Instance.new("Folder", workspace)
ACTIVE_FRUITS.Name = "FruitsFolder"

-- función que crea una fruta en el mundo
local function spawnFruit(typeIndex, position)
    local info = FruitModule.Types[typeIndex]
    if not info then return end
    local prefab = PREFAB_FOLDER:FindFirstChild(info.ModelName)
    if not prefab then return end

    local clone = prefab:Clone()
    clone.Parent = ACTIVE_FRUITS
    clone.PrimaryPart = clone:FindFirstChildWhichIsA("BasePart") or clone:FindFirstChild("Handle")
    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(CFrame.new(position + Vector3.new(0, 1, 0)))
    end

    -- configuración simple: cuando un jugador toca la fruta, se "colecciona"
    local touched = false
    local function onTouched(hit)
        if touched then return end
        local plr = Players:GetPlayerFromCharacter(hit.Parent)
        if plr then
            touched = true
            -- aquí podrías dar la fruta o notificar al jugador (en desarrollo)
            local msg = Instance.new("Hint", plr.PlayerGui)
            msg.Text = "Has recogido: "..info.Name
            delay(2, function() msg:Destroy() end)
            clone:Destroy()
        end
    end

    if clone.PrimaryPart then
        clone.PrimaryPart.Touched:Connect(onTouched)
    end
end

-- spawn aleatorio periódico (solo para pruebas)
spawn(function()
    while true do
        wait(15) -- cada 15s
        local pos = FruitModule.SpawnPositions[math.random(#FruitModule.SpawnPositions)]
        local t = math.random(1, #FruitModule.Types)
        spawnFruit(t, pos)
    end
end)

-- RemoteEvent: permite que GUI pida spawnear (solo si jugador es admin)
RequestSpawn.OnServerEvent:Connect(function(player, typeIndex)
    -- seguridad: comprueba si el jugador está autorizado (aquí ejemplo simple)
    local admins = {["TuUserID"] = true} -- coloca tu UserId o usa otra lógica
    if not admins[tostring(player.UserId)] then
        return
    end
    local pos = FruitModule.SpawnPositions[1] or Vector3.new(0,5,0)
    spawnFruit(typeIndex, pos)
end)
