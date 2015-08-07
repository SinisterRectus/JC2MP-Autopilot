-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'HUD'

function HUD:__init()
	
	self.enabled = true

	self.scale = 0.01
	self.size = Render.Size:Length() * self.scale
	
	self.position = Vector2(Render.Width * 0.14, Render.Height * 0.08)
	
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
	
end

function HUD:Toggle(args)
	if args.text == "/hud" then
		self.enabled = not self.enabled
		return false
	end
end

function HUD:Draw() -- Subscribed to Render

	if not self.enabled or not IsValid(Autopilot.vehicle) then return end
	
	self.angle = Autopilot.vehicle:GetAngle()
	self.vposition = Autopilot.vehicle:GetPosition()
	self.velocity = Autopilot.vehicle:GetLinearVelocity()
	
	local air_speed = self.velocity:Length() * self.speed_units[self.air_speed_units][2]
	local ground_speed = Vector2(self.velocity.x, self.velocity.z):Length() * self.speed_units[self.ground_speed_units][2]
	local vertical_speed = self.velocity.y * self.speed_units[self.vertical_speed_units][2]
	
	local air_speed_string = "Air Speed: "..tostringint(air_speed)..self.speed_units[self.air_speed_units][1]
	local ground_speed_string = "Ground Speed: "..tostringint(ground_speed)..self.speed_units[self.ground_speed_units][1]
	local vertical_speed_string = "Vertical Speed: "..tostringint(vertical_speed).. self.speed_units[self.vertical_speed_units][1]
	
	local column1_position = self.position
	
	Render:DrawText(column1_position, air_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 1), ground_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 2), vertical_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 3), "Health: "..tostringint(Autopilot.vehicle:GetHealth()*100).."%", Color.White, self.size)
	
	local altitude = (self.vposition.y - 200) * self.distance_units[self.altitude_units][2]
	local terrain_height = math.max((Physics:GetTerrainHeight(self.vposition) * self.distance_units[self.altitude_units][2] - 200), 0)
	local xcoord = (self.vposition.x + 16384) * self.distance_units[self.xcoord_units][2]
	local ycoord = (self.vposition.z + 16384) * self.distance_units[self.ycoord_units][2]
	
	local sealevel_alt_string = "Altitude: "..tostringint(altitude)..self.distance_units[self.altitude_units][1]
	
	local column2_position = Vector2(self.position.x + 14 * self.size, self.position.y)

	local heading = YawToHeading(math.deg(self.angle.yaw))
	
	local roll_string = "Roll: "..tostringint(math.deg(self.angle.roll)).."°"
	local pitch_string = "Pitch: "..tostringint(math.deg(self.angle.pitch)).."°"
	local heading_string = "Heading: "..tostringint(heading).."°"
	
	local column3_position = Vector2(self.position.x + 25 * self.size, self.position.y)
	
	Render:DrawText(column2_position, roll_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 1), pitch_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 2), heading_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 3), sealevel_alt_string, Color.White, self.size)
	
end
	
function HUD:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.size = args.size:Length() * self.scale
	self.position = Vector2(args.size.x * 0.14, args.size.y * 0.08)
	
end

HUD = HUD()
