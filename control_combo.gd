extends Node

var word_list: Array = []

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
# Lọc remaining words
# ===============================
func get_remaining_words(guess: String, pattern: String, excluded: String, misplaced: String) -> Array:
	guess = guess.to_upper()
	var results = []
	for word in word_list:
		word = word.to_upper()
		var match_pattern = true
		for i in range(5):
			if pattern[i] != "?" and word[i] != pattern[i]:
				match_pattern = false
				break
		if not match_pattern:
			continue
		var has_excluded = false
		for ch in excluded.to_upper():
			if word.find(ch) != -1:
				has_excluded = true
				break
		if has_excluded:
			continue
		# misplaced bỏ qua
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
	excluded_letters: String = "", 
	debug_mode: bool = false
) -> Array:
	var results = []
	var total = remaining_words.size()
	var tested = 0
	
	# Tính tần suất chữ cái trong remaining_words
	var letter_freq = {}
	for word in remaining_words:
		var seen = {}
		for ch in word.to_upper():
			if not seen.has(ch):
				letter_freq[ch] = letter_freq.get(ch, 0) + 1
				seen[ch] = true
	
	# Chuyển contain_true/contain_false sang half_score_letters/no_score_letters
	var parsed = parse_contain_true_false(contain_true, contain_false)
	var half_score_letters = parsed["half_score_letters"]
	var no_score_letters = parsed["no_score_letters"]
	
	for candidate in word_list:
		var wu = candidate.to_upper()
		
		# Loại candidate chứa chữ cấm
		if excluded_letters != "":
			var skip = false
			for c in excluded_letters.to_upper():
				if wu.find(c) != -1:
					skip = true
					break
			if skip:
				continue
		
		# Tính overlap_count (số từ trùng, chưa loại)
		var overlap_count = 0
		for ans in remaining_words:
			var sim = _simulate_guess_fast(candidate, ans)
			if _is_valid_fast(ans, sim[0], sim[1], sim[2], candidate):
				overlap_count += 1
		
		var overlap_percent = (overlap_count * 100.0) / total
		
		# Tính score theo tần suất và hai mức half/no
		var score = 0
		var seen = {}
		for ch in wu:
			if not seen.has(ch):
				if no_score_letters.find(ch) != -1:
					pass # không cộng điểm
				elif half_score_letters.find(ch) != -1:
					score += letter_freq.get(ch, 0) * 0.5
				else:
					score += letter_freq.get(ch, 0)
				seen[ch] = true
		
		# Lưu kết quả
		if overlap_percent == 100 or score > 0:
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
	
	# Sắp xếp: ưu tiên overlap_percent thấp → loại được nhiều nhất, nếu bằng thì score giảm dần
	results.sort_custom(sort_ascending)
	
	return results

func sort_ascending(a, b):
	if a["score"] > b["score"]:
		return true
	return false

# ===============================
# Lưu kết quả
# ===============================
func save_results_to_file(results: Array, output_path: String) -> void:
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if not file:
		push_error("Không ghi được file: %s" % output_path)
		return
	for r in results:
		file.store_line("%s → trùng %d → tỷ lệ %.2f%% → điểm %d" % [
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
	word_list = load_words_to_array("res://words.txt")
	print("Đã đọc %d từ từ: words.txt" % word_list.size())
	
	# Ví dụ lọc lượt 1
	var contain_true = "S?AN?".to_upper()
	var contain_false = "P4".to_upper()
	var exclude = "ORECLITWHIY".to_upper()
	
	var remaining_words = get_remaining_words("", contain_true, exclude, contain_false)
	var freq = count_letter_frequency(remaining_words)
	
	print("→ LỌC HOÀN TẤT: %d từ còn lại" % remaining_words.size())
	print(remaining_words)
	print(freq)
	
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
	var results = find_best_eliminator(filtered_word_list, remaining_words, exclude, contain_true, contain_false, true)
	
	save_results_to_file(results, "res://elimination_result.txt")
	await get_tree().create_timer(0.5).timeout
	save_text_to_file_at_top(freq, "res://elimination_result.txt",true)
	await get_tree().create_timer(0.5).timeout
	save_text_to_file_at_top(remaining_words, "res://elimination_result.txt",true)
	
	if results.size() > 0:
		prints("\n→ Từ tốt nhất: ",results[0])

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
