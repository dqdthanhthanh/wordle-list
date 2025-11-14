extends Control


func _ready():
	var guess_combos: Array[Array] = [
		["SOARE", "CLINT"],
		["ALTER", "NOISY"],
		["ADIEU", "SPORT"],
		["RAISE", "COUNT"]
	]
	
	var word_list: Array = load_words_to_array("res://words.txt")
	var answer_list: Array = load_words_to_array("res://wordle-answers-alphabetical.txt")
	var total_words: int = word_list.size()
	
	print("TỔNG TỪ ĐIỂN: %d từ" % total_words)
	print("TỔNG ĐÁP ÁN: %d từ\n" % answer_list.size())
	
	# NHẬP KHOẢNG TEST TẠI ĐÂY
	var start_idx: int = 0
	var end_idx: int = 100   # ← THAY ĐỔI TẠI ĐÂY: 0,10 / 0,100 / 500,510...
	
	var summary: Array[Dictionary] = []
	
	for combo in guess_combos:
		var result = test_combo_range(combo, word_list, answer_list, start_idx, end_idx)
		summary.append({
			"name": "-".join(combo),
			"avg": result.avg,
			"count": result.count
		})
	
	# TỔNG KẾT ĐÚNG SỐ ĐÁP ÁN
	print("=".repeat(80))
	print("TỔNG KẾT HIỆU QUẢ COMBO (trên đáp án %d–%d):" % [start_idx, end_idx])
	print("-".repeat(80))
	for item in summary:
		print("Combo %s: %.3f%% (trên %d đáp án)" % [item["name"], item["avg"], item["count"]])
	print("=".repeat(80))

func test_combo_range(combo: Array, word_list: Array, answer_list: Array, 
					  start_idx: int, end_idx: int) -> Dictionary:
	var combo_name = ", ".join(combo).replace(",", " + ")
	print("=".repeat(70))
	print("TEST COMBO: %s (đáp án %d → %d)" % [combo_name, start_idx, end_idx])
	print("-".repeat(70))
	
	var initial_count: int = word_list.size()
	var total_percent: float = 0.0
	var valid_count: int = 0
	
	for idx in range(start_idx, end_idx + 1):
		if idx >= answer_list.size():
			print("Cảnh báo: Index %d vượt quá (chỉ có %d đáp án)" % [idx, answer_list.size()])
			break
		
		var answer = answer_list[idx].to_upper()
		var current_words: Array = word_list.duplicate()
		
		for guess in combo:
			guess = guess.to_upper()
			var result = simulate_guess(guess, answer)
			var next_words: Array = []
			for word in current_words:
				var w = word.to_upper()
				if is_word_valid(w, result["correct"], result["misplaced"], result["excluded"]):
					next_words.append(word)
			current_words = next_words
		
		var percent = (current_words.size() * 100.0) / initial_count
		print("  [#%d: %s] → %.3f%%" % [idx, answer, percent])
		
		total_percent += percent
		valid_count += 1
	
	var avg_percent = total_percent / valid_count if valid_count > 0 else 0.0
	print("→ Trung bình: %.3f%% (trên %d đáp án)\n" % [avg_percent, valid_count])
	
	return {"avg": avg_percent, "count": valid_count}

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
