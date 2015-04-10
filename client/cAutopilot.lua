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
				
	self.panel_available = false -- Whether you are in a plane with autopilot available
	self.panel_open = false -- Whether the autopilot panel is open
	
	self.one_key = true -- If true then Z toggles both the panel and mouse
	self.panel_toggle_button = "Z"
	self.mouse_toggle_button = "M"
	
	self.screen_height = Render.Height
	self.screen_width = Render.Width
	self.text_scale = 0.03
	
	self.window_position = Vector2(0.65, 0.05)
	self.window_size = Vector2(0.3, 0.26)
	self.window_button_size = Vector2(0.3, 0.11)
	self.window_button_position = Vector2(0, 0.12)
	self.window_label_size = Vector2(0.25, 0.12)
	self.window_slider_size = Vector2(0.28, 0.12) --0.28 0.12
	
	self.window = Window.Create()
	self.window:SetVisible(self.panel_open)
	self.window:SetTitle("Autopilot Panel")
	self.window:SetClosable(false)
	
	self.window:SetSizeRel(self.window_size)
	self.window:SetPositionRel(self.window_position)
	
	self.window.ap_button = Button.Create(self.window)
	self.window.rh_button = Button.Create(self.window)
	self.window.ph_button = Button.Create(self.window)
	self.window.hh_button = Button.Create(self.window)
	self.window.ah_button = Button.Create(self.window)
	self.window.sh_button = Button.Create(self.window)
	self.window.wh_button = Button.Create(self.window)
	
	self.window.ap_button:SetText(self.config.ap.name)
	self.window.rh_button:SetText(self.config.rh.name)
	self.window.ph_button:SetText(self.config.ph.name)
	self.window.hh_button:SetText(self.config.hh.name)
	self.window.ah_button:SetText(self.config.ah.name)
	self.window.sh_button:SetText(self.config.sh.name)
	self.window.wh_button:SetText(self.config.wh.name)
	
	self.window.ap_button:SetToggleable(true)
	self.window.rh_button:SetToggleable(true)
	self.window.ph_button:SetToggleable(true)
	self.window.hh_button:SetToggleable(true)
	self.window.ah_button:SetToggleable(true)
	self.window.sh_button:SetToggleable(true)
	self.window.wh_button:SetToggleable(true)
	
	self.window.rh_label = Label.Create(self.window)
	self.window.ph_label = Label.Create(self.window)
	self.window.hh_label = Label.Create(self.window)
	self.window.ah_label = Label.Create(self.window)
	self.window.sh_label = Label.Create(self.window)
	
	self.window.rh_slider = HorizontalSlider.Create(self.window)
	self.window.ph_slider = HorizontalSlider.Create(self.window)
	self.window.hh_slider = HorizontalSlider.Create(self.window)
	self.window.ah_slider = HorizontalSlider.Create(self.window)
	self.window.sh_slider = HorizontalSlider.Create(self.window)
	
	self.window.rh_slider:SetRange(self.config.rh.min_setting, self.config.rh.max_setting)
	self.window.ph_slider:SetRange(self.config.ph.min_setting, self.config.ph.max_setting)
	self.window.hh_slider:SetRange(self.config.hh.min_setting, self.config.hh.max_setting)
	self.window.ah_slider:SetRange(self.config.ah.min_setting, self.config.ah.max_setting)
	self.window.sh_slider:SetRange(self.config.sh.min_setting, self.config.sh.max_setting)
	
	self.window.ah_slider:SetClampToNotches(true)
	self.window.sh_slider:SetClampToNotches(true)
	
	self.window.ah_slider:SetNotchCount((self.config.ah.max_setting-self.config.ah.min_setting)/self.config.ah.step)
	self.window.sh_slider:SetNotchCount((self.config.sh.max_setting-self.config.sh.min_setting)/self.config.sh.step)
	
	self.window.rh_inc = Button.Create(self.window)
	self.window.ph_inc = Button.Create(self.window)
	self.window.hh_inc = Button.Create(self.window)
	self.window.ah_inc = Button.Create(self.window)
	self.window.sh_inc = Button.Create(self.window)
	
	self.window.rh_inc:SetText("+")
	self.window.ph_inc:SetText("+")
	self.window.hh_inc:SetText("+")
	self.window.ah_inc:SetText("+")
	self.window.sh_inc:SetText("+")
	
	self.window.rh_dec = Button.Create(self.window)
	self.window.ph_dec = Button.Create(self.window)
	self.window.hh_dec = Button.Create(self.window)
	self.window.ah_dec = Button.Create(self.window)
	self.window.sh_dec = Button.Create(self.window)
	
	self.window.rh_dec:SetText("-")
	self.window.ph_dec:SetText("-")
	self.window.hh_dec:SetText("-")
	self.window.ah_dec:SetText("-")
	self.window.sh_dec:SetText("-")
	
	self.window.ap_button:Subscribe("ToggleOn", self, self.APButtonOn)
	self.window.rh_button:Subscribe("ToggleOn", self, self.RHButtonOn)
	self.window.ph_button:Subscribe("ToggleOn", self, self.PHButtonOn)
	self.window.hh_button:Subscribe("ToggleOn", self, self.HHButtonOn)
	self.window.ah_button:Subscribe("ToggleOn", self, self.AHButtonOn)
	self.window.sh_button:Subscribe("ToggleOn", self, self.SHButtonOn)
	self.window.wh_button:Subscribe("ToggleOn", self, self.WHButtonOn)
	
	self.window.ap_button:Subscribe("ToggleOff", self, self.APButtonOff)
	self.window.rh_button:Subscribe("ToggleOff", self, self.RHButtonOff)
	self.window.ph_button:Subscribe("ToggleOff", self, self.PHButtonOff)
	self.window.hh_button:Subscribe("ToggleOff", self, self.HHButtonOff)
	self.window.ah_button:Subscribe("ToggleOff", self, self.AHButtonOff)
	self.window.sh_button:Subscribe("ToggleOff", self, self.SHButtonOff)
	self.window.wh_button:Subscribe("ToggleOff", self, self.WHButtonOff)
	
	self.window.rh_slider:Subscribe("ValueChanged", self, self.RHSlider)
	self.window.ph_slider:Subscribe("ValueChanged", self, self.PHSlider)
	self.window.hh_slider:Subscribe("ValueChanged", self, self.HHSlider)
	self.window.ah_slider:Subscribe("ValueChanged", self, self.AHSlider)
	self.window.sh_slider:Subscribe("ValueChanged", self, self.SHSlider)
	
	self.window.rh_inc:Subscribe("Press", self, self.RHIncrease)
	self.window.ph_inc:Subscribe("Press", self, self.PHIncrease)
	self.window.hh_inc:Subscribe("Press", self, self.HHIncrease)
	self.window.ah_inc:Subscribe("Press", self, self.AHIncrease)
	self.window.sh_inc:Subscribe("Press", self, self.SHIncrease)
	
	self.window.rh_dec:Subscribe("Press", self, self.RHDecrease)
	self.window.ph_dec:Subscribe("Press", self, self.PHDecrease)
	self.window.hh_dec:Subscribe("Press", self, self.HHDecrease)
	self.window.ah_dec:Subscribe("Press", self, self.AHDecrease)
	self.window.sh_dec:Subscribe("Press", self, self.SHDecrease)
	
	self.window:Subscribe("Render", self, self.ButtonRender)
	self.window:Subscribe("Render", self, self.LabelRender)
	self.window:Subscribe("Render", self, self.SliderRender)
	
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
	if Mouse:GetVisible() then
		if args.input == 3 or args.input == 4 or args.input == 5 or args.input == 6 or args.input == 138 or args.input == 139 then
			return false
		end
	end	
end

function Autopilot:WindowResize() -- Subscribed to ResolutionChange
	self.window:SetSizeRel(self.window_size)
	self.window:SetPositionRel(self.window_position)
end
	
function Autopilot:ButtonRender() -- Subscribed to Window Render

	self.text_size = self.window:GetSize():Length() * self.text_scale
	
	self.window.ap_button:SetToggleState(self.config.ap.on)
	self.window.rh_button:SetToggleState(self.config.rh.on)
	self.window.ph_button:SetToggleState(self.config.ph.on)
	self.window.hh_button:SetToggleState(self.config.hh.on)
	self.window.ah_button:SetToggleState(self.config.ah.on)
	self.window.sh_button:SetToggleState(self.config.sh.on)
	self.window.wh_button:SetToggleState(self.config.wh.on)

	self.window.ap_button:SetSizeRel(self.window_button_size)
	self.window.ap_button:SetTextSize(self.text_size)
	self.window.ap_button:SetPositionRel(self.window_button_position * 0)
	
	self.window.rh_button:SetText(self.config.rh.name)
	self.window.rh_button:SetSizeRel(self.window_button_size)
	self.window.rh_button:SetTextSize(self.text_size)
	self.window.rh_button:SetPositionRel(self.window_button_position * 1)
	
	self.window.ph_button:SetText(self.config.ph.name)
	self.window.ph_button:SetSizeRel(self.window_button_size)
	self.window.ph_button:SetTextSize(self.text_size)
	self.window.ph_button:SetPositionRel(self.window_button_position * 2)
	
	self.window.hh_button:SetText(self.config.hh.name)
	self.window.hh_button:SetSizeRel(self.window_button_size)
	self.window.hh_button:SetTextSize(self.text_size)
	self.window.hh_button:SetPositionRel(self.window_button_position * 3)
	
	self.window.ah_button:SetText(self.config.ah.name)
	self.window.ah_button:SetSizeRel(self.window_button_size)
	self.window.ah_button:SetTextSize(self.text_size)
	self.window.ah_button:SetPositionRel(self.window_button_position * 4)
	
	self.window.sh_button:SetText(self.config.sh.name)
	self.window.sh_button:SetSizeRel(self.window_button_size)
	self.window.sh_button:SetTextSize(self.text_size)
	self.window.sh_button:SetPositionRel(self.window_button_position * 5)
	
	self.window.wh_button:SetText(self.config.wh.name)
	self.window.wh_button:SetSizeRel(self.window_button_size)
	self.window.wh_button:SetTextSize(self.text_size)
	self.window.wh_button:SetPositionRel(self.window_button_position * 6)
	
	self.window.rh_dec:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.rh_dec:SetTextSize(self.text_size)
	self.window.rh_dec:SetPositionRel(self.window.rh_button:GetPositionRel() + Vector2(0.77, 0))
	
	self.window.ph_dec:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.ph_dec:SetTextSize(self.text_size)
	self.window.ph_dec:SetPositionRel(self.window.ph_button:GetPositionRel() + Vector2(0.77, 0))
	
	self.window.hh_dec:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.hh_dec:SetTextSize(self.text_size)
	self.window.hh_dec:SetPositionRel(self.window.hh_button:GetPositionRel() + Vector2(0.77, 0))
	
	self.window.ah_dec:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.ah_dec:SetTextSize(self.text_size)
	self.window.ah_dec:SetPositionRel(self.window.ah_button:GetPositionRel() + Vector2(0.77, 0))
	
	self.window.sh_dec:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.sh_dec:SetTextSize(self.text_size)
	self.window.sh_dec:SetPositionRel(self.window.sh_button:GetPositionRel() + Vector2(0.77, 0))
	
	self.window.rh_inc:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.rh_inc:SetTextSize(self.text_size)
	self.window.rh_inc:SetPositionRel(self.window.rh_button:GetPositionRel() + Vector2(0.87, 0))
	
	self.window.ph_inc:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.ph_inc:SetTextSize(self.text_size)
	self.window.ph_inc:SetPositionRel(self.window.ph_button:GetPositionRel() + Vector2(0.87, 0))
	
	self.window.hh_inc:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.hh_inc:SetTextSize(self.text_size)
	self.window.hh_inc:SetPositionRel(self.window.hh_button:GetPositionRel() + Vector2(0.87, 0))
	
	self.window.ah_inc:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.ah_inc:SetTextSize(self.text_size)
	self.window.ah_inc:SetPositionRel(self.window.ah_button:GetPositionRel() + Vector2(0.87, 0))
	
	self.window.sh_inc:SetSizeRel(self.window_button_size - Vector2(0.2, 0))
	self.window.sh_inc:SetTextSize(self.text_size)
	self.window.sh_inc:SetPositionRel(self.window.sh_button:GetPositionRel() + Vector2(0.87, 0))
end

function Autopilot:LabelRender() -- Subscribed to Window Render

	self.window.rh_label:SetText(tostringint(self.config.rh.setting)..self.config.rh.units)
	self.window.ph_label:SetText(tostringint(self.config.ph.setting)..self.config.ph.units)
	self.window.hh_label:SetText(tostringint(self.config.hh.setting)..self.config.hh.units)
	self.window.ah_label:SetText(tostringint(self.config.ah.setting)..self.config.ah.units)
	self.window.sh_label:SetText(tostringint(self.config.sh.setting)..self.config.sh.units)

	self.window.rh_label:SetSizeRel(self.window_label_size)
	self.window.rh_label:SetTextSize(self.text_size)
	self.window.rh_label:SetPositionRel(self.window.rh_button:GetPositionRel() + Vector2(self.window.rh_button:GetWidthRel() * 1.1, self.window.rh_button:GetHeightRel() * 0.32))
	
	self.window.ph_label:SetSizeRel(self.window_label_size)
	self.window.ph_label:SetTextSize(self.text_size)
	self.window.ph_label:SetPositionRel(self.window.ph_button:GetPositionRel() + Vector2(self.window.ph_button:GetWidthRel() * 1.1, self.window.ph_button:GetHeightRel() * 0.32))
	
	self.window.hh_label:SetSizeRel(self.window_label_size)
	self.window.hh_label:SetTextSize(self.text_size)
	self.window.hh_label:SetPositionRel(self.window.hh_button:GetPositionRel() + Vector2(self.window.hh_button:GetWidthRel() * 1.1, self.window.hh_button:GetHeightRel() * 0.32))
	
	self.window.ah_label:SetSizeRel(self.window_label_size)
	self.window.ah_label:SetTextSize(self.text_size)
	self.window.ah_label:SetPositionRel(self.window.ah_button:GetPositionRel() + Vector2(self.window.ah_button:GetWidthRel() * 1.1, self.window.ah_button:GetHeightRel() * 0.32))
	
	self.window.sh_label:SetSizeRel(self.window_label_size)
	self.window.sh_label:SetTextSize(self.text_size)
	self.window.sh_label:SetPositionRel(self.window.sh_button:GetPositionRel() + Vector2(self.window.sh_button:GetWidthRel() * 1.1, self.window.sh_button:GetHeightRel() * 0.32))

end

function Autopilot:SliderRender() -- Subscribed to Window Render

	self.window.rh_slider:SetValue(self.config.rh.setting)
	self.window.rh_slider:SetSizeRel(self.window_slider_size)
	self.window.rh_slider:SetPositionRel(self.window.rh_button:GetPositionRel() + Vector2(self.window.rh_button:GetWidthRel() * 1.6, 0))
	
	self.window.ph_slider:SetValue(self.config.ph.setting)	
	self.window.ph_slider:SetSizeRel(self.window_slider_size)
	self.window.ph_slider:SetPositionRel(self.window.ph_button:GetPositionRel() + Vector2(self.window.ph_button:GetWidthRel() * 1.6, 0))
	
	self.window.hh_slider:SetValue(self.config.hh.setting)
	self.window.hh_slider:SetSizeRel(self.window_slider_size)
	self.window.hh_slider:SetPositionRel(self.window.hh_button:GetPositionRel() + Vector2(self.window.hh_button:GetWidthRel() * 1.6, 0))
	
	self.window.ah_slider:SetValue(self.config.ah.setting)
	self.window.ah_slider:SetSizeRel(self.window_slider_size)
	self.window.ah_slider:SetPositionRel(self.window.ah_button:GetPositionRel() + Vector2(self.window.ah_button:GetWidthRel() * 1.6, 0))
	
	self.window.sh_slider:SetValue(self.config.sh.setting)
	self.window.sh_slider:SetSizeRel(self.window_slider_size)
	self.window.sh_slider:SetPositionRel(self.window.sh_button:GetPositionRel() + Vector2(self.window.sh_button:GetWidthRel() * 1.6, 0))

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

	if LocalPlayer:InVehicle() and LocalPlayer == LocalPlayer:GetVehicle():GetDriver() and self.plane[LocalPlayer:GetVehicle():GetModelId()] then
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
		for i,k in ipairs(self.config.wh.uses) do
			self.config[k].on = false
		end
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
