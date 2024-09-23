extends Control
  
@onready var mode = $OptionButton
@onready var easy = $EasyCheckBox
@onready var normal = $NormalCheckBox2
@onready var hard = $HardCheckBox3
@onready var extreme = $ExtremeCheckBox4


var selectedMode =""

func _ready():
	add_items()

func add_items():
	mode.add_item("Bot")
	mode.add_item("Boss fight")
	mode.add_item("Survival")

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
	$MapPreview.texture = map_images[current_map_index]

func _on_button_pressed():
	var selected_map_scene = map_scenes[current_map_index]
	get_tree().change_scene_to_file(selected_map_scene)


func _on_previous_button_2_pressed():
	current_char_index -= 1
	if current_char_index < 0:
		current_char_index = character_animations.size() - 1
		  
	update_character_preview()
	
func update_character_preview():
	$CharacterPreview.play(str(current_char_index))

func _on_next_button_2_pressed():
	current_char_index += 1
	if current_char_index >= character_animations.size():
		current_char_index = 0 
	update_character_preview()


func _on_option_button_item_selected(index):
	var currentSelected = index
	
	if currentSelected==0:
		selectedMode="Bot"
	if currentSelected==1:
		selectedMode="Boss fight"
	if currentSelected==2:
		selectedMode="Survival"


func _on_uuruu_asuult_pressed():
	get_tree().change_scene_to_file("res://Scenes/control.tscn")

func _on_hard_check_box_3_toggled(toggled_on):
	pass # Replace with function body.


func _on_extreme_check_box_4_toggled(toggled_on):
	pass # Replace with function body.


func _on_easy_check_box_toggled(toggled_on):
	#if $EasyCheckBox.pressed==false:
		#if $NormalCheckBox2.pressed==true:
			#$NormalCheckBox2.pressed=false
			#$EasyCheckBox.pressed=true
	
	pass

func _on_normal_check_box_2_toggled(toggled_on):
	pass # Replace with function body.
