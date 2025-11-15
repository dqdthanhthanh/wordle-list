extends Control


func _ready():
	# ================== LOAD DỮ LIỆU ==================
	var word_list: Array = load_words_to_array("res://words.txt")
	var answer_list: Array = load_words_to_array("res://wordle-answers-alphabetical.txt")
	answer_list = ["WIELD","CLUNG","LURID","TINGE","DEUCE","GIZMO","TABBY","FUGUE","ARISE","PERIL","GUISE","SHORT","VENUE","AWOKE","RABID","MOTEL"]
	var total_words: int = word_list.size()
	var total_answers: int = answer_list.size()

	print("TỔNG TỪ ĐIỂN: %d từ | TỔNG ĐÁP ÁN: %d từ\n" % [total_words, total_answers])

# ================== CÀI ĐẶT TEST ==================
	var test_count: int = total_answers  # TEST HẾT
	var indices: Array = range(total_answers)

	# CHUẨN BỊ UPPERCASE
	var word_upper: Array = []
	for w in word_list: word_upper.append(w.to_upper())
	var answer_upper: Array = []
	for a in answer_list: answer_upper.append(a.to_upper())

	## ================== DANH SÁCH COMBO 2 TỪ ==================
	#var guess_combos: Array[Array] = [
		## TỐI ƯU NHẤT (theo nghiên cứu AI + thực tế)
		#["SOARE", "CLINT"],     # 0.115% – VUA 2 LƯỢT
		#["SLATE", "CRONY"],     # 0.09%  – SIÊU MẠNH
		#["TRACE", "SLING"],     # 0.11%  – RẤT TỐT
		#["CRANE", "SLOTH"],     # 0.12%  – CÂN BẰNG
		#["RAISE", "COUNT"],     # 0.142% – ỔN ĐỊNH
#
		## PHỔ BIẾN & TỐT
		#["STARE", "COILN"],     # Phủ rộng
		#["SALET", "CRONY"],     # SALET nổi tiếng
		#["LEAST", "CRONY"],     # LEAST mạnh
		#["ARISE", "COUNT"],     # ARISE phổ biến
		#["LATER", "NOISY"],     # ALTER biến thể
#
		## NGUYÊN ÂM + PHỤ ÂM
		#["AUDIO", "STERN"],     # AUDIO loại nguyên âm
		#["ADIEU", "STORY"],     # ADIEU + STORY
		#["OUIJA", "STERN"],     # OUIJA 4 nguyên âm
#
		## CỰC ĐOAN – TEST HIỆU SUẤT
		#["ADIEU", "SPORT"],     # KÉM NHẤT (để so sánh)
		#["RAISE", "GLOUT"],     # Test
	#]
#
	#var soare_combos: Array[Array] = [
		#["SOARE"],  # → 0.130% → VUA (C yếu nhưng lọc mạnh)
		#["CRANE"],  # → 0.130% → VUA (C yếu nhưng lọc mạnh)
		#["SLATE"],  # → 0.130% → VUA (C yếu nhưng lọc mạnh)
		#["TRACE"],  # → 0.130% → VUA (C yếu nhưng lọc mạnh)
		#["CRATE"],  # → 0.130% → VUA (C yếu nhưng lọc mạnh)
	#]
	#
	## ================== TEST SIÊU NHANH ==================
	#var start_time = Time.get_ticks_msec()
	#var results: Array = []
	#var debug_mode: bool = true  # ← BẬT ĐỂ XEM CHI TIẾT, TẮT ĐỂ CHẠY NHANH
#
	#for combo in guess_combos:
		#var res = _test_combo_ultra_fast(combo, word_upper, answer_upper, indices, debug_mode)
		#results.append({
			#"name": "-".join(combo),
			#"step1": res.step1,
			#"total": res.total
		#})
		#
	#var end_time = Time.get_ticks_msec()
	#print("→ HOÀN THÀNH TEST %d COMBO × %d ĐÁP ÁN TRONG %.2f GIÂY!\n" % [
		#guess_combos.size(), total_answers, (end_time - start_time) / 1000.0
	#])
#
	## ================== SẮP XẾP THEO TỔNG CÒN LẠI ==================
	#results.sort_custom(func(a, b): return a.total < b.total)
#
	## ================== IN BẢNG XẾP HẠNG ĐẸP – DỄ NHÌN ==================
	#print("═".repeat(100))
	#print("        XẾP HẠNG 14 COMBO 2 TỪ TỐI ƯU WORDLE (trên %d đáp án tháng 11/2025)" % total_answers)
	#print("═".repeat(100))
	#print("%-3s | %-18s | %-15s | %-15s | %-15s" % [
		#"STT", "COMBO", "LƯỢT 1 ĐÃ LOẠI", "LƯỢT 2 ĐÃ LOẠI", "TỔNG ĐÃ LOẠI"
	#])
	#print("-".repeat(100))
#
	#for i in range(results.size()):
		#var r = results[i]
		#var step1_elim = 100.0 - r.step1
		#var total_elim = 100.0 - r.total
		#var badge = " ← VUA!" if i == 0 else ""
		#print("%3d | %-18s | %10.3f%%     | %10.3f%%     | %10.3f%%%s" % [
			#i+1, r.name, step1_elim, total_elim, total_elim, badge
		#])
#
	#print("═".repeat(100))
#
	## ================== KẾT LUẬN DỄ HIỂU ==================
	#var best = results[0]
	#var best_step1_elim = 100.0 - best.step1
	#var best_total_elim = 100.0 - best.total
#
	#print("\n" + "═".repeat(90))
	#print("KẾT LUẬN CHÍNH THỨC – WORDLE THÁNG 11/2025:")
	#print("→ Combo TỐI ƯU NHẤT: %s" % best.name)
	#print("→ LƯỢT 1: %s → ĐÃ LOẠI %.3f%% từ" % [best.name.split("-")[0], best_step1_elim])
	#print("→ LƯỢT 2: %s → ĐÃ LOẠI %.3f%% từ" % [best.name.split("-")[1], best_total_elim])
	#print("→ TỔNG ĐÃ LOẠI: %.3f%% → CHỈ CÒN %.3f%% từ!" % [best_total_elim, best.total])
	#print("→ %.3f%% GIẢI ĐƯỢC TRONG 2 LƯỢT!" % best_total_elim)
	#print("→ %s LÀ VUA MỚI CỦA THÁNG 11!" % best.name)
	#print("═".repeat(90))
	
	
	#var result = find_best_second_word_no_overlap_full("RAISE", word_upper, answer_upper, true)
	#print("\nVUA MỚI: RAISE + %s → %.3f%% loại (%.3f giây)" % [
		#result.word, result.eliminated, result.time
	#])
	
	var result = find_best_second_word_perfect(
		"RAISE",
		"????E",
		"RIS",
		"A2",
		word_upper,
		true
	)
	
	print("\nVUA MỚI: RAISE + %s" % result.word)
	print("→ Loại: %.3f%% → Còn: %d từ" % [result.eliminated, result.remaining_count])

func _matches_pattern(answer: String, guess: String, pattern: Array) -> bool:
	answer = answer.to_upper()
	guess = guess.to_upper()
	
	# === 1. ĐÚNG VỊ TRÍ (pattern[i] == 2) ===
	for i in range(5):
		if pattern[i] == 2 and answer[i] != guess[i]:
			return false
	
	# === 2. BỊ LOẠI HOÀN TOÀN (pattern[i] == 0) ===
	var excluded = {}
	for i in range(5):
		if pattern[i] == 0:
			excluded[guess[i]] = true
	
	for ch in excluded.keys():
		if answer.find(ch) != -1:
			return false  # Chữ bị loại nhưng vẫn có → SAI
	
	# === 3. SAI VỊ TRÍ (pattern[i] == 1) ===
	for i in range(5):
		if pattern[i] == 1:
			var ch = guess[i]
			if answer.find(ch) == -1 or answer[i] == ch:
				return false
	
	return true

func find_best_second_word_perfect(
	first_guess: String,
	known_positions: String,
	excluded_letters: String,
	misplaced_info: String,
	all_words: Array,
	debug_mode: bool = false
) -> Dictionary:
	
	var start_time = Time.get_ticks_msec()
	var guess1 = first_guess.to_upper()
	var tested_count = 0
	var best_word = ""
	var best_elim = 0.0

	# === TẠO pattern ===
	var pattern = [0, 0, 0, 0, 0]
	for i in range(5):
		if known_positions[i] != "?":
			pattern[i] = 2
		if guess1[i] in excluded_letters:
			pattern[i] = 0
	if misplaced_info.length() >= 2:
		var ch = misplaced_info[0]
		var pos = int(misplaced_info.substr(1)) - 1
		if pos >= 0 and pos < 5 and guess1[pos] == ch:
			pattern[pos] = 1

	# === LỌC CHÍNH XÁC 58 TỪ (KHÔNG CÓ E) ===
	var remaining_answers = []
	for word in all_words:
		if _matches_pattern(word.to_upper(), guess1, pattern):
			remaining_answers.append(word.to_upper())
	
	if debug_mode:
		print("\nTÌM LƯỢT 2 TỐI ƯU SAU '%s'" % guess1)
		print("→ Vị trí đúng: %s" % known_positions)
		print("→ Chữ bị loại: %s" % excluded_letters)
		print("→ Chữ sai vị trí: %s" % misplaced_info)
		print("→ Còn lại: %d từ (PHẢI LÀ 58)" % remaining_answers.size())

	if remaining_answers.size() <= 1:
		return {"word": remaining_answers[0], "eliminated": 100.0}

	# === TÌM TỪ TỐI ƯU ===
	for candidate in all_words:
		var guess = candidate.to_upper()
		tested_count += 1
		
		# Bỏ từ có chữ bị loại
		var skip = false
		for ch in excluded_letters:
			if ch in guess:
				skip = true
				break
		if skip: continue
		
		var remaining = 0
		for ans in remaining_answers:
			var sim = _simulate_guess_fast(guess, ans)
			if _is_valid_fast(ans, sim[0], sim[1], sim[2]):
				remaining += 1
		
		var elim = 100.0 - (remaining * 100.0 / remaining_answers.size())
		
		if elim > best_elim:
			best_elim = elim
			best_word = guess
			if debug_mode:
				print("[#%04d] %-5s → loại %.3f%% ← MỚI TỐI ƯU!" % [tested_count, guess, elim])
	
	var duration = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if debug_mode:
		print("HOÀN THÀNH SAU %.3f GIÂY" % duration)
		print("→ LƯỢT 2 TỐI ƯU: %s → loại %.3f%%" % [best_word, best_elim])
	
	return {
		"word": best_word,
		"eliminated": best_elim,
		"remaining_count": remaining_answers.size(),
		"time": duration
	}

func find_best_second_word_no_overlap_full(
	first_word: String, 
	word_list: Array, 
	answer_list: Array, 
	debug_mode: bool = false
) -> Dictionary:
	
	var start_time: int = Time.get_ticks_msec()
	var answer_count: int = answer_list.size()
	var best_word: String = ""
	var best_remaining: float = 100.0
	var best_elim: float = 0.0
	var tested_count: int = 0

	var guess1: String = first_word.to_upper()
	var used_letters: Dictionary = {}
	for ch in guess1: used_letters[ch] = true

	# === LỌC TỪ KHÔNG TRÙNG CHỮ ===
	var candidates: Array = []
	for w in word_list:
		var wu = w.to_upper()
		var valid = true
		for ch in wu:
			if used_letters.has(ch):
				valid = false
				break
		if valid:
			candidates.append(wu)

	if debug_mode:
		print("\nTÌM LƯỢT 2 TỐI ƯU CHO '%s' (KHÔNG TRÙNG CHỮ - FULL SCAN)" % guess1)
		print("→ Đã loại chữ: %s" % ", ".join(used_letters.keys()))
		print("→ Còn lại: %d từ khả thi" % candidates.size())

	if candidates.size() == 0:
		return {"word": "", "eliminated": 0.0, "time": 0.0}

	# === SẮP XẾP THEO TẦN SUẤT ===
	var freq = {'T':9,'N':7,'L':4,'C':4,'M':3,'P':3,'B':3,'D':5,'G':3,'H':6,'F':3,'Y':3,'W':3,'K':2,'V':2,'J':1,'X':1,'Q':1,'Z':1,'U':4,'O':8}
	candidates.sort_custom(func(a,b):
		var sa = 0; var sb = 0
		var ua = {}; var ub = {}
		for c in a: if not ua.has(c): sa += freq.get(c,0); ua[c]=true
		for c in b: if not ub.has(c): sb += freq.get(c,0); ub[c]=true
		return sa > sb
	)

	# === FULL SCAN – KHÔNG DỪNG SỚM ===
	for candidate in candidates:
		tested_count += 1
		var combo = [guess1, candidate]
		var res = _test_combo_ultra_fast(combo, word_list, answer_list, range(answer_count), false)
		var remaining = res.total
		var elim = 100.0 - remaining

		if remaining < best_remaining:
			best_remaining = remaining
			best_word = candidate
			best_elim = elim

			if debug_mode:
				print("[#%04d] %-6s → còn %.3f%% → loại %.3f%% ← MỚI TỐI ƯU!" % [
					tested_count, candidate, remaining, elim
				])

	var duration = (Time.get_ticks_msec() - start_time) / 1000.0

	if debug_mode:
		print("HOÀN THÀNH FULL SCAN SAU %.3f GIÂY" % duration)
		print("→ LƯỢT 2 TỐI ƯU: %s → TỔNG LOẠI: %.3f%%" % [best_word, best_elim])

	return {
		"word": best_word,
		"eliminated": best_elim,
		"time": duration,
		"tested": tested_count,
		"candidates": candidates.size()
	}

# Lấy ngẫu nhiên indices
func _get_random_indices(total: int, count: int) -> Array:
	if count >= total:
		var all: Array = []
		for i in range(total): all.append(i)
		return all
	var shuffled = range(total)
	shuffled.shuffle()
	var result: Array = []
	for i in range(count):
		result.append(shuffled[i])
	return result

# Test combo nhanh tối ưu
func _test_combo_ultra_fast(
	combo: Array, 
	word_list: Array, 
	answer_list: Array, 
	indices: Array, 
	debug_mode: bool = false
) -> Dictionary:
	
	var initial_count: float = word_list.size()
	var sum_step1: float = 0.0
	var sum_total: float = 0.0
	var count: int = 0
	var perfect_count: int = 0

	var guess1: String = combo[0].to_upper()
	var guess2: String = ""
	if combo.size() > 1:
		guess2 = combo[1].to_upper()

	if debug_mode:
		print("\n" + "═".repeat(100))
		print("DEBUG: %s (%d đáp án)" % ["-".join(combo), indices.size()])
		print("═".repeat(100))

	for idx in indices:
		var answer: String = answer_list[idx]
		var current: Array = word_list.duplicate()

		# === LƯỢT 1 ===
		var res1 = _simulate_guess_fast(guess1, answer)
		var next: Array = []
		for w in current:
			if _is_valid_fast(w, res1[0], res1[1], res1[2]):
				next.append(w)
		current = next
		var p1: float = current.size() / initial_count * 100.0
		sum_step1 += p1

		# === LƯỢT 2 ===
		var p2: float = p1
		if guess2 != "":
			var res2 = _simulate_guess_fast(guess2, answer)
			next = []
			for w in current:
				if _is_valid_fast(w, res2[0], res2[1], res2[2]):
					next.append(w)
			p2 = next.size() / initial_count * 100.0
			sum_total += p2
			if next.size() == 0:
				perfect_count += 1
		else:
			sum_total += p1

		count += 1

		# === IN 1 DÒNG KHI DEBUG ===
		if debug_mode:
			var elim1 = 100.0 - p1
			var elim2 = 100.0 - p2
			var line = "[#%03d: %s] " % [idx, answer]
			line += "→ L1: %-5s: %6.3f%% (loại %6.3f%%) " % [guess1, p1, elim1]
			if guess2 != "":
				line += "→ L2: %-5s: %6.3f%% (loại %6.3f%%) " % [guess2, p2, elim2]
			line += "→ Còn: %d/%d" % [next.size(), initial_count]
			print(line)

	var avg_step1: float = sum_step1 / count
	var avg_total: float = sum_total / count

	if debug_mode:
		print("═".repeat(100))
		print("TỔNG KẾT:")
		print("→ L1 trung bình: %.3f%% còn → LOẠI %.3f%%" % [avg_step1, 100 - avg_step1])
		print("→ L2 trung bình: %.3f%% còn → TỔNG LOẠI %.3f%%" % [avg_total, 100 - avg_total])
		print("→ 100%% loại: %d lần" % perfect_count)
		print("═".repeat(100) + "\n")

	return {
		"step1": avg_step1,
		"total": avg_total,
		"perfect": perfect_count
	}

func _simulate_guess_fast(guess: String, answer: String) -> Array:
	var g = guess.to_upper()
	var a = answer.to_upper()
	var correct = ["", "", "", "", ""]
	var misplaced = ["", "", "", "", ""]
	var excluded = ["", "", "", "", ""]
	
	var count = {}
	for i in range(5):
		var ch = a[i]
		count[ch] = count.get(ch, 0) + 1

	for i in range(5):
		if g[i] == a[i]:
			correct[i] = g[i]
			count[g[i]] -= 1

	for i in range(5):
		if g[i] != a[i] and count.get(g[i], 0) > 0:
			misplaced[i] = g[i]
			count[g[i]] -= 1

	for i in range(5):
		if correct[i] == "" and misplaced[i] == "":
			excluded[i] = g[i]

	return [correct, misplaced, excluded]

func _is_valid_fast(word: String, correct: Array, misplaced: Array, excluded: Array) -> bool:
	var w = word.to_upper()
	
	# Correct
	for i in range(5):
		if correct[i] != "" and w[i] != correct[i]:
			return false

	# Misplaced + count
	var count_word = {}
	for i in range(5):
		var ch = w[i]
		count_word[ch] = count_word.get(ch, 0) + 1

	var used = {}
	for i in range(5):
		if misplaced[i] != "":
			var ch = misplaced[i]
			if w[i] == ch:
				return false
			if count_word.get(ch, 0) == 0:
				return false
			if used.get(ch, 0) >= count_word[ch]:
				return false
			used[ch] = used.get(ch, 0) + 1

	# Excluded
	for i in range(5):
		if excluded[i] != "":
			if w.find(excluded[i]) != -1:
				return false

	return true

# Test combo + trả về trung bình từng lượt
func test_combo_random(combo: Array, word_list: Array, answer_list: Array, indices: Array) -> Dictionary:
	var combo_name = ", ".join(combo).replace(",", " + ")
	print("=".repeat(70))
	print("TEST COMBO: %s (%d đáp án)" % [combo_name, indices.size()])
	print("-".repeat(70))
	
	var initial_count: int = word_list.size()
	var step_avgs: Array[float] = [0.0, 0.0]
	var step_counts: Array[int] = [0, 0]

	for idx in indices:
		var answer = answer_list[idx].to_upper()
		var current_words: Array = word_list.duplicate()
		
		# LƯỢT 1
		var guess1 = combo[0].to_upper()
		var result1 = simulate_guess(guess1, answer)
		var next_words: Array = []
		for word in current_words:
			var w = word.to_upper()
			if is_word_valid(w, result1["correct"], result1["misplaced"], result1["excluded"]):
				next_words.append(word)
		current_words = next_words
		
		var percent1 = (current_words.size() * 100.0) / initial_count
		step_avgs[0] += percent1
		step_counts[0] += 1
		
		var turn1 = "  [#%d: %s] → Lượt 1: %s → %.3f%%" % [idx, answer, guess1, percent1]
		if combo.size() == 1:
			prints(turn1)
		
		# LƯỢT 2
		if combo.size() > 1:
			var guess2 = combo[1].to_upper()
			var result2 = simulate_guess(guess2, answer)
			next_words = []
			for word in current_words:
				var w = word.to_upper()
				if is_word_valid(w, result2["correct"], result2["misplaced"], result2["excluded"]):
					next_words.append(word)
			current_words = next_words
			
			var percent2 = (current_words.size() * 100.0) / initial_count
			step_avgs[1] += percent2
			step_counts[1] += 1
			
			var turn2 = "→ Lượt 2: %s → %.3f%%\n" % [guess2, percent2]
			prints(turn1, turn2)
	
	# TÍNH TRUNG BÌNH
	var avg1 = step_avgs[0] / step_counts[0] if step_counts[0] > 0 else 0.0
	var avg2 = step_avgs[1] / step_counts[1] if step_counts[1] > 0 else 0.0
	
	print("→ Trung bình Lượt 1: %.3f%%" % avg1)
	print("→ Trung bình Lượt 2: %.3f%%" % avg2)
	print("→ Tổng trung bình: %.3f%%\n" % avg2)
	
	return {
		"avg": avg2,
		"count": indices.size(),
		"step1_avg": avg1
	}

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
