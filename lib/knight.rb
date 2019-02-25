class Knight
  attr_reader :piece

  def initialize(piece)
    @piece = piece
  end

  def valid_moves(board, row, column, prev_move)
    moves = []
    [[-1, 2], [1, 2], [-2, 1], [2, 1], [-2, -1], [2, -1], [-1, -2],
    [1, -2]].each do |i, j|
      if (0..7).include?(row + i) && (0..7).include?(column + j)
        moves << [row + i, column + j]
      end
    end
    moves
  end
end
