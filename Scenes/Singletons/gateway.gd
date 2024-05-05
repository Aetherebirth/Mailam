extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api : MultiplayerAPI
@onready var gateway: Node = $"."

@export var port = 6942
var max_players = 100
#var cert = load("res://X509_Certificate.crt")
#var key = load("res://x509_Key.key")
#var dtls_options = TLSOptions.server(key, cert)
func _ready() -> void:
	StartServer()

func _process(delta: float) -> void:
	if not get_multiplayer() == null:
		return;
	gateway_api.poll();
	
	
func StartServer() -> void:
	print("Starting client gateway server...")
	gateway_api = MultiplayerAPI.create_default_interface()
	network.create_server(port, max_players)
	#network.host.dtls_server_setup(dtls_options)
	get_tree().set_multiplayer(gateway_api, gateway.get_path())
	gateway_api.multiplayer_peer = network
	
	network.peer_connected.connect(_peer_connected)
	network.peer_disconnected.connect(_peer_disconnected)
	
	var network_id = network.get_unique_id()
	var gateway_id = gateway_api.get_unique_id()
	
	print("Client Gateway ID: %s " % str(gateway_id))
	
@rpc("any_peer", "reliable")
func LoginRequest(username, password):
	print("Receiving login request from client")
	var player_id = multiplayer.get_remote_sender_id()
	Authenticate.AuthenticatePlayer(username, password, player_id)
	
@rpc("authority", "call_remote", "reliable")
func ReturnLoginRequest(player_id, results):
	ReturnLoginRequest.rpc_id(player_id, results)
	network.disconnect_peer(player_id)

func _peer_connected(id: int) -> void:
	print("User connected: " + str(id))
func _peer_disconnected(id: int) -> void:
	print("User disconnected: " + str(id))
