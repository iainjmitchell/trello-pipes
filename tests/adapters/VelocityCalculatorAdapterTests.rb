require 'test/unit'
require 'rspec-expectations'

module TrelloPipes
	class VelocityCalculatorAdapter
		def initialize(successor)
			@successor = successor
		end

		def push(cards)
			@successor.push(0)
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
end

class MockDisplay
	attr_reader :velocity

	def push(velocity)
		@velocity = velocity
	end
end