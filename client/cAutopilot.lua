-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'Autopilot'

function Autopilot:__init()

	self.planes = {}
	self.planes[24] = true -- F-33 DragonFly
	self.planes[30] = true -- Si-47 Leopard
	self.planes[34] = true -- G9 Eclipse
	self.planes[39] = true -- Aeroliner 474
	self.planes[51] = true -- Cassius 192
	self.planes[59] = false -- Peek Airhawk 225
	self.planes[81] = true -- Pell Silverbolt 6
	self.planes[85] = true -- Bering I-86DP
	
	-- By default, autopilot is made not available in the Peek Airhawk 225
		
	self.config = { 
	
		["ap"] = {
			["name"] = "Autopilot",
			["on"] = false,
		},
		
		["rh"] = {
			["name"] = "Roll-Hold",
			["on"] = false,
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
			["setting"] = 0,
			["units"] = " m",
			["min_setting"] = 0, -- Do not set less than 0
			["max_setting"] = 5000, -- Planes do not maneuver properly above 5000 m
			["gain"] = 0.30, -- 0.30 default
			["pitch_limit"] = 45, -- Maximum pitch angle while AH is active, 30 to 60 recommended
			["bias"] = 5, -- Correction for gravity
			["step"] = 50 -- Step size for changing setting
		},
		
		["sh"] = {
			["name"] = "Speed-Hold",
			["on"] = false,
			["setting"] = 0,
			["units"] = " km/h",
			["min_setting"] = 0, -- Do not set less than 0
			["max_setting"] = 500, -- Planes rarely exceed 500 km/h without server functions
			["gain"] = 0.04, -- 0.04 default
			["max_input"] = 1.0, -- Percentage from 0 to 1
			["step"] = 5 -- Step size for changing setting
		},
		
		["wh"] = {
			["name"] = "Waypoint-Hold",
			["on"] = false,
		}
	}
				
	self.panel_available = true -- Whether you are in a plane with autopilot available
	self.panel_open = true -- Whether the autopilot panel is open
	
	self.one_key = true -- If true then Z toggles both the panel and mouse
	self.panel_toggle_button = "Z"
	self.mouse_toggle_button = "M"
	
	self.screen_height = Render.Height
	self.screen_width = Render.Width
	self.text_scale = 0.03
	
	self.window = Window.Create()
	
	self.window.position = Vector2(0.65, 0.05)
	self.window.size = Vector2(0.28, 0.26)
	self.window.button_size = Vector2(0.30, 0.11)
	self.window.button_position = Vector2(0, 0.12)
	self.window.label_size = Vector2(0.25, 0.12)
	self.window.slider_size = Vector2(0.31, 0.12)
	
	self.window:SetVisible(self.panel_open)
	self.window:SetTitle("Autopilot Panel")
	self.window:SetClosable(false)
	
	self.window:SetSizeRel(self.window.size)
	self.window:SetPositionRel(self.window.position)
	
	self.window.setting = {}
	
	self.window.setting.ap = {}
	self.window.setting.rh = {}
	self.window.setting.ph = {}
	self.window.setting.hh = {}
	self.window.setting.ah = {}
	self.window.setting.sh = {}
	self.window.setting.wh = {}
	
	for i,k in pairs(self.window.setting) do
	
		k.button = Button.Create(self.window)
		k.button:SetText(self.config[i].name)
		k.button:SetToggleable(true)
		
		if self.config[i].setting then
			k.label = Label.Create(self.window)
			k.slider = HorizontalSlider.Create(self.window)
			k.slider:SetRange(self.config[i].min_setting, self.config[i].max_setting)
			
			if self.config[i].step then
				k.slider:SetClampToNotches(true)
				k.slider:SetNotchCount((self.config[i].max_setting-self.config[i].min_setting)/self.config.ah.step)
			end
			
			k.inc = Button.Create(self.window)
			k.dec = Button.Create(self.window)
			k.inc:SetText("+")
			k.dec:SetText("-")
			
		end
		
	end
	
	self.window.setting.ap.button:Subscribe("ToggleOn", self, self.APButtonOn)
	self.window.setting.rh.button:Subscribe("ToggleOn", self, self.RHButtonOn)
	self.window.setting.ph.button:Subscribe("ToggleOn", self, self.PHButtonOn)
	self.window.setting.hh.button:Subscribe("ToggleOn", self, self.HHButtonOn)
	self.window.setting.ah.button:Subscribe("ToggleOn", self, self.AHButtonOn)
	self.window.setting.sh.button:Subscribe("ToggleOn", self, self.SHButtonOn)
	self.window.setting.wh.button:Subscribe("ToggleOn", self, self.WHButtonOn)
	
	self.window.setting.ap.button:Subscribe("ToggleOff", self, self.APButtonOff)
	self.window.setting.rh.button:Subscribe("ToggleOff", self, self.RHButtonOff)
	self.window.setting.ph.button:Subscribe("ToggleOff", self, self.PHButtonOff)
	self.window.setting.hh.button:Subscribe("ToggleOff", self, self.HHButtonOff)
	self.window.setting.ah.button:Subscribe("ToggleOff", self, self.AHButtonOff)
	self.window.setting.sh.button:Subscribe("ToggleOff", self, self.SHButtonOff)
	self.window.setting.wh.button:Subscribe("ToggleOff", self, self.WHButtonOff)
	
	self.window.setting.rh.slider:Subscribe("ValueChanged", self, self.RHSlider)
	self.window.setting.ph.slider:Subscribe("ValueChanged", self, self.PHSlider)
	self.window.setting.hh.slider:Subscribe("ValueChanged", self, self.HHSlider)
	self.window.setting.ah.slider:Subscribe("ValueChanged", self, self.AHSlider)
	self.window.setting.sh.slider:Subscribe("ValueChanged", self, self.SHSlider)
	
	self.window.setting.rh.inc:Subscribe("Press", self, self.RHIncrease)
	self.window.setting.ph.inc:Subscribe("Press", self, self.PHIncrease)
	self.window.setting.hh.inc:Subscribe("Press", self, self.HHIncrease)
	self.window.setting.ah.inc:Subscribe("Press", self, self.AHIncrease)
	self.window.setting.sh.inc:Subscribe("Press", self, self.SHIncrease)
	
	self.window.setting.rh.dec:Subscribe("Press", self, self.RHDecrease)
	self.window.setting.ph.dec:Subscribe("Press", self, self.PHDecrease)
	self.window.setting.hh.dec:Subscribe("Press", self, self.HHDecrease)
	self.window.setting.ah.dec:Subscribe("Press", self, self.AHDecrease)
	self.window.setting.sh.dec:Subscribe("Press", self, self.SHDecrease)
	
	self.window:Subscribe("Render", self, self.WindowRender)
	
	Events:Subscribe("ResolutionChange", self, self.WindowResize)
	Events:Subscribe("KeyUp", self, self.PanelOpen)
	Events:Subscribe("LocalPlayerInput", self, self.InputBlock)
	Events:Subscribe("PreTick", self, self.PanelAvailable)
	Events:Subscribe("InputPoll", self, self.RollHold)
	Events:Subscribe("InputPoll", self, self.PitchHold)
	Events:Subscribe("InputPoll", self, self.HeadingHold)
	Events:Subscribe("InputPoll", self, self.AltitudeHold)
	Events:Subscribe("InputPoll", self, self.SpeedHold)
	Events:Subscribe("InputPoll", self, self.WaypointHold)
	
end

function Autopilot:RHSlider(args)
	self.config.rh.setting = args:GetValue()
end

function Autopilot:PHSlider(args)
	self.config.ph.setting = args:GetValue()
end

function Autopilot:HHSlider(args)
	self.config.hh.setting = args:GetValue()
end

function Autopilot:AHSlider(args)
	self.config.ah.setting = args:GetValue()
end

function Autopilot:SHSlider(args)
	self.config.sh.setting = args:GetValue()
end

function Autopilot:RHIncrease()
	if self.config.rh.setting < self.config.rh.max_setting then
		self.config.rh.setting = self.config.rh.setting + 1
	end
end

function Autopilot:PHIncrease()
	if self.config.ph.setting < self.config.ph.max_setting then
		self.config.ph.setting = self.config.ph.setting + 1
	end
end

function Autopilot:HHIncrease()
	if self.config.hh.setting < self.config.hh.max_setting then
		self.config.hh.setting = self.config.hh.setting + 1
	end
end

function Autopilot:AHIncrease()
	if self.config.ah.setting < self.config.ah.max_setting then
		self.config.ah.setting = self.config.ah.setting + self.config.ah.step
	end
end

function Autopilot:SHIncrease()
	if self.config.sh.setting < self.config.sh.max_setting then
		self.config.sh.setting = self.config.sh.setting + self.config.sh.step
	end
end

function Autopilot:RHDecrease()
	if self.config.rh.setting > self.config.rh.min_setting then
		self.config.rh.setting = self.config.rh.setting - 1
	end
end

function Autopilot:PHDecrease()
	if self.config.ph.setting > self.config.ph.min_setting then
		self.config.ph.setting = self.config.ph.setting - 1
	end
end

function Autopilot:HHDecrease()
	if self.config.hh.setting > self.config.hh.min_setting then
		self.config.hh.setting = self.config.hh.setting - 1
	end
end

function Autopilot:AHDecrease()
	if self.config.ah.setting > self.config.ah.min_setting then
		self.config.ah.setting = self.config.ah.setting - self.config.ah.step
	end
end

function Autopilot:SHDecrease()
	if self.config.sh.setting > self.config.sh.min_setting then
		self.config.sh.setting = self.config.sh.setting - self.config.sh.step
	end
end

function Autopilot:APButtonOn()
	self.config.ap.on = true
end

function Autopilot:RHButtonOn()
	self.config.ap.on = true
	self.config.rh.on = true
end

function Autopilot:PHButtonOn()
	self.config.ap.on = true
	self.config.ph.on = true
end

function Autopilot:HHButtonOn()
	self.config.ap.on = true
	self.config.rh.on = true
	self.config.hh.on = true
end

function Autopilot:AHButtonOn()
	self.config.ap.on = true
	self.config.ph.on = true
	self.config.ah.on = true
end

function Autopilot:SHButtonOn()
	self.config.ap.on = true
	self.config.sh.on = true
end

function Autopilot:WHButtonOn()
	local waypoint, marker = Waypoint:GetPosition()
	if marker then
		self.config.ap.on = true
		self.config.rh.on = true
		self.config.hh.on = true
		self.config.wh.on = true
	end
end

function Autopilot:APButtonOff()
	self.config.ap.on = false
	self.config.rh.on = false
	self.config.ph.on = false
	self.config.hh.on = false
	self.config.ah.on = false
	self.config.sh.on = false
	self.config.wh.on = false
end

function Autopilot:RHButtonOff()
	if self.config.wh.on == false and self.config.hh.on == false then
		self.config.rh.on = false
	end
end

function Autopilot:PHButtonOff()
	if self.config.ah.on == false then
		self.config.ph.on = false
	end
end

function Autopilot:HHButtonOff()
	if self.config.wh.on == false then
		self.config.rh.on = false
		self.config.hh.on = false
	end
end

function Autopilot:AHButtonOff()
	self.config.ph.on = false
	self.config.ah.on = false
end

function Autopilot:SHButtonOff()
	self.config.sh.on = false
end

function Autopilot:WHButtonOff()
	self.config.rh.on = false
	self.config.hh.on = false
	self.config.wh.on = false
end

function Autopilot:PanelOpen(args) -- Subscribed to KeyUp
	if self.one_key then
	
		if args.key == string.byte(self.panel_toggle_button) and self.panel_available then
			self.panel_open = not self.panel_open
			Mouse:SetVisible(self.panel_open)
		end
		
	elseif not self.one_key then
	
		if args.key == string.byte(self.panel_toggle_button) and self.panel_available then
			self.panel_open = not self.panel_open
		end
		
		if args.key == string.byte(self.mouse_toggle_button) and self.panel_available then
			Mouse:SetVisible(not Mouse:GetVisible())
		end
	end
end

function Autopilot:InputBlock(args) -- Subscribed to LocalPlayerInput
	if self.panel_open then
		if args.input == 3 or args.input == 4 or args.input == 5 or args.input == 6 or args.input == 138 or args.input == 139 then
			return false
		end
	end	
end

function Autopilot:WindowResize() -- Subscribed to ResolutionChange
	self.window:SetSizeRel(self.window.size)
	self.window:SetPositionRel(self.window.position)
end
	
function Autopilot:WindowRender() -- Subscribed to Window Render

	self.text_size = self.window:GetSize():Length() * self.text_scale
	
	self.window.setting.ap.button:SetPositionRel(self.window.button_position * 0)
	self.window.setting.rh.button:SetPositionRel(self.window.button_position * 1)
	self.window.setting.ph.button:SetPositionRel(self.window.button_position * 2)
	self.window.setting.hh.button:SetPositionRel(self.window.button_position * 3)
	self.window.setting.ah.button:SetPositionRel(self.window.button_position * 4)
	self.window.setting.sh.button:SetPositionRel(self.window.button_position * 5)
	self.window.setting.wh.button:SetPositionRel(self.window.button_position * 6)
	
	for i,k in pairs(self.window.setting) do
	
		k.button:SetToggleState(self.config[i].on)
		k.button:SetText(self.config[i].name)
		k.button:SetSizeRel(self.window.button_size)
		k.button:SetTextSize(self.text_size)
		
		if self.config[i].setting then
		
			k.label:SetText(tostringint(self.config[i].setting)..self.config[i].units)
			k.label:SetSizeRel(self.window.label_size)
			k.label:SetTextSize(self.text_size)
			k.label:SetPositionRel(k.button:GetPositionRel() + Vector2(k.button:GetWidthRel() * 1.1, k.button:GetHeightRel() * 0.32))
			
			k.slider:SetValue(self.config[i].setting)
			k.slider:SetSizeRel(self.window.slider_size)
			k.slider:SetPositionRel(self.window.setting[i].button:GetPositionRel() + Vector2(self.window.setting[i].button:GetWidthRel() * 1.6, 0))
			
			k.dec:SetSizeRel(Vector2(self.window.button_size.x / 4, self.window.button_size.y))
			k.dec:SetTextSize(self.text_size)
			k.dec:SetPositionRel(k.button:GetPositionRel() + Vector2(0.81, 0))
			
			k.inc:SetSizeRel(Vector2(self.window.button_size.x / 4, self.window.button_size.y))
			k.inc:SetTextSize(self.text_size)
			k.inc:SetPositionRel(k.button:GetPositionRel() + Vector2(0.89, 0))
			
		end
	end
	
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

function Autopilot:PanelAvailable() -- Subscribed to PreTick

	if LocalPlayer:InVehicle() and LocalPlayer == LocalPlayer:GetVehicle():GetDriver() and self.planes[LocalPlayer:GetVehicle():GetModelId()] then
		self.panel_available = true
	else
		self.panel_available = false
	end
	
	if Game:GetState() == GUIState.Game then
		self.window:SetVisible(self.panel_open)
	else
		self.window:SetVisible(false)
		Mouse:SetVisible(false)
	end
	
	if not self.panel_available then
		self.panel_open = false
		for i,k in pairs(self.config) do
			self.config[i].on = false
		end
		Mouse:SetVisible(false)
	end
end

function Autopilot:RollHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.rh.on then return false end	
	
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

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.ph.on then return false end
	
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

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.hh.on then return false end
	
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

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.ah.on then return false end
	
	self.config.ph.setting = (self.config.ah.setting - Autopilot:GetAltitude(LocalPlayer:GetVehicle()) + self.config.ah.bias) * self.config.ah.gain
	
	if self.config.ph.setting > self.config.ah.pitch_limit then
		self.config.ph.setting = self.config.ah.pitch_limit
	elseif self.config.ph.setting < -self.config.ah.pitch_limit then
		self.config.ph.setting = -self.config.ah.pitch_limit
	end
	
end

function Autopilot:SpeedHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.sh.on then return false end
	
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

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.wh.on then return false end
	
	local waypoint, marker = Waypoint:GetPosition()
	
	if not marker then
		self.config.wh.on = false
		self.config.hh.on = false
		self.config.rh.on = false
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

Autopilot = Autopilot()
