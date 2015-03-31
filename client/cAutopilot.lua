-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'Autopilot'

function Autopilot:__init()

	self.plane = {}
	self.plane[24] = {true, 296, 406, "tbd", "tbd", 5000} -- F-33 DragonFly
	self.plane[30] = {true, 277, 340, "tbd", "tbd", 5000} -- Si-47 Leopard
	self.plane[34] = {true, 341, 401, "tbd", "tbd", 20000} -- G9 Eclipse
	self.plane[39] = {true, 324, 352, "tbd", "tbd", 100000} -- Aeroliner 474
	self.plane[51] = {true, 250, 314, "tbd", "tbd", 12500} -- Cassius 192
	self.plane[59] = {false, 207, 242, "tbd", "tbd", 1500} -- Peek Airhawk 225
	self.plane[81] = {true, 262, 343, "tbd", "tbd", 1500} -- Pell Silverbolt 6 (not upgraded)
	self.plane[85] = {true, 313, 339, "tbd", "tbd", 100000} -- Bering I-86DP
	
	-- Values from left to right are:
		-- Autopilot availability
		-- Approximate air speeds in km/h at:
			-- Level flight and neutral thrust
			-- Level flight and full thrust
			-- 45 deg up flight and neutral thrust
			-- 45 deg up flight and full thrust
			-- 45 deg down flight and neutral thrust
			-- 45 deg down flight and full thrust
		-- Default mass 
		
	-- By default, autopilot is made not available in the Peek Airhawk 225
	
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
	self.altitude_mod = 0.3 -- Default 0.3
	self.throttle_mod = 0.05 -- Default 0.05
	
	self.max_power = 0.8 -- Global maximum input power, default 1.0
	
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

function Autopilot:On()
	self.settings[1][2] = true
end

function Autopilot:Off()
	for i,k in ipairs(self.settings) do
		self.settings[i][2] = false
	end
end

function Autopilot:GetRoll(v)
	return math.deg(v:GetAngle().roll)
end

function Autopilot:GetPitch(v)
	return math.deg(v:GetAngle().pitch)
end

function Autopilot:GetYaw(v)
	return math.deg(v:GetAngle().yaw)
end

function Autopilot:GetAltitude(v)
	return v:GetPosition().y - 200	
end

function Autopilot:GetAirSpeed(v)
	return v:GetLinearVelocity():Length() * 3.6
end

function Autopilot:Control(args) -- Subscribed to LocalPlayerChat

	local text1 = args.text:split(" ")[1]
	local text2 = args.text:split(" ")[2]
	local text3 = args.text:split(" ")[3]
	local n = tonumber(text2)
	
	if text3 then return false end

	if text1 == "/ap" then
		if not Autopilot:PanelAvailable() then
			Chat:Print("Autopilot is not available.", self.msg_color)
			return false
		end
		
		if self.settings[1][2] == false then
			Autopilot:On()
			Chat:Print("Autopilot enabled.", self.msg_color)
		elseif self.settings[1][2] == true then
			Autopilot:Off()
			Chat:Print("Autopilot disabled.", self.msg_color)
		end
		
	return false
	end
	
	if text1 == "/rh" and not text2 then
		if not Autopilot:PanelAvailable() then
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
	elseif text1 == "/rh" and n then
		if n >= -90 and n <= 90 then
			self.settings[2][3] = n
			Chat:Print("Roll-hold set to "..self.settings[2][3]..self.settings[2][4], self.msg_color)
		elseif n < -90 or n > 90 then
			Chat:Print("Please enter a valid number from -90 to 90", self.msg_color)
		end
	return false
	end
	
	if text1 == "/ph" and not text2 then
		if not Autopilot:PanelAvailable() then
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
	elseif text1 == "/ph" and n then
		if n >= -90 and n <= 90 then
			self.settings[3][3] = n
			Chat:Print("Pitch-hold set to "..self.settings[3][3]..self.settings[3][4], self.msg_color)
		elseif n < -90 or n > 90 then
			Chat:Print("Please enter a valid number from -90 to 90", self.msg_color)
		end
	return false
	end
	
	if text1 == "/hh" and not text2 then
		if not Autopilot:PanelAvailable() then
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
	elseif text1 == "/hh" and n then
		if n >= 0 and n <= 360 then
			self.settings[4][3] = n
			Chat:Print("Heading-hold set to "..self.settings[4][3]..self.settings[4][4], self.msg_color)
		elseif n < 0 or n > 360 then
			Chat:Print("Please enter a valid number from 0 to 360", self.msg_color)
		end
	return false
	end
	
	if text1 == "/ah" and not text2 then
		if not Autopilot:PanelAvailable() then
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
	elseif text1 == "/ah" and n then
		if n >= 0 and n <= 5000 then
			self.settings[5][3] = n
			Chat:Print("Altitude-hold set to "..self.settings[5][3]..self.settings[5][4], self.msg_color)
		elseif n < 0 or n > 5000 then
			Chat:Print("Please enter a valid number from 0 to 5000", self.msg_color)
			end
	return false
	end
	
	if text1 == "/th" and not text2 then
		if not Autopilot:PanelAvailable() then
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
	elseif text1 == "/th" and n then
		if n >= 0 and n <= 700 then
			self.settings[6][3] = n
			Chat:Print("Throttle-hold set to "..self.settings[6][3]..self.settings[6][4], self.msg_color)
		elseif n < 0 or n > 700 then
			Chat:Print("Please enter a valid number from 0 to 700", self.msg_color)
		end
		return false
	end
	
	if text1 == "/wh" and not text2 then
		if not Autopilot:PanelAvailable() then
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

function Autopilot:DrawHUDLine(pos, str, on)

	local color = self.hud_off_color
	if on == true then color = self.hud_on_color end
	Render:DrawText(pos, str, color, self.hud_size)
	
end

function Autopilot:HUD() -- Subscribed to Render

	if Autopilot:PanelAvailable() then
		local position = Vector2(self.screen_width * 0.7, self.screen_height * 0.086)
		for i,k in ipairs(self.settings) do
			if #k == 2 then
				Autopilot:DrawHUDLine(position, k[1], k[2])
			elseif #k > 2 then 
				Autopilot:DrawHUDLine(position, k[1].." = "..tostring(math.floor(k[3] + 0.5))..tostring(k[4]), k[2])
			end
			position.y = position.y + Render:GetTextHeight(k[1], self.hud_size)
		end
	end
	
end

function Autopilot:PanelAvailable() -- Subscribed to PreTick

	if LocalPlayer:InVehicle() then
		local v = LocalPlayer:GetVehicle()
		if LocalPlayer == v:GetDriver() and self.plane[v:GetModelId()] then
			return true
		end
	end
	Autopilot:Off()
	return false
	
end

function Autopilot:RollHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[2][2] then return false end
	
	local v = LocalPlayer:GetVehicle()
	
	local roll = Autopilot:GetRoll(v)
	
	local power = math.abs(roll - self.settings[2][3]) * self.roll_mod
	if power > self.max_power then power = self.max_power end
	
	if self.settings[2][3] <  roll then
		Input:SetValue(Action.PlaneTurnRight, power)
	end
	
	if self.settings[2][3] > roll then
		Input:SetValue(Action.PlaneTurnLeft, power)
	end
	
end

function Autopilot:PitchHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[3][2] then return false end
	
	local v = LocalPlayer:GetVehicle()
	
	local pitch = Autopilot:GetPitch(v)
	local roll = Autopilot:GetRoll(v)
	
	local power = math.abs(pitch - self.settings[3][3]) * self.pitch_mod
	if power > self.max_power then power = self.max_power end
	
	if math.abs(roll) < 90 then
		if self.settings[3][3] > pitch then
			Input:SetValue(Action.PlanePitchUp, power)
		end
		
		if self.settings[3][3] < pitch then
			Input:SetValue(Action.PlanePitchDown, power)
		end
	end
	
	if math.abs(roll) >= 90 then
		if self.settings[3][3] > pitch then
			Input:SetValue(Action.PlanePitchDown, power)
		end
		
		if self.settings[3][3] < pitch then
			Input:SetValue(Action.PlanePitchUp, power)
		end
	end
	
end

function Autopilot:HeadingHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[4][2] then return false end
	
	local v = LocalPlayer:GetVehicle()
	
	local heading = -Autopilot:GetYaw(v)
	
	if heading <= 0 then
		heading = heading + 360
	end
	
	diff = self.settings[4][3] - heading
	
	if diff >= 0 and diff < 180 then self.settings[2][3] = -diff * self.heading_mod end
	if diff > 180 then self.settings[2][3] = diff * self.heading_mod  end
	if diff < -180 then self.settings[2][3] = diff * self.heading_mod  end
	if diff <= 0 and diff > -180 then self.settings[2][3] = -diff * self.heading_mod end
	
	if self.settings[2][3] > self.roll_limit then
		self.settings[2][3] = self.roll_limit
	elseif self.settings[2][3] < -self.roll_limit then
		self.settings[2][3] = -self.roll_limit
	end
	
end

function Autopilot:AltitudeHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[5][2] then return false end
	
	local v = LocalPlayer:GetVehicle()

	self.settings[3][3] = (self.settings[5][3] - Autopilot:GetAltitude(v)) * self.altitude_mod
	
	if self.settings[3][3] > self.pitch_limit then
		self.settings[3][3] = self.pitch_limit
	elseif self.settings[3][3] < -self.pitch_limit then
		self.settings[3][3] = -self.pitch_limit
	end
	
end

function Autopilot:ThrottleHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[6][2] then return false end
	
	local v = LocalPlayer:GetVehicle()
	
	local air_speed = Autopilot:GetAirSpeed(v)
	
	local power = math.abs(air_speed - self.settings[6][3]) * self.throttle_mod
	if power > self.max_power then power = self.max_power end
	
	if air_speed < self.settings[6][3] then
		Input:SetValue(Action.PlaneIncTrust, power)
	end
	if air_speed > self.settings[6][3] then
		Input:SetValue(Action.PlaneDecTrust, power)
	end
	
end

function Autopilot:WaypointHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not LocalPlayer:InVehicle() or not self.settings[7][2] then return false end
	
	local v = LocalPlayer:GetVehicle()
	local position = v:GetPosition()
	local waypoint = Waypoint:GetPosition()
	local heading
	local diffx = position.x - waypoint.x
	local diffy = position.z - waypoint.z
	
	local angle = math.atan(diffx / diffy)
	
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

function Autopilot:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.screen_width = args.size.x
	self.screen_height = args.size.y
	self.hud_size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	
end

Autopilot = Autopilot()
