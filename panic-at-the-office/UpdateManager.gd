extends Node


@export var updateWindow: PackedScene


const VERSION_URL = "https://raw.githubusercontent.com/NaN-Plus-Plus/Panic-At-The-Disco-Updates/refs/heads/main/version.json"
const CURRENT_VERSION = "0.1.0"

var latest_version: String = ""
var download_url: String = ""


func _ready() -> void:
	check_for_updates()
	

func check_for_updates() -> void:
	var http := HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(_on_version_received)
	
	var error = http.request(VERSION_URL)
	
	if error != OK:
		print("Nie udało się rozpocząć sprawdzania aktualizacji!!! ", error)
		

func _on_version_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Nie udało się połączyć z serwerem aktualizacji")
		return
	
	if response_code != 200:
		print("Błąd serwera aktualizacji: ", response_code)
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if not json is Dictionary:
		print("Nieprawidłowy format version.json")
		return
		
	latest_version = str(json.get("version", ""))
	
	var system = OS.get_name()
	
	if system == "Windows":
		download_url = str(json.get("windows_url", ""))
	elif system == "Linux":
		download_url = str(json.get("linux_url", ""))
	
	
	if latest_version.is_empty():
		print("Nie znalezniono numeru wersji")
		return
		
	print("Aktualna wersja gry: ", CURRENT_VERSION)
	print("Najnowsza wersja gry: ", latest_version)
	
	if latest_version != CURRENT_VERSION:
		var window = updateWindow.instantiate()
		window.download_url = download_url
		add_child(window)
	else:
		print("Gra jest aktualna")
		
