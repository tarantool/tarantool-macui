local json = require('json')
local digest = require('digest')

local spacename, origin, newobj = ...

local fixedorigin = {}
for key, val in pairs(origin) do
    if tonumber(key) ~= nil then
        fixedorigin[tonumber(key)] = val
    end
end

local fixednew = {}
for key, val in pairs(newobj) do
    if tonumber(key) ~= nil then
        fixednew[tonumber(key)] = val
    end
end

-- parse values from string
for index, origval in pairs(fixedorigin) do
    local newval = fixednew[index]
    if newval ~= origval then
        if type(newval) == 'string' then
            fixednew[index] = dostring('return ' .. newval)
        end
    end
end

local space = box.space[spacename]
if space == nil then
    return nil, 'No space with name '..spacename
end

local format = space:format()

if format == nil then
    format = {}
    for k, index in pairs(space.index) do
        if type(k) == 'number' then
            for _, part in ipairs(index.parts) do
                format[part.fieldno] = {}
                format[part.fieldno].name = tostring(part.fieldno)
                format[part.fieldno].type = part.type
            end
        end
    end
end

for index, part in pairs(format) do
    if part.type == "*" or part.type == "any" then
        
    elseif part.type == 'scalar' then
        if type(fixednew[index]) == 'table' then
            return nil, "Field " .. part.name .. " type mismatch expected " .. part.type
            .. " got " .. type(fixednew[index])
        end
    elseif type(fixednew[index]) ~= part.type then
        return nil, "Field " .. part.name .. " type mismatch expected " .. part.type
        .. " got " .. type(fixednew[index])
    end
end


local pkey_changed = false
for _, part in ipairs(space.index[0].parts) do
    if fixedorigin[part.fieldno] ~= fixednew[part.fieldno] then
        pkey_changed = true
        break
    end
end

if pkey_changed then
    local newkey = {}
    local origkey = {}
    for _, part in ipairs(space.index[0].parts) do
        table.insert(origkey, fixedorigin[part.fieldno])
        table.insert(newkey, fixednew[part.fieldno])
    end
    
    if space:get(newkey) ~= nil then
        return nil, "Tuple with new primary key already exists"
    end
    
    space:delete(origkey)
end

fixednew = space:put(box.tuple.new(fixednew))

local row = fixednew:totable()
row['cursor'] = digest.base64_encode(json.encode(row),{nopad=true, nowrap=true,urlsafe=true})
setmetatable(row, {__serialize="mapping"})

return row
