require 'test/unit'
require 'rspec-expectations'

module TrelloPipes
	class VelocityCalculatorAdapter
		def initialize(successor)
			@successor = successor
		end

		def push(cards)
			complexity = 0
			complexity = cards.inject(complexity) do |complexity, card|
				complexity + CardComplexity.new(card).complexity
			end
			@successor.push(complexity)
		end
	end

	class CardComplexity 
		attr_reader :complexity

		COMPLEXITY_REGEX = /\(\d*\)/

		def initialize(trello_card)
			complexity_match = trello_card.name.match(COMPLEXITY_REGEX)
			@complexity = (complexity_match.to_s.delete! '()').to_i
		end
	end
end

class VelocityCalculatorAdapterTests < Test::Unit::TestCase
	include TrelloPipes

	def test_no_cards_outputs_zero
		mock_display = MockDisplay.new
		no_cards = []
		VelocityCalculatorAdapter.new(mock_display).push(no_cards)
		expect(mock_display.velocity).to eql(0)
	end

	def test_one_card_with_velocity
		velocity = rand(1..13)
		mock_display = MockDisplay.new
		one_card = [FakeCard.new("(#{velocity}) bob")]
		VelocityCalculatorAdapter.new(mock_display).push(one_card)
		expect(mock_display.velocity).to eql(velocity)
	end

	def test_multiple_cards_with_velocity
		velocity1 = rand(1..13)
		velocity2 = rand(1..13)
		velocity3 = rand(1..13)
		mock_display = MockDisplay.new
		multiple_cards = [
			FakeCard.new("(#{velocity1}) bob1"),
			FakeCard.new("(#{velocity2}) bob2"),
			FakeCard.new("(#{velocity3}) bob3")
		]
		VelocityCalculatorAdapter.new(mock_display).push(multiple_cards)
		expect(mock_display.velocity).to eql(velocity1 + velocity2 + velocity3)
	end

	def test_one_card_with_velocity_and_one_without
		velocity = rand(1..13)
		mock_display = MockDisplay.new
		one_card_with_velocity_and_one_without = [
			FakeCard.new("bob1 (#{velocity})"),
			FakeCard.new("bob2")
		]
		VelocityCalculatorAdapter.new(mock_display).push(one_card_with_velocity_and_one_without)
		expect(mock_display.velocity).to eql(velocity)
	end
end

class MockDisplay
	attr_reader :velocity

	def push(velocity)
		@velocity = velocity
	end
end

class FakeCard
	attr_reader :name

	def initialize(name)
		@name = name
	end
end