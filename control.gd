extends Control


func _ready():
	var file_path = "res://words.txt"  # Thay đổi đường dẫn nếu cần
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Không thể mở file: " + file_path)
		push_error("Lỗi: " + str(FileAccess.get_open_error()))
		return
	
	print("Danh sách các từ trong file:")
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "":  # Bỏ qua dòng trống
			print(line)
	
	file.close()
