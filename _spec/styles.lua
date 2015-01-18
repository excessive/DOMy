-- Unlike CSS, this will not have conditional formatting. It's a pain in the ass.
return {
	object = {
		text = {
			color = { 255, 255, 255, 255 },
		},
		button = {
			on_hover = {
				background_color = { 255, 0, 0, 255 },
			},
		},
		image = {
			width = 300,
			height = 200,
		},
	},
	id = {
		debug = {
			visible = false,
		},
		intro = {
			font_face = "assets/fonts/OpenSans.ttf",
			font_size = 18,
		},
	},
	class = {
		block = {
			display = "block",
		},
		link = {
			color = { 123, 123, 123, 255 },
			text_decoration = "underline",
		},
		nav = {
			list_style_flow = "horizontal"
		},
	},
}
