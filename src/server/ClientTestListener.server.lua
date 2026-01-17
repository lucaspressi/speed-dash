-- Este script ESCUTA mensagens do client e mostra no SERVER log
-- Se você ver "🎉 CLIENT IS ALIVE!" aqui, significa que o client está funcionando!

print("[SERVER] ClientTestListener iniciado - aguardando mensagem do client...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Espera pela pasta Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)

if not Remotes then
	warn("[SERVER] ERROR: Remotes folder not found!")
	return
end

-- Cria o RemoteEvent para o teste
local ClientAliveTest = Instance.new("RemoteEvent")
ClientAliveTest.Name = "ClientAliveTest"
ClientAliveTest.Parent = Remotes

print("[SERVER] ✅ ClientAliveTest RemoteEvent created and ready!")

-- Escuta mensagens do client
ClientAliveTest.OnServerEvent:Connect(function(player, message)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("[SERVER] 🎉 RECEBEU MENSAGEM DO CLIENT! 🎉")
	print("[SERVER] Player: " .. player.Name)
	print("[SERVER] Mensagem: " .. tostring(message))
	print("[SERVER] ✅ ISSO PROVA QUE O CLIENT ESTÁ FUNCIONANDO!")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end)

print("[SERVER] Listener conectado! Esperando client enviar mensagem...")
