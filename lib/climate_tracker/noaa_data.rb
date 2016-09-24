class ClimateTracker::NOAA_Data
	attr_accessor :data_type, :data_dump, :delta_temp, :pull_count, :re_pull, :data_avg, :year1_avgs, :year2_avgs

	@@states = {}
	@@header = { "token" => "JPhvnfSrGIAesNPlFwRxKFsZTwPuYoum" }

	def initialize
		@data_type = "MNTM"
		@pull_count = 0
		@re_pull = true
		#Possible Data Types
		# > MMNT, MMXT, MNTM (Min T, Max T, and Avg T monthly)
		# > TCPC (Total Precip) TSNW (Total snowfall)
	end

	def self.states
		if @@states.empty?
			#populate available states
			uri = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/locations?locationcategoryid=ST&limit=52")
			request = Net::HTTP::Get.new(uri.request_uri, initheader = @@header)
			http = Net::HTTP.new(uri.host, uri.port).start 
			response = http.request(request)
			data = JSON.parse(response.body) 
			data["results"].collect do |result|
				st_name = result["name"].upcase
				st_id = result["id"]
				@@states[st_name] = st_id
			end
		end
		@@states.keys
	end

	def pull_data(date, state)
		#NOAA program requires range of 1 year for dataset ANNUAL. Create 1 year ago range from given date
		date_array = date.split("-")
		date_array[0] = date_array[0].to_i-1
		last_year_date = date_array.join("-")
		year_date = date

		#retrieve appropriate state_code and download temperatures for above range
		if @@states.empty?
			self.class.states
		end
		state_code = @@states[state]
		uri = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=ANNUAL&datatypeid=#{@data_type}&locationid=#{state_code}&startdate=#{last_year_date}&enddate=#{year_date}&units=metric&limit=1000")
		request = Net::HTTP::Get.new(uri.request_uri, initheader = @@header)
		http = Net::HTTP.new(uri.host, uri.port).start 
		response = http.request(request)
		@data_dump = JSON.parse(response.body) #returns are only for the month of the years in which this were called.  (ie. startdate XXXX-02-01 will only display February) ur
		
		@pull_count += 1
		@re_pull = false
		self
	end

	def gather_values
		total_values = 0.000
		@data_dump["results"].each do |result| 
			total_values += result["value"].to_f
		end

		@data_avg = (((total_values / @data_dump["results"].size)*(9.0/5.0))+32.0)
		
		@data_avg #float
	end

	def temp_difference(year1, year2, state)
		if self.re_pull == true 
			@year1_avgs = self.pull_data(year1, state).gather_values 
		elsif @year1_avgs == nil
			@year1_avgs = @data_avg
		elsif @year2_avgs != @data_avg
			@year1_avgs = @data_avg
		end

		@year2_avgs = self.pull_data(year2, state).gather_values
		delta_temp = (@year2_avgs - @year1_avgs).round(2) 
		delta_percent = ((@year2_avgs/@year1_avgs)*100).round(2)
		if delta_temp > 0 #if delta_temp is positive than temp went up
			delta_descr = "warmer"
			delta_descr_2 = "increase"
		else 
			delta_descr = "colder"
			delta_descr_2 = "decrease"
		end

		@delta_temp = [delta_temp, delta_percent, delta_descr, delta_descr_2] #hash[state] = [temp change, %, warmer/colder, increase/decrease]

		@delta_temp
	end
end