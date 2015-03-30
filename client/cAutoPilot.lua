-- Written by Sinister Rectus - http://steamcommunity.com/id/SinisterRectus

class 'AutoPilot'

function AutoPilot:__init()

	self.plane = {}
	self.plane[24] = true -- F-33 DragonFly
	self.plane[30] = true -- Si-47 Leopard
	self.plane[34] = true -- G9 Eclipse
	self.plane[39] = true -- Aeroliner 474
	self.plane[51] = true -- Cassius 192
	self.plane[59] = false -- Peek Airhawk 225
	self.plane[81] = true -- Pell Silverbolt 6
	self.plane[85] = true -- Bering I-86DP
	
	-- Booleans determine autopilot availability
	-- By default, autopilot is made not available in the Peek Airhawk 225.
	
	self.hud_on_color = Color(255, 128, 0)
	self.hud_off_color = Color(255, 255, 255)
	self.msg_color = Color(192, 192, 192) -- Local chat messages

	self.screen_height = Render.Height
	self.screen_width = Render.Width
	self.scale = 0.012 -- Master HUD scale setting
	self.hud_size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale -- HUD size based on screen diagonal size
	
	self.settings = {}
	self.settings[1] = {"Autopilot", false}
	self.settings[2] = {"Roll-Hold", false, 0, "°"}
	self.settings[3] = {"Pitch-Hold", false, 0, "°"}
	self.settings[4] = {"Heading-Hold", false, 0, "°"}
	self.settings[5] = {"Altitude-Hold", false, 0, " m"}
	self.settings[6] = {"Throttle-Hold", false, 0, " km/h"}
	self.settings[7] = {"Waypoint-Hold", false}
	
	-- Booleans determine on/off status, not availability
	-- Making individual functions unavailable is not featured
	
	self.roll_mod = 0.125 -- Default 0.125
	self.pitch_mod = 0.5 -- Default 0.5
	self.heading_mod = 2.0 -- Default 2.0
	self.altitude_mod = 1.0 -- Default 1.0
	self.throttle_mod = 0.05 -- Default 0.05
	
	-- Lower modifier settings provide weaker inputs
	-- Optimizing these for each plane may be worth the effort
	
	self.pitch_limit = 45 -- Maximum absolute angle of attack used by altitude-hold
	self.roll_limit = 60 -- Maximum absolute bank angle used by heading-hold
	
	Events:Subscribe("LocalPlayerChat", self, self.Control)
	Events:Subscribe("Render", self, self.HUD)
	Events:Subscribe("PreTick", self, self.PanelAvailable)
	Events:Subscribe("InputPoll", self, self.RollHold)
	Events:Subscribe("InputPoll", self, self.PitchHold)
	Events:Subscribe("InputPoll", self, self.HeadingHold)
	Events:Subscribe("InputPoll", self, self.AltitudeHold)
	Events:Subscribe("InputPoll", self, self.ThrottleHold)
	Events:Subscribe("InputPoll", self, self.WaypointHold)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
	
end

function AutoPilot:On()

	self.settings[1][2] = true
	
end

function AutoPilot:Off()

	for i,k in ipairs(self.settings) do
		self.settings[i][2] = false
	end
	
end

function AutoPilot:GetRoll()
	
	local v = LocalPlayer:GetVehicle()
	local angle = v:GetAngle()
	return math.deg(angle.roll)

end

function AutoPilot:GetPitch()

	local v = LocalPlayer:GetVehicle()
	local angle = v:GetAngle()
	return math.deg(angle.pitch)

end

function AutoPilot:GetHeading()

	local v = LocalPlayer:GetVehicle()
	local angle = v:GetAngle()
	local heading = -math.deg(angle.yaw)
	
	if heading < 0 then
		heading = heading + 360
	end
	
	return heading
	
end

function AutoPilot:GetAltitude()

	local v = LocalPlayer:GetVehicle()
	return v:GetPosition().y - 200
	
end

function AutoPilot:GetAirSpeed()

	local v = LocalPlayer:GetVehicle()
	return v:GetLinearVelocity():Length() * 3.6

end

function AutoPilot:Control(args) -- Subscribed to LocalPlayerChat

	local text1 = args.text:split(" ")[1]
	local text2 = args.text:split(" ")[2]
	local text3 = args.text:split(" ")[3]
	local n = tonumber(text2)
	local m = tonumber(text3)

	if text1 == "/ap" then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[1][2] == false then
			AutoPilot:On()
			Chat:Print("Autopilot enabled.", self.msg_color)
		elseif self.settings[1][2] == true then
			AutoPilot:Off()
			Chat:Print("Autopilot disabled.", self.msg_color)
		end
		
	return false
	end
	
	if text1 == "/rh" and not text2 then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[2][2] == false then
			Chat:Print("Roll-hold enabled.", self.msg_color)
			self.settings[1][2] = true
			self.settings[2][2] = true
		elseif self.settings[2][2] == true then
			if self.settings[4][2] == true then
				Chat:Print("Heading-hold is using roll-hold!", self.msg_color)
				return false
			end
			Chat:Print("Roll-hold disabled.", self.msg_color)	
			self.settings[2][2] = false
			return false
		end
	end
		
	if text1 == "/rh" and text2 and not n then
		Chat:Print("Please enter a valid number from -90 to 90", self.msg_color)
	elseif text1 == "/rh" and (n >= -90 and n <= 90) then
		self.settings[2][3] = n
		Chat:Print("Roll-hold set to "..self.settings[2][3]..self.settings[2][4], self.msg_color)
	elseif text1 == "/rh" and (n < -90 or n > 90) then
		Chat:Print("Please enter a valid number from -90 to 90", self.msg_color)
		return false
	end
	
	if text1 == "/ph" and not text2 then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[3][2] == false then
			Chat:Print("Pitch-hold enabled.", self.msg_color)
			self.settings[1][2] = true
			self.settings[3][2] = true
		elseif self.settings[3][2] == true then
			if self.settings[5][2] == true then
				Chat:Print("Altitude-hold is using pitch-hold!", self.msg_color)
				return false
			end
			Chat:Print("Pitch-hold disabled.", self.msg_color)	
			self.settings[3][2] = false
			return false
		end
	end
		
	if text1 == "/ph" and text2 and not n then
		Chat:Print("Please enter a valid number from -90 to 90", self.msg_color)
	elseif text1 == "/ph" and (n >= -90 and n <= 90) then
		self.settings[3][3] = n
		Chat:Print("Pitch-hold set to "..self.settings[3][3]..self.settings[3][4], self.msg_color)
	elseif text1 == "/ph" and (n < -90 or n > 90) then
		Chat:Print("Please enter a valid number from -90 to 90", self.msg_color)
		return false
	end
	
	if text1 == "/hh" and not text2 then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[4][2] == false then
			Chat:Print("Heading-hold enabled.", self.msg_color)
			self.settings[1][2] = true
			self.settings[2][2] = true
			self.settings[4][2] = true
		elseif self.settings[4][2] == true then
			if self.settings[7][2] == true then
				Chat:Print("Waypoint-hold is using heading-hold!", self.msg_color)
				return false
			end
			Chat:Print("Heading-hold disabled.", self.msg_color)	
			self.settings[2][2] = false
			self.settings[4][2] = false
			return false
		end
	end
		
	if text1 == "/hh" and text2 and not n then
		Chat:Print("Please enter a valid number from 0 to 360", self.msg_color)
	elseif text1 == "/hh" and (n >= 0 and n <= 360) then
		self.settings[4][3] = n
		Chat:Print("Pitch-hold set to "..self.settings[4][3]..self.settings[4][4], self.msg_color)
	elseif text1 == "/hh" and (n < 0 or n > 360) then
		Chat:Print("Please enter a valid number from 0 to 360", self.msg_color)
		return false
	end
	
	if text1 == "/ah" and not text2 then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[5][2] == false then
			Chat:Print("Altitude-hold enabled.", self.msg_color)
			self.settings[1][2] = true
			self.settings[3][2] = true
			self.settings[5][2] = true
		elseif self.settings[5][2] == true then
			Chat:Print("Altitude-hold disabled.", self.msg_color)	
			self.settings[3][2] = false
			self.settings[5][2] = false
			return false
		end
	end
		
	if text1 == "/ah" and text2 and not n then
		Chat:Print("Please enter a valid number from 0 to 5000", self.msg_color)
	elseif text1 == "/ah" and (n >= 1 and n <= 5000) then
		self.settings[5][3] = n
		Chat:Print("Altitude-hold set to "..self.settings[5][3]..self.settings[5][4], self.msg_color)
	elseif text1 == "/ah" and (n < 1 or n > 500) then
		Chat:Print("Please enter a valid number from 1 to 360", self.msg_color)
		return false
	end
	
	if text1 == "/th" and not text2 then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[6][2] == false then
			Chat:Print("Throttle-hold enabled.", self.msg_color)
			self.settings[1][2] = true
			self.settings[6][2] = true
		elseif self.settings[6][2] == true then
			Chat:Print("Throttle-hold disabled.", self.msg_color)	
			self.settings[6][2] = false
			return false
		end
	end
		
	if text1 == "/th" and text2 and not n then
		Chat:Print("Please enter a valid number from 0 to 700", self.msg_color)
	elseif text1 == "/th" and (n >= 0 and n <= 700) then
		self.settings[6][3] = n
		Chat:Print("Throttle-hold set to "..self.settings[6][3]..self.settings[6][4], self.msg_color)
	elseif text1 == "/th" and (n < 0 or n > 700) then
		Chat:Print("Please enter a valid number from 0 to 700", self.msg_color)
		return false
	end
	
	if text1 == "/wh" and not text2 then
		if not AutoPilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[7][2] == false then
			Chat:Print("Waypoint-hold enabled.", self.msg_color)
			self.settings[1][2] = true
			self.settings[2][2] = true
			self.settings[4][2] = true
			self.settings[7][2] = true
		elseif self.settings[7][2] == true then
			Chat:Print("Waypoint-hold disabled.", self.msg_color)	
			self.settings[2][2] = false
			self.settings[4][2] = false
			self.settings[7][2] = false
			return false
		end
	end
		
end

function AutoPilot:DrawHUDLine(pos, str, on)

	local color = self.hud_off_color
	if on == true then color = self.hud_on_color end
	Render:DrawText(pos, str, color, self.hud_size)
	
end

function AutoPilot:HUD() -- Subscribed to Render

	if AutoPilot:PanelAvailable() then
		local position = Vector2(self.screen_width * 0.7, self.screen_height * 0.086)
		for i,k in ipairs(self.settings) do
			if #k == 2 then
				AutoPilot:DrawHUDLine(position, k[1], k[2])
			elseif #k > 2 then 
				AutoPilot:DrawHUDLine(position, k[1].." = "..tostring(math.floor(k[3] + 0.5))..tostring(k[4]), k[2])
			end
			position.y = position.y + Render:GetTextHeight(k[1], self.hud_size)
		end
	end
	
end

function AutoPilot:PanelAvailable() -- Subscribed to PreTick

	if LocalPlayer:InVehicle() then
		local v = LocalPlayer:GetVehicle()
		if LocalPlayer == v:GetDriver() and self.plane[v:GetModelId()] then
			return true
		end
	end
	AutoPilot:Off()
	return false
	
end

function AutoPilot:RollHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[2][2] then return false end
	
	roll = AutoPilot:GetRoll()
	
	local power = math.abs(roll - self.settings[2][3]) * self.roll_mod
	if power > 1 then power = 1 end
	
	if self.settings[2][3] <  roll then
		Input:SetValue(Action.PlaneTurnRight, power)
	end
	
	if self.settings[2][3] > roll then
		Input:SetValue(Action.PlaneTurnLeft, power)
	end
	
end

function AutoPilot:PitchHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[3][2] then return false end
	
	local pitch = AutoPilot:GetPitch()
	
	local power = math.abs(pitch - self.settings[3][3]) * self.pitch_mod
	if power > 1 then power = 1 end
	
	if self.settings[3][3] > pitch then
		Input:SetValue(Action.PlanePitchUp, power)
	end
	
	if self.settings[3][3] < pitch then
		Input:SetValue(Action.PlanePitchDown, power)
	end
	
end

function AutoPilot:HeadingHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[4][2] then return false end

	diff = self.settings[4][3] - AutoPilot:GetHeading()
	
	if diff > 0 and diff < 180 then self.settings[2][3] = -diff * self.heading_mod end
	if diff > 180 then self.settings[2][3] = diff * self.heading_mod  end
	if diff < -180 then self.settings[2][3] = diff * self.heading_mod  end
	if diff < 0 and diff > -180 then self.settings[2][3] = -diff * self.heading_mod end
	
	if self.settings[2][3] > self.roll_limit then
		self.settings[2][3] = self.roll_limit
	elseif self.settings[2][3] < -self.roll_limit then
		self.settings[2][3] = -self.roll_limit
	end
	
end

function AutoPilot:AltitudeHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[5][2] then return false end

	self.settings[3][3] = (self.settings[5][3] - AutoPilot:GetAltitude()) * self.altitude_mod
	
	if self.settings[3][3] > self.pitch_limit then
		self.settings[3][3] = self.pitch_limit
	elseif self.settings[3][3] < -self.pitch_limit then
		self.settings[3][3] = -self.pitch_limit
	end

end

function AutoPilot:ThrottleHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[6][2] then return false end
	
	local air_speed = AutoPilot:GetAirSpeed()
	
	local power = math.abs(air_speed - self.settings[6][3]) * self.throttle_mod
	if power > 1 then power = 1 end
	
	if air_speed < self.settings[6][3] then
		Input:SetValue(Action.PlaneIncTrust, power)
	end
	if air_speed > self.settings[6][3] then
		Input:SetValue(Action.PlaneDecTrust, power)
	end
	
end

function AutoPilot:WaypointHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[7][2] then return false end
	local v = LocalPlayer:GetVehicle()
	local position = v:GetPosition()
	local waypoint = Waypoint:GetPosition()
	local heading = 0
	diffx = position.x - waypoint.x
	diffy = position.z - waypoint.z
	
	angle = math.atan(diffx / diffy)
	
	if diffx > 0 and diffy > 0 then
		heading  = 360 - math.deg(angle)
	elseif diffx < 0 and diffy > 0 then
		heading = math.abs(math.deg(angle))
	elseif diffx < 0 and diffy < 0 then
		heading = 180 - math.deg(angle)
	elseif diffx > 0 and diffy < 0 then 
		heading = 180 + math.abs(math.deg(angle))
	end
	
	self.settings[4][3] = heading
	
end

function AutoPilot:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.screen_width = args.size.x
	self.screen_height = args.size.y
	self.hud_size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	
end

AutoPilot = AutoPilot()