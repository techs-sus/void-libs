local binder = {}
binder.__index = binder
type binderInstance = typeof(binder) & {
	player: Player,
}

function binder.new(player: Player): binderInstance
	return setmetatable({
		player = player,
	}, binder)
end

function binder:listen(keycodes: Array<Enum.KeyCode>)
	-- TODO: figure out if we should override the current keycodes
	-- or insert into the current keycodes
end

local function test()
	local b = binder.new()
	b:listen({ Enum.KeyCode.E })
end
