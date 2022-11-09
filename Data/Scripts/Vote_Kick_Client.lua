local YOOTIL = require(script:GetCustomProperty("YOOTIL"))

local votekick_button = script:GetCustomProperty("votekick_button"):WaitForObject()
local votekick_panel = script:GetCustomProperty("votekick_panel"):WaitForObject()
local close_button = script:GetCustomProperty("close_button"):WaitForObject()
local players_list = script:GetCustomProperty("players_list"):WaitForObject()
local player_row = script:GetCustomProperty("player_row")
local message = script:GetCustomProperty("message"):WaitForObject()
local no_players = script:GetCustomProperty("no_players")

local local_player = Game.GetLocalPlayer()

local players = {}

function open_panel()
	votekick_panel.visibility = Visibility.FORCE_ON
end

function close_panel()
	votekick_panel.visibility = Visibility.FORCE_OFF
end

votekick_button.clickedEvent:Connect(function()
	if(votekick_panel.visibility == Visibility.FORCE_ON) then
		close_panel()
	else
		open_panel()
	end
end)

close_button.clickedEvent:Connect(close_panel)

function refresh_list()
	for i, c in pairs(players_list:GetChildren()) do
		c:Destroy()
	end

	if(#Game.GetPlayers() == 1) then
		World.SpawnAsset(no_players, { parent = players_list })
		
		return
	end

	local offset = 0

	for _, p in ipairs(Game.GetPlayers()) do
		if(p.id ~= local_player.id) then
			if(players[p.id] ~= nil) then
				local row = World.SpawnAsset(player_row, { parent = players_list })

				row:FindChildByName("Name").text = YOOTIL.Utils.truncate(p.name, 16, "...")
				
				local vote_btn = row:FindChildByName("Vote")

				if(players[p.id][local_player.id]) then
					vote_btn.isInteractable = false
					vote_btn:GetChildren()[1].visibility = Visibility.FORCE_ON
					vote_btn.text = ""
				else
					vote_btn.clickedEvent:Connect(function()
						players[p.id][local_player.id] = true
						YOOTIL.Events.broadcast_to_server("votekick", p.id)
						vote_btn:GetChildren()[1].visibility = Visibility.FORCE_ON
						vote_btn.text = ""
						vote_btn.isInteractable = false
					end)
				end

				row.y = offset

				offset = offset + 90
			end
		end
	end
end

Game.playerJoinedEvent:Connect(function(player)
	players[player.id] = {}

	refresh_list()
end)

Game.playerLeftEvent:Connect(function(player)
	if(players[player.id] ~= nil) then
		players[player.id] = nil
	end

	refresh_list()
end)

refresh_list()

Events.Connect("show_votekick_message", function()
	close_panel()
	votekick_button.isInteractable = false
	message.visibility = Visibility.FORCE_ON
	UI.SetCanCursorInteractWithUI(false)
	UI.SetCursorVisible(false)
end)

UI.SetCanCursorInteractWithUI(true)
UI.SetCursorVisible(true)