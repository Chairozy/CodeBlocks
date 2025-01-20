class_name UuidV4

static func generate_uuid_v4() -> String:
	var hex_chars = "0123456789abcdef"
	var uuid = []
	
	for i in range(36):
		if i in [8, 13, 18, 23]:
			uuid.append("-")
		elif i == 14:
			uuid.append("4")  # Versi 4
		elif i == 19:
			uuid.append(hex_chars[randi_range(8, 11)])  # 8, 9, A, atau B
		else:
			uuid.append(hex_chars[randi_range(0, 15)])
	return "".join(uuid)
