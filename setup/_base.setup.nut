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
