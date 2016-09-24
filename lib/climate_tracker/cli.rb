class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :start_date_temp, :stop_date, :delta_temp, :data_set

	def initialize
		current_date = DateTime.now.to_date.strftime("%F")
		date_array = current_date.split("-")
		date_array[0] = date_array[0].to_i-1
		@std_stop_date = date_array.join("-") #Dataset doesn't go to 2016 so need to use 2015 as maximum year.
		@data_set = ClimateTracker::NOAA_Data.new
	end

	def call
		puts ""
		puts "Welcome to the Climate Tracker - New England"
		puts ""
		puts ""
		puts "This Climate Tracker displays the average monthly temperature for any date the User requests for New England."
		puts ""
		puts "Before we begin, a target state must be entered (this can be changed later if desired)."
		self.pick_state

		@input = ""
		until @input == "exit" do

			puts "Please type 'list' to find average temperatures for your chosen state, 'compare' to find the change in temperature between two dates, 'exit' to exit."

			@input = gets.strip.downcase
			until self.input_valid? do
				puts "Please enter either 'list' or 'compare':"
				@input = gets.strip.downcase
			end

			if @input == "compare"
				self.compare
			elsif @input == "list"
				self.list
			elsif @input == "exit"
				break
			end
		end
	end

	def pick_state
		puts "Please pick your desired state. To see a list of state codes, type 'states':"
		state = gets.strip.upcase
		if state == 'STATES' || state == 'STATE'
			puts "Gathering states..."
			puts "#{ClimateTracker::NOAA_Data.states}"
			puts ""
			self.pick_state
		else
			@state = state
		end
	end


	def list
		puts "This function will return the average monthly temperature for a given date in your chosen state."
		puts ""
		puts "Would you still like to use the target state: #{@state}? (y/n)"
		@input = gets.strip.downcase
		if @input == "y"
			if @data_set.pull_count > 0
				@data_set.re_pull = false
			end
		elsif @input == "n"
			puts "Please pick a target state:"
			self.pick_state
		end

		puts "Great. Now please pick a date (DD/MM/YYY)"
		date = self.pick_date
		@start_date = self.standarize_date(date)

		puts "Processing..."
		#download avg monthly temp values for date & state, find average for year.
		temp = @data_set.pull_data(@start_date, @state).gather_values
		puts "#{@state}'s monthly average temperature on #{@start_date} was #{temp}°F."
		@input = ""
		puts "Would you like to pick a new state or compare this result to another date? (list or compare)"
	end 

	def compare
		puts "This is the temperature change calculator. To begin, please answer a couple questions:"
		puts ""

		puts "Would you still like to use the target state: #{@state}? (y/n)"
		@input = gets.strip.downcase
		if @input == "y"
			@data_set.re_pull = false
		elsif @input == "n"
			puts "Please pick a target state:"
			self.pick_state
		end

		if @data_set.pull_count >= 1
			puts "Would you like to pick a new target date? Current target is #{@start_date}"
			@input = gets.strip.downcase
			if @input == "y"
				puts "What is your target date? (DD/MM/YYY)"
				target_date = self.pick_date
				@start_date = self.standarize_date(target_date)
			else
				@data_set.re_pull = false
			end
		else
			puts "What is your target date? (DD/MM/YYY)"
			target_date = self.pick_date
			@start_date = self.standarize_date(target_date)
		end

		puts "Would you like to set a year to compare to? If not, will use one year ago today: #{@std_stop_date}. (y/n)"
		decide = gets.strip
		if decide == "y" || decide == "yes"
			puts "Please pick a date: (DD/MM/YYY)"
			stop_date = self.pick_date
			@stop_date = self.standarize_date(stop_date)
		else
			@stop_date = @std_stop_date
		end

		puts "Processing..."
		@delta_temp = @data_set.temp_difference(@start_date, @stop_date, @state)

		puts "In #{@state}, #{@stop_date} was #{@delta_temp[0]}°F #{@delta_temp[2]} than #{@start_date} (#{(@delta_temp[1]-100).round(2)}% #{@delta_temp[3]})!"
	end

	def pick_date
		new_date = gets.strip
		until self.date_valid?(new_date)	
			puts "Invalid date or date format.  Please enter your target date: (DD/MM/YYY)"
			new_date = gets.strip
		end
		new_date
	end

	def date_valid?(date)
		date =~ /\A\d{2}\/\d{2}\/\d{4}\z/ ? true : (return false)
		date_array = date.split("/")
		date_array[0].to_i > 00 && date_array[0].to_i < 31 ? true : (return false)
		date_array[1].to_i > 00 && date_array[1].to_i < 12 ? true : (return false)
		date_array[2].to_i > 1775 && date_array[2].to_i < 2016 ? true : (return false)
	end

	def standarize_date(date)
		date_array = date.split("/")
		standard_date = date_array.reverse!.join("-")
	end

	def input_valid?
		@input == "compare" || @input == "list" || @input == "exit" ? true : false
	end
end

