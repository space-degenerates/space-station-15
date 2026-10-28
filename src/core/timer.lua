local etable = require("core.table")

local TimerSystem = {}
TimerSystem.timers = {}
TimerSystem.NamedTimers = {}

---@class engine.timer
---@field time number
---@field callback function
---@field params table
---@field name string
local Timer = {}
Timer.__index = Timer

---Makes a new timer that gets called after a certain amount of time
---@param time number
---@param callback function
---@param params table?
---@return engine.timer
function TimerSystem.new(time, callback, params, name)
    local self = setmetatable({}, Timer)

    self.time = time
    self.callback = callback
    self.params = params or {}
    self.name = name
    table.insert(TimerSystem.timers, self)
    if TimerSystem.NamedTimers[name] then
        TimerSystem.timers[etable.find(TimerSystem.timers, TimerSystem.NamedTimers[name])] = nil
    end
    if name then
        TimerSystem.NamedTimers[name] = self
    end
    return self
end

function Timer:update(delta)
    self.time = self.time - delta

    if self.time <= 0 then
        self.callback(self.params)
        return true
    end
end

function TimerSystem.update(delta)
    local ListForRemoval = {}
    for i, timer in next, TimerSystem.timers do
        local removal = timer:update(delta)
        if removal then
            table.insert(ListForRemoval, {i, timer.name})
        end
    end
    for i, indx in next, ListForRemoval do
        table.remove(TimerSystem.timers, indx[1])
        if indx[2] then
            TimerSystem.NamedTimers[indx[2]] = nil
        end
	end
end

return TimerSystem
