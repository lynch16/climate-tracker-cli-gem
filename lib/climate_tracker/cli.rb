class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :stop_date, :data_category, :state, :delta_temp, :delta_precip

	def initialize
		current_date = DateTime.now.to_date.strftime("%F")
		date_array = current_date.split("-")
		date_array[0] = date_array[0].to_i-1
		@std_stop_date = date_array.join("-") #Dataset doesn't go to 2016 so need to use 2015 as maximum year average.
	end

	def call
		puts ""
		puts "Welcome to the Climate Tracker - New England"
		puts ""
		puts "Which state in New England would you like to search? (VT, ME, MA, NH)"

		@state = gets.strip

		puts "Would you like to compare temperature or precipitation or both? (T, P, B)"

		@data_category = gets.strip.upcase

		puts "What is your birthday? (DD/MM/YYY)"

		birthday = gets.strip
		start_date_array = birthday.split("/")
		@start_date = start_date_array.reverse!.join("-")

		puts "Would you like to set an end year? If not, will use #{std_stop_date}. (y/n)"

		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a year (YYY)"
			@stop_date = gets.strip
		else
			@stop_date = @std_stop_date
		end

		self.compute
	end

	def compute
		data = ClimateTracker::NOAAScraper.new(@state, @data_category, @start_date, @stop_date).scrape
		# @delta_temp = data.temp_difference
		# @delta_precip = data.precip_difference
	end
end


