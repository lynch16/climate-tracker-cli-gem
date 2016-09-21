class ClimateTracker::NOAAScraper
	attr_accessor :state, :data_type, :start_year, :stop_year, :start_data, :stop_data

	def initialize(state, data_category, start_year, stop_year)
		@start_year = start_year
		@stop_year = stop_year

		case state
		when "NH"
			@state = "FIPS:33"
		when "ME"
			@state = "FIPS:23"
		when "MA"
			@state = "FIPS:25"
		when "VT"
			@state = "FIPS:50"
		end

		if data_category == "T"
			@data_type = "MNTM"
		elsif data_category == "P"
			@data_type = "TCPC"
		else
			@data_type = "MNTM&datatype=TCPC"
		end
	end

	def scrape
		header = { "token" => "JPhvnfSrGIAesNPlFwRxKFsZTwPuYoum" }
		uri_start = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=ANNUAL&datatypeid=#{@data_type}&locationid=#{@state}&startdate=#{@start_year.to_i-1}-01-01&enddate=#{@start_year}-01-01&units=metric&limit=1000")
		request = Net::HTTP::Get.new(uri_start.request_uri, initheader = header)
		http = Net::HTTP.new(uri_start.host, uri_start.port).start 
		response = http.request(request)
		@start_data = JSON.parse(response.body)

		uri_stop = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=ANNUAL&datatypeid=#{@data_type}&locationid=#{@state}&startdate=#{@stop_year.to_i-1}-01-01&enddate=#{@stop_year}-01-01&units=metric&limit=1000")
		request = Net::HTTP::Get.new(uri_stop.request_uri, initheader = header)
		http = Net::HTTP.new(uri_stop.host, uri_stop.port).start 
		response = http.request(request)
		@stop_data = JSON.parse(response.body)

		self
	end

	def temp_difference
		total_start_values = 0.000
		total_end_values = 0

		start_data = @start_data["results"].collect do |result|
			result["date"].include?("#{@start_year}-") ? result : nil #collect data taken during start year
		end

		start_data.compact!.collect do |result| #collect only values from start year
			total_start_values += result["value"].to_i
		end

		start_avg = total_start_values / start_data.size.to_f

		end_data = @stop_data["results"].collect do |result|
			result["date"].include?("#{@stop_year}-") ? result : nil #collect data taken during end year
		end

		end_data.compact!.collect do |result| #collect only values from end year
			total_end_values += result["value"].to_i
		end

		end_avg = total_end_values / end_data.size.to_f

		delta_temp = [(end_avg - start_avg), ((end_avg/start_avg)*100) ] #returns as array with absolute change and percentage
	end

	def precip_difference
	end

	# ANNUAL > MMNT, MMXT, MNTM (Min T, Max T, and Avg T monthly)
	# > TCPC (Total Precip) TSNW (Total snowfall)
	
	#LocationID - States
	# ME: FIPS:23
	# NH: FIPS:33
	# MA: FIPS:25
	# VT: FIPS:50

end