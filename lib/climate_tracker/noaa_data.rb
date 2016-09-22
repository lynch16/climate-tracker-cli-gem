class ClimateTracker::NOAA_Data
	attr_accessor :data_type, :data_dump_all_states, :header, :data_push

	@@states = {
		"NH" => "FIPS:33",
		"ME" => "FIPS:23",
		"MA" => "FIPS:25",
		"VT" => "FIPS:50" 
	}

	def initialize
		@header = { "token" => "JPhvnfSrGIAesNPlFwRxKFsZTwPuYoum" }
		@data_dump_all_states = {}
		@data_push = {}
		@data_type = "MNTM"
		# > MMNT, MMXT, MNTM (Min T, Max T, and Avg T monthly)
		# > TCPC (Total Precip) TSNW (Total snowfall)
	end

	def pull_data(date)
		date_array = date.split("-")
		date_array[0] = date_array[0].to_i-1
		last_year_date = date_array.join("-")
		year_date = date

		@@states.each do |state, state_code|
			uri_start = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=ANNUAL&datatypeid=#{@data_type}&locationid=#{state_code}&startdate=#{last_year_date}&enddate=#{year_date}&units=metric&limit=1000")
			request = Net::HTTP::Get.new(uri_start.request_uri, initheader = @header)
			http = Net::HTTP.new(uri_start.host, uri_start.port).start 
			response = http.request(request)
			@data_dump_all_states[state] = JSON.parse(response.body) #returns are only for the month of the years in which this were called.  (ie. startdate XXXX-02-01 will only display February) ur
		end

		self
	end

	def gather_values
		total_values = 0.000
		value_avgs = {}
		@data_dump_all_states.each do |state, data|
			data["results"].each do |result| 
				total_values += result["value"].to_f
			end

			value_avgs[state] = (total_values / data["results"].size)
		end
		value_avgs #hash[state] = average
	end

	def temp_difference(year1, year2)
		year1_avgs = {}
		year2_avgs = {}

		year1_avgs = self.pull_data(year1).gather_values #hash[state] = average
		year2_avgs = self.pull_data(year2).gather_values
		
		@@states.each do |state, state_code|
			delta_temp = (year2_avgs[state] - year1_avgs[state]).round(2) #if result is positive than temp went up
			delta_percent =  ((year2_avgs[state]/year1_avgs[state])*100).round(2)
			if delta_temp > 0 
				delta_descr = "warmer" 
				delta_descr_2 = "increase"
			else 
				delta_descr = "colder"
				delta_descr_2 = "decrease"
			end

			@data_push[state] = [delta_temp, delta_percent, delta_descr, delta_descr_2] #hash[state] = [temp change, %, warmer/colder, increase/decrease]
		end
		@data_push
	end
end