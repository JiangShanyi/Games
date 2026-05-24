# HarmonyGame

A simple 2048 game built with HarmonyOS ArkTS.

## Overview

The current version includes:

- A 4 x 4 2048 board
- Swipe controls for moving tiles
- Tile merging and new tile spawning
- Real-time score updates
- Best score tracking during the app session
- Win screen when a 2048 tile is created
- Lose screen when no valid moves remain
- New game / restart

## Development Notes

- `score` and `bestScore` are ArkUI `@State` values and are rendered directly in the page so they refresh during gameplay.
- `gameStatus` controls whether the game is currently playing, won, or lost.
- `currentGameId` prevents delayed animation callbacks from an old game from affecting a newly restarted board.
- Tile IDs include the current game id so ArkUI does not reuse old tile views after reset.
