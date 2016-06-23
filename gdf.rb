#!/usr/bin/env ruby
#

require 'bindata'

module GDF
	VALID_POSTFIX = "\x01\x03\x03"
	T0 = Time.utc(2000, 01, 01, 0, 0, 0)

	# Define the records within a GDF: 

	# Header
	# This is the first portion with gdf metadata
	# It occurs once per file, at the beginning
	class Header < BinData::Record
		endian :little
		uint32 :collar_id
		string :prefix, :read_length => 4
		string :msg, :read_length => 16
		string :postfix, :read_length => 3
		virtual :valid, :assert =>	lambda { postfix == GDF::VALID_POSTFIX }
	end

	# Junk
	# This follow the header, and appears to 
	# have no bearing on the data.
	# Not sure of its purpose
	class Junk < BinData::Record
		string :raw, :read_length => 51
	end

	# Datetime
	# DateTime stored as an integer
	# of seconds since 20010101_00:00:00
	class TimeRecord < BinData::Primitive
		endian :big
		int32 :raw_seconds

		def get
			s = raw_seconds & 0x3FFFFFFF 	# filter out most siginificant bit
			return GDF::T0 + s
		end

		def set(time_in)
			time = Time.at(time_in) - GDF::T0
			self.raw_seconds = time.to_i
		end
	end

	# Coord
	# This is a subsection with xyz ecef coordinates
	# It is used within the larger Fix Record
	class Coord < BinData::Record
		endian :big
		int32 :ecef_x
		int32 :ecef_y
		int32 :ecef_z
	end

	# Sats
	# This is a subsection of a fix
	# It contains the data on satellites used
	# and signal strength
	class Sats < BinData::Record


		endian	:little
	end


	# Fix 
	# A single gps fix, with all associated data.
	# After the Header and Junk, the rest of the gdf
	# is just repeated fixes.
	class Fix < BinData::Record
		endian 	:little
		uint32 	:time_seconds
		coord  	:coord
		uint8 	:fix_type
		uint8	:dop

		uint8	:main_v
		uint8	:bkp_v
		uint8	:temp
	end



	fix_types = ['No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix']



end

