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