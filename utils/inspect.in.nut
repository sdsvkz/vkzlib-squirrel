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
