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
		puts "This Climate Tracker displays the average monthly temperature for any date the User requests for New England. Also, Users can find the change in temperature that has occured within the user's lifetime"
		puts ""
		puts "Let's get started. Please enter 'start' to find average temperature, 'lifetime' to find amount of change in your lifetime."

		@input = gets.strip.downcase
		if @input == "lifetime"
			self.lifetime
		elsif @input == "start"
			self.standard
		end
	end

	def standard
		puts "This program displays average monthly temperatures for New England for your chosen date.  Please enter a date"

		date = gets.strip
		start_date_array = date.split("/")
		@start_date = start_date_array.reverse!.join("-")

	end 

	def lifetime
		puts "This is the 'In a Lifetime' calculator. To begin, please answer a few questions:"
		puts ""
		puts "Which state in New England would you like to search? (VT, ME, MA, NH)"

		@state = gets.strip.upcase

		puts "What is your birthday? (DD/MM/YYY)"

		birthday = gets.strip
		start_date_array = birthday.split("/")
		@start_date = start_date_array.reverse!.join("-")

		puts "Would you like to set an alternative year to compare to? If not, will use today: #{std_stop_date}. (y/n)"

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
		data = ClimateTracker::NOAAScraper.new(@state, @data_category, @start_date, @stop_date)
		data.data_today
		data.data_at_date
		@delta_temp = data.temp_difference 
		# @delta_precip = data.precip_difference
	end
end

