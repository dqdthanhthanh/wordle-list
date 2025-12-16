extends Node

var all_answer_past: Array = load_words_to_array("res://wordle-answers-past.txt")
var word_list: Array = load_words_to_array("res://valid-wordle-words.txt")
#var word_list: Array = load_words_to_array("res://wordle-full.txt")
var word_list_exclude: Array = load_words_to_array("res://wordle-full_exclude.txt")
var all_answer: Array = load_words_to_array("res://wordle-answer-full.txt")
var all_answer_exclude: Array = load_words_to_array("res://wordle-answer-exclude.txt")
var limit_answer_past:bool = true
var able_word_list:Array
var able_answer:Array
var contain_true_score: float = 2
var contain_false_score: float = 1
var weight_missing_letters:float = 5

"""
Tổng kết: 1570 còn lại data mới
SALET 3.76 [0, 48, 582, 702, 181, 43, 14]
CRANE 3.83 [0, 13, 553, 752, 204, 36, 12]
TRACE 3.84 [0, 16, 550, 741, 213, 39, 11]
STARE 3.84 [0, 16, 557, 724, 217, 45, 11]
ROATE 3.85 [0, 17, 530, 747, 228, 38, 10]
Trung bình: 3.824

Tổng kết: 725 còn lại data cũ
SALET 2.98 [0, 134, 477, 108, 5, 1, 0]
TARSE 3.00 [0, 126, 480, 116, 2, 1, 0]
STARE 3.01 [0, 117, 487, 118, 3, 0, 0]
TRACE 3.06 [0, 115, 464, 135, 10, 0, 1]
CRANE 3.05 [0, 115, 473, 123, 11, 3, 0]
LEAST 3.03 [0, 117, 478, 120, 9, 1, 0]
ROATE 3.05 [0, 108, 484, 125, 7, 1, 0]
SOARE 3.04 [0, 128, 453, 133, 10, 1, 0]
ALTER 3.03 [0, 114, 479, 125, 7, 0, 0]
GRAME 3.13 [0, 98, 451, 160, 14, 1, 1]
ADIEU 3.22 [0, 76, 434, 197, 18, 0, 0]
AUDIO 3.25 [0, 74, 421, 210, 18, 2, 0]

Tổng kết khi giải 1613 đáp án cũ
TRACE 3.66 [1, 49, 678, 702, 152, 20, 11]
CRANE 3.68 [1, 40, 671, 712, 156, 15, 18]
SALET 3.72 [0, 38, 655, 697, 183, 26, 14]
LEAST 3.72 [1, 28, 651, 713, 189, 19, 12]
STARE 3.72 [1, 31, 655, 718, 167, 18, 23]
ROATE 3.73 [0, 37, 632, 721, 192, 15, 16]
SOARE 3.73 [0, 23, 694, 664, 181, 34, 17]
ALTER 3.74 [1, 36, 599, 792, 144, 17, 24]
MARSE 3.75 [0, 27, 610, 752, 195, 19, 10]
AUDIO 3.90 [1, 27, 497, 749, 292, 36, 11]
ADIEU 3.96 [0, 16, 450, 806, 282, 38, 21]
"""

# ===============================
# _ready
# ===============================
func _ready()-> void:
	#convert_to_uppercase_and_sort("res://wordle-answers-past.txt","res://wordle-answers-past_new.txt")
	#convert_to_one_word_per_line("res://wordle_words.txt","res://wordle_words.txt")
	#convert_to_word_list("res://list_weight.txt", "res://clean_word_list.txt")
	#merge_wordle_files("res://clean_word_list.txt", "res://wordle-answers-past.txt", "res://wordle-answer-full.txt")
	#subtract_list("res://wordle-full.txt", "res://wordle-answers-past.txt","res://wordle-full_exclude.txt")
	#subtract_list("res://wordle-answer-full.txt", "res://wordle-answers-past.txt","res://wordle-answer-exclude.txt")
	
	#var word_list_fix:Array[String] = ["SEGUE"]
	#add_word_to_list_and_save("res://wordle-answers-past.txt",word_list_fix)
	#remove_word_from_list_and_save("res://wordle-answer-exclude.txt",word_list_fix)
	
	limit_answer_past = true
	able_word_list = word_list
	if limit_answer_past == true:
		able_answer = all_answer_exclude
	else:
		able_answer = all_answer
	
	main_process()
	#all_combo_test(true,"ISSUE")
	
	#var corrects = ["AUGUR", "AWARD", "BRAVA", "DRAMA", "DWARF", "FRAUD", "GRAPH", "GRAVY", "GUARD", "HYDRA", "QUARK", "RUMBA", "UMBRA", "WHARF"]
	#var answers = corrects.duplicate()
	#answers.insert(0, "FUDGY")
	#all_combo_main_process(answers,corrects)

func main_process()-> void:
	# Data
	var contain_true:String = "?????".to_upper()
	var contain_false:String = "".to_upper()
	var exclude:String = "".to_upper()
	var contain = "".to_upper()
	
	# Check danh sách
	print("Đã đọc %d từ từ: words.txt" % able_word_list.size())
	
	var remaining_words = get_remaining_words(able_answer, contain_true, exclude, contain_false)
	#remaining_words = filter_by_contain(all_answer, contain,contain.length()-1)
	var position_weights = compute_position_weights(remaining_words)
	#position_weights = [0,0,0,0,0]
	var freq_array = count_letter_frequency(remaining_words)
	
	print("→ LỌC HOÀN TẤT: %d từ còn lại" % remaining_words.size())
	print(remaining_words)
	print(freq_array)
	print(position_weights)
	
	var results = filtered_word_list(able_word_list, remaining_words, exclude, contain_true, contain_false, true)
	
	if results.size() > 0:
		prints("\n→ Từ tốt nhất: ",results[0])
	
	var check_size = 20
	
	if remaining_words.size() <= check_size:
		prints("")
		find_best_guess_from_remaining(remaining_words)
		prints("")
	
	call_API_final_check(remaining_words,check_size)
	
	save_data_check(remaining_words,freq_array,position_weights,results)

func all_combo_test(is_multiple:bool = false, test = "SEGUE"):
	#corrects = ["JOKER","POPPY","MOMMY","STUNT","GIDDY","JUDGE","REGAL","DITTY","FIXER","STOUT","MOIST","RODEO","HOLLY","BOXER","TASTE","HUNCH","SPOON","WATCH","POUND","SHAKE","SHADE","FOLLY","RIPER","RIDER","TAUNT","JOLLY","HATCH","FROWN","ROWER"]
	var corrects = [test]
	if is_multiple == true:
		#var wordle:Array = all_answer
		corrects = pick_random_words(able_answer, able_answer.size()-1)
	
	#var answers:Array[String] = ["SALET","SLATE"]
	#var answers:Array[String] = ["TRACE","SALET","CRANE","ROATE","STARE"]
	var answers:Array[String] = ["TRACE","CRANE","SALET","LEAST","STARE","ROAST","ROATE","SOARE","ALTER","ADIEU","AUDIO"]
	
	all_combo_main_process(answers,corrects)
	$AudioStreamPlayer.play()

func all_combo_main_process(answers:Array,corrects:Array,debug:bool = false):
	prints("Số combo test:",answers.size(),answers)
	prints("Số đáp án:",corrects.size(),corrects)
	
	var check 
	var save = []
	
	for i in answers.size():
		save.append([0,0,0,0,0,0,0])
	
	for i in corrects.size():
		prints("_____")
		for j in answers.size():
			check = guess_main_process(answers[j],corrects[i],debug)
			if check[1] == true:
				save[j][check[0].size()-1] += 1
			else:
				save[j][6] += 1
			prints(i+1,answers[j],"%.2f" % compute_average_score(save[j]),save[j],check[0].size(),corrects[i],check)
		able_answer.erase(corrects[i])
		able_word_list.erase(corrects[i])
	
	prints("Tổng kết:",corrects.size())
	var sum = 0
	for i in answers.size():
		prints(answers[i],"%.2f" % compute_average_score(save[i]),save[i])
		sum += float("%.2f" % compute_average_score(save[i]))
	prints("Trung bình:",float(sum)/answers.size())

func guess_main_process(answer:String = "ROATE",correct:String = "CLUNG",debug:bool=false)-> Array:
	# Check danh sách
	var guesses:Array[String]
	var contain_true:String = "?????"
	var contain_false:String = ""
	var exclude:String = ""
	var remaining_words:Array
	var data
	var check:bool = false
	var size:int
	
	for i in 6:
		if debug:
			prints("Lượt",i,answer)
		if !guesses.has(answer):
			#if i == 1:
				#guesses.append("SALET")
			#elif i == 2:
				#guesses.append("CORNI")
			#else:
				guesses.append(answer)
		data = compute_constraints_from_guesses(correct, guesses)
		contain_true = data.contain_true
		contain_false = data.contain_false
		exclude = data.exclude
		remaining_words = get_remaining_words(able_answer, contain_true, exclude, contain_false)
		size = remaining_words.size()
		if debug:
			prints("remaining_words",remaining_words)
		if size > 0:
			if size == 1:
				answer = remaining_words[0]
				if !guesses.has(answer):
					guesses.append(answer)
				check = true
			else:
				contain_true_score = 2
				contain_false_score = 1
				if size <= 2:
					weight_missing_letters = 0
				elif size <= 10:
					# 2-10 → 0-2
					weight_missing_letters = remap(size, 2, 10, 1, 2)
				elif size <= 100:
					# 10-100 → 2-5
					weight_missing_letters = remap(size, 10, 100, 2, 5)
				else:
					weight_missing_letters = 5  # cap max weight
				if i == 4:
					size *= size
				#weight_missing_letters = 0
				
				var list = able_word_list.duplicate()
				for guess in guesses:
					if list.has(guess):
						list.erase(guess)
				var result = filtered_word_list(list, remaining_words, exclude, contain_true, contain_false, false)
				answer = result[0].word
				if debug:
					if size < 10:
						print("result",result)
			if debug:
				prints("answer",answer)
				prints(data)
				prints(correct,guesses)
			if "?" not in data.contain_true:
				check = true
				if debug:
					prints("Tìm ra đáp án đúng cho",correct)
				break
			if debug:
				prints("Còn lại",size)
		else:
			check = true
			break
	if debug:
		prints([guesses,check])
	
	return [guesses,check]

func check_guess_process()-> void:
	var correct:String = "CADDY"
	var guess:Array[String] = ["ROATE"]
	var result = compute_constraints_from_guesses(correct, guess)
	print(correct)
	print(guess)
	print(result)

func compute_constraints_from_guesses(correct: String, guesses: Array) -> Dictionary:
	"""
	correct: ví dụ "OPINE" (đã uppercase hoặc sẽ được uppercase trong hàm)
	guesses: Array các Array, ví dụ [["ROATE"], ["UNITY"], ...]
	trả về: { "contain_true": "????E", "contain_false": "O2", "exclude": "RAT" }
	"""
	correct = correct.to_upper()
	var L = correct.length()
	if L != 5:
		push_error("Answer length must be 5")
		return {}

	# init
	var contain_true := "?????"  # 5 chars
	var contain_false_map := {}   # {'O': [2,4], ...} positions 1-based
	var exclude_map := {}

	# Duyệt từng guess (mỗi guess là array, lấy phần tử 0)
	for g_arr in guesses:
		var guess = str(g_arr).to_upper()
		if guess.length() != L:
			continue

		# 1) chuẩn bị: đánh dấu green và đếm remaining letters trong answer
		var used_correct = []
		for i in range(L):
			used_correct.append(false)
		# mark greens and build remaining_count
		var remaining_count := {}
		for i in range(L):
			# we won't fill remaining_count yet — first mark greens
			pass
		# mark greens
		for i in range(L):
			if guess[i] == correct[i]:
				# set contain_true at position i
				contain_true = contain_true.substr(0, i) + guess[i] + contain_true.substr(i + 1)
				used_correct[i] = true
		# build remaining_count from answer for non-green positions
		for i in range(L):
			if not used_correct[i]:
				var ch = correct[i]
				remaining_count[ch] = remaining_count.get(ch, 0) + 1

		# 2) xử lý non-green positions: nếu letter còn trong remaining_count => yellow (misplaced)
		#    nếu không => gray (exclude), nhưng chỉ mark exclude sau khi chắc chắn không yellow/green
		for i in range(L):
			if guess[i] == correct[i]:
				continue  # already green
			var ch = guess[i]
			if remaining_count.get(ch, 0) > 0:
				# yellow: ghi vị trí sai (i+1) cho chữ ch
				if not contain_false_map.has(ch):
					contain_false_map[ch] = []
				# tránh push trùng vị trí
				if (i + 1) not in contain_false_map[ch]:
					contain_false_map[ch].append(i + 1)
				# chiếm 1 occurrence trong remaining_count
				remaining_count[ch] = remaining_count[ch] - 1
			else:
				# gray -> khả năng exclude, nhưng có thể letter đã là green/yellow ở nơi khác;
				# ở đây remaining_count đã xử lý occurrences, nên nếu còn 0 thì letter là gray
				# lưu tạm vào exclude_map (key true)
				# chú ý: nếu letter đã là green hoặc đã có yellow từ trước, không đưa vào exclude
				if contain_true.find(ch) == -1 and not contain_false_map.has(ch):
					exclude_map[ch] = true

	# Sau khi xử lý tất cả guesses, chuẩn hoá outputs
	# contain_true đã là chuỗi 5 ký tự
	# build contain_false string theo format LETTER + concat positions
	var contain_false_str := ""
	for ch in contain_false_map.keys():
		# sắp xếp các vị trí tăng dần
		contain_false_map[ch].sort()
		var s = str(ch)
		for pos in contain_false_map[ch]:
			s += str(pos)
		contain_false_str += s

	# build exclude string (loại trùng)
	var exclude_str := ""
	for ch in exclude_map.keys():
		exclude_str += ch
	
	# trả về
	return {
		"contain_true": contain_true,
		"contain_false": contain_false_str,
		"exclude": exclude_str
	}

func compute_average_score(stats: Array) -> float:
	var total_games = 0
	var total_score = 0.0

	for i in range(stats.size()):
		var count = stats[i]
		total_games += count

		var score = (i + 1) if i < 6 else 7
		total_score += score * count

	if total_games == 0:
		return 0.0

	# Tính trung bình và làm tròn 3 chữ số thập phân
	return (total_score / total_games)

func check_combo_data():
	var guess_combos: Array[Array] = [
		["ROATE", "SULCI"],
		["SOARE", "UNITY"],
		["SOARE", "CLINT"],
		["TRACE", "SLING"],
		["CRANE", "SLOTH"],
		["RAISE", "COUNT"],

		["STARE", "COILN"],
		["SALET", "CRONY"],
		["LEAST", "CRONY"], 
		["ARISE", "COUNT"],
		
		["AUDIO", "STERN"],
		["ADIEU", "STORY"],
		["OUIJA", "STERN"],
		
		["ADIEU", "SPORT"],
		["RAISE", "GLOUT"], 
	]
	
	var rank_word_list = rank_word_list_by_remaining(word_list, all_answer)
	for r in rank_word_list:
		print(r["word"], "→ loại được:", r["score"], "từ, còn lại:", r["remaining_after"])

	#prints(filter_words_by_guess("ROATE", word_list).size())
	#prints(filter_words_by_guess("ROATESULCI", word_list).size())
	var ranked = rank_guess_combos(guess_combos, word_list)
	for r in ranked:
		print("Combo:", r["combo"], " → total_score:", r["total_score"])
		for ws in r["word_scores"]:
			print("   Word:", ws["word"], " → score:", ws["score"])

# Lọc words: giữ các từ có >= min_count ký tự (không trùng lặp) nằm trong `contain`.
func filter_by_contain(words: Array, contain: String, min_count: int) -> Array:
	# Chuyển sang chữ hoa để so sánh không phân biệt hoa thường
	var contain_up := contain.to_upper()
	# Tạo set chữ từ 'contain' để lookup O(1)
	var contain_set := {}
	for ch in contain_up:
		# chỉ thêm A-Z nếu cần (an toàn)
		if ch >= "A" and ch <= "Z":
			contain_set[ch] = true

	# Nếu không có chữ nào trong contain thì trả về mảng rỗng
	if contain_set.keys().size() == 0:
		return []

	# Nếu min_count <= 0 trả về toàn bộ danh sách (không lọc)
	if min_count <= 0:
		return words.duplicate()

	var out := []
	for w in words:
		if typeof(w) != TYPE_STRING:
			continue
		var word_up:String = w.to_upper()
		var seen:= {}
		var match_count := 0
		# đếm số chữ *khác nhau* của word nằm trong contain_set
		for ch in word_up:
			if not seen.has(ch) and contain_set.has(ch):
				seen[ch] = true
				match_count += 1
				# bỏ sớm nếu đạt đủ
				if match_count >= min_count:
					out.append(w)
					break
	# trả về danh sách đã lọc (giữ nguyên thứ tự ban đầu)
	return out

func filtered_word_list(word_list, remaining_words, exclude, contain_true, contain_false, debug:bool = false) -> Array:
	var filtered_word_lists = []
	for word in word_list:
		var wu = word.to_upper()
		var skip = false
		for c in exclude.to_upper():
			if wu.find(c) != -1:
				skip = true
				break
		if not skip:
			filtered_word_lists.append(word)
	
	var letters_in_remaining = []
	var freq_array = count_letter_frequency(remaining_words)
	for pair in freq_array:
		letters_in_remaining.append(pair[0])  # lấy tất cả các chữ xuất hiện trong remaining_words

	var filtered_word_list2 = []
	for word in filtered_word_lists:
		var wu = word.to_upper()
		var valid = true
		for ch in wu:
			if not letters_in_remaining.has(ch):
				valid = false
				break
		if valid:
			filtered_word_list2.append(word)

	filtered_word_lists = filtered_word_list2
	if debug:
		print("→ filtered_word_list còn %d từ sau khi lọc theo letter_freq" % filtered_word_lists.size())
		print(letters_in_remaining)
		print(filtered_word_list)
	
	var position_weights = compute_position_weights(remaining_words)
	var result = find_best_eliminator(filtered_word_lists, remaining_words, contain_true, contain_false,position_weights,debug)
		
	return result

func call_API_final_check(remaining_words,size):
	prints("remaining_words",remaining_words)
	if remaining_words.size() <= size:
		var best = await get_most_common_word(remaining_words)
		print("Most common word:", best)

func save_data_check(remaining_words,freq_array,position_weights,results):
	await save_results_to_file(results, "res://elimination_result.txt")
	await save_text_to_file_at_top(position_weights, "res://elimination_result.txt",true)
	await save_text_to_file_at_top(freq_array, "res://elimination_result.txt",true)
	await save_text_to_file_at_top(remaining_words, "res://elimination_result.txt",true)

# ===============================
# Giả lập lượt đoán
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

# ===============================
# Tìm từ loại tốt nhất lượt 2
func find_best_eliminator(
	word_list: Array, 
	remaining_words: Array, 
	contain_true: String = "",         
	contain_false: String = "",        
	position_weights:Array = [0,0,0,0,0],
	debug_mode: bool = false
) -> Array:
	
	var results = []
	var total = remaining_words.size()
	var tested = 0
	
	# === 1. THỐNG KÊ TẦN SUẤT CHỮ TRONG remaining_words ===
	var letter_freq = {}
	for word in remaining_words:
		var seen = {}
		for ch in word.to_upper():
			if not seen.has(ch):
				letter_freq[ch] = letter_freq.get(ch, 0) + 1
				seen[ch] = true
	
	# === 2. GHÉP contain_true + contain_false ===
	var contain_full = ""
	var letters = {}
	for ch in contain_true.to_upper():
		if ch != "?":
			letters[ch] = true
	for ch in contain_false.to_upper():
		if ch >= "A" and ch <= "Z":
			letters[ch] = true
	for ch in letters.keys():
		contain_full += ch
	
	# === 3. DUYỆT MỖI TỪ TRONG word_list ===
	for candidate in word_list:
		var wu = candidate.to_upper()
		
		# === 3A. TÍNH ĐỘ PHỦ (overlap_count) ===
		var overlap_count = 0
		for ans in remaining_words:
			var sim = _simulate_guess_fast(candidate, ans)
			if _is_valid_fast(ans, sim[0], sim[1], sim[2], candidate):
				overlap_count += 1
		
		var overlap_percent = (overlap_count * 100.0) / total
		
		# === 3B. TÍNH SCORE DỰA TRÊN TẦN SUẤT CHỮ ===
		var score = 0
		var seen = {}
		for i in range(wu.length()):
			var ch = wu[i]
			if not seen.has(ch):
				if contain_true.find(ch) != -1:
					score += letter_freq.get(ch, 0) * contain_true_score
				elif contain_false.find(ch) != -1:
					score += letter_freq.get(ch, 0) * contain_false_score
				else:
					score += letter_freq.get(ch, 0)
				seen[ch] = true
		
		# === 3C. CỘNG BONUS THEO contain_full (các chữ quan trọng) ===
		var match_count = 0
		for ch in contain_full:
			if wu.find(ch) != -1:
				match_count += 1
		if contain_full.length() > 0:
			score += score * match_count / contain_full.length()
		
		# === 3D. TRỌNG SỐ VỊ TRÍ ===
		for i in range(wu.length()):
			var ch = wu[i]
			if letter_freq.has(ch):
				score += letter_freq[ch] * position_weights[i] / 10.0
		
		# === 3E. BONUS CHO CÁC CHỮ KHÔNG CÓ TRONG contain_full ===
		#      yêu cầu của bạn: bonus_missing += bonus_missing * weight_missing_letters
		var bonus_missing = 0.0
		for ch in wu:
			if contain_full.find(ch) == -1:
				if bonus_missing == 0:
					bonus_missing = 1.0   # base để được nhân lên
				bonus_missing += bonus_missing * weight_missing_letters
		
		score += bonus_missing
		
		# === LƯU KẾT QUẢ ===
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
	
	# === SẮP XẾP THEO SCORE GIẢM DẦN ===
	results.sort_custom(func(a, b):
		return a["score"] > b["score"]
	)
	
	return results

# ===============================
# Lưu kết quả
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

func compute_position_weights(word_list):
	var position_counts = [ {}, {}, {}, {}, {} ]  # 5 vị trí
	for word in word_list:
		for i in range(5):
			var ch = word[i]
			position_counts[i][ch] = position_counts[i].get(ch, 0) + 1
	
	var weights = []
	var total_words = word_list.size()
	for i in range(5):
		var max_count = 0
		for ch in position_counts[i].keys():
			max_count = max(max_count, position_counts[i][ch])
		weights.append(float(max_count) / total_words)
	return weights

func filter_words_by_guess(guess: String, remaining_words: Array) -> Array:
	var filtered = []
	var guess_chars = {}
	for ch in guess.to_upper():
		guess_chars[ch] = true
	
	for word in remaining_words:
		var wu = word.to_upper()
		var has_any = false
		for ch in wu:
			if guess_chars.has(ch):
				has_any = true
				break
		if has_any:
			filtered.append(word)
	
	return filtered

func score_guess_combo(combo: Array, remaining_words: Array) -> Dictionary:
	var current_remaining:Array = remaining_words.duplicate()
	var guess:String
	var word_scores = []
	for i in combo:
		guess += i
		var before_count = current_remaining.size()
		current_remaining = filter_words_by_guess(guess, remaining_words)
		var eliminated = current_remaining.size()
		word_scores.append({
			"word": i,
			"score": eliminated,
			"remaining_after": current_remaining.size()
		})
	return {
		"combo": combo,
		"total_score": current_remaining.size(),
		"word_scores": word_scores
	}

func rank_guess_combos(guess_combos: Array, remaining_words: Array) -> Array:
	var results = []
	for combo in guess_combos:
		var combo_result = score_guess_combo(combo, remaining_words)
		results.append(combo_result)
	# Sắp xếp giảm dần theo total_score
	results.sort_custom(func(a,b):
		return a["total_score"] > b["total_score"]
	)
	return results

func rank_word_list_by_remaining(word_list: Array, remaining_words: Array) -> Array:
	var results = []
	var total = remaining_words.size()
	
	for word in word_list:
		var filtered = filter_words_by_guess(word, remaining_words)
		var score = total - filtered.size()  # số từ bị loại
		results.append({
			"word": word,
			"score": score,
			"remaining_after": filtered.size()
		})
	
	# Sắp xếp giảm dần theo score
	results.sort_custom(func(a, b):
		return a["score"] < b["score"]
	)
	
	return results

# Gọi API kiểm tra tần suất từ
func get_word_frequency(word: String) -> float:
	var url = "https://api.datamuse.com/words?sp=%s&md=f" % word
	var request := HTTPRequest.new()
	add_child(request)

	var err = request.request(url)  # chỉ cần url, mặc định GET
	if err != OK:
		return 0.0

	var result = await request.request_completed
	var body: PackedByteArray = result[3]
	var text = body.get_string_from_utf8()

	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_ARRAY or data.size() == 0:
		return 0.0

	var tags = data[0].get("tags", [])
	for t in tags:
		if t.begins_with("f:"):
			return float(t.substr(2))
	return 0.0

# Lấy từ thông dụng nhất trong danh sách
func get_most_common_word(words: Array) -> String:
	var best_word = ""
	var best_freq = -1.0

	for w in words:
		var freq = await get_word_frequency(w)
		print("Word:", w, " freq:", freq)

		if freq > best_freq:
			best_freq = freq
			best_word = w

	return best_word

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

func pick_random_words(word_list: Array, count: int) -> Array:
	if count >= word_list.size():
		return word_list.duplicate()
	
	var selected = []
	var indices = []
	
	# Tạo mảng index
	for i in range(word_list.size()):
		indices.append(i)
	
	# Trộn mảng index
	indices.shuffle()
	
	# Lấy count phần tử đầu
	for i in range(count):
		selected.append(word_list[indices[i]])
	
	return selected

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

# wordlist_tools.gd
# TOOL: subtract_list() – Loại bỏ từ trùng giữa 2 file → lưu file mới
# Author: AI Supreme God | 19/11/2025

func subtract_list(
	source_file: String,
	remove_file: String,
	output_file: String,
	case_sensitive: bool = false
) -> void:
	
	print("BẮT ĐẦU subtract_list()")
	print("→ Nguồn      : %s" % source_file)
	print("→ Loại bỏ    : %s" % remove_file)
	print("→ Kết quả    : %s" % output_file)
	
	var start_time = Time.get_ticks_msec()
	
	# Đọc file cần loại bỏ (danh sách đáp án chính thức)
	var to_remove = {}
	var file_remove = FileAccess.open(remove_file, FileAccess.READ)
	if not file_remove:
		push_error("KHÔNG MỞ ĐƯỢC FILE LOẠI BỎ: %s" % remove_file)
		return
	
	while !file_remove.eof_reached():
		var line = file_remove.get_line().strip_edges()
		if line.length() == 5:
			var key = line if case_sensitive else line.to_upper()
			to_remove[key] = true
	file_remove.close()
	print("→ Đã đánh dấu %,d từ cần loại bỏ" % to_remove.size())
	
	# Đọc file nguồn và lọc
	var result_words = []
	var file_source = FileAccess.open(source_file, FileAccess.READ)
	if not file_source:
		push_error("KHÔNG MỞ ĐƯỢC FILE NGUỒN: %s" % source_file)
		return
	
	var total_read = 0
	while !file_source.eof_reached():
		var line = file_source.get_line().strip_edges()
		if line.length() != 5: 
			continue
		total_read += 1
		
		var key = line if case_sensitive else line.to_upper()
		if not to_remove.has(key):
			result_words.append(line)  # Giữ nguyên chữ hoa/thường gốc
	
	file_source.close()
	
	# Ghi kết quả ra file mới
	var file_out = FileAccess.open(output_file, FileAccess.WRITE)
	if not file_out:
		push_error("KHÔNG GHI ĐƯỢC FILE KẾT QUẢ: %s" % output_file)
		return
	
	# Sắp xếp A-Z cho đẹp (tùy chọn)
	result_words.sort()
	
	for word in result_words:
		file_out.store_line(word)
	file_out.close()
	
	var duration = (Time.get_ticks_msec() - start_time) / 1000.0

func split_multi(s: String, separators: Array[String]) -> Array[String]:
	var result: Array[String] = [s]
	for sep in separators:
		var new_result: Array[String] = []
		for part in result:
			var chunks = part.split(sep, false)
			for c in chunks:
				var t = c.strip_edges()
				if t != "":
					new_result.append(t)
		result = new_result
	return result


func convert_to_word_list(input_path: String, output_path: String):
	var f = FileAccess.open(input_path, FileAccess.READ)
	if f == null:
		print("Cannot open input file:", input_path)
		return
	
	var temp_words: Array[String] = []

	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "":
			continue

		# Tách bằng nhiều ký tự phân tách
		var parts = split_multi(line, [" ", "\t", ",", ";"])

		for p in parts:
			p = p.strip_edges()
			# Nếu muốn chỉ giữ từ chỉ chứa chữ cái:
			if p != "" and p.is_valid_identifier():
				temp_words.append(p.to_upper())
	
	f.close()

	# 🔥 Loại trùng bằng dictionary
	var seen := {}
	var words: Array[String] = []
	for w in temp_words:
		if not seen.has(w):
			seen[w] = true
			words.append(w)

	# Sắp xếp
	words.sort()

	# Ghi file
	var out = FileAccess.open(output_path, FileAccess.WRITE)
	for w in words:
		out.store_line(w)
	out.close()

	print("Done. Saved:", words.size(), "words to:", output_path)

func find_best_guess_from_remaining(
	remaining_words: Array,
	weight_file_path: String = "res://list_weight.txt"
) -> Dictionary:
	
	print("=== TÌM TỪ ĐOÁN TỐT NHẤT TRONG %d TỪ CÒN LẠI ===" % remaining_words.size())
	
	var file = FileAccess.open(weight_file_path, FileAccess.READ)
	if not file:
		push_error("KHÔNG MỞ ĐƯỢC FILE: %s" % weight_file_path)
		return {}
	
	var word_weights = {}  # "YUMMY": 57.6636
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts = line.split("\t", true, 1)  # Tách bởi tab
		if parts.size() < 2:
			continue
		var word = parts[0].strip_edges().to_upper()
		var weight_str = parts[1].replace("%", "").strip_edges()
		var weight = float(weight_str)
		word_weights[word] = weight
	
	file.close()
	print("Đã load %d từ với trọng số từ file!" % word_weights.size())
	
	# Lọc chỉ những từ có trong remaining_words
	var candidates = []
	for word in remaining_words:
		var w = word.to_upper()
		if word_weights.has(w):
			candidates.append({
				"word": w,
				"weight": word_weights[w]
			})
		else:
			# Nếu không có trong file → mặc định 58% (rất tốt)
			candidates.append({
				"word": w,
				"weight": 58.0
			})
	
	# Sắp xếp theo trọng số GIẢM DẦN (cao nhất = tốt nhất)
	candidates.sort_custom(func(a, b): return a.weight > b.weight)
	
	# In bảng xếp hạng đẹp
	print("\nXẾP HẠNG TỪ TỐT NHẤT (dựa trên % loại bỏ trung bình):\n")
	for i in range(candidates.size()):
		var c = candidates[i]
		var rank = i + 1
		var star = " → TỐT NHẤT!" if rank == 1 else ""
		print("%d. %s → %.4f%%%s" % [rank, c.word, c.weight, star])
	
	if candidates.size() > 0:
		var best = candidates[0]
		print("\nKẾT LUẬN: TỪ TỐT NHẤT ĐỂ ĐOÁN NGAY BÂY GIỜ LÀ:")
		print(">>> %s <<< (%.4f%%)" % [best.word, best.weight])
		return best
	else:
		print("Không tìm thấy từ nào hợp lệ!")
		return {}

# convert_horizontal_to_vertical.gd
# Godot 4 | Tác giả: Wordle AI God
# Chuyển file wordle_words.txt (các từ nằm ngang) → mỗi từ 1 dòng

func convert_to_one_word_per_line(
	input_path: String = "res://wordle_words.txt",
	output_path: String = "res://wordle_words_vertical.txt"
) -> void:
	
	print("BẮT ĐẦU CHUYỂN ĐỔI: MỖI TỪ 1 DÒNG")
	print("→ Từ file: %s" % input_path)
	print("→ Ra file: %s" % output_path)
	
	var file_in = FileAccess.open(input_path, FileAccess.READ)
	if not file_in:
		push_error("KHÔNG MỞ ĐƯỢC FILE NGUỒN: %s" % input_path)
		return
	
	var all_text = file_in.get_as_text()
	file_in.close()
	
	# Tách tất cả từ (bằng space hoặc nhiều space)
	var words = []
	for word in all_text.split(" ", false):  # false = bỏ qua khoảng trắng thừa
		var w = word.strip_edges().to_upper()
		if w.length() == 5 and w.is_valid_identifier():  # chỉ giữ từ 5 chữ A-Z
			words.append(w)
	
	# Ghi ra file mới – mỗi từ 1 dòng
	var file_out = FileAccess.open(output_path, FileAccess.WRITE)
	if not file_out:
		push_error("KHÔNG GHI ĐƯỢC FILE KẾT QUẢ: %s" % output_path)
		return
	
	for word in words:
		file_out.store_line(word)
	
	file_out.close()
	
	print("\nHOÀN THÀNH SIÊU NHANH!")
	print("→ Tổng cộng: %,d từ được chuyển" % words.size())
	print("→ Đã lưu thành công: %s" % output_path)
	print("→ Sẵn sàng dùng cho Wordle AI!\n")

# to_uppercase_and_sort.gd
# Godot 4 | Tác giả: Wordle God Supreme
# Chuyển toàn bộ từ thành CHỮ HOA + sắp xếp thứ tự A → Z

# to_uppercase_and_sort_fixed.gd
# Godot 4.5+ HOÀN HẢO – Không dùng .unique()

func convert_to_uppercase_and_sort(
	input_path: String = "res://wordle_words.txt",
	output_path: String = "res://wordle_words_upper_sorted.txt"
) -> void:
	
	print("BẮT ĐẦU CHUYỂN: chữ thường → CHỮ HOA + SẮP XẾP A-Z + LOẠI TRÙNG")
	print("→ Input : %s" % input_path)
	print("→ Output: %s" % output_path)
	
	var file_in = FileAccess.open(input_path, FileAccess.READ)
	if not file_in:
		push_error("KHÔNG MỞ ĐƯỢC FILE NGUỒN: %s" % input_path)
		return
	
	var word_dict := {}  # Dùng Dictionary để tự động loại trùng (siêu nhanh!)
	
	while !file_in.eof_reached():
		var line = file_in.get_line().strip_edges()
		if line == "":
			continue
		var upper = line.to_upper()
		if upper.length() == 5 and upper.is_valid_identifier():  # chỉ A-Z, 5 chữ
			word_dict[upper] = true  # key duy nhất → tự loại trùng
	
	file_in.close()
	
	# Chuyển keys thành Array và sắp xếp A-Z
	var words := word_dict.keys()
	words.sort()  # Godot 4 vẫn có .sort() bình thường
	
	# Ghi ra file – mỗi từ 1 dòng
	var file_out = FileAccess.open(output_path, FileAccess.WRITE)
	if not file_out:
		push_error("KHÔNG GHI ĐƯỢC FILE: %s" % output_path)
		return
	
	for word in words:
		file_out.store_line(word)
	
	file_out.close()
	
	print("\nHOÀN THÀNH THÀNH CÔNG!")
	print("→ Tổng cộng: %,d từ duy nhất" % words.size())
	print("→ Đã chuyển hết thành CHỮ HOA")
	print("→ Đã sắp xếp A → Z")
	print("→ Đã loại bỏ hoàn toàn từ trùng")
	print("→ File đã lưu: %s" % output_path)
	print("→ SẴN SÀNG CHO WORDLE AI THẦN THÁNH!\n")

func remove_word_from_list_and_save(
	path: String,
	remove_words: Array
) -> void:
	
	var past_words: Array = load_words_to_array(path)
	var remove_dict := {}
	var result := []
	
	# Tạo dict các từ cần xoá
	for w in remove_words:
		remove_dict[w.to_upper()] = true
	
	# Lọc giữ lại từ KHÔNG bị xoá
	for w in past_words:
		var key = w.to_upper()
		if not remove_dict.has(key):
			result.append(key)
	
	result.sort()
	
	# Ghi đè lại chính file cũ
	var file := FileAccess.open(path, FileAccess.WRITE)
	for w in result:
		file.store_line(w)
	file.close()

func add_word_to_list_and_save(
	path: String,
	add_words: Array
) -> void:
	
	var past_words: Array = load_words_to_array(path)
	var word_dict := {}
	
	# Đưa toàn bộ từ cũ vào dict chống trùng
	for w in past_words:
		word_dict[w.to_upper()] = true
	
	# Thêm từ mới (nếu chưa có)
	for w in add_words:
		var key = w.to_upper()
		if not word_dict.has(key):
			past_words.append(key)
			word_dict[key] = true
	
	past_words.sort()
	
	# Ghi đè lại chính file cũ
	var file := FileAccess.open(path, FileAccess.WRITE)
	for w in past_words:
		file.store_line(w.to_upper())
	file.close()
