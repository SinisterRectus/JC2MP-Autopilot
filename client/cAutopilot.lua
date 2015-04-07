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
	self.plane[81] = true -- Pell Silverbolt 6 (not upgraded)
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
			["min"] = -60,
			["max"] = 60,
			["gain"] = 0.08	
		},
		
		["ph"] = {			
			["name"] = "Pitch-Hold",
			["on"] = false,
			["uses"] = {},
			["used_by"] = {"ah"},
			["setting"] = 0,
			["units"] = "°",
			["min"] = -60,
			["max"] = 60,
			["gain"] = 0.50
		},
		
		["hh"] = {			
			["name"] = "Heading-Hold",
			["on"] = false,
			["uses"] = {"rh"},
			["used_by"] = {"wh"},
			["setting"] = 0,
			["units"] = "°",
			["min"] = 0,
			["max"] = 360,
			["gain"] = 2.00,
			["roll_limit"] = 45 -- Maximum roll angle while HH is active
		},
		
		["ah"] = {
			["name"] = "Altitude-Hold",
			["on"] = false,
			["uses"] = {"ph"},
			["used_by"] = {},
			["setting"] = 0,
			["units"] = " m",
			["min"] = 0,
			["max"] = 5000,
			["gain"] = 0.30,
			["pitch_limit"] = 45, -- Maximum pitch angle while AH is active
			["bias"] = 5 -- Correction for gravity
		},
		
		["th"] = {
			["name"] = "Throttle-Hold",
			["on"] = false,
			["uses"] = {},
			["used_by"] = {},
			["setting"] = 0,
			["units"] = " km/h" ,
			["min"] = 0,
			["max"] = 700,
			["gain"] = 0.05,
		},
		
		["wh"] = {
			["name"] = "Waypoint-Hold",
			["on"] = false,
			["uses"] = {"hh", "rh"},
			["used_by"] = {}
		}
	}
			
	-- END CONFIG --
		
	self.max_power = 1.0 -- Global maximum input value
	
	Events:Subscribe("LocalPlayerChat", self, self.Control)
	Events:Subscribe("Render", self, self.HUD)
	Events:Subscribe("InputPoll", self, self.RollHold)
	Events:Subscribe("InputPoll", self, self.PitchHold)
	Events:Subscribe("InputPoll", self, self.HeadingHold)
	Events:Subscribe("InputPoll", self, self.AltitudeHold)
	Events:Subscribe("InputPoll", self, self.ThrottleHold)
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
	return math.max(v:GetPosition().y - 200, 0)
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
	
	if args.text:split(" ")[3] then
		Chat:Print("Invalid autopilot command", self.msg_color)
		return false 
	end
	
	local waypoint, marker = Waypoint:GetPosition()
	local cmd = text1:split("/")[2]
	local n = tonumber(text2)
	
	if self.config[cmd] then
		if Autopilot:PanelAvailable() then
			if not text2 then
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
			elseif n and self.config[cmd].setting then
				if n >= self.config[cmd].min and n <= self.config[cmd].max then
					self.config[cmd].setting = n
					Chat:Print(self.config[cmd].name.." set to "..self.config[cmd].setting, self.msg_color)
				else
					Chat:Print("Please enter a number between "..self.config[cmd].min.." and "..self.config[cmd].max, self.msg_color)
				end
			elseif not n and self.config[cmd].setting then
				Chat:Print("Please enter a number between "..self.config[cmd].min.." and "..self.config[cmd].max, self.msg_color)
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
		local throttle_string = self.config.th.name.." : "..tostringint(self.config.th.setting)..self.config.th.units
		local waypoint_string = self.config.wh.name
		
		local line = Vector2(0, self.hud_size)
		
		Render:DrawText(position + line * 0, autopilot_string, Autopilot:HUDColor(self.config.ap.on), self.hud_size)
		Render:DrawText(position + line * 1, roll_string, Autopilot:HUDColor(self.config.rh.on), self.hud_size)
		Render:DrawText(position + line * 2, pitch_string, Autopilot:HUDColor(self.config.ph.on), self.hud_size)
		Render:DrawText(position + line * 3, heading_string, Autopilot:HUDColor(self.config.hh.on), self.hud_size)
		Render:DrawText(position + line * 4, altitude_string, Autopilot:HUDColor(self.config.ah.on), self.hud_size)
		Render:DrawText(position + line * 5, throttle_string, Autopilot:HUDColor(self.config.th.on), self.hud_size)
		Render:DrawText(position + line * 6, waypoint_string, Autopilot:HUDColor(self.config.wh.on), self.hud_size)
		
	end
	
end

function Autopilot:PanelAvailable()

	if LocalPlayer:InVehicle() then
		local v = LocalPlayer:GetVehicle()
		if LocalPlayer == v:GetDriver() and self.plane[v:GetModelId()] then
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
	
	local v = LocalPlayer:GetVehicle()
	local roll = Autopilot:GetRoll(v)
	
	local power = math.abs(roll - self.config.rh.setting) * self.config.rh.gain
	if power > self.max_power then power = self.max_power end
	
	if self.config.rh.setting < roll then
		Input:SetValue(Action.PlaneTurnRight, power)
	end
	
	if self.config.rh.setting > roll then
		Input:SetValue(Action.PlaneTurnLeft, power)
	end
	
end

function Autopilot:PitchHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.ph.on then return false end
	
	local v = LocalPlayer:GetVehicle()
	local pitch = Autopilot:GetPitch(v)
	local roll = Autopilot:GetRoll(v)
	
	local power = math.abs(pitch - self.config.ph.setting) * self.config.ph.gain
	if power > self.max_power then power = self.max_power end
	
	if math.abs(roll) < 90 then
		if self.config.ph.setting > pitch then
			Input:SetValue(Action.PlanePitchUp, power)
		end
		
		if self.config.ph.setting < pitch then
			Input:SetValue(Action.PlanePitchDown, power)
		end
	end
	
	if math.abs(roll) >= 90 then
		if self.config.ph.setting > pitch then
			Input:SetValue(Action.PlanePitchDown, power)
		end
		
		if self.config.ph.setting < pitch then
			Input:SetValue(Action.PlanePitchUp, power)
		end
	end
	
end

function Autopilot:HeadingHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.hh.on then return false end
	
	local v = LocalPlayer:GetVehicle()
	local heading = -Autopilot:GetYaw(v)
	
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
	
	local v = LocalPlayer:GetVehicle()

	self.config.ph.setting = (self.config.ah.setting - Autopilot:GetAltitude(v) + self.config.ah.bias) * self.config.ah.gain
	
	if self.config.ph.setting > self.config.ah.pitch_limit then
		self.config.ph.setting = self.config.ah.pitch_limit
	elseif self.config.ph.setting < -self.config.ah.pitch_limit then
		self.config.ph.setting = -self.config.ah.pitch_limit
	end
	
end

function Autopilot:ThrottleHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not Autopilot:PanelAvailable() or not self.config.th.on then return false end
	
	local v = LocalPlayer:GetVehicle()
	
	local air_speed = Autopilot:GetAirSpeed(v)
	
	local power = math.abs(air_speed - self.config.th.setting) * self.config.th.gain
	if power > self.max_power then power = self.max_power end
	
	if air_speed < self.config.th.setting then
		Input:SetValue(Action.PlaneIncTrust, power)
	end
	if air_speed > self.config.th.setting then
		Input:SetValue(Action.PlaneDecTrust, power)
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
	
	local v = LocalPlayer:GetVehicle()
	local position = v:GetPosition()
	local heading
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
	
	self.config.hh.setting = heading
	
end

function Autopilot:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.screen_width = args.size.x
	self.screen_height = args.size.y
	self.hud_size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	
end

Autopilot = Autopilot()
