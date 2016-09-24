# ClimateTracker
## Installation
Execute:

    $ bundle

Or install it yourself as:

    $ gem install climate_tracker

## Usage

This gem uses NOAA Climate API to retrieve the temperature data for any state in the U.S. for any defined date or range. There are two functions of the gem: Start and Compare (not case dependent).  The Start function will retreive a list of the average monthly temperature in the desired state for a given date.  This is found by averaging the average monthly temperature of every NOAA Station in the given state.  The Compare function will provide a comparision of the average change in average monthly temperatures in a state between two user defined dates. Of note, NOAA only has published through 2015 so the datasets are limited to February 1, 1831 - November 1, 2015.  The most recent available date should improve overtime and this README will be updated at each major version to correct the most recent date of that time.  This gem is also set to try and limit the number of queries from NOAA Climate API through the use of a "pull_count".  The overall average from the prior search will save allowing the user to more quickly use the Compare function.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/climate_tracker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

