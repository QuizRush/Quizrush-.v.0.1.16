extends Control
@onready var checkbox1 = $Panel/Single
@onready var checkbox2 = $Panel/Multi

var selectedMode =""
var ok=false

var info=[
	preload("res://Vid/Screenshot 2024-09-24 092145.png"),
	preload("res://Vid/2dcombat.jpg"),
	preload("res://Vid/Best-Final-Boss-Fights-In-2D-Platforming-Games.jpg"),
	preload("res://Vid/Gemini_Generated_Image_effinheffinheffi.jpg"),
	preload("res://Vid/fcd4lhhkccj91.jpg"),
	preload("res://Vid/survival109141280jpg-e97a7a_160w.jpg")
]

var character_animations = [
	preload("res://Levels/characters/demon-idle.png"),
	preload("res://Levels/characters/fire-skull.png"),
	preload("res://Levels/characters/gothic-hero-idle.png"),
	preload("res://Levels/characters/Spritesheet.png"),
	preload("res://Levels/characters/sunny-dragon-fly.png")
]


var map_images = [
	preload("res://Levels/maps/gothic-castle-preview.png"),
	preload("res://Levels/maps/mist-forest-background-previewx2.png"),
	preload("res://Levels/maps/night-town-background-previewx2.png"),
	preload("res://Levels/maps/preview-day-platformer.png"),
	preload("res://Levels/maps/preview-sci-fi-environment-tileset.png")
]

var map_infos = [
	"gothic-castle",
	"mist-forest",
	"night-town",
	"platformer",
	"sci-fi-environment"
]

var char_infos = [
	"demon-idle",
	"fire-skull",
	"gothic-hero-idle",
	"Spritesheet",
	"sunny-dragon-fly"
]

func _on_checkbox_toggled(checkbox: CheckBox):
	if checkbox.pressed:
		for other_checkbox in get_tree().get_nodes_in_group("checkbox_group"):
			if other_checkbox != checkbox:
				other_checkbox.pressed = false

var map_scenes = [
	"res://Levels/level_1.tscn",
	"res://Levels/level_2.tscn",
	"res://Levels/level_3.tscn",
	"res://Levels/level_4.tscn",
	"res://Levels/level_5.tscn"
]
var current_map_index = 0
var current_char_index = 0
var toggledInfo = 0
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
	$Panel4/MapPreview.texture = map_images[current_map_index]
	$Panel4/info.text = map_infos[current_map_index]
func _on_button_pressed():
	var selected_map_scene = map_scenes[current_map_index]
	get_tree().change_scene_to_file(selected_map_scene)


func _on_previous_button_2_pressed():
	current_char_index -= 1
	if current_char_index < 0:
		current_char_index = character_animations.size() - 1
		  
	update_character_preview()
	
func update_character_preview():
	$Panel4/CharacterPreview.play(str(current_char_index))
	$Panel4/info1.text = char_infos[current_char_index]
func _on_next_button_2_pressed():
	current_char_index += 1
	if current_char_index >= character_animations.size():
		current_char_index = 0 
	update_character_preview()

func _on_single_toggled(toggled_on):
	if($Panel/Single.toggle_mode==true):
		$Panel/Multi.toggle_mode=false
		$Panel5/info.text="Solo-leveling. Bugdin gantsaaraa shaana"
	toggledInfo=0
	update_review()

func _on_multi_toggled(toggled_on):
	if($Panel/Multi.toggle_mode==true):

		$Panel/Single.toggle_mode=false
		$Panel5/info.text="Hamuudaaraa shaana."
	toggledInfo=1
	update_review()
	
func _on_boss_toggled(toggled_on):
	$Panel5/info.text="Bosstoi shaaltsana. Hard asf."
	toggledInfo=2
	update_review()
	
func _on_endless_toggled(toggled_on):
	$Panel5/info.text="Duusgaval 5k."
	toggledInfo=3
	update_review()
func _on_pv_p_toggled(toggled_on):
	$Panel5/info.text="Hamuudtaigaa shaaltsana."
	toggledInfo=4
	update_review()

func _on_survival_toggled(toggled_on):
	$Panel5/info.text="Medal edr avna."
	toggledInfo=5
	update_review()

func update_review():
	$Panel5/Info.texture = info[toggledInfo]
	
func _on_use_db_pressed():
	get_tree().change_scene_to_file("res://Scenes/qShow.tscn")
	#$Panel2/DB.disabled = false
	
func _on_custom_q_pressed():
	get_tree().change_scene_to_file("res://Scenes/control.tscn")
	#$Panel2/DB2.disabled = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
