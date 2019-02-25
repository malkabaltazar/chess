require_relative "board"
require "csv"

class Chess
  def initialize
    @white = Player.new("white")
    @black = Player.new("black")
    @white.enemy = @black
    @black.enemy = @white
    @board = Board.new(@white, @black)
    @current = @white
  end

  def play
    puts "Welcome to command line chess! Type save or reload at any time."
    @board.puts_board
    until @board.gameover
      input = @board.play(@current)
      save if input == "save"
      reload if input == "reload"
      switch
    end
  end

  private

  def switch
    if @current == @white
      @current = @black
    else
      @current = @white
    end
  end

  def save
    puts "Name your game:"
    name = gets.chomp
    game = [name, @board.board.flatten.join, @board.prev_move.flatten.join,
    @current.color, @white.king.moved, @white.rook.a_moved, @white.rook.h_moved,
    @black.king.moved, @black.rook.a_moved, @black.rook.h_moved]
    File.open("saved_games.csv", 'a') do |file|
      file.puts "#{game.join(",")}"
    end
    puts "Game saved."
    exit
  end

  def reload
    puts "What name is your game saved under?"
    i = 65
    contents = CSV.read "saved_games.csv", headers: true
    contents.each do |row|
      puts "(#{i.chr}) #{row["name"]}"
      i += 1
    end
    row = gets.chomp.upcase.ord-65
    begin
      @white = Player.new("white", contents[row]["@white.king"], contents[row]["@white.rook.a"], contents[row]["@white.rook.h"])
      @black = Player.new("black", contents[row]["@black.king"], contents[row]["@black.rook.a"], contents[row]["@black.rook.h"])
      @white.enemy = @black
      @black.enemy = @white
      prev_move = contents[row]["@prev_move"].split("")
      origin = [prev_move[0].to_i, prev_move[1].to_i]
      target = [prev_move[2].to_i, prev_move[3].to_i]
      @board = Board.new(@white, @black, contents[row]["@board"].split(""), [origin, target])
      if contents[row]["@current"] == "black" then @current = @white else @current = @black end
      @board.puts_board
    rescue
      puts "Invalid input."
    end
  end
end

Chess.new.play
