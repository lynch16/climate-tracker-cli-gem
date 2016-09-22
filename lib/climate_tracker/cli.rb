class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :start_date_temp, :stop_date, :data_category, :state, :delta_temp

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
		puts "This program displays average monthly temperatures for New England for your chosen date.  Please enter a date: (DD/MM/YYY)"

		date = gets.strip
		start_date_array = date.split("/")
		@start_date = start_date_array.reverse!.join("-")

		@start_date_temp = ClimateTracker::NOAA_Data.new.pull_data(@start_date).gather_values
		@start_date_temp.each do |state, state_temp|
			puts "#{state}'s monthly average temperature on #{@start_date} was #{state_temp.round(2)}°C."
		end
	end 

	def lifetime
		puts "This is the 'In a Lifetime' calculator. To begin, please answer a few questions:"
		puts ""

		puts "What is your birthday? (DD/MM/YYY)"
		birthday = gets.strip
		start_date_array = birthday.split("/")
		@start_date = start_date_array.reverse!.join("-")

		puts "Would you like to set an alternative year to compare to? If not, will use today: #{@std_stop_date}. (y/n)"
		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a year (DD/MM/YYY)"
			stop_date = gets.strip
			stop_date_array = stop_date.split("/")
			@stop_date = stop_date_array.reverse!.join("-")
		else
			@stop_date = @std_stop_date
		end

		puts "Thank you. Processing..."
		@delta_temp = ClimateTracker::NOAA_Data.new.temp_difference(@start_date, @stop_date)

		@delta_temp.each do |state, state_changes|
			puts "In #{state}, #{@stop_date} was #{state_changes[0]}°C #{state_changes[2]} than #{@start_date} (#{(state_changes[1]-100).round(2)}% #{state_changes[3]})!"
		end
	end
end

