########################### BEGIN minimal.setup.nut ############################
############################ BEGIN _base.setup.nut #############################
// Guard
if (!("vkz" in getroottable)) {

	::vkz <- {
		_internal = {},
		compat = {},
		module = {},
		test = {},
		utils = {},
	}

	local runScript = null

	if ("IncludeScript" in getroottable()) {
		runScript = ::IncludeScript
	} else if ("loadfile" in getroottable()) {
		runScript = @(path) ::loadfile(path, true)()
	} else {
		throw "vkzlib.module: Unsupported environment"
	}

	/**
	 * @desc Configuration
	 *
	 * You can modify this variable in `vkzlib.config.nut`
	 * e.g. ::VKZLIB_CONFIG.DEBUG = true
	 */
	::VKZLIB_CONFIG <- {

		/**
		 * @desc Path to external libraries storage
		 * @type {string}
		 */
		LIB_DIR = "lib/",

		/**
		 * @desc Path to vkzlib
		 *
		 * Defaults to `LIB_DIR + "vkzlib/"`
		 */
		VKZLIB_DIR = null,

		/**
		 * @desc Main project directory
		 * @type {string}
		 *
		 * Used for setting default `require` path
		 */
		PROJECT_DIR = "",

		/**
		 * @desc Debug flag
		 * @type {bool}
		 *
		 * Enable this should print additional messages for debugging
		 */
		DEBUG = false,

		/**
		 * @desc A function runs after setup script executed
		 * @type {() => void}
		 */
		ON_LOADED = null,

	}

	// Get config from working directory
	try {
		runScript("vkzlib.config.nut")
	} catch (e) {
		::print("WARNING: error on loading vkzlib.config.nut from working directory:\n" + e + "\n")
	}

	local vkzlib = @(path) ::VKZLIB_CONFIG.LIB_DIR + "vkzlib/" + path

	runScript(vkzlib("module/export.nut"))

	runScript(vkzlib("module/require.nut"))

	::vkz._internal.vkzlib <- vkzlib
	::vkz.compat.runScript <- runScript
	::vkz.module.export <- ::export
	::vkz.module.require <- ::require

}

############################# END _base.setup.nut ##############################

if (::VKZLIB_CONFIG.ON_LOADED != null) {
	::VKZLIB_CONFIG.ON_LOADED()
}
############################ END minimal.setup.nut #############################

const SECTION_SEPERATOR_LENGTH = 128

local function duplicateString(str, times) {
	local res = ""
	for (local i = 0; i < times; ++i) {
		res += str
	}
	return res
}

/**
 * @param {string} symbol Single character
 * @param {integer} length
 * @param {string} embeddedMsg
 */
local function getSectionSeperator(symbol, length, embeddedMsg = "") {
	if (symbol.len() != 1) {
		throw "Symbol must be a single character"
	}

	if (embeddedMsg == "") {
		return duplicateString(symbol, length)
	}

	local msg = " " + embeddedMsg + " "
	local totalSymbolLength = length - msg.len()
	local frontSymbolLength = totalSymbolLength / 2
	local backSymbolLength = frontSymbolLength + totalSymbolLength % 2

	return duplicateString(symbol, frontSymbolLength) + msg + duplicateString(symbol, backSymbolLength)
}

local SECTION_SEPERATOR_SINGLE = getSectionSeperator("-", SECTION_SEPERATOR_LENGTH)
local SECTION_SEPERATOR_DOUBLE = getSectionSeperator("=", SECTION_SEPERATOR_LENGTH)

/**
 * @typedef {() => void} TestCase
 */

/**
 * @param {string} testSuiteName Name of the test suite
 * @param {() => TestCase[]} block Body of the test suite, returns a list of `TestCase`
 */
local function describe(testSuiteName, block) {
	print(getSectionSeperator("=", SECTION_SEPERATOR_LENGTH, testSuiteName) + "\n\n")
	local testResults = block().map(function (testCase) {
		try {
			testCase()
			return 1
		} catch (_) {
			return 0
		}
	})
	local totalSuccess = testResults.reduce(@(acc, x) acc += x)
	local totalFailed = testResults.len() - totalSuccess
	local resultMsg = totalSuccess + " passed | " + totalFailed + " failed"
	print(getSectionSeperator("=", SECTION_SEPERATOR_LENGTH, resultMsg) + "\n\n")
	if (totalFailed != 0) {
		throw "Test failed"
	}
}

/**
 * @param {string} testCaseName Name of the test case
 * @param {() => void} block Body of the test case
 * @return {TestCase} testCase
 */
local function it(testCaseName, block) {
	return function () {
		print(getSectionSeperator("-", SECTION_SEPERATOR_LENGTH, testCaseName) + "\n\n")
		print("stdout:" + "\n")
		local success = false
		try {
			block()
			success = true
		} catch (e) {}
		local resultMsg = success ? "✓ Test passed" : "✕ Test failed"
		print("\n\n" + resultMsg + "\n\n")
		print(SECTION_SEPERATOR_SINGLE + "\n\n")
		if (!success) {
			throw "Test failed"
		}
	}
}

return export({
	describe = describe,
	it = it,
})
