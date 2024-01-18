require_relative 'hangman_game'

puts "HANGMAN\n\n"
print "Do you want to load a saved game? Press 'y' to continue or 'n' to quit (or any other key is 'y'): "

game = Hangman.handle_option(gets.chomp.to_s, Hangman.get_data)
continue = true
while continue
  game.pretty_print_result while game.guess_word != game.secret_word && game.wrong_guesses.split(/\s+/).length < 12
  continue = game.pretty_end_game
  game = Hangman.restart(game)
end
