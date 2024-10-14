extends Node

var client = null
var session = null
var socket = null

var level_custom_data = {
	"selected_map": null,
	"selected_char": null,
	"selected_mode": null,
	"round": null,
	"question_num": null,
	"questions": null
}

func inst():
	client = NakamaManager.client
	session = NakamaManager.session
	socket = NakamaManager.socket


func send_question():
	var questions_list = []
	questions_list.append(level_custom_data["questions"])
	var json_data = {
		"Questions": questions_list
	}
	var level_data_json = JSON.stringify(json_data)
	var write_result = await client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new("Quiz", "Quiz", 1, 1, level_data_json, "")
	])
	if write_result:
		print("New Levels collection created and level data successfully sent to Nakama.")
	else:
		print("Failed to create Levels collection and send level data.")


func _process(delta):
	pass
