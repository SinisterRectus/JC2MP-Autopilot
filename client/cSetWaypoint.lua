-- Written by Sinister Rectus

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
	
	if x_string and y_string then
	
		if tonumber(x_string) then
			n = tonumber(x_string)
		elseif not tonumber(x_string) and string.find(x_string, "k") and string.sub(x_string, string.find(x_string, "k") + 1) == "" then
			n = tonumber(x_string:split("k")[1]) * 1000
		end
		
		if tonumber(y_string) then 
			m = tonumber(y_string)
		elseif not tonumber(y_string) and string.find(y_string, "k") and string.sub(y_string, string.find(x_string, "k") + 1) == "" then
			m = tonumber(y_string:split("k")[1]) * 1000
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
