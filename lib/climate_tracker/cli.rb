class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :stop_date, :data_category, :state, :delta_temp, :delta_precip

	def initialize
		current_date = DateTime.now.to_date.strftime("%F")
		date_array = current_date.split("-")
		date_array[0] = date_array[0].to_i-1
		@std_stop_date = date_array.join("-") #Dataset doesn't go to 2016 so need to use 2015 as maximum year average.
		@data_category = "T" #used to expand app beyond Temperature
	end

	def call
		puts ""
		puts "Welcome to the Climate Tracker - New England"
		puts ""
		puts ""
		puts "This Climate Tracker displays the change in temperature that have occured within the user's lifetime among the states of New England"
		puts ""
		puts "Let's get started"
		puts ""

		puts "Which state in New England would you like to search? (VT, ME, MA, NH)"

		@state = gets.strip.upcase

		puts "What is your birthday? (DD/MM/YYY)"

		birthday = gets.strip
		start_date_array = birthday.split("/")
		@start_date = start_date_array.reverse!.join("-")

		puts "Would you like to set an alternative year to compare to? If not, will use today:#{std_stop_date}. (y/n)"

		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a year (DD/MM/YYY)"
			stop_date = gets.strip
			stop_date_array = stop_date.split("/")
			@stop_date = stop_date_array.reverse!.join("-")
		else
			@stop_date = @std_stop_date
		end

		self.compute
		puts "In #{state}, #{@stop_date} was #{@delta_temp[0]}°C #{delta_temp[2]} than #{@start_date} (#{(delta_temp[1]-100).round(2)}% #{delta_temp[3]})!"
	end

	def compute
		data = ClimateTracker::NOAAScraper.new(@state, @data_category, @start_date, @stop_date).scrape
		@delta_temp = data.temp_difference
		# @delta_precip = data.precip_difference
	end
end


