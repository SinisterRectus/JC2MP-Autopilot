-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'Autopilot'

function Autopilot:__init()
			
	self.config = { 
		["ap"] = {
			["name"] = "Autopilot",
			["on"] = false
		},
		["rh"] = {
			["name"] = "Roll",
			["on"] = false,
			["setting"] = 0,
			["units"] = "°",
			["min_setting"] = -60, -- Do not set less than -180
			["max_setting"] = 60, -- Do not set greater than 180
			["gain"] = 0.20, -- 0.20 default
			["max_input"] = 0.7, -- Percentage from 0 to 1
			["quick"] = "Zero"
		},
		["ph"] = {			
			["name"] = "Pitch",
			["on"] = false,
			["setting"] = 0,
			["units"] = "°",
			["min_setting"] = -60, -- Do not set less than -90
			["max_setting"] = 60, -- Do not set greater than 90
			["gain"] = 0.50, -- 0.50 default
			["max_input"] = 0.8, -- Percentage from 0 to 1
			["quick"] = "Zero"
		},
		["hh"] = {			
			["name"] = "Heading",
			["on"] = false,
			["setting"] = 0,
			["units"] = "°",
			["min_setting"] = 0, -- Do not change
			["max_setting"] = 360, -- Do not change
			["gain"] = 2.00, -- 2.00 default
			["roll_limit"] = 45, -- Maximum roll angle while HH is active, 30 to 60 recommended
			["quick"] = "Lock"
		},
		["ah"] = {
			["name"] = "Altitude",
			["on"] = false,
			["setting"] = 0,
			["units"] = " m",
			["min_setting"] = 0, -- Do not set less than 0
			["max_setting"] = 5000, -- Planes do not maneuver properly above 5000 m
			["gain"] = 0.30, -- 0.30 default
			["pitch_limit"] = 45, -- Maximum pitch angle while AH is active, 30 to 60 recommended
			["bias"] = 5, -- Correction for gravity
			["step"] = 50, -- Step size for changing setting
			["quick"] = "Lock"
		},
		["sh"] = {
			["name"] = "Speed",
			["on"] = false,
			["setting"] = 0,
			["units"] = " km/h",
			["min_setting"] = 0, -- Do not set less than 0
			["max_setting"] = 500, -- Planes rarely exceed 500 km/h without server functions
			["gain"] = 0.04, -- 0.04 default
			["max_input"] = 1, -- Percentage from 0 to 1, needs to be exactly 1 for take-off
			["step"] = 5, -- Step size for changing setting
			["quick"] = "Cruise"
		},
		["wh"] = {
			["name"] = "Waypoint",
			["on"] = false
		},
		["oh"] = {
			["name"] = "Approach",
			["on"] = false
		},
		["th"] = {
			["name"] = "Target",
			["on"] = false
		}
	}
	
	self.planes = {
		[24] = { -- F-33 DragonFly
			["available"] = true,
			["landing_speed"] = 160,
			["cruise_speed"] = 296,
			["max_speed"] = 406,
			["slow_distance"] = 1000,
			["flare_distance"] = 50,
			["flare_pitch"] = 3,
			["cone_angle"] = 90
		},
		[30] = { -- Si-47 Leopard
			["available"] = true,
			["landing_speed"] = 160,
			["cruise_speed"] = 277,
			["max_speed"] = 340,
			["slow_distance"] = 1000,
			["flare_distance"] = 100,
			["flare_pitch"] = 3,
			["cone_angle"] = 90
		},
		[34] = { -- G9 Eclipse
			["available"] = true,
			["landing_speed"] = 190,
			["cruise_speed"] = 341,
			["max_speed"] = 401,
			["slow_distance"] = 1500,
			["flare_distance"] = 150,
			["flare_pitch"] = 3,
			["cone_angle"] = 75
		},
		[39] = { -- Aeroliner 474
			["available"] = true,
			["landing_speed"] = 180,
			["cruise_speed"] = 324,
			["max_speed"] = 352,
			["slow_distance"] = 1000,
			["flare_distance"] = 100,
			["flare_pitch"] = -1,
			["cone_angle"] = 60
		},
		[51] = { -- Cassius 192
			["available"] = true,
			["landing_speed"] = 120,
			["cruise_speed"] = 250,
			["max_speed"] = 314,
			["slow_distance"] = 1000,
			["flare_distance"] = 100,
			["flare_pitch"] = 3,
			["cone_angle"] = 75
		},
		[59] = { -- Peek Airhawk 225
			["available"] = true,
			["landing_speed"] = 130,
			["cruise_speed"] = 207,
			["max_speed"] = 242,
			["slow_distance"] = 1000,
			["flare_distance"] = 20,
			["flare_pitch"] = 0,
			["cone_angle"] = 90
		},
		[81] = { -- Pell Silverbolt 6
			["available"] = true,
			["landing_speed"] = 150,
			["cruise_speed"] = 262,
			["max_speed"] = 343,
			["slow_distance"] = 1000,
			["flare_distance"] = 20,
			["flare_pitch"] = 3,
			["cone_angle"] = 90
		},
		[85] = { -- Bering I-86DP
			["available"] = true,
			["landing_speed"] = 180,
			["cruise_speed"] = 313,
			["max_speed"] = 339,
			["slow_distance"] = 1000,
			["flare_distance"] = 200,
			["flare_pitch"] = 3,
			["cone_angle"] = 60
		}
	}
	
	self.airports = {
		["PIA"] = {
			["27"] = {
				["near_marker"] = Vector3(-5842.51, 208.97, -3009.23),
				["far_marker"] = Vector3(-6816.68, 208.97, -2994.51),				
				["glide_length"] = 4000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["09"] = {
				["near_marker"] = Vector3(-6816.68, 208.97, -2994.51),
				["far_marker"] = Vector3(-5842.51, 208.97, -3009.23),
				["glide_length"] = 1500,
				["glide_pitch"] = 5,
				["cone_angle"] = 5
			},
			["05"] = {
				["near_marker"] = Vector3(-6398.21, 208.90, -3176.93),
				["far_marker"] = Vector3(-5998.58, 208.90, -3576.45),
				["glide_length"] = 2500,
				["glide_pitch"] = 5,
				["cone_angle"] = 5
			},
			["23"] = {
				["near_marker"] = Vector3(-5998.58, 208.90, -3576.45),
				["far_marker"] = Vector3(-6398.21, 208.90, -3176.93),
				["glide_length"] = 3000,
				["glide_pitch"] = 3,
				["cone_angle"] = 10
			}
		},
		["Kem Sungai Sejuk"] = {
			["04"] = {
				["near_marker"] = Vector3(601.69, 298.84, -3937.16),
				["far_marker"] = Vector3(882.20, 298.84, -4246.67),
				["glide_length"] = 5000,
				["glide_pitch"] = 4,
				["cone_angle"] = 10
			}
		},
		["Pulau Dayang Terlena"] = {
			["03L"] = {
				["near_marker"] = Vector3(-12238.39, 610.94, 4664.57),
				["far_marker"] = Vector3(-11970.58, 610.94, 4162.33),
				["glide_length"] = 5000,
				["glide_pitch"] = 6,
				["cone_angle"] = 10
			},
			["21R"] = {
				["near_marker"] = Vector3(-11970.58, 610.94, 4162.33),
				["far_marker"] = Vector3(-12238.39, 610.94, 4664.57),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 10
			},
			["03R"] = {
				["near_marker"] = Vector3(-12101.96, 611.10, 4737.54),
				["far_marker"] = Vector3(-11834.03, 611.10, 4236.06),
				["glide_length"] = 5000,
				["glide_pitch"] = 6,
				["cone_angle"] = 10
			},
			["21L"] = {
				["near_marker"] = Vector3(-11834.03, 611.10, 4236.06),
				["far_marker"] = Vector3(-12101.96, 611.10, 4737.54),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 10
			},
			["12"] = {
				["near_marker"] = Vector3(-12196.25, 611.22, 4874.13),
				["far_marker"] = Vector3(-11693.96, 611.22, 5142.52),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["30"] = {
				["near_marker"] = Vector3(-11693.96, 611.22, 5142.52),
				["far_marker"] = Vector3(-12196.25, 611.22, 4874.13),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
		},
		["Kem Jalan Merpati"] = {
			["30"] = {
				["near_marker"] = Vector3(-6643.80, 1050.34, 11950.66),
				["far_marker"] = Vector3(-7131.25, 1050.34, 11658.72),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}
		},
		["Kem Udara Wau Pantas"] = {
			["27"] = {
				["near_marker"] = Vector3(6140.61, 251.00, 7158.83),
				["far_marker"] = Vector3(5573.50, 251.00, 7158.61),				
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["09"] = {
				["near_marker"] = Vector3(5573.50, 251.00, 7158.61),
				["far_marker"] = Vector3(6140.61, 251.00, 7158.83),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["36"] = {
				["near_marker"] = Vector3(6044.50, 251.00, 6996.85),
				["far_marker"] = Vector3(6044.50, 251.00, 6428.61),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["18"] = {
				["near_marker"] = Vector3(6044.50, 251.00, 6428.61),
				["far_marker"] = Vector3(6044.50, 251.00, 6996.85),
				["glide_length"] = 1500,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}		
		},
		["Pulau Dongeng"] = {
			["12"] = {
				["near_marker"] = Vector3(5696.48, 264.18, 10363.78),
				["far_marker"] = Vector3(5863.38, 264.18, 10460.01),
				["glide_length"] = 2000,
				["glide_pitch"] = 4,
				["cone_angle"] = 15
			}
		},
		["Tanah Lebar"] = {
			["28R"] = {
				["near_marker"] = Vector3(-160.40, 295.36, 7089.45),
				["far_marker"] = Vector3(-351.18, 295.36, 7060.66),
				["glide_length"] = 5000,
				["glide_pitch"] = 6,
				["cone_angle"] = 6
			},
			["28L"] = {
				["near_marker"] = Vector3(-169.66, 295.35, 7148.39),
				["far_marker"] = Vector3(-358.35, 295.35, 7119.41),
				["glide_length"] = 5000,
				["glide_pitch"] = 6,
				["cone_angle"] = 6
			}
		},
		["Kampung Tujuh Telaga"] = {
			["14"] = {
				["near_marker"] = Vector3(595.28, 207.06, -98.16),
				["far_marker"] = Vector3(748.07, 208.15, 58.73),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}
		},
		["Teluk Permata"] = {
			["14"] = {
				["near_marker"] = Vector3(-7123.66, 207.01, -10822.38),
				["far_marker"] = Vector3(-6837.64, 207.01, -10636.57),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}
		},
		["Banjaran Gundin"] = {
			["23"] = {
				["near_marker"] = Vector3(-4610.55, 405.64, -11649.26),
				["far_marker"] = Vector3(-5012.30, 405.64, -11247.39),
				["glide_length"] = 5000,
				["glide_pitch"] = 5,
				["cone_angle"] = 15
			},
			["45"] = {
				["near_marker"] = Vector3(-5012.30, 405.64, -11247.39),
				["far_marker"] = Vector3(-4610.55, 405.64, -11649.26),
				["glide_length"] = 5000,
				["glide_pitch"] = 5,
				["cone_angle"] = 12
			}
		},
		["Sungai Cengkih Besar"] = {
			["20"] = {
				["near_marker"] = Vector3(4706.35, 208.40, -10989.74),
				["far_marker"] = Vector3(4477.04, 208.40, -10467.98),				
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["29"] = {
				["near_marker"] = Vector3(4667.72, 208.44, -10624.48),
				["far_marker"] = Vector3(4147.00, 208.44, -10853.32),				
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["11"] = {
				["near_marker"] = Vector3(4147.00, 208.44, -10853.32),
				["far_marker"] = Vector3(4667.72, 208.44, -10624.48),				
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}
		},
		["Paya Luas"] = {
			["27"] = {
				["near_marker"] = Vector3(12011.65, 206.88, -10715.07),
				["far_marker"] = Vector3(11440.75, 206.88, -10715.09),				
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["09"] = {
				["near_marker"] = Vector3(11440.75, 206.88, -10715.09),
				["far_marker"] = Vector3(12011.65, 206.88, -10715.07),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["36"] = {
				["near_marker"] = Vector3(12171.29, 206.88, -10243.73),
				["far_marker"] = Vector3(12171.29, 206.88, -10812.65),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["18"] = {
				["near_marker"] = Vector3(12171.26, 206.88, -10812.65),
				["far_marker"] = Vector3(12171.26, 206.88, -10243.73),
				["glide_length"] = 1500,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}			
		},
		["Lemabah Delima"] = {
			["13"] = {
				["near_marker"] = Vector3(9460.27, 204.78, 3661.23),
				["far_marker"] = Vector3(9890.33, 204.78, 4031.97),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			},
			["31"] = {
				["near_marker"] = Vector3(9890.33, 204.78, 4032.38),
				["far_marker"] = Vector3(9460.27, 204.78, 3661.23),
				["glide_length"] = 5000,
				["glide_pitch"] = 3,
				["cone_angle"] = 15
			}
		}
	}
	
	self.panel_available = false -- Whether you are in a plane with autopilot available
	
	if LocalPlayer:InVehicle() then
		local vehicle = LocalPlayer:GetVehicle()
		local model = vehicle:GetModelId()
		if self.planes[model] then
			if self.planes[model].available then
				self.panel_available = true
				self.vehicle = vehicle
				self.model = model
			end
		end
	end

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
	Events:Subscribe("InputPoll", self, self.ApproachHold)
	Events:Subscribe("InputPoll", self, self.TargetHold)
	
end

function Autopilot:InitGUI()

	self.window = Window.Create()
	
	self.two_keys = false -- If false then Z toggles both the panel and mouse
	self.panel_toggle_button = "Z"
	self.mouse_toggle_button = "M"
	
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
	
	self.break_line = Button.Create(self.window)
		
	for k,v in pairs(self.window.setting) do
	
		v.button = Button.Create(self.window)
		v.button:SetText(self.config[k].name)
		v.button:SetToggleable(true)
		v.button:SetTextPressedColor(Color.Orange)
		
		if self.config[k].setting then
			v.label = Label.Create(self.window)
			v.slider = HorizontalSlider.Create(self.window)
			v.slider:SetRange(self.config[k].min_setting, self.config[k].max_setting)
			
			if self.config[k].step then
				v.slider:SetClampToNotches(true)
				v.slider:SetNotchCount((self.config[k].max_setting-self.config[k].min_setting)/self.config[k].step)
			end
			
			v.inc = Button.Create(self.window)
			v.dec = Button.Create(self.window)
			v.inc:SetText("+")
			v.dec:SetText("-")
			
			v.quick = Button.Create(self.window)
			v.quick:SetText(self.config[k].quick)
			
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

function Autopilot:RHQuick(args)
	self.config.rh.setting = 0
	self:RHOn()
end

function Autopilot:PHQuick(args)
	self.config.ph.setting = 0
	self:PHOn()
end

function Autopilot:HHQuick(args)
	self.config.hh.setting = self:GetHeading()
	self:HHOn()
end

function Autopilot:AHQuick(args)
	self.config.ah.setting = self:GetAltitude()
	self:AHOn()
end

function Autopilot:SHQuick(args)
	self.config.sh.setting = self.planes[self.model].cruise_speed
	self:SHOn()
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
	if self.config.hh.setting == 360 then
		self.config.hh.setting = 1
	elseif self.config.hh.setting < self.config.hh.max_setting then
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
	if self.config.hh.setting == 0 then
		self.config.hh.setting = 359
	elseif self.config.hh.setting > self.config.hh.min_setting then
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

function Autopilot:APOn()
	self.config.ap.on = true
end

function Autopilot:RHOn()
	self:APOn()
	self.config.rh.on = true
end

function Autopilot:PHOn()
	self:APOn()
	self.config.ph.on = true
end

function Autopilot:HHOn()
	self:RHOn()
	self.config.hh.on = true
end

function Autopilot:AHOn()
	self:PHOn()
	self.config.ah.on = true
end

function Autopilot:SHOn()
	self:APOn()
	self.config.sh.on = true
end

function Autopilot:WHOn()
	local waypoint, marker = Waypoint:GetPosition()
	if marker then
		self:OHOff()
		self:THOff()
		self:HHOn()
		self.config.wh.on = true
	else
		Chat:Print("Waypoint not set.", Color.Silver)
	end
end

function Autopilot:OHOn()

	local position = self.vehicle:GetPosition()
	local runway_name
	local runway_direction
	local airport_name
	local nearest_marker
	local nearest_marker_distance = math.huge
	
	for airport,runways in pairs(self.airports) do
		for runway in pairs(runways) do
		
			local near_marker = self.airports[airport][runway].near_marker
			local far_marker = self.airports[airport][runway].far_marker
			local distance = Vector3.Distance(position, near_marker)
				
			if distance < self.airports[airport][runway].glide_length and distance < nearest_marker_distance then
			
				local dy = near_marker.y - position.y
				
				local runway_cone_angle = self.airports[airport][runway].cone_angle
				local pitch_to_plane = math.deg(math.asin(-dy / distance))
				local pitch_from_runway = self.airports[airport][runway].glide_pitch
				local pitch_difference1 = self:DegreesDifference(pitch_to_plane, pitch_from_runway)
				
				if math.abs(pitch_difference1) < 0.5 * runway_cone_angle then
				
					local dx = near_marker.x - position.x
					local dz = near_marker.z - position.z

					local heading_to_plane = self:YawToHeading(math.deg(math.atan2(dx, dz)))
					local heading_from_runway = self:YawToHeading(math.deg(math.atan2(far_marker.x - near_marker.x, far_marker.z - near_marker.z)))
					local heading_difference1 = self:DegreesDifference(heading_to_plane, heading_from_runway)
								
					if math.abs(heading_difference1) < 0.5 * runway_cone_angle then
					
						local plane_cone_angle = self.planes[self.model].cone_angle
						local pitch_to_runway = math.deg(math.asin(dy / distance))
						local pitch_from_plane = self:GetPitch()
						local pitch_difference2 = self:DegreesDifference(pitch_to_runway, pitch_from_plane)
						
						if math.abs(pitch_difference2) < 0.5 * plane_cone_angle then
					
							local heading_to_runway = self:YawToHeading(math.deg(math.atan2(-dx, -dz)))
							local heading_from_plane = self:GetHeading()
							local heading_difference2 = self:DegreesDifference(heading_from_plane, heading_to_runway)
					
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
		self.approach = {}
		Chat:Print("Approach to "..airport_name.." RWY"..runway_name.." set.", Color.Orange)
		self.approach.near_marker = self.airports[airport_name][runway_name].near_marker
		self.approach.far_marker = self.airports[airport_name][runway_name].far_marker
		self.approach.angle = Angle(math.rad(self:HeadingToYaw(runway_direction)), math.rad(self.airports[airport_name][runway_name].glide_pitch), 0)
		self:WHOff()
		self:HHOn()
		self:AHOn()
		self:SHOn()
		self.config.oh.on = true
		self.flare = false
	else
		Chat:Print("You are not approaching a runway.", Color.Silver)
	end
	
end

function Autopilot:THOn()

	local local_vehicle = LocalPlayer:GetVehicle()
	local local_position = LocalPlayer:GetPosition()
	local nearest_target = nil
	local nearest_target_distance = math.huge
	
	for vehicle in Client:GetVehicles() do
	
		if vehicle:GetDriver() and vehicle ~= local_vehicle then
	
			local model = vehicle:GetModelId()
			if self.planes[model] then
			
				local vehicle_position = vehicle:GetPosition()
				local vehicle_distance = Vector3.Distance(local_position, vehicle_position)
				
				if vehicle_distance < nearest_target_distance then

					local dy = vehicle_position.y - local_position.y
				
					local plane_cone_angle = self.planes[self.model].cone_angle
					local pitch_to_target = math.deg(math.asin(dy / vehicle_distance))
					local pitch_from_plane = self:GetPitch()
					local pitch_difference = self:DegreesDifference(pitch_to_target, pitch_from_plane)
					
					if math.abs(pitch_difference) < 0.5 * plane_cone_angle then
					
						local dx = vehicle_position.x - local_position.x
						local dz = vehicle_position.z - local_position.z
				
						local heading_to_target = self:YawToHeading(math.deg(math.atan2(-dx, -dz)))
						local heading_from_plane = self:GetHeading()
						local heading_difference = self:DegreesDifference(heading_from_plane, heading_to_target)
				
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
		Chat:Print("Target acquired: "..tostring(nearest_target:GetDriver()), Color.Orange)
		self.target = {}
		self.target.vehicle = nearest_target
		self.target.follow_distance = 100
		self:OHOff()
		self:WHOff()
		self:SHOn()
		self:HHOn()
		self:PHOn()
		self.config.th.on = true
	else
		Chat:Print("No target found.", Color.Silver)
	end

end

function Autopilot:APOff()
	self.config.ap.on = false
	self.config.rh.on = false
	self.config.ph.on = false
	self.config.hh.on = false
	self.config.ah.on = false
	self.config.sh.on = false
	self.config.wh.on = false
	self.config.oh.on = false
	self.config.th.on = false
end

function Autopilot:RHOff()
	if not self.config.wh.on and not self.config.hh.on then
		self.config.rh.on = false
	end
end

function Autopilot:PHOff()
	if not self.config.ah.on and not self.config.oh.on then
		self.config.ph.on = false
	end
end

function Autopilot:HHOff()
	if not self.config.wh.on and not self.config.oh.on then
		self.config.hh.on = false
		self:RHOff()
	end
end

function Autopilot:AHOff()
	if not self.config.oh.on or self.flare then
		self.config.ah.on = false
		self:PHOff()
	end
end

function Autopilot:SHOff()
	if not self.config.oh.on then
		self.config.sh.on = false
	end
end

function Autopilot:WHOff()
	if self.config.wh.on then
		self.config.wh.on = false
		if not self.config.oh.on then
			self:HHOff()
		end
	end
end

function Autopilot:OHOff()
	if self.config.oh.on then
		self.config.oh.on = false
		if not self.config.wh.on then
			self:HHOff()
		end
		self:AHOff()
		self:SHOff()
		self.approach = nil
	end
end

function Autopilot:THOff()
	if self.config.th.on then
		self:HHOff()
		self:PHOff()
		self:SHOff()
		self.target = nil
		self.config.th.on = false
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
	if self.config.rh.on then
		if i == 60 or i == 61 then
			return false
		end
	end
	if self.config.ph.on then
		if i == 58 or i == 59 then
			return false
		end
	end
	if self.config.sh.on then
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
		
		if self.config[k].setting then
		
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
		v.button:SetToggleState(self.config[k].on)
		if self.config[k].setting then
			v.label:SetText(tostringint(self.config[k].setting)..self.config[k].units)
			v.slider:SetValue(self.config[k].setting)		
		end
	end
		
end

function tostringint(n)
	return tostring(math.floor(n + 0.5))
end

function Autopilot:DegreesDifference(theta1, theta2)
	return (theta2 - theta1 + 180) % 360 - 180
end

function Autopilot:OppositeDegrees(theta)
	return (theta + 180) % 360
end

function Autopilot:GetRoll()
	return math.deg(self.vehicle:GetAngle().roll)
end

function Autopilot:GetPitch()
	return math.deg(self.vehicle:GetAngle().pitch)
end

function Autopilot:GetYaw()
	return math.deg(self.vehicle:GetAngle().yaw)
end

function Autopilot:GetHeading()
	local yaw = self:GetYaw()
	return self:YawToHeading(yaw)
end

function Autopilot:YawToHeading(yaw)
	if yaw < 0 then
		return -yaw
	else
		return 360 - yaw
	end
end

function Autopilot:HeadingToYaw(heading)
	if heading < 180 then
		return -heading
	else
		return 360 - heading
	end
end

function Autopilot:GetAltitude()
	return self.vehicle:GetPosition().y - 200
end

function Autopilot:GetAirSpeed()
	return self.vehicle:GetLinearVelocity():Length() * 3.6
end

function Autopilot:GetVerticalSpeed()
	return self.vehicle:GetLinearVelocity().y * 3.6
end

function Autopilot:GetGroundSpeed()
	return Vector2(self.vehicle:GetLinearVelocity().x, self.vehicle:GetLinearVelocity().z):Length() * 3.6
end

function Autopilot:EnterPlane(args)
	
	local model = args.vehicle:GetModelId()
	if self.planes[model] then
		if self.planes[model].available then
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
		if IsValid(args.entity) then
			if args.entity:GetDriver() == LocalPlayer then
				local model = args.entity:GetModelId()
				if self.planes[model] then
					if self.panel_available then
						self:APOff()
						self.panel_available = false
						self.vehicle = nil
						self.model = nil
						self.window:SetVisible(false)
						Mouse:SetVisible(false)
					end
				end
			end
		end
	end

end

function Autopilot:RollHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.rh.on or not IsValid(self.vehicle) then return end	
	
	local roll = self:GetRoll()
	
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

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.ph.on or not IsValid(self.vehicle) then return end
	
	local pitch = self:GetPitch()
	local roll = self:GetRoll()
	
	local input = math.abs(pitch - self.config.ph.setting) * self.config.ph.gain
	if input > self.config.ph.max_input then input = self.config.ph.max_input end
	
	-- Deactivates if the plane is banked too far left or right.
	
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

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.hh.on or not IsValid(self.vehicle) then return end
	
	local heading = self:GetHeading()
	
	local diff = self:DegreesDifference(self.config.hh.setting, heading)
	
	self.config.rh.setting = diff * self.config.hh.gain
	
	if self.config.rh.setting > self.config.hh.roll_limit then
		self.config.rh.setting = self.config.hh.roll_limit
	elseif self.config.rh.setting < -self.config.hh.roll_limit then
		self.config.rh.setting = -self.config.hh.roll_limit
	end
	
end

function Autopilot:AltitudeHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.ah.on or not IsValid(self.vehicle) then return end
	
	self.config.ph.setting = (self.config.ah.setting - Autopilot:GetAltitude() + self.config.ah.bias) * self.config.ah.gain
	
	if self.config.ph.setting > self.config.ah.pitch_limit then
		self.config.ph.setting = self.config.ah.pitch_limit
	elseif self.config.ph.setting < -self.config.ah.pitch_limit then
		self.config.ph.setting = -self.config.ah.pitch_limit
	end
	
end

function Autopilot:SpeedHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.sh.on or not IsValid(self.vehicle) then return end
		
	local air_speed = self:GetAirSpeed()
	
	local input = math.abs(air_speed - self.config.sh.setting) * self.config.sh.gain
	if input > self.config.sh.max_input then input = self.config.sh.max_input end
	
	if air_speed < self.config.sh.setting and not self.config.oh.on then
		Input:SetValue(Action.PlaneIncTrust, input)
	end
	if air_speed > self.config.sh.setting then
		Input:SetValue(Action.PlaneDecTrust, input)
	end
	
end

function Autopilot:WaypointHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.wh.on or not IsValid(self.vehicle) then return end
	
	local waypoint, marker = Waypoint:GetPosition()
	
	if not marker then
		self:WHOff()
		return
	end
	
	self:FollowTargetXZ(waypoint)
	
end

function Autopilot:ApproachHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.oh.on or not IsValid(self.vehicle) then return end
	
	local position = self.vehicle:GetPosition()
	
	if not self.flare then
		local distance = Vector3.Distance(self.approach.near_marker, position)
		if distance > self.planes[self.model].flare_distance then
			self.approach.farpoint = self.approach.near_marker + self.approach.angle * Vector3.Forward * distance
			self.config.ah.setting = self.approach.farpoint.y - 200 - self.config.ah.bias
			self.config.sh.setting = math.min(math.lerp(self.planes[self.model].landing_speed, self.planes[self.model].cruise_speed, distance / self.planes[self.model].slow_distance), self.planes[self.model].cruise_speed)
			self.approach.target = math.lerp(self.approach.near_marker, self.approach.farpoint, 0.5)
			self:FollowTargetXZ(self.approach.target)
		else
			self.flare = true
			self:AHOff()
			self:PHOn()
			self.approach.target = self.approach.far_marker
			self.config.ph.setting = self.planes[self.model].flare_pitch
			self.config.sh.setting = self.planes[self.model].landing_speed
		end
	else
		local distance = Vector3.Distance(self.approach.far_marker, position)
		local length = Vector3.Distance(self.approach.far_marker, self.approach.near_marker)
		self.config.sh.setting = math.min(math.lerp(0, self.planes[self.model].landing_speed, distance / length), self.planes[self.model].landing_speed)
		self:FollowTargetXZ(self.approach.target)
	end
	
end

function Autopilot:TargetHold() -- Subscribed to InputPoll

	if Game:GetState() ~= GUIState.Game or not self.panel_available or not self.config.th.on or not IsValid(self.vehicle) then return end
	
	if not IsValid(self.target.vehicle) or not self.target.vehicle:GetDriver() then
		Chat:Print("Target lost.", Color.Orange)
		self:THOff()
		return
	end
	
	local target_position = self.target.vehicle:GetPosition()
	local position = LocalPlayer:GetPosition()
	local distance = Vector3.Distance(target_position, position)
	local bias = distance / self.target.follow_distance
	
	self.config.sh.setting = math.clamp(bias * self.target.vehicle:GetLinearVelocity():Length() * 3.6, self.config.sh.min_setting, self.config.sh.max_setting)
	
	self:FollowTargetXZ(target_position)
	self:FollowTargetY(target_position)

end

function Autopilot:FollowTargetXZ(target_position) -- Heading-hold must be on

	local position = self.vehicle:GetPosition()
	local dx = position.x - target_position.x
	local dz = position.z - target_position.z
	
	self.config.hh.setting = self:YawToHeading(math.deg(math.atan2(dx, dz)))

end

function Autopilot:FollowTargetY(target_position) -- Pitch-hold must be on

	local position = self.vehicle:GetPosition()
	local dy = position.y - target_position.y
	local distance = Vector3.Distance(position, target_position)
	
	self.config.ph.setting = math.deg(math.asin(-dy / distance))

end

Autopilot = Autopilot()
