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
      .height('33%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 22, right: 22, top: 42 })
      .backgroundColor(this.topBackgroundColor)

      Column() {
        Column() {
          Row() {
            Text('Difficulty')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#253238')
              .layoutWeight(1)

            Text(this.difficultyTitle())
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.accentColor)
              .borderRadius(8)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Text(this.difficultyDescription())
            .fontSize(14)
            .fontColor('#5C6D70')
            .lineHeight(20)
            .margin({ top: 12, bottom: 18 })

          Slider({ value: this.difficulty, min: 0, max: 2, step: 1 })
            .width('100%')
            .onChange((value: number) => {
              this.difficulty = Math.round(value)
            })

          Row() {
            Text('Easy')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.difficultyLevel() === 0 ? this.accentColor : '#7B5E4B')
              .layoutWeight(1)
              .textAlign(TextAlign.Start)

            Text('Medium')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.difficultyLevel() === 1 ? this.accentColor : '#7B5E4B')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Text('Hard')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.difficultyLevel() === 2 ? this.accentColor : '#7B5E4B')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 22, right: 22, top: 24, bottom: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({
          radius: 12,
          color: '#1E2A3020',
          offsetX: 0,
          offsetY: 5
        })

        if (this.isMultiplayer) {
          this.ActionButton('Play vs. BOT', 'Use the selected AI level.', this.accentColor, 'bot')

          this.ActionButton('Play vs. friend', 'Share the board on one device.', this.secondaryColor, 'friend')
        } else {
          this.ActionButton('Play', 'Start with the selected difficulty.', this.accentColor, 'single')
        }

        Blank()
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 24, right: 24, top: 24, bottom: 22 })
      .backgroundColor('#FAF8EF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF8EF')
  }

  @Builder
  ActionButton(title: string, subtitle: string, background: string, action: string) {
    Button() {
      Row() {
        Column() {
          Text('>')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(background)
        }
        .width(54)
        .height(54)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ right: 16 })

        Column() {
          Text(title)
            .fontSize(24)
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

  private difficultyDescription(): string {
    let level = this.difficultyLevel()
    if (this.gameKey === '2048') {
      if (level === 0) {
        return 'Gentler random tiles with fewer 4s.'
      }
      if (level === 2) {
        return 'Tougher random tiles with more 4s.'
      }
      return 'Classic random tile mix.'
    }

    if (this.gameKey === 'ttt') {
      if (level === 0) {
        return 'The bot makes playful random moves.'
      }
      if (level === 2) {
        return 'The bot searches for the strongest move.'
      }
      return 'The bot can win, block, and take center.'
    }

    if (level === 0) {
      return '3 x 3 board.'
    }
    if (level === 2) {
      return '5 x 5 board.'
    }
    return '4 x 4 board.'
  }
}
