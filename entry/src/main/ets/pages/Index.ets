import { Game2048Page } from './2048'
import { MenuPage } from './Menu'
import { GameStartPage } from './StartPage'
import { TicTacToePage } from './TicTacToe'
import { Game8TilePuzzlePage } from './8TilePuzzle'

@Entry
@Component
struct Index {
  @State currentPage: string = 'menu'
  @State selectedGame: string = ''
  @State selectedDifficulty: number = 1
  @State ticTacToeMode: string = 'medium'

  build() {
    Stack() {
      if (this.currentPage === 'menu') {
        MenuPage({
          onOpen2048: () => {
            this.openStartPage('2048')
          },
          onOpenTicTacToe: () => {
            this.openStartPage('ttt')
          },
          onOpenPuzzle: () => {
            this.openStartPage('puzzle')
          }
        })
      } else if (this.currentPage === 'start') {
        GameStartPage({
          title: this.startTitle(),
          description: this.startDescription(),
          gameKey: this.selectedGame,
          accentColor: this.startAccentColor(),
          secondaryColor: this.startSecondaryColor(),
          topBackgroundColor: this.startBackgroundColor(),
          isMultiplayer: this.selectedGame === 'ttt',
          onBack: () => {
            this.currentPage = 'menu'
          },
          onPlaySingle: (difficulty: number) => {
            this.playSingle(difficulty)
          },
          onPlayBot: (difficulty: number) => {
            this.playTicTacToeBot(difficulty)
          },
          onPlayFriend: (difficulty: number) => {
            this.playTicTacToeFriend(difficulty)
          }
        })
      } else if (this.currentPage === '2048') {
        Game2048Page({
          difficultyLevel: this.selectedDifficulty,
          onBackToMenu: () => {
            this.currentPage = 'start'
          }
        })
      } else if (this.currentPage === 'ttt') {
        TicTacToePage({
          launchMode: this.ticTacToeMode,
          onBackToMenu: () => {
            this.currentPage = 'start'
          }
        })
      } else if (this.currentPage === 'puzzle') {
        Game8TilePuzzlePage({
          difficultyLevel: this.selectedDifficulty,
          onBackToMenu: () => {
            this.currentPage = 'start'
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private openStartPage(game: string): void {
    this.selectedGame = game
    this.currentPage = 'start'
  }

  private playSingle(difficulty: number): void {
    this.selectedDifficulty = difficulty
    if (this.selectedGame === '2048') {
      this.currentPage = '2048'
    } else if (this.selectedGame === 'puzzle') {
      this.currentPage = 'puzzle'
    }
  }

  private playTicTacToeBot(difficulty: number): void {
    this.selectedDifficulty = difficulty
    this.ticTacToeMode = this.botModeFromDifficulty(difficulty)
    this.currentPage = 'ttt'
  }

  private playTicTacToeFriend(difficulty: number): void {
    this.selectedDifficulty = difficulty
    this.ticTacToeMode = 'two'
    this.currentPage = 'ttt'
  }

  private botModeFromDifficulty(difficulty: number): string {
    if (difficulty <= 0) {
      return 'easy'
    }
    if (difficulty >= 2) {
      return 'hard'
    }
    return 'medium'
  }

  private startTitle(): string {
    if (this.selectedGame === '2048') {
      return '2048'
    }
    if (this.selectedGame === 'ttt') {
      return 'Tic Tac Toe'
    }
    return 'Sliding Puzzles'
  }

  private startDescription(): string {
    if (this.selectedGame === '2048') {
      return 'Merge matching tiles and chase the 2048 tile before the board fills up.'
    }
    if (this.selectedGame === 'ttt') {
      return 'Make three in a row against a bot or a friend on the same device.'
    }
    return 'Slide numbered tiles into order by moving pieces through the empty space.'
  }

  private startAccentColor(): string {
    if (this.selectedGame === '2048') {
      return '#8F7A66'
    }
    if (this.selectedGame === 'ttt') {
      return '#D95F4D'
    }
    return '#D95F4D'
  }

  private startSecondaryColor(): string {
    if (this.selectedGame === 'ttt') {
      return '#6A3C86'
    }
    return '#335C67'
  }

  private startBackgroundColor(): string {
    if (this.selectedGame === '2048') {
      return '#F1E6D8'
    }
    if (this.selectedGame === 'ttt') {
      return '#F3E0DF'
    }
    return '#DCE7E1'
  }
}
