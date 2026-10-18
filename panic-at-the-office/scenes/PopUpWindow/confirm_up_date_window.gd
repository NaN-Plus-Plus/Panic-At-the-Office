extends BasePopUpWindow


const ZIP_PATH := "user://update.zip"
const STAGING_PATH := "user://update_staging"

var download_url: String = ""
var http: HTTPRequest

@onready var info: Label = $MarginContainer/VBoxContainer/VBoxContainer/Text

func _process(_delta: float) -> void:
	if http != null and http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		var total := http.get_body_size()
		var downloaded := http.get_downloaded_bytes()

		if total > 0:
			info.text = "Pobieranie: %d%%" % int(float(downloaded) / total * 100.0)
		else:
			info.text = "Łączenie z serwerem..."

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_download_completed)

func _on_ok_pressed() -> void:
	$MarginContainer/VBoxContainer/Buttons/Ok.visible = false
	$MarginContainer/VBoxContainer/Buttons/Cancer.visible = false
	if download_url.is_empty():
		info.text = "Ni ma linku! "
		print("Nie zwrócono linku!")
		return
		
	info.text = "Zczytuje aktualizacje"
	print("Próba zczytania aktualizacji")
	
	if not remove_old_update():
		return
		
	var error := http.request(download_url)
	
	print("Wynik uruchomienia żądania: ", error)
	
	if error != OK:
		info.text = "Nie udało się pobrać"
		print("Nie udało się pobrać", error)
		
func _on_download_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Otrzymano odpowiedź HTTP!")
	print("Wynik połączenia: ", result)
	print("Kod HTTP: ", response_code)
	print("Rozmiar odpowiedzi: ", body.size(), " bajtów")
	if result != HTTPRequest.RESULT_SUCCESS:
		info.text = "Błąd podczas pobierania"
		print("Błąd połączenia podczas pobierania: ", result)
		return
	
	if response_code != 200:
		info.text = "Serwer zwrócił błąd HTTP"
		print("Serwer zwrócił błąd HTTP: ", response_code)
		return
		
	if body.is_empty():
		info.text = "Pobrany plik jest pusty"
		print("POBRANY PLIK JEST PUSTY GASP?????")
		return
		
	var file := FileAccess.open("user://update.zip", FileAccess.WRITE)
	
	if file == null:
		info.text = "Nie udało się zapisać ZIP-a"
		print("Nie udało się zapisać ZIP-a: ", FileAccess.get_open_error())
		return
		
	file.store_buffer(body)
	file.close()
	
	info.text = "ZIP pobrany i zapisany!"
	print("ZIP pobrany i zapisany!")
	print("Lokalizacja: ", ProjectSettings.globalize_path("user://update.zip"))
	
	if extract_update():
		info.text = "Aktualizacja została rozpakowana!!"
		print("Aktualizacja została rozpakowana!")
		lauch_updater()
	else:
		info.text = "Nie udało się rozpakować..."
		print("Nie udało się rozpakować aktualizacji!!")


func remove_old_update() -> bool:
	var zip_path := "user://update.zip"
	
	if FileAccess.file_exists(zip_path):
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(zip_path))
		
		if error != OK:
			info.text = "Nie udało się usunąć starego ZIP-a"
			print("Nie udało się usunąć starego ZIP-a ", error)
			return false
		
	return true
	

func extract_update() -> bool:
	if not FileAccess.file_exists(ZIP_PATH):
		info.text = "Nie znaleziono update.zip"
		print("Nie znaleziono 'update.zip' !! ")
		return false
		
	var zip_file := FileAccess.open(ZIP_PATH, FileAccess.READ)
	
	if zip_file == null:
		info.text = "Nie udało się otworzyć update.zip"
		print("Nie udało się otworzyć 'update.zip' !! ")
		return false
		
	if zip_file.get_length() == 0:
		info.text = "Archiwum ZIP jest puste"
		print("Archiwum ZIP jest puste !! ")
		zip_file.close()
		return false
	
	zip_file.close()
	
	var zip := ZIPReader.new()
	var error := zip.open(ZIP_PATH)
	
	if error != OK:
		info.text = "Archiwum ZIP jest uszkodzone lub nie można go otworzyć"
		print("Archiwum ZIP jest uszkodzone lub nie można go otworzyć: ", error)
		zip.close()
		return false
		
	var files := zip.get_files()
	
	if files.is_empty():
		info.text = "Archiwum nie zawiera żadnych plików"
		print("Archiwum nie zawiera żadnych plików")
		zip.close()
		return false
		
	if not clean_directory(STAGING_PATH):
		info.text = "Nie udało się wyczyścić katalogu tymczasowego"
		print("Nie udało się wyczyścić katalogu tymaczasowego")
		zip.close()
		return false
		
	var root := ProjectSettings.globalize_path(STAGING_PATH)
	error = DirAccess.make_dir_recursive_absolute(root)
	
	if error != OK:
		info.text = "Nie udało się utworzyć katalogu docelowego"
		print("Nie udało się utowrzyć katalogu docelowego: ", error)
		zip.close()
		return false
		
	for file_path in files:
		var relative_path := file_path.replace("\\", "/")
		
		if relative_path.begins_with("/") or ":" in relative_path:
			info.text = "Niezabezpieczona ścieżka w ZIP-ie"
			print("Niezabezpieczona ścieżka w ZIP-ie: ", file_path)
			zip.close()
			return false
			
		for part in relative_path.split("/"):
			if part == "..":
				info.text = "Niebezpieczna ścieżka w ZIP-ie"
				print("Niebezpieczna ścieżka w ZIP-ie: ", file_path)
				zip.close()
				return false
				
		var destination := root.path_join(relative_path)
		
		if relative_path.ends_with("/"):
			error = DirAccess.make_dir_recursive_absolute(destination)
			
			if error != OK:
				zip.close()
				return false
				
			continue
		
		error = DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
		
		if error != OK:
			info.text = "Nie udało sie utworzyc katalogu"
			print("Nie udało się utworzyć katalogu: ", destination)
			zip.close()
			return false
			
		var contents: PackedByteArray = zip.read_file(file_path)
		
		var output := FileAccess.open(destination, FileAccess.WRITE)
		
		if output == null:
			info.text = "Nie udalo sie zapisac pliku"
			print("Nie udało sie zapisać pliku: ", destination)
			zip.close()
			return false
			
		output.store_buffer(contents)
		output.close()
		
	zip.close()
	
	info.text = "Rozpakowywanie zakończone!!"
	print("Rozpakowywanie zakończone!!")
	print("Pliki znajdują się w: ", root)
	
	return true
	

func clean_directory(path: String) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	
	if not DirAccess.dir_exists_absolute(absolute_path):
		return true
		
	var dir := DirAccess.open(absolute_path)
	if dir == null:
		print("Nie udało się otworzyć katalogu: ", absolute_path)
		return false
		
	dir.list_dir_begin()
	var entry := dir.get_next()
	
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child_path := path.path_join(entry)
			
			if dir.current_is_dir():
				if not clean_directory(child_path):
					dir.list_dir_end()
					return false
			else:
				var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(child_path))
				
				if error != OK:
					dir.list_dir_end()
					return false
					
		entry = dir.get_next()
	dir.list_dir_end()
	
	return DirAccess.remove_absolute(absolute_path) == OK


func lauch_updater() -> void:
	var updater_path := ""

	if OS.get_name() == "Windows":
		updater_path = OS.get_executable_path().get_base_dir().path_join("PanicUpdater.exe")
	else:
		updater_path = OS.get_executable_path().get_base_dir().path_join("PanicUpdater.x86_64")

	var staging_path := ProjectSettings.globalize_path("user://update_staging")
	var game_path := OS.get_executable_path().get_base_dir()
	var game_pid := OS.get_process_id()
	
	if not FileAccess.file_exists(updater_path):
		info.text = "Nie znaleziono PanicUpdater"
		push_error("Nie znaleziono PanicUpdater: " + updater_path)
		return
		
	if not DirAccess.dir_exists_absolute(staging_path):
		info.text = "Nie znaleziono folderu stagingu"
		push_error("Nie znaleziono folderu stagingu: " + staging_path)
		return
		
	var args := [
		"--",
		staging_path,
		game_path,
		str(game_pid)
	]
	
	var updater_pid := OS.create_process(updater_path, args)
	
	if updater_pid == -1:
		info.text = "Nie udało się uruchomić PanicUpdater"
		push_error("Nie udało się uruchomić PanicUpdater ...")
		return
		
	info.text = "Updater uruchomiony!"
	print("Updater uruchomiony! PID: ", updater_pid)
	
	get_tree().quit()
