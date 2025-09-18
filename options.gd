# Options.gd
extends Control

@onready var music_slider = $MusicVolumeSlider
@onready var sfx_slider = $SFXVolumeSlider
@onready var music_percent_label = $MusicPercentLabel
@onready var sfx_percent_label = $SFXPercentLabel

func _ready():
	if not music_slider:
		print("ERROR: MusicVolumeSlider not found!")
		return
	if not sfx_slider:
		print("ERROR: SFXVolumeSlider not found!")
		return
	if not music_percent_label:
		print("ERROR: MusicPercentLabel not found!")
		return
	if not sfx_percent_label:
		print("ERROR: SFXPercentLabel not found!")
		return
	# Set slider ranges
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.value = 100
	
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.value = 100
	
	
	# Connect signals
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Load saved settings
	load_audio_settings()

func _on_music_volume_changed(value: float):
	# Update the percentage label
	music_percent_label.text = str(int(value)) + "%"
	
	var db = linear_to_db(value / 100.0)
	if value == 0:
		db = -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
	save_audio_settings()

func _on_sfx_volume_changed(value: float):
	# Update the percentage label
	sfx_percent_label.text = str(int(value)) + "%"
	
	var db = linear_to_db(value / 100.0)
	if value == 0:
		db = -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	save_audio_settings()

func load_audio_settings():
	var config = ConfigFile.new()
	if config.load("user://audio_settings.cfg") == OK:
		music_slider.value = config.get_value("audio", "music_volume", 100)
		sfx_slider.value = config.get_value("audio", "sfx_volume", 100)
		# Apply the loaded values
		_on_music_volume_changed(music_slider.value)
		_on_sfx_volume_changed(sfx_slider.value)

func save_audio_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save("user://audio_settings.cfg")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://title.tscn")
