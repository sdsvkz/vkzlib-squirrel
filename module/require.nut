// `minimal.setup.nut` should define `vkz`. This script should be loaded afterward
if (!("vkz" in getroottable())) {
	throw "vkzlib.module.require: `vkz` is not defined"
}

// Guard
if ("require" in getroottable()) {
	return
}

::require <- {
	// This requires the user to use a consistent module path convention
	// To prevent one file to have multiple paths for requiring
	loaded = {},
	// Versions of `require` that doesn't throw an error
	nothrow = {},
}

local _include = null

local function ensureIsTable(x) {
	if (typeof x != "table") {
		throw "vkzlib.module.require: exported module is not a table, but " + typeof a + "."
	}
	return x
}

if ("DoIncludeScript" in getroottable()) {
	_include = function (path) {
		local scope = {}
		::DoIncludeScript(path, scope)
		return ensureIsTable(scope._VKZ_EXPORTED_MODULE)
	}
} else if ("loadfile" in getroottable()) {
	_include = @(path) ::loadfile(path, true)()
} else {
	throw "vkzlib.module.require: Unsupported environment"
}

/**
 * @typedef {table} RequireResult
 * @property {bool} ok success or not
 * @property {any} res the module if success, otherwise an error
 */

/**
 * @desc Load the file, record path and then return (weakref to the) module
 *
 * @param {string} path Path to the file
 * @return {RequireResult} result
 */
local function _require(path) {
	// Already loaded? If so, skip loading and return the loaded module
	if (path in ::require.loaded) {
		return {
			res = ::require.loaded[path],
			ok = true,
		}
	}

	try {
		local module = _include(path)
		::require.loaded[path] <- module
		return {
			res = ::require.loaded[path].weakref(),
			ok = true,
		}
	} catch (e) {
		return {
			res = e,
			ok = false,
		}
	}
}

local function _getThrowVersion(requireFunc, name) {
	return function (path) {
		local result = requireFunc(path)
		if (result.ok) {
			return result.res
		} else {
			print("Error on calling " + name + " with: " + path)
			print("\n  " + result.res + "\n")
			throw "Require failed: Error occurred above"
		}
	}
}

/**
 * @param {string} path Path to the file
 * @return {RequireResult} result
 */
::require.nothrow.runtime <- @(path) _require(path)

/**
 * @param {string} path Path to the file
 * @return {any} The module
 *
 * @throws {string} err Error message
 */
::require.runtime <- _getThrowVersion(::require.nothrow.runtime, "require.runtime")

/**
 * @param {string} path Path to the file
 * @return {RequireResult} result
 */
::require.nothrow.call <- @(path) _require(::VKZLIB_CONFIG.PROJECT_DIR + path)

/**
 * @param {string} path Path to the file
 * @return {any} The module
 *
 * @throws {string} err Error message
 */
::require.call <- _getThrowVersion(::require.nothrow.call, "require.call")

::require.setdelegate({
	_call = @(_, path) ::require.call(path),
})

/**
 * @param {string} path Path to the file
 * @return {RequireResult} result
 */
::require.nothrow.lib <- @(path) _require(::VKZLIB_CONFIG.LIB_DIR + path)

/**
 * @param {string} path Path to the file
 * @return {any} The module
 *
 * @throws {string} err Error message
 */
::require.lib <- _getThrowVersion(::require.nothrow.lib, "require.lib")

/**
 * @param {string} path Path to the file
 * @return {RequireResult} result
 */
::require.nothrow.vkzlib <- function (path) {
	return _require(::vkz._internal.vkzlib(path))
}

/**
 * @param {string} path Path to the file
 * @return {any} The module
 *
 * @throws {string} err Error message
 */
::require.vkzlib <- _getThrowVersion(::require.nothrow.vkzlib, "require.vkzlib")

return ::require
