# ClimateTracker
## Installation
Execute:

    $ bundle

Or install it yourself as:

    $ gem install climate_tracker

## Usage

This gem will retrieve the temperature data for New Hampshire, Massachussetts, Vermont, and Maine for any defined date or range. The first prompt requests the user to enter Start or Compare (not case dependent).  The Start case will retreive a list of all the temperatures in all the included states for a given date.  The Compare option will provide a comparision of the average change in temperatures across those same states between two user defined dates.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/climate_tracker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

