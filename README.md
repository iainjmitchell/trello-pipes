trello-pipes
============

Pipes and filters for data from trello boards

##Introduction

This gem contains pipes, filters and adapters that can be used for analyising data on trello boards.  It was originally attended to help get stats such as cycle time and velocity, but could be used for a variety of means

##Installation

The package is installed on rubygems and can be installed using the following command

    gem install 'trello-pipes'

or adding the following to your Gemfile
    
    gem 'trello-pipes'

##Dependencies

The pipes require a board object from the ruby-trello gem to be passed into the producer(s).  You can either use this gem directly, or the anti-corruption layer that I put together, this is also available in ruby gems and is called 'trello-factory'.

##Example 

Here is an example used to return all the cards that went into a given column in the last 7 days.

```ruby
	
```
