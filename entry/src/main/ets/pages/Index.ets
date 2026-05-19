@Entry
@Component
struct Index {
  @State board: number[] = [
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0
  ]

  @State score: number = 0
  @State bestScore: number = 0

  private cellIndexes: number[] = [
    0, 1, 2, 3,
    4, 5, 6, 7,
    8, 9, 10, 11,
    12, 13, 14, 15
  ]

  private lastLineScore: number = 0

  aboutToAppear(): void {
    this.startNewGame()
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('2048')
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
            .fontColor('#776E65')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('New Game')
          .height(44)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor('#8F7A66')
          .borderRadius(10)
          .onClick(() => {
            this.startNewGame()
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        this.ScoreBox('SCORE', this.score)
        this.ScoreBox('BEST', this.bestScore)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 18, bottom: 18 })

      Column() {
        Button('Up')
          .width(110)
          .height(42)
          .fontColor(Color.White)
          .backgroundColor('#8F7A66')
          .borderRadius(10)
          .onClick(() => {
            this.move(2)
          })

        Row() {
          Button('Left')
            .width(100)
            .height(42)
            .fontColor(Color.White)
            .backgroundColor('#8F7A66')
            .borderRadius(10)
            .margin({ right: 10 })
            .onClick(() => {
              this.move(0)
            })

          Button('Right')
            .width(100)
            .height(42)
            .fontColor(Color.White)
            .backgroundColor('#8F7A66')
            .borderRadius(10)
            .margin({ left: 10 })
            .onClick(() => {
              this.move(1)
            })
        }
        .margin({ top: 8, bottom: 8 })

        Button('Down')
          .width(110)
          .height(42)
          .fontColor(Color.White)
          .backgroundColor('#8F7A66')
          .borderRadius(10)
          .onClick(() => {
            this.move(3)
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 20 })

      Grid() {
        ForEach(this.cellIndexes, (index: number) => {
          GridItem() {
            Column() {
              Text(this.board[index] === 0 ? '' : this.board[index].toString())
                .fontSize(this.tileFontSize(this.board[index]))
                .fontWeight(FontWeight.Bold)
                .fontColor(this.tileTextColor(this.board[index]))
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(this.tileColor(this.board[index]))
            .borderRadius(12)
          }
        }, (index: number): string => index.toString())
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('100%')
      .aspectRatio(1)
      .padding(10)
      .backgroundColor('#BBADA0')
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 36, bottom: 24 })
    .backgroundColor('#FAF8EF')
  }

  @Builder
  ScoreBox(title: string, value: number) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#EEE4DA')

      Text(value.toString())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 2 })
    }
    .width(90)
    .height(60)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#BBADA0')
    .borderRadius(10)
    .margin({ left: 10 })
  }

  private startNewGame(): void {
    this.score = 0
    this.board = this.createEmptyBoard()

    this.addRandomTile()
    this.addRandomTile()
  }

  private createEmptyBoard(): number[] {
    let result: number[] = []

    for (let i = 0; i < 16; i++) {
      result.push(0)
    }

    return result
  }

  private copyBoard(source: number[]): number[] {
    let result: number[] = []

    for (let i = 0; i < source.length; i++) {
      result.push(source[i])
    }

    return result
  }

  private addRandomTile(): void {
    let emptyIndexes: number[] = []

    for (let i = 0; i < this.board.length; i++) {
      if (this.board[i] === 0) {
        emptyIndexes.push(i)
      }
    }

    if (emptyIndexes.length === 0) {
      return
    }

    let nextBoard: number[] = this.copyBoard(this.board)
    let randomPosition: number = Math.floor(Math.random() * emptyIndexes.length)
    let boardIndex: number = emptyIndexes[randomPosition]

    if (Math.random() < 0.9) {
      nextBoard[boardIndex] = 2
    } else {
      nextBoard[boardIndex] = 4
    }

    this.board = nextBoard
  }

  // direction:
  // 0 = left
  // 1 = right
  // 2 = up
  // 3 = down
  private move(direction: number): void {
    let nextBoard: number[] = this.createEmptyBoard()
    let gainedScore: number = 0

    for (let i = 0; i < 4; i++) {
      let line: number[] = this.readLine(i, direction)

      if (direction === 1 || direction === 3) {
        line = this.reverseLine(line)
      }

      let mergedLine: number[] = this.mergeLine(line)

      gainedScore += this.lastLineScore

      if (direction === 1 || direction === 3) {
        mergedLine = this.reverseLine(mergedLine)
      }

      this.writeLine(nextBoard, i, direction, mergedLine)
    }

    if (!this.sameBoard(this.board, nextBoard)) {
      this.board = nextBoard
      this.score += gainedScore

      if (this.score > this.bestScore) {
        this.bestScore = this.score
      }

      this.addRandomTile()
    }
  }

  private readLine(index: number, direction: number): number[] {
    let line: number[] = []

    for (let i = 0; i < 4; i++) {
      if (direction === 0 || direction === 1) {
        line.push(this.board[index * 4 + i])
      } else {
        line.push(this.board[i * 4 + index])
      }
    }

    return line
  }

  private writeLine(target: number[], index: number, direction: number, line: number[]): void {
    for (let i = 0; i < 4; i++) {
      if (direction === 0 || direction === 1) {
        target[index * 4 + i] = line[i]
      } else {
        target[i * 4 + index] = line[i]
      }
    }
  }

  private mergeLine(line: number[]): number[] {
    let values: number[] = []
    let result: number[] = []

    this.lastLineScore = 0

    for (let i = 0; i < line.length; i++) {
      if (line[i] !== 0) {
        values.push(line[i])
      }
    }

    let i: number = 0

    while (i < values.length) {
      if (i + 1 < values.length && values[i] === values[i + 1]) {
        let mergedValue: number = values[i] * 2
        result.push(mergedValue)
        this.lastLineScore += mergedValue
        i += 2
      } else {
        result.push(values[i])
        i += 1
      }
    }

    while (result.length < 4) {
      result.push(0)
    }

    return result
  }

  private reverseLine(line: number[]): number[] {
    let result: number[] = []

    for (let i = line.length - 1; i >= 0; i--) {
      result.push(line[i])
    }

    return result
  }

  private sameBoard(a: number[], b: number[]): boolean {
    for (let i = 0; i < 16; i++) {
      if (a[i] !== b[i]) {
        return false
      }
    }

    return true
  }

  private tileColor(value: number): string {
    switch (value) {
      case 0:
        return '#CDC1B4'
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
}