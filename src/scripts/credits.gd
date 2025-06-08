extends Node2D

const BLUSKY_URL : String = "https://bsky.app/profile/jynus.com"
const ITCHIO_URL : String = "https://jynus.itch.io"
const WEB_URL : String = "https://jynus.com"
const GITHUB_URL : String = "https://github.com/jynus/gmtk24"

@onready var done_button : Button = %doneButton

func _ready():
	set_focus()
	%creditsText.text = "[center][b]" + tr("Design & programming") + "[/b]:\n\n" + \
						"Jaime Crespo \"jynus\"\n\n" + \
						"[center][b]" + tr("Music & Sounds") + "[/b]:\n\n" + \
						tr("Courtesy of Epidemic Sound") + "\n\n" + \
						tr("See [url=https://github.com/jynus/gmtk25]README[/url] or [url=https://jynus.itch.io/XXXXXX]Itch.io page[/url] for the full attribution list.")+ "\n\n" + \
						tr("* Made with Godot 4.5 in 4 days for the GMTK Game Jam 2025 *")+ "\n\n" + \
						tr("Full source code is available at GitHub under the AGPL-3.0 License") + \
						"[/center]"

func set_focus():
	done_button.grab_focus()

func return_to_main_menu():
	"""Go back to main menu screen"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_done_button_pressed():
	return_to_main_menu()

func open_web_browser(url: String):
	"""
	Opens the system web browser (or another tab, if on web) with
	the given url link
	"""
	OS.shell_open(url)

func _on_itchio_button_pressed():
	Fx.click.play()
	open_web_browser(ITCHIO_URL)

func _on_web_button_pressed():
	Fx.click.play()
	open_web_browser(WEB_URL)

func _on_github_button_pressed() -> void:
	Fx.click.play()
	open_web_browser(GITHUB_URL)


func _on_bluesky_button_pressed() -> void:
	Fx.click.play()
	open_web_browser(BLUSKY_URL)


func _on_credits_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
