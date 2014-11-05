require 'test/unit'
require 'rspec-expectations'
require 'securerandom'

module TrelloPipes
	class CardsAfterAndIncludingListProducer
		def initialize(successor, trello_board)
			@successor = successor
		end

		def produce
			@successor.push([])
		end
	end
end

class CardsAfterAndIncludingListProducerTests < Test::Unit::TestCase
	include TrelloPipes

	def test_that_nothing_is_produced_when_board_has_no_lists
		mock_successor = MockSuccessor.new
		board_with_no_lists = FakeBoard.new
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_no_lists)
		producer.produce
		expect(mock_successor.pushed_cards.length).to eql(0)
	end


end

class MockSuccessor 
	attr_reader :pushed_cards 

	def push(cards)
		@pushed_cards = cards
	end
end

class FakeBoard
	attr_reader :lists 

	def initialize 
		@lists = []
	end

	def add(list)
		@lists.push(list)
	end
end