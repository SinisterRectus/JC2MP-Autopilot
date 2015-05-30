-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'HUD'

function HUD:__init()

	self.planes = {}
	self.planes[24] = true -- F-33 DragonFly
	self.planes[30] = true -- Si-47 Leopard
	self.planes[34] = true -- G9 Eclipse
	self.planes[39] = true -- Aeroliner 474
	self.planes[51] = true -- Cassius 192
	self.planes[59] = true -- Peek Airhawk 225
	self.planes[81] = true -- Pell Silverbolt 6
	self.planes[85] = true -- Bering I-86DP
	
	self.enabled = true
	
	if LocalPlayer:InVehicle() then
		local vehicle = LocalPlayer:GetVehicle()
		if self.planes[vehicle:GetModelId()] then
			self.occupied = vehicle
		end
	end
	
	self.screen_size = Render.Size
	self.screen_height = Render.Height
	self.screen_width = Render.Width
	self.scale = 0.01
	self.size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	
	self.position = Vector2(self.screen_width * 0.14, self.screen_height * 0.08)
	
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
	Events:Subscribe("LocalPlayerChat", self, self.Toggle)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterPlane)
	Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitPlane)
	
end

function int(n)
	return math.floor(n + 0.5)	
end

function HUD:Toggle(args)
	if args.text == "/hud" then
		self.enabled = not self.enabled
		return false
	end
end

function HUD:Draw() -- Subscribed to Render

	if not self.enabled then return end

	if Autopilot.airports then
		--self:DrawGlideScope("PIA", "09")
		--self:DrawGlideScope("PIA", "27")
		--self:DrawGlideScope("PIA", "05")
		--self:DrawGlideScope("PIA", "23")
		--self:DrawGlideScope("Kem Sungai Sejuk", "04")
	end
	
	if not self.occupied then return end

	if Autopilot.approach then
		--Render:DrawCircle(Render:WorldToScreen(Autopilot.approach.target), 5, Color.Orange)
		--Render:DrawCircle(Render:WorldToScreen(Autopilot.approach.farpoint), 5, Color.Orange)
	end
	
	self.angle = self.occupied:GetAngle()
	self.vposition = self.occupied:GetPosition()
	self.velocity = self.occupied:GetLinearVelocity()
	
	--self:DrawPlaneFOV(self.occupied)
	
	local air_speed = self.velocity:Length() * self.speed_units[self.air_speed_units][2]
	local ground_speed = Vector2(self.velocity.x, self.velocity.z):Length() * self.speed_units[self.ground_speed_units][2]
	local vertical_speed = self.velocity.y * self.speed_units[self.vertical_speed_units][2]
	
	local air_speed_string = "Air Speed: "..tostring(int(air_speed))..self.speed_units[self.air_speed_units][1]
	local ground_speed_string = "Ground Speed: "..tostring(int(ground_speed))..self.speed_units[self.ground_speed_units][1]
	local vertical_speed_string = "Vertical Speed: "..tostring(int(vertical_speed)).. self.speed_units[self.vertical_speed_units][1]
	
	local column1_position = self.position
	
	Render:DrawText(column1_position, air_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 1), ground_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 2), vertical_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 3), "Health: "..tostring(int(self.occupied:GetHealth()*100)).."%", Color.White, self.size)
	
	local altitude = (self.vposition.y - 200) * self.distance_units[self.altitude_units][2]
	local terrain_height = math.max((Physics:GetTerrainHeight(self.vposition) * self.distance_units[self.altitude_units][2] - 200), 0)
	local xcoord = (self.vposition.x + 16384) * self.distance_units[self.xcoord_units][2]
	local ycoord = (self.vposition.z + 16384) * self.distance_units[self.ycoord_units][2]
	
	local sealevel_alt_string = "SL Alt: "..tostring(int(altitude))..self.distance_units[self.altitude_units][1]
	local groundlevel_alt_string = "GL Alt: "..tostring(int(altitude - terrain_height))..self.distance_units[self.altitude_units][1]
	local xcoord_string = "X-Coord: "..tostring(int(xcoord))..self.distance_units[self.xcoord_units][1]
	local ycoord_string = "Y-Coord: "..tostring(int(ycoord))..self.distance_units[self.ycoord_units][1]
	
	local column2_position = Vector2(self.position.x + 14 * self.size, self.position.y)
	
	Render:DrawText(column2_position, sealevel_alt_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 1), groundlevel_alt_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 2), xcoord_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 3), ycoord_string, Color.White, self.size)

	local heading = -math.deg(self.angle.yaw)
	
	if heading <= 0 then
		heading = heading + 360
	end
	
	local roll_string = "Roll: "..tostring(int(math.deg(self.angle.roll))).."°"
	local pitch_string = "Pitch: "..tostring(int(math.deg(self.angle.pitch))).."°"
	local yaw_string = "Yaw: "..tostring(int(math.deg(self.angle.yaw))).."°"
	local heading_string = "Heading: "..tostring(int(heading)).."°"
	
	local column3_position = Vector2(self.position.x + 25 * self.size, self.position.y)
	
	Render:DrawText(column3_position, roll_string, Color.White, self.size)
	Render:DrawText(column3_position + Vector2(0, self.size * 1), pitch_string, Color.White, self.size)
	Render:DrawText(column3_position + Vector2(0, self.size * 3), yaw_string, Color.White, self.size)
	Render:DrawText(column3_position + Vector2(0, self.size * 2), heading_string, Color.White, self.size)
	
end

function HUD:DrawGlideScope(airport_name, runway_name)

	local glide = {}
	glide.near_marker = Autopilot.airports[airport_name][runway_name].near_marker
	glide.far_marker = Autopilot.airports[airport_name][runway_name].far_marker
	local dx = glide.far_marker.x - glide.near_marker.x
	local dz = glide.far_marker.z - glide.near_marker.z
	glide.angle = Angle(math.atan2(dx,dz), math.rad(Autopilot.airports[airport_name][runway_name].glide_pitch), 0)
	glide.sweep_yaw = Angle(math.rad(Autopilot.airports[airport_name][runway_name].cone_angle / 2), 0, 0)
	glide.sweep_pitch = Angle(0, math.rad(Autopilot.airports[airport_name][runway_name].cone_angle / 2), 0)

	Render:DrawLine(glide.near_marker, glide.near_marker + glide.angle * Vector3.Forward * Autopilot.airports[airport_name][runway_name].glide_length, Color.Orange)
	Render:DrawLine(glide.near_marker, glide.near_marker + glide.angle * glide.sweep_yaw * Vector3.Forward * Autopilot.airports[airport_name][runway_name].glide_length, Color.Cyan)
	Render:DrawLine(glide.near_marker, glide.near_marker + glide.angle * -glide.sweep_yaw * Vector3.Forward * Autopilot.airports[airport_name][runway_name].glide_length, Color.Cyan)
	--Render:DrawLine(glide.near_marker, glide.near_marker + glide.angle * glide.sweep_pitch * Vector3.Forward * Autopilot.airports[airport_name][runway_name].glide_length, Color.Cyan)
	--Render:DrawLine(glide.near_marker, glide.near_marker + glide.angle * -glide.sweep_pitch * Vector3.Forward * Autopilot.airports[airport_name][runway_name].glide_length, Color.Cyan)

end

function HUD:DrawPlaneFOV(vehicle)

	if Autopilot.planes then

		local model = vehicle:GetModelId()
		local sweep_yaw = Angle(math.rad(Autopilot.planes[model].cone_angle / 2), 0, 0)
		
		Render:DrawLine(self.vposition, self.vposition + self.angle * Vector3.Forward * 5000, Color.Magenta)
		Render:DrawLine(self.vposition, self.vposition + sweep_yaw * self.angle * Vector3.Forward * 5000, Color.Magenta)
		Render:DrawLine(self.vposition, self.vposition + -sweep_yaw * self.angle * Vector3.Forward * 5000, Color.Magenta)
		
	end

end

function HUD:EnterPlane(args)
	if self.planes[args.vehicle:GetModelId()]then
		self.occupied = args.vehicle
	end
end

function HUD:ExitPlane(args)
	if self.occupied then
		self.occupied = nil
	end
end
	
function HUD:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.screen_width = args.size.x
	self.screen_height = args.size.y
	self.size = math.sqrt(self.screen_height^2 + self.screen_width^2) * self.scale
	self.position = Vector2(self.screen_width * 0.14, self.screen_height * 0.08)
	
end

HUD = HUD()
