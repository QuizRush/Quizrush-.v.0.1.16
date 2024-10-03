extends Node

var shooting := false
signal on_health_changed(node: Node, amount_changed: int)
var player_pos : Vector2
var local_player_id
