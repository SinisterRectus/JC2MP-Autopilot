local format = string.format
local settings, units = settings, units
local Vector2, Render = Vector2, Render

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

function HUD:Draw()

	if not self.enabled then return end
	local vehicle = Autopilot.vehicle
	if not IsValid(vehicle) then return end

	local size = self.size
	local color = Color.White

	local column1 = self.position

	local air_speed_string = format("Air Speed: %i%s", vehicle:GetAirSpeed() * units.speed[settings.speed][2], units.speed[settings.speed][1])
	local ground_speed_string = format("Ground Speed: %i%s", vehicle:GetGroundSpeed() * units.speed[settings.speed][2], units.speed[settings.speed][1])
	local vertical_speed_string = format("Vertical Speed: %i%s", vehicle:GetVerticalSpeed() * units.speed[settings.speed][2], units.speed[settings.speed][1])
	local health_string = format("Health: %i%s", vehicle:GetHealth() * 100, "%")

	Render:DrawText(column1, air_speed_string, color, size)
	Render:DrawText(column1 + Vector2(0, size * 1), ground_speed_string, color, size)
	Render:DrawText(column1 + Vector2(0, size * 2), vertical_speed_string, color, size)
	Render:DrawText(column1 + Vector2(0, size * 3), health_string, color, size)

	local column2 = Vector2(column1.x + 14 * size, column1.y)

	local roll_string = format("Roll: %i%s", vehicle:GetRoll() * units.angle[settings.angle][2], units.angle[settings.angle][1])
	local pitch_string = format("Pitch: %i%s", vehicle:GetPitch() * units.angle[settings.angle][2], units.angle[settings.angle][1])
	local heading_string = format("Heading: %i%s", vehicle:GetHeading() * units.angle[settings.angle][2], units.angle[settings.angle][1])
	local altitude_string = format("Altitude: %i%s", vehicle:GetAltitude() * units.distance[settings.distance][2], units.distance[settings.distance][1])

	local column3_position = Vector2(column1.x + 25 * size, column1.y)

	Render:DrawText(column2, roll_string, color, size)
	Render:DrawText(column2 + Vector2(0, size * 1), pitch_string, color, size)
	Render:DrawText(column2 + Vector2(0, size * 2), heading_string, color, size)
	Render:DrawText(column2 + Vector2(0, size * 3), altitude_string, color, size)

end

function HUD:ResolutionChange(args) -- Subscribed to ResolutionChange
	self.size = args.size:Length() * self.scale
	self.position = Vector2(args.size.x * 0.14, args.size.y * 0.08)
end

HUD = HUD()
