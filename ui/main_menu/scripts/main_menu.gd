extends Control

@onready var networking = get_node("/root/Network")
@onready var host_ip: LineEdit = $MarginContainer/VBoxContainer/HostIP

func _ready():
	networking.game_scene = "res://ui/main_scene/main_scene.tscn"

func _on_host_game_pressed():
	networking.host_game()

func _on_join_game_pressed():
	networking.join_game(host_ip.text)
