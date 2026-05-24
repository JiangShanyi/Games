@Component
export struct Game8TilePuzzlePage {
  onBackToMenu: () => void = () => {}
  @State boardValues: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 0]
  @State moves: number = 0
  @State bestMoves: number = 0
  @State gameStatus: string = 'playing'
  @State resultMessage: string = ''
  private readonly TILE_SIZE: number = 88
  private readonly TILE_GAP: number = 10
  private readonly BOARD_PADDING: number = 10
  private readonly BOARD_SIZE: number = (this.TILE_SIZE * 3) + (this.TILE_GAP * 2) + (this.BOARD_PADDING * 2)
  private readonly boardIndexes: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8]

  aboutToAppear(): void {
    this.startNewGame()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            Text('8-Tile')
              .fontSize(44)
              .fontWeight(FontWeight.Bold)
              .fontColor('#253238')

            Text('Puzzle')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D95F4D')
              .margin({ top: -4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row() {
            this.StatBox('MOVES', this.moves.toString(), '#335C67')
            this.StatBox('BEST', this.bestMoves === 0 ? '--' : this.bestMoves.toString(), '#D95F4D')
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Blank()
            .layoutWeight(1)

          Row() {
            Button('Menu')
              .width(78)
              .height(42)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor('#335C67')
              .borderRadius(4)
              .onClick(() => {
                this.returnToMenu()
              })

            Button('New Puzzle')
              .width(118)
              .height(42)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor('#D95F4D')
              .borderRadius(4)
              .margin({ left: 8 })
              .onClick(() => {
                this.startNewGame()
              })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: 14, bottom: 24 })

        Stack() {
          Grid() {
            ForEach(this.boardIndexes, (index: number) => {
              GridItem() {
                if (this.boardValues[index] === 0) {
                  Column()
                    .width('100%')
                    .height('100%')
                    .backgroundColor('#DCE7E1')
                    .borderRadius(10)
                } else {
                  Column() {
                    Text(this.boardValues[index].toString())
                      .fontSize(36)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#253238')
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor(this.tileColor(this.boardValues[index]))
                  .borderRadius(10)
                  .shadow({
                    radius: 8,
                    color: '#1E2A3040',
                    offsetX: 0,
                    offsetY: 3
                  })
                  .onClick(() => {
                    this.handleTileTapByIndex(index)
                  })
                }
              }
            }, (index: number) => index.toString())
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr')
          .columnsGap(this.TILE_GAP)
          .rowsGap(this.TILE_GAP)
          .width('100%')
          .height('100%')

          if (this.gameStatus === 'won') {
            this.ResultLayer()
          }
        }
        .width(this.BOARD_SIZE)
        .height(this.BOARD_SIZE)
        .padding(this.BOARD_PADDING)
        .backgroundColor('#335C67')
        .borderRadius(16)
        .gesture(
          PanGesture({ direction: PanDirection.All, distance: 18 })
            .onActionEnd((event) => {
              this.handleSwipe(event.offsetX, event.offsetY)
            })
        )
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 20,
        right: 20,
        top: 36,
        bottom: 24
      })
      .backgroundColor('#F7F3E8')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatBox(title: string, value: string, color: string) {
    Column() {
      Text(title)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F7F3E8')

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 2 })
    }
    .width(68)
    .height(46)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(color)
    .borderRadius(6)
    .margin({ left: 6 })
  }

  @Builder
  ResultLayer() {
    Column() {
      Text('Solved!')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#253238')

      Text(this.resultMessage)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#253238')
        .margin({ top: 8, bottom: 22 })

      Button('New Puzzle')
        .width(132)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor('#D95F4D')
        .borderRadius(10)
        .onClick(() => {
          this.startNewGame()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F7F3E8E6')
    .borderRadius(16)
  }

  private returnToMenu(): void {
    this.onBackToMenu()
  }

  private startNewGame(): void {
    this.moves = 0
    this.gameStatus = 'playing'
    this.resultMessage = ''
    this.boardValues = this.createShuffledBoard()
  }

  private createShuffledBoard(): number[] {
    let board: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 0]
    let emptyIndex = 8
    let previousEmptyIndex = -1

    for (let step = 0; step < 90; step++) {
      let neighbors = this.getAdjacentIndexes(emptyIndex)
      let candidates: number[] = []
      for (let neighbor of neighbors) {
        if (neighbor !== previousEmptyIndex || neighbors.length === 1) {
          candidates.push(neighbor)
        }
      }

      let nextIndex = candidates[Math.floor(Math.random() * candidates.length)]
      board[emptyIndex] = board[nextIndex]
      board[nextIndex] = 0
      previousEmptyIndex = emptyIndex
      emptyIndex = nextIndex
    }

    if (this.isSolvedBoard(board)) {
      board = [1, 2, 3, 4, 5, 6, 0, 7, 8]
    }

    return board
  }

  private handleTileTapByIndex(tileIndex: number): void {
    if (this.gameStatus !== 'playing') {
      return
    }

    let emptyIndex = this.boardValues.indexOf(0)
    if (!this.areAdjacent(tileIndex, emptyIndex)) {
      return
    }

    this.moveTileByIndex(tileIndex, emptyIndex)
  }

  private handleSwipe(offsetX: number, offsetY: number): void {
    if (this.gameStatus !== 'playing') {
      return
    }

    let absX = Math.abs(offsetX)
    let absY = Math.abs(offsetY)
    if (absX < 20 && absY < 20) {
      return
    }

    let emptyIndex = this.boardValues.indexOf(0)
    let emptyRow = Math.floor(emptyIndex / 3)
    let emptyCol = emptyIndex % 3
    let tileIndex = -1

    if (absX > absY) {
      if (offsetX < 0 && emptyCol < 2) {
        tileIndex = emptyIndex + 1
      } else if (offsetX > 0 && emptyCol > 0) {
        tileIndex = emptyIndex - 1
      }
    } else {
      if (offsetY < 0 && emptyRow < 2) {
        tileIndex = emptyIndex + 3
      } else if (offsetY > 0 && emptyRow > 0) {
        tileIndex = emptyIndex - 3
      }
    }

    if (tileIndex >= 0) {
      this.moveTileByIndex(tileIndex, emptyIndex)
    }
  }

  private moveTileByIndex(tileIndex: number, emptyIndex: number): void {
    if (
      tileIndex < 0 ||
        tileIndex >= this.boardValues.length ||
        emptyIndex < 0 ||
        emptyIndex >= this.boardValues.length ||
        !this.areAdjacent(tileIndex, emptyIndex)
    ) {
      return
    }

    let value = this.boardValues[tileIndex]
    if (value === 0) {
      return
    }

    let nextBoard = this.boardValues.slice()
    nextBoard[emptyIndex] = value
    nextBoard[tileIndex] = 0
    this.boardValues = nextBoard
    this.moves += 1

    if (this.isSolvedBoard(this.boardValues)) {
      this.gameStatus = 'won'
      this.resultMessage = 'Finished in ' + this.moves.toString() + ' moves.'
      this.updateBestMoves()
    }
  }

  private tileColor(value: number): string {
    switch (value) {
      case 1:
        return '#E7F0EF'
      case 2:
        return '#F5D7C3'
      case 3:
        return '#D8E8C4'
      case 4:
        return '#CFE0F3'
      case 5:
        return '#F1C3BC'
      case 6:
        return '#F2DF8C'
      case 7:
        return '#BFDCD6'
      default:
        return '#E7D4F3'
    }
  }

  private updateBestMoves(): void {
    if (this.bestMoves === 0 || this.moves < this.bestMoves) {
      this.bestMoves = this.moves
    }
  }

  private getAdjacentIndexes(index: number): number[] {
    let indexes: number[] = []
    let row = Math.floor(index / 3)
    let col = index % 3

    if (row > 0) {
      indexes.push(index - 3)
    }
    if (row < 2) {
      indexes.push(index + 3)
    }
    if (col > 0) {
      indexes.push(index - 1)
    }
    if (col < 2) {
      indexes.push(index + 1)
    }

    return indexes
  }

  private areAdjacent(firstIndex: number, secondIndex: number): boolean {
    if (firstIndex < 0 || secondIndex < 0) {
      return false
    }

    let firstRow = Math.floor(firstIndex / 3)
    let firstCol = firstIndex % 3
    let secondRow = Math.floor(secondIndex / 3)
    let secondCol = secondIndex % 3
    let rowDistance = Math.abs(firstRow - secondRow)
    let colDistance = Math.abs(firstCol - secondCol)
    return rowDistance + colDistance === 1
  }

  private isSolvedBoard(board: number[]): boolean {
    for (let i = 0; i < 8; i++) {
      if (board[i] !== i + 1) {
        return false
      }
    }
    return board[8] === 0
  }
}
