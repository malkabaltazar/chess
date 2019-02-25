class Pawn
  attr_reader :piece, :direction, :starting_row

  def initialize(piece)
    @piece = piece
    if @piece == "\u2659"
      @direction = -1
      @starting_row = 6
      @enemy_pieces = ["\u265A", "\u265B", "\u265C", "\u265D", "\u265E", "\u265F"]
    else
      @direction = 1
      @starting_row = 1
      @enemy_pieces = ["\u2654", "\u2655", "\u2656", "\u2657", "\u2658", "\u2659"]
    end
  end

  def valid_moves(board, row, column, prev_move)
    moves = []
    if row == @starting_row &&
      board[row + @direction + @direction][column] == " "
    then
      moves << [row + @direction + @direction, column]
    end
    moves << [row + @direction, column] if board[row + @direction][column] == " "
    moves.push(*capture(board, row, column))
    moves.push(*en_passant(board, row, column, prev_move))
    moves
  end

  def capture(board, row, column)
    moves = []
    if @enemy_pieces.include?(board[row + @direction][column + 1])
      moves << [row + @direction, column + 1]
    end
    if @enemy_pieces.include?(board[row + @direction][column - 1])
      moves << [row + @direction, column - 1]
    end
    moves
  end

  def en_passant(board, row, column, prev_move)
    return [] if prev_move == nil
    prev_origin = prev_move[0]
    prev_target = prev_move[1]
    moves = []
    if row - @direction - @direction - @direction == @starting_row &&
      board[prev_target[0]][prev_target[1]] == @enemy_pieces[5] &&
      prev_target[0] == prev_origin[0] - @direction - @direction &&
      prev_target[1] == prev_origin[1] &&
      prev_target[0] == row
    then
      if board[row][column + 1] == @enemy_pieces[5]
        moves << [row + @direction, column + 1]
      end
      if board[row][column - 1] == @enemy_pieces[5]
        moves << [row + @direction, column - 1]
      end
    end
    moves
  end
end
