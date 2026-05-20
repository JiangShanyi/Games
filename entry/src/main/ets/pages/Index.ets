@Observed
export class TileData {
  id: string;
  value: number; // Logical value: updates instantly
  displayValue: number; // Visual value: waits for slide animation to finish
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
      // Binds to displayValue so it stays as a 2 while sliding, and turns into a 4 upon arrival
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

@Entry
@Component
struct Index {
  @State activeTiles: TileData[] = []
  @State score: number = 0
  @State bestScore: number = 0
  private logicalBoard: (TileData | null)[] = new Array(16).fill(null)
  private tileIdCounter: number = 0
  private readonly TILE_SIZE: number = 70
  private readonly TILE_GAP: number = 10
  private readonly BOARD_PADDING: number = 10
  private readonly BOARD_SIZE: number = (this.TILE_SIZE * 4) + (this.TILE_GAP * 3) + (this.BOARD_PADDING * 2)

  aboutToAppear(): void {
    this.startNewGame()
  }

  build() {
    Column() {
      // --- HEADER SECTION ---
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
      .margin({ top: 18, bottom: 24 })

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
    .height('100%')
    .padding({
      left: 20,
      right: 20,
      top: 36,
      bottom: 24
    })
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
    this.activeTiles = []
    this.logicalBoard = new Array(16).fill(null)
    this.tileIdCounter = 0

    let t1 = this.createRandomTile()
    let t2 = this.createRandomTile()

    if (t1) {
      this.activeTiles.push(t1)
    }
    if (t2) {
      this.activeTiles.push(t2)
    }

    setTimeout(() => {
      animateTo({ duration: 190, curve: Curve.EaseOut }, () => {
        for (let t of this.activeTiles) {
          t.scaleSize = 1.0
        }
      })
    }, 50)
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
      'tile_' + this.tileIdCounter++,
      value,
      Math.floor(boardIndex / 4),
      boardIndex % 4
    )

    this.logicalBoard[boardIndex] = newTile
    return newTile
  }

  private handleSwipe(offsetX: number, offsetY: number): void {
    let absX: number = Math.abs(offsetX)
    let absY: number = Math.abs(offsetY)

    if (absX < 20 && absY < 20) {
      return
    }

    if (absX > absY) {
      if (offsetX > 0) {
        this.move(1)
      } else {
        this.move(0)
      }
    } else {
      if (offsetY > 0) {
        this.move(3)
      } else {
        this.move(2)
      }
    }
  }

  private move(direction: number): void {
    let gainedScore = 0

    interface MergePair {
      survivor: TileData;
      victim: TileData;
    }

    let pendingMerges: MergePair[] = []
    let victimsToRemove: string[] = []

    // Save initial coordinates to detect if the board physically moved
    interface Position {
      row: number;
      col: number;
    }

    let initialPositions = new Map<string, Position>()
    for (let t of this.activeTiles) {
      initialPositions.set(t.id, { row: t.row, col: t.col } as Position)
    }

    // Slide Animations
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
          if (v + 1 < values.length && values[v].value === values[v+1].value) {
            let survivor = values[v]
            let victim = values[v+1]

            // Instantly update logic so fast-swipes work, but hold displayValue for the slide
            survivor.value *= 2
            gainedScore += survivor.value

            newLine.push(survivor)
            pendingMerges.push({ survivor, victim })
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

      // Force the victims to slide side-by-side with the survivors
      for (let merge of pendingMerges) {
        merge.victim.row = merge.survivor.row
        merge.victim.col = merge.survivor.col
      }

      this.score += gainedScore
      if (this.score > this.bestScore) {
        this.bestScore = this.score
      }
    })

    // Validate if any movement happened
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

    // Cleanup and Merge Pops
    if (moved) {
      // Wait exactly the length of the slide animation before snapping values
      setTimeout(() => {
        // Destroy the victims
        this.activeTiles = this.activeTiles.filter(t => !victimsToRemove.includes(t.id))

        // Upgrade the text value and pop the scale size
        for (let merge of pendingMerges) {
          merge.survivor.displayValue = merge.survivor.value
          merge.survivor.scaleSize = 1.2
        }

        let randomTile = this.createRandomTile()
        if (randomTile) {
          this.activeTiles.push(randomTile)
        }

        // Give ArkUI 20ms to render the new tile at 0.01 and survivor at 1.2, then snap back to 1.0
        setTimeout(() => {
          animateTo({ duration: 150, curve: Curve.EaseOut }, () => {
            for (let merge of pendingMerges) {
              merge.survivor.scaleSize = 1.0
            }
            if (randomTile) {
              randomTile.scaleSize = 1.0
            }
          })
        }, 20)

      }, 200)
    }
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