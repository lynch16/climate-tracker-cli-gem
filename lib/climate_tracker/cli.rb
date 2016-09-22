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
		@input = ""
		unless @input == "exit" do
			puts ""
			puts "Welcome to the Climate Tracker - New England"
			puts ""
			puts ""
			puts "This Climate Tracker displays the average monthly temperature for any date the User requests for New England."
			puts ""
			puts "Let's get started. Please enter 'start' to find average temperatures across NE, 'compare' to find the change in temperature between two dates."

			@input = gets.strip.downcase
			if @input == "compare"
				self.compare
			elsif @input == "start"
				self.standard
			end

			puts ""
			puts "Would you like to try another date (enter 'start') or compare two dates (enter 'compare')?"
			@input = gets.strip.downcase
		end
	end

	def standard
		puts "This program displays average monthly temperatures for New England for your chosen date.  Please enter a date: (DD/MM/YYY)"

		date = gets.strip
		puts "Processing..."
		start_date_array = date.split("/")
		@start_date = start_date_array.reverse!.join("-")

		@start_date_temp = ClimateTracker::NOAA_Data.new.pull_data(@start_date).gather_values
		@start_date_temp.each do |state, state_temp|
			puts "#{state}'s monthly average temperature on #{@start_date} was #{state_temp.round(2)}°F."
		end
	end 

	def compare
		puts "This is the temperature change calculator. To begin, please answer a couple questions:"
		puts ""

		puts "What is your target date? (DD/MM/YYY)"
		target_date = gets.strip
		start_date_array = target_date.split("/")
		@start_date = start_date_array.reverse!.join("-")

		puts "Would you like to set an alternative year to compare to? If not, will use one year ago today: #{@std_stop_date}. (y/n)"
		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a year (DD/MM/YYY)"
			stop_date = gets.strip
			stop_date_array = stop_date.split("/")
			@stop_date = stop_date_array.reverse!.join("-")
		else
			@stop_date = @std_stop_date
		end

		puts "Processing..."
		@delta_temp = ClimateTracker::NOAA_Data.new.temp_difference(@start_date, @stop_date)

		@delta_temp.each do |state, state_changes|
			puts "In #{state}, #{@stop_date} was #{state_changes[0]}°F #{state_changes[2]} than #{@start_date} (#{(state_changes[1]-100).round(2)}% #{state_changes[3]})!"
		end
	end
end

