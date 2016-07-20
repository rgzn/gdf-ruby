##!/usr/bin/env ruby
#
# Convert ECEF to LLA and back

require 'geoutm'

class ECEF
	attr_accessor :x, :y, :z
	# Ellipsoid parameters
	WGS84 = { 	
		:a => 6378137.0,				# semi-major axis
		:f => 1.0/298.257223563,
		:b => 6356752.314245179,
		:ecc => 0.081819218048345,
		:e2 => 6.6943799901377997e-3, 	# first eccentric (2f-f**2)
	}
	RAD2DEG = 180.0/Math::PI
	DEG2RAD = Math::PI/180.0


	def initialize(x, y, z)
		@x 	= x.to_f
		@y	= y.to_f
		@z	= z.to_f
	end

	def ECEF::at(coordinates) 
		case coordinates
		when ECEF
			self.new(coordinates.x, coordinates.y, coordinates.z)
		when GeoUtm::LatLon
			self.at(self.lla2xyz(coordinates.lat, coordinates.lon))
		when GeoUtm::UTM
			latlon = coordinates.to_lat_lon
			self.at(latlon)
		else
			raise "Cannot initialize #{self} with #{coordinates} 
				of type #{coordinates.class}"
		end
	end


	def ECEF::lla2xyz(latitude, longitude, altitude = 0.0)
		lat = latitude.to_f * DEG2RAD
		lon = longitude.to_f * DEG2RAD
		alt = altitude.to_f

		a = ECEF::WGS84[:a]
		f = ECEF::WGS84[:f]
		e2 = ECEF::WGS84[:e2]
		
		chi = Math.sqrt( 1.0 - e2*(Math.sin(lat))**2 )
		x = ( a/chi  + alt )*Math.cos(lat)*Math.cos(lon)
		y = ( a/chi  + alt )*Math.cos(lat)*Math.sin(lon)
		z = ( a*(1.0 - e2)/chi + alt )*Math.sin(lat)
		return ECEF.new(x, y, z)
	end

#	def utm2xyz(utm_n, utm_e, zone, altitude = 0.0)
#		zoneString = zone.to_s
#		n = utm_n.to_f
#		e = utm_e.to_f
#		lonlat = GeoUtm::UTM.new(n, e, zoneString)
#		
#		
#	end


	def lon
		lon_rad = Math.atan2(@y, @x)
		return lon_rad * RAD2DEG
	end

	def lat
		a = ECEF::WGS84[:a]
		b = ECEF::WGS84[:b]
		ecc = ECEF::WGS84[:ecc]
		p = Math.sqrt(x*x + y*y)
		theta = Math.atan(z*a/(p*b) )
		sint3 = Math.sin(theta)*Math.sin(theta)*Math.sin(theta)
		cost3 = Math.cos(theta)*Math.cos(theta)*Math.cos(theta)

		numlat = z + ((a*a - b*b)/b)*sint3
		denlat = p - ecc*ecc*a*cost3
		lat_rad =  Math.atan( numlat/denlat )
		return lat_rad * RAD2DEG
	end

	def alt
		a = ECEF::WGS84[:a]
		ecc = ECEF::WGS84[:ecc]
		lat = self.lat * DEG2RAD
		p = Math.sqrt(x*x + y*y)
		ntemp = 1.0 - (ecc*Math.sin(lat))**2
		if ntemp < 0.0
			n = a
		else
			n = a / Math.sqrt( ntemp )
		end
		alt = (p / Math.cos(lat)) - n
		return alt
	end

	def to_LatLon
		 return GeoUtm::LatLon.new(self.lat, self.lon)
	end

	def to_utm
		if ( self.lat.nan? || self.lon.nan?)
			utm = GeoUtm::UTM.new("N/A","N/A","N/A")  
		else

			begin	
				utm = GeoUtm::LatLon.new(self.lat, self.lon).to_utm
			rescue
				utm = GeoUtm::UTM.new("N/A","N/A","N/A")
			end
		end

		return utm
	end

	def e
		self.to_utm.e
	end

	def n
		self.to_utm.n
	end

	def zone
		self.to_utm.zone
	end


	def to_s 
		"x: " + x.to_s + 
			", y: " + y.to_s + 
			", z: " + z.to_s
	end

end

