local red = { 255, 0, 0, 255 }

return {
    { "inline", {
        width  = 50,
        height = 50,
    }},

    { "inline#four.red", {
        width  = 400,
        height = 200,
    }},

    { "inline.root", {
        display = "block",
        width   = 300,
        height  = 200,
    }},

    { ".root", ".other", {
        { ".red", {
            { ".third", {
                beep = "boop",
            }},

            display = "inline",
        }},

        width  = 400,
        height = 200,
    }},

    { ".root.red", {
        width  = 200,
        height = 200,
    }},

    { ".red", {
        text_color = red,
    }},

    { "inline#four", {
        display = "inline",
        width   = 600,
        height  = 600,
    }},

    { ".red:last_child", {
        width  = 10,
        height = 10,
    }},

    { ".red:last_child", {
        height = 20,
        kek = "top",
    }},
}
