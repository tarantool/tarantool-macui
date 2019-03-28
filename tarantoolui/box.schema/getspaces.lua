local show_system = ...
local result = {}

local function index(space)
    local list = {}
    local format = space:format()
    for name, info in pairs(space.index) do
        if type(name) == 'string' then
            for _, part in ipairs(info.parts) do
                if format[part.fieldno] ~= nil then
                    part.name = format[part.fieldno].name
                    else
                    part.name = part.fieldno
                end
            end
            table.insert(list, info);
        end
    end
    table.sort(list, function(l, r) return l.id < r.id end)
    return list
end

for name, space in pairs(box.space) do
    local skip = false
    if show_system == 0 and space.id < 512 then
        skip = true
    end
    
    if type(name) == 'string' and not skip then
        table.insert(result, {
                     name = space.name,
                     id = space.id,
                     field_count = space.field_count,
                     format = space:format(),
                     index = index(space),
                     is_local = space.is_local,
                     temporary = space.temporary,
                     enabled = space.enabled,
                     engine = space.engine,
                     })
    end
end
table.sort(result, function(l, r) return l.id < r.id end)
return result
