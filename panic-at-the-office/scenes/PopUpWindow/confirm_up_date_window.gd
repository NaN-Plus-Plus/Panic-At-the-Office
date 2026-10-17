extends BasePopUpWindow


const ZIP_PATH := "user://update.zip"
const STAGING_PATH := "user://update_staging"

var download_url: String = ""
var http: HTTPRequest


func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_download_completed)

func _on_ok_pressed() -> void:
	if download_url.is_empty():
		print("Nie zwrócono linku!")
		return
		
	print("Próba zczytania aktualizacji")
	
	if not remove_old_update():
		return
		
	var error := http.request(download_url)
	
	if error != OK:
		print("Nie udało się pobrać", error)
		
func _on_download_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Błąd połączenia podczas pobierania: ", result)
		return
	
	if response_code != 200:
		print("Serwer zwrócił błąd HTTP: ", response_code)
		return
		
	if body.is_empty():
		print("POBRANY PLIK JEST PUSTY GASP?????")
		return
		
	var file := FileAccess.open("user://update.zip", FileAccess.WRITE)
	
	if file == null:
		print("Nie udało się zapisać ZIP-a: ", FileAccess.get_open_error())
		return
		
	file.store_buffer(body)
	file.close()
	
	print("ZIP pobrany i zapisany!")
	print("Lokalizacja: ", ProjectSettings.globalize_path("user://update.zip"))
	
	if extract_update():
		print("Aktualizacja została rozpakowana!")
		lauch_updater()
	else:
		print("Nie udało się rozpakować aktualizacji!!")


func remove_old_update() -> bool:
	var zip_path := "user://update.zip"
	
	if FileAccess.file_exists(zip_path):
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(zip_path))
		
		if error != OK:
			print("Nie udało się usunąć starego ZIP-a ", error)
			return false
		
	return true
	

func extract_update() -> bool:
	if not FileAccess.file_exists(ZIP_PATH):
		print("Nie znaleziono 'update.zip' !! ")
		return false
		
	var zip_file := FileAccess.open(ZIP_PATH, FileAccess.READ)
	
	if zip_file == null:
		print("Nie udało się otworzyć 'update.zip' !! ")
		return false
		
	if zip_file.get_length() == 0:
		print("Archiwum ZIP jest puste !! ")
		zip_file.close()
		return false
	
	zip_file.close()
	
	var zip := ZIPReader.new()
	var error := zip.open(ZIP_PATH)
	
	if error != OK:
		print("Archiwum ZIP jest uszkodzone lub nie można go otworzyć: ", error)
		zip.close()
		return false
		
	var files := zip.get_files()
	
	if files.is_empty():
		print("Archiwum nie zawiera żadnych plików")
		zip.close()
		return false
		
	if not clean_directory(STAGING_PATH):
		print("Nie udało się wyczyścić katalogu tymaczasowego")
		zip.close()
		return false
		
	var root := ProjectSettings.globalize_path(STAGING_PATH)
	error = DirAccess.make_dir_recursive_absolute(root)
	
	if error != OK:
		print("Nie udało się utowrzyć katotalogu docelowego: ", error)
		zip.close()
		return false
		
	for file_path in files:
		var relative_path := file_path.replace("\\", "/")
		
		if relative_path.begins_with("/") or ":" in relative_path:
			print("Niezabezpieczona ścieżka w ZIP-ie: ", file_path)
			zip.close()
			return false
			
		for part in relative_path.split("/"):
			if part == "..":
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
			print("Nie udało się utworzyć katalogu: ", destination)
			zip.close()
			return false
			
		var contents: PackedByteArray = zip.read_file(file_path)
		
		var output := FileAccess.open(destination, FileAccess.WRITE)
		
		if output == null:
			print("Nie udało sie zapisać pliku: ", destination)
			zip.close()
			return false
			
		output.store_buffer(contents)
		output.close()
		
	zip.close()
	
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
	var updater_path := OS.get_executable_path().get_base_dir().path_join("PanicUpdater.exe")
	var staging_path := ProjectSettings.globalize_path("user://update_staging")
	var game_path := OS.get_executable_path().get_base_dir()
	var game_pid := OS.get_process_id()
	
	if not FileAccess.file_exists(updater_path):
		push_error("Nie znaleziono PanicUpdater.exe: " + updater_path)
		return
		
	if not DirAccess.dir_exists_absolute(staging_path):
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
		push_error("Nie udało się uruchomić PanicUpdater.exe ...")
		return
		
	print("Updater uruchomiony! PID: ", updater_pid)
	
	get_tree().quit()
