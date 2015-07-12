-- Written by Sinister Rectus - http://www.jc-mp.com/forums/index.php?action=profile;u=73431

class 'ApproachPath'

function ApproachPath:__init()

	self.timer = Timer()
	self.delay = 5000

	Events:Subscribe("Render", self, self.Search)
	
end


function ApproachPath:Search()

	if Autopilot.vehicle and self.timer:GetMilliseconds() > self.delay and Game:GetState() == GUIState.Game then
	
		local position = Autopilot.vehicle:GetPosition()
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
					local pitch_difference1 = Autopilot:DegreesDifference(pitch_to_plane, pitch_from_runway)
					
					if math.abs(pitch_difference1) < 0.5 * runway_cone_angle then
					
						local dx = near_marker.x - position.x
						local dz = near_marker.z - position.z

						local heading_to_plane = Autopilot:YawToHeading(math.deg(math.atan2(dx, dz)))
						local heading_from_runway = Autopilot:YawToHeading(math.deg(math.atan2(far_marker.x - near_marker.x, far_marker.z - near_marker.z)))
						local heading_difference1 = Autopilot:DegreesDifference(heading_to_plane, heading_from_runway)
									
						if math.abs(heading_difference1) < 0.5 * runway_cone_angle then
						
							local plane_cone_angle = planes[Autopilot.model].cone_angle
							local pitch_to_runway = math.deg(math.asin(dy / distance))
							local pitch_from_plane = Autopilot:GetPitch()
							local pitch_difference2 = Autopilot:DegreesDifference(pitch_to_runway, pitch_from_plane)
							
							if math.abs(pitch_difference2) < 0.5 * plane_cone_angle then
						
								local heading_to_runway = Autopilot:YawToHeading(math.deg(math.atan2(-dx, -dz)))
								local heading_from_plane = Autopilot:GetHeading()
								local heading_difference2 = Autopilot:DegreesDifference(heading_from_plane, heading_to_runway)
						
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
			self.approach.near_marker = airports[airport_name][runway_name].near_marker
			self.approach.far_marker = airports[airport_name][runway_name].far_marker
			self.approach.angle = Angle(math.rad(Autopilot:HeadingToYaw(runway_direction)), math.rad(airports[airport_name][runway_name].glide_pitch), 0)
			self.approach.sweep_yaw = Angle(math.rad(airports[airport_name][runway_name].cone_angle / 2), 0, 0)
			self.approach.glide_length = airports[airport_name][runway_name].glide_length
		else
			self.approach = nil
		end
		
		self.timer:Restart()
		
	end
	
	if self.approach then
	
		local dx = self.approach.far_marker.x - self.approach.near_marker.x
		local dz = self.approach.far_marker.z - self.approach.near_marker.z

		Render:DrawLine(self.approach.near_marker, self.approach.near_marker + self.approach.angle * Vector3.Forward * self.approach.glide_length, Color.Orange)
		Render:DrawLine(self.approach.near_marker, self.approach.near_marker + self.approach.angle * self.approach.sweep_yaw * Vector3.Forward * self.approach.glide_length, Color.Cyan)
		Render:DrawLine(self.approach.near_marker, self.approach.near_marker + self.approach.angle * -self.approach.sweep_yaw * Vector3.Forward * self.approach.glide_length, Color.Cyan)
		
	end

end

ApproachPath = ApproachPath()
