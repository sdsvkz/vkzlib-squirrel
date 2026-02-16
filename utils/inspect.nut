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
		 * @desc Path to library storage
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

/**
 * @param {integer} indentSize
 * @return {string} indentStr
 */
local function _getIndent(indentSize) {
	local indent = ""
	for (local i = 0; i < indentSize; i++) {
		indent += " "
	}
	return indent
}

/**
 * @param {string} s The string to inspect
 * @return {string} pretty The string with double-quotes added around it
 */
local function _inspectString(s) {
	return "\"" + s + "\""
}

/**
 * @param {array} xs The array to inspect
 * @param {integer} indentLevel Level of current indentation
 * @param {integer} indentSize Size of indentation
 * @param {(x: any, indentSize: integer, indentLevel: integer) => string} inspectItem Function to inspect items of array
 * @return {string} pretty Human-readable string representation of the array
 */
local function _inspectArray(xs, indentSize, indentLevel, inspectItem) {
	local currentIndent = _getIndent(indentLevel * indentSize)
	local newIndent = _getIndent(indentSize)
	local indent = currentIndent + newIndent

	local res = "["
	local isNotEmpty = false
	foreach (v in xs) {
		isNotEmpty = true
		res += "\n" + indent + inspectItem(v, indentSize, indentLevel + 1) + ","
	}
	if (isNotEmpty) {
		res += "\n" + currentIndent
	}
	return res + "]"
}

/**
 * @param {table} t The table to inspect
 * @param {integer} indentLevel Level of current indentation
 * @param {integer} indentSize Size of indentation
 * @param {(x: any, indentSize: integer, indentLevel: integer) => string} inspectKV Function to inspect keys and values in table
 * @return {string} pretty Human-readable string representation of the table
 */
local function _inspectTable(t, indentSize, indentLevel, inspectKV) {
	local currentIndent = _getIndent(indentLevel * indentSize)
	local newIndent = _getIndent(indentSize)
	local indent = currentIndent + newIndent

	local res = "{"
	local isNotEmpty = false
	foreach(k, v in t) {
		isNotEmpty = true
		res += "\n" + indent + inspectKV(k, indentSize, indentLevel + 1) + ": " + inspectKV(v, indentSize, indentLevel + 1) + ","
	}
	if (isNotEmpty) {
		res += "\n" + currentIndent
	}
	return res + "}"
}

local M = {}

/**
 * @param {any} x The object to inspect
 * @param {integer} indentSize Size of indentation
 * @param {integer} indentLevel Level of current indentation
 * @return {string} pretty Human-readable string representation of the object
 */
M.inspect <- function (x, indentSize = 2, indentLevel = 0) {
	if (typeof x == "string") {
		return _inspectString(x)
	} else if (typeof x == "array") {
		return _inspectArray(x, indentSize, indentLevel, M.inspect)
	} else if (typeof x == "table") {
		return _inspectTable(x, indentSize, indentLevel, M.inspect)
	} else {
		return x.tostring()
	}
}

return export(M)
