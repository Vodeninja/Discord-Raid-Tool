local handle = io.popen(string.format("cd %s && lit ls", os.getenv("USERPROFILE")))
local output = handle:read("*a")
handle:close()
local discordiaInstalled = output:match("SinisterRectus/discordia")

if not discordiaInstalled then
    local installHandle = io.popen(string.format("cd %s && lit install SinisterRectus/discordia", os.getenv("USERPROFILE")))
    print("installing discordia packages")
    installHandle:close()
end

local discordia = require("discordia")
local https = require('https')
local fs = require('fs')
local tokens = {}

local function strExplode(separator, str, withpattern)
    if separator == "" then return totable(str) end

    if withpattern == nil then
        withpattern = false
    end

    local ret = {}
    local current_pos = 1

    for i = 1, string.len(str) do
        local start_pos, end_pos = string.find(str, separator, current_pos, not withpattern)
        if not start_pos then break end
        ret[i] = string.sub(str, current_pos, start_pos - 1)
        current_pos = end_pos + 1
    end

    ret[#ret + 1] = string.sub(str, current_pos)

    return ret
end

local function sendTextToChannels(clients, channel_id, text, guild_id)
    for _, client in pairs(clients) do
        client:getGuild(guild_id):getChannel(channel_id):send(text)
    end
end

local function joinVoiceChannels(clients, guild_id, channel_id)
    for _, client in pairs(clients) do
        coroutine.wrap(function()
            local guild = client:getGuild(guild_id)

            if guild then
                local channel = guild:getChannel(channel_id)

                if channel then
                    local connection = channel:join()
                    print(i)
                end
            end
        end)()
    end
end

local function playMusicInChannels(clients, guild_id, channel_id, sounds)
    for _, client in pairs(clients) do
        coroutine.wrap(function()
            local guild = client:getGuild(guild_id)

            if guild then
                local channel = guild:getChannel(channel_id)

                if channel then
                    local connection = channel:join()
                    connection:playFFmpeg(sounds)
                end
            end
        end)()
    end
end

local function jumpVoiceChannels(clients, channel_id1, channel_id2, guild_id)
    for _, client in pairs(clients) do
        coroutine.wrap(function()
            local connections1 = client:getGuild(guild_id):getChannel(channel_id1)
            local connections2 = client:getGuild(guild_id):getChannel(channel_id2)

            while timers < 1 do
                local connection = connections1:join()
                local connection2 = connections2:join()
            end
        end)()
    end
end

local function start(clients)
    client_ct = 0
    for k, v in pairs(clients) do
        if k then
            client_ct = client_ct + 1
        end
    end
    print([[
    
    █░█ █▀▄ █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀
    ▀▄▀ █▄▀ █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░
]])
    print("              You have " .. client_ct .. " bots")
    print([[
    1. Text (all tokens)
    2. Join voice (all tokens)
    3. Disco (music all tokens) 
    4. Voice jumper (all tokens)]])
    local func = io.read()

    if func == "1" then
        print("Channel:")
        local channel_id = io.read()
        print("Text:")
        local text = io.read()
        print("Guild ID:")
        local guild_id = io.read()
        sendTextToChannels(clients, channel_id, text, guild_id)
    elseif func == "2" then
        print("Guild ID:")
        local guild_id = io.read()
        print("Channel ID:")
        local channel_id = io.read()
        joinVoiceChannels(clients, guild_id, channel_id)
    elseif func == "3" then
        print("Guild ID:")
        local guild_id = io.read()
        print("Channel ID:")
        local channel_id = io.read()
        print("Music:")
        local sounds = io.read()
        playMusicInChannels(clients, guild_id, channel_id, sounds)
    elseif func == "4" then
        print("First channel ID:")
        local channel_id1 = io.read()
        print("Second channel ID:")
        local channel_id2 = io.read()
        print("Guild ID:")
        local guild_id = io.read()
        jumpVoiceChannels(clients, channel_id1, channel_id2, guild_id)
    end
end

local function runClients()
    local clients = {}

    for _, token in pairs(tokens) do
        local client = discordia.Client()
        client:run(token)
        clients[token] = client
    end

    return clients
end

local function main()
    local data = fs.readFileSync('tokens.txt')
    tokens = strExplode("\n", data)
    local clients = runClients()
    os.execute("cls")
    start(clients)
    discordia.waitFor("ready")
end

main()