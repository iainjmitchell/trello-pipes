require 'test/unit'
require 'rspec-expectations'
require 'date'
require 'time'

module TrelloPipes
	class EnteredListAfterDateFilter
		def initialize(successor, date, list_name, trello_board)
			@successor = successor
			@list_name = list_name
			@date = Time.parse(date.to_s)
			@subsequent_list_names = 
				SubsequentListNameRepository.new(trello_board, list_name).get
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

class EnteredListAfterDateFilterTests < Test::Unit::TestCase
	include TrelloPipes

	def test_no_cards_in_no_cards_out
		mock_successor = MockSuccessor.new
		list_name = "a list #{rand(1..4)}"
		no_cards = []
		date = DateTime.now
		board = FakeBoard.new().add(FakeList.new(list_name))
		EnteredListAfterDateFilter.new(mock_successor, date, list_name, board)
			.push(no_cards)
		expect(mock_successor.pushed_cards).to eql([])
	end

	def test_one_card_that_entered_list_after_date
		mock_successor = MockSuccessor.new
		list_name = "a list #{rand(1..4)}"
		yesterday = DateTime.now - 1
		card_entered_after = FakeCardBuilder.create
			.moved_to(list_name)
			.today
			.build
		cards = [card_entered_after]
		board = FakeBoard.new().add(FakeList.new(list_name))
		EnteredListAfterDateFilter.new(mock_successor, yesterday, list_name, board)
			.push(cards)
		expect(mock_successor.pushed_cards).to eql([card_entered_after])
	end

	def test_one_card_that_entered_list_before_date
		mock_successor = MockSuccessor.new
		list_name = "a list #{rand(1..4)}"
		today = DateTime.now
		card_entered_after = FakeCardBuilder.create
			.moved_to(list_name)
			.days_ago(1)
			.build
		cards = [card_entered_after]
		board = FakeBoard.new().add(FakeList.new(list_name))
		EnteredListAfterDateFilter.new(mock_successor, today, list_name, board)
			.push(cards)
		expect(mock_successor.pushed_cards).to eql([])
	end

	def test_one_card_that_entered_list_on_date
		mock_successor = MockSuccessor.new
		list_name = "a list #{rand(1..4)}"
		today = DateTime.now
		card_entered_after = FakeCardBuilder.create
			.moved_to(list_name)
			.today
			.build
		cards = [card_entered_after]
		board = FakeBoard.new().add(FakeList.new("#{list_name} (1)"))
		EnteredListAfterDateFilter.new(mock_successor, today, list_name, board)
			.push(cards)
		expect(mock_successor.pushed_cards).to eql(cards)
	end

	def test_one_card_that_jumped_list_and_entered_next_before_date
		mock_successor = MockSuccessor.new
		list_name = "the list #{rand(1..5)}"
		next_list_name = "a list #{rand(1..4)}"
		today = DateTime.now
		card_entered_after = FakeCardBuilder.create
			.moved_to(next_list_name)
			.today
			.build
		cards = [card_entered_after]
		board = FakeBoard.new()
			.add(FakeList.new(list_name))
			.add(FakeList.new(next_list_name))
		EnteredListAfterDateFilter.new(mock_successor, today, list_name, board)
			.push(cards)
		expect(mock_successor.pushed_cards).to eql(cards)
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
		self
	end
end

class FakeList
	attr_reader :name

	def initialize(name)
		@name = name
	end
end

class FakeCardBuilder
	ONE_DAY = 86400

	def initialize
		@fake_card = FakeCard.new 
	end

	def self.create 
		FakeCardBuilder.new
	end

	def moved_to(list_name)
		return MovementBuilder.new(self, @fake_card, list_name)
	end

	def build
		@fake_card
	end

	class MovementBuilder
		def initialize(fake_card_builder, fake_card, list_name)
			@fake_card_builder = fake_card_builder
			@fake_card = fake_card
			@list_name = list_name
			@todays_date = Time.now
		end

		def today
			@fake_card.add_movement(list_name: @list_name, date: @todays_date)
			return @fake_card_builder
		end

		def days_ago(days)
			date = @todays_date - (ONE_DAY * days)
			@fake_card.add_movement(list_name: @list_name, date: date)
			return @fake_card_builder
		end
	end
end

class FakeCard
	attr_reader :actions

	def initialize
		@actions = []
	end

	def add_movement(parameters)
		action = FakeMovementAction.new(parameters)
		@actions.push(action)
	end
end

class FakeMovementAction 
	attr_reader :type, :data, :date

	def initialize(parameters)
		@type = 'updateCard'
		@date = parameters[:date]
		@data = {
			'listAfter' => {
				'name' => parameters[:list_name]
			}
		}
	end
end
