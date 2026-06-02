export class RingSortCache {
  difficultyLevel: number;
  stations: string[][];
  gameStatus: string;
  selectedStationIndex: number;
  liftProgress: number;
  currentPuzzleLevel: number;
  undoStack: string[][][];
  canUndo: boolean;

  constructor(
    difficultyLevel: number,
    stations: string[][],
    gameStatus: string,
    selectedStationIndex: number,
    liftProgress: number,
    currentPuzzleLevel: number,
    undoStack: string[][][],
    canUndo: boolean
  ) {
    this.difficultyLevel = difficultyLevel;
    this.stations = stations;
    this.gameStatus = gameStatus;
    this.selectedStationIndex = selectedStationIndex;
    this.liftProgress = liftProgress;
    this.currentPuzzleLevel = currentPuzzleLevel;
    this.undoStack = undoStack;
    this.canUndo = canUndo;
  }
}

@Component
export struct RingSortPage {
  onBackToMenu: () => void = () => {}
  onCacheChange: (difficultyLevel: number, cache: RingSortCache) => void =
    (difficultyLevel: number, cache: RingSortCache) => {}
  difficultyLevel: number = 1
  cache: RingSortCache | null = null

  @State stations: string[][] = []
  @State selectedStationIndex: number = -1
  @State gameStatus: string = 'playing'
  @State isAnimating: boolean = false
  @State liftProgress: number = 0
  @State movingFromIndex: number = -1
  @State movingToIndex: number = -1
  @State movingColor: string = ''
  @State movingStartLevel: number = 0
  @State movingEndLevel: number = 0
  @State moveTravelProgress: number = 0
  @State moveDropProgress: number = 0
  @State finishedStationIndex: number = -1
  @State finishPulseProgress: number = 0
  @State canUndo: boolean = false
  @State currentPuzzleLevel: number = 1

  private animationId: number = 0
  private undoStack: string[][][] = []

  aboutToAppear(): void {
    if (this.cache !== null && this.cache.difficultyLevel === this.normalizedDifficulty()) {
      this.restoreCache(this.cache)
    } else {
      this.startNewGame()
    }
  }

  build() {
    Stack() {
      Column() {
        Column() {
          Row() {
            Button('<')
              .width(42)
              .height(42)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F7F2E8')
              .backgroundColor('#2F5148')
              .borderRadius(21)
              .onClick(() => {
                this.returnToMenu()
              })

            Text(this.levelName() + ' Ring Sort - Level ' + this.currentPuzzleLevel.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F7F2E8')
              .textAlign(TextAlign.Center)
              .layoutWeight(1)

            Blank()
              .width(42)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Row() {
            Button('Undo')
              .width(88)
              .height(34)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.canUndo ? '#23312E' : '#D8DED4')
              .backgroundColor(this.canUndo ? '#F7F2E8' : '#64766E')
              .borderRadius(17)
              .margin({ right: 10 })
              .onClick(() => {
                this.undoMove()
              })

            Button('Restart')
              .width(88)
              .height(34)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#23312E')
              .backgroundColor('#F7F2E8')
              .borderRadius(17)
              .onClick(() => {
                this.startNewGame()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 10 })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Stack() {
          Grid() {
            ForEach(this.stationIndexes(), (index: number) => {
              GridItem() {
                this.StationView(index)
              }
              .zIndex(this.stationLayer(index))
              .clip(false)
            }, (index: number) => index.toString())
          }
          .columnsTemplate(this.gridTemplate())
          .rowsTemplate('1fr 1fr')
          .columnsGap(this.stationGap())
          .rowsGap(this.stationRowGap())
          .width('100%')
          .height('100%')
          .clip(false)

          if (this.isMovingRingVisible()) {
            this.MovingRing()
          }

          if (this.gameStatus === 'won') {
            this.ResultLayer()
          }
        }
        .width(this.boardWidth())
        .height(this.boardHeight())
        .alignSelf(ItemAlign.Center)
        .margin({ top: 48 })
        .clip(false)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 18,
        right: 18,
        top: 30,
        bottom: 18
      })
      .backgroundColor('#172B27')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StationView(index: number) {
    Stack() {
      this.FinishGlow(index)
      this.RodBack(index)

      ForEach(this.ringLevelIndexes(), (level: number) => {
        this.StationRing(index, level)
      }, (level: number) => level.toString())

      this.RodFront(index)
      this.BaseView(index)
      this.StationHalo(index)
    }
    .width(this.stationWidth())
    .height(this.stationHeight())
    .scale({
      x: this.stationScale(index),
      y: this.stationScale(index),
      centerX: '50%',
      centerY: '70%'
    })
    .zIndex(this.stationLayer(index))
    .onClick(() => {
      this.handleStationTap(index)
    })
  }

  @Builder
  StationRing(stationIndex: number, level: number) {
    if (this.shouldShowRing(stationIndex, level)) {
      Stack() {
        Column()
          .width(this.ringWidth())
          .height(this.ringHeight())
          .backgroundColor(this.ringColor(this.stations[stationIndex][level]))
          .borderRadius(this.ringHeight() / 2)
          .border({
            width: 1,
            color: this.ringBorderColor(stationIndex, level)
          })
          .shadow({
            radius: this.ringShadowRadius(stationIndex, level),
            color: this.ringShadowColor(stationIndex, level),
            offsetX: 0,
            offsetY: 4
          })

        Column()
          .width(this.ringHoleWidth())
          .height(this.ringHoleHeight())
          .backgroundColor('#D8DED4')
          .borderRadius(this.ringHoleHeight() / 2)
          .position({
            x: (this.ringWidth() - this.ringHoleWidth()) / 2,
            y: (this.ringHeight() - this.ringHoleHeight()) / 2
          })
          .opacity(0.86)

      }
      .width(this.ringWidth())
      .height(this.ringHeight())
      .position({
        x: this.ringLeft(),
        y: this.ringTop(level)
      })
      .translate({
        x: 0,
        y: this.stationRingTranslateY(stationIndex, level),
        z: 0
      })
      .scale({
        x: this.ringScale(stationIndex),
        y: this.ringScale(stationIndex),
        centerX: '50%',
        centerY: '50%'
      })
      .zIndex(this.ringLayer(stationIndex, level))
    }
  }

  @Builder
  MovingRing() {
    Stack() {
      Column()
        .width(this.ringWidth())
        .height(this.ringHeight())
        .backgroundColor(this.ringColor(this.movingColor))
        .borderRadius(this.ringHeight() / 2)
        .border({ width: 1, color: '#D6A94F' })
        .shadow({
          radius: 12,
          color: '#00000055',
          offsetX: 0,
          offsetY: 8
        })

      Column()
        .width(this.ringHoleWidth())
        .height(this.ringHoleHeight())
        .backgroundColor('#D8DED4')
        .borderRadius(this.ringHoleHeight() / 2)
        .position({
          x: (this.ringWidth() - this.ringHoleWidth()) / 2,
          y: (this.ringHeight() - this.ringHoleHeight()) / 2
        })
        .opacity(0.9)

    }
    .width(this.ringWidth())
    .height(this.ringHeight())
    .position({
      x: this.movingRingX(),
      y: this.movingRingY()
    })
    .scale({
      x: 1.04,
      y: 1.04,
      centerX: '50%',
      centerY: '50%'
    })
    .zIndex(30)
  }

  @Builder
  RodBack(index: number) {
    Column()
      .width(this.rodWidth())
      .height(this.rodHeight())
      .backgroundColor(this.rodColor(index))
      .borderRadius(this.rodWidth() / 2)
      .position({
        x: (this.stationWidth() - this.rodWidth()) / 2,
        y: this.rodTop()
      })
      .shadow({
        radius: 5,
        color: '#00000035',
        offsetX: 0,
        offsetY: 2
      })
      .zIndex(1)
  }

  @Builder
  RodFront(index: number) {
    Column()
      .width(this.rodWidth())
      .height(this.rodHeight())
      .backgroundColor(this.rodFrontColor(index))
      .borderRadius(this.rodWidth() / 2)
      .position({
        x: (this.stationWidth() - this.rodWidth()) / 2,
        y: this.rodTop()
      })
      .opacity(0.7)
      .zIndex(9)
  }

  @Builder
  BaseView(index: number) {
    Stack() {
      Column()
        .width(this.baseWidth())
        .height(this.baseHeight())
        .backgroundColor(this.baseColor(index))
        .borderRadius(this.baseHeight() / 2)
        .border({
          width: this.baseBorderWidth(index),
          color: this.baseBorderColor(index)
        })

      Column()
        .width(this.baseWidth() - 12)
        .height(5)
        .backgroundColor('#FFFFFF40')
        .borderRadius(3)
        .position({ x: 6, y: 3 })
    }
    .width(this.baseWidth())
    .height(this.baseHeight())
    .position({
      x: (this.stationWidth() - this.baseWidth()) / 2,
      y: this.baseTop()
    })
    .zIndex(12)
  }

  @Builder
  FinishGlow(index: number) {
    Column()
      .width(this.stationWidth())
      .height(this.stationHeight())
      .backgroundColor(this.finishedStationIndex === index ? '#F6D36B' : '#00000000')
      .opacity(this.finishedStationIndex === index ? this.finishPulseProgress * 0.18 : 0)
      .borderRadius(18)
      .zIndex(0)
  }

  @Builder
  StationHalo(index: number) {
    Column()
      .width(this.stationWidth())
      .height(this.stationHeight())
      .backgroundColor('#00000000')
      .borderRadius(18)
      .border({
        width: this.stationHaloWidth(index),
        color: this.stationHaloColor(index)
      })
      .opacity(this.stationHaloOpacity(index))
      .zIndex(20)
  }

  @Builder
  ResultLayer() {
    Column() {
      Text(this.resultTitle())
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F7F2E8')
        .margin({ bottom: 22 })

      Button(this.resultButtonTitle())
        .width(144)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#23312E')
        .backgroundColor('#F7F2E8')
        .borderRadius(10)
        .onClick(() => {
          this.handleResultAction()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#172B27E8')
    .borderRadius(18)
    .zIndex(40)
  }

  private returnToMenu(): void {
    this.onCacheChange(this.normalizedDifficulty(), this.createCache())
    this.animationId += 1
    this.isAnimating = false
    this.onBackToMenu()
  }

  private startNewGame(): void {
    this.animationId += 1
    this.stations = this.copyStations(this.levelTemplate())
    this.selectedStationIndex = -1
    this.gameStatus = 'playing'
    this.isAnimating = false
    this.liftProgress = 0
    this.movingFromIndex = -1
    this.movingToIndex = -1
    this.movingColor = ''
    this.movingStartLevel = 0
    this.movingEndLevel = 0
    this.moveTravelProgress = 0
    this.moveDropProgress = 0
    this.finishedStationIndex = -1
    this.finishPulseProgress = 0
    this.undoStack = []
    this.canUndo = false
  }

  private createCache(): RingSortCache {
    return new RingSortCache(
      this.normalizedDifficulty(),
      this.copyStations(this.stations),
      this.gameStatus,
      this.isAnimating ? -1 : this.selectedStationIndex,
      this.isAnimating ? 0 : this.liftProgress,
      this.currentPuzzleLevel,
      this.copyUndoStack(this.undoStack),
      this.canUndo
    )
  }

  private restoreCache(cache: RingSortCache): void {
    this.animationId += 1
    this.stations = this.copyStations(cache.stations)
    this.selectedStationIndex = cache.selectedStationIndex
    this.gameStatus = cache.gameStatus
    this.isAnimating = false
    this.liftProgress = cache.liftProgress
    this.movingFromIndex = -1
    this.movingToIndex = -1
    this.movingColor = ''
    this.movingStartLevel = 0
    this.movingEndLevel = 0
    this.moveTravelProgress = 0
    this.moveDropProgress = 0
    this.finishedStationIndex = -1
    this.finishPulseProgress = 0
    this.currentPuzzleLevel = cache.currentPuzzleLevel
    this.undoStack = this.copyUndoStack(cache.undoStack)
    this.canUndo = cache.canUndo && this.undoStack.length > 0
  }

  private handleResultAction(): void {
    this.currentPuzzleLevel += 1
    this.startNewGame()
  }

  private handleStationTap(index: number): void {
    if (this.gameStatus !== 'playing' || this.isAnimating) {
      return
    }

    if (this.selectedStationIndex < 0) {
      this.selectStation(index)
      return
    }

    if (this.selectedStationIndex === index) {
      this.dropSelection()
      return
    }

    this.tryMoveRing(this.selectedStationIndex, index)
  }

  private selectStation(index: number): void {
    if (this.stations[index].length === 0) {
      return
    }

    let selectId = ++this.animationId
    this.isAnimating = true
    this.selectedStationIndex = index
    this.liftProgress = 0

    animateTo({ duration: 150, curve: Curve.EaseOut }, () => {
      this.liftProgress = 1
    })

    setTimeout(() => {
      if (selectId !== this.animationId) {
        return
      }

      this.isAnimating = false
    }, 155)
  }

  private dropSelection(): void {
    let dropId = ++this.animationId
    this.isAnimating = true

    animateTo({ duration: 140, curve: Curve.EaseInOut }, () => {
      this.liftProgress = 0
    })

    setTimeout(() => {
      if (dropId !== this.animationId) {
        return
      }

      this.selectedStationIndex = -1
      this.isAnimating = false
    }, 145)
  }

  private undoMove(): void {
    if (this.isAnimating || this.undoStack.length === 0) {
      return
    }

    let previousStations = this.undoStack.pop()
    this.canUndo = this.undoStack.length > 0
    if (!previousStations) {
      return
    }

    this.animationId += 1
    this.stations = this.copyStations(previousStations)
    this.selectedStationIndex = -1
    this.gameStatus = 'playing'
    this.isAnimating = false
    this.liftProgress = 0
    this.movingFromIndex = -1
    this.movingToIndex = -1
    this.movingColor = ''
    this.movingStartLevel = 0
    this.movingEndLevel = 0
    this.moveTravelProgress = 0
    this.moveDropProgress = 0
    this.finishedStationIndex = -1
    this.finishPulseProgress = 0
  }

  private pushUndoSnapshot(snapshot: string[][]): void {
    this.undoStack.push(this.copyStations(snapshot))
    this.canUndo = true
  }

  private tryMoveRing(fromIndex: number, toIndex: number): void {
    if (!this.canMoveRing(fromIndex, toIndex)) {
      return
    }

    let source = this.stations[fromIndex]
    let destination = this.stations[toIndex]
    let autoMoveCount = this.autoMoveRingCount(source, destination)
    let previousStations = this.copyStations(this.stations)
    let targetWasComplete = this.isCompleteStation(destination)
    let moveId = ++this.animationId

    this.pushUndoSnapshot(previousStations)
    this.isAnimating = true

    this.playMoveStep(fromIndex, toIndex, autoMoveCount, 0, moveId, targetWasComplete)
  }

  private playMoveStep(
    fromIndex: number,
    toIndex: number,
    totalMoves: number,
    moveIndex: number,
    moveId: number,
    targetWasComplete: boolean
  ): void {
    if (moveId !== this.animationId) {
      return
    }

    let source = this.stations[fromIndex]
    let destination = this.stations[toIndex]
    if (source.length === 0 || destination.length >= this.capacity()) {
      this.finishMoveSequence(toIndex, moveId, targetWasComplete)
      return
    }

    let movingColor = source[source.length - 1]
    let travelDuration = moveIndex === 0 ? 340 : 145
    let dropDuration = moveIndex === 0 ? 190 : 80

    this.movingFromIndex = fromIndex
    this.movingToIndex = toIndex
    this.movingColor = movingColor
    this.movingStartLevel = source.length - 1
    this.movingEndLevel = destination.length
    this.moveTravelProgress = 0
    this.moveDropProgress = 0

    animateTo({ duration: travelDuration, curve: Curve.EaseInOut }, () => {
      this.moveTravelProgress = 1
    })

    setTimeout(() => {
      if (moveId !== this.animationId) {
        return
      }

      animateTo({ duration: dropDuration, curve: Curve.EaseInOut }, () => {
        this.moveDropProgress = 1
      })
    }, travelDuration + 5)

    setTimeout(() => {
      if (moveId !== this.animationId) {
        return
      }

      let nextStations = this.copyStations(this.stations)
      let ring = nextStations[fromIndex].pop()
      if (ring) {
        nextStations[toIndex].push(ring)
      }
      this.stations = nextStations
      this.movingFromIndex = -1
      this.movingToIndex = -1
      this.movingColor = ''
      this.moveTravelProgress = 0
      this.moveDropProgress = 0

      if (moveIndex + 1 < totalMoves) {
        setTimeout(() => {
          this.playMoveStep(fromIndex, toIndex, totalMoves, moveIndex + 1, moveId, targetWasComplete)
        }, 35)
        return
      }

      this.finishMoveSequence(toIndex, moveId, targetWasComplete)
    }, travelDuration + dropDuration + 15)
  }

  private finishMoveSequence(toIndex: number, moveId: number, targetWasComplete: boolean): void {
    if (moveId !== this.animationId) {
      return
    }

    this.selectedStationIndex = -1
    this.liftProgress = 0

    let newlyFinishedStation = !targetWasComplete && this.isCompleteStation(this.stations[toIndex])
    let solvedAfterMove = this.isSolvedStations(this.stations)

    if (newlyFinishedStation) {
      this.playFinishedStationAnimation(toIndex, moveId)
    }

    setTimeout(() => {
      if (moveId !== this.animationId) {
        return
      }

      this.isAnimating = false
      if (solvedAfterMove) {
        this.gameStatus = 'won'
      }
    }, newlyFinishedStation ? 360 : 0)
  }

  private canMoveRing(fromIndex: number, toIndex: number): boolean {
    if (fromIndex < 0 || fromIndex >= this.stations.length || toIndex < 0 || toIndex >= this.stations.length) {
      return false
    }

    let source = this.stations[fromIndex]
    let destination = this.stations[toIndex]
    if (source.length === 0 || destination.length >= this.capacity()) {
      return false
    }

    if (destination.length === 0) {
      return true
    }

    return destination[destination.length - 1] === source[source.length - 1]
  }

  private autoMoveRingCount(source: string[], destination: string[]): number {
    let movingColor = source[source.length - 1]
    let matchingTopCount = this.matchingTopRingCount(source, movingColor)
    let availableSpace = this.capacity() - destination.length

    if (matchingTopCount < 2 || this.isCompleteStation(source)) {
      return 1
    }

    if (availableSpace < matchingTopCount) {
      return 1
    }

    return matchingTopCount
  }

  private matchingTopRingCount(station: string[], color: string): number {
    let count = 0
    for (let i = station.length - 1; i >= 0; i--) {
      if (station[i] !== color) {
        break
      }
      count++
    }
    return count
  }

  private levelTemplate(): string[][] {
    let stations = this.solvedLevelTemplate()
    let seed = this.levelSeed()
    let lastFromIndex = -1
    let lastToIndex = -1
    let moves = this.scrambleMoveCount()

    for (let i = 0; i < moves; i++) {
      let options = this.inverseScrambleMoveOptions(stations, lastFromIndex, lastToIndex)
      if (options.length === 0) {
        options = this.inverseScrambleMoveOptions(stations, -1, -1)
      }
      if (options.length === 0) {
        break
      }

      seed = this.nextSeed(seed)
      let selectedMove = options[Math.floor(seed % options.length)]
      let fromIndex = selectedMove[0]
      let toIndex = selectedMove[1]
      let ring = stations[fromIndex].pop()
      if (ring) {
        stations[toIndex].push(ring)
      }
      lastFromIndex = fromIndex
      lastToIndex = toIndex
    }

    return stations
  }

  private solvedLevelTemplate(): string[][] {
    let stations: string[][] = []
    let colors = this.levelColors()

    for (let i = 0; i < colors.length; i++) {
      let station: string[] = []
      for (let j = 0; j < this.capacity(); j++) {
        station.push(colors[i])
      }
      stations.push(station)
    }

    stations.push([])
    stations.push([])
    return stations
  }

  private inverseScrambleMoveOptions(stations: string[][], lastFromIndex: number, lastToIndex: number): number[][] {
    let options: number[][] = []

    for (let fromIndex = 0; fromIndex < stations.length; fromIndex++) {
      let source = stations[fromIndex]
      if (source.length === 0) {
        continue
      }

      let ring = source[source.length - 1]
      if (source.length > 1 && source[source.length - 2] !== ring) {
        continue
      }

      for (let toIndex = 0; toIndex < stations.length; toIndex++) {
        if (fromIndex === toIndex || stations[toIndex].length >= this.capacity()) {
          continue
        }

        if (fromIndex === lastToIndex && toIndex === lastFromIndex) {
          continue
        }

        options.push([fromIndex, toIndex])
      }
    }

    return options
  }

  private levelColors(): string[] {
    let allColors: string[] = ['A', 'B', 'C', 'D', 'E', 'F']
    let colors: string[] = []
    let count = this.levelColorCount()

    for (let i = 0; i < count; i++) {
      colors.push(allColors[i])
    }

    return colors
  }

  private levelColorCount(): number {
    let maxColors = this.maxColorCount()
    if (this.currentPuzzleLevel <= 4) {
      return maxColors - 1
    }

    return maxColors
  }

  private maxColorCount(): number {
    if (this.difficultyLevel <= 0) {
      return 4
    }
    if (this.difficultyLevel >= 2) {
      return 6
    }
    return 5
  }

  private scrambleMoveCount(): number {
    let level = this.currentPuzzleLevel
    let baseMoves = this.levelColorCount() * this.capacity()
    let stepMoves = 3

    if (this.difficultyLevel <= 0) {
      stepMoves = 2
    } else if (this.difficultyLevel >= 2) {
      stepMoves = 4
    }

    return baseMoves + ((level - 1) * stepMoves)
  }

  private levelSeed(): number {
    return (7919 * (this.normalizedDifficulty() + 2)) + (104729 * this.currentPuzzleLevel) + 13
  }

  private nextSeed(seed: number): number {
    return ((seed * 1664525) + 1013904223) % 2147483647
  }

  private copyStations(source: string[][]): string[][] {
    let next: string[][] = []
    for (let station of source) {
      next.push(station.slice())
    }
    return next
  }

  private copyUndoStack(source: string[][][]): string[][][] {
    let next: string[][][] = []
    for (let snapshot of source) {
      next.push(this.copyStations(snapshot))
    }
    return next
  }

  private stationIndexes(): number[] {
    let indexes: number[] = []
    for (let i = 0; i < this.stations.length; i++) {
      indexes.push(i)
    }
    return indexes
  }

  private ringLevelIndexes(): number[] {
    let levels: number[] = []
    for (let i = 0; i < this.capacity(); i++) {
      levels.push(i)
    }
    return levels
  }

  private shouldShowRing(stationIndex: number, level: number): boolean {
    if (!this.hasRingAt(stationIndex, level)) {
      return false
    }
    if (this.movingFromIndex === stationIndex && this.movingStartLevel === level) {
      return false
    }
    return true
  }

  private hasRingAt(stationIndex: number, level: number): boolean {
    if (stationIndex < 0 || stationIndex >= this.stations.length) {
      return false
    }
    return this.stations[stationIndex].length > level
  }

  private isSolvedStations(stations: string[][]): boolean {
    for (let station of stations) {
      if (station.length === 0) {
        continue
      }

      if (!this.isCompleteStation(station)) {
        return false
      }
    }
    return true
  }

  private isCompleteStation(station: string[]): boolean {
    if (station.length !== this.capacity()) {
      return false
    }

    let color = station[0]
    for (let ring of station) {
      if (ring !== color) {
        return false
      }
    }
    return true
  }

  private playFinishedStationAnimation(index: number, moveId: number): void {
    this.finishedStationIndex = index
    this.finishPulseProgress = 0

    animateTo({ duration: 130, curve: Curve.EaseOut }, () => {
      this.finishPulseProgress = 1
    })

    setTimeout(() => {
      if (moveId !== this.animationId) {
        return
      }

      animateTo({ duration: 210, curve: Curve.EaseInOut }, () => {
        this.finishPulseProgress = 0
      })
    }, 135)

    setTimeout(() => {
      if (moveId !== this.animationId) {
        return
      }

      this.finishedStationIndex = -1
    }, 355)
  }

  private levelName(): string {
    if (this.difficultyLevel <= 0) {
      return 'Easy'
    }
    if (this.difficultyLevel >= 2) {
      return 'Hard'
    }
    return 'Medium'
  }

  private resultTitle(): string {
    return 'Level ' + this.currentPuzzleLevel.toString() + ' Complete!'
  }

  private resultButtonTitle(): string {
    return 'Next Level'
  }

  private normalizedDifficulty(): number {
    if (this.difficultyLevel <= 0) {
      return 0
    }
    if (this.difficultyLevel >= 2) {
      return 2
    }
    return 1
  }

  private capacity(): number {
    if (this.difficultyLevel <= 0) {
      return 3
    }
    if (this.difficultyLevel >= 2) {
      return 5
    }
    return 4
  }

  private ringColor(color: string): string {
    switch (color) {
      case 'A':
        return '#D84C4C'
      case 'B':
        return '#40C58B'
      case 'C':
        return '#F0C84D'
      case 'D':
        return '#6C67D8'
      case 'E':
        return '#4DA8D8'
      case 'F':
        return '#D98245'
      default:
        return '#D8DED4'
    }
  }

  private stationColumns(): number {
    return this.stations.length <= 6 ? 3 : 4
  }

  private stationWidth(): number {
    return this.stationColumns() === 3 ? 74 : 64
  }

  private stationHeight(): number {
    if (this.capacity() >= 5) {
      return 158
    }
    if (this.capacity() <= 3) {
      return 142
    }
    return 150
  }

  private stationGap(): number {
    return this.stationColumns() === 3 ? 22 : 14
  }

  private stationRowGap(): number {
    return 30
  }

  private boardWidth(): number {
    return (this.stationColumns() * this.stationWidth()) + ((this.stationColumns() - 1) * this.stationGap())
  }

  private boardHeight(): number {
    return (this.stationHeight() * 2) + this.stationRowGap()
  }

  private ringWidth(): number {
    return this.stationColumns() === 3 ? 62 : 54
  }

  private ringHeight(): number {
    return this.capacity() >= 5 ? 18 : 20
  }

  private ringGap(): number {
    return 0
  }

  private ringStep(): number {
    return this.ringHeight() + this.ringGap()
  }

  private ringLeft(): number {
    return (this.stationWidth() - this.ringWidth()) / 2
  }

  private ringTop(level: number): number {
    return this.baseTop() - this.ringHeight() - (level * this.ringStep())
  }

  private ringHoleWidth(): number {
    return this.ringWidth() * 0.42
  }

  private ringHoleHeight(): number {
    return Math.max(7, this.ringHeight() - 9)
  }

  private liftHeight(): number {
    return 34
  }

  private ringLiftHeight(level: number): number {
    let clearTop = this.rodTop() - this.ringHeight() - 8
    let neededLift = this.ringTop(level) - clearTop
    return Math.max(this.liftHeight(), neededLift)
  }

  private stationRingTranslateY(stationIndex: number, level: number): number {
    if (this.selectedStationIndex === stationIndex && this.stations[stationIndex].length - 1 === level) {
      return -this.ringLiftHeight(level) * this.liftProgress
    }
    return 0
  }

  private rodWidth(): number {
    return 8
  }

  private rodTop(): number {
    return 30
  }

  private rodHeight(): number {
    return this.baseTop() - this.rodTop() + 4
  }

  private baseWidth(): number {
    return this.stationWidth() - 2
  }

  private baseHeight(): number {
    return 20
  }

  private baseTop(): number {
    return this.stationHeight() - this.baseHeight() - 2
  }

  private baseBorderWidth(index: number): number {
    if (this.finishedStationIndex === index && this.finishPulseProgress > 0) {
      return 3
    }
    return 1
  }

  private baseColor(index: number): string {
    if (this.finishedStationIndex === index && this.finishPulseProgress > 0) {
      return '#B08A3F'
    }
    return '#59645E'
  }

  private baseBorderColor(index: number): string {
    if (this.finishedStationIndex === index && this.finishPulseProgress > 0) {
      return '#F6D36B'
    }
    return '#9CA79E'
  }

  private rodColor(index: number): string {
    return '#C2CBBF'
  }

  private rodFrontColor(index: number): string {
    return '#EEF3E7'
  }

  private stationHaloWidth(index: number): number {
    if (this.finishedStationIndex === index && this.finishPulseProgress > 0) {
      return 2 + (this.finishPulseProgress * 3)
    }
    return 0
  }

  private stationHaloColor(index: number): string {
    if (this.finishedStationIndex === index && this.finishPulseProgress > 0) {
      return '#F6D36B'
    }
    return '#F7F2E8'
  }

  private stationHaloOpacity(index: number): number {
    if (this.finishedStationIndex === index && this.finishPulseProgress > 0) {
      return 0.35 + (this.finishPulseProgress * 0.45)
    }
    return 0
  }

  private stationScale(index: number): number {
    if (this.finishedStationIndex === index) {
      return 1 + (this.finishPulseProgress * 0.05)
    }
    return 1
  }

  private ringScale(stationIndex: number): number {
    if (this.finishedStationIndex === stationIndex) {
      return 1 + (this.finishPulseProgress * 0.05)
    }
    return 1
  }

  private ringBorderColor(stationIndex: number, level: number): string {
    if (this.selectedStationIndex === stationIndex && this.stations[stationIndex].length - 1 === level) {
      return '#D6A94F'
    }
    if (this.finishedStationIndex === stationIndex) {
      return '#F6D36B'
    }
    return '#00000035'
  }

  private ringShadowRadius(stationIndex: number, level: number): number {
    if (this.selectedStationIndex === stationIndex && this.stations[stationIndex].length - 1 === level) {
      return 10
    }
    if (this.finishedStationIndex === stationIndex) {
      return 8
    }
    return 4
  }

  private ringShadowColor(stationIndex: number, level: number): string {
    if (this.selectedStationIndex === stationIndex && this.stations[stationIndex].length - 1 === level) {
      return '#F6D36B88'
    }
    if (this.finishedStationIndex === stationIndex) {
      return '#F6D36B66'
    }
    return '#00000040'
  }

  private ringLayer(stationIndex: number, level: number): number {
    if (this.selectedStationIndex === stationIndex && this.stations[stationIndex].length - 1 === level) {
      return 24
    }
    return 4 + level
  }

  private stationLayer(index: number): number {
    if (this.movingFromIndex === index || this.movingToIndex === index) {
      return 8
    }
    if (this.selectedStationIndex === index || this.finishedStationIndex === index) {
      return 6
    }
    return 1
  }

  private isMovingRingVisible(): boolean {
    return this.movingFromIndex >= 0 && this.movingToIndex >= 0 && this.movingColor !== ''
  }

  private movingRingX(): number {
    let progress = this.easeInOutProgress(this.moveTravelProgress)
    let startX = this.ringBoardX(this.movingFromIndex, this.movingStartLevel)
    let endX = this.ringBoardX(this.movingToIndex, this.movingEndLevel)
    return startX + ((endX - startX) * progress)
  }

  private movingRingY(): number {
    let progress = this.easeInOutProgress(this.moveTravelProgress)
    let startLift = this.ringLiftHeight(this.movingStartLevel)
    let endLift = this.ringLiftHeight(this.movingEndLevel)
    let startY = this.ringBoardY(this.movingFromIndex, this.movingStartLevel) - startLift
    let endLiftY = this.ringBoardY(this.movingToIndex, this.movingEndLevel) - endLift
    let arc = Math.sin(progress * 3.14159) * 18
    return startY + ((endLiftY - startY) * progress) - arc + (endLift * this.easeInProgress(this.moveDropProgress))
  }

  private ringBoardX(stationIndex: number, level: number): number {
    return this.stationLeft(stationIndex) + this.ringLeft()
  }

  private ringBoardY(stationIndex: number, level: number): number {
    return this.stationTop(stationIndex) + this.ringTop(level)
  }

  private stationLeft(index: number): number {
    if (index < 0) {
      return 0
    }
    return (index % this.stationColumns()) * (this.stationWidth() + this.stationGap())
  }

  private stationTop(index: number): number {
    if (index < 0) {
      return 0
    }
    return Math.floor(index / this.stationColumns()) * (this.stationHeight() + this.stationRowGap())
  }

  private easeInProgress(progress: number): number {
    let clamped = this.clampProgress(progress)
    return clamped * clamped
  }

  private easeInOutProgress(progress: number): number {
    let clamped = this.clampProgress(progress)
    if (clamped < 0.5) {
      return 2 * clamped * clamped
    }

    let remaining = -2 * clamped + 2
    return 1 - ((remaining * remaining) / 2)
  }

  private clampProgress(progress: number): number {
    if (progress < 0) {
      return 0
    }
    if (progress > 1) {
      return 1
    }
    return progress
  }

  private gridTemplate(): string {
    let result = '1fr'
    for (let i = 1; i < this.stationColumns(); i++) {
      result += ' 1fr'
    }
    return result
  }
}
