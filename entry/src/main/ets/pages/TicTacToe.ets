@Component
export struct TicTacToePage {
  onBackToMenu: () => void = () => {}

  @State board: string[] = ['', '', '', '', '', '', '', '', '']
  @State isXNext: boolean = true
  @State winner: string = '' // Holds '', 'X', 'O', or 'Draw'
  @State scoreX: number = 0
  @State scoreO: number = 0

  private cellIndexes: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8]

  private handleCellClick(index: number): void {
    if (this.board[index] !== '' || this.winner !== '') {
      return
    }

    // Explicitly update the state array without array destructuring modifiers
    let nextBoard = [...this.board]
    nextBoard[index] = this.isXNext ? 'X' : 'O'
    this.board = nextBoard

    let winResult = this.checkWinner(nextBoard)
    if (winResult !== '') {
      this.winner = winResult
      if (winResult === 'X') {
        this.scoreX += 1
      } else if (winResult === 'O') {
        this.scoreO += 1
      }
    } else {
      this.isXNext = !this.isXNext
    }
  }

  private checkWinner(board: string[]): string {
    let lines: number[][] = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ]

    for (let i = 0; i < lines.length; i++) {
      let line = lines[i]
      let a = line[0]
      let b = line[1]
      let c = line[2]
      if (board[a] !== '' && board[a] === board[b] && board[a] === board[c]) {
        return board[a]
      }
    }

    let isDraw = true
    for (let i = 0; i < 9; i++) {
      if (board[i] === '') {
        isDraw = false
        break
      }
    }

    if (isDraw) {
      return 'Draw'
    }

    return ''
  }

  private resetGame(): void {
    this.board = ['', '', '', '', '', '', '', '', '']
    this.isXNext = true
    this.winner = ''
  }

  private returnToMenu(): void {
    this.onBackToMenu()
  }

  build() {
    Stack() {
      Column() {
        // Header Section
        Row() {
          Button('Back')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#776E65')
            .backgroundColor('#F1E6D8')
            .borderRadius(12)
            .onClick(() => {
              this.returnToMenu()
            })

          Blank()

          Text('Tic Tac Toe')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4B4038')
        }
        .width('100%')
        .margin({ bottom: 32 })

        // Scoreboard Layout
        Row() {
          Column() {
            Text('Player X')
              .fontSize(14)
              .fontColor('#9A8B80')
              .fontWeight(FontWeight.Medium)
            Text(this.scoreX.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4B4038')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .backgroundColor('#F1E6D8')
          .padding(12)
          .borderRadius(14)
          .margin({ right: 12 })

          Column() {
            Text('Player O')
              .fontSize(14)
              .fontColor('#9A8B80')
              .fontWeight(FontWeight.Medium)
            Text(this.scoreO.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4B4038')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .backgroundColor('#F1E6D8')
          .padding(12)
          .borderRadius(14)
        }
        .width('100%')
        .margin({ bottom: 32 })

        // Dynamic Game Status Notification Banner
        Column() {
          if (this.winner === '') {
            Text(this.isXNext ? "X's Turn" : "O's Turn")
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#776E65')
          } else if (this.winner === 'Draw') {
            Text("It's a Draw!")
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F67C5F')
          } else {
            Text(`Winner: Player ${this.winner}!`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8F7A66')
          }
        }
        .margin({ bottom: 32 })

        // 3x3 Interaction Board Grid
        Grid() {
          ForEach(this.cellIndexes, (index: number) => {
            GridItem() {
              Button() {
                Text(this.board[index])
                  .fontSize(44)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.board[index] === 'X' ? '#F2B179' : '#F67C5F')
              }
              .width('100%')
              .height('100%')
              .backgroundColor('#FAF8EF')
              .borderRadius(12)
              .onClick(() => {
                this.handleCellClick(index)
              })
            }
          }, (index: number) => index.toString())
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width(300)
        .height(300)
        .backgroundColor('#BBADA0')
        .padding(10)
        .borderRadius(16)
        .margin({ bottom: 40 })

        // Action Reset Button
        Button('Restart Match')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor('#8F7A66')
          .padding({ left: 32, right: 32, top: 14, bottom: 14 })
          .borderRadius(24)
          .onClick(() => {
            this.resetGame()
          })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 24, right: 24, top: 56, bottom: 24 })
      .backgroundColor('#FAF8EF')
    }
    .width('100%')
    .height('100%')
  }
}
