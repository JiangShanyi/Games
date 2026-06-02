@Component
export struct GameStartPage {
  title: string = ''
  description: string = ''
  gameKey: string = 'single'
  accentColor: string = '#D95F4D'
  secondaryColor: string = '#335C67'
  topBackgroundColor: string = '#F7F3E8'
  isMultiplayer: boolean = false
  onBack: () => void = () => {}
  onPlaySingle: (difficulty: number) => void = (difficulty: number) => {}
  onPlayBot: (difficulty: number) => void = (difficulty: number) => {}
  onPlayFriend: (difficulty: number) => void = (difficulty: number) => {}

  @State difficulty: number = 1

  build() {
    Column() {
      // --- TOP HEADER BLOCK ---
      Column() {
        Row() {
          Button('<')
            .width(52)
            .height(52)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.accentColor)
            .backgroundColor('#FFFFFF')
            .borderRadius(26)
            .shadow({ radius: 6, color: '#00000010', offsetX: 0, offsetY: 3 })
            .onClick(() => {
              this.onBack()
            })

          Text(this.title)
            .fontSize(this.titleFontSize())
            .fontWeight(FontWeight.Bold)
            .fontColor('#253238')
            .textAlign(TextAlign.Center)
            .layoutWeight(1)

          Blank()
            .width(52)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(this.description)
          .fontSize(17)
          .fontColor('#5C6D70')
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .margin({ top: 24 })
          .padding({ left: 18, right: 18 })
      }
      .width('100%')
      .height('30%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 22, right: 22, top: 42 })
      .backgroundColor(this.topBackgroundColor)

      // --- MAIN CONTROL CARD & ACTIONS ---
      Column() {
        Column() {
          Row() {
            Text('Difficulty')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#253238')
              .layoutWeight(1)

            Text(this.difficultyTitle())
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.accentColor)
              .borderRadius(12)
              .shadow({ radius: 6, color: '#00000015', offsetX: 0, offsetY: 3 })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 12 }) // Slightly adjusted to balance the larger slider hit box

          // FIXED: Added generous vertical padding to vastly expand the tap and drag touch zone
          Slider({ value: this.difficulty, min: 0, max: 2, step: 0.01 })
            .width('100%')
            .trackThickness(10)
            .blockSize({ width: 28, height: 28 })
            .selectedColor(this.accentColor)
            .blockColor(this.accentColor)
            .padding({ top: 22, bottom: 22 }) // Expands the hit target box vertically
            .onChange((value: number, mode: SliderChangeMode) => {
              if (mode === SliderChangeMode.Moving || mode === SliderChangeMode.Begin) {
                this.difficulty = value
              } else {
                this.snapDifficulty(value)
              }
            })

          // ENLARGED TEXT LABELS
          Row() {
            Text('Easy')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.difficultyLevel() === 0 ? this.accentColor : '#A0B0B2')
              .layoutWeight(1)
              .textAlign(TextAlign.Start)

            Text('Medium')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.difficultyLevel() === 1 ? this.accentColor : '#A0B0B2')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Text('Hard')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.difficultyLevel() === 2 ? this.accentColor : '#A0B0B2')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .margin({ top: 4 }) // Adjusted down to offset the new slider padding
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 28, bottom: 28 })
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
        .shadow({
          radius: 16,
          color: '#1E2A3015',
          offsetX: 0,
          offsetY: 8
        })
        .margin({ bottom: 16 })

        // --- DYNAMIC PLAY BUTTONS ---
        if (this.isMultiplayer) {
          this.ActionButton('Play vs. BOT', 'Challenge our intelligent engine', this.accentColor, 'bot')
          this.ActionButton('Play vs. Friend', 'Pass and play on the same device', this.secondaryColor, 'friend')
        } else {
          this.ActionButton('Play', '', this.accentColor, 'single')
        }

        Blank()
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 24, right: 24, top: 28, bottom: 22 })
      .backgroundColor('#FAF8EF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF8EF')
  }

  // PREMIUM STYLED ACTION BUTTON BUILDER
  @Builder
  ActionButton(title: string, subtitle: string, background: string, action: string) {
    Button() {
      Row() {
        Column() {
          Text(title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          if (subtitle.length > 0) {
            Text(subtitle)
              .fontSize(13)
              .fontColor('#FFFFFFF0')
              .margin({ top: 4 })
              .opacity(0.85)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        Column() {
          Text('➔')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(background)
        }
        .width(46)
        .height(46)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(23)
        .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(86)
    .padding({ left: 24, right: 20 })
    .backgroundColor(background)
    .borderRadius(22)
    .margin({ top: 16 })
    .shadow({
      radius: 12,
      color: background + '35',
      offsetX: 0,
      offsetY: 6
    })
    .onClick(() => {
      this.handleAction(action)
    })
  }

  private handleAction(action: string): void {
    if (action === 'bot') {
      this.onPlayBot(this.difficultyLevel())
    } else if (action === 'friend') {
      this.onPlayFriend(this.difficultyLevel())
    } else {
      this.onPlaySingle(this.difficultyLevel())
    }
  }

  private titleFontSize(): number {
    return this.title.length > 12 ? 26 : 30
  }

  private snapDifficulty(value: number): void {
    let nearest = this.nearestDifficulty(value)

    setTimeout(() => {
      animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
        this.difficulty = nearest
      })
    }, 30)
  }

  private nearestDifficulty(value: number): number {
    let nearest = Math.round(value)
    if (nearest < 0) {
      return 0
    }
    if (nearest > 2) {
      return 2
    }
    return nearest
  }

  private difficultyLevel(): number {
    if (this.difficulty < 0.5) {
      return 0
    }
    if (this.difficulty > 1.5) {
      return 2
    }
    return 1
  }

  private difficultyTitle(): string {
    switch (this.difficultyLevel()) {
      case 0:
        return 'Easy'
      case 2:
        return 'Hard'
      default:
        return 'Medium'
    }
  }
}