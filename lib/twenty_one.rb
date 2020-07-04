require 'bundler/setup'

class Card
  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @hidden = false
  end

  def hide
    @hidden = true
  end

  def unhide
    @hidden = false
  end

  def to_s
    if @hidden
      'unknown card'
    else
      "#{@rank} of #{@suit}"
    end
  end

  def value
    if @rank =~ /^\d+$/
      @rank.to_i
    elsif @rank == 'Ace'
      11
    else
      10
    end
  end
end

class Deck
  RANKS = [
    '2', '3', '4', '5', '6', '7', '8', '9', '10',
    'Jack', 'King', 'Queen', 'Ace'
  ]
  SUITS = %w(Hearts Diamonds Spades Clubs)

  def initialize
    @cards = []

    RANKS.each do |rank|
      SUITS.each { |suit| @cards << Card.new(rank, suit) }
    end
  end

  def draw_card
    @cards.shuffle!.pop
  end
end

class Participant
  attr_reader :cards

  def initialize
    @cards = []
  end

  def hide_card
    @cards[1].hide
  end

  def unhide_all_cards
    @cards.each(&:unhide)
  end

  def to_s
    if @cards.size == 2
      @cards.join(' and ')
    else
      @cards[0..-3].join(', ') + ', ' + @cards[-2..-1].join(', and ')
    end
  end

  def <<(card)
    @cards << card
  end
end

class TwentyOneGame
  def initialize
    @player = nil
    @dealer = nil
    @deck = nil
    @score = { player: 0, dealer: 0 }
  end

  def play
    puts '==> Welcome to Twenty One <=='
    puts 'First to 5 wins'

    loop do
      play_one_match
      break if !play_another_match?
    end

    puts 'Thanks for playing!'
  end

  def valid_yn?(str)
    !!(str =~ /^[yn]$/i)
  end

  def valid_hs?(str)
    !!(str =~ /^[hs]$/i)
  end

  def play_another_match?
    puts "Would you like to play another match?  Y or N"
    input = gets.chomp
    while !valid_yn?(input)
      puts "Invalid input, enter Y to play another match or N to quit!"
      input = gets.chomp
    end
    input.downcase == 'y'
  end

  def game_winner
    return :player if @score[:player] >= 5
    return :dealer if @score[:dealer] >= 5
  end

  def game_over?
    !!game_winner
  end

  def show_match_results
    puts "#{game_winner == :player ? 'Player' : 'Dealer'} won!"
  end

  def initialize_game
    @player = Participant.new
    @dealer = Participant.new
    @deck = Deck.new
  end

  def reset_score
    @score = { player: 0, dealer: 0 }
  end

  def play_one_match
    reset_score

    loop do
      play_one_game
      break if game_over?
    end

    show_match_results
  end

  def show_score
    puts "Current score: Player #{@score[:player]}, Dealer #{@score[:dealer]}"
  end

  def hit_or_stay_choice
    puts "Do you want to hit or stay?  H to hit, S to stay"
    input = gets.chomp

    until valid_hs?(input)
      puts "Invalid input!  H to hit, S to stay"
      input = gets.chomp
    end

    input.downcase
  end

  def score_hand(participant)
    points = participant.cards.map(&:value)
    score = points.inject(&:+)

    until score < 21 || !points.include?(11)
      points[points.index(11)] = 1
      score = points.inject(&:+)
    end

    score
  end

  def player_turn
    loop do
      puts "Dealer cards: #{@dealer}"
      puts "Player cards: #{@player} (#{score_hand(@player)} points)"

      break if hit_or_stay_choice == 's'
      @player << @deck.draw_card
      break if busted?(@player)
    end
  end

  def busted?(participant)
    score_hand(participant) > 21
  end

  def dealer_turn
    until score_hand(@dealer) >= 17
      @dealer << @deck.draw_card
      puts "Dealer hit!"
      break if busted?(@dealer)
      gets.chomp
    end
  end

  def deal_hands
    2.times do
      @player << @deck.draw_card
      @dealer << @deck.draw_card
    end
  end

  def winner
    if busted?(@player)
      :dealer
    elsif busted?(@dealer)
      :player
    elsif score_hand(@player) > score_hand(@dealer)
      :player
    elsif score_hand(@player) < score_hand(@dealer)
      :dealer
    end
  end

  def show_game_results
    game_winner = winner
    @dealer.unhide_all_cards

    puts
    puts "<============>"

    puts "Player cards: #{@player} (#{score_hand(@player)} points)"
    puts "Dealer cards: #{@dealer} (#{score_hand(@dealer)} points)"

    if busted?(@player)
      puts 'Player busted!'
    elsif busted?(@dealer)
      puts 'Dealer busted!'
    end

    if !game_winner
      puts 'It was a tie!'
    else
      puts "#{game_winner.capitalize} won!"
    end

    puts "<============>"
    puts
  end

  def update_score
    game_winner = winner
    @score[game_winner] += 1 if game_winner
  end

  def play_one_game
    initialize_game
    deal_hands
    @dealer.hide_card

    player_turn
    dealer_turn unless busted?(@player)

    show_game_results
    update_score
    show_score
  end
end

TwentyOneGame.new.play
