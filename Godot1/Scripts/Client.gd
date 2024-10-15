extends Control
class_name NakamaMultiplayer


var session : NakamaSession # this is the session
var client : NakamaClient # this is the client {session}
var socket : NakamaSocket # connection to nakama
var createdMatch
var multiplayerBridge : NakamaMultiplayerBridge

@onready var buttonGang = $host
@onready var buttonGeng = $join
@onready var buttonGing = $options


@onready var player_name_label = $Panel2/Panel2/Label 
@onready var player_ready_label = $Panel2/Panel2/Label2 
@onready var opponent_name_label = $Panel2/Panel3/Label 
@onready var opponent_ready_label = $Panel2/Panel3/Label2 



var character_animations = [
	preload("res://Levels/characters/demon-idle.png"),
	preload("res://Levels/characters/fire-skull.png"),
	preload("res://Levels/characters/gothic-hero-idle.png"),
	preload("res://Levels/characters/Spritesheet.png"),
	preload("res://Levels/characters/sunny-dragon-fly.png")
]

var char_pros = [
	preload("res://art/character/All_characters/Characters(100x100)/Archer/Archer/Archer-Idle-pro.png"),
	preload("res://art/character/All_characters/Characters(100x100)/Armored Axeman/Armored Axeman/Armored Axeman-Idle-pro.png"),
	preload("res://art/character/All_characters/Characters(100x100)/Greatsword Skeleton/Greatsword Skeleton/Greatsword Skeleton-Idle-pro.png"),
	preload("res://art/character/All_characters/Characters(100x100)/Swordsman/Swordsman/Swordsman-Idle-pro.png"),
	preload("res://art/character/All_characters/Characters(100x100)/Soldier/Soldier/Soldier-Idle-pro.png")

]

var map_images = [
	preload("res://multiplayerLevels/Screenshot 2024-10-13 081040.png"),
	preload("res://multiplayerLevels/Screenshot 2024-10-13 081319.png"),
	preload("res://multiplayerLevels/Background.png")
]

var map_infos = [
	"Negen ger",
	"Baigaliin saihand hunii saihantai",
	"Mist forest"
]

var char_infos = [
	"Archer",
	"Armored Axeman",
	"Greatsword Skeleton",
	"Swordsman",
	"Soldier"
]

var char_infos1 = [
	"Fanny shoots a cable in the target direction that pulls her to the first obstacle hit. She can cast this skill again within 2 seconds until her energy runs out. Each successive cast reduces the skill's energy cost by 2.
Fanny automatically casts Tornado Strike Tornado Strike upon hitting an enemy mid-flight, as long as her energy is sufficient.",
	"Hayabusa dashes in the target direction and releases four phantoms that travel in separate directions. The phantoms will remain at the end of their paths or attach themselves to the first enemy hero hit, dealing 130–180 (+30% Extra Physical Attack) Physical Damage and slowing them by 40% for 2 seconds. Hayabusa will immediately stop if he hits an enemy hero during the dash.
Use Again: Hayabusa teleports to a phantom's location and reduces the cooldown of Ninjutsu: Phantom Shuriken Ninjutsu: Phantom Shuriken by 1 second. If the phantom is attached to an enemy hero, he also deals 130–180 (+30% Extra Physical Attack) Physical Damage to the enemy.",
	"Freya strikes in the target direction, gaining a 60–260 (+70% Extra Physical Attack) shield while dealing 20–230 (+90% Extra Physical Attack) Physical Damage to enemies hit and slowing them by 30% for 0.5 seconds. Freya can cast this skill again withnin 3.5 seconds at the cost of 2 stacks of Sacred Orb.
On the 3rd cast, Freya leaps into the air and smashes the area below, dealing 26–276 (+108% Extra Physical Attack) Physical Damage to enemies within range and knocking them airborne for 0.4 seconds.",
	"Freya gains 6 stacks of Sacred Orb and enters the Valkyrie state, gaining a 600–900 (+180% Extra Physical Attack) shield and 30&Ndash;70 Physical Attack. Meanwhile, her Basic Attacks become ranged and deal splash damage. The Valkyrie state lasts for 10 seconds.",
	"Chou strikes in the target direction, dealing 180 / 200 / 220 / 240 / 260 / 280 (+70% Total Physical Attack) Physical Damage to enemies hit. This skill can be casted 3 times before it goes on coldown. On the 3rd cast, Chou also knocks enemies hit airborne.
Hitting an enemy hero with the 3rd cast resets the cooldown of Shunpo Shunpo."
]



var current_map_index = 0
var current_char_index = 0
var toggledInfo = 0
var selected_mode_sm =""
var selected_mode_be =""
var selected_mode_ps =""
var selected_t2 =""
var map
var selected_map_scene
var selected_char
var round
var q

var selectedGroup
var currentChannel
var chatChannels := {}

static var Players = {}

var party

signal OnStartGame()

# Called when the node enters the scene tree for the first time.
func _ready():
	client = Nakama.create_client("defaultkey", "163.43.113.37", 7350, "http")
	session = await client.authenticate_email_async(NakamaManager.email, NakamaManager.password)

	socket = Nakama.create_socket_from(client)
	
	await socket.connect_async(session)
	
	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketReceivedError)
	
	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)
	
	var account = await client.get_account_async(session)
	#
	$Panel2/Panel2/Label.text = account.user.display_name
	setupMultiplayerBridge()
	#subToFriendChannels()
	pass # Replace with function body.

func updateUserInfo(username, displayname, avaterurl = "", language = "en", location = "us", timezone = "est"):
	await client.update_account_async(session, username, displayname, avaterurl, language, location, timezone)

func onMatchPresence(presence : NakamaRTAPI.MatchPresenceEvent):
	print(presence)

func onMatchState(state : NakamaRTAPI.MatchData):
	print("data is : " + str(state.data))

func onSocketConnected():
	print("Socket Connected")

func onSocketClosed():
	print("Socket Closed")

func onSocketReceivedError(err):
	print("Socket Error:" + str(err))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/play/zavsariin.tscn")
	
		

func setupMultiplayerBridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)
	multiplayerBridge.match_join_error.connect(onMatchJoinError)
	var multiplayer = get_tree().get_multiplayer()
	multiplayer.set_multiplayer_peer(multiplayerBridge.multiplayer_peer)
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	
func onPeerConnected(id):
	print("Peer connected id is: " + str(id))
	var local_id = multiplayer.get_unique_id()
	if !Players.has(id):
		Players[id] = {
			"name": str(id),
			"ready": 0
		}
	if !Players.has(local_id):
		Players[local_id] = {
			"name": str(local_id),
			"ready": 0
		}
	if id == local_id:
		$Panel2/Panel2/Label.text = "You: " + Players[id]["name"]
		print(Players[id]["name"])
		$Panel2/Panel2/Label2.text = "Not Ready"
	else:
		if Players.has(id):  # Ensure the player's name exists before accessing it
			$Panel2/Panel3/Label.text = "Opponent: " + Players[id]["name"]
			print(Players[id]["name"])
			$Panel2/Panel3/Label2.text = "Not Ready"
		else:
			print("Player name not found for ID: " + str(id))


	
func onPeerDisconnected(id):
	print("Peer disconnected id is : " + str(id))
	
func onMatchJoinError(error):
	print("Unable to join match: " + error.message)

func onMatchJoin():
	print("joined Match with id: " + multiplayerBridge.match_id)
func _on_store_data_button_down():
	var saveGame = {
		"name" : "username",
		"items" : [{
			"id" : 1,
			"name" : "gun",
			"ammo" : 10
		},
		{
			"id" : 2,
			"name" : "sword",
			"ammo" : 0
		}],
		"level" : 10
	}
	var data = JSON.stringify(saveGame)
	var result = await client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new("saves", "savegame2", 1, 1, data , "")
	])
	
	if result.is_exception():
		print("error" + str(result))
		return
	print("Stored data successfully!")
	pass # Replace with function body.


func _on_get_data_button_down():
	var result = await client.read_storage_objects_async(session, [
		NakamaStorageObjectId.new("saves", "savegame", session.user_id)
	])
	
	if result.is_exception():
		print("error" + str(result))
		return
	for i in result.objects:
		print(i.value)
	pass # Replace with function body.


func _on_list_data_button_down():
	var dataList = await client.list_storage_objects_async(session, "saves",session.user_id, 5)
	for i in dataList.objects:
		print(i)
	pass # Replace with function body.matchmakin


func _on_join_create_match_button_down():
	multiplayerBridge.join_named_match($Panel3/MatchName.text)
	
	#createdMatch = await socket.create_match_async($Panel3/MatchName.text)
	#if createdMatch.is_exception():
		#print("Failed to create match " + str(createdMatch))
		#return
	#
	#print("Created match :" + str(createdMatch.match_id))
	pass 



@rpc("any_peer")
func sendData(message):
	print(message)

func _on_matchmaking_button_down():
	$Panel2/Panel2/Label2.text = "Ready"
	var query = "+properties.region:US +properties.rank:>=4 +properties.rank:<=10"
	var stringP = {"region" : "US"}
	var numberP = { "rank": 6}
	
	var ticket = await socket.add_matchmaker_async(query,2, 4, stringP, numberP)
	
	if ticket.is_exception():
		print("failed to matchmake : " + str(ticket))
		return
	
	print("match ticket number : " + str(ticket))
	
	socket.received_matchmaker_matched.connect(onMatchMakerMatched)
	pass # Replace with function body.

func onMatchMakerMatched(matched : NakamaRTAPI.MatchmakerMatched):
	var joinedMatch = await socket.join_matched_async(matched)
	createdMatch = joinedMatch

######### Friends 
func _on_add_friend_button_down():
	var id = [$Panel4/AddFriendText.text]
	
	var result = await client.add_friends_async(session, null, id)
	pass # Replace with function body.


func _on_get_friends_button_down():
	var result = await client.list_friends_async(session)
	
	for i in result.friends:
		var container = HBoxContainer.new()
		var currentlabel = Label.new()
		currentlabel.text = i.user.display_name
		container.add_child(currentlabel)
		print(i)
		var currentButton = Button.new()
		container.add_child(currentButton)
		currentButton.text = "Trade"
		#currentButton.text = "Invite"

		#currentButton.button_down.connect(onInviteToParty.bind(i))
		$Panel4/Panel4/VBoxContainer.add_child(container)
		
	pass # Replace with function body.


func _on_remove_friend_button_down():
	var result = await client.delete_friends_async(session,[], [$Panel4/AddFriendText.text])
	pass # Replace with function body.


func _on_block_friends_button_down():
	var result = await client.block_friends_async(session,[], [$Panel4/AddFriendText.text])
	pass # Replace with function body.


func _on_create_group_button_down():
	var group = await client.create_group_async(session, $Panel6/GroupName.text, $Panel6/GroupDesc.text, "" , "en", true, 32)
	print(group)
	pass # Replace with function body.


func _on_get_group_memebers_button_down():
	var result = await client.list_group_users_async(session, $Panel5/GroupName.text)
	
	for i in result.group_users:
		var currentlabel = Label.new()
		currentlabel.text = i.user.display_name
		$Panel5/Panel4/GroupVBox.add_child(i.user.username)
		print("users in group " + $Panel5/GroupName.text  + i.user.username)
	pass # Replace with function body.


func _on_button_button_down():
	Ready.rpc(multiplayer.get_unique_id())
	
	pass # Replace with function body.
var currentID 
@rpc("any_peer", "call_local")
func Ready(id):
	Players[id].ready = 1
	
	$Panel2/Panel3/Label2.text = "Ready"
	if multiplayer.is_server():
		var readyPlayers = 0
		for i in Players:
			if Players[i].ready == 1:
				readyPlayers += 1
		if readyPlayers == Players.size():
			StartGame.rpc()

@rpc("any_peer", "call_local")
func StartGame():
	#Map info
	selected_map_scene = map_infos[current_map_index]
	#Character
	selected_char = char_infos[current_char_index]
	
	selected_mode_sm = "MultiPlayer"
	if($Panel8/mode/PvP.button_pressed):
		selected_mode_ps = "PvP"
	else:
		selected_mode_ps = "Survival"
			
	MultiplayerNakamaManager.level_custom_data["selected_map"] = selected_map_scene
	MultiplayerNakamaManager.level_custom_data["selected_char"] = selected_char
	MultiplayerNakamaManager.level_custom_data["selected_mode"] = {
		"Multiplayer": selected_mode_sm,
		"PvpSurvival": selected_mode_ps
	}
	MultiplayerNakamaManager.level_custom_data["round"] = $Panel8/mode/Panel9/LineEdit.text
	MultiplayerNakamaManager.level_custom_data["question_num"] = $Panel8/mode/Panel9/LineEdit2.text
	OnStartGame.emit()
	hide()
	pass

func _on_join_chat_room_button_down():
	var type = NakamaSocket.ChannelType.Room
	currentChannel = await socket.join_chat_async($Panel7/ChatName.text, type, false, false)
	
	print("channel id: " + currentChannel.id)
	pass # Replace with function body.

func onChannelMessage(message : NakamaAPI.ApiChannelMessage):
	var content = JSON.parse_string(message.content)
	if content.type == 0:
		$Panel7/Chat/TabContainer.get_node(content.id).text += message.username + ": " + str(content.message) + "\n"
	elif content.type == 1 && party == null:
		$Panel8/Panel2.show()
		party = {"id" : content.partyID}
		$Panel8/Panel2/Label.text = str(content.message)
		pass

func _on_submit_chat_button_down():
	await socket.write_chat_message_async(currentChannel.id, {
		"message" : $Panel7/Chat/ChatText.text,
		"id" : chatChannels[currentChannel.id].label,
		"type" : 0
		})
	pass # Replace with function body.


func _on_join_group_chat_room_button_down():
	var type = NakamaSocket.ChannelType.Group
	currentChannel = await socket.join_chat_async(selectedGroup.id, type, true, false)
	
	print("channel id: " + currentChannel.id)
	chatChannels[selectedGroup.id] = {
		"channel" : currentChannel,
		"label" : "Group Chat"
		}
	var currentEdit = TextEdit.new()
	currentEdit.name = "currentGroup"
	$Panel7/Chat/TabContainer.add_child(currentEdit)
	currentEdit.text = await listMessages(currentChannel)
	$Panel7/Chat/TabContainer.tab_changed.connect(onChatTabChanged.bind(selectedGroup.id))
	
	pass # Replace with function body.

func onChatTabChanged(index, channelID):
	currentChannel = chatChannels[channelID].channel
	pass
	
func listMessages(currentChannel):
	
	var result = await  client.list_channel_messages_async(session, currentChannel.id, 100, true)
	var text = ""
	for message in result.messages:
		if(message.content != "{}"):
			var content = JSON.parse_string(message.content)
		
			text += message.username + ": " + str(content.message) + "\n"
	return text
	
func subToFriendChannels():
	var result = await client.list_friends_async(session)
	for i in result.friends:
		var type = NakamaSocket.ChannelType.DirectMessage
		var channel = await socket.join_chat_async(i.user.id, type, true, false)
		chatChannels[channel.id] = {
		"channel" : channel,
		"label" : i.user.username
		} 
		var currentEdit = TextEdit.new()
		currentEdit.name = i.user.username
		$Panel7/Chat/TabContainer.add_child(currentEdit)
		currentEdit.text = await listMessages(channel)
		$Panel7/Chat/TabContainer.tab_changed.connect(onChatTabChanged.bind(channel.id))

func _on_join_direct_chat_button_down():
	var type = NakamaSocket.ChannelType.DirectMessage
	var usersResult = await  client.get_users_async(session, [], [$Panel7/ChatName.text])
	if usersResult.users.size() > 0:
		currentChannel = await socket.join_chat_async(usersResult.users[0].id, type, true, false)
		
		print("channel id: " + currentChannel.id)
		
		var result = await  client.list_channel_messages_async(session, currentChannel.id, 100, true)
		
		for message in result.messages:
			if(message.content != "{}"):
				var content = JSON.parse_string(message.content)
			
				$Panel7/Chat/ChatTextBox.text += message.username + ": " + str(content.message) + "\n"
		
	
	pass 

func _on_host_pressed():
	buttonGang.set_size(Vector2(63,63))
	buttonGang.position = (Vector2(310,70))
	buttonGeng.position = (Vector2(380,90))
	buttonGing.position = (Vector2(450,90))
	buttonGeng.set_size(Vector2(63,43)) 
	buttonGing.set_size(Vector2(63,43)) 
	var style_box = StyleBoxFlat.new()
	style_box.bg_color =Color(0.004, 0.063, 0.094)
	$Panel3.add_theme_stylebox_override("panel", style_box)
	$Panel3.visible = true
	$Panel8.visible = false
	$Panel3/JoinCreateMatch.text = "Create"
func _on_join_pressed():
	buttonGang.set_size(Vector2(63,43)) 
	buttonGang.position = (Vector2(310,90))
	buttonGeng.position = (Vector2(380,70))
	buttonGing.position = (Vector2(450,90))
	
	buttonGeng.set_size(Vector2(63,63))
	buttonGing.set_size(Vector2(63,43)) 
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.17, 0.155, 0.29)
	$Panel3.add_theme_stylebox_override("panel", style_box)
	$Panel3.visible = true
	$Panel8.visible = false
	$Panel3/JoinCreateMatch.text = "Join"

func _on_options_pressed():
	buttonGang.set_size(Vector2(63,43)) 
	buttonGeng.set_size(Vector2(63,43))
	buttonGang.position = (Vector2(310,90))
	buttonGeng.position = (Vector2(380,90))
	buttonGing.position = (Vector2(450,70))
	buttonGing.set_size(Vector2(63,63)) 
	$Panel3.visible = false
	$Panel8.visible = true
	

func _on_next_button_pressed():
	current_map_index += 1
	if current_map_index >= map_images.size():
		current_map_index = 0  
	update_map_preview()

func _on_previous_button_pressed():
	current_map_index -= 1
	if current_map_index < 0:
		current_map_index = map_images.size() - 1  
	update_map_preview()

func update_map_preview():
	print("sda")
	print(map_infos[current_map_index])
	$Panel8/map/MapPreview.texture = map_images[current_map_index]
	$Panel8/map/info.text = map_infos[current_map_index]
	
func _on_previous_button_2_pressed():
	current_char_index -= 1
	if current_char_index < 0:
		current_char_index = character_animations.size() - 1
	update_character_preview()

func update_character_preview():
	$Panel8/char/CharacterPreview.play(str(current_char_index))
	$Panel8/char/info1.text = char_infos[current_char_index]
	$Panel8/char/Label.text = char_infos1[current_char_index]
	$Panel2/Panel2/Werewolf11.texture = char_pros[current_char_index]
	
func _on_next_button_2_pressed():
	current_char_index += 1
	if current_char_index >= character_animations.size():
		current_char_index = 0
	update_character_preview()


func _on_button_pressed():
	$Panel8/map.visible = true
	$Panel8/char.visible = false
	$Panel8/mode.visible = false
	


func _on_button_2_pressed():
	$Panel8/map.visible = false
	$Panel8/char.visible = true
	$Panel8/mode.visible = false


func _on_button_3_pressed():
	$Panel8/map.visible = false
	$Panel8/char.visible = false
	$Panel8/mode.visible = true


func _on_use_db_pressed():
	$qshow.visible = true
	if($Panel8/mode/Panel9/DB.button_pressed == false):
		$Panel8/mode/Panel9/DB.button_pressed = true
	if($Panel8/mode/Panel9/DB2.button_pressed == true):
		$Panel8/mode/Panel9/DB2.button_pressed=false
	$Panel8/mode/Panel9/DB2.disabled = true
	$Panel8/mode/Panel9/CustomQ.disabled = true


func _on_custom_q_pressed():
	pass # Replace with function body.
