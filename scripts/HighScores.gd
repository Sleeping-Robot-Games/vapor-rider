extends Node2D

var score_row = preload("res://scenes/ScoreRow.tscn")

onready var http_request = get_node("../../HTTPRequest")

func _ready():
	http_request.connect("request_completed", self, "_on_request_completed")
	
func request_scores():
	var url = "https://high-score-api.onrender.com/api/v1/games/65fe0a2f7dbc06d1f4b97e0c/scores"
	var headers = []
	http_request.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_request_completed(result, response_code, headers, body):
	print(response_code)
	print(result)
	
	if response_code != 200:
		return
		
	var response = body.get_string_from_utf8()
	print(response)
	
	var json = JSON.parse(response)
	
	var users_data = []
			
	for user in json.result.data:
		users_data.append({
			"score": user.scores.Score,
			"name": user.username,
			"data": user
		})
	
	users_data.sort_custom(self, "sort_by_score")
	
	print(users_data)
	
	for user_data in users_data:
		var new_score_row = score_row.instance()
		new_score_row.get_node("Score").text = str(user_data.score)
		new_score_row.get_node("Name").text = str(user_data.name)
		$ScrollContainer/VBoxContainer.add_child(new_score_row)

func sort_by_score(a, b):
	if a["score"] < b["score"]:
		return -1 
	elif a["score"] > b["score"]:
		return 1 
	else:
		return 0 

func _on_HighScores_visibility_changed():
	if visible:
		for row in $ScrollContainer/VBoxContainer.get_children():
			$ScrollContainer/VBoxContainer.remove_child(row)
			row.queue_free()
		request_scores()
