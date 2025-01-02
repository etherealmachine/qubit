# Qubit
Short description and motivation.

## Features
* Create A/B tests with multiple variants
* Launch a test
* Canary a test and slowly roll it out to more traffic
* Close a test, routing all traffic to a specific variant
* Delete a test
* View the variants of a test before it's launched
* Specify events for a test
* Specify parameters for a test variant
* View metrics for a test
* Create and run censuses to test conditions on a set of subjects

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "qubit"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install qubit
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## TODO
* Mark test as closed and have index to filter by open/closed tests
* Test census sampling job
* Demo sampling from a census in a controller
* Close a census