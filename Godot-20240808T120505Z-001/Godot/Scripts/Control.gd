extends Control
class_name NakamaMultiplayer

var session: NakamaSession
var client: NakamaClient
var socket: NakamaSocket

var createdMatch
var multiplayerBridge: NakamaMultiplayerBridge

@onready var question_text = $Panel5/question_text
@onready var option_1 = $Panel5/option_1
@onready var option_2 = $Panel5/option_2
@onready var option_3 = $Panel5/option_3
@onready var option_4 = $Panel5/option_4
@onready var correct_answer = $Panel5/correct_answer
@onready var submit_button = $Panel5/submit_button

@onready var question_text2=$Panel4/LineEdit3


@onready var question_text1 = $Panel3/LineEdit
@onready var keyword=$Panel3/LineEdit2

@export var rich_text_label : RichTextLabel

static var Players = {}
var torf=false

signal onStartGame()

func _ready():
	submit_button.connect("pressed", Callable(self,"_on_submit_button_pressed"))
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")

func updateUserInfo(username, displayname, avatarurl="", language="en", location="US", timezone="GMT+8"):
	await client.update_account_async(session, username, displayname, avatarurl, language, location, timezone)

func onMatchPresence(presence: NakamaRTAPI.MatchPresenceEvent):
	print(presence)

func onMatchState(state: NakamaRTAPI.MatchData):
	print(state)

func onSocketConnected():
	print("Socket Connected")

func onSocketClosed():
	print("Socket Closed")

func onSocketReceivedError(err):
	print("Error: " + str(err))

func _process(delta):
	pass

func _on_login_button_pressed():
	session = await client.authenticate_email_async($Panel2/EmailInput.text, $Panel2/PasswordInput.text)
	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)

	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketReceivedError)
	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)

	var account = await client.get_account_async(session)
	$Panel/UserAccountText.text = account.user.username
	$Panel/DisplayNameText.text = account.user.display_name

	setupMultiplayerBridge()

func setupMultiplayerBridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)
	multiplayerBridge.match_join_error.connect(onMatchJoinError)

	var multiplayer = get_tree().get_multiplayer()
	multiplayer.set_multiplayer_peer(multiplayerBridge.multiplayer_peer)

	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)

func onPeerConnected(id):
	print("Peer connected, ID: " + str(id))
	if !Players.has(id):
		Players[id] = {
			"name": id,
			"ready": 0
		}

	if !Players.has(multiplayer.get_unique_id()):
		Players[multiplayer.get_unique_id()] = {
			"name": multiplayer.get_unique_id(),
			"ready": 0
		}

func onPeerDisconnected(id):
	print("Peer disconnected, ID: " + str(id))

func onMatchJoinError(error):
	print("Unable to join: " + error.message)

func onMatchJoin():
	print("Joined match")

func _on_join_pressed():
	multiplayerBridge.join_named_match($Panel3/LineEdit.text)

func _on_ping_pressed():
	pass

func _on_matchmaking_button_down():
	var query = "+properties.region:U +properties.rank:>=4 +properties.rank:<=10"
	var stringP = {"region": "mn"}
	var numberP = {"rank": 6}
	var ticket = await socket.add_matchmaker_async(query, 2, 4, stringP, numberP)

	if ticket.is_exception():
		print("Failed to matchmake: " + str(ticket))
		return

	print("Match ticket number: " + str(ticket))
	socket.received_matchmaker_matched.connect(onMatchMakerMatched)

func onMatchMakerMatched(matched: NakamaRTAPI.MatchmakerMatched):
	var joinedMatch = await socket.join_matched_async(matched)
	createdMatch = joinedMatch
	print("Match joined: " + str(createdMatch.match_id))

func _on_add_friend_button_down():
	var id = [$Panel4/addFriendText.text]
	var result = await client.add_friends_async(session, null, id)

func _on_get_friend_button_down():
	var result = await client.list_friends_async(session)

	for i in result.friends:
		var currentLabel = Label.new()
		currentLabel.text = i.user.display_name
		$Panel4/Panel5/VBoxContainer.add_child(currentLabel)

func _on_get_friend_2_button_down():
	var result = await client.delete_friends_async(session, [], [$Panel4/addFriendText.text])

func _on_start_button_down():
	Ready.rpc(multiplayer.get_unique_id())
	pass

@rpc("any_peer", "call_local")
func Ready(id):
	Players[id].ready = 1

	if multiplayer.is_server():
		var readyPlayers = 0
		for i in Players:
			if Players[i].ready == 1:
				readyPlayers += 1
				print(Players)
		if readyPlayers == Players.size():
			StartGame.rpc()

@rpc("any_peer", "call_local")
func StartGame():
	onStartGame.emit()
	hide()
func _on_submit_button_pressed():
	var storage_key = "QuestionList"

	# Retrieve existing questions
	var storage_object_ids = [NakamaWriteStorageObject.new("Question", storage_key, 1, 1, "", "")]
	var result = await client.read_storage_objects_async(session, storage_object_ids)

	var question_list = []
	if result.is_exception():
		print("Error retrieving questions: " + str(result))
		return

	if result.objects.size() > 0:
		print("Retrieved storage object: " + str(result.objects[0]))
		var json_instance = JSON.new()
		var parse_result = json_instance.parse(result.objects[0].value)

		if parse_result == OK:
			var data = json_instance.get_data()
			if data.has("questions"):  # Check if the key exists
				question_list = data["questions"]  # Get the existing questions
				
			else:
				print("Key 'questions' not found in data.")
		else:
			print("Error parsing JSON: " + str(parse_result))
	else:
		print("No existing questions found, creating a new list.")

	# Create the new question
	var new_question = {
		"question_text": question_text.text,
		"options": [option_1.text, option_2.text, option_3.text, option_4.text],
		"correct_answer": correct_answer.text
	}
	question_list.append(new_question) 
	print('psda') # Add the new question to the list
	print(question_list)
	print(new_question)
	# Wrap the updated question list in an object to save
	var json_data = {
		"questions": question_list
	}

	# Save the updated list back to Nakama
	var data = JSON.stringify(json_data)  # Stringify the object
	var write_result = await client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new("Question", storage_key, 1, 1, data, "")
	])

	if write_result.is_exception():
		print("Error: " + str(write_result))
		return

	print("Successfully stored")
	question_text.text = ""
	option_1.text = ""
	option_2.text = ""
	option_3.text = ""
	option_4.text = ""
	correct_answer.text = ""

func _on_submit_button_2_pressed():
	var question1 = {
		"question_text1": question_text1.text,
		"keyword": keyword.text
	}
	var data = JSON.stringify(question1)
	
	var result = await client.write_storage_objects_async(session,[
		NakamaWriteStorageObject.new("Question1", "Question1", 1, 1 ,data, "")
	])
	
	if result.is_exception():
		print("Error"+ str(result))
		return
	print("Succesfully stored")
	question_text1.text = ""
	keyword.text = ""
func _on_button_pressed():
	var question2 = {
		"question_text2": question_text2.text,
		"True or False": torf
	}
	var data = JSON.stringify(question2)
	
	var result = await client.write_storage_objects_async(session,[
		NakamaWriteStorageObject.new("Question2", "Question2", 1, 1 ,data, "")
	])
	
	if result.is_exception():
		print("Error"+ str(result))
		return
	print("Succesfully stored")
	question_text2.text = ""
func _on_check_button_toggled(checked: bool):
	if checked:
		torf=true
	else:
		torf=false
