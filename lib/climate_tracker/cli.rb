class ClimateTracker::CLI
	attr_accessor :std_stop_date, :start_date, :start_date_temp, :stop_date, :delta_temp

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

			puts "Please type 'list' to find average temperatures for your chosen state, 'compare' to find the change in temperature between two dates, 'exit' to exit."

			@input = gets.strip.downcase
			until self.input_valid? do
				puts "Please enter either 'list' or 'compare':"
				@input = gets.strip.downcase
			end

			if @input == "compare"
				self.compare_new
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
			puts "#{ClimateTracker::NOAA_Data.states}"
			self.pick_state
		else
			@state = state
		end
	end


	def list
		puts "This feature displays average monthly temperatures for your chosen date and state. Before we begin, a target state must be entered (this can be changed later)."
		self.pick_state

		puts "Great. Now please pick a date (DD/MM/YYY)"
		date = gets.strip
		until self.date_valid?(date)	
			puts "Invalid date or date format.  Please enter your target date: (DD/MM/YYY)"
			date = gets.strip
		end
		puts "Processing..."
		@start_date = self.standarize_date(date)

		#create NOAA_Data obj; download avg monthly temp values for date & state, find average for year.
		@list_obj = ClimateTracker::NOAA_Data.new
		temp = @list_obj.pull_data(@start_date, @state).gather_values
		puts "#{@state}'s monthly average temperature on #{@start_date} was #{temp}°F."
		@input = ""
		puts "Would you like to pick a new state or compare this result to another date? (list or compare)"
	end 

	def compare_new
		puts "This is the temperature change calculator. To begin, please answer a couple questions:"
		puts ""

		puts "Please first pick a target state:"
		self.pick_state

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
		@compare_obj = ClimateTracker::NOAA_Data.new
		delta_temp = @compare_obj.temp_difference(@start_date, @stop_date, @state)

		puts "In #{@state}, #{@stop_date} was #{delta_temp[0]}°F #{delta_temp[2]} than #{@start_date} (#{(delta_temp[1]-100).round(2)}% #{delta_temp[3]})!"
	end

	def compare_prior
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

	def input_valid?
		@input == "compare" || @input == "list" || @input == "exit" ? true : false
	end
end

