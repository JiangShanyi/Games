@Component
export struct TicTacToePage {
  onBackToMenu: () => void = () => {}
  launchMode: string = 'medium'

  @State mode: string = 'medium'
  @State selectedBotLevel: string = 'medium'
  @State board: string[] = ['', '', '', '', '', '', '', '', '']
  @State isXNext: boolean = true
  @State winner: string = ''
  @State scoreX: number = 0
  @State scoreO: number = 0
  @State draws: number = 0
  @State lastMoveIndex: number = -1
  @State winningIndexes: number[] = []

  private readonly cellIndexes: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8]
  private botMoveId: number = 0

  aboutToAppear(): void {
    this.startMode(this.launchMode)
  }

  build() {
    Stack() {
      if (this.mode === 'select') {
        this.ModeSelectView()
      } else {
        this.GameView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F3E8')
  }

  @Builder
  ModeSelectView() {
    Column() {
      Stack() {
        Text('X')
          .fontSize(132)
          .fontWeight(FontWeight.Bold)
          .fontColor('#19515A')
          .opacity(0.42)
          .position({ x: 58, y: 78 })

        Text('O')
          .fontSize(118)
          .fontWeight(FontWeight.Bold)
          .fontColor('#19515A')
          .opacity(0.42)
          .position({ x: 236, y: 112 })

        Row() {
          Button('<')
            .width(52)
            .height(52)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#A85D70')
            .backgroundColor('#FFF8EF')
            .borderRadius(26)
            .onClick(() => {
              this.returnToMenu()
            })

          Blank()

          Button('?')
            .width(46)
            .height(46)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor('#6A3C86')
            .borderRadius(10)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .padding({ left: 22, right: 22, top: 42 })

        Column() {
          Text('Tic Tac Toe')
            .fontSize(38)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF8EF')

          Text('X is red. O is blue.')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF8EF')
            .margin({ top: 22 })

          Text('Make three in a row to win.')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF8EF')
            .margin({ top: 18 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 72 })
      }
      .width('100%')
      .height(266)
      .backgroundColor('#2F7F88')

      Column() {
        Stack() {
          Column()
            .width(126)
            .height(100)
            .backgroundColor('#FFF8EF')
            .borderRadius(50)

          Column() {
            Text('XO')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E64B35')
          }
          .width(108)
          .height(82)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#111417')
          .borderRadius(42)
        }
        .width('100%')
        .height(82)
        .margin({ top: -42, bottom: 4 })

        Column() {
          Row() {
            Text('Difficulty')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D95F4D')
              .layoutWeight(1)

            Text(this.selectedBotLevelText())
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#D95F4D')
              .borderRadius(6)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Row() {
            this.DifficultyButton('Easy', 'easy')
            this.DifficultyButton('Medium', 'medium')
            this.DifficultyButton('Hard', 'hard')
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ top: 20 })
        }
        .width('100%')
        .padding({ left: 22, right: 22, top: 24, bottom: 24 })
        .backgroundColor('#F6D1A6')
        .borderRadius(18)
        .shadow({
          radius: 12,
          color: '#7B5E4B24',
          offsetX: 0,
          offsetY: 5
        })

        this.MatchButton('Play vs. BOT', 'Challenge the selected AI.', 'BOT', '#D95F4D', 'bot')
        this.MatchButton('Play vs. friend', 'Pass the phone and play together.', 'VS', '#6A3C86', 'two')

        Blank()
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 24, right: 24, bottom: 20 })
      .backgroundColor('#F7F3E8')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F3E8')
  }

  @Builder
  DifficultyButton(title: string, level: string) {
    Button(title)
      .layoutWeight(1)
      .height(42)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.selectedBotLevel === level ? Color.White : '#7B5E4B')
      .backgroundColor(this.selectedBotLevel === level ? '#D95F4D' : '#FFF8EF')
      .borderRadius(8)
      .margin({ left: 4, right: 4 })
      .onClick(() => {
        this.selectedBotLevel = level
      })
  }

  @Builder
  MatchButton(title: string, subtitle: string, badge: string, background: string, selectedMode: string) {
    Button() {
      Row() {
        Column() {
          Text(badge)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(background)
        }
        .width(58)
        .height(58)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFF8EF')
        .borderRadius(12)
        .margin({ right: 16 })

        Column() {
          Text(title)
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(subtitle)
            .fontSize(12)
            .fontColor('#FFF8EF')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(82)
    .padding({ left: 18, right: 18 })
    .backgroundColor(background)
    .borderRadius(14)
    .margin({ top: 16 })
    .onClick(() => {
      this.startMode(selectedMode === 'bot' ? this.selectedBotLevel : selectedMode)
    })
  }

  @Builder
  GameView() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F2CDBB')

      Row() {
        this.ScorePill()
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .position({ x: 0, y: 108 })

      Text('Tic Tac Toe')
        .width('100%')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#253238')
        .textAlign(TextAlign.Center)
        .position({ x: 0, y: 48 })

      Column() {
        Blank()
          .height(292)

        this.BoardView()

        if (this.winner !== '') {
          this.ResultBubble()
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      Button('<')
        .width(50)
        .height(50)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8E617A')
        .backgroundColor('#EAF7FF')
        .borderRadius(25)
        .position({ x: 22, y: 42 })
        .onClick(() => {
          this.returnToModeSelect()
        })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ScorePill() {
    Stack() {
      Column()
        .width(86)
        .height(18)
        .backgroundColor('#2F2D33')
        .borderRadius(4)
        .position({ x: 87, y: 0 })

      Row() {
        this.LeftScoreSide()

        Column() {
          Text(this.centerModeLabel())
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E8F2F4')

          Text('VS')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#EAFBFF')
            .margin({ top: 2 })
        }
        .width(74)
        .height(66)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        this.RightScoreSide()
      }
      .width(260)
      .height(72)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#2F2D33')
      .borderRadius(8)
      .position({ x: 0, y: 10 })
    }
    .width(260)
    .height(82)
  }

  @Builder
  LeftScoreSide() {
    Column() {
      Text(this.leftScoreLabel())
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#DB685B')

      Text(this.scoreX.toString())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#DB685B')
        .margin({ top: -2 })
    }
    .width(86)
    .height(66)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  RightScoreSide() {
    Column() {
      Text(this.rightScoreLabel())
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2DB4F5')

      Text(this.scoreO.toString())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2DB4F5')
        .margin({ top: -2 })
    }
    .width(86)
    .height(66)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BoardView() {
    Grid() {
      ForEach(this.cellIndexes, (index: number) => {
        GridItem() {
          this.BoardCell(index)
        }
      }, (index: number) => index.toString())
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width(318)
    .height(318)
    .backgroundColor('#111111')
  }

  @Builder
  BoardCell(index: number) {
    Column() {
      Text(this.board[index])
        .fontSize(82)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.cellTextColor(index))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.cellBackground(index))
    .onClick(() => {
      if (this.winner !== '') {
        this.resetRound()
      } else {
        this.handleCellClick(index)
      }
    })
  }

  @Builder
  ResultBubble() {
    Button(this.resultTitle())
      .width(226)
      .height(48)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
      .backgroundColor('#2F2D33')
      .borderRadius(24)
      .margin({ top: 38 })
      .onClick(() => {
        this.resetRound()
      })
  }

  @Builder
  RoundStatusView() {
    if (this.winner === 'Draw') {
      Text('Draw Round')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#7B5E4B')

      Text('No winner this time.')
        .fontSize(13)
        .fontColor('#5C6D70')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    } else if (this.winner === 'X') {
      Text(this.isBotGame() ? 'You Win!' : 'Player X Wins!')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D95F4D')

      Text('Three X marks are connected.')
        .fontSize(13)
        .fontColor('#5C6D70')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    } else if (this.winner === 'O') {
      Text(this.isBotGame() ? 'Bot Wins!' : 'Player O Wins!')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#335C67')

      Text('Three O marks are connected.')
        .fontSize(13)
        .fontColor('#5C6D70')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    } else if (this.isBotTurn()) {
      Text('Bot Thinking')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4B568E')

      Text('The bot is weighing the board.')
        .fontSize(13)
        .fontColor('#5C6D70')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    } else if (this.isBotGame()) {
      Text('Your Turn')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#253238')

      Text('You are playing X.')
        .fontSize(13)
        .fontColor('#5C6D70')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    } else {
      Text(this.isXNext ? "X's Turn" : "O's Turn")
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#253238')

      Text('Share the board and chase three in a row.')
        .fontSize(13)
        .fontColor('#5C6D70')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    }
  }

  private selectedBotLevelText(): string {
    switch (this.selectedBotLevel) {
      case 'easy':
        return 'Easy'
      case 'hard':
        return 'Hard'
      default:
        return 'Medium'
    }
  }

  private startMode(selectedMode: string): void {
    if (selectedMode === 'easy' || selectedMode === 'medium' || selectedMode === 'hard') {
      this.selectedBotLevel = selectedMode
    }
    this.mode = selectedMode
    this.resetScores()
    this.resetRound()
  }

  private returnToModeSelect(): void {
    this.mode = 'select'
    this.resetScores()
    this.resetRound()
    this.onBackToMenu()
  }

  private returnToMenu(): void {
    this.mode = 'select'
    this.resetScores()
    this.resetRound()
    this.onBackToMenu()
  }

  private resetScores(): void {
    this.scoreX = 0
    this.scoreO = 0
    this.draws = 0
  }

  private resetRound(): void {
    this.botMoveId += 1
    this.board = ['', '', '', '', '', '', '', '', '']
    this.isXNext = true
    this.winner = ''
    this.lastMoveIndex = -1
    this.winningIndexes = []
  }

  private handleCellClick(index: number): void {
    if (this.mode === 'select' || this.board[index] !== '' || this.winner !== '' || this.isBotTurn()) {
      return
    }

    let mark = this.isXNext ? 'X' : 'O'
    let shouldContinue = this.playMove(index, mark)
    if (shouldContinue && this.isBotTurn()) {
      this.scheduleBotMove()
    }
  }

  private playMove(index: number, mark: string): boolean {
    let nextBoard = this.board.slice()
    nextBoard[index] = mark
    this.board = nextBoard
    this.lastMoveIndex = index

    let winningIndexes = this.getWinningIndexes(nextBoard)
    if (winningIndexes.length > 0) {
      this.finishRound(mark, winningIndexes)
      return false
    }

    if (this.getEmptyIndexes(nextBoard).length === 0) {
      this.finishRound('Draw', [])
      return false
    }

    this.winner = ''
    this.winningIndexes = []
    this.isXNext = mark === 'O'
    return true
  }

  private finishRound(result: string, winningIndexes: number[]): void {
    this.winner = result
    this.winningIndexes = winningIndexes
    this.isXNext = result === 'O'

    if (result === 'X') {
      this.scoreX = this.scoreX + 1
    } else if (result === 'O') {
      this.scoreO = this.scoreO + 1
    } else {
      this.draws = this.draws + 1
    }
  }

  private scheduleBotMove(): void {
    if (!this.isBotTurn()) {
      return
    }

    let moveId = ++this.botMoveId
    setTimeout(() => {
      if (moveId !== this.botMoveId || !this.isBotTurn()) {
        return
      }

      let botIndex = this.chooseBotMove()
      if (botIndex >= 0) {
        this.playMove(botIndex, 'O')
      }
    }, 360)
  }

  private chooseBotMove(): number {
    let emptyIndexes = this.getEmptyIndexes(this.board)
    if (emptyIndexes.length === 0) {
      return -1
    }

    if (this.mode === 'easy') {
      return this.randomMove(emptyIndexes)
    }

    if (this.mode === 'medium') {
      let mediumMove = this.chooseMediumMove(emptyIndexes)
      if (mediumMove >= 0) {
        return mediumMove
      }
      return this.randomMove(emptyIndexes)
    }

    return this.chooseHardMove(emptyIndexes)
  }

  private chooseMediumMove(emptyIndexes: number[]): number {
    let winMove = this.findWinningMove(this.board, 'O')
    if (winMove >= 0) {
      return winMove
    }

    let blockMove = this.findWinningMove(this.board, 'X')
    if (blockMove >= 0) {
      return blockMove
    }

    if (this.board[4] === '') {
      return 4
    }

    return this.randomMove(emptyIndexes)
  }

  private chooseHardMove(emptyIndexes: number[]): number {
    let bestScore = -1000
    let bestMoves: number[] = []

    for (let move of emptyIndexes) {
      let nextBoard = this.board.slice()
      nextBoard[move] = 'O'
      let score = this.minimax(nextBoard, false, 0)
      if (score > bestScore) {
        bestScore = score
        bestMoves = [move]
      } else if (score === bestScore) {
        bestMoves.push(move)
      }
    }

    return this.randomMove(bestMoves)
  }

  private minimax(board: string[], isBotTurn: boolean, depth: number): number {
    let result = this.checkWinner(board)
    if (result === 'O') {
      return 10 - depth
    }
    if (result === 'X') {
      return depth - 10
    }
    if (result === 'Draw') {
      return 0
    }

    let emptyIndexes = this.getEmptyIndexes(board)
    if (isBotTurn) {
      let bestScore = -1000
      for (let move of emptyIndexes) {
        let nextBoard = board.slice()
        nextBoard[move] = 'O'
        bestScore = Math.max(bestScore, this.minimax(nextBoard, false, depth + 1))
      }
      return bestScore
    }

    let bestScore = 1000
    for (let move of emptyIndexes) {
      let nextBoard = board.slice()
      nextBoard[move] = 'X'
      bestScore = Math.min(bestScore, this.minimax(nextBoard, true, depth + 1))
    }
    return bestScore
  }

  private findWinningMove(board: string[], mark: string): number {
    let emptyIndexes = this.getEmptyIndexes(board)
    for (let move of emptyIndexes) {
      let nextBoard = board.slice()
      nextBoard[move] = mark
      if (this.checkWinner(nextBoard) === mark) {
        return move
      }
    }
    return -1
  }

  private randomMove(indexes: number[]): number {
    if (indexes.length === 0) {
      return -1
    }
    return indexes[Math.floor(Math.random() * indexes.length)]
  }

  private getEmptyIndexes(board: string[]): number[] {
    let indexes: number[] = []
    for (let i = 0; i < 9; i++) {
      if (board[i] === '') {
        indexes.push(i)
      }
    }
    return indexes
  }

  private checkWinner(board: string[]): string {
    let winningIndexes = this.getWinningIndexes(board)
    if (winningIndexes.length > 0) {
      return board[winningIndexes[0]]
    }

    return this.getEmptyIndexes(board).length === 0 ? 'Draw' : ''
  }

  private getWinningIndexes(board: string[]): number[] {
    let lines: number[][] = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ]

    for (let i = 0; i < lines.length; i++) {
      let line = lines[i]
      let a = line[0]
      let b = line[1]
      let c = line[2]
      if (board[a] !== '' && board[a] === board[b] && board[a] === board[c]) {
        return [a, b, c]
      }
    }

    return []
  }

  private isBotGame(): boolean {
    return this.mode === 'easy' || this.mode === 'medium' || this.mode === 'hard'
  }

  private isBotTurn(): boolean {
    return this.isBotGame() && !this.isXNext && this.winner === ''
  }

  private modeTitle(): string {
    switch (this.mode) {
      case 'easy':
        return 'Easy Bot'
      case 'medium':
        return 'Medium Bot'
      case 'hard':
        return 'Hard Bot'
      default:
        return 'Friend'
    }
  }

  private leftScoreLabel(): string {
    return this.isBotGame() ? 'You' : 'P1'
  }

  private rightScoreLabel(): string {
    return this.isBotGame() ? 'Bot' : 'P2'
  }

  private centerModeLabel(): string {
    switch (this.mode) {
      case 'easy':
        return 'Easy'
      case 'medium':
        return 'Medium'
      case 'hard':
        return 'Hard'
      default:
        return 'Friend'
    }
  }

  private resultTitle(): string {
    if (this.winner === 'Draw') {
      return 'Draw - tap for next'
    }
    if (this.winner === 'X') {
      return this.isBotGame() ? 'You win - tap for next' : 'P1 wins - tap for next'
    }
    if (this.winner === 'O') {
      return this.isBotGame() ? 'Bot wins - tap for next' : 'P2 wins - tap for next'
    }
    return ''
  }

  private isWinningIndex(index: number): boolean {
    for (let winningIndex of this.winningIndexes) {
      if (winningIndex === index) {
        return true
      }
    }
    return false
  }

  private cellBackground(index: number): string {
    if (this.isWinningIndex(index)) {
      return this.board[index] === 'X' ? '#F2B8AC' : '#BFDCD6'
    }
    return '#F2CDBB'
  }

  private cellTextColor(index: number): string {
    if (this.board[index] === 'X') {
      return '#D95F4D'
    }
    if (this.board[index] === 'O') {
      return '#335C67'
    }
    return '#C9BBA8'
  }
}
