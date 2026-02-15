local function assertEqual(actual, expect, getHint = null) {
	if (actual != expect) {
		local hint = getHint != null ? getHint() : ""
		print("Expect " + expect + ", actual " + actual + "\n" + hint + "\n")
		throw "Assertion failed"
	}
}

return export({
	assertEqual = assertEqual,
})
