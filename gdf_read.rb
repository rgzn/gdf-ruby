#!/usr/bin/env ruby
#

require 'bindata'

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
end

# Junk
# This follow the header, and appears to 
# have no bearing on the data.
# Not sure of its purpose
class Junk < BinData::Record
	string :raw, :read_length => 51
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
