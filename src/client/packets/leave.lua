local render = require("client.render")

return function(name)
	local entity = Client.players[name]
	if entity then
		for i = #render.objects, 1, -1 do
			if render.objects[i] == entity or render.objects[i] == entity.tag then
				table.remove(render.objects, i)
			end
		end
	end
	Client.players[name] = nil
end
