require_relative "king"
require_relative "queen"
require_relative "rook"
require_relative "bishop"
require_relative "knight"
require_relative "pawn"

class Player
  attr_reader :color, :king, :queen, :rook, :bishop, :knight, :pawn, :pieces
  attr_accessor :enemy

  def initialize(color, king = false, rook_a = false, rook_h = false)
    @color = color
    if @color == "white"
      @queen = Queen.new("\u2655")
      @rook = Rook.new("\u2656", rook_a, rook_h)
      @king = King.new("\u2654", @rook, king)
      @bishop = Bishop.new("\u2657")
      @knight = Knight.new("\u2658")
      @pawn = Pawn.new("\u2659")
    else
      @queen = Queen.new("\u265B")
      @rook = Rook.new("\u265C", rook_a, rook_h)
      @king = King.new("\u265A", @rook, king)
      @bishop = Bishop.new("\u265D")
      @knight = Knight.new("\u265E")
      @pawn = Pawn.new("\u265F")
    end
    @pieces = @king, @queen, @rook, @bishop, @knight, @pawn
  end

  def play(board)
    puts "#{@color.upcase}, enter a piece followed by coordinates. (e.g. Qg5)"
    arr = get_input
    return arr if arr == "save" || arr == "reload"
    while [@king, @queen, @rook, @bishop, @knight, @pawn].any? { |i| i.piece == board[arr[1]][arr[2]] }
      puts "You may not take your own piece. Try again."
      arr = get_input
    end
    arr
  end

  def which_one?(arr)
    return arr[0] if arr.length == 1
    puts "Enter the current location of the piece you would like to move:"
    i = 65
    arr.each do |row, column|
      puts "(#{i.chr}) #{(column.+97).chr}#{[8, 7, 6, 5, 4, 3, 2, 1][row]}"
      i += 1
    end
    response = gets.chomp.upcase.ord-65
    if arr[response] != nil
      return arr[response]
    else
      puts "Invalid input. PLease type 'A' or 'B' etc."
      which_one?(arr)
    end
  end

  private

  def get_input
    input = gets.chomp.split("")
    return "save" if input.join == "save"
    return "reload" if input.join == "reload"
    while input.length != 3
      puts "Be sure you type a letter for the piece, a letter representing a
column and a number representing the row you would like to move to with
no spaces between them. (e.g. Qg5)"
      input = gets.chomp.split("")
    end
    [get_piece(input[0].upcase), [7, 6, 5, 4, 3, 2, 1, 0][input[-1].to_i-1],
    input[-2].downcase.ord-97]
  end

  def get_piece(input)
    case input
    when "K"
      @king
    when "Q"
      @queen
    when "R"
      @rook
    when "B"
      @bishop
    when "N"
      @knight
    when "P"
      @pawn
    else
      puts "Please type 'K', 'Q', 'R', 'B', 'N', or 'P'."
      get_piece(gets.chomp.upcase)
    end
  end
end
