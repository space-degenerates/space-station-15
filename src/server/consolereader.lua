local channel = love.thread.getChannel("console")

while true do
    local line = io.read("*l")
    if not line then break end
    channel:push(line)
end
