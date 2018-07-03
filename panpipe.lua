local lfs = require "lfs"

-- Create working dir
local path = "tmp" .. os.date("%y%m%d_%H%M")

local startDir = lfs.currentdir()

lfs.mkdir(path)
lfs.chdir(path)
lfs.link(startDir, "root", true)

--- Pipe the content of the inline code and code block through a shell.
-- The output of the original content becomes the new content.
-- @param elem A pandoc element to parse.
function pipeContent(elem)
    local content = elem.text
    local pipeCmd = nil

    for i, v in ipairs(elem.attributes) do
        if v[1] == "pipe" then
            pipeCmd = v[2]
            break
        end
    end
    if pipeCmd then
        elem.text = pandoc.pipe("sh", {"-c", pipeCmd}, content)
    end
    return elem
end

--- Unwrap the content and parse it as pandoc markdown.
-- @param elem A pandoc element to parse.
function unwrapContent(elem)
    for i, v in pairs(elem.classes) do
        if v == "unwrap" then
            return pandoc.read(elem.text).blocks                      
        end
    end
end

--- Hide the output of inline code and code block marked as hidden.
-- @param elem A pandoc element to parse.
function hideContent(elem)
    for i, v in pairs(elem.classes) do
        if v == "hidden" then
            return {}                      
        end
    end
end

return {
    -- Pipe content
    {
        CodeBlock = pipeContent,
        Code = pipeContent
    },
    -- Unwrap code
    {
        CodeBlock = unwrapContent,
        Code = unwrapContent
    },
    -- Hide output
    {
        CodeBlock = hideContent,
        Code = hideContent
    },
    -- Return to working dir
    {
        Pandoc = function (elem)
                lfs.chdir(startDir)
                os.execute('rm -rd "' .. path .. '"')
            end
    }
}

