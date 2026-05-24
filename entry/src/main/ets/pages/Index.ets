import { Game2048Page } from './2048'
import { MenuPage } from './Menu'
import { TicTacToePage } from './TicTacToe'
import { Game8TilePuzzlePage } from './8TilePuzzle'

@Entry
@Component
struct Index {
  @State currentPage: string = 'menu'

  build() {
    Stack() {
      MenuPage({
        onOpen2048: () => {
          this.currentPage = '2048'
        },
        onOpenTicTacToe: () => {
          this.currentPage = 'ttt'
        },
        onOpenPuzzle: () => {
          this.currentPage = 'puzzle'
        }
      })
        .visibility(this.currentPage === 'menu' ? Visibility.Visible : Visibility.None)

      Game2048Page({
        onBackToMenu: () => {
          this.currentPage = 'menu'
        }
      })
        .visibility(this.currentPage === '2048' ? Visibility.Visible : Visibility.None)

      TicTacToePage({
        onBackToMenu: () => {
          this.currentPage = 'menu'
        }
      })
        .visibility(this.currentPage === 'ttt' ? Visibility.Visible : Visibility.None)

      Game8TilePuzzlePage({
        onBackToMenu: () => {
          this.currentPage = 'menu'
        }
      })
        .visibility(this.currentPage === 'puzzle' ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}