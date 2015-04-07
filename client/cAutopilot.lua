-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'Autopilot'

function Autopilot:__init()

	self.plane = {}
	self.plane[24] = true -- F-33 DragonFly
	self.plane[30] = true -- Si-47 Leopard
	self.plane[34] = true -- G9 Eclipse
	self.plane[39] = true -- Aeroliner 474
	self.plane[51] = true -- Cassius 192
	self.plane[59] = false -- Peek Airhawk 225
	self.plane[81] = true -- Pell Silverbolt 6
	self.plane[85] = true -- Bering I-86DP
	
	-- By default, autopilot is made not available in the Peek Airhawk 225
	
	self.hud_on_color = Color(255, 128, 0)
	self.hud_off_color = Color(255, 255, 255)
	self.msg_color = Color(192, 192, 192) -- Local chat messages

	self.screen_height = Render.Height
	self.screen_width = Render.Width
	self.scale = 0.012 -- Master HUD scale setting
	self.hud_size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale -- HUD size based on screen diagonal size
	
	-- BEGIN CONFIG --
	
	self.config = { 
	
		["ap"] = {
			["name"] = "Autopilot",
			["on"] = false,
			["uses"] = {},
			["used_by"] = {}
		},
		
		["rh"] = {
			["name"] = "Roll-Hold",
			["on"] = false,
			["uses"] = {},
			["used_by"] = {"hh", "wh"},
			["setting"] = 0,
			["units"] = "°",
			["min_setting"] = -60, -- Do not set less than -180
			["max_setting"] = 60, -- Do not set greater than 180
			["gain"] = 0.20, -- 0.20 default
			["max_input"] = 0.7 -- Percentage from 0 to 1
		},
		
		["ph"] = {			
			["name"] = "Pitch-Hold",
			["on"] = false,
			["uses"] = {},
			["used_by"] = {"ah"},
			["setting"] = 0,
			["units"] = "°",
			["min_setting"] = -60, -- Do not set less than -90
			["max_setting"] = 60, -- Do not set greater than 90
			["gain"] = 0.50, -- 0.50 default
			["max_input"] = 0.8 -- Percentage from 0 to 1
		},
		
		["hh"] = {			
			["name"] = "Heading-Hold",
			["on"] = false,
			["uses"] = {"rh"},
			["used_by"] = {"wh"},
			["setting"] = 0,
			["units"] = "°",
			["min_setting"] = 0, -- Do not change
			["max_setting"] = 360, -- Do not change
			["gain"] = 2.00, -- 2.00 default
			["roll_limit"] = 45 -- Maximum roll angle while HH is active, 30 to 60 recommended
		},
		
		["ah"] = {
			["name"] = "Altitude-Hold",
			["on"] = false,
			["uses"] = {"ph"},
			["used_by"] = {},
			["setting"] = 0,
			["units"] = " m",
			["min_setting"] = 0, -- Do not set less than 0
			["max_setting"] = 5000, -- Planes do not maneuver properly above 5000 m
			["gain"] = 0.30, -- 0.30 default
			["pitch_limit"] = 45, -- Maximum pitch angle while AH is active, 30 to 60 recommended
			["bias"] = 5 -- Correction for gravity
		},
		
		["sh"] = {
			["name"] = "Speed-Hold",
			["on"] = false,
			["uses"] = {},
			["used_by"] = {},
			["setting"] = 0,
			["units"] = " km/h",
			["min_setting"] = 0, -- Do not set less than 0
			["max_setting"] = 700, -- Planes rarely exceed 500 km/h without server functions
			["gain"] = 0.05, -- 0.05 default
			["max_input"] = 1.0 -- Percentage from 0 to 1
		},
		
		["wh"] = {
			["name"] = "Waypoint-Hold",
			["on"] = false,
			["uses"] = {"hh", "rh"},
			["used_by"] = {}
		}
	}
			
	-- END CONFIG --

	Events:Subscribe("LocalPlayerChat", self, self.Control)
	Events:Subscribe("Render", self, self.HUD)
	Events:Subscribe("InputPoll", self, self.RollHold)
	Events:Subscribe("InputPoll", self, self.PitchHold)
	Events:Subscribe("InputPoll", self, self.HeadingHold)
	Events:Subscribe("InputPoll", self, self.AltitudeHold)
	Events:Subscribe("InputPoll", self, self.SpeedHold)
	Events:Subscribe("InputPoll", self, self.WaypointHold)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
	
end

function tostringint(n)
	return tostring(math.floor(n + 0.5))
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

function Autopilot:GetVerticalSpeed(v)
	return v:GetLinearVelocity().y * 3.6
end

function Autopilot:GetGroundSpeed(v)
	return Vector2(v:GetLinearVelocity().x, v:GetLinearVelocity().z):Length() * 3.6
end

function Autopilot:Control(args) -- Subscribed to LocalPlayerChat

	local text1 = args.text:split(" ")[1]
	local text2 = args.text:split(" ")[2]
	
	local waypoint, marker = Waypoint:GetPosition()
	local cmd = text1:split("/")[2]
	local n = tonumber(text2)
		
	if self.config[cmd] then
		if Autopilot:PanelAvailable() then
			if #args.text:split(" ") == 1 then
				if self.config[cmd].on == false then
					if cmd == "wh" and not marker then
						Chat:Print("No waypoint set", self.msg_color)
					else
						if self.config.ap.on == false then
							self.config.ap.on = true
						end
						for i,k in ipairs(self.config[cmd].uses) do
							self.config[k].on = true
						end
						self.config[cmd].on = true
						Chat:Print(self.config[cmd].name.." enabled", self.msg_color)
					end
				elseif self.config[cmd].on == true then
					if cmd == "ap" then
						for i,k in pairs(self.config) do
							k["on"] = false
						end
					end
					local in_use = false
					for i,k in ipairs(self.config[cmd].used_by) do
						if self.config[k].on == true then
							Chat:Print(self.config[k].name.." is using "..self.config[cmd].name, self.msg_color)
							used = true
						end
					end
					if in_use == false then
						self.config[cmd].on = false
						for i,k in ipairs(self.config[cmd].uses) do
							self.config[k].on = false
						end
						Chat:Print(self.config[cmd].name.." disabled", self.msg_color)
					end
				end
			elseif n and self.config[cmd].setting and #args.text:split(" ") == 2 then
				if n >= self.config[cmd].min_setting and n <= self.config[cmd].max_setting then
					self.config[cmd].setting = n
					Chat:Print(self.config[cmd].name.." set to "..self.config[cmd].setting, self.msg_color)
				else
					Chat:Print("Please enter a number between "..self.config[cmd].min_setting.." and "..self.config[cmd].max_setting, self.msg_color)
				end
			elseif not n and self.config[cmd].setting and #args.text:split(" ") == 2 then
				Chat:Print("Please enter a number between "..self.config[cmd].min_setting.." and "..self.config[cmd].max_setting, self.msg_color)
			else
				Chat:Print("Invalid autopilot command", self.msg_color)
			end
		else
			Chat:Print("Autopilot not available", self.msg_color)
		end
	return false
	end	
end

function Autopilot:HUDColor(on)
	if on == true then
		return self.hud_on_color
	else
		return self.hud_off_color
	end
end

function Autopilot:HUD() -- Subscribed to Render

	if Autopilot:PanelAvailable() then
	
		local position = Vector2(self.screen_width * 0.7, self.screen_height * 0.086)
		
		local autopilot_string = self.config.ap.name
		local roll_string = self.config.rh.name.." : "..tostringint(self.config.rh.setting)..self.config.rh.units
		local pitch_string = self.config.ph.name.." : "..tostringint(self.config.ph.setting)..self.config.ph.units
		local heading_string = self.config.hh.name.." : "..tostringint(self.config.hh.setting)..self.config.hh.units
		local altitude_string = self.config.ah.name.." : "..tostringint(self.config.ah.setting)..self.config.ah.units
		local speed_string = self.config.sh.name.." : "..tostringint(self.config.sh.setting)..self.config.sh.units
		local waypoint_string = self.config.wh.name
		
		local line = Vector2(0, self.hud_size)
		
		Render:DrawText(position + line * 0, autopilot_string, Autopilot:HUDColor(self.config.ap.on), self.hud_size)
		Render:DrawText(position + line * 1, roll_string, Autopilot:HUDColor(self.config.rh.on), self.hud_size)
		Render:DrawText(position + line * 2, pitch_string, Autopilot:HUDColor(self.config.ph.on), self.hud_size)
		Render:DrawText(position + line * 3, heading_string, Autopilot:HUDColor(self.config.hh.on), self.hud_size)
		Render:DrawText(position + line * 4, altitude_string, Autopilot:HUDColor(self.config.ah.on), self.hud_size)
		Render:DrawText(position + line * 5, speed_string, Autopilot:HUDColor(self.config.sh.on), self.hud_size)
		Render:DrawText(position + line * 6, waypoint_string, Autopilot:HUDColor(self.config.wh.on), self.hud_size)
		
	end
	
end

function Autopilot:PanelAvailable()

	if LocalPlayer:InVehicle() then
		if LocalPlayer == LocalPlayer:GetVehicle():GetDriver() and self.plane[LocalPlayer:GetVehicle():GetModelId()] then
			return true
		end
	end
	for i,k in pairs(self.config) do
		k["on"] = false
	end
	return false
	
end

function Autopilot:RollHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.rh.on then return false end
	
	local roll = Autopilot:GetRoll(LocalPlayer:GetVehicle())
	
	local input = math.abs(roll - self.config.rh.setting) * self.config.rh.gain
	if input > self.config.rh.max_input then input = self.config.rh.max_input end
	
	if self.config.rh.setting < roll then
		Input:SetValue(Action.PlaneTurnRight, input)
	end
	
	if self.config.rh.setting > roll then
		Input:SetValue(Action.PlaneTurnLeft, input)
	end
	
end

function Autopilot:PitchHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.ph.on then return false end
	
	local pitch = Autopilot:GetPitch(LocalPlayer:GetVehicle())
	local roll = Autopilot:GetRoll(LocalPlayer:GetVehicle())
	
	local input = math.abs(pitch - self.config.ph.setting) * self.config.ph.gain
	if input > self.config.ph.max_input then input = self.config.ph.max_input end
	
	if math.abs(roll) < 60 then
		if self.config.ph.setting > pitch then
			Input:SetValue(Action.PlanePitchUp, input)
		end
		
		if self.config.ph.setting < pitch then
			Input:SetValue(Action.PlanePitchDown, input)
		end
	end
	
	if math.abs(roll) > 120 then
		if self.config.ph.setting > pitch then
			Input:SetValue(Action.PlanePitchDown, input)
		end
		
		if self.config.ph.setting < pitch then
			Input:SetValue(Action.PlanePitchUp, input)
		end
	end
	
end

function Autopilot:HeadingHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.hh.on then return false end
	
	local heading = -Autopilot:GetYaw(LocalPlayer:GetVehicle())
	
	if heading <= 0 then
		heading = heading + 360
	end
	
	diff = ((self.config.hh.setting - heading) + 180) % 360 - 180
	
	self.config.rh.setting = -diff * self.config.hh.gain
	
	if self.config.rh.setting > self.config.hh.roll_limit then
		self.config.rh.setting = self.config.hh.roll_limit
	elseif self.config.rh.setting < -self.config.hh.roll_limit then
		self.config.rh.setting = -self.config.hh.roll_limit
	end
	
end

function Autopilot:AltitudeHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.ah.on then return false end
	
	self.config.ph.setting = (self.config.ah.setting - Autopilot:GetAltitude(LocalPlayer:GetVehicle()) + self.config.ah.bias) * self.config.ah.gain
	
	if self.config.ph.setting > self.config.ah.pitch_limit then
		self.config.ph.setting = self.config.ah.pitch_limit
	elseif self.config.ph.setting < -self.config.ah.pitch_limit then
		self.config.ph.setting = -self.config.ah.pitch_limit
	end
	
end

function Autopilot:SpeedHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.sh.on then return false end
	
	local air_speed = Autopilot:GetAirSpeed(LocalPlayer:GetVehicle())
	
	local input = math.abs(air_speed - self.config.sh.setting) * self.config.sh.gain
	if input > self.config.sh.max_input then input = self.config.sh.max_input end
	
	if air_speed < self.config.sh.setting then
		Input:SetValue(Action.PlaneIncTrust, input)
	end
	if air_speed > self.config.sh.setting then
		Input:SetValue(Action.PlaneDecTrust, input)
	end
	
end

function Autopilot:WaypointHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.wh.on then return false end
	
	local waypoint, marker = Waypoint:GetPosition()
	
	if not marker then
		self.config.wh.on = false
		for i,k in ipairs(self.config.wh.uses) do
			self.config[k].on = false
		end
		Chat:Print(self.config.wh.name.." disabled", self.msg_color)
		return false
	end
	
	local position = LocalPlayer:GetVehicle():GetPosition()
	local diffx = position.x - waypoint.x
	local diffy = position.z - waypoint.z
	
	angle = math.atan(diffx / diffy)
	
	if diffx > 0 and diffy > 0 then
		self.config.hh.setting  = 360 - math.deg(angle)
	elseif diffx < 0 and diffy > 0 then
		self.config.hh.setting = math.abs(math.deg(angle))
	elseif diffx < 0 and diffy < 0 then
		self.config.hh.setting = 180 - math.deg(angle)
	elseif diffx > 0 and diffy < 0 then 
		self.config.hh.setting = 180 + math.abs(math.deg(angle))
	end
	
end

function Autopilot:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.screen_width = args.size.x
	self.screen_height = args.size.y
	self.hud_size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	
end

Autopilot = Autopilot()
