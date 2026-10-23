local etable = require("core.table")

local TimerSystem = {}
TimerSystem.timers = {}

---@class engine.timer
---@field time number
---@field callback function
---@field params table
local Timer = {}
Timer.__index = Timer

---Makes a new timer that gets called after a certain amount of time
---@param time number
---@param callback function
---@param params table?
---@return engine.timer
function TimerSystem.new(time, callback, params)
    local self = setmetatable({}, Timer)

    self.time = time
    self.callback = callback
    self.params = params or {}
    table.insert(TimerSystem.timers, self)
    print("new timer")
    return self
end

function Timer:update(delta)
    self.time = self.time - delta

    if self.time <= 0 then
        print("timer hit")
        self.callback(self.params)
        return true
    end
end

function TimerSystem.update(delta)
    local ListForRemoval = {}
    for i, timer in next, TimerSystem.timers do
        local removal = timer:update(delta)
        if removal then
            table.insert(ListForRemoval, i)
        end
    end
    for i, index in next, ListForRemoval do
        table.remove(TimerSystem.timers, index)
	end
end

return TimerSystem
