require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @letters
  end

  def score
    # get the guessed word
    word = params[:word]
    letters = params[:letter_grid].split('')

    # check if the letters in the word, are present in the grid
    word_in_grid = word.upcase.chars.all? do |letter|
      word.upcase.count(letter) <= letters.count(letter)
    end

    @total_score = cookies[:score].to_i || 0
    @score = 0

    # early abort
    unless word_in_grid
      @result = 'you must only use letters in the grid! fool!'
      return
    end

    # check the dictionary and check that the word is in the dictionary
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response = JSON.parse(URI.open(url).read)
    word_is_valid = response['found']

    # abort if not english word
    unless word_is_valid
      @result = 'this word looks a little funky to me...'
      return
    end

    @result = 'great scott! you found a word!'

    @score = word.length

    # cookies[:score] = nil
    # @total_score = 0
    @total_score += @score
    cookies[:score] = @total_score
  end

  #   # raise
  #   def run_game(attempt, grid, start_time, end_time)
  #     url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
  #     user_serialized = URI.open(url).read
  #     user = JSON.parse(user_serialized)
  #     attempt_in_grid = attempt.upcase.chars.all? do |letter|
  #       attempt.upcase.count(letter) <= grid.count(letter)
  #   end

  #   time_taken_to_answer = (end_time - start_time)
  # if attempt_in_grid
  #   if user["found"]
  #     score = (attempt.length) / time_taken_to_answer
  #     { time: time_taken_to_answer, score: score, message: "well done" }
  #   else
  #     { time: time_taken_to_answer, score: 0, message: "not an english word" }
  #   end
  # else
  #   { time: time_taken_to_answer, score: 0, message: "not in the grid" }
  # end

  def generate_grid(grid_size)
    letters = []
    vowels = %w[A E I O U]
    consonants = %w[B C D F G H J K L M N P Q R S T V W X Y Z]

    num_vowels = 4
    num_vowels.times { letters << vowels.sample }
    (grid_size - num_vowels).times { letters << consonants.sample }

    letters.shuffle

    # (0...grid_size).map { ("A".."Z").to_a[rand(26)] }
  end
end
