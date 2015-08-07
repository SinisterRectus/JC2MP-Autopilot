-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'Autopilot'

function Autopilot:__init()

	self.color = {Color.Orange, Color.Silver} -- Color scheme
	
	self.draw_target = true -- Whether to draw a target indicator for target-hold		
	self.draw_approach = true -- Whether to draw a path for approach-hold
		
	self.two_keys = false -- If false then Z toggles both the panel and mouse
	self.panel_toggle_button = "Z"
	self.mouse_toggle_button = "M"
	
	if LocalPlayer:InVehicle() then
		local vehicle = LocalPlayer:GetVehicle()
		if vehicle:GetDriver() == LocalPlayer then
			local model = vehicle:GetModelId()
			if planes[model] and planes[model].available then
				self.vehicle = vehicle
				self.model = model
			end
		end
	end
	
	if self.vehicle then self.panel_available = true else self.panel_available = false end

	self:InitGUI()
	
	Events:Subscribe("ModuleLoad", self, self.WindowResize)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
	Events:Subscribe("KeyUp", self, self.PanelOpen)
	Events:Subscribe("LocalPlayerInput", self, self.InputBlock)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterPlane)
	Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitPlane)
	Events:Subscribe("EntityDespawn", self, self.PlaneDespawn)
	
	Events:Subscribe("InputPoll", self, self.RollHold)
	Events:Subscribe("InputPoll", self, self.PitchHold)
	Events:Subscribe("InputPoll", self, self.HeadingHold)
	Events:Subscribe("InputPoll", self, self.AltitudeHold)
	Events:Subscribe("InputPoll", self, self.SpeedHold)
	Events:Subscribe("InputPoll", self, self.WaypointHold)
	Events:Subscribe("Render", self, self.ApproachHold)
	Events:Subscribe("Render", self, self.TargetHold)
	
end

function Autopilot:InitGUI()

	self.window = Window.Create()
	
	self.text_scale = 0.03
	self.window.position = Vector2(0.63, 0.04)
	self.window.size = Vector2(0.28, 0.28)
	self.window.button_size = Vector2(0.22, 0.095)
	self.window.button_position = Vector2(0, 0.105)
	self.window.label_size = Vector2(0.16, self.window.button_size.y)
	self.window.slider_size = Vector2(0.31, self.window.button_size.y)
	
	self.window:SetTitle("Autopilot Panel")
	self.window:SetVisible(false)
	self.window:SetClosable(false)
	
	self.window:SetSizeRel(self.window.size)
	self.window:SetPositionRel(self.window.position)
	
	self.window.setting = {
		["ap"] = {},
		["rh"] = {},
		["ph"] = {},
		["hh"] = {},
		["ah"] = {},
		["sh"] = {},
		["wh"] = {},
		["oh"] = {},
		["th"] = {}
	}
	
	self.break_line = Rectangle.Create(self.window)
	self.break_line:SetColor(Color(64, 64, 64))
		
	for k,v in pairs(self.window.setting) do
	
		v.button = Button.Create(self.window)
		v.button:SetText(config[k].name)
		v.button:SetToggleable(true)
		v.button:SetTextPressedColor(self.color[1])
		
		if config[k].setting then
			v.label = Label.Create(self.window)
			v.slider = HorizontalSlider.Create(self.window)
			v.slider:SetRange(config[k].min_setting, config[k].max_setting)
			
			if config[k].step then
				v.slider:SetClampToNotches(true)
				v.slider:SetNotchCount((config[k].max_setting-config[k].min_setting)/config[k].step)
			end
			
			v.inc = Button.Create(self.window)
			v.dec = Button.Create(self.window)
			v.inc:SetText("+")
			v.dec:SetText("-")
			
			v.quick = Button.Create(self.window)
			v.quick:SetText(config[k].quick)
			
		end
		
	end
	
	self.window.setting.ap.button:Subscribe("ToggleOn", self, self.APOn)
	self.window.setting.rh.button:Subscribe("ToggleOn", self, self.RHOn)
	self.window.setting.ph.button:Subscribe("ToggleOn", self, self.PHOn)
	self.window.setting.hh.button:Subscribe("ToggleOn", self, self.HHOn)
	self.window.setting.ah.button:Subscribe("ToggleOn", self, self.AHOn)
	self.window.setting.sh.button:Subscribe("ToggleOn", self, self.SHOn)
	self.window.setting.wh.button:Subscribe("ToggleOn", self, self.WHOn)
	self.window.setting.oh.button:Subscribe("ToggleOn", self, self.OHOn)
	self.window.setting.th.button:Subscribe("ToggleOn", self, self.THOn)
	
	self.window.setting.ap.button:Subscribe("ToggleOff", self, self.APOff)
	self.window.setting.rh.button:Subscribe("ToggleOff", self, self.RHOff)
	self.window.setting.ph.button:Subscribe("ToggleOff", self, self.PHOff)
	self.window.setting.hh.button:Subscribe("ToggleOff", self, self.HHOff)
	self.window.setting.ah.button:Subscribe("ToggleOff", self, self.AHOff)
	self.window.setting.sh.button:Subscribe("ToggleOff", self, self.SHOff)
	self.window.setting.wh.button:Subscribe("ToggleOff", self, self.WHOff)
	self.window.setting.oh.button:Subscribe("ToggleOff", self, self.OHOff)
	self.window.setting.th.button:Subscribe("ToggleOff", self, self.THOff)
	
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
	
	self.window.setting.rh.quick:Subscribe("Press", self, self.RHQuick)
	self.window.setting.ph.quick:Subscribe("Press", self, self.PHQuick)
	self.window.setting.hh.quick:Subscribe("Press", self, self.HHQuick)
	self.window.setting.ah.quick:Subscribe("Press", self, self.AHQuick)
	self.window.setting.sh.quick:Subscribe("Press", self, self.SHQuick)
	
	self.window:Subscribe("Render", self, self.WindowUpdate)
	self.window:Subscribe("Resize", self, self.WindowResize)

end

function Autopilot:RHSlider(args)
	config.rh.setting = args:GetValue()
end

function Autopilot:PHSlider(args)
	config.ph.setting = args:GetValue()
end

function Autopilot:HHSlider(args)
	config.hh.setting = args:GetValue()
end

function Autopilot:AHSlider(args)
	config.ah.setting = args:GetValue()
end

function Autopilot:SHSlider(args)
	config.sh.setting = args:GetValue()
end

function Autopilot:RHQuick(args)
	config.rh.setting = 0
	self:RHOn()
end

function Autopilot:PHQuick(args)
	config.ph.setting = 0
	self:PHOn()
end

function Autopilot:HHQuick(args)
	config.hh.setting = self.vehicle:GetHeading()
	self:HHOn()
end

function Autopilot:AHQuick(args)
	config.ah.setting = self.vehicle:GetAltitude()
	self:AHOn()
end

function Autopilot:SHQuick(args)
	config.sh.setting = planes[self.model].cruise_speed
	self:SHOn()
end

function Autopilot:RHIncrease()
	if config.rh.setting < config.rh.max_setting then
		config.rh.setting = config.rh.setting + 1
	end
end

function Autopilot:PHIncrease()
	if config.ph.setting < config.ph.max_setting then
		config.ph.setting = config.ph.setting + 1
	end
end

function Autopilot:HHIncrease()
	if config.hh.setting == 360 then
		config.hh.setting = 1
	elseif config.hh.setting < config.hh.max_setting then
		config.hh.setting = config.hh.setting + 1
	end
end

function Autopilot:AHIncrease()
	if config.ah.setting < config.ah.max_setting then
		config.ah.setting = config.ah.setting + config.ah.step
	end
end

function Autopilot:SHIncrease()
	if config.sh.setting < config.sh.max_setting then
		config.sh.setting = config.sh.setting + config.sh.step
	end
end

function Autopilot:RHDecrease()
	if config.rh.setting > config.rh.min_setting then
		config.rh.setting = config.rh.setting - 1
	end
end

function Autopilot:PHDecrease()
	if config.ph.setting > config.ph.min_setting then
		config.ph.setting = config.ph.setting - 1
	end
end

function Autopilot:HHDecrease()
	if config.hh.setting == 0 then
		config.hh.setting = 359
	elseif config.hh.setting > config.hh.min_setting then
		config.hh.setting = config.hh.setting - 1
	end
end

function Autopilot:AHDecrease()
	if config.ah.setting > config.ah.min_setting then
		config.ah.setting = config.ah.setting - config.ah.step
	end
end

function Autopilot:SHDecrease()
	if config.sh.setting > config.sh.min_setting then
		config.sh.setting = config.sh.setting - config.sh.step
	end
end

function Autopilot:APOn()
	config.ap.on = true
end

function Autopilot:RHOn()
	if not self.scanning then
		self:APOn()
		config.rh.on = true
	end
end

function Autopilot:PHOn()
	if not self.scanning then
		self:APOn()
		config.ph.on = true
	end
end

function Autopilot:HHOn()
	if not self.scanning then
		self:RHOn()
		config.hh.on = true
	end
end

function Autopilot:AHOn()
	if not self.scanning and not config.th.on then
		self:PHOn()
		config.ah.on = true
	end
end

function Autopilot:SHOn()
	if not self.scanning then
		self:APOn()
		config.sh.on = true
	end
end

function Autopilot:WHOn()
	local waypoint, marker = Waypoint:GetPosition()
	if marker then
		self:OHOff()
		self:THOff()
		self:HHOn()
		config.wh.on = true
	else
		Chat:Print("Waypoint not set.", self.color[2])
	end
end

function Autopilot:OHOn()
	self:APOn()
	self:SHOff()
	self:WHOff()
	self:THOff()
	config.oh.on = true
	self.scanning = true
	self.approach_timer = Timer()
	Chat:Print("Scanning for runways...", self.color[2])
end

function Autopilot:THOn()
	self:APOn()
	self:SHOff()
	self:WHOff()
	self:OHOff()
	config.th.on = true
	self.scanning = true
	self.target_timer = Timer()
	Chat:Print("Scanning for targets...", self.color[2])
end

function Autopilot:APOff()
	self:OHOff()
	self:THOff()
	self:AHOff()
	self:WHOff()
	self:HHOff()
	self:PHOff()
	self:RHOff()
	self:SHOff()
	config.ap.on = false
end

function Autopilot:RHOff()
	if not config.wh.on and not config.hh.on then
		config.rh.on = false
	end
end

function Autopilot:PHOff()
	if not config.ah.on and not config.th.on and not config.oh.on then
		config.ph.on = false
	end
end

function Autopilot:HHOff()
	if not config.wh.on and not config.th.on and not config.oh.on then
		config.hh.on = false
		self:RHOff()
	end
end

function Autopilot:AHOff()
	if not config.oh.on then
		config.ah.on = false
		self:PHOff()
	end
end

function Autopilot:SHOff()
	if not config.th.on and not config.oh.on then
		config.sh.on = false
	end
end

function Autopilot:WHOff()
	if config.wh.on then
		config.wh.on = false
		if not config.oh.on then
			self:HHOff()
		end
	end
end

function Autopilot:OHOff()
	if config.oh.on then
		config.oh.on = false
		self.scanning = nil
		self.approach = nil
		self.flare = nil
		if not config.wh.on then
			self:HHOff()
		end
		self:AHOff()
		self:SHOff()
	end
end

function Autopilot:THOff()
	if config.th.on then
		config.th.on = false
		self.scanning = nil
		self.target = nil
		self:HHOff()
		self:PHOff()
		self:SHOff()
	end
end

function Autopilot:PanelOpen(args) -- Subscribed to KeyUp

	if self.two_keys then
	
		if args.key == string.byte(self.panel_toggle_button) and self.panel_available then
			self.window:SetVisible(not self.window:GetVisible())
		end
		
		if args.key == string.byte(self.mouse_toggle_button) and self.panel_available then
			Mouse:SetVisible(not Mouse:GetVisible())
		end
		
	else
	
		if args.key == string.byte(self.panel_toggle_button) and self.panel_available then
			self.window:SetVisible(not self.window:GetVisible())
			Mouse:SetVisible(self.window:GetVisible())
		end
		
	end
	
end

function Autopilot:InputBlock(args) -- Subscribed to LocalPlayerInput
	local i = args.input
	if Mouse:GetVisible() then
		if i == 3 or i == 4 or i == 5 or i == 6 or i == 138 or i == 139 then
			return false
		end
	end
	if config.rh.on then
		if i == 60 or i == 61 then
			return false
		end
	end
	if config.ph.on then
		if i == 58 or i == 59 then
			return false
		end
	end
	if config.sh.on then
		if i == 64 or i == 65 then
			return false
		end
	end
end

function Autopilot:ResolutionChange() -- Subscribe to ResolutionChange
	self.window:SetSizeRel(self.window.size)
	self.window:SetPositionRel(self.window.position)
	self:WindowResize()
end
	
function Autopilot:WindowResize() -- Subscribed to ModuleLoad and Window Resize

	local window_size = self.window:GetSize()

	self.text_size = window_size:Length() * self.text_scale
	
	self.window.setting.ap.button:SetPositionRel(self.window.button_position * 0)
	self.window.setting.rh.button:SetPositionRel(self.window.button_position * 1)
	self.window.setting.ph.button:SetPositionRel(self.window.button_position * 2)
	self.window.setting.hh.button:SetPositionRel(self.window.button_position * 3)
	self.window.setting.ah.button:SetPositionRel(self.window.button_position * 4)
	self.window.setting.sh.button:SetPositionRel(self.window.button_position * 5)
	
	self.window.setting.wh.button:SetPositionRel(self.window.button_position * 7)
	self.window.setting.oh.button:SetPositionRel(Vector2(self.window.button_position.x + self.window.button_size.x * 1.03, self.window.button_position.y * 7))
	self.window.setting.th.button:SetPositionRel(Vector2(self.window.button_position.x + self.window.button_size.x * 2.06, self.window.button_position.y * 7))
	
	self.break_line:SetPositionRel(self.window.button_position * 6.35)
	self.break_line:SetSizeRel(Vector2(window_size.x, self.window.button_size.y * 0.2))
	
	for k,v in pairs(self.window.setting) do

		v.button:SetSizeRel(self.window.button_size)
		v.button:SetTextSize(self.text_size)
		
		if config[k].setting then
		
			v.label:SetSizeRel(self.window.label_size)
			v.label:SetTextSize(self.text_size)
			v.label:SetPositionRel(v.button:GetPositionRel() + Vector2(v.button:GetWidthRel() * 1.06, v.button:GetHeightRel() * 0.2))
			
			v.slider:SetSizeRel(self.window.slider_size)
			v.slider:SetPositionRel(v.label:GetPositionRel() + Vector2(v.label:GetWidthRel(), v.label:GetHeightRel() * -0.3))
			
			v.dec:SetSizeRel(Vector2(self.window.button_size.x / 3.5, self.window.button_size.y))
			v.dec:SetTextSize(self.text_size)
			v.dec:SetPositionRel(v.button:GetPositionRel() + Vector2(v.button:GetWidthRel() * 3.2, 0))
			
			v.inc:SetSizeRel(Vector2(self.window.button_size.x / 3.5, self.window.button_size.y))
			v.inc:SetTextSize(self.text_size)
			v.inc:SetPositionRel(v.dec:GetPositionRel() + Vector2(0.065, 0))
			
			v.quick:SetSizeRel(Vector2(self.window.button_size.x / 1.5, self.window.button_size.y))
			v.quick:SetTextSize(self.text_size)
			v.quick:SetPositionRel(v.inc:GetPositionRel() + Vector2(0.065, 0))
			
		end
	end
	
end

function Autopilot:WindowUpdate() -- Subscribed to Window Render

	for k,v in pairs(self.window.setting) do
		v.button:SetToggleState(config[k].on)
		if config[k].setting then
			v.label:SetText(tostringint(config[k].setting)..config[k].units)
			v.slider:SetValue(config[k].setting)		
		end
	end
		
end

function Autopilot:EnterPlane(args)
	
	if args.is_driver then
		local model = args.vehicle:GetModelId()
		if planes[model] and planes[model].available then
			self:APOff()
			self.panel_available = true
			self.vehicle = args.vehicle
			self.model = model
		end
	end
	
end

function Autopilot:ExitPlane(args)

	if self.panel_available then
		self:APOff()
		self.panel_available = false
		self.vehicle = nil
		self.model = nil
		self.window:SetVisible(false)
		Mouse:SetVisible(false)
	end

end

function Autopilot:PlaneDespawn(args)

	if args.entity.__type == "Vehicle" then
		if self.vehicle and self.vehicle == args.entity then
			self:APOff()
			self.panel_available = false
			self.vehicle = nil
			self.model = nil
			self.window:SetVisible(false)
			Mouse:SetVisible(false)
		end
	end

end

function Autopilot:RollHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.rh.on or not IsValid(self.vehicle) then return end	
	
	local roll = self.vehicle:GetRoll()
	
	local input = math.abs(roll - config.rh.setting) * config.rh.gain
	if input > config.rh.max_input then input = config.rh.max_input end
	
	if config.rh.setting < roll then
		Input:SetValue(Action.PlaneTurnRight, input)
	end
	
	if config.rh.setting > roll then
		Input:SetValue(Action.PlaneTurnLeft, input)
	end
	
end

function Autopilot:PitchHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.ph.on or not IsValid(self.vehicle) then return end
	
	local pitch = self.vehicle:GetPitch()
	local roll = self.vehicle:GetRoll()
	
	local input = math.abs(pitch - config.ph.setting) * config.ph.gain
	if input > config.ph.max_input then input = config.ph.max_input end
	
	-- Deactivates if the plane is banked too far left or right.
	
	if math.abs(roll) < 60 then
		if config.ph.setting > pitch then
			Input:SetValue(Action.PlanePitchUp, input)
		end
		
		if config.ph.setting < pitch then
			Input:SetValue(Action.PlanePitchDown, input)
		end
	end
	
	if math.abs(roll) > 120 then
		if config.ph.setting > pitch then
			Input:SetValue(Action.PlanePitchDown, input)
		end
		
		if config.ph.setting < pitch then
			Input:SetValue(Action.PlanePitchUp, input)
		end
	end
	
end

function Autopilot:HeadingHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.hh.on or not IsValid(self.vehicle) then return end
	
	local heading = self.vehicle:GetHeading()
	
	local diff = DegreesDifference(config.hh.setting, heading)
	
	config.rh.setting = diff * config.hh.gain
	
	if config.rh.setting > config.hh.roll_limit then
		config.rh.setting = config.hh.roll_limit
	elseif config.rh.setting < -config.hh.roll_limit then
		config.rh.setting = -config.hh.roll_limit
	end
	
end

function Autopilot:AltitudeHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.ah.on or not IsValid(self.vehicle) then return end
	
	config.ph.setting = (config.ah.setting - self.vehicle:GetAltitude() + config.ah.bias) * config.ah.gain
	
	if config.ph.setting > config.ah.pitch_limit then
		config.ph.setting = config.ah.pitch_limit
	elseif config.ph.setting < -config.ah.pitch_limit then
		config.ph.setting = -config.ah.pitch_limit
	end
	
end

function Autopilot:SpeedHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.sh.on or not IsValid(self.vehicle) then return end
		
	local air_speed = self.vehicle:GetAirSpeed()
	
	local input = math.abs(air_speed - config.sh.setting) * config.sh.gain
	if input > config.sh.max_input then input = config.sh.max_input end
	
	if air_speed < config.sh.setting and not config.oh.on then
		Input:SetValue(Action.PlaneIncTrust, input)
	end
	if air_speed > config.sh.setting then
		Input:SetValue(Action.PlaneDecTrust, input)
	end
	
end

function Autopilot:WaypointHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.wh.on or not IsValid(self.vehicle) then return end
	
	local waypoint, marker = Waypoint:GetPosition()
	
	if not marker then
		self:WHOff()
		return
	end
	
	self:FollowTargetXZ(waypoint)
	
end

function Autopilot:ApproachHold() -- Subscribed to Render

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.oh.on or not IsValid(self.vehicle) then return end
	
	if not self.approach and self.approach_timer:GetMilliseconds() > 1000 then
	
		local position = self.vehicle:GetPosition()
		local runway_name
		local runway_direction
		local airport_name
		local nearest_marker
		local nearest_marker_distance = math.huge
		
		for airport,runways in pairs(airports) do
			for runway in pairs(runways) do
			
				local near_marker = airports[airport][runway].near_marker
				local far_marker = airports[airport][runway].far_marker
				local distance = Vector3.Distance(position, near_marker)
					
				if distance < airports[airport][runway].glide_length and distance < nearest_marker_distance then
				
					local dy = near_marker.y - position.y
					
					local runway_cone_angle = airports[airport][runway].cone_angle
					local pitch_to_plane = math.deg(math.asin(-dy / distance))
					local pitch_from_runway = airports[airport][runway].glide_pitch
					local pitch_difference1 = DegreesDifference(pitch_to_plane, pitch_from_runway)
					
					if math.abs(pitch_difference1) < 0.5 * runway_cone_angle then
					
						local dx = near_marker.x - position.x
						local dz = near_marker.z - position.z

						local heading_to_plane = YawToHeading(math.deg(math.atan2(dx, dz)))
						local heading_from_runway = YawToHeading(math.deg(math.atan2(far_marker.x - near_marker.x, far_marker.z - near_marker.z)))
						local heading_difference1 = DegreesDifference(heading_to_plane, heading_from_runway)
									
						if math.abs(heading_difference1) < 0.5 * runway_cone_angle then
						
							local plane_cone_angle = planes[self.model].cone_angle
							local pitch_to_runway = math.deg(math.asin(dy / distance))
							local pitch_from_plane = self.vehicle:GetPitch()
							local pitch_difference2 = DegreesDifference(pitch_to_runway, pitch_from_plane)
							
							if math.abs(pitch_difference2) < 0.5 * plane_cone_angle then
						
								local heading_to_runway = YawToHeading(math.deg(math.atan2(-dx, -dz)))
								local heading_from_plane = self.vehicle:GetHeading()
								local heading_difference2 = DegreesDifference(heading_from_plane, heading_to_runway)
						
								if math.abs(heading_difference2) < 0.5 * plane_cone_angle then

									nearest_marker_distance = distance
									nearest_marker = near_marker
									airport_name = airport
									runway_name = runway
									runway_direction = heading_from_runway
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end	
		end
		
		if nearest_marker then
			self.scanning = nil
			self:HHOn()
			self:AHOn()
			self:SHOn()
			self.approach = {}
			Chat:Print("Approach to "..airport_name.." RWY"..runway_name.." set.", self.color[1])
			self.approach.near_marker = airports[airport_name][runway_name].near_marker
			self.approach.far_marker = airports[airport_name][runway_name].far_marker
			self.approach.angle = Angle(math.rad(HeadingToYaw(runway_direction)), math.rad(airports[airport_name][runway_name].glide_pitch), 0)
			self.approach.sweep_yaw = Angle(math.rad(airports[airport_name][runway_name].cone_angle / 2), 0, 0)
			self.approach.glide_length = airports[airport_name][runway_name].glide_length
			self.flare = nil
		end
		
		self.approach_timer:Restart()
	
	end
	
	if self.approach then

		local position = self.vehicle:GetPosition()
		
		if not self.flare then
			local distance = Vector3.Distance(self.approach.near_marker, position)
			if distance > planes[self.model].flare_distance then
				self.approach.farpoint = self.approach.near_marker + self.approach.angle * Vector3.Forward * distance
				config.ah.setting = self.approach.farpoint.y - 200 - config.ah.bias
				config.sh.setting = math.min(math.lerp(planes[self.model].landing_speed, planes[self.model].cruise_speed, distance / planes[self.model].slow_distance), planes[self.model].cruise_speed)
				self.approach.target = math.lerp(self.approach.near_marker, self.approach.farpoint, 0.5)
				self:FollowTargetXZ(self.approach.target)
			else
				self.flare = true
				self:AHOff()
				self:PHOn()
				self.approach.target = self.approach.far_marker
				config.ph.setting = planes[self.model].flare_pitch
				config.sh.setting = planes[self.model].landing_speed
			end
		else
			local distance = Vector3.Distance(self.approach.far_marker, position)
			local length = Vector3.Distance(self.approach.far_marker, self.approach.near_marker)
			config.sh.setting = math.min(math.lerp(0, planes[self.model].landing_speed, distance / length), planes[self.model].landing_speed)
			self:FollowTargetXZ(self.approach.target)
		end

		if self.draw_approach then
		
			Render:DrawLine(self.approach.near_marker, self.approach.near_marker + self.approach.angle * Vector3.Forward * self.approach.glide_length, self.color[1])
			Render:DrawLine(self.approach.near_marker, self.approach.near_marker + self.approach.angle * self.approach.sweep_yaw * Vector3.Forward * self.approach.glide_length, Color.Cyan)
			Render:DrawLine(self.approach.near_marker, self.approach.near_marker + self.approach.angle * -self.approach.sweep_yaw * Vector3.Forward * self.approach.glide_length, Color.Cyan)
			
		end
		
	end
	
end

function Autopilot:TargetHold() -- Subscribed to Render

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not config.th.on or not IsValid(self.vehicle) then return end
	
	if not self.target and self.target_timer:GetMilliseconds() > 1000 then
	
		local local_vehicle = LocalPlayer:GetVehicle()
		local local_position = LocalPlayer:GetPosition()
		local nearest_target = nil
		local nearest_target_distance = math.huge
		
		for vehicle in Client:GetVehicles() do
		
			if vehicle:GetDriver() and vehicle ~= local_vehicle then
		
				local model = vehicle:GetModelId()
				if planes[model] then
				
					local vehicle_position = vehicle:GetPosition()
					local vehicle_distance = Vector3.Distance(local_position, vehicle_position)
					
					if vehicle_distance < nearest_target_distance then

						local dy = vehicle_position.y - local_position.y
					
						local plane_cone_angle = planes[self.model].cone_angle
						local pitch_to_target = math.deg(math.asin(dy / vehicle_distance))
						local pitch_from_plane = self.vehicle:GetPitch()
						local pitch_difference = DegreesDifference(pitch_to_target, pitch_from_plane)
						
						if math.abs(pitch_difference) < 0.5 * plane_cone_angle then
						
							local dx = vehicle_position.x - local_position.x
							local dz = vehicle_position.z - local_position.z
					
							local heading_to_target = YawToHeading(math.deg(math.atan2(-dx, -dz)))
							local heading_from_plane = self.vehicle:GetHeading()
							local heading_difference = DegreesDifference(heading_from_plane, heading_to_target)
					
							if math.abs(heading_difference) < 0.5 * plane_cone_angle then

								nearest_target = vehicle
								nearest_target_distance = vehicle_distance
								
							end

						end
					end
					
				end
				
			end
			
		end
		
		if nearest_target then
			self.scanning = nil
			Chat:Print("Target acquired: "..tostring(nearest_target:GetDriver()), self.color[1])
			self.target = {}
			self.target.vehicle = nearest_target
			self.target.follow_distance = 100
			self:SHOn()
			self:HHOn()
			self:PHOn()
		end	
		
		self.target_timer:Restart()
	
	end
	
	if self.target then
	
		if not IsValid(self.target.vehicle) or not self.target.vehicle:GetDriver() then
			Chat:Print("Target lost.", self.color[1])
			self:THOff()
			return
		end
		
		local target_position = self.target.vehicle:GetPosition()
		local position = LocalPlayer:GetPosition()
		local distance = Vector3.Distance(target_position, position)
		local bias = distance / self.target.follow_distance
		
		config.sh.setting = math.clamp(bias * self.target.vehicle:GetLinearVelocity():Length() * 3.6, config.sh.min_setting, config.sh.max_setting)
		
		self:FollowTargetXZ(target_position)
		self:FollowTargetY(target_position)
		
		if self.draw_target then
		
			local name = self.target.vehicle:GetName()
			local model = self.target.vehicle:GetModelId()
			local center = Render:WorldToScreen(target_position + self.target.vehicle:GetAngle() * Vector3.Up * 2)
			
			local n = Render.Height * self.text_scale
			local m = 0.75 * n
			
			Render:DrawLine(center + Vector2(-n, -m), center + Vector2(-n,  m), self.color[1])
			Render:DrawLine(center + Vector2(-m,  n), center + Vector2( m,  n), self.color[1])
			Render:DrawLine(center + Vector2( n,  m), center + Vector2( n, -m), self.color[1])
			Render:DrawLine(center + Vector2( m, -n), center + Vector2(-m, -n), self.color[1])
			
			Render:DrawText(center + Vector2(n * 1.25, -0.3 * Render:GetTextHeight(tostring(distance), 1.2 * self.text_size)), tostringint(distance).." m", self.color[1], 1.2 * self.text_size)
			
		end
		
	end

end

function Autopilot:FollowTargetXZ(target_position) -- Heading-hold must be on

	local position = self.vehicle:GetPosition()
	local dx = position.x - target_position.x
	local dz = position.z - target_position.z
	
	config.hh.setting = YawToHeading(math.deg(math.atan2(dx, dz)))

end

function Autopilot:FollowTargetY(target_position) -- Pitch-hold must be on

	local position = self.vehicle:GetPosition()
	local dy = position.y - target_position.y
	local distance = Vector3.Distance(position, target_position)
	
	config.ph.setting = math.deg(math.asin(-dy / distance))

end

Autopilot = Autopilot()
