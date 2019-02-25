require_relative "player"

class Board
  attr_reader :gameover, :board, :prev_move

  def initialize(white, black, board = [], prev_move = nil)
    @white = white
    @black = black
    @board = board
    if @board == []
      8.times { @board.push([" ", " ", " ", " ", " ", " ", " ", " "]) }
      @board[0] = [@black.rook.piece, @black.knight.piece, @black.bishop.piece,
                   @black.queen.piece, @black.king.piece, @black.bishop.piece,
                   @black.knight.piece, @black.rook.piece]
      @board[1] = []; 8.times { @board[1] << @black.pawn.piece }
      @board[6] = []; 8.times { @board[6] << @white.pawn.piece }
      @board[7] = [@white.rook.piece, @white.knight.piece, @white.bishop.piece,
                   @white.queen.piece, @white.king.piece, @white.bishop.piece,
                   @white.knight.piece, @white.rook.piece]
    else
      @board = [board[0..7], board[8..15], board[16..23], board[24..31],
      board[32..39], board[40..47], board[48..55], board[56..63]]
    end
    @prev_move = prev_move
    @gameover = false
  end

  def puts_board
    puts "  a b c d e f g h"
    rows = [8, 7, 6, 5, 4, 3, 2, 1]
    (0..6).each { |i| puts "#{rows[i]} \e[4m#{@board[i].join("|")}\e[0m" }
    puts "1 #{@board[7].join("|")}"
  end

  def play(player)
    check_for_check(player)
    return if @gameover == true
    origin = nil; arr = nil
    loop do
      arr = player.play(@board)
      return arr if arr == "save" || arr == "reload"
      possible_origins = filter_positions(search_board(@board, [arr[0]]), arr, player)
      legal_moves = legal(player, possible_origins, [arr[1], arr[2]])
      legal_castling = can_castle(@board, player, legal_moves, [arr[1], arr[2]])
      if legal_moves.length > 0 && legal_castling.length == 0
        puts "You may not castle out of, through, or into check."
      elsif possible_origins.length > 0 && legal_moves.length == 0
        puts "You may not put yourself in or stay in check. Try again."
      elsif legal_moves.length == 0
        puts "No #{arr[0].class.to_s.downcase} within reach of that location. Try again."
      elsif legal_moves.length == 1
        origin = legal_moves[0]; break
      else
        origin = player.which_one?(legal_moves); break
      end
    end
    @board = move(@board, player, origin, [arr[1], arr[2]])
    @prev_move = [origin, [arr[1], arr[2]]]
    puts_board
  end

  private

  def check_for_check(player)
    legal = []
    search_board(@board, player.pieces).each do |row, column, piece|
      piece.valid_moves(@board, row, column, @prev_move).each do |r, c|
        unless player.pieces.any? { |i| i.piece == @board[r][c] }
          legal << [row, column] if legal(player, [[row, column]], [r, c]).length > 0
        end
      end
    end
    if legal.empty?
      @gameover = true
      if in_check?(@board, player) then puts "CHECKMATE" else puts "STALEMATE" end
    elsif in_check?(@board, player)
      puts "#{player.color.capitalize}'s king is in CHECK!"
    else
      false
    end
  end

  def legal(player, possible_origins, target)
    legal_moves = []
    possible_origins.each do |origins|
      copy_board = Marshal.load(Marshal.dump(@board))
      copy_board = en_passant(copy_board, player, origins, target) unless @prev_move == nil
      if can_castle(copy_board, player, [origins], target).length > 0
        copy_board = castling(copy_board, player, origins, target)
      end
      copy_board[target[0]][target[1]] = copy_board[origins[0]][origins[1]]
      copy_board[origins[0]][origins[1]] = " "
      legal_moves << origins if in_check?(copy_board, player, nil, [origins, target]) != true
    end
    legal_moves
  end

  def in_check?(board, player, position = nil, previous_move = @prev_move)
    position = search_board(board, [player.king])[0] if position == nil
    search_board(board, player.enemy.pieces).each do |row, column, piece|
      moves = piece.valid_moves(board, row, column, previous_move)
      return true if moves.include?([position[0], position[1]])
    end
    false
  end

  def search_board(board, pieces)
    positions = []
    board.each_index do |a|
      board[a].each_index do |i|
        pieces.each do |piece|
          positions << [a, i, piece] if board[a][i] == piece.piece
        end
      end
    end
    positions
  end

  def filter_positions(positions, arr, player)
    possible_pieces = []
    positions.each do |row, column|
      moves = arr[0].valid_moves(@board, row, column, @prev_move)
      possible_pieces << [row, column] if moves.include?([arr[1], arr[2]])
    end
    possible_pieces
  end

  def move(board, player, origin, target)
    board = en_passant(board, player, origin, target)
    board = promote(board, player, origin, target)
    board = castling(board, player, origin, target)
    mark_moved(origin, player)
    board[target[0]][target[1]] = board[origin[0]][origin[1]]
    board[origin[0]][origin[1]] = " "
    board
  end

  def en_passant(board, player, origin, target)
    if board[origin[0]][origin[1]] == player.pawn.piece &&
      board[target[0]][target[1]] == " " &&
      origin[1] != target[1]
    then
      board[@prev_move[1][0]][@prev_move[1][1]] = " "
    end
    board
  end

  def promote(board, player, origin, target)
    if board[origin[0]][origin[1]] == player.pawn.piece &&
      [0, 7].include?(target[0])
    then
      puts "Which piece would you like to promote your pawn to?"
      input = gets.chomp.upcase
      case input
      when "Q"
        board[origin[0]][origin[1]] = player.queen.piece
      when "R"
        board[origin[0]][origin[1]] = player.rook.piece
      when "B"
        board[origin[0]][origin[1]] = player.bishop.piece
      when "N"
        board[origin[0]][origin[1]] = player.knight.piece
      else
        puts "Please type 'Q', 'R', 'B', or 'N'."
        promote(player, origin, target)
      end
    end
    board
  end

  def mark_moved(origin, player)
    if origin == [0, 0] || origin == [7, 0]
      player.rook.a_moved = true
    elsif origin == [0, 7] || origin == [7, 7]
      player.rook.h_moved = true
    elsif origin == [0, 4] || origin == [7, 4]
      player.king.moved = true
    end
  end

  def can_castle(board, player, poss_origins, target)
    origins = Marshal.load(Marshal.dump(poss_origins))
    origins.each do |row, column|
      if board[row][column] == player.king.piece && column == 4
        if target == [player.king.starting_row, 2]
          pass = [[row, column], target, [player.king.starting_row, 3]]
          origins.delete([row, column]) if pass.any? { |pass| in_check?(board, player, pass) }
        elsif target == [player.king.starting_row, 6]
          pass = [[row, column], target, [player.king.starting_row, 5]] # TEST
          origins.delete([row, column]) if pass.any? { |pass| in_check?(board, player, pass) }
        end
      end
    end
    return origins
  end

  def castling(board, player, origin, target)
    if board[origin[0]][origin[1]] == player.king.piece
      if origin[1] == target[1] - 2
        board[origin[0]][5] = board[origin[0]][7]
        board[origin[0]][7] = " "
      elsif origin[1] == target[1] + 2
        board[origin[0]][3] = board[origin[0]][0]
        board[origin[0]][0] = " "
      end
    end
    board
  end
end
