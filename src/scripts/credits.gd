extends Node2D

const BLUSKY_URL : String = "https://bsky.app/profile/jynus.com"
const ITCHIO_URL : String = "https://jynus.itch.io"
const WEB_URL : String = "https://jynus.com"
const GITHUB_URL : String = "https://github.com/jynus/gmtk25"

@onready var done_button : Button = %doneButton

func _ready():
	set_focus()
	%creditsText.text = "[center][color=eaa56c]" + tr("Design & programming") + ":[/color]\n\n" + \
						"Jaime Crespo \"jynus\"\n\n" + \
						"[center][color=eaa56c]" + tr("Music & Sounds") + ":[/color]\n\n" + \
						tr("Courtesy of [url=https://www.epidemicsound.com]Epidemic Sound[/url]") + "\n\n" + \
						tr("See [url=https://github.com/jynus/gmtk25]README[/url] or [url=https://jynus.itch.io/XXXXXX]Itch.io page[/url] for the full attribution list.")+ "\n\n" + \
						tr("Made with [url=https://godotengine.org]Godot[/url] 4.5-beta4 in 4 days for the [url=https://itch.io/jam/gmtk-2025]GMTK Game Jam 2025[/url]")+ "\n\n" + \
						tr("Full source code is available at [url=https://github.com/jynus/gmtk25]GitHub under the AGPL-3.0 License[/url]")+ "\n\n" + \
						"[img=800]res://assets/textures/GMTKJam2025.webp[/img]\n\n" + \
						"[/center]"

func set_focus():
	done_button.grab_focus()

func return_to_main_menu():
	"""Go back to main menu screen"""
	SceneManager.change_scene("res://scenes/main_menu.tscn", SceneManager.Transition.FADE_TO_BLACK, 0.5)

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
