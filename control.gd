extends Control


func _ready():
	var src = "res://words.txt"
	var tmp = "res://filtered_words.txt"
	var pos = "?I???"
	var exclude = "ADEU"
	var poscontainexclude = "G"

	# BƯỚC 1: filter_words_by_pattern
	print("BƯỚC 1: Lọc filter_words_by_pattern")
	filter_words_by_pattern(src, pos, tmp)

	## BƯỚC 3: filter_words_not_containing_letters_to_file
	print("\nBƯỚC 2: filter_words_not_containing_letters_to_file")
	filter_words_not_containing_letters_to_file(tmp, exclude, tmp)
	
	# BƯỚC 4: filter_words_position_exclude_style
	print("\nBƯỚC 3: filter_words_position_exclude_style")
	filter_words_position_exclude_style(tmp, poscontainexclude, tmp)

	print("\nHOÀN TẤT! Kết quả: %s" % tmp)

func filter_words_position_exclude_style(
	input_path: String,
	pattern: String,          # "U1E23"
	output_path: String
) -> void:

	var temp_file = "res://temp_step.txt"

	# === BƯỚC 1: Tách pattern → lấy các chữ cái cần có ===
	var required = ""
	var i = 0
	while i < pattern.length():
		var ch = pattern[i].to_upper()
		if not required.contains(ch):
			required += ch
		i += 2  # Bỏ qua số
	print("  → Bước 1: Lọc từ có: %s" % required)

	# === BƯỚC 2: GỌI 2 HÀM RIÊNG BIỆT (theo yêu cầu) ===
	var letters_only = extract_letters_only(required)
	filter_words_containing_letters_to_file(input_path, letters_only, temp_file)
	filter_words_exclude_positions_from_file(temp_file, pattern, output_path)

	## === DỌN DẸP FILE TẠM ===
	if FileAccess.file_exists(temp_file):
		DirAccess.remove_absolute(temp_file)

	print("  Xong! Kết quả: %s\n" % output_path.get_file())

func extract_letters_only(pattern: String) -> String:
	var result = ""
	for ch in pattern:
		if ch.is_valid_identifier() and ch != "_":  # Chỉ giữ chữ cái
			if not result.contains(ch.to_upper()):
				result += ch.to_upper()
	return result

# 1. Lọc từ CÓ CHỮ (UI, UE, U, v.v.)
func filter_words_containing_letters_to_file(
	input_path: String,
	letters_str: String,      # "U", "UI", "AEI"
	output_path: String
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file: %s" % input_path)
		return

	# Chuẩn hóa: "U" → ["U"], "UI" → ["U","I"]
	var letters = []
	for ch in letters_str:
		letters.append(ch.to_upper())

	if letters.is_empty():
		push_error("letters_str rỗng!")
		return

	var matches = []

	print("  Lọc từ CÓ CHỮ: %s" % ", ".join(letters))
	print("    Đọc từ: %s → Ghi vào: %s" % [input_path.get_file(), output_path.get_file()])
	print("    " + "─".repeat(50))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var word_upper = word.to_upper()
		var has_all = true

		# Kiểm tra TỪNG chữ cái trong letters
		for ch in letters:
			if not (ch in word_upper):
				has_all = false
				break

		if has_all:
			matches.append(word)
			print("    + %s" % word)
		else:
			# In lý do loại (chỉ khi debug)
			var missing = []
			for ch in letters:
				if not (ch in word_upper):
					missing.append(ch)
			print("    - %s (thiếu: %s)" % [word, ", ".join(missing)])

	file.close()

	# GHI KẾT QUẢ
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không ghi file: %s" % output_path)
		return
	for w in matches:
		out.store_line(w)
	out.close()

	print("  Tổng: %d từ thỏa mãn.\n" % matches.size())

# 2. Loại từ ở VỊ TRÍ CẤM (U ở 1, E ở 2,3)
func filter_words_exclude_positions_from_file(input_path: String, pattern: String, output_path: String) -> void:
	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null: return

	var rules = {}
	var i = 0
	while i < pattern.length():
		var ch = pattern[i].to_upper()
		i += 1
		if i >= pattern.length(): break
		var pos = int(pattern[i])
		if not rules.has(ch): rules[ch] = []
		rules[ch].append(pos)
		i += 1

	var matches = []
	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5: continue
		var w = word.to_upper()
		var valid = true
		for ch in rules:
			for p in rules[ch]:
				if w[p] == ch: valid = false; break
			if not valid: break
		if valid: matches.append(word)
	file.close()

	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null: return
	for w in matches: out.store_line(w)
	out.close()
	
	print("  B1: Lọc ra từ bị loại:")
	
	for tex in matches:
		print("    - "+tex)
		
	print("  Tổng: %d từ thỏa mãn.\n" % matches.size())

func filter_words_with_letters_not_at_positions_simple(
	input_path: String,
	pattern: String,          # "U1E23", "A0X12"
	output_path: String
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file: %s" % input_path)
		return

	# --- PHÂN TÍCH PATTERN ---
	var rules = {}  # {"U": [1], "E": [2,3]}
	var i = 0
	while i < pattern.length():
		var ch = pattern[i].to_upper()
		if not ('A' <= ch and ch <= 'Z'):
			push_error("Chỉ dùng A-Z: %s" % ch)
			return
		i += 1
		if i >= pattern.length():
			push_error("Thiếu số sau '%s'!" % ch)
			return
		var pos_char = pattern[i]
		if not pos_char.is_valid_int():
			push_error("Phải là số 0-4: %s" % pos_char)
			return
		var pos = int(pos_char)
		if pos < 0 or pos > 4:
			push_error("Vị trí 0-4: %s" % pos)
			return
		
		if not rules.has(ch):
			rules[ch] = []
		rules[ch].append(pos)
		i += 1

	var required_letters = rules.keys()
	if required_letters.is_empty():
		push_error("Pattern rỗng!")
		return

	var matches = []

	print("  Đọc từ: %s" % input_path.get_file())
	print("  Yêu cầu:")
	print("    - PHẢI CÓ: %s" % ", ".join(required_letters))
	for letter in rules:
		print("    - '%s' ≠ vị trí: %s" % [letter, ", ".join(rules[letter].map(func(p): return str(p)))])
	print("  → Ghi vào: %s" % output_path.get_file())
	print("─".repeat(60))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var word_upper = word.to_upper()

		# 1. BẮT BUỘC PHẢI CÓ ĐỦ TẤT CẢ CHỮ CÁI TRONG PATTERN
		var has_all_required = true
		for ch in required_letters:
			if not (ch in word_upper):
				has_all_required = false
				break
		if not has_all_required:
			continue  # Loại ngay nếu thiếu U hoặc E

		# 2. Không được ở vị trí cấm
		var valid = true
		for letter in rules:
			for pos in rules[letter]:
				if word_upper[pos] == letter:
					valid = false
					break
			if not valid:
				break

		if valid:
			matches.append(word)
			print("  + %s" % word)

	file.close()

	# GHI FILE
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không ghi file: %s" % output_path)
		return
	for w in matches:
		out.store_line(w)
	out.close()

	print("  Tổng: %d từ thỏa mãn.\n" % matches.size())

func filter_words_with_letters_not_at_position_to_file(
	input_path: String,
	pattern: String,          # "U1E3", "A0X2", v.v.
	output_path: String
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở được: %s" % input_path)
		return

	# Tách pattern: "U1E3" → [{letter: 'U', pos: 1}, {letter: 'E', pos: 3}]
	var rules = []
	var i = 0
	while i < pattern.length():
		var letter = pattern[i].to_upper()
		i += 1
		if i >= pattern.length():
			push_error("Pattern lỗi: thiếu số!")
			return
		var pos = int(pattern[i])
		if pos < 0 or pos > 4:
			push_error("Vị trí phải 0-4!")
			return
		rules.append({"letter": letter, "pos": pos})
		i += 1

	# Trích xuất danh sách chữ cái cần có
	var required_letters = []
	for r in rules:
		if not (r.letter in required_letters):
			required_letters.append(r.letter)

	var matches = []

	print("  Đọc từ: %s" % input_path.get_file())
	print("  Yêu cầu:")
	print("    - Có các chữ: %s" % ", ".join(required_letters))
	for r in rules:
		print("    - '%s' ≠ vị trí %d" % [r.letter, r.pos])
	print("  → Ghi vào: %s" % output_path.get_file())
	print("─".repeat(50))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var word_upper = word.to_upper()

		# 1. Kiểm tra có đủ các chữ cái cần thiết không?
		var has_all_required = true
		for ch in required_letters:
			if not (ch in word_upper):
				has_all_required = false
				break
		if not has_all_required:
			continue

		# 2. Kiểm tra không có chữ nào ở vị trí cấm
		var valid = true
		for r in rules:
			if word_upper[r.pos] == r.letter:
				valid = false
				break

		if valid:
			matches.append(word)
			print("  + %s" % word)

	file.close()

	# GHI RA FILE
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không ghi được: %s" % output_path)
		return
	for w in matches:
		out.store_line(w)
	out.close()

	print("  Tổng: %d từ thỏa mãn.\n" % matches.size())

func filter_words_excluding_letter_at_position_to_file(
	input_path: String,
	exclude_pattern: String,  # "U1E3", "A0X2", v.v.
	output_path: String
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở được: %s" % input_path)
		return

	# Tách pattern: "U1E3" → [{letter: 'U', pos: 1}, {letter: 'E', pos: 3}]
	var rules = []
	var i = 0
	while i < exclude_pattern.length():
		var letter = exclude_pattern[i].to_upper()
		i += 1
		if i >= exclude_pattern.length():
			push_error("Pattern lỗi: thiếu vị trí!")
			return
		var pos_str = exclude_pattern[i]
		var pos = int(pos_str)
		if pos < 0 or pos > 4:
			push_error("Vị trí phải từ 0-4!")
			return
		rules.append({"letter": letter, "pos": pos})
		i += 1

	var matches = []

	print("  Đọc từ: %s" % input_path.get_file())
	print("  LOẠI nếu:")
	for rule in rules:
		print("    - '%s' ở vị trí %d" % [rule.letter, rule.pos])
	print("  → Ghi vào: %s" % output_path.get_file())
	print("─".repeat(50))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var word_upper = word.to_upper()
		var should_exclude = false

		for rule in rules:
			if word_upper[rule.pos] == rule.letter:
				should_exclude = true
				break

		if not should_exclude:
			matches.append(word)
			print("  + %s" % word)

	file.close()

	# GHI RA FILE
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không ghi được: %s" % output_path)
		return
	for w in matches:
		out.store_line(w)
	out.close()

	print("  Tổng: %d từ còn lại.\n" % matches.size())


func filter_words_by_letter_at_position_to_file(
	input_path: String, 
	word_length: int, 
	letter: String, 
	position: int, 
	output_path: String
) -> void:
	
	# Đọc file đầu vào
	var input_file = FileAccess.open(input_path, FileAccess.READ)
	if input_file == null:
		push_error("Không mở được file đầu vào: %s" % input_path)
		return
	
	var matches = []
	var target = letter.to_upper()
	
	print("  Đọc từ: %s" % input_path.get_file())
	print("  Tìm từ %d chữ cái, '%s' ở vị trí %d" % [word_length, target, position])
	print("  → Ghi vào: %s" % output_path.get_file())
	print("─".repeat(50))
	
	while !input_file.eof_reached():
		var word = input_file.get_line().strip_edges()
		if word == "":
			continue
		
		var clean = word.to_upper()
		if clean.length() == word_length and clean[position] == target:
			matches.append(word)
			print("  + %s" % word)
	
	input_file.close()
	
	# GHI KẾT QUẢ RA FILE MỚI (hoặc ghi đè)
	var output_file = FileAccess.open(output_path, FileAccess.WRITE)
	if output_file == null:
		push_error("Không thể ghi file: %s" % output_path)
		return
	
	for word in matches:
		output_file.store_line(word)
	
	output_file.close()
	
	print("  Tổng: %d từ được lưu.\n" % matches.size())

## Lọc tuần tự theo pattern và ghi đè file
func filter_words_by_pattern(
	input_path: String,
	pattern: String,          # "D???E", "??N??", "A?I?E"
	output_path: String
) -> void:

	# Kiểm tra pattern đúng 5 ký tự
	if pattern.length() != 5:
		push_error("Pattern phải đúng 5 ký tự! (ví dụ: D???E)")
		return

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file: %s" % input_path)
		return

	var matches = []
	print("  Lọc theo pattern: '%s'" % pattern)
	print("    Đọc từ: %s → Ghi vào: %s" % [input_path.get_file(), output_path.get_file()])
	print("    " + "─".repeat(50))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var word_upper = word.to_upper()
		var valid = true

		# Kiểm tra từng vị trí
		for i in 5:
			var p = pattern[i]
			if p == "?":
				continue  # Bỏ qua
			if word_upper[i] != p.to_upper():
				valid = false
				break

		if valid:
			matches.append(word)
			print("    + %s" % word)

	file.close()

	# GHI KẾT QUẢ RA FILE
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không ghi file: %s" % output_path)
		return
	for w in matches:
		out.store_line(w)
	out.close()

	print("  Tổng: %d từ thỏa mãn.\n" % matches.size())

func filter_words_containing_letters(
	input_path: String, 
	required_letters: Array,  # Danh sách chữ cái cần có (String)
	output_path: String
) -> void:
	
	var input_file = FileAccess.open(input_path, FileAccess.READ)
	if input_file == null:
		push_error("Không mở được: %s" % input_path)
		return
	
	var matches = []
	var letters_upper = []
	for ch in required_letters:
		letters_upper.append(ch.to_upper())
	
	print("  Đọc từ: %s" % input_path.get_file())
	print("  Yêu cầu có: %s" % ", ".join(letters_upper))
	print("  → Ghi vào: %s" % output_path.get_file())
	print("─".repeat(50))
	
	while !input_file.eof_reached():
		var word = input_file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue
		
		var word_upper = word.to_upper()
		var has_all = true
		
		# Kiểm tra từng chữ cái yêu cầu
		for letter in letters_upper:
			if not (letter in word_upper):
				has_all = false
				break
		
		if has_all:
			matches.append(word)
			print("  + %s" % word)
	
	input_file.close()
	
	# GHI KẾT QUẢ
	var output_file = FileAccess.open(output_path, FileAccess.WRITE)
	if output_file == null:
		push_error("Không ghi được: %s" % output_path)
		return
	
	for word in matches:
		output_file.store_line(word)
	
	output_file.close()
	print("  Tổng: %d từ thỏa mãn.\n" % matches.size())

func filter_words_not_containing_letters_to_file(
	input_path: String,
	excluded_str: String,     # "AC", "XYZ", "AEI"...
	output_path: String
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở được: %s" % input_path)
		return

	# Tự tách "AC" → ['A','C']
	var excluded = []
	for ch in excluded_str:
		excluded.append(ch.to_upper())

	var matches = []

	print("  Đọc từ: %s" % input_path.get_file())
	print("  LOẠI BỎ nếu chứa: %s" % ", ".join(excluded))
	print("  → Ghi vào: %s" % output_path.get_file())
	print("─".repeat(50))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var word_upper = word.to_upper()
		var has_excluded = false

		for ch in excluded:
			if ch in word_upper:
				has_excluded = true
				break

		if not has_excluded:
			matches.append(word)
			print("  + %s" % word)

	file.close()

	# GHI RA FILE
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không ghi được: %s" % output_path)
		return
	for w in matches:
		out.store_line(w)
	out.close()

	print("  Tổng: %d từ còn lại (không chứa %s).\n" % [matches.size(), excluded_str])
