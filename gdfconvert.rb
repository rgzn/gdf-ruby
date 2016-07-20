#!/usr/bin/env ruby
#
#

require_relative 'gdf.rb'

inputFiles = ARGV

outputFile = "gdfConverted.txt"
delim = "\t"

outputHeader = GDF::GDF.new.get_csv_header(delim)
File.open(outputFile, 'w') do |f|
	f << outputHeader
end


inputFiles.each do |filename|
	if !File.file?(filename)
		puts "#{filename} does not exit"
	else if ! ( File.extname(filename) =~ /\.gdf/i )
		puts "#{filename} is not a gdf"
	else
		data = GDF::GDF.new(:filename => filename)
		data.read(File.open(filename))
		File.open(outputFile, 'a') do |f|
			f << data.to_csv(delim)
		end
	end
end

end
