module TrelloPipes
	class CardsAfterAndIncludingListProducer
		def initialize(parameters)
			@successor = parameters[:successor]
			@trello_board = parameters[:trello_board]
		end

		def produce(list_name)
			lists = get_lists_after_and_including(list_name)
			cards = all_cards_from(lists)
			@successor.push(cards)
		end

		private
		def get_lists_after_and_including(list_name)
			list_index = @trello_board.lists.index { | list | list.name.match(list_name) }
			return [] if list_index.nil?
			@trello_board.lists.slice(list_index, @trello_board.lists.size)
		end

		def all_cards_from(lists)
			return [] if lists.empty?
			head, *tail = lists
			return head.cards + all_cards_from(tail)
		end
	end
end