require 'test/unit'
require 'rspec-expectations'
require 'securerandom'

module TrelloPipes
	class CardContainsComplexityFilter
		def initialize(successor)
			@successor = successor
		end

		def push(cards)
			@successor.push(cards)
		end
	end
end


class CardContainsComplexityFilterTests < Test::Unit::TestCase
	include TrelloPipes

	def test_no_cards_in_no_cards_out
		mock_successor = MockSuccessor.new
		no_cards = []
		CardContainsComplexityFilter.new(mock_successor).push(no_cards)
		expect(mock_successor.pushed_cards).to eql([])
	end
end

class FakeCard
end

class MockSuccessor 
	attr_reader :pushed_cards 

	def push(cards)
		@pushed_cards = cards
	end
end