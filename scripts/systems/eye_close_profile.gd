class_name HotelEyeCloseProfile
extends RefCounted

var vision_radius := 100.0
var anomaly_vision_radius := 96.0
var song_vision_radius := 44.0
var slit_height_scale := 0.50
var feather_width := 42.0
var visible_brightness := 0.36
var heartbeat_stream: AudioStream
var breathing_stream: AudioStream
var song_stream: AudioStream
var heartbeat_volume_db := -8.0
var breathing_volume_db := -13.0
var song_volume_db := -7.0


func copy():
	var profile = get_script().new()
	profile.vision_radius = vision_radius
	profile.anomaly_vision_radius = anomaly_vision_radius
	profile.song_vision_radius = song_vision_radius
	profile.slit_height_scale = slit_height_scale
	profile.feather_width = feather_width
	profile.visible_brightness = visible_brightness
	profile.heartbeat_stream = heartbeat_stream
	profile.breathing_stream = breathing_stream
	profile.song_stream = song_stream
	profile.heartbeat_volume_db = heartbeat_volume_db
	profile.breathing_volume_db = breathing_volume_db
	profile.song_volume_db = song_volume_db
	return profile
