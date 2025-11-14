extends Control


func _ready():
	var guess:Array[String] = ["SOARE","CLINT"]
	var all_paset_anwser:Array = load_words_to_array("res://wordle-answers-alphabetical.txt")
	
	for i in all_paset_anwser:
		for j in guess:
			generate_filters_from_guess(j, i, "res://words.txt", "res://filtered_words.txt")

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
