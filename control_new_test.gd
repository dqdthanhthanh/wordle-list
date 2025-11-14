extends Control


func _ready():
	var guess_combos: Array[Array] = [
		["SOARE", "CLINT"],
		["ALTER", "NOISY"]
	]
	
	var word_list: Array = load_words_to_array("res://words.txt")
	var answer_list: Array = load_words_to_array("res://wordle-answers-alphabetical.txt")
	var total_words: int = word_list.size()
	
	print("TỔNG TỪ ĐIỂN: %d từ" % total_words)
	print("TỔNG ĐÁP ÁN: %d từ\n" % answer_list.size())
	
	# TEST CHỈ VỚI ĐÁP ÁN THỨ 10
	for combo in guess_combos:
		test_combo_single_answer(combo, word_list, answer_list, 10)

func test_combo_single_answer(combo: Array, word_list: Array, answer_list: Array, test_index: int = 10) -> void:
	# Kiểm tra chỉ số hợp lệ
	if test_index < 0 or test_index >= answer_list.size():
		print("Lỗi: Chỉ số %d không hợp lệ! (answer_list có %d từ)" % [test_index, answer_list.size()])
		return
	
	var selected_answer = answer_list[test_index].to_upper()
	var combo_name = ", ".join(combo).replace(",", " + ")
	
	print("=".repeat(70))
	print("TEST COMBO: %s" % combo_name)
	print("ĐÁP ÁN TEST (index %d): %s" % [test_index, selected_answer])
	print("-".repeat(70))
	
	var current_words: Array = word_list.duplicate()
	var initial_count: int = current_words.size()
	
	print("Bắt đầu: %d từ (100.00%%)" % initial_count)
	
	# LŨY TÍCH QUA TỪNG BƯỚC
	for i in range(combo.size()):
		var guess = combo[i].to_upper()
		var result = simulate_guess(guess, selected_answer)
		
		var next_words: Array = []
		for word in current_words:
			var w = word.to_upper()
			if is_word_valid(w, result["correct"], result["misplaced"], result["excluded"]):
				next_words.append(word)  # giữ nguyên chữ thường
		
		current_words = next_words
		var remaining = current_words.size()
		var percent = (remaining * 100.0) / initial_count
		
		print("  → Đoán: %s → Còn %d/%d từ (%.2f%%)" % [guess, remaining, initial_count, percent])
	
	print("KẾT THÚC: Còn %d/%d từ (%.2f%%)\n" % [current_words.size(), initial_count, (current_words.size() * 100.0) / initial_count])

func simulate_guess(guess: String, answer: String) -> Dictionary:
	guess = guess.to_upper()
	answer = answer.to_upper()
	
	var correct = "?????"
	var misplaced = ""
	var excluded = ""
	
	# XANH
	for i in range(5):
		if guess[i] == answer[i]:
			correct[i] = guess[i]
	
	# VÀNG + XÁM
	for i in range(5):
		var g = guess[i]
		if g in answer and guess[i] != answer[i]:
			misplaced += g + str(i)
		elif g not in answer:
			if not excluded.contains(g):
				excluded += g
	
	return {
		"correct": correct,
		"misplaced": misplaced,
		"excluded": excluded
	}

func is_word_valid(word: String, correct: String, misplaced: String, excluded: String) -> bool:
	word = word.to_upper()
	
	# XANH
	for i in range(5):
		if correct[i] != "?" and word[i] != correct[i]:
			return false
	
	# VÀNG
	var i = 0
	while i < misplaced.length():
		var ch = misplaced[i]
		if not word.contains(ch):
			return false
		i += 1
		if i < misplaced.length() and misplaced[i].is_valid_int():
			var pos = int(misplaced[i])
			if word[pos] == ch:
				return false
			i += 1
	
	# XÁM
	for ch in excluded:
		if word.contains(ch):
			return false
	
	return true

func save_array_to_file(arr: Array, path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		for item in arr:
			file.store_line(item)
		file.close()

func load_words_to_array(file_path: String) -> Array:
	var words_array = []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Không mở được file: %s" % file_path)
		return words_array
	
	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word.length() > 0:
			words_array.append(word.to_lower())
	
	file.close()
	print("Đã đọc %d từ từ: %s" % [words_array.size(), file_path.get_file()])
	return words_array

func generate_filters_from_guess(
	guess: String,
	answer: String,
	input_path: String = "res://words.txt",
	output_path: String = "res://filtered_words.txt"
) -> Dictionary:

	print("\n=== WORDLE AI - PHÂN TÍCH ĐOÁN ===")
	print("Đoán: %s | Đáp án: %s" % [guess.to_upper(), answer.to_upper()])

	if not FileAccess.file_exists(input_path):
		push_error("File không tồn tại: %s" % input_path)
		return {}

	var guess_u = guess.to_upper()
	var answer_u = answer.to_upper()

	var correct_positions = "?????"
	var misplaced_letters = ""
	var excluded_letters = ""

	print("  " + "-".repeat(50))

	# BƯỚC 1: XANH
	for i in range(5):
		if guess_u[i] == answer_u[i]:
			correct_positions[i] = guess_u[i]

	# BƯỚC 2: VÀNG – ĐƠN GIẢN NHƯ BẠN MUỐN
	for i in range(5):
		var g = guess_u[i]
		if g in answer_u:
			misplaced_letters += g + str(i)

	# BƯỚC 3: XÁM – những chữ KHÔNG có trong đáp án
	for i in range(5):
		var g = guess_u[i]
		if g not in answer_u:
			if not excluded_letters.contains(g):
				excluded_letters += g

	# IN KẾT QUẢ
	print("    Xanh: %s" % correct_positions)
	print("    Vàng: %s" % misplaced_letters)
	print("    Xám:  %s" % (excluded_letters if excluded_letters else "(không)"))

	# ÁP DỤNG LỌC
	var remaining = apply_generated_filters(
		correct_positions,
		excluded_letters,
		misplaced_letters,
		input_path,
		output_path
	)

	print("  HOÀN TẤT! Còn %d từ khả thi.\n" % remaining)

	return {
		"correct": correct_positions,
		"excluded": excluded_letters,
		"misplaced": misplaced_letters,
		"count": remaining
	}

func apply_generated_filters(
	correct_pos: String,
	excluded: String,
	misplaced: String,
	input_path: String,
	output_path: String
) -> int:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null: return 0

	var valid_words = []
	var must_have = {}
	var must_not_have = {}
	var forbidden_pos = {}

	# 1. XANH → bắt buộc đúng vị trí
	for i in range(5):
		if correct_pos[i] != "?":
			must_have[correct_pos[i]] = true

	# 2. VÀNG → phải có chữ + KHÔNG ở vị trí cấm
	var i = 0
	while i < misplaced.length():
		var ch = misplaced[i]
		must_have[ch] = true
		i += 1
		while i < misplaced.length() and misplaced[i].is_valid_int():
			var pos = int(misplaced[i])
			if correct_pos[pos] == "?" or correct_pos[pos] != ch:  # ← QUAN TRỌNG!
				forbidden_pos[pos] = ch
			i += 1

	# 3. XÁM → loại hoàn toàn
	for ch in excluded:
		must_not_have[ch] = true

	# LỌC TỪ
	while !file.eof_reached():
		var word = file.get_line().strip_edges().to_upper()
		if word.length() != 5: continue

		var ok = true

		# Phải có chữ cần
		for ch in must_have:
			if not word.contains(ch): ok = false; break
		if not ok: continue

		# Không có chữ loại
		for ch in must_not_have:
			if word.contains(ch): ok = false; break
		if not ok: continue

		# Vị trí đúng (xanh)
		for pos in range(5):
			if correct_pos[pos] != "?" and word[pos] != correct_pos[pos]:
				ok = false; break
		if not ok: continue

		# Vị trí cấm (vàng) – CHỈ CẤM NẾU KHÔNG PHẢI XANH
		for pos in forbidden_pos:
			if word[pos] == forbidden_pos[pos]:
				ok = false; break
		if not ok: continue

		valid_words.append(word.to_lower())

	file.close()

	# GHI FILE
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out != null:
		for w in valid_words:
			out.store_line(w)
		out.close()

	return valid_words.size()
