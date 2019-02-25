class Queen
  attr_reader :piece

  def initialize(piece)
    @piece = piece
  end

  def valid_moves(board, row, column, prev_move)
    moves = []
    moves.push(*advance(board, row, column, 1))
    moves.push(*advance(board, row, column, -1))
    moves.push(*sideways(board, row, column, 1))
    moves.push(*sideways(board, row, column, -1))
    moves.push(*diagonal(board, row, column, 1, 1))
    moves.push(*diagonal(board, row, column, 1, -1))
    moves.push(*diagonal(board, row, column, -1, 1))
    moves.push(*diagonal(board, row, column, -1, -1))
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

  def diagonal(board, row, column, direction_r, direction_c)
    moves = []
    while (0..7).include?(row + direction_r) && (0..7).include?(column + direction_c)
      row += direction_r; column += direction_c
      moves << [row, column]
      break if board[row][column] != " "
    end
    moves
  end
end
