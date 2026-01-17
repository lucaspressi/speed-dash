-- TESTE SUPER SIMPLES - Este script prova que o Client está rodando!
-- Ele vai aparecer tanto no CLIENT quanto no SERVER log!

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🟢 HELLO FROM CLIENT!")
print("🟢 CLIENT SCRIPT IS RUNNING!")
print("🟢 Look for this in the CLIENT tab!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Agora vamos avisar o servidor também!
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Espera os Remotes aparecerem
local success, Remotes = pcall(function()
	return ReplicatedStorage:WaitForChild("Remotes", 10)
end)

if success and Remotes then
	print("🟢 CLIENT: Found Remotes folder, checking for test event...")

	local testEvent = Remotes:FindFirstChild("ClientAliveTest")
	if testEvent then
		print("🟢 CLIENT: Firing ClientAliveTest to server!")
		testEvent:FireServer("CLIENT IS ALIVE!")
	else
		print("🟡 CLIENT: ClientAliveTest not found yet, will create on server side")
	end
else
	print("🔴 CLIENT: Could not find Remotes folder!")
end

wait(1)

print("🟢 CLIENT: Still here! This proves client works!")
