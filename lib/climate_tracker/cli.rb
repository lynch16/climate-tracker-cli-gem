class ClimateTracker::CLI
	attr_accessor :std_stop_year, :start_year, :stop_year, :data_category, :state, :delta_temp, :delta_precip

	def initialize
		current_year = DateTime.now.to_date.year
		@std_stop_year = current_year - 1 #Dataset doesn't go to 2016 so need to use 2015 as maximum year average.
	end

	def call
		puts "Welcome to the Climate Tracker - New England"
		puts "Which state in New England would you like to search? (VT, ME, MA, NH)"

		@state = gets.strip.upcase

		puts "Would you like to compare temperature or precipitation or both? (T, P, B)"

		@data_category = gets.strip.upcase

		puts "What is the start year? (YYY)"

		@start_year = gets.strip

		puts "Would you like to set an end year? If not, will use #{std_stop_year}. (y/n)"

		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a year (YYY)"
			@stop_year = gets.strip
		else
			@stop_year = @std_stop_year
		end

		self.compute
		puts "This year was #{@delta_temp[0]}°C warmer than #{@stop_year}, an increase of #{delta_temp[1]}%!"
	end

	def compute
		data = ClimateTracker::NOAAScraper.new(@state, @data_category, @start_year, @stop_year).scrape
		@delta_temp = data.temp_difference
		# @delta_precip = data.precip_difference
	end
end


