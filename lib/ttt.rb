require 'bundler/setup'

class Player
  def initialize(board)
    @board = board
  end
end

class Human < Player
  def choose_move
    @board.show_board

    puts "Choose one: #{@board.formatted_options}"
    loop do
      input = gets.chomp.to_i
      break input if @board.options_list.include?(input)
      puts "Invalid choice! Choose one: #{@board.formatted_options}"
    end
  end
end

class Computer < Player
  def choose_move
    @board.options_list.sample
  end
end

class Board
  EMPTY_MARK = '-'

  def join_or(list, separator = ', ')
    return '' if list.empty?

    if list.size == 1
      list[0]
    elsif list.size == 2
      list.join(' or ')
    else
      list[0..-2].join(separator) + "#{separator}or " + list[-1]
    end
  end

  def initialize
    @vals = {}
    reset
  end

  def mark_spot(spot, mark)
    @vals[spot] = mark
  end

  def reset
    @vals = (1..9).map { |n| [n, EMPTY_MARK] }.to_h
  end

  def show_board
    puts "#{@vals[1]} | #{@vals[2]} | #{@vals[3]}"
    puts "#{@vals[4]} | #{@vals[5]} | #{@vals[6]}"
    puts "#{@vals[7]} | #{@vals[8]} | #{@vals[9]}"
  end

  def full?
    !@vals.values.any? { |val| val == EMPTY_MARK }
  end

  def filled_rows
    potential_winners = [
      [1, 2, 3], [4, 5, 6], [7, 8, 9],
      [1, 4, 7], [2, 5, 8], [3, 6, 9],
      [1, 5, 9], [3, 5, 7]
    ]

    potential_winners.map    { |list| list.map { |spot| @vals[spot] } }
                     .filter { |list| list.all? { |spot| spot != EMPTY_MARK } }
  end

  def winner?
    filled_rows.any? { |list| list.uniq.size == 1 }
  end

  def winning_mark
    filled_rows.filter { |list| list.uniq.size == 1 }[0][0]
  end

  def game_over?
    full? || winner?
  end

  def options_list
    @vals.filter { |_, val| val == EMPTY_MARK }.keys
  end

  def formatted_options
    join_or(options_list.map(&:to_s))
  end
end

class TTTGame
  MARK_OPTIONS = ['X', 'O']

  def initialize
    @board = Board.new
    @players = nil
    @markers = nil
    @score = nil
  end

  def valid_yn?(str)
    str =~ /^[yn]$/i
  end

  def pick_yn
    loop do
      choice = gets.chomp
      break choice.downcase if valid_yn?(choice)
      puts "Invalid choice!  Enter Y or N."
    end
  end

  def set_order
    puts "Go first?  Enter Y to go first, or N for the computer to go first."
    choice = pick_yn
    @players = [Human.new(@board), Computer.new(@board)]
    @players.reverse! if choice == 'n'
  end

  def set_markers
    puts "Do you want to use X?  Y to use X; N to use O instead."
    choice = pick_yn
    these_markers = (choice == 'y' ? MARK_OPTIONS : MARK_OPTIONS.reverse)

    @markers = {}
    @markers[@players.find { |p| p.class == Human }] = these_markers[0]
    @markers[@players.find { |p| p.class == Computer }] = these_markers[1]
  end

  def reset_score
    @score = @players.each_with_object({}) do |score, player|
      score[player] = 0
      score
    end
  end

  def setup_match
    set_order
    set_markers
    reset_score
  end

  def show_match_winner
    winner = @score.filter { |_, points| points >= 5 }.keys[0]
    puts "Winner: #{winner.class}"
  end

  def play
    puts "==> Welcome to Tic-Tac-Toe <=="

    loop do
      setup_match
      play_match
      show_match_winner
      puts "Play again?  Enter Y to play again, N to exit."
      break if pick_yn == 'n'
    end

    puts "==> Thanks for playing! <=="
  end

  def play_match
    until @score.values.any? { |val| val >= 5 }
      @board.reset
      play_one_game
    end
  end

  def show_score
    @players.each { |player| puts "#{player.class}: #{@score[player]}" }
  end

  def player_from_mark(mark)
    @markers.key(mark)
  end

  def update_score(winning_mark)
    @score[player_from_mark(winning_mark)] += 1
  end

  def show_game_result
    puts
    case player_from_mark(@board.winning_mark).class.name
    when 'Human' then puts 'Human won!'
    when 'Computer' then puts 'Computer won!'
    else
      puts 'Tie!'
    end
  end

  def play_one_game
    play_one_turn until @board.game_over?
    update_score(@board.winning_mark) if @board.winner?
    show_game_result
    show_score
    puts
  end

  def play_one_turn
    @players.each do |player|
      choice = player.choose_move
      @board.mark_spot(choice, @markers[player])
      break if @board.game_over?
    end
  end
end

TTTGame.new.play
