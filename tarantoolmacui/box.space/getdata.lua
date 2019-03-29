local json = require('json')
local digest = require('digest')

local spacename, first, cursor, search = ...

local space = box.space[spacename]
if space == nil then
    return nil, 'No space with name '..spacename
end

if cursor ~= nil then
    cursor = json.decode(digest.base64_decode(cursor))
end

local function get_index_values(tuple, index)
    local values = {}
    for _, part in ipairs(index.parts) do
        table.insert(values, tuple[part.fieldno])
    end
    return values
end

local cursorkey = nil
if cursor ~= nil then
    cursorkey = get_index_values(cursor, space.index[0])
end

local iter = 'GT'

if first < 0 then
    first = math.abs(first)
    iter = 'LT'
end

local counter = 0
local result = {}

local backward = false
if iter == 'LT' or iter == 'LE' or iter == 'REQ' then
    backward = true
end
for _, tuple in space:pairs(cursorkey, iter) do
    local match = false
    if search ~= nil and search ~= '' then
        for _, val in ipairs(tuple) do
            if type(val) == 'number' then
                if val == tonumber(search) then
                    match = true
                    break
                end
            elseif type(val) == 'string' then
                if val.find(search) ~= nil then
                    match = true
                    break
                end
            end
        end
    else
        match = true
    end
    
    if match == true then
        if counter >= first then
            break
        end
        counter = counter + 1

        local row = tuple:totable()
        row['cursor'] = digest.base64_encode(json.encode(row),{nopad=true, nowrap=true,urlsafe=true})
        
        if backward then
            table.insert(result, 1,
                         setmetatable(row,
                                      {__serialize="mapping"}))
        else
            table.insert(result,
                         setmetatable(row,
                                     {__serialize="mapping"}))
        end
    end
end
return result
