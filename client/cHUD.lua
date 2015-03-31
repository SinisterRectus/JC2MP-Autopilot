-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'HUD'

function HUD:__init()

	self.plane = {}
	self.plane[24] = true -- F-33 DragonFly
	self.plane[30] = true -- Si-47 Leopard
	self.plane[34] = true -- G9 Eclipse
	self.plane[39] = true -- Aeroliner 474
	self.plane[51] = true -- Cassius 192
	self.plane[59] = true -- Peek Airhawk 225
	self.plane[81] = true -- Pell Silverbolt 6
	self.plane[85] = true -- Bering I-86DP
	
	self.color = Color(255, 255, 255)
	self.msg_color = Color(192, 192, 192)
	
	self.screen_height = Render.Height
	self.screen_width = Render.Width
	self.scale = 0.012 -- 0.012 default
	self.size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	
	self.position = Vector2(self.screen_width * 0.15, self.screen_height * 0.086)
	
	self.speed_units = {}
	self.speed_units[1] = {" m/s", 1}
	self.speed_units[2] = {" km/h", 3.6}
	self.speed_units[3] = {" mph", 2.237 }
	self.speed_units[4] = {" ft/s", 3.281}
	self.speed_units[5] = {" kts", 1.944}
	
	self.distance_units = {}
	self.distance_units[1] = {" m", 1}
	self.distance_units[2] = {" ft", 3.281}
	
	self.air_speed_units = 2
	self.ground_speed_units = 2
	self.vertical_speed_units = 2
	self.altitude_units = 1
	self.xcoord_units = 1
	self.ycoord_units = 1
	
	Events:Subscribe("Render", self, self.Draw)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
	
end

function math.int(n)

	return math.floor(n + 0.5)
	
end

function HUD:Draw() -- Subscribed to Render

	if not self:PanelAvailable() then return false end
	local v = LocalPlayer:GetVehicle()
	local angle = v:GetAngle()
	
	local air_speed = v:GetLinearVelocity():Length() * self.speed_units[self.air_speed_units][2]
	local ground_speed = v:GetLinearVelocity():Length() * self.speed_units[self.ground_speed_units][2] * math.cos(angle.pitch)
	local vertical_speed = v:GetLinearVelocity():Length() * self.speed_units[self.vertical_speed_units][2] * math.sin(angle.pitch)
	
	local air_speed_string = "Air Speed: "..tostring(math.int(air_speed))..self.speed_units[self.air_speed_units][1]
	local ground_speed_string = "Ground Speed: "..tostring(math.int(ground_speed))..self.speed_units[self.ground_speed_units][1]
	local vertical_speed_string = "Vertical Speed: "..tostring(math.int(vertical_speed)).. self.speed_units[self.vertical_speed_units][1]
	
	local column1_position = self.position

	Render:DrawText(column1_position, air_speed_string, self.color, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 1), ground_speed_string, self.color, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 2), vertical_speed_string, self.color, self.size)
	
	local vpos = v:GetPosition()
	local altitude = (vpos.y - 200) * self.distance_units[self.altitude_units][2]
	local terrain_height = math.max((Physics:GetTerrainHeight(vpos) * self.distance_units[self.altitude_units][2] - 200), 0)
	local xcoord = (vpos.x + 16384) * self.distance_units[self.xcoord_units][2]
	local ycoord = (vpos.z + 16384) * self.distance_units[self.ycoord_units][2]
	
	local sealevel_alt_string = "SL Alt: "..tostring(math.int(altitude))..self.distance_units[self.altitude_units][1]
	local groundlevel_alt_string = "GL Alt: "..tostring(math.int(altitude - terrain_height))..self.distance_units[self.altitude_units][1]
	local xcoord_string = "X-Coord: "..tostring(math.int(xcoord))..self.distance_units[self.xcoord_units][1]
	local ycoord_string = "Y-Coord: "..tostring(math.int(ycoord))..self.distance_units[self.ycoord_units][1]
	
	local column2_position = Vector2(self.position.x + 14 * self.size, self.position.y)
	
	Render:DrawText(column2_position, sealevel_alt_string, self.color, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 1), groundlevel_alt_string, self.color, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 2), xcoord_string, self.color, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 3), ycoord_string, self.color, self.size)

	local heading = -math.deg(angle.yaw)
	
	if heading <= 0 then
		heading = heading + 360
	end
	
	local roll_string = "Roll: "..tostring(math.int(math.deg(angle.roll))).."°"
	local pitch_string = "Pitch: "..tostring(math.int(math.deg(angle.pitch))).."°"
	local yaw_string = "Yaw: "..tostring(math.int(math.deg(angle.yaw))).."°"
	local heading_string = "Heading: "..tostring(math.int(heading)).."°"
	
	local column3_position = Vector2(self.position.x + 25 * self.size, self.position.y)
	
	Render:DrawText(column3_position, roll_string, self.color, self.size)
	Render:DrawText(column3_position + Vector2(0, self.size * 1), pitch_string, self.color, self.size)
	Render:DrawText(column3_position + Vector2(0, self.size * 2), yaw_string, self.color, self.size)
	Render:DrawText(column3_position + Vector2(0, self.size * 3), heading_string, self.color, self.size)
	
end

function HUD:PanelAvailable()

	if LocalPlayer:InVehicle() then
		local v = LocalPlayer:GetVehicle()
		if self.plane[v:GetModelId()] then
			return true
		end
	end
	return false
	
end
	
function HUD:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.screen_width = args.size.x
	self.screen_height = args.size.y
	self.size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	self.position = Vector2(self.screen_width * 0.2, self.screen_height * 0.1)
	
end

HUD = HUD()
