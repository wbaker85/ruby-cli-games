require 'bundler/setup'

class RPSPlayer
  include Comparable

  MOVE_CHOICES = [:rock, :paper, :scissors, :lizard, :spock]

  CHOICE_PRECENDENCE = {
    rock: [:scissors, :lizard],
    paper: [:rock, :spock],
    scissors: [:paper, :lizard],
    lizard: [:spock, :paper],
    spock: [:scissors, :rock]
  }

  attr_reader :move

  def initialize
    @move = nil
  end

  def join_or(list, separator = ', ')
    if list.size == 1
      list[0]
    elsif list.size == 2
      list.join(' or ')
    else
      list[0..-2].join(separator) + "#{separator}or " + list[-1]
    end
  end

  def formatted_choices
    choice_strings = MOVE_CHOICES.map(&:to_s)
    join_or(choice_strings)
  end

  def valid_choice?(choice_str)
    MOVE_CHOICES.any? { |choice| choice.to_s.start_with?(choice_str.downcase) }
  end

  def choice_from_str(choice_str)
    MOVE_CHOICES.find { |choice| choice.to_s.start_with?(choice_str.downcase) }
  end

  def <=>(other_player)
    if CHOICE_PRECENDENCE[move].include?(other_player.move)
      1
    elsif move == other_player.move
      0
    else
      -1
    end
  end
end

class Human < RPSPlayer
  def make_move
    p "Choose one: #{formatted_choices}"
    input = gets.chomp
    until valid_choice?(input)
      p "Invalid choice! Choose one of these: #{formatted_choices}"
      input = gets.chomp
    end
    @move = choice_from_str(input)
  end

  def to_sym
    :human
  end
end

class Computer < RPSPlayer
  def make_move
    @move = MOVE_CHOICES.sample
  end

  def to_sym
    :computer
  end
end

class RPSGame
  def initialize
    @score = nil
    @human_player = Human.new
    @computer_player = Computer.new
  end

  def valid_yes_no(str)
    str =~ /^[yn]$/i
  end

  def play
    show_welcome

    loop do
      reset_score
      play_match
      break if !play_again?
    end

    show_goodbye
  end

  def reset_score
    @score = { human: 0, computer: 0 }
  end

  def show_welcome
    puts "==> Welcome to RPS <=="
  end

  def play_match
    until @score.values.any? { |val| val >= 5 }
      play_one_game
    end
  end

  def play_again?
    p 'Do you want to play again?  Y for yes, N to exit.'
    input = gets.chomp
    until valid_yes_no(input)
      p 'Invalid input!  Please enter Y or N!'
      input = gets.chomp
    end
    input.downcase == 'y'
  end

  def show_goodbye
    puts "Thanks for playing!"
  end

  def play_one_game
    @human_player.make_move
    @computer_player.make_move
    winner = game_winner
    @score[winner.to_sym] += 1 unless winner.to_sym == :tie
    show_game_results(winner)
  end

  def game_winner
    if @human_player == @computer_player
      :tie
    else
      [@human_player, @computer_player].max
    end
  end

  def show_game_results(winner)
    puts
    puts "Human choice: #{@human_player.move}"
    puts "Computer choice: #{@computer_player.move}"
    puts "Winner: #{winner.to_sym}"
    puts "Current score: #{@score}"
    puts
  end
end

RPSGame.new.play
