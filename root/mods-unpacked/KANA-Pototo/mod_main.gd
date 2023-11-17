extends Node


const KANA_POTOTO_DIR := "KANA-Pototo"
const KANA_POTOTO_LOG_NAME := "KANA-Pototo"

var mod_dir_paths := {
	"base": "",
	"train_conductor": "",
	"treasure_hunter": "",
}

# --- data used by script extensions ---
var KANA_sfx: PackedScene = preload("res://mods-unpacked/KANA-Pototo/KANA-TrainConductor/custom_scenes/sfx.tscn")
var KANA_sfx_player: AudioStreamPlayer
var ContentLoader: Node

onready var KANA_bfx := get_node("/root/ModLoader/KANA-BFX")


func _init(modLoader = ModLoader) -> void:
	mod_dir_paths.base = ModLoaderMod.get_unpacked_dir().plus_file(KANA_POTOTO_DIR)
	mod_dir_paths.train_conductor = mod_dir_paths.base.plus_file("KANA-TrainConductor")
	mod_dir_paths.treasure_hunter = mod_dir_paths.base.plus_file("KANA-TreasureHunter")

	install_script_extensions(mod_dir_paths.train_conductor.plus_file("extensions"))
	install_script_extensions(mod_dir_paths.treasure_hunter.plus_file("extensions"))
	add_translations(mod_dir_paths.train_conductor.plus_file("translations"))
	add_translations(mod_dir_paths.treasure_hunter.plus_file("translations"))


func _ready() -> void:
	ContentLoader = get_node("/root/ModLoader/Darkly77-ContentLoader/ContentLoader")

	ready_train_conductor()
	ready_treasure_hunter()


func install_script_extensions(extensions_dir_path) -> void:
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("singletons/run_data.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.plus_file("main.gd"))


func add_translations(translations_dir_path) -> void:
	ModLoaderMod.add_translation(translations_dir_path.plus_file("translation.de.translation"))
	ModLoaderMod.add_translation(translations_dir_path.plus_file("translation.en.translation"))


func ready_train_conductor() -> void:
	var content_dir = mod_dir_paths.train_conductor.plus_file("content_data")

	# Add content. These .tres files are ContentData resources
	ContentLoader.load_data(content_dir.plus_file("TrainConductorContent.tres"), KANA_POTOTO_LOG_NAME)

	KANA_sfx_player = KANA_sfx.instance()
	add_child(KANA_sfx_player)


func ready_treasure_hunter() -> void:
	var content_dir = mod_dir_paths.treasure_hunter.plus_file("content_data")

	# Add content. These .tres files are ContentData resources
	ContentLoader.load_data(content_dir.plus_file("KANA_Treasure_Hunte_Content.tres"), KANA_POTOTO_LOG_NAME)

	KANA_bfx.connect("consumable_spawn_triggered", self, "_on_kana_bfx_consumable_spawn_triggered")


func play_sfx() -> void:
	if not KANA_sfx_player.playing and not KANA_bfx.state.walking_turrets.boost_active:
		KANA_sfx_player.pitch_scale = rand_range(0.9, 1.1)
		KANA_sfx_player.play()


func _on_kana_bfx_consumable_spawn_triggered(id: String, position: Vector2, triggered_by: Object) -> void:
	if triggered_by.weapon_id == "weapon_kana_shovel":
		RunData.tracked_item_effects["weapon_kana_shovel"] += 1
		triggered_by.emit_signal("tracked_value_updated")
