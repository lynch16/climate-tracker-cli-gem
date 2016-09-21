class ClimateTracker::NOAAScraper
	attr_accessor :state, :data_type, :start_date, :start_date_back, :stop_date, :stop_date_back, :start_data, :stop_data, :detla_t

	def initialize(state, data_category, start_year, stop_year)
		@start_date = start_year
		start_year_array = start_year.split("-")
		start_year_array[0] = start_year_array[0].to_i-1
		@start_date_back = start_year_array.join("-")

		@stop_date = stop_year
		stop_year_array = stop_year.split("-")
		stop_year_array[0] = stop_year_array[0].to_i-1
		@stop_date_back = stop_year_array.join("-")

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

		@data_type = "MNTM"
		# > MMNT, MMXT, MNTM (Min T, Max T, and Avg T monthly)
		# > TCPC (Total Precip) TSNW (Total snowfall)
	end

	def scrape
		header = { "token" => "JPhvnfSrGIAesNPlFwRxKFsZTwPuYoum" }
		uri_start = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=ANNUAL&datatypeid=#{@data_type}&locationid=#{@state}&startdate=#{@start_date_back}&enddate=#{@start_date}&units=metric&limit=1000")
		request = Net::HTTP::Get.new(uri_start.request_uri, initheader = header)
		http = Net::HTTP.new(uri_start.host, uri_start.port).start 
		response = http.request(request)
		@start_data = JSON.parse(response.body) #returns are only for the month of the years in which this were called.  (ie. startdate XXXX-02-01 will only display February) 

		uri_stop = URI.parse("http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=ANNUAL&datatypeid=#{@data_type}&locationid=#{@state}&startdate=#{@stop_date_back}&enddate=#{@stop_date}&units=metric&limit=1000")
		request = Net::HTTP::Get.new(uri_stop.request_uri, initheader = header)
		http = Net::HTTP.new(uri_stop.host, uri_stop.port).start 
		response = http.request(request)
		@stop_data = JSON.parse(response.body)

		self
	end

	def temp_difference
		total_start_values = 0.000
		total_end_values = 0

		@start_data["results"].each do |result| #collect only values from start year
			total_start_values += result["value"].to_f
		end

		start_avg = total_start_values / @start_data["results"].size

		@stop_data["results"].each do |result| #collect only values from end year
			total_end_values += result["value"].to_f
		end

		end_avg = total_end_values / @stop_data["results"].size

		delta_temp = (end_avg - start_avg).round(2) #if result is positive than temp went up
		delta_percent =  ((end_avg/start_avg)*100).round(2)
		if delta_temp > 0 
			delta_descr = "warmer" 
			delta_descr_2 = "increase"
		else 
			delta_descr = "colder"
			delta_descr_2 = "decrease"
		end

		@delta_t = [delta_temp, delta_percent, delta_descr, delta_descr_2]#returns as array with absolute change and percentage
	end
end