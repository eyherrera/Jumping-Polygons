shader_type canvas_item;

// This texture grabs whatever is behind this ColorRect (the game)
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// 0.0 = Normal (Invisible), 1.0 = Fully Pixelated
uniform float progress : hint_range(0.0, 1.0);
uniform float max_pixel_size = 64.0; // How big the blocks get

void fragment() {
	// 1. Calculate the current pixel size based on progress
	// We use pow() to make the start slow and the end fast (exponential feels better)
	float current_size = mix(1.0, max_pixel_size, pow(progress, 3.0));

	// 2. Snap the UV coordinates to a grid
	// SCREEN_UV is 0.0 to 1.0. We divide by pixel size, floor it, then multiply back.
	// We adjust for aspect ratio so pixels stay square-ish.
	vec2 grid_uv = round(SCREEN_UV * (1.0 / SCREEN_PIXEL_SIZE) / current_size) * current_size * SCREEN_PIXEL_SIZE;

	// 3. Output the pixelated color
	COLOR = texture(screen_texture, grid_uv);
}