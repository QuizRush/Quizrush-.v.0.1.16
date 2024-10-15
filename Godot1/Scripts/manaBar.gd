extends Node2D

var mana_level = 1
var mana_textures = []

@onready var sprite = $Sprite2D

func _ready():
	load_mana_textures()
	update_mana_bar()

func load_mana_textures():
	mana_textures.append(load("res://art/zursan/mana1.png"))
	mana_textures.append(load("res://art/zursan/mana2.png"))
	mana_textures.append(load("res://art/zursan/mana3.png"))
	mana_textures.append(load("res://art/zursan/mana4.png"))
	mana_textures.append(load("res://art/zursan/mana5.png"))

@rpc
func increase_mana():
	if mana_level < 5:
		mana_level += 1
		update_mana_bar()
		rpc("sync_mana_level", mana_level)

@rpc
func reset_mana():
	mana_level = 1
	update_mana_bar()
	rpc("sync_mana_level", mana_level)

@rpc
func sync_mana_level(level: int):
	mana_level = level
	update_mana_bar()

func update_mana_bar():
	sprite.texture = mana_textures[mana_level - 1]
