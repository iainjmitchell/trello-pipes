require 'test/unit'
require 'rspec-expectations'
require 'securerandom'
require_relative '../../lib/trello/filters/CardContainsComplexityFilter'

class CardContainsComplexityFilterTests < Test::Unit::TestCase
	include TrelloPipes

	def test_no_cards_in_no_cards_out
		mock_successor = MockSuccessor.new
		no_cards = []
		CardContainsComplexityFilter.new(successor: mock_successor)
			.push(no_cards)
		expect(mock_successor.pushed_cards).to eql([])
	end

	def test_one_card_with_complexity
		complexity = rand(1..13)
		mock_successor = MockSuccessor.new
		card_with_complexity = FakeCard.new("(#{complexity}) Hello")
		one_card_with_complexity = [card_with_complexity]
		CardContainsComplexityFilter.new(successor: mock_successor)
			.push(one_card_with_complexity)
		expect(mock_successor.pushed_cards).to eql(one_card_with_complexity)
	end

	def test_one_card_without_complexity
		mock_successor = MockSuccessor.new
		card_without_complexity = FakeCard.new('Hello')
		one_card_without_complexity = [card_without_complexity]
		CardContainsComplexityFilter.new(successor: mock_successor)
			.push(one_card_without_complexity)
		expect(mock_successor.pushed_cards).to eql([])
	end
end

class FakeCard
	attr_reader :name

	def initialize(name = 'no name')
		@name = name
	end
end

class MockSuccessor 
	attr_reader :pushed_cards 

	def push(cards)
		@pushed_cards = cards
	end
end