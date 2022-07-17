local HttpService = game:GetService("HttpService")
local binder = {}
local Promise: Promise.Static = loadstring(
	HttpService:GetAsync("https://raw.githubusercontent.com/evaera/roblox-lua-promise/master/lib/init.lua", true)
)()
binder.__index = binder
type binderInstance = typeof(binder) & {
	remoteFunction: RemoteFunction,
	player: Player,
	useNLS: boolean,
}
function binder.new(player: Player, useNLS: boolean | false): binderInstance
	local self = setmetatable({
		remoteFunction = useNLS and Instance.new("RemoteFunction", player.PlayerGui), -- We might want the mouse position
		player = player,
		useNLS = useNLS or false,
	}, binder)
	if useNLS then
		-- this might yield forever
		local guid = HttpService:GenerateGUID()
		self.guid = guid
		task.spawn(function()
			NLS(
				string.format(
					"local g = '%s';local rf = script.Parent; local uis = game:GetService('UserInputService'); rf.OnServerInvoke = function(s,v1) if s == g then if v1 == 'mouse' then return owner:GetMouse().Hit.Position end end end",
					"guid"
				),
				self.remoteFunction
			)
		end)
	end
	return self
end

function binder:getMousePosition(): Promise
	assert(self.useNLS, "Mouse position is localized.")
	return Promise.new(function(resolve)
		resolve(self.remoteFunction:InvokeClient(self.guid, "mouse"))
	end):timeout(5, "Client took too long to respond")
end

function binder:__tostring()
	return "binder (0.01-dev) - for " .. self.player.Name
end

function binder:listen(keycodes: Array<Enum.KeyCode>)
	-- TODO: figure out if we should override the current keycodes
	-- or insert into the current keycodes
end

local test = binder.new(owner, true)
print(test:getMousePosition():await())
