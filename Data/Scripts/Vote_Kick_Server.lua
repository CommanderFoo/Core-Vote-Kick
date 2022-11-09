local YOOTIL = require(script:GetCustomProperty("YOOTIL"))

local players = {}

Game.playerJoinedEvent:Connect(function(player)
	players[player.id] = {}
end)

Game.playerLeftEvent:Connect(function(player)
	if(players[player.id] ~= nil) then
		players[player.id] = nil
	end
end)

function check_votes(player_id)
	local total = 0

	for k, v in pairs(players[player_id]) do
		total = total + 1
	end

	if(total == 3) then
		local player = Game.FindPlayer(player_id)
	
		YOOTIL.Events.broadcast_to_player(player, "show_votekick_message")

		Task.Spawn(function()
			player:TransferToGame("923e7b/stonehenge")
		end, 5)
	end
end

Events.ConnectForPlayer("votekick", function(voter, player_id)
	if(players[player_id] ~= nil and not players[player_id][voter.id]) then
		players[player_id][voter.id] = true

		check_votes(player_id)
	end
end)