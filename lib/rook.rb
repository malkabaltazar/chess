class Rook
  attr_reader :piece
  attr_accessor :a_moved, :h_moved

  def initialize(piece, a_moved, h_moved)
    @piece = piece
    @a_moved = a_moved
    @h_moved = h_moved
  end

  def valid_moves(board, row, column, prev_move)
    moves = []
    moves.push(*advance(board, row, column, 1))
    moves.push(*advance(board, row, column, -1))
    moves.push(*sideways(board, row, column, 1))
    moves.push(*sideways(board, row, column, -1))
    moves
  end

  def advance(board, row, column, direction)
    moves = []
    while (0..7).include?(row + direction)
      row += direction
      moves << [row, column]
      break if board[row][column] != " "
    end
    moves
  end

  def sideways(board, row, column, direction)
    moves = []
    while (0..7).include?(column + direction)
      column += direction
      moves << [row, column]
      break if board[row][column] != " "
    end
    moves
  end
end
