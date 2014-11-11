require 'test/unit'
require 'rspec-expectations'
require 'securerandom'

module TrelloPipes
	class CardNameContainsFilter
		def initialize(parameters)
			@successor = parameters[:successor]
		end

		def push(cards)
			@successor.push([])
		end
	end
end


class CardNameContainsFilterTests < Test::Unit::TestCase
	include TrelloPipes

	def test_no_cards_outputs_no_cards
		mock_successor = MockSuccessor.new
		no_cards = []
		CardNameContainsFilter.new(
				successor: mock_successor,
				value: 'bob')
			.push(no_cards)
		expect(mock_successor.pushed_cards.size).to eql(0)
	end
end

class FakeCard
	attr_reader :name

	def initialize(name)
		@name = name
	end
end

class MockSuccessor 
	attr_reader :pushed_cards 

	def push(cards)
		@pushed_cards = cards
	end
end