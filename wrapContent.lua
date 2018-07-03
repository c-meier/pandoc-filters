-- Recuperate the wrappings specification from the wrappings.lua file in the
-- current folder.
local wrappings = require "wrappings"

--- Wrap the wrapping arround the wanted element.
-- @param elem A pandoc element to parse.
function wrapBlockContent(elem)
for i, v in pairs(elem.classes) do
    if wrappings[v] then
        return {
            pandoc.RawBlock(FORMAT, wrappings[v][FORMAT][1]),
            elem,
            pandoc.RawBlock(FORMAT, wrappings[v][FORMAT][2])
        }                      
    end
end
return {elem}
end

--- Wrap the wrapping arround the wanted element.
-- @param elem A pandoc element to parse.
function wrapInlineContent(elem)
for i, v in pairs(elem.classes) do
    if wrappings[v] then
        return {
            pandoc.RawInline(FORMAT, wrappings[v][FORMAT][1]),
            elem,
            pandoc.RawInline(FORMAT, wrappings[v][FORMAT][2])
        }                      
    end
end
return {elem}
end

return {
    -- Wrap element
    {
        Div = wrapBlockContent,
        Span = wrapInlineContent,
    },
}

