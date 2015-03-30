-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'SetWaypoint'

-- Set waypoint using format: /sw # #, where # = # or #k
-- Clear waypoint using format: /cw

function SetWaypoint:__init()

	self.msg_color = Color(192, 192, 192) -- Local chat messages

	Events:Subscribe("LocalPlayerChat", self, self.Control)
	
end

function SetWaypoint:Control(args) -- Subscribed to LocalPlayerChat

	local cmd_string = tostring(args.text:split(" ")[1])
	local x_string = tostring(args.text:split(" ")[2])
	local y_string = tostring(args.text:split(" ")[3])
	
	local n
	local m
	
	if x_string and y_string then -- If an entry exists for both coordinates
	
		if tonumber(x_string) then -- If the x entry is only a number
			n = tonumber(x_string) -- then set waypoint at that number
		elseif not tonumber(x_string) then -- If the entry is not only a number
			if string.find(x_string, "k") then -- and if "k" is found
				if string.sub(x_string, string.find(x_string, "k") + 1) == "" then -- and nothing else
					n = tonumber(x_string:split("k")[1]) * 1000 -- then set waypoint at that number * 1000
				end
			end
		end
		
		if tonumber(y_string) then -- Ditto for y coord
			m = tonumber(y_string)
		elseif not tonumber(y_string) then
			if string.find(y_string, "k") then
				if string.sub(y_string, string.find(x_string, "k") + 1) == "" then
					m = tonumber(y_string:split("k")[1]) * 1000
				end
			end
		end	
		
	end
	
	if cmd_string == "/sw" and n and m then
		Waypoint:SetPosition(Vector3(n - 16384, 0, m - 16384))
		Chat:Print("Waypoint set at x = "..tostring(n).." m, y = "..tostring(m).." m", self.msg_color)
	end
	
	if args.text == "/cw" then
		Waypoint:SetPosition(LocalPlayer:GetPosition())
		Waypoint:Remove()
		Chat:Print("Waypoint removed.", self.msg_color)
	end
	
end

SetWaypoint = SetWaypoint()
