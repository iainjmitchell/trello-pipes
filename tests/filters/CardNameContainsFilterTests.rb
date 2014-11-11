require 'test/unit'
require 'rspec-expectations'
require 'securerandom'

module TrelloPipes
	class CardNameContainsFilter
		def initialize(parameters)
			@successor = parameters[:successor]
			@search_term = parameters[:value]
		end

		def push(cards)
			puts "search: #{@search_term} value: #{cards[0].name}" if cards.size > 0
			if (cards.size > 0 && cards[0].name.include?(@search_term))
					@successor.push(cards)

			else

				@successor.push([])
			end
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

	def test_one_card_with_text_in_card_name
		mock_successor = MockSuccessor.new
		search_value = "terry#{rand(1..9)}"
		card_name = "should include #{search_value}"
		one_card = [FakeCard.new(card_name)]
		CardNameContainsFilter.new(
				successor: mock_successor,
				value: search_value)
			.push(one_card)
		expect(mock_successor.pushed_cards).to eql(one_card)
	end

	def test_one_card_without_text_in_card_name
		mock_successor = MockSuccessor.new
		search_value = "terry#{rand(1..9)}"
		card_name = "should not include"
		one_card = [FakeCard.new(card_name)]
		CardNameContainsFilter.new(
				successor: mock_successor,
				value: search_value)
			.push(one_card)
		expect(mock_successor.pushed_cards).to eql([])
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