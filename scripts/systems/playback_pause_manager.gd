class_name HotelPlaybackPauseManager
extends RefCounted

var paused_audio_players: Array[Node] = []
var paused_video_players: Array[Node] = []


func pause_tree(tree: SceneTree, root: Node) -> void:
	if tree.paused:
		return

	paused_audio_players.clear()
	paused_video_players.clear()
	_pause_playback(root)
	tree.paused = true


func resume_tree(tree: SceneTree) -> void:
	if not tree.paused:
		return

	tree.paused = false
	for player in paused_audio_players:
		if is_instance_valid(player):
			player.stream_paused = false

	for player in paused_video_players:
		if is_instance_valid(player):
			player.paused = false

	paused_audio_players.clear()
	paused_video_players.clear()


func _pause_playback(node: Node) -> void:
	if _is_audio_player(node):
		if node.playing and not node.stream_paused:
			node.stream_paused = true
			paused_audio_players.append(node)
	elif node is VideoStreamPlayer:
		if node.is_playing() and not node.paused:
			node.paused = true
			paused_video_players.append(node)

	for child in node.get_children():
		_pause_playback(child)


func _is_audio_player(node: Node) -> bool:
	return node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D
