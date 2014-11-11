require 'time'

module TrelloPipes
	class EnteredListAfterDateFilter
		def initialize(parameters)
			@successor = parameters[:successor]
			@list_name = parameters[:list]
			@date = Time.parse(parameters[:date].to_s)
			@subsequent_list_names = 
				SubsequentListNameRepository.new(parameters[:trello_board], @list_name).get
		end

		def push(cards)
			matching_cards = cards.select do | card |
				movement_action = find_movement_action(card.actions, @list_name, @subsequent_list_names)
				movement_action.date > @date
			end 
			@successor.push(matching_cards)
		end

		private 
		def find_movement_action(actions, list_name, subsequent_list_names)
			specification = MovementIntoListSpecification.new(list_name)
			movement_action = actions.find do | action |
				specification.is_satisified_by(action)
			end
			return movement_action unless movement_action.nil?
			return NullMovementAction.new if subsequent_list_names.empty?
			head, *tail = subsequent_list_names
			return find_movement_action(actions, head, tail)
		end
	end

	class MovementIntoListSpecification
		MOVE_INTO_LIST_ACTION = 'updateCard'
		def initialize(list_name)
			@list_name = list_name
		end

		def is_satisified_by(action)
			(action.type == MOVE_INTO_LIST_ACTION && 
					action.data && action.data['listAfter'] && 
						action.data['listAfter']['name'].include?(@list_name))
		end
	end

	class NullMovementAction
		attr_reader :date

		def initialize
			date = Time.at(0)
		end
	end

	class SubsequentListNameRepository
		def initialize(trello_board, list_name)
			list_names = trello_board.lists.map {|list| list.name}
			list_index = list_names.index {|name| name.match(list_name)}
			@subsequent_list_names = list_names.slice(list_index+1, list_names.size-1)
		end

		def get()
			@subsequent_list_names
		end
	end
end