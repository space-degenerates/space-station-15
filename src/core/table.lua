local engine = require("core.init")

local etable = {}

---Find an object in the table.
---@param list table
---@param object any
---@return number?
function etable.find(list, object)
	for index, o in next, list do
		if o == object then
			return index
		end
	end
end

---Find first object of class in the table.
---@param list table
---@param class any
---@return number?
function etable.findofClass(list, class)
	for index, o in next, list do
		if o.__index == class then
			return index
		end
	end
end

---Completely wipes the table.
---@param list table
function etable.deepClear(list)
	for index, object in next, list do
		if type(object) == "table" then
			engine.table.deepClear(object)
		else
			list[index] = nil
		end
	end
end

return etable
