module TrelloPipes
	class CardContainsComplexityFilter
		def initialize(parameters)
			@successor = parameters[:successor]
		end

		def push(cards)
			complexity_cards = cards.select { | card | card.name.match(/\(\d*\)/)}
			@successor.push(complexity_cards)
		end
	end
end