require 'test/unit'
require 'rspec-expectations'
require 'securerandom'

module TrelloPipes
	class CardsAfterAndIncludingListProducer
		def initialize(successor, trello_board)
			@successor = successor
		end

		def produce(end_list_name)
			@successor.push([])
		end
	end
end

class CardsAfterAndIncludingListProducerTests < Test::Unit::TestCase
	include TrelloPipes

	def test_that_nothing_is_produced_when_board_has_no_lists
		list_name = "a list #{SecureRandom.uuid}"
		mock_successor = MockSuccessor.new
		board_with_no_lists = FakeBoard.new
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_no_lists)
		producer.produce(list_name)
		expect(mock_successor.pushed_cards.length).to eql(0)
	end

	def test_that_nothing_is_produced_when_board_has_list_BUT_no_cards
		list_name = "a list #{SecureRandom.uuid}"
		mock_successor = MockSuccessor.new
		board_with_list = FakeBoard.new
		board_with_list.add(FakeList.new(list_name))
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_list)
		producer.produce(list_name)
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

class FakeList
	attr_reader :name, :cards

	def initialize(name)
		@name = name
		@cards = []
	end

	def add(card)
		@cards.push(card)
	end
end