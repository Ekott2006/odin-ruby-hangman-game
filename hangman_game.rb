require 'json'

class Hangman
  MAX_ATTEMPTS = 12

  attr_accessor :name, :score, :secret_word, :wrong_guesses, :guess_word

  def initialize(name, score = 0, secret_word = nil, wrong_guesses = '', guess_word = nil)
    secret_word, guess_word = Hangman.generate_random_word if secret_word.nil? && guess_word.nil?
    @name = name
    @score = score
    @secret_word = secret_word
    @wrong_guesses = wrong_guesses
    @guess_word = guess_word
  end

  def self.restart(game)
    new_game = Hangman.new(game.name)
    new_game.score = game.score + 1
    new_game
  end

  def self.handle_option(option, array)
    option = option.downcase != 'n'
    game = nil

    if option
      if array.empty?
        puts 'Saved Game is empty, create a new user'
        return handle_option('n', array)
      end

      array.each_with_index { |value, i| puts "#{i + 1}: #{value['name']}" }
      num = get_user_choice(array.length)
      user = array[num - 1]
      game = Hangman.new(user['name'], user['score'], user['secret_word'], user['wrong_guesses'], user['guess_word'])
    else
      name = get_user_name
      game = Hangman.new(name)
    end
    game
  end

  def self.save(game)
    filename = 'saved_game.json'
    parsed_array = JSON.parse(File.read(filename))
    index = parsed_array.find_index { |value| value['name'] == game.name }
    index.nil? ? parsed_array << game.to_json : parsed_array[index] = game.to_json
    File.write(filename, JSON.generate(parsed_array))
    puts '-------------------------------------------------------------'
    puts 'SAVE SUCCESSFUL'
  end

  def self.get_data
    filename = 'saved_game.json'
    JSON.parse(File.read(filename))
  end

  def pretty_print_result
    puts '----------------------------------------------------------------------------------------------'
    puts "Player name: #{@name}"
    puts "Score: #{@score} \t\t\t\t Guesses left: #{MAX_ATTEMPTS - @wrong_guesses.split(/\s+/).length}"
    puts "Wrong Guesses: #{@wrong_guesses.split(/\s+/)}"
    puts "\n#{@guess_word}\n\n"
    handle_answer
  end

  def pretty_end_game
    puts '------------------------------------------------------------------------------------------------'
    puts "\n#{@guess_word}\n\n"
    puts 'You won!!!!' if @guess_word == @secret_word
    puts 'Try harder next time' if @guess_word != @secret_word
    print "\n Do you want to play again? Press 'y' to continue or 'n' to quit (or any other key is 'y'): "
    gets.chomp.to_s.downcase != 'n'
  end

  def to_json(*)
    { name: @name, score: @score, secret_word: @secret_word, wrong_guesses: @wrong_guesses, guess_word: @guess_word }
  end

  private

  def self.generate_random_word
    lines = File.read('google-10000-english-no-swears.txt').split(/\s+/)
    secret_word = lines.select { |line| line.length.between?(5, 12) }.sample
    guess_word = secret_word.gsub(/[A-Za-z]/, '_')
    [secret_word, guess_word]
  end

  def handle_answer
    answer = ''
    until answer.length > 0
      print "Enter a letter or the full words or 'save' to save progress (e.g 'l' or 'man'): "
      answer = gets.chomp.to_s.downcase
    end
    Hangman.save(self) if answer == 'save'
    update_char(answer) if answer.length == 1 && answer.match?(/[A-Za-z]/)
    update_word(answer) if answer.length > 1 && answer.match?(/[A-Za-z]/) && answer != 'save'
  end

  def update_char(char)
    updated = false
    @secret_word.length.times do |i|
      next unless @secret_word[i] == char

      @guess_word[i] = char
      updated = true
    end
    @wrong_guesses << "#{char} " unless updated || @wrong_guesses.match?(char)
  end

  def update_word(word)
    if @secret_word == word
      @guess_word = @secret_word
    else
      @wrong_guesses << "#{word} "
    end
  end

  def self.get_user_choice(max)
    num = 0
    until num.between?(1, max)
      print "Choose a user [1 - #{max}]: "
      num = gets.chomp.to_i
    end
    num
  end

  def self.get_user_name
    name = ''
    until name.length > 0
      puts "NOTE: If a player with the same name exists, it will override it"
      print 'Enter your name: '
      name = gets.chomp.to_s
    end
    name
  end
end
