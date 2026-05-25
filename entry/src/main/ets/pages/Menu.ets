@Component
export struct MenuPage {
  onOpen2048: () => void = () => {}
  onOpenTicTacToe: () => void = () => {}
  onOpenPuzzle: () => void = () => {}

  build() {
    Stack() {
      Column() {
        Column() {
          Text('Mini Games Collection')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4B4038')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ bottom: 32 })

        Button() {
          Row() {
            Column() {
              Text('2048')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor('#4B4038')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('Start')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ left: 18, right: 18, top: 10, bottom: 10 })
              .backgroundColor('#8F7A66')
              .borderRadius(18)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height(120)
        .padding({ left: 20, right: 18 })
        .backgroundColor('#F1E6D8')
        .borderRadius(18)
        .onClick(() => {
          this.onOpen2048()
        })

        Button() {
          Row() {
            Column() {
              Text('Tic Tac Toe')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#4B4038')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('Start')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ left: 18, right: 18, top: 10, bottom: 10 })
              .backgroundColor('#B65F4B')
              .borderRadius(18)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height(120)
        .padding({ left: 20, right: 18 })
        .backgroundColor('#F3E0DF')
        .borderRadius(18)
        .margin({ top: 16 })
        .onClick(() => {
          this.onOpenTicTacToe()
        })

        Button() {
          Row() {
            Column() {
              Text('Sliding Puzzles')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#253238')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('Start')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ left: 18, right: 18, top: 10, bottom: 10 })
              .backgroundColor('#D95F4D')
              .borderRadius(18)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height(120)
        .padding({ left: 20, right: 18 })
        .backgroundColor('#DCE7E1')
        .borderRadius(18)
        .margin({ top: 16 })
        .onClick(() => {
          this.onOpenPuzzle()
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 24,
        right: 24,
        top: 56,
        bottom: 24
      })
      .backgroundColor('#FAF8EF')
    }
    .width('100%')
    .height('100%')
  }
}
