extends Control

#region Signals

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

#endregion

@onready var host_ip: LineEdit = $MarginContainer/VBoxContainer/HostIP
const PORT: int = 7000
const DEFAULT_SERVER_IP: String = "127.0.0.1"
const MAX_CONNECTIONS: int = 20

var players = {}

var player_info = {"name": "Name"}
var players_loaded: int = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_host_game_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	load_game.rpc_id(1, "res://ui/main_scene/main_scene.tscn")

func _on_join_game_pressed():
	var address: String = host_ip.text
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

#region Events

@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			players_loaded = 0

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

#region Multiplayer Signal Handlers

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	print("Connected: ", peer_id, " ", players[peer_id])
	player_connected.emit(peer_id, player_info)
	
	load_game.rpc_id(peer_id, "res://ui/main_scene/main_scene.tscn")

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

#endregion

#endregion
