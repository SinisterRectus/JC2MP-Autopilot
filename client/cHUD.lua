-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'HUD'

function HUD:__init()
	
	self.enabled = true

	self.scale = 0.01
	self.size = Render.Size:Length() * self.scale
	
	self.position = Vector2(Render.Width * 0.14, Render.Height * 0.08)
	
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
	
	local vehicle = Autopilot.vehicle
	
	local column1_position = self.position
	
	local air_speed_string = string.format("Air Speed: %i%s", vehicle:GetAirSpeed() * units.speed[settings.speed][2], units.speed[settings.speed][1])
	local ground_speed_string = string.format("Ground Speed: %i%s", vehicle:GetGroundSpeed() * units.speed[settings.speed][2], units.speed[settings.speed][1])
	local vertical_speed_string = string.format("Vertical Speed: %i%s", vehicle:GetVerticalSpeed() * units.speed[settings.speed][2], units.speed[settings.speed][1])
	local health_string = string.format("Health: %i%s", vehicle:GetHealth() * 100, "%")
	
	Render:DrawText(column1_position, air_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 1), ground_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 2), vertical_speed_string, Color.White, self.size)
	Render:DrawText(column1_position + Vector2(0, self.size * 3), health_string, Color.White, self.size)

	local column2_position = Vector2(self.position.x + 14 * self.size, self.position.y)
	
	local roll_string = string.format("Roll: %i%s", vehicle:GetRoll() * units.angle[settings.angle][2], units.angle[settings.angle][1])
	local pitch_string = string.format("Pitch: %i%s", vehicle:GetPitch() * units.angle[settings.angle][2], units.angle[settings.angle][1])
	local heading_string = string.format("Heading: %i%s", vehicle:GetHeading() * units.angle[settings.angle][2], units.angle[settings.angle][1])
	local altitude_string = string.format("Altitude: %i%s", vehicle:GetAltitude() * units.distance[settings.distance][2], units.distance[settings.distance][1])
	
	local column3_position = Vector2(self.position.x + 25 * self.size, self.position.y)
	
	Render:DrawText(column2_position, roll_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 1), pitch_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 2), heading_string, Color.White, self.size)
	Render:DrawText(column2_position + Vector2(0, self.size * 3), altitude_string, Color.White, self.size)
	
end
	
function HUD:ResolutionChange(args) -- Subscribed to ResolutionChange

	self.size = args.size:Length() * self.scale
	self.position = Vector2(args.size.x * 0.14, args.size.y * 0.08)
	
end

HUD = HUD()
