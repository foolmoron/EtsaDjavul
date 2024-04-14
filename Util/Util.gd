class_name Util

static func sorted_by(array: Array, key_func: Callable):
	var pairs: Array = []
	for item in array:
		pairs.append([item, key_func.call(item)])
	pairs.sort_custom(func(a, b): return a[1] > b[1])
	var final := []
	for p in pairs:
		final.append(p[0])
	return final

static func best_by(array: Array, key_func: Callable):
	# var pairs: Array = []
	# for item in array:
	# 	pairs.append([item, key_func.call(item,)])
	# pairs.sort_custom(func(a, b): return a[1] > b[1])
	var best = -1e12
	var best_item = null
	for item in array:
		var val := float(key_func.call(item, best))
		if val > best:
			best = val
			best_item = item
	return [best_item, best]
	