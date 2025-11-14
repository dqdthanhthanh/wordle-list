extends Control

"
Lượt 1: Dùng từ test E,A,R,S,T → loại ~40% (900+ từ)
Lượt 2: Dùng từ test D,O,L,N,C → loại ~30%
Lượt 3: Còn ~100 từ → dùng Wordle Bot để chọn tối ưu

ALTER
NOISY

PUNCH
DUNCH
WHUMP
"

@onready var pos1 = $VBoxContainer/HBoxContainer/LineEditSTT1
@onready var pos2 = $VBoxContainer/HBoxContainer/LineEditSTT2
@onready var pos3 = $VBoxContainer/HBoxContainer/LineEditSTT3
@onready var pos4 = $VBoxContainer/HBoxContainer/LineEditSTT4
@onready var pos5 = $VBoxContainer/HBoxContainer/LineEditSTT5

@onready var rich_label: RichTextLabel = $RichTextLabel
@onready var input_pos: LineEdit = $VBoxContainer/HBoxContainer/LineEdit
@onready var input_exclude: LineEdit = $VBoxContainer/HBoxContainer/LineEdit2
@onready var input_poscontainexclude: LineEdit = $VBoxContainer/HBoxContainer/LineEdit3

var path:Array[String] = ["res://filtered_words.txt",
"res://best_suggestions.txt",
"res://order_words.txt",
"res://valid-wordle-words.txt",
"res://ranked_words.txt",
"res://ranked_words_all.txt",
"res://ranked_words_answer.txt",
"res://all_past_anwser.txt"]

#var all_word:String = "res://valid-wordle-words.txt"
#var all_answer:String = "res://order_words.txt"
#var all_answer_past:String = "res://wordle-answers-alphabetical.txt"
var src:String = "res://order_words.txt"
var tmp:String = "res://filtered_words.txt"
var pos:String = "?????"
var exclude:String = ""
var poscontainexclude:String = ""

#LURID ATEGO L2R5I3D4

func check_wordsle():
	if $VBoxContainer/HBoxContainer2/CheckBox.button_pressed == false:
		src = path[2]
	else:
		src = path[3]
	
	pos = get_pattern()
	exclude = input_exclude.text
	poscontainexclude = input_poscontainexclude.text
	
	# BƯỚC 1: filter_words_by_pattern
	print("BƯỚC 1: Lọc filter_words_by_pattern")
	filter_words_by_pattern(src, pos, tmp)
	await get_tree().create_timer(0.5).timeout
	
	## BƯỚC 3: filter_words_not_containing_letters_to_file
	print("\nBƯỚC 2: filter_words_not_containing_letters_to_file")
	filter_words_not_containing_letters_to_file(tmp, exclude, tmp)
	await get_tree().create_timer(0.5).timeout
	
	# BƯỚC 4: filter_words_position_exclude_style
	print("\nBƯỚC 3: filter_words_position_exclude_style")
	filter_words_position_exclude_style(tmp, poscontainexclude, tmp)
	await get_tree().create_timer(0.5).timeout
#
	#print("\nHOÀN TẤT! Kết quả: %s" % tmp)
	print("\nHOÀN TẤT! Kết quả: %s")
	
	#"res://ranked_words.txt"
	rank_worle_words(tmp)
	
	## Bước 2: ĐÁNH GIÁ % CHỮ TRONG GỢI Ý
	#rank_words_advanced(tmp,"res://best_suggestions.txt")
	rank_big_list_by_small_list(tmp, src, "res://best_suggestions.txt")
	#rank_words_by_letter_frequency(tmp,"res://best_suggestions.txt")
	#evaluate_suggestions_frequency("res://best_suggestions.txt")

@warning_ignore("unused_parameter")
func _on_check_box_toggled(toggled_on: bool) -> void:
	_on_button_pressed()

func _on_button_clear_pressed() -> void:
	clear_pattern()
	input_pos.text = "?????"
	input_exclude.text = ""
	input_poscontainexclude.text = ""
	_on_button_pressed()

func _on_button_pressed() -> void:
	$TabContainer.get_child(0).text = "Wellcome to MGF Wordle Tools \n Loading... Please waiting!"
	prints($TabContainer.get_child(0).text)
	check_wordsle()
	await get_tree().create_timer(3).timeout
	update_tab($TabContainer.current_tab)

func _on_tab_container_tab_changed(tab: int) -> void:
	$TabContainer.get_child(0).text = "Wellcome to MGF Wordle Tools \n Loading... Please waiting!"
	prints($TabContainer.get_child(tab).text)
	update_tab(tab)

func update_tab(tab: int):
	show_text_from_file($TabContainer.get_child(tab),path[tab])


func get_pattern() -> String:
	var positions = [pos1, pos2, pos3, pos4, pos5]
	var pattern = ""
	
	for p in positions:
		var text = p.text.strip_edges()
		if text == "":
			pattern += "?"  # Nếu rỗng thì dùng dấu ?
		else:
			pattern += text[0].to_upper()  # Lấy ký tự đầu và chuyển hoa

	return pattern

func clear_pattern() -> void:
	var positions = [pos1, pos2, pos3, pos4, pos5]
	
	for p in positions:
		p.text = ""

func _ready():
	#analyze_letter_frequency(src)
	
	_on_button_pressed()
	
	# DỮ LIỆU TẦN SUẤT BẠN CUNG CẤP
	#rank_worle_words(all)
	#filter_words_not_containing_letters_to_file("res://valid-wordle-words.txt", "ALTER", tmp)
	#rank_worle_words(tmp)
	#filter_words_not_containing_letters_to_file("res://valid-wordle-words.txt", "ALTERNOISY", tmp)
	#rank_worle_words(tmp)
	
	#full_check_word_stats("stump")

@warning_ignore("shadowed_variable")
func show_text_from_file(node:RichTextLabel, path: String) -> void:
	if not FileAccess.file_exists(path):
		node.text = "[color=red]Không tìm thấy file: %s[/color]" % path
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		node.text = "[color=red]Không thể đọc file![/color]"
		return

	var content = file.get_as_text()
	file.close()

	node.clear()
	node.text = ""
	node.text = content

func rank_big_list_by_small_list(small_path: String, big_path: String, output_path: String = "res://best_suggestions.txt") -> void:
	# --- Bước 1: đọc danh sách nhỏ ---
	var small_list = _load_words(small_path)
	if small_list.is_empty():
		push_error("Không có từ nào trong danh sách nhỏ!")
		return

	# --- Bước 2: đọc danh sách lớn ---
	var big_list = _load_words(big_path)
	if big_list.is_empty():
		push_error("Không có từ nào trong danh sách lớn!")
		return

	# --- Bước 3: tạo tập chữ cái xuất hiện trong danh sách nhỏ ---
	var letters_small := {}
	for word in small_list:
		for ch in word.to_upper():
			letters_small[ch] = true

	# --- Bước 4: tính điểm cho từng từ trong danh sách lớn ---
	var ranked := []
	for word in big_list:
		var score = 0
		var used := {}
		for ch in word.to_upper():
			if letters_small.has(ch) and not used.has(ch):
				score += 1
				used[ch] = true
		ranked.append({
			"word": word,
			"score": score,
			"letters": used.keys()
		})

	# --- Bước 5: sắp xếp giảm dần ---
	ranked.sort_custom(func(a, b): return a.score > b.score)

	# --- Bước 6: lưu kết quả ---
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Không thể ghi file: %s" % output_path)
		return

	file.store_line("# XẾP HẠNG DANH SÁCH LỚN THEO DANH SÁCH NHỎ")
	file.store_line("# Small list: %s" % small_path.get_file())
	file.store_line("# Big list: %s\n" % big_path.get_file())

	for i in range(ranked.size()):
		var r = ranked[i]
		file.store_line("%3d. %-12s  (%d chữ trùng: %s)" % [i+1, r.word, r.score, ", ".join(r.letters)])

	file.close()
	print("✅ Kết quả đã lưu vào: %s" % output_path)


# --- Hàm phụ: đọc file danh sách từ ---
@warning_ignore("shadowed_variable")
func _load_words(path: String) -> Array:
	var arr := []
	if not FileAccess.file_exists(path):
		push_error("Không tìm thấy file: %s" % path)
		return arr
	var f = FileAccess.open(path, FileAccess.READ)
	while f and not f.eof_reached():
		var line = f.get_line().strip_edges()
		if line != "":
			arr.append(line)
	f.close()
	return arr

@warning_ignore("shadowed_variable")
func rank_words_advanced(path: String, output_path: String) -> void:
	print("Đọc danh sách từ: %s" % path.get_file())
	var words = _load_words(path)
	if words.is_empty():
		push_error("Không có từ nào!")
		return

	# --- BƯỚC 1: Tần suất chữ cái trong toàn danh sách ---
	var letter_freq := {}
	for word in words:
		var used := {}
		for ch in word.to_upper():
			if ch >= 'A' and ch <= 'Z' and not used.has(ch):
				used[ch] = true
				letter_freq[ch] = letter_freq.get(ch,0) + 1

	# --- BƯỚC 2: Tần suất chữ cái theo vị trí ---
	var max_len = 0
	for word in words:
		if word.length() > max_len:
			max_len = word.length()
	var pos_freq := []
	for i in range(max_len):
		pos_freq.append({}) # dict cho từng vị trí

	for word in words:
		for i in range(word.length()):
			var ch = word[i].to_upper()
			if ch >= 'A' and ch <= 'Z':
				pos_freq[i][ch] = pos_freq[i].get(ch,0) + 1

	# --- BƯỚC 3: Tính điểm cho từng từ ---
	var ranked := []
	var w1 = 1.0  # trọng số tần suất chữ cái
	var w2 = 1.0  # trọng số tần suất theo vị trí
	var w3 = 1.0  # trọng số chữ cái duy nhất

	for word in words:
		var upper = word.to_upper()
		var unique_letters = []
		var total_letter_score = 0
		var position_score = 0
		for i in range(upper.length()):
			var ch = upper[i]
			if not ch in unique_letters:
				unique_letters.append(ch)
				total_letter_score += letter_freq.get(ch,0)
			position_score += pos_freq[i].get(ch,0)
		var score = w1*total_letter_score + w2*position_score + w3*unique_letters.size()
		ranked.append({
			"word": word,
			"score": score,
			"letters": unique_letters
		})

	# --- BƯỚC 4: Sắp xếp giảm dần ---
	ranked.sort_custom(func(a,b): return a.score > b.score)

	# --- BƯỚC 5: Lưu ra file res://best_suggestions.txt ---
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Không thể ghi file: %s" % output_path)
		return

	file.store_line("# XẾP HẠNG TỪ NÂNG CAO (kết hợp 3 tiêu chí)")
	file.store_line("# Từ file: %s\n" % path.get_file())

	for i in range(ranked.size()):
		var r = ranked[i]
		file.store_line("%3d. %-10s  điểm: %-6.2f  (%s)" % [
			i+1,
			r.word,
			r.score,
			", ".join(r.letters)
		])

	file.close()
	print("✅ Đã lưu toàn bộ kết quả vào: %s" % output_path)

# === HÀM ĐÁNH GIÁ % CHỮ CÁI TRONG FILE GỢI Ý ===
func evaluate_suggestions_frequency(
	suggestions_path: String = "res://best_suggestions.txt"
) -> void:

	var file = FileAccess.open(suggestions_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file gợi ý: %s" % suggestions_path)
		return

	var words = []
	var freq = {}
	var total_letters = 0

	print("  ĐÁNH GIÁ TẦN SUẤT CHỮ CÁI TRONG GỢI Ý: %s" % suggestions_path.get_file())
	print("  " + "-".repeat(60))

	# Đọc từng dòng, bỏ header
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.begins_with("#") and "→" in line:
			var parts = line.split("→", true, 1)
			if parts.size() < 2: continue
			var word_part = parts[0].strip_edges()
			var word = word_part.split(" ", true, 2)[-1].strip_edges()  # Lấy từ sau #
			if word.length() == 5:
				words.append(word)
				var w = word.to_upper()
				for ch in w:
					if 'A' <= ch and ch <= 'Z':
						freq[ch] = freq.get(ch, 0) + 1
						total_letters += 1

	file.close()

	if total_letters == 0:
		print("  Không có dữ liệu chữ cái trong gợi ý!")
		return

	# Sắp xếp giảm dần
	var sorted = freq.keys()
	sorted.sort_custom(func(a, b): return freq[a] > freq[b])

	# In kết quả
	print("  Tần suất chữ cái trong Top %d gợi ý:" % words.size())
	for ch in sorted:
		var count = freq[ch]
		var percent = (count * 100.0) / total_letters
		print("    %s: %d lần (%.2f%%)" % [ch, count, percent])

	print("  Tổng chữ cái trong gợi ý: %d\n" % total_letters)

# === XẾP HẠNG TỪ THEO CHỮ PHỔ BIẾN TRONG DANH SÁCH ===
@warning_ignore("shadowed_variable")
func rank_words_by_letter_frequency(path: String, output_path: String) -> void:
	print("Đọc danh sách từ trong: %s" % path.get_file())
	var words = _load_words(path)
	if words.is_empty():
		push_error("Không có từ nào trong file!")
		return

	# --- BƯỚC 1: Đếm tần suất xuất hiện của từng chữ cái (theo từ, không lặp trong cùng 1 từ) ---
	var freq := {}
	for word in words:
		var used := {}
		for ch in word.to_upper():
			if ch >= 'A' and ch <= 'Z' and not used.has(ch):
				used[ch] = true
				freq[ch] = freq.get(ch, 0) + 1

	# --- BƯỚC 2: Tính điểm từng từ dựa theo tần suất chữ ---
	var ranked := []
	for word in words:
		var score := 0
		var letters := []
		for ch in word.to_upper():
			if freq.has(ch) and not ch in letters:
				score += freq[ch]
				letters.append(ch)
		ranked.append({
			"word": word,
			"score": score,
			"letters": letters
		})

	# --- BƯỚC 3: Sắp xếp giảm dần theo điểm ---
	ranked.sort_custom(func(a, b): return a.score > b.score)

	# --- BƯỚC 4: Ghi ra file ---
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Không thể ghi file: %s" % output_path)
		return

	file.store_line("# XẾP HẠNG THEO TẦN SUẤT CHỮ CÁI")
	file.store_line("# Tính từ danh sách: %s\n" % path.get_file())

	# Ghi tần suất từng chữ
	file.store_line("## TẦN SUẤT CHỮ CÁI:")
	var sorted_letters = freq.keys()
	sorted_letters.sort_custom(func(a,b): return freq[a] > freq[b])
	for ch in sorted_letters:
		file.store_line("  %s: %d" % [ch, freq[ch]])

	file.store_line("\n## XẾP HẠNG TỪ:")
	for i in range(ranked.size()):
		var r = ranked[i]
		file.store_line("%3d. %-10s  điểm: %-3d  (%s)" % [
			i + 1,
			r.word,
			r.score,
			", ".join(r.letters)
		])

	file.close()
	print("\nĐã lưu toàn bộ kết quả vào: %s ✅" % output_path)

func full_check_word_stats(word):
# Bước 1: Tính tần suất từ file
	var freq_result = analyze_letter_frequency("res://valid-wordle-words.txt")

	# Bước 2: Kiểm tra từ stump
	check_word_stats(word, freq_result)

func check_word_stats(word: String, freq_result: Dictionary) -> void:
	if word.length() != 5:
		push_error("Từ phải đúng 5 chữ!")
		return

	var freq = freq_result.freq
	var total = freq_result.total
	if total == 0:
		push_error("Không có dữ liệu tần suất!")
		return

	var w = word.to_upper()
	var score = 0.0
	var used = {}  # Tránh tính trùng
	var breakdown = []

	print("  KIỂM TRA TỪ: %s" % word)
	print("  " + "-".repeat(50))

	for ch in w:
		if 'A' <= ch and ch <= 'Z' and not used.has(ch):
			var count = freq.get(ch, 0)
			var percent = (count * 100.0) / total
			score += percent
			used[ch] = true
			breakdown.append("%s (%d lần, %.2f%%)" % [ch, count, percent])

	print("    Tổng điểm: %.2f%%" % score)
	print("    Chi tiết: %s" % " | ".join(breakdown))
	print("    Từ này xếp hạng cao nếu > 30.00%% (39,39-10,04%) \n")

@warning_ignore("shadowed_variable")
func rank_worle_words(src):
	var freq_data = analyze_letter_frequency(src).freq
	#var freq_data = analyze_letter_frequency(src).total
	save_ranked_words_to_file(src, "res://ranked_words.txt", freq_data, 1000000)

# === HÀM PHỤ: TẠO CHUỖI LẶP (THAY THẾ "=" * 80) ===
func _repeat_string(s: String, n: int) -> String:
	var result = ""
	for i in range(n):
		result += s
	return result

# === HÀM CHÍNH: LƯU XẾP HẠNG RA FILE ===
func save_ranked_words_to_file(
	input_path: String,
	output_path: String = "res://ranked_words.txt",
	freq_data: Dictionary = {},
	limit: int = 100  # 0 = tất cả
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file đọc: %s" % input_path)
		return

	var freq = freq_data.duplicate()
	var total_letters = 0

	# Tính tần suất nếu chưa có
	if freq.is_empty():
		while !file.eof_reached():
			var word = file.get_line().strip_edges()
			if word == "" or word.length() != 5: continue
			var w = word.to_upper()
			for ch in w:
				if 'A' <= ch and ch <= 'Z':
					freq[ch] = freq.get(ch, 0) + 1
					total_letters += 1
		file.close()
		file = FileAccess.open(input_path, FileAccess.READ)
	else:
		for count in freq.values():
			total_letters += count

	if total_letters == 0:
		print("  Không có dữ liệu!")
		return

	# Tính phần trăm
	var percent = {}
	for ch in freq:
		percent[ch] = (freq[ch] * 100.0) / total_letters

	# Tính điểm từng từ
	var word_scores = []
	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5: continue
		var w = word.to_upper()
		var score = 0.0
		var used = {}
		for ch in w:
			if 'A' <= ch and ch <= 'Z' and not used.has(ch):
				score += percent.get(ch, 0.0)
				used[ch] = true
		word_scores.append({
			"word": word,
			"score": score,
			"used": used,
			"percent": percent
		})
	file.close()

	# Sắp xếp giảm dần
	word_scores.sort_custom(func(a, b): return a.score > b.score)

	# === GHI RA FILE – ĐÃ SỬA LỖI LAMBDA ===
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	if out == null:
		push_error("Không mở file ghi: %s" % output_path)
		return

	# Ghi header
	out.store_line("WORDLE AI - XẾP HẠNG TỪ THEO TẦN SUẤT CHỮ CÁI")
	out.store_line("Tổng chữ cái: %d | File: %s" % [total_letters, input_path.get_file()])
	out.store_line(_repeat_string("=", 80))  # ← DÙNG HÀM NGOÀI → KHÔNG LỖI

	var count = 0
	for item in word_scores:
		count += 1
		if limit > 0 and count > limit:
			break

		var breakdown = []
		for ch in item.word.to_upper():
			if item.used.has(ch):
				breakdown.append("%s:%.2f%%" % [ch, item.percent.get(ch, 0.0)])
				item.used.erase(ch)

		var line = "#%-4d %-6s %6.2f%%   (%s)" % [
			count,
			item.word,
			item.score,
			", ".join(breakdown)
		]
		out.store_line(line)

	out.close()

	print("  Đã lưu xếp hạng vào: %s (Top %d từ)" % [
		output_path.get_file(),
		limit if limit > 0 else word_scores.size()
	])
	print("  Tổng từ xếp hạng: %d\n" % word_scores.size())

func analyze_letter_frequency(input_path: String) -> Dictionary:
	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file: %s" % input_path)
		return {}

	var freq = {}  # { "A": 120, "B": 50, ... }
	var total_letters = 0

	print("  Phân tích tần suất chữ cái trong: %s" % input_path.get_file())
	print("  " + "-".repeat(60))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue
		var w = word.to_upper()
		for ch in w:
			if 'A' <= ch and ch <= 'Z':
				freq[ch] = freq.get(ch, 0) + 1
				total_letters += 1

	file.close()

	if total_letters == 0:
		print("  Không có dữ liệu!")
		return {}

	# Sắp xếp + in kết quả
	var sorted = freq.keys()
	sorted.sort_custom(func(a, b): return freq[a] > freq[b])

	print("  Tần suất tổng:")
	for ch in sorted:
		var count = freq[ch]
		var percent = (count * 100.0) / total_letters
		print("    %s (%d lần, %.2f%%)" % [ch, count, percent])

	print("  Tổng số chữ cái: %d\n" % total_letters)

	# TRẢ VỀ Dictionary: { "E": 1233, "A": 979, ... }
	return {
		"freq": freq,
		"total": total_letters
	}

func normalize_pattern(user_input: String) -> String:
	var result = ""
	var i = 0
	while i < user_input.length():
		var ch = user_input[i].to_upper()
		
		# Chỉ xử lý chữ cái A-Z
		if 'A' <= ch and ch <= 'Z':
			result += ch
			i += 1
			
			# Đọc tất cả số liên tiếp sau chữ cái
			while i < user_input.length() and user_input[i].is_valid_int():
				var digit = int(user_input[i])
				
				# Chỉ xử lý số từ 1 đến 5 → giảm 1
				if digit >= 1 and digit <= 5:
					result += str(digit - 1)  # 1→0, 2→1, 3→2, 4→3, 5→4
				# Bỏ số 0 hoặc >5
				i += 1
		else:
			i += 1  # Bỏ qua ký tự không hợp lệ
	return result

func filter_words_position_exclude_style(
	input_path: String,
	pattern: String,          # "A02T034N3", "U1E23"
	output_path: String
) -> void:

	var temp_file = "res://temp_step.txt"
	
	pattern = normalize_pattern(pattern)
	print(pattern)

	# === BƯỚC 1: TRÍCH XUẤT CHỮ CÁI DUY NHẤT (loại trùng) ===
	var required_letters = ""
	var i = 0
	while i < pattern.length():
		var ch = pattern[i].to_upper()
		if not ('A' <= ch and ch <= 'Z'):
			push_error("Chỉ dùng A-Z: %s" % ch)
			_cleanup_temp(temp_file)
			return
		if not required_letters.contains(ch):
			required_letters += ch
		# Bỏ qua tất cả số liên tiếp
		i += 1
		while i < pattern.length() and pattern[i].is_valid_int():
			i += 1

	if required_letters.is_empty():
		push_error("Pattern không có chữ cái!")
		_cleanup_temp(temp_file)
		return

	print("  → Pattern: '%s' → Yêu cầu CÓ ĐỦ: %s" % [pattern, required_letters])

	# === BƯỚC 2: LỌC TỪ CÓ ĐỦ CHỮ CÁI ===
	filter_words_containing_letters_to_file(input_path, required_letters, temp_file)

	# === BƯỚC 3: LOẠI TỪ Ở VỊ TRÍ CẤM ===
	filter_words_exclude_positions_from_file(temp_file, pattern, output_path)

	# === DỌN DẸP ===
	_cleanup_temp(temp_file)

	print("  Xong! Kết quả: %s\n" % output_path.get_file())


# XÓA FILE TẠM
@warning_ignore("shadowed_variable")
func _cleanup_temp(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

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
			#print("    - %s (thiếu: %s)" % [word, ", ".join(missing)])

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
func filter_words_exclude_positions_from_file(
	input_path: String,
	pattern: String,          # "A02T04N3", "U1E23", "X012"
	output_path: String
) -> void:

	var file = FileAccess.open(input_path, FileAccess.READ)
	if file == null:
		push_error("Không mở file: %s" % input_path)
		return

	# === PHÂN TÍCH PATTERN: "A02T04N3" → {"A": [0,2], "T": [0,4], "N": [3]} ===
	var rules = {}  # { "A": [0,2], "T": [0,4], "N": [3] }
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

		# Đọc TẤT CẢ số liên tiếp theo sau chữ cái
		while i < pattern.length() and pattern[i].is_valid_int():
			@warning_ignore("shadowed_variable")
			var pos = int(pattern[i])
			if pos < 0 or pos > 4:
				push_error("Vị trí phải 0-4: %s" % pos)
				return
			if not rules.has(ch):
				rules[ch] = []
			if not rules[ch].has(pos):
				rules[ch].append(pos)
			i += 1

	if rules.is_empty():
		push_error("Pattern không hợp lệ!")
		return

	var matches = []

	print("  Loại từ ở vị trí cấm theo: '%s'" % pattern)
	print("    Đọc từ: %s → Ghi vào: %s" % [input_path.get_file(), output_path.get_file()])
	print("    " + "─".repeat(60))

	while !file.eof_reached():
		var word = file.get_line().strip_edges()
		if word == "" or word.length() != 5:
			continue

		var w = word.to_upper()
		var valid = true

		# Kiểm tra từng chữ cái ở các vị trí cấm
		for ch in rules:
			@warning_ignore("shadowed_variable")
			for pos in rules[ch]:
				if w[pos] == ch:
					valid = false
					break
			if not valid:
				break

		if valid:
			matches.append(word)
			print("    + %s" % word)  # IN TỪNG TỪ THỎA MÃN

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
		@warning_ignore("shadowed_variable")
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
			@warning_ignore("shadowed_variable")
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
		@warning_ignore("shadowed_variable")
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
		@warning_ignore("shadowed_variable")
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
