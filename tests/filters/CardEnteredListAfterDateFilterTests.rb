require 'test/unit'
require 'rspec-expectations'
require 'date'

module TrelloPipes
	class CardEnteredListAfterDateFilter
		def initialize(successor, date)
			@successor = successor
		end

		def push(cards)
			@successor.push(cards)
		end
	end
end

class CardEnteredListAfterDateFilterTests < Test::Unit::TestCase
	include TrelloPipes

	def test_no_cards_in_no_cards_out
		mock_successor = MockSuccessor.new
		no_cards = []
		date = DateTime.now
		CardEnteredListAfterDateFilter.new(mock_successor, date).push(no_cards)
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
