local c = {}

local _IMLIB_LOAD_IMAGE    				= imlib_load_image
local _IMLIB_CONTEXT_SET_IMAGE 			= imlib_context_set_image
local _IMLIB_RENDER_IMAGE_ON_DRAWABLE  	= imlib_render_image_on_drawable
local _IMLIB_FREE_IMAGE    				= imlib_free_image
local _IMLIB_IMAGE_GET_WIDTH			= imlib_image_get_width
local _IMLIB_IMAGE_GET_HEIGHT			= imlib_image_get_height

local set = function(obj, path)
	local img = _IMLIB_LOAD_IMAGE(path)
	_IMLIB_CONTEXT_SET_IMAGE(img)

	obj.width = _IMLIB_IMAGE_GET_WIDTH()
	obj.height = _IMLIB_IMAGE_GET_HEIGHT()
	obj.path = path

	_IMLIB_FREE_IMAGE()
end

local draw = function(obj)
	local img = _IMLIB_LOAD_IMAGE(obj.path)
	_IMLIB_CONTEXT_SET_IMAGE(img)
	_IMLIB_RENDER_IMAGE_ON_DRAWABLE(obj.x, obj.y)
	_IMLIB_FREE_IMAGE()
end

c.set = set
c.draw = draw

return c
