@tool
extends TileMapLayer

# -- WIRELESS CONTROL --
# Assign your EditorMusicSync node here in the Inspector
@export var music_sync_tool: Node2D

@export_category("Shortcuts")
# We removed the immediate reset. Now it stays checked while playing.
@export var preview_active: bool = false:
	set(value):
		preview_active = value # Update the visual checkbox state
		
		if music_sync_tool:
			# Pass the true/false state directly to the tool
			music_sync_tool.preview_active = value
			
			if value:
				print("Remote: Preview Started")
			else:
				print("Remote: Preview Stopped")
		else:
			if value: # Only warn if they tried to turn it ON without a link
				printerr("Please assign the Music Sync Tool to the 'Music Sync Tool' slot!")
				preview_active = false # Reset if link is broken
