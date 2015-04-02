local colors = {
	border     = { 50, 60, 150, 180 },
	background = { 30, 30, 50, 250 },
	heading    = mul({ 200, 220, 255, 255 }, 0.5),
	button     = { 255, 255, 255, 255 },
	text       = { 230, 230, 230, 255 },
}

local fonts = {
	normal = "assets/NotoSans-Regular.ttf",
	bold   = "assets/NotoSans-Bold.ttf",
}

return {
	{ ".window_frame", {
		background_path  = "assets/window-inactive.9.png",
		margin           = 15,
		padding          = 4,
		width            = 350,
		height           = 400,
		--visible          = false,
		position         = "absolute",
		font_path        = fonts.normal,
		font_size        = 18,

		{ "text", {
			text_color = colors.text,
			text_align = "justify",
			margin     = 10,
		}},

		{ "textinput", {
			border     = 2,
			text_color = colors.text,
			margin     = 10,
			padding    = { 0, 5, 3, 5 },
			width      = "100%",
		}},

		{ "textinput:focus", {
			background_color = { 255, 255, 255, 15 },
		}},

		{ "image", {
			margin = 10,
			border = 1,
			background_color = opacity(colors.background, 0.75),
			border_color = colors.border,
			border_radius = 4,
			width  = 64,
			height = 64,
		}},
	}},

	{ ".window_frame:focus", {
		background_path  = "assets/window-active.9.png",
	}},

	{ ".window_frame_title", {
		background_color = alpha(mul(colors.background, 0.5), 0.5),
		text_transform = "uppercase",
		text_color     = mul(colors.heading, 2.5),
		text_shadow    = { 0, 2 },
		text_shadow_color = mul(colors.heading, 0.75),
		font_path      = fonts.bold,
		border         = { 0, 0, 2, 0 },
		border_color   = mul(colors.heading, 0.65),
		-- ahahahahahaha oh wow
		-- fite me land0n
		margin         = { -10, -10, 2, -10 },
		padding        = { 15, 20, 8, 20 },
	}},

	{ ".window_frame_content", {
		height            = 350,
		font_path         = "inherit",
		font_size         = "inherit",
		line_height       = "inherit",
		text_align        = "inherit",
		text_shadow       = "inherit",
		text_color        = "inherit",
		text_shadow_color = "inherit",
		overflow          = "scroll",
	}},
}
