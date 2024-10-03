extends Control
class_name NakamaMultiplayer

var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var createdMatch 
var multiplayerBridge
static var Players = {}
# Called when the node enters the scene tree for the first time.
signal OnStartGame
func _ready():
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")

func updateUserInfo(username, displayname, avaterurl = "", language = "en", location = "mongolia", timezone = "UTC+8"):
	await client.update_account_async(session, username, displayname, avaterurl, language, location, timezone)
func onSocketConnected():
	print("Socket connected")
	
func onSocketClosed():
	print("Socket closed")
	
func onSocketReceivedError(err):
	print("Socket Error" + str(err))
	
func onMatchPresense(presence : NakamaRTAPI.MatchPresenceEvent ):
	print(presence)
	
func onMatchState(state : NakamaRTAPI.MatchData):
	print(state.data)
	
func _process(delta):
	#print(Players.size())
	pass


func _on_login_button_down():
	session = await client.authenticate_email_async($Panel2/EmailInput.text,$Panel2/PasswordInput.text)

	socket = Nakama.create_socket_from(client)
	await  socket.connect_async(session)
	
	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketReceivedError)
	socket.received_match_presence.connect(onMatchPresense)
	socket.received_match_state.connect(onMatchState)
	
	updateUserInfo("test", "testDisplay")
	
	var account = await client.get_account_async(session)
	
	$Panel/UserAccountText.text = account.user.username
	$Panel/DisplayNameText.text = account.user.display_name
	
	setupMultiplayerABridge()



func _on_get_data_button_button_down():
	var result = await client.read_storage_objects_async(session, [
		NakamaStorageObjectId.new("saves", "savegame", session.user_id)
	])
	
	if result.is_exception():
		print("error" + str(result))
		return
	for i in result.objects:
		print(str(i))
func _on_store_data_button_button_down():
	var saveGame = {
		"name" : "username",
		"item" : [{
			"id" : 1,
			"name" : "gun", 
			"ammo" : 0
		}]
	}
	var data = JSON.stringify(saveGame)
	var result = await  client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new("saves", "savegame", 1, 1, data, "" )
	])
	
	if result.is_exception():
		print("error" + str(result))
		return
	print("Stored data successfully")
func _on_ping_button_down():
	#sendData.rpc("hello world")
	var data = {"hello" : "world"}
	socket.send_match_state_async(createdMatch.match_id, 1, JSON.stringify(data))
@rpc("any_peer")
func sendData(message):
	print(message)

	


func _on_join_create_button_down():
	multiplayerBridge.join_named_match($Panel3/MatchName.text)
	
	#createdMatch = await  socket.create_match_async($Panel3/MatchName.text)
	#if createdMatch.is_exception():
		#print("Failed to create match" + str(createdMatch))
		#return
	#print("Created match" + str(createdMatch.match_id))

func setupMultiplayerABridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)
	multiplayerBridge.match_join_error.connect(onMatchJoinError)
	var multiplayer = get_tree().get_multiplayer()
	multiplayer.set_multiplayer_peer(multiplayerBridge.multiplayer_peer)
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	
func onPeerConnected(id):
	print("Peer connected id is : " + str(id))
	Global.local_player_id = id
	if !Players.has(id):
		Players[id] = {
			"name" : id,
			"ready" : 0
		}
	if !Players.has(multiplayer.get_unique_id()):
		Players[multiplayer.get_unique_id()] = {
			"name" : multiplayer.get_unique_id(),
			"ready" : 0
		}
	
func onPeerDisconnected(id):
	print("Peer Disconnected id is : " + str(id))
	
func onMatchJoinError(error):
	print("Unable to join match" + error.message)
	
func onMatchJoin():
	print("Joined Match with id: " + multiplayerBridge.match_id)


func _on_matchmaking_button_down():
	var query = "+properties.region : MN +properties.rank:>4 +properties.rank :<10"
	var stringP = {"region" : "MN"}
	var numberP = {"rank": 6}
	
	var ticket = await socket.add_matchmaker_async(query, 2,4, stringP, numberP)
	
	if ticket.is_exception():
		print("failed to matchmake : "+str(ticket))
		return
	print("match ticket number : "+str(ticket))
	
	socket.received_matchmaker_matched .connect(onMatchMakerMatched)
	
func onMatchMakerMatched(matched : NakamaRTAPI.MatchmakerMatched):
	var joinedMatch = await socket.join_matched_async(matched)
	createdMatch = joinedMatch
	
func _on_ready_button_down():
	Ready.rpc(multiplayer.get_unique_id())
	
@rpc("any_peer", "call_local")
func Ready(id):
	Players[id].ready = 1
	
	if multiplayer.is_server():
		var readyPlayers = 0
		for i in Players:
			if Players[i].ready == 1:
				readyPlayers += 1
		if readyPlayers == Players.size():
			StartGame.rpc()
			
@rpc("any_peer", "call_local")
func StartGame():
	hide()
	OnStartGame.emit()




