class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :start_date_temp, :stop_date, :state, :delta_temp

	def initialize
		current_date = DateTime.now.to_date.strftime("%F")
		date_array = current_date.split("-")
		date_array[0] = date_array[0].to_i-1
		@std_stop_date = date_array.join("-") #Dataset doesn't go to 2016 so need to use 2015 as maximum year.
	end

	def call
		puts ""
		puts "Welcome to the Climate Tracker - New England"
		puts ""
		puts ""
		puts "This Climate Tracker displays the average monthly temperature for any date the User requests for New England."
		puts ""

		@input = ""
		until @input == "exit" do
			puts "Please type 'start' to find average temperatures across New England, 'compare' to find the change in temperature between two dates."

			@input = gets.strip.downcase
			if @input == "compare"
				self.compare
			elsif @input == "start"
				self.standard
			else 
				puts "Please enter either Start or Compare:"
				@input = gets.strip.downcase
				if @input == "compare"
					self.compare
				elsif @input == "start"
					self.standard
				else 
					puts "Please enter either Start or Compare:"
					@input = gets.strip.downcase
				end
			end

			puts ""
			puts "Would you like to try again? (type exit to exit)"
			@input = gets.strip.downcase
		end
	end

	def standard
		puts "This feature displays average monthly temperatures for New England for your chosen date.  Please enter a date: (DD/MM/YYY)"

		date = gets.strip
		until self.date_valid?(date)	
			puts "Invalid date or date format.  Please enter your target date: (DD/MM/YYY)"
			date = gets.strip
		end
		puts "Processing..."
		@start_date = self.standarize_date(date)

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
		until self.date_valid?(target_date)	
			puts "Invalid date or date format.  Please enter your target date (DD/MM/YYY)"
			target_date = gets.strip
		end
		@start_date = self.standarize_date(target_date)

		puts "Would you like to set a year to compare to? If not, will use one year ago today: #{@std_stop_date}. (y/n)"
		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a date: (DD/MM/YYY)"
			stop_date = gets.strip
			until self.date_valid?(stop_date)	
				puts "Invalid date or date format.  Please enter your target date: (DD/MM/YYY)"
				stop_date = gets.strip
			end
			@stop_date = self.standarize_date(stop_date)
		else
			@stop_date = @std_stop_date
		end

		puts "Processing..."
		@delta_temp = ClimateTracker::NOAA_Data.new.temp_difference(@start_date, @stop_date)

		@delta_temp.each do |state, state_changes|
			puts "In #{state}, #{@stop_date} was #{state_changes[0]}°F #{state_changes[2]} than #{@start_date} (#{(state_changes[1]-100).round(2)}% #{state_changes[3]})!"
		end
	end

	def date_valid?(date)
		date =~ /\A\d{2}\/\d{2}\/\d{4}\z/ ? true : (return false)
		date_array = date.split("/")
		date_array[0].to_i > 00 ? true : (return false)
		date_array[1].to_i > 00 ? true : (return false)
		date_array[2].to_i > 1775 && date_array[2].to_i < 2016 ? true : (return false)
	end

	def standarize_date(date)
		date_array = date.split("/")
		standard_date = date_array.reverse!.join("-")
	end

end

