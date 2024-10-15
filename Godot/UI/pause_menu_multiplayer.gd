extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	_set_buttons_disabled(true)  # Disable buttons at the start

func resume():
	if is_multiplayer_authority():
		unpause_game()
	else:
		rpc("rpc_unpause_game")

func pause():
	if is_multiplayer_authority():
		pause_game()
	else:
		rpc("rpc_pause_game")

func testEsc():
	if Input.is_action_just_pressed("esc"):
		if !get_tree().paused:
			pause()
		else:
			resume()
			
func pause_game():
	$AnimationPlayer.play("blur")
	print("Attempting to pause the game...")
	get_tree().paused = true
	print("Game paused: ", get_tree().paused) 
	_set_buttons_disabled(false) 

	if is_multiplayer_authority():
		rpc("rpc_pause_game")

@rpc
func rpc_pause_game():
	$AnimationPlayer.play("blur")
	print("RPC received: Pausing game on other clients.")
	get_tree().paused = true
	_set_buttons_disabled(false)  # Enable buttons on other clients

func unpause_game():
	$AnimationPlayer.play_backwards("blur")
	print("Unpausing the game...")
	get_tree().paused = false
	print("Game paused state: ", get_tree().paused)
	_set_buttons_disabled(true)  # Disable buttons when unpaused
	$Control.visible = false  # Hide control on authority

	if is_multiplayer_authority():
		rpc("rpc_unpause_game")

@rpc
func rpc_unpause_game():
	$AnimationPlayer.play_backwards("blur")
	print("RPC received: Unpausing game on other clients.")
	get_tree().paused = false
	_set_buttons_disabled(true)  # Disable buttons on other clients
	$Control.visible = false  # Hide control for clients as well

func _on_resume_pressed():
	resume()

func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

func _process(delta):
	testEsc()

# Helper function to manage button states
func _set_buttons_disabled(disabled: bool):
	$PanelContainer/VBoxContainer/resume.disabled = disabled
	$PanelContainer/VBoxContainer/restart.disabled = disabled
	$PanelContainer/VBoxContainer/quit.disabled = disabled
