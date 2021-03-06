class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :start_date_temp, :stop_date, :delta_temp, :data_set

	def initialize
		current_date = DateTime.now.to_date.strftime("%F")
		date_array = current_date.split("-")
		date_array[0] = date_array[0].to_i-1
		@std_stop_date = date_array.join("-") #Dataset doesn't go to 2016 so need to use 2015 as maximum year.  Also need to format for API requirements
		@data_set = ClimateTracker::NOAA_Data.new
	end

	def call
		puts ""
		puts "Welcome to the Climate Tracker"
		puts ""
		puts ""
		puts "This Climate Tracker displays the average monthly temperature for any date the User requests for any state in the United States."
		puts ""

		@input = ""
		until @input == "exit" do

			puts "Please type 'list' to find average temperature for your chosen state at a selected date, 'compare' to find the change in temperature between two dates, 'exit' to exit."

			@input = gets.strip.downcase
			until self.input_valid? do
				puts "Invalid input. Please enter either 'list', 'compare' or 'exit':"
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

	def list
		puts "This function will return the average monthly temperature for a given date in your chosen state."
		puts ""

        if @state != nil
    		puts "Would you still like to use the target state: #{@state}? (y/n)"
    		@input = gets.strip.downcase
    		if @input == "n"
    			@data_set.re_pull = true
    			self.pick_state
    		end
        else
            self.pick_state
        end

		@start_date = self.pick_date

		puts "Processing: #{@start_date} for #{@state}..."
		#download avg monthly temp values for date & state, find average for month of year.
		temp = @data_set.pull_data(@start_date, @state).gather_values
		puts "#{@state}'s monthly average temperature on #{@start_date} was #{temp.round(2)}°F."
		@input = "" #clear input
		puts "Returning to Main Menu."
	end

	def compare
		puts "This is the temperature comparision calculator. To begin, please answer a couple questions:"
		puts ""

        if @state != nil
    		puts "Would you still like to use the target state: #{@state}? (y/n)"
    		@input = gets.strip.downcase
    		if @input == "n"
    			@data_set.re_pull = true
    			self.pick_state
    		end
        else
            self.pick_state
        end

		if @data_set.pull_count >= 1
			puts "Would you like to pick a new target date? Current target is #{@start_date}? (y/n)"
			@input = gets.strip.downcase
			if @input == "y"
				@start_date = self.pick_date
				@data_set.re_pull = true
			end
		else
			@start_date = self.pick_date
		end

		puts "Would you like to set a date to compare to? If not, will use one year ago today: #{@std_stop_date}. (y/n)"
		@input = gets.strip
		if @input == "y" || @input == "yes"
			@stop_date = self.pick_date
		else
			@stop_date = @std_stop_date
		end

		puts "Processing: #{@start_date} - #{@stop_date} for #{@state}..."
		@delta_temp = @data_set.temp_difference(@start_date, @stop_date, @state)

		puts "In #{@state}, #{@stop_date} was #{@delta_temp[0]}°F #{@delta_temp[2]} than #{@start_date} (#{(@delta_temp[1]-100).round(2)}% #{@delta_temp[3]})!"
	end

	def pick_state
		puts "Please pick your desired state. To see a list of states, type 'states':"
		state = gets.strip.upcase
		if state == 'STATES' || state == 'STATE'
			puts "Gathering states..."
			puts "#{ClimateTracker::NOAA_Data.states}" #list all states available in API
			puts ""
			self.pick_state
		elsif @data_set.class.states.include?(state)
			puts "Accepted."
			@state = state
		else
			puts "State not recognized."
			self.pick_state
		end
	end

	def pick_date
        puts "Please pick a target date (DD/MM/YYY)"
		new_date = gets.strip
		until self.date_valid?(new_date)
			puts "Invalid date or date format.  Please enter your target date: (DD/MM/YYY)"
			new_date = gets.strip
		end
		puts "Accepted."
		self.standarize_date(new_date)
	end

	def date_valid?(date)
		date =~ /\A\d{2}\/\d{2}\/\d{4}\z/ ? true : (return false) #entered with correct format?
		date_array = date.split("/")
		date_array[0].to_i > 00 && date_array[0].to_i < 31 ? true : (return false) #days between 0 and 31
		date_array[1].to_i > 00 && date_array[1].to_i < 12 ? true : (return false) #months between 1 and 12
		date_array[2].to_i > 1775 && date_array[2].to_i < 2016 ? true : (return false) #years within range
	end

	def standarize_date(date)
		date_array = date.split("/")
		standard_date = date_array.reverse!.join("-")
	end

	def input_valid?
		@input == "compare" || @input == "list" || @input == "exit" ? true : false
	end
end
