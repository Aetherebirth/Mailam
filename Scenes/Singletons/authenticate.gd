extends Node

signal connected
signal disconnected

static var is_peer_connected: bool

@export var default_port: int = 6943
@export var max_clients: int
@export var default_ip: String = "127.0.0.1"
@export var use_localhost_in_editor: bool

var network = ENetMultiplayerPeer.new()
var logon_attempts : int

func _ready() -> void:
	ConnectToServer()
	
func ConnectToServer() -> void:
	print("Connecting to Authentication Server...")
	network.create_client(default_ip,default_port)
	self.multiplayer.multiplayer_peer = network
	
	self.multiplayer.connected_to_server.connect(_connected_to_server)
	self.multiplayer.connection_failed.connect(_connection_failed)
	self.multiplayer.server_disconnected.connect(_disconnected_from_server)
	
	#var network_id = network.get_unique_id()

@rpc("any_peer", "call_remote",  "reliable")
func AuthenticatePlayer(username, password, player_id):
	print("sending out authentication request")
	AuthenticatePlayer.rpc_id(1, username, password, player_id)

@rpc("any_peer", "call_remote",  "reliable")
func AuthenticationResults(results, player_id):
	print("results received and replying to player login request")
	Gateway.ReturnLoginRequest.rpc_id(player_id, player_id, results)

func _connection_failed() -> void:
	print("Connection to auth server failed")
	disconnected.emit()
func _connected_to_server() -> void:
	print("Connected to auth server")
func _disconnected_from_server() -> void:
	print("Disconnected from auth server")

func peer_connected(id: int) -> void:
	print("Peer connected to auth: " + str(id))
func peer_disconnected(id: int) -> void:
	print("Peer disconnected from auth: " + str(id))
