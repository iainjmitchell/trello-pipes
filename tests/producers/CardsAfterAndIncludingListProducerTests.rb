require 'test/unit'
require 'rspec-expectations'
require 'securerandom'
require_relative '../../lib/trello/producers/CardsAfterAndIncludingListProducer'

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

	def test_that_multiple_cards_are_produced_when_board_has_list_with_multiple_cards
		list_name = "a list #{SecureRandom.uuid}"
		card1 = FakeCard.new
		card2 = FakeCard.new
		card3 = FakeCard.new
		mock_successor = MockSuccessor.new
		board_with_list = FakeBoard.new
		list_with_multiple_cards = FakeList.new(list_name)
		list_with_multiple_cards
			.add(card1)
			.add(card2)
			.add(card3)
		board_with_list.add(list_with_multiple_cards)
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_list)
		producer.produce(list_name)
		expect(mock_successor.pushed_cards).to eql([card1, card2, card3])
	end

	def test_that_multiple_cards_are_produced_when_board_has_cards_across_multiple_lists_after_and_inc_referenced_list
		list_name = "a list #{SecureRandom.uuid}"
		card1 = FakeCard.new
		card2 = FakeCard.new
		card3 = FakeCard.new
		mock_successor = MockSuccessor.new
		board_with_multiple_lists = FakeBoard.new
		referenced_list = FakeList.new(list_name)
		referenced_list
			.add(card1)
		list_after = FakeList.new('list after')
			.add(card2)
			.add(card3)
		board_with_multiple_lists.add(referenced_list)
		board_with_multiple_lists.add(list_after)
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_multiple_lists)
		producer.produce(list_name)
		expect(mock_successor.pushed_cards).to eql([card1, card2, card3])
	end

	def test_that_cards_in_earlier_lists_are_not_included
		list_name = "a list #{SecureRandom.uuid}"
		card1 = FakeCard.new
		card2 = FakeCard.new
		card3 = FakeCard.new
		mock_successor = MockSuccessor.new
		board_with_multiple_lists = FakeBoard.new
		earlier_list = FakeList.new('earlier')
			.add(card1)
			.add(card2)
		referenced_list = FakeList.new(list_name)
		referenced_list
			.add(card3)
		board_with_multiple_lists.add(earlier_list)
		board_with_multiple_lists.add(referenced_list)
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_multiple_lists)
		producer.produce(list_name)
		expect(mock_successor.pushed_cards).to eql([card3])
	end

	def test_list_with_name_that_includes_referenced_name
		referenced_list_name = "a list #{SecureRandom.uuid}"
		card1 = FakeCard.new
		card2 = FakeCard.new
		card3 = FakeCard.new
		mock_successor = MockSuccessor.new
		board_with_list = FakeBoard.new
		list_with_multiple_cards = FakeList.new("(1) #{referenced_list_name}")
		list_with_multiple_cards
			.add(card1)
			.add(card2)
			.add(card3)
		board_with_list.add(list_with_multiple_cards)
		producer = CardsAfterAndIncludingListProducer.new(mock_successor, board_with_list)
		producer.produce(referenced_list_name)
		expect(mock_successor.pushed_cards).to eql([card1, card2, card3])
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
		self
	end
end