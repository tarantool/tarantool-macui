local name = ...
local result = {}

local function index(space)
    local list = {}
    for name, info in pairs(space.index) do
        if type(name) == 'string' then
            table.insert(list, info);
        end
    end
    table.sort(list, function(l, r) return l.id < r.id end)
    return list
end

local space = box.space[name]

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


box.space[name]:drop()

return result
