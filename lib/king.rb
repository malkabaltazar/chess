require_relative "player"

class King
  attr_reader :piece, :starting_row
  attr_accessor :moved

  def initialize(piece, rook, moved)
    @piece = piece
    @rook = rook
    @moved = moved
    if @piece == "\u2654"
      @starting_row = 7
    else
      @starting_row = 0
    end
  end

  def valid_moves(board, row, column, prev_moves)
    moves = []
    [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0],
    [1, 1]].each do |i, j|
      if (0..7).include?(row + i) && (0..7).include?(column + j)
        moves << [row + i, column + j]
      end
    end
    moves.push(*castling(board, row, column))
    moves
  end

  def castling(board, row, column)
    moves = []
    if @moved == false
      if @rook.a_moved == false &&
        board[@starting_row][1] == " " && board[@starting_row][2] == " " &&
        board[@starting_row][3] == " "
      then
        moves << [row, column - 2]
      end
      if @rook.h_moved == false &&
        board[@starting_row][5] == " " && board[@starting_row][6] == " "
      then
        moves << [row, column + 2]
      end
    end
    moves
  end
end
