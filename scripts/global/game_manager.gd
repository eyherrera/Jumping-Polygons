extends Node

## Global manager for tracking session statistics, such as attempt counts.

# -- STATE --

## Current attempt count. Defaults to 1 for the first run.
var attempts: int = 1

# -- PUBLIC METHODS --

## Resets the attempt counter back to 1.
## Call this when starting a completely new game session or returning to the menu.
func reset_attempts():
	attempts = 1

## Increments the attempt counter by one.
## Call this immediately upon player death or level restart.
func add_attempt():
	attempts += 1
