extends Node2D

@onready var back_button: Button = %backButton
@onready var you_won_text: RichTextLabel = %youWonText

func _ready() -> void:
	back_button.grab_focus()
	%youWonText.text="[center]" + tr("Congratulations.") + "\n" + \
	tr("You reached the last level of this mace.") + "\n\n\n\n\n" + \
	tr("Please consider [color=darkblue][url=https://itch.io/jam/gmtk-2025/rate/3627164]rating this game for the GMTK Jam[/url][/color] or leaving [color=darkblue][url=https://jynus.itch.io/cursed-room]a comment[/url][/color].") + \
	"[/center]"

func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")

func _on_credits_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/credits.tscn")

func _on_you_won_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
