function love.conf(t)
    if arg[1] == "--server" or arg[3] == "--server" then
        ---@diagnostic disable-next-line: assign-type-mismatch
        t.window = false
        t.modules.window = false
        t.modules.graphics = false
    else
        t.window.width = 1280
        t.window.height = 720
        t.window.resizable = true
    end
end
