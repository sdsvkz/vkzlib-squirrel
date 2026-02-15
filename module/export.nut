// `minimal.setup.nut` should define `vkz`. This script should be loaded afterward
if (!("vkz" in getroottable())) {
	throw "vkzlib.module.require: `vkz` is not defined"
}

// Guard
if ("export" in getroottable()) {
	return
}

local function ensureIsTable(x) {
	if (typeof x != "table") {
		throw "vkzlib.module.export: only table can be exported"
	}
	return x
}

local _export = null

if ("DoIncludeScript" in getroottable()) {
	_export = function (item) {
		_VKZ_EXPORTED_MODULE <- ensureIsTable(item)
		return _VKZ_EXPORTED_MODULE
	}
} else if ("loadfile" in getroottable()) {
	_export = function (item) {
		ensureIsTable(item)
		return item
	}
} else {
	throw "vkzlib.module.export: Unsupported environment"
}

::export <- _export

return ::export
