import { Game2048Cache, Game2048Page } from './2048'
import { MenuPage } from './Menu'
import { GameStartPage } from './StartPage'
import { TicTacToeCache, TicTacToePage } from './TicTacToe'
import { Game8TilePuzzleCache, Game8TilePuzzlePage } from './8TilePuzzle'
import { RingSortCache, RingSortPage } from './RingSort'

@Entry
@Component
struct Index {
  @State currentPage: string = 'menu'
  @State selectedGame: string = ''
  @State selectedDifficulty: number = 1
  @State ticTacToeMode: string = 'medium'
  private game2048Caches: (Game2048Cache | null)[] = [null, null, null]
  private puzzleCaches: (Game8TilePuzzleCache | null)[] = [null, null, null]
  private ringSortCaches: (RingSortCache | null)[] = [null, null, null]
  private ticTacToeCaches: (TicTacToeCache | null)[] = [null, null, null, null, null, null]

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
          },
          onOpenRingSort: () => {
            this.openStartPage('ring')
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
          cache: this.cached2048Page(),
          onCacheChange: (difficultyLevel: number, cache: Game2048Cache) => {
            this.save2048Cache(difficultyLevel, cache)
          },
          onBackToMenu: () => {
            this.currentPage = 'start'
          }
        })
      } else if (this.currentPage === 'ttt') {
        TicTacToePage({
          launchMode: this.ticTacToeMode,
          cacheKey: this.ticTacToeCacheKey(),
          cache: this.cachedTicTacToePage(),
          onCacheChange: (cacheKey: string, cache: TicTacToeCache) => {
            this.saveTicTacToeCache(cacheKey, cache)
          },
          onBackToMenu: () => {
            this.currentPage = 'start'
          }
        })
      } else if (this.currentPage === 'puzzle') {
        Game8TilePuzzlePage({
          difficultyLevel: this.selectedDifficulty,
          cache: this.cachedPuzzlePage(),
          onCacheChange: (difficultyLevel: number, cache: Game8TilePuzzleCache) => {
            this.savePuzzleCache(difficultyLevel, cache)
          },
          onBackToMenu: () => {
            this.currentPage = 'start'
          }
        })
      } else if (this.currentPage === 'ring') {
        RingSortPage({
          difficultyLevel: this.selectedDifficulty,
          cache: this.cachedRingSortPage(),
          onCacheChange: (difficultyLevel: number, cache: RingSortCache) => {
            this.saveRingSortCache(difficultyLevel, cache)
          },
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
    } else if (this.selectedGame === 'ring') {
      this.currentPage = 'ring'
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

  private cached2048Page(): Game2048Cache | null {
    return this.game2048Caches[this.difficultyIndex(this.selectedDifficulty)]
  }

  private save2048Cache(difficultyLevel: number, cache: Game2048Cache): void {
    this.game2048Caches[this.difficultyIndex(difficultyLevel)] = cache
  }

  private cachedPuzzlePage(): Game8TilePuzzleCache | null {
    return this.puzzleCaches[this.difficultyIndex(this.selectedDifficulty)]
  }

  private savePuzzleCache(difficultyLevel: number, cache: Game8TilePuzzleCache): void {
    this.puzzleCaches[this.difficultyIndex(difficultyLevel)] = cache
  }

  private cachedRingSortPage(): RingSortCache | null {
    return this.ringSortCaches[this.difficultyIndex(this.selectedDifficulty)]
  }

  private saveRingSortCache(difficultyLevel: number, cache: RingSortCache): void {
    this.ringSortCaches[this.difficultyIndex(difficultyLevel)] = cache
  }

  private cachedTicTacToePage(): TicTacToeCache | null {
    return this.ticTacToeCaches[this.ticTacToeCacheIndex(this.ticTacToeCacheKey())]
  }

  private saveTicTacToeCache(cacheKey: string, cache: TicTacToeCache): void {
    this.ticTacToeCaches[this.ticTacToeCacheIndex(cacheKey)] = cache
  }

  private difficultyIndex(difficulty: number): number {
    if (difficulty <= 0) {
      return 0
    }
    if (difficulty >= 2) {
      return 2
    }
    return 1
  }

  private ticTacToeCacheKey(): string {
    if (this.ticTacToeMode === 'two') {
      return 'two_' + this.difficultyIndex(this.selectedDifficulty).toString()
    }
    return this.ticTacToeMode
  }

  private ticTacToeCacheIndex(cacheKey: string): number {
    if (cacheKey === 'easy') {
      return 0
    }
    if (cacheKey === 'hard') {
      return 2
    }
    if (cacheKey === 'two_0') {
      return 3
    }
    if (cacheKey === 'two_1') {
      return 4
    }
    if (cacheKey === 'two_2') {
      return 5
    }
    return 1
  }

  private startTitle(): string {
    if (this.selectedGame === '2048') {
      return '2048'
    }
    if (this.selectedGame === 'ttt') {
      return 'Tic Tac Toe'
    }
    if (this.selectedGame === 'ring') {
      return 'Ring Sort'
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
    if (this.selectedGame === 'ring') {
      return 'Lift top rings between stations until every finished station holds one color.'
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
    if (this.selectedGame === 'ring') {
      return '#B08A3F'
    }
    return '#D95F4D'
  }

  private startSecondaryColor(): string {
    if (this.selectedGame === 'ttt') {
      return '#6A3C86'
    }
    if (this.selectedGame === 'ring') {
      return '#2F5148'
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
    if (this.selectedGame === 'ring') {
      return '#E8E1D0'
    }
    return '#DCE7E1'
  }
}
