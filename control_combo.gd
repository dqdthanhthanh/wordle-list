extends Node

# ===============================
# Kiểm tra chữ
# ===============================
func is_alpha_only(text: String) -> bool:
	for ch in text:
		if ch < "A" or ch > "Z":
			return false
	return true

func load_words_to_array(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Không mở file: %s" % path)
		return []
	var words = []
	while !file.eof_reached():
		var line = file.get_line().strip_edges().to_upper()
		if line.length() == 5 and is_alpha_only(line):
			words.append(line)
	file.close()
	return words

# ===============================
# Giả lập lượt đoán
# ===============================
func _simulate_guess_fast(guess: String, answer: String) -> Array:
	guess = guess.to_upper()
	answer = answer.to_upper()
	var green = []
	var yellow = []
	var gray = []
	var count = {}
	for ch in answer:
		count[ch] = count.get(ch, 0) + 1
	for i in range(5):
		if guess[i] == answer[i]:
			green.append(i)
			count[guess[i]] -= 1
	for i in range(5):
		if guess[i] != answer[i] and count.get(guess[i], 0) > 0:
			yellow.append(i)
			count[guess[i]] -= 1
	for i in range(5):
		if i not in green and i not in yellow:
			gray.append(i)
	return [green, yellow, gray]

func _is_valid_fast(answer: String, green: Array, yellow: Array, gray: Array, guess: String) -> bool:
	answer = answer.to_upper()
	guess = guess.to_upper()
	for i in green:
		if answer[i] != guess[i]:
			return false
	var count = {}
	for ch in answer:
		count[ch] = count.get(ch, 0) + 1
	for i in green:
		count[guess[i]] -= 1
	for i in yellow:
		if count.get(guess[i], 0) <= 0:
			return false
		count[guess[i]] -= 1
	for i in gray:
		if answer.find(guess[i]) != -1:
			return false
	return true

# ===============================
# Chuyển contain_false 1-based ("S15U4") sang 0-based ("S04U3")
# ===============================

func parse_contain_false_positions(contain_false: String) -> Array:
	var result = []
	var i = 0
	contain_false = contain_false.to_upper()
	while i < contain_false.length():
		var ch = contain_false[i]
		i += 1
		var num_str = ""
		while i < contain_false.length() and contain_false[i] >= "0" and contain_false[i] <= "9":
			num_str += contain_false[i]
			i += 1
		if num_str != "":
			# Có thể nhiều số: "123" -> [1,2,3]
			for n in num_str.split(""):
				result.append({"letter": ch, "pos": int(n) - 1}) # 0-based
	return result

func get_remaining_words(word_list: Array, contain_true: String, exclude: String, contain_false: String) -> Array:
	var results = []
	contain_true = contain_true.to_upper()
	exclude = exclude.to_upper()
	contain_false = contain_false.to_upper()
	
	var cf_positions = parse_contain_false_positions(contain_false)
	
	for word in word_list:
		var wu = word.to_upper()
		var skip = false
		
		# Bước 1: loại exclude
		for ch in exclude:
			if wu.find(ch) != -1:
				skip = true
				break
		if skip:
			continue
		
		# Bước 2: kiểm tra contain_true theo vị trí
		for i in range(contain_true.length()):
			if contain_true[i] != "?" and wu[i] != contain_true[i]:
				skip = true
				break
		if skip:
			continue
		
		# Bước 3: kiểm tra contain_false
		for cf in cf_positions:
			var ch = cf["letter"]
			var pos = cf["pos"]
			if pos < wu.length() and wu[pos] == ch:
				skip = true
				break
			# Nếu chữ không có trong từ nào, loại luôn (tuỳ config)
			if wu.find(ch) == -1:
				skip = true
				break
		if skip:
			continue
		
		results.append(word)
	
	return results


func get_remaining_words_full(word_list: Array, contain_true: String, exclude: String, contain_false: String) -> Array:
	var results = []
	
	# Chuẩn hoá chữ hoa
	contain_true = contain_true.to_upper()
	exclude = exclude.to_upper()
	contain_false = contain_false.to_upper()
	
	# Bước 0: Chuyển contain_false dạng "O2A3L5" thành mảng [(O,1),(A,2),(L,4)] 0-based
	var cf_rules = []
	for i in range(0, contain_false.length(), 2):
		var ch = contain_false[i]
		var pos = int(contain_false[i + 1]) - 1  # chuyển sang 0-based
		cf_rules.append([ch, pos])
	
	for word in word_list:
		var w = word.to_upper()
		var skip = false
		
		# Bước 1: loại theo exclude
		for c in exclude:
			if w.find(c) != -1:
				skip = true
				break
		if skip:
			continue
		
		# Bước 2: kiểm tra contain_true
		for i in range(contain_true.length()):
			var ch = contain_true[i]
			if ch != "?" and w[i] != ch:
				skip = true
				break
		if skip:
			continue
		
		# Bước 3: kiểm tra contain_false
		for rule in cf_rules:
			var ch = rule[0]
			var pos = rule[1]
			if w.find(ch) == -1:   # chữ không có trong từ → loại
				skip = true
				break
			if w[pos] == ch:       # chữ ở vị trí cấm → loại
				skip = true
				break
		if skip:
			continue
		
		results.append(word)
	
	return results

# ===============================
# Tìm từ loại tốt nhất lượt 2
# ===============================
func parse_contain_true_false(contain_true: String, contain_false: String) -> Dictionary:
	var half_score_letters = []
	var no_score_letters = []

	# contain_true: dạng "AE???" -> chỉ lấy các chữ không phải "?"
	for ch in contain_true.to_upper():
		if ch != "?":
			half_score_letters.append(ch)
	
	# contain_false: dạng "C1B234D5" -> chỉ lấy chữ, bỏ số
	for ch in contain_false.to_upper():
		if ch >= "A" and ch <= "Z":
			no_score_letters.append(ch)
	
	return {
		"half_score_letters": half_score_letters,
		"no_score_letters": no_score_letters
	}

func find_best_eliminator(
	word_list: Array, 
	remaining_words: Array, 
	contain_true: String = "",         
	contain_false: String = "",        
	contain_true_score: float = 1.0,
	contain_false_score: float = 1.0,  
	debug_mode: bool = false
) -> Array:
	var results = []
	var total = remaining_words.size()
	var tested = 0
	
	# -------------------------
	# 1️⃣ Tính tần suất chữ cái trong remaining_words
	# -------------------------
	var letter_freq = {}
	for word in remaining_words:
		var seen = {}
		for ch in word.to_upper():
			if not seen.has(ch):
				letter_freq[ch] = letter_freq.get(ch, 0) + 1
				seen[ch] = true
	
	# -------------------------
	# 2️⃣ Tạo contain_full = tất cả chữ không lặp lại trong contain_true + contain_false
	# -------------------------
	var contain_full = get_contain_full(contain_true, contain_false)
	
	# -------------------------
	# 3️⃣ Duyệt từng candidate
	# -------------------------
	for candidate in word_list:
		var wu = candidate.to_upper()
		
		# Tính overlap_count (số từ trùng, chưa loại)
		var overlap_count = 0
		for ans in remaining_words:
			var sim = _simulate_guess_fast(candidate, ans)
			if _is_valid_fast(ans, sim[0], sim[1], sim[2], candidate):
				overlap_count += 1
		
		var overlap_percent = (overlap_count * 100.0) / total
		
		# Tính score theo tần suất và hệ số chứa chữ
		var score = 0
		var seen = {}
		for ch in wu:
			if not seen.has(ch):
				var ch_score = 0.0
				if contain_true.find(ch) != -1:
					ch_score = letter_freq.get(ch, 0) / (contain_true_score*total)
					#print(" +%d (%s) → contain_true" % [ch_score, ch])
				elif contain_false.find(ch) != -1:
					ch_score = letter_freq.get(ch, 0) / (contain_false_score*total)
					#print(" +%d (%s) → contain_false" % [ch_score, ch])
				else:
					ch_score = letter_freq.get(ch, 0)
					#print(" +%d (%s) → other" % [ch_score, ch])
				score += ch_score
				seen[ch] = true
		
		# Tính thêm điểm dựa trên số chữ trùng với contain_full
		var match_count = 0
		for ch in contain_full:
			if wu.find(ch) != -1:
				match_count += 1
		if contain_full.length() > 0:
			score += (score * match_count / contain_full.length())/total
			
		# Tính bonus nếu candidate còn trong remaining_words
		if remaining_words.has(candidate):
			if total > 0:
				score += score * (2.0 / total)
		
		# Lưu kết quả
		if overlap_count > 0:
			results.append({
				"word": candidate,
				"overlap_count": overlap_count,
				"overlap_percent": overlap_percent,
				"score": score
			})
			
			tested += 1
			if debug_mode:
				print("[%04d] %s → trùng %d/%d → %.2f%% → điểm %.2f" % [
					tested, candidate, overlap_count, total, overlap_percent, score
				])
	
	# -------------------------
	# 4️⃣ Sắp xếp giảm dần theo score
	# -------------------------
	results.sort_custom(func(a, b):
		return a["score"] > b["score"]
	)
	
	return results

# ===============================
# Lưu kết quả
# ===============================
func save_results_to_file(results: Array, output_path: String) -> void:
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if not file:
		push_error("Không ghi được file: %s" % output_path)
		return
	for r in results:
		file.store_line("%s → trùng %d → tỷ lệ %.2f%% → điểm %.2f" % [
			r["word"],            # Từ
			r["overlap_count"],   # Số từ trùng
			r["overlap_percent"], # Tỷ lệ trùng %
			r["score"]            # Điểm chữ cái
		])
	file.close()
	print("Đã lưu kết quả vào %s" % output_path)

# ===============================
# _ready
# ===============================
func _ready():
	#ORATE → trùng 1612 → tỷ lệ 100.00% → điểm 3013.00
	#OATER → trùng 1612 → tỷ lệ 100.00% → điểm 3013.00
	#ROATE → trùng 1612 → tỷ lệ 100.00% → điểm 3013.00
	#SULCI → trùng 195 → tỷ lệ 100.00% → điểm 413.00
	
	var word_list: Array = load_words_to_array("res://wordle-full.txt")
	var all_answer: Array = load_words_to_array("res://wordle-La.txt")
	var all_past_answer: Array = load_words_to_array("res://wordle-answers-alphabetical.txt")
	#merge_wordle_files("res://wordle-Ta.txt", "res://wordle-La.txt", "res://wordle-full.txt")
	print("Đã đọc %d từ từ: words.txt" % word_list.size())
	
	# Ví dụ lọc lượt 1
	var contain_true:String = "?lea?".to_upper()
	var contain_false:String = "a3e5".to_upper()
	var exclude:String = "sorcint".to_upper()
	var contain = "dfnpvgbxmwnd".to_upper()
	var contain_full:String = get_contain_full(contain_true, contain_false)
	print(contain_full)  # Output: có thể "TYSAN" (chữ hoa, không trùng)
	var contain_true_score: float = 2
	var contain_false_score: float = 1
	
	var remaining_words = get_remaining_words(all_answer, contain_true, exclude, contain_false)
	#var remaining_words = get_remaining_contain(all_answer, contain,3)
	
	var freq_array = count_letter_frequency(remaining_words)
	
	print("→ LỌC HOÀN TẤT: %d từ còn lại" % remaining_words.size())
	print(remaining_words)
	print(freq_array)
	
	# Tìm từ loại tốt nhất lượt 2
	var filtered_word_list = []
	for word in word_list:
		var wu = word.to_upper()
		var skip = false
		for c in exclude.to_upper():
			if wu.find(c) != -1:
				skip = true
				break
		if not skip:
			filtered_word_list.append(word)
	
	var letters_in_remaining = []
	for pair in freq_array:
		letters_in_remaining.append(pair[0])  # lấy tất cả các chữ xuất hiện trong remaining_words

	var filtered_word_list2 = []
	for word in filtered_word_list:
		var wu = word.to_upper()
		var valid = true
		for ch in wu:
			if not letters_in_remaining.has(ch):
				valid = false
				break
		if valid:
			filtered_word_list2.append(word)

	filtered_word_list = filtered_word_list2
	print("→ filtered_word_list còn %d từ sau khi lọc theo letter_freq" % filtered_word_list.size())
	print(letters_in_remaining)
	print(filtered_word_list)


	var results = find_best_eliminator(filtered_word_list, remaining_words, contain_true, contain_false,contain_true_score,contain_false_score, true)
	
	save_results_to_file(results, "res://elimination_result.txt")
	await get_tree().create_timer(0.5).timeout
	save_text_to_file_at_top(freq_array, "res://elimination_result.txt",true)
	await get_tree().create_timer(0.5).timeout
	save_text_to_file_at_top(remaining_words, "res://elimination_result.txt",true)
	
	if results.size() > 0:
		prints("\n→ Từ tốt nhất: ",results[0])
	
	var ds = ""
	for w in remaining_words:
		ds += w
		ds += ", "
	prints(ds)

# Hàm lọc từ chỉ giữ lại từ có ít nhất 1 chữ trong 'contain'
func get_remaining_contain(word_list: Array, contain: String, max_count:int) -> Array:
	var result = []
	var letters = contain
	var count = 0
	for w in word_list:
		count = 0
		for t in contain:
			if t in w:
				count += 1
				if count == max_count:
					result.append(w)
					count = 0
					break  # đủ 1 chữ là giữ, khỏi kiểm tiếp
			else:
				count -= 1
	return result

func get_contain_full(contain_true: String, contain_false: String) -> String:
	var letters = {}
	
	# Lấy chữ từ contain_true, bỏ '?'
	for ch in contain_true.to_upper():
		if ch != "?":
			letters[ch] = true
	
	# Lấy chữ từ contain_false, chỉ chữ A-Z
	for ch in contain_false.to_upper():
		if ch >= "A" and ch <= "Z":
			letters[ch] = true
	
	# Chuyển sang string, không trùng lặp
	var result = ""
	for ch in letters.keys():
		result += ch
	
	return result

func merge_wordle_files(file1_path: String, file2_path: String, output_path: String) -> void:
	var words_set = {}  # dùng dictionary làm set
	
	read_file_to_set(file1_path, words_set)
	read_file_to_set(file2_path, words_set)
	
	var words_array = words_set.keys()
	words_array.sort()  # sắp xếp theo chữ cái
	
	var file_out = FileAccess.open(output_path, FileAccess.WRITE)
	if not file_out:
		push_error("Không ghi được file: %s" % output_path)
		return
	for word in words_array:
		file_out.store_line(word)
	file_out.close()
	print("Đã tổng hợp và lưu %d từ vào %s" % [words_array.size(), output_path])

# Hàm đọc file và đưa tất cả từ vào set (dictionary) để loại trùng
func read_file_to_set(path: String, words_set: Dictionary) -> void:
	if not FileAccess.file_exists(path):
		push_error("File không tồn tại: %s" % path)
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Không mở được file: %s" % path)
		return
	while not file.eof_reached():
		var line = file.get_line().strip_edges().to_upper()
		if line != "":
			words_set[line] = true
	file.close()

func count_letter_frequency(words: Array) -> Array:
	var freq = {}
	for word in words:
		var seen = {}  # tránh đếm trùng trong cùng 1 từ
		for ch in word.to_upper():
			if not seen.has(ch):
				freq[ch] = freq.get(ch, 0) + 1
				seen[ch] = true

	# Chuyển dictionary sang array [(letter, count), ...]
	var freq_array = []
	for k in freq.keys():
		freq_array.append([k, freq[k]])

	# Sắp xếp giảm dần theo count
	freq_array.sort_custom(func(a, b):
		return a[1] > b[1]
	)

	return freq_array

func sort_ascending_freq(a, b):
	if a["score"] > b["score"]:
		return true
	return false

func save_text_to_file_at_top(data, path: String,oneline:bool = false) -> void:
	# Đọc nội dung cũ
	var old_content: Array = []
	if FileAccess.file_exists(path):
		var file_read = FileAccess.open(path, FileAccess.READ)
		if file_read:
			while !file_read.eof_reached():
				old_content.append(file_read.get_line())
			file_read.close()

	# Mở file ghi (overwrite)
	var file_write = FileAccess.open(path, FileAccess.WRITE)
	if not file_write:
		push_error("Không ghi được file: %s" % path)
		return

	# Viết dữ liệu mới trước
	if data is Array:
		for line in data:
			if oneline == false:
				file_write.store_line(str(line))
			else:
				file_write.store_string(str(line))
				file_write.store_string(str(" "))
		if oneline == true:
			file_write.store_string(str("\n"))
	else:
		file_write.store_line(str(data))

	# Viết nội dung cũ sau
	for line in old_content:
		file_write.store_line(str(line))

	file_write.close()
	print("Đã lưu dữ liệu vào đầu file %s" % path)

func save_text_to_file_at_bottom(data, path: String) -> void:
	# Đọc nội dung cũ
	var old_content: Array = []
	if FileAccess.file_exists(path):
		var file_read = FileAccess.open(path, FileAccess.READ)
		if file_read:
			while !file_read.eof_reached():
				old_content.append(file_read.get_line())
			file_read.close()

	# Mở file ghi (overwrite)
	var file_write = FileAccess.open(path, FileAccess.WRITE)
	if not file_write:
		push_error("Không ghi được file: %s" % path)
		return

	# Viết nội dung cũ trước
	for line in old_content:
		file_write.store_line(str(line))

	# Viết dữ liệu mới vào cuối
	if data is Array:
		for line in data:
			file_write.store_string(str(line))
			file_write.store_string(str(" "))
	else:
		file_write.store_string(str(data))

	file_write.close()
	print("Đã lưu dữ liệu vào cuối file %s" % path)
