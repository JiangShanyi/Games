@Observed
export class TileData {
  id: string;
  value: number;
  displayValue: number;
  row: number;
  col: number;
  scaleSize: number;

  constructor(id: string, value: number, row: number, col: number) {
    this.id = id;
    this.value = value;
    this.displayValue = value;
    this.row = row;
    this.col = col;
    this.scaleSize = 0.01;
  }
}

class BoardSnapshot {
  values: number[];
  score: number;
  gameStatus: string;
  resultTitle: string;
  resultMessage: string;

  constructor(values: number[], score: number, gameStatus: string, resultTitle: string, resultMessage: string) {
    this.values = values;
    this.score = score;
    this.gameStatus = gameStatus;
    this.resultTitle = resultTitle;
    this.resultMessage = resultMessage;
  }
}

@Component
export struct TileView {
  @ObjectLink tile: TileData;
  private readonly TILE_SIZE: number = 70;
  private readonly TILE_GAP: number = 10;

  private tileColor(value: number): string {
    switch (value) {
      case 2:
        return '#EEE4DA'
      case 4:
        return '#EDE0C8'
      case 8:
        return '#F2B179'
      case 16:
        return '#F59563'
      case 32:
        return '#F67C5F'
      case 64:
        return '#F65E3B'
      case 128:
        return '#EDCF72'
      case 256:
        return '#EDCC61'
      case 512:
        return '#EDC850'
      case 1024:
        return '#EDC53F'
      case 2048:
        return '#EDC22E'
      default:
        return '#3C3A32'
    }
  }

  private tileTextColor(value: number): string {
    if (value === 2 || value === 4) {
      return '#776E65'
    }
    return '#F9F6F2'
  }

  private tileFontSize(value: number): number {
    if (value >= 1024) {
      return 28
    }
    if (value >= 128) {
      return 34
    }
    return 40
  }

  build() {
    Column() {
      Text(this.tile.displayValue.toString())
        .fontSize(this.tileFontSize(this.tile.displayValue))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.tileTextColor(this.tile.displayValue))
    }
    .width(this.TILE_SIZE)
    .height(this.TILE_SIZE)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.tileColor(this.tile.displayValue))
    .borderRadius(12)
    .position({
      x: this.tile.col * (this.TILE_SIZE + this.TILE_GAP),
      y: this.tile.row * (this.TILE_SIZE + this.TILE_GAP)
    })
    .scale({
      x: this.tile.scaleSize,
      y: this.tile.scaleSize,
      centerX: '50%',
      centerY: '50%'
    })
  }
}

@Component
export struct Game2048Page {
  onBackToMenu: () => void = () => {}
  @State activeTiles: TileData[] = []
  @State score: number = 0
  @State bestScore: number = 0
  @State gameStatus: string = 'playing'
  @State resultTitle: string = ''
  @State resultMessage: string = ''
  private logicalBoard: (TileData | null)[] = new Array(16).fill(null)
  private undoStack: BoardSnapshot[] = []
  private tileIdCounter: number = 0
  private currentGameId: number = 0
  private isAnimating: boolean = false
  private readonly TILE_SIZE: number = 70
  private readonly TILE_GAP: number = 10
  private readonly BOARD_PADDING: number = 10
  private readonly BOARD_SIZE: number = (this.TILE_SIZE * 4) + (this.TILE_GAP * 3) + (this.BOARD_PADDING * 2)

  aboutToAppear(): void {
    this.startNewGame()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('2048')
            .fontSize(56)
            .fontWeight(FontWeight.Bold)
            .fontColor('#776E65')
            .layoutWeight(1)

          Row() {
            Column() {
              Text('SCORE')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#EEE4DA')

              Text(this.score.toString())
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ top: 2 })
            }
            .width(82)
            .height(54)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#BBADA0')
            .borderRadius(6)
            .margin({ left: 8 })

            Column() {
              Text('BEST')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#EEE4DA')

              Text(this.bestScore.toString())
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ top: 2 })
            }
            .width(82)
            .height(54)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#BBADA0')
            .borderRadius(6)
            .margin({ left: 8 })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          Button() {
            Text('Menu')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .layoutWeight(1)
          .height(46)
          .backgroundColor('#8F7A66')
          .borderRadius(6)
          .onClick(() => {
            this.returnToMenu()
          })

          Button() {
            Text('Undo')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .layoutWeight(1)
          .height(46)
          .backgroundColor('#8F7A66')
          .borderRadius(6)
          .margin({ left: 10, right: 10 })
          .onClick(() => {
            this.undoMove()
          })

          Button() {
            Text('New Game')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .layoutWeight(1)
          .height(46)
          .backgroundColor('#8F7A66')
          .borderRadius(6)
          .onClick(() => {
            this.startNewGame()
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: 16, bottom: 24 })

        Row() {
          Stack({ alignContent: Alignment.TopStart }) {
            Grid() {
              ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], (item: number) => {
                GridItem() {
                  Column()
                    .width('100%')
                    .height('100%')
                    .backgroundColor('#CDC1B4')
                    .borderRadius(12)
                }
              }, (item: number) => item.toString())
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(this.TILE_GAP)
            .rowsGap(this.TILE_GAP)
            .width('100%')
            .height('100%')

            ForEach(this.activeTiles, (tile: TileData) => {
              TileView({ tile: tile })
            }, (tile: TileData) => tile.id)

            if (this.gameStatus !== 'playing') {
              this.ResultLayer()
            }
          }
          .width(this.BOARD_SIZE)
          .height(this.BOARD_SIZE)
          .padding(this.BOARD_PADDING)
          .backgroundColor('#BBADA0')
          .borderRadius(16)
          .gesture(
            PanGesture({ direction: PanDirection.All, distance: 18 })
              .onActionEnd((event) => {
                this.handleSwipe(event.offsetX, event.offsetY)
              })
          )
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 20,
        right: 20,
        top: 36,
        bottom: 24
      })
      .backgroundColor('#FAF8EF')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ResultLayer() {
    Column() {
      Text(this.resultTitle)
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#776E65')

      Text(this.resultMessage)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#776E65')
        .margin({ top: 8 })

      Row() {
        this.ResultScoreBox('SCORE', this.score)
        this.ResultScoreBox('BEST', this.bestScore)
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 18, bottom: 22 })

      Button(this.gameStatus === 'won' ? 'Play Again' : 'Try Again')
        .width(132)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor('#8F7A66')
        .borderRadius(10)
        .onClick(() => {
          this.startNewGame()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.gameStatus === 'won' ? '#EDC22EE6' : '#EEE4DAE6')
    .borderRadius(16)
  }

  @Builder
  ResultScoreBox(title: string, value: number) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#EEE4DA')

      Text(value.toString())
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 2 })
    }
    .width(92)
    .height(58)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#BBADA0')
    .borderRadius(10)
    .margin({ left: 6, right: 6 })
  }

  private returnToMenu(): void {
    this.onBackToMenu()
  }

  private startNewGame(): void {
    this.currentGameId += 1
    let gameId = this.currentGameId

    this.resetScore()
    this.gameStatus = 'playing'
    this.resultTitle = ''
    this.resultMessage = ''
    this.isAnimating = false
    this.activeTiles = []
    this.logicalBoard = new Array(16).fill(null)
    this.undoStack = []
    this.tileIdCounter = 0

    let t1 = this.createRandomTile()
    let t2 = this.createRandomTile()

    let startingTiles: TileData[] = []
    if (t1) {
      startingTiles.push(t1)
    }
    if (t2) {
      startingTiles.push(t2)
    }
    this.activeTiles = startingTiles

    setTimeout(() => {
      if (gameId !== this.currentGameId || this.gameStatus !== 'playing') {
        return
      }

      animateTo({ duration: 190, curve: Curve.EaseOut }, () => {
        for (let t of this.activeTiles) {
          t.scaleSize = 1.0
        }
      })
    }, 50)
  }

  private resetScore(): void {
    this.score = 0
    this.updateBestScore()
  }

  private addScore(points: number): void {
    if (points <= 0) {
      return
    }
    let nextScore = this.score + points
    this.score = nextScore
    this.updateBestScore()
  }

  private updateBestScore(): void {
    if (this.score > this.bestScore) {
      this.bestScore = this.score
    }
  }

  private createSnapshot(): BoardSnapshot {
    let values: number[] = []
    for (let i = 0; i < 16; i++) {
      let tile = this.logicalBoard[i]
      values.push(tile === null ? 0 : tile.value)
    }
    return new BoardSnapshot(values, this.score, this.gameStatus, this.resultTitle, this.resultMessage)
  }

  private restoreSnapshot(snapshot: BoardSnapshot): void {
    this.currentGameId += 1
    this.isAnimating = false
    this.score = snapshot.score
    this.gameStatus = snapshot.gameStatus
    this.resultTitle = snapshot.resultTitle
    this.resultMessage = snapshot.resultMessage
    this.logicalBoard = new Array(16).fill(null)

    let restoredTiles: TileData[] = []
    for (let i = 0; i < 16; i++) {
      let value = snapshot.values[i]
      if (value > 0) {
        let tile = new TileData(
          'tile_' + this.currentGameId + '_' + this.tileIdCounter++,
          value,
          Math.floor(i / 4),
          i % 4
        )
        tile.displayValue = value
        tile.scaleSize = 1.0
        restoredTiles.push(tile)
        this.logicalBoard[i] = tile
      }
    }
    this.activeTiles = restoredTiles
    this.updateBestScore()
  }

  private undoMove(): void {
    if (this.isAnimating || this.undoStack.length === 0) {
      return
    }
    let snapshot = this.undoStack.pop()
    if (snapshot) {
      this.restoreSnapshot(snapshot)
    }
  }

  private createRandomTile(): TileData | null {
    let emptyIndexes: number[] = []
    for (let i = 0; i < 16; i++) {
      if (this.logicalBoard[i] === null) {
        emptyIndexes.push(i)
      }
    }

    if (emptyIndexes.length === 0) {
      return null
    }

    let randomPosition = Math.floor(Math.random() * emptyIndexes.length)
    let boardIndex = emptyIndexes[randomPosition]
    let value = Math.random() < 0.9 ? 2 : 4

    let newTile = new TileData(
      'tile_' + this.currentGameId + '_' + this.tileIdCounter++,
      value,
      Math.floor(boardIndex / 4),
      boardIndex % 4
    )

    this.logicalBoard[boardIndex] = newTile
    return newTile
  }

  private handleSwipe(offsetX: number, offsetY: number): void {
    if (this.gameStatus !== 'playing' || this.isAnimating) {
      return
    }

    let absX: number = Math.abs(offsetX)
    let absY: number = Math.abs(offsetY)

    if (absX < 20 && absY < 20) {
      return
    }

    if (absX > absY) {
      this.move(offsetX > 0 ? 1 : 0)
    } else {
      this.move(offsetY > 0 ? 3 : 2)
    }
  }

  private move(direction: number): void {
    let gameId = this.currentGameId
    let gainedScore = 0
    let previousSnapshot = this.createSnapshot()

    interface MergePair {
      survivor: TileData;
      victim: TileData;
    }

    let pendingMerges: MergePair[] = []
    let victimsToRemove: string[] = []

    interface Position {
      row: number;
      col: number;
    }

    let initialPositions = new Map<string, Position>()
    for (let t of this.activeTiles) {
      initialPositions.set(t.id, { row: t.row, col: t.col } as Position)
    }

    animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      for (let i = 0; i < 4; i++) {
        let line = this.readLine(i, direction)
        if (direction === 1 || direction === 3) {
          line = this.reverseLine(line)
        }

        let values: TileData[] = []
        for (let tile of line) {
          if (tile !== null) {
            values.push(tile)
          }
        }

        let newLine: (TileData | null)[] = []
        let v = 0
        while (v < values.length) {
          if (v + 1 < values.length && values[v].value === values[v + 1].value) {
            let survivor = values[v]
            let victim = values[v + 1]

            survivor.value *= 2
            gainedScore += survivor.value

            newLine.push(survivor)
            pendingMerges.push({ survivor, victim } as MergePair)
            victimsToRemove.push(victim.id)
            v += 2
          } else {
            newLine.push(values[v])
            v += 1
          }
        }

        while (newLine.length < 4) {
          newLine.push(null)
        }

        if (direction === 1 || direction === 3) {
          newLine = this.reverseLine(newLine)
        }
        this.writeLine(i, direction, newLine)
      }

      for (let merge of pendingMerges) {
        merge.victim.row = merge.survivor.row
        merge.victim.col = merge.survivor.col
      }
    })

    let moved = false
    if (victimsToRemove.length > 0) {
      moved = true
    }
    for (let t of this.activeTiles) {
      let init = initialPositions.get(t.id)
      if (init && (init.row !== t.row || init.col !== t.col)) {
        moved = true
      }
    }

    if (!moved) {
      this.checkLoseState()
      return
    }

    this.undoStack.push(previousSnapshot)

    this.isAnimating = true
    this.addScore(gainedScore)

    setTimeout(() => {
      if (gameId !== this.currentGameId || this.gameStatus !== 'playing') {
        return
      }

      let nextActiveTiles = this.activeTiles.filter(t => !victimsToRemove.includes(t.id))

      for (let merge of pendingMerges) {
        merge.survivor.displayValue = merge.survivor.value
        merge.survivor.scaleSize = 1.2
      }

      let randomTile = this.createRandomTile()
      if (randomTile) {
        nextActiveTiles.push(randomTile)
      }
      this.activeTiles = nextActiveTiles

      this.checkWinState()
      this.checkLoseState()

      setTimeout(() => {
        if (gameId !== this.currentGameId) {
          return
        }

        animateTo({ duration: 150, curve: Curve.EaseOut }, () => {
          for (let merge of pendingMerges) {
            merge.survivor.scaleSize = 1.0
          }
          if (randomTile) {
            randomTile.scaleSize = 1.0
          }
        })

        setTimeout(() => {
          if (gameId !== this.currentGameId || this.gameStatus !== 'playing') {
            return
          }

          this.isAnimating = false
        }, 150)
      }, 20)
    }, 200)
  }

  private checkWinState(): void {
    if (this.gameStatus !== 'playing') {
      return
    }

    for (let tile of this.activeTiles) {
      if (tile.value >= 2048) {
        this.gameStatus = 'won'
        this.resultTitle = 'You Win!'
        this.resultMessage = 'You made the 2048 tile.'
        this.isAnimating = false
        return
      }
    }
  }

  private checkLoseState(): void {
    if (this.gameStatus !== 'playing') {
      return
    }

    if (!this.canMove()) {
      this.gameStatus = 'lost'
      this.resultTitle = 'Game Over'
      this.resultMessage = 'No moves left.'
      this.isAnimating = false
    }
  }

  private canMove(): boolean {
    for (let i = 0; i < 16; i++) {
      if (this.logicalBoard[i] === null) {
        return true
      }
    }

    for (let row = 0; row < 4; row++) {
      for (let col = 0; col < 4; col++) {
        let current = this.logicalBoard[row * 4 + col]
        if (current === null) {
          return true
        }

        let right = col < 3 ? this.logicalBoard[row * 4 + col + 1] : null
        let down = row < 3 ? this.logicalBoard[(row + 1) * 4 + col] : null
        if ((right !== null && right.value === current.value) || (down !== null && down.value === current.value)) {
          return true
        }
      }
    }

    return false
  }

  private readLine(index: number, direction: number): (TileData | null)[] {
    let line: (TileData | null)[] = []
    for (let i = 0; i < 4; i++) {
      if (direction === 0 || direction === 1) {
        line.push(this.logicalBoard[index * 4 + i])
      } else {
        line.push(this.logicalBoard[i * 4 + index])
      }
    }
    return line
  }

  private writeLine(index: number, direction: number, line: (TileData | null)[]): void {
    for (let i = 0; i < 4; i++) {
      let tile = line[i]
      let boardIndex = (direction === 0 || direction === 1) ? (index * 4 + i) : (i * 4 + index)

      this.logicalBoard[boardIndex] = tile

      if (tile !== null) {
        tile.row = Math.floor(boardIndex / 4)
        tile.col = boardIndex % 4
      }
    }
  }

  private reverseLine(line: (TileData | null)[]): (TileData | null)[] {
    let result: (TileData | null)[] = []
    for (let i = line.length - 1; i >= 0; i--) {
      result.push(line[i])
    }
    return result
  }
}
