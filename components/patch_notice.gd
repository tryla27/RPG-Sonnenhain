extends RefCounted
var last_token := ""

func consume(token: String) -> bool:
	token = token.strip_edges().left(80)
	if token.is_empty() or token == last_token: return false
	last_token = token
	return true
