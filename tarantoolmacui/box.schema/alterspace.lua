local name, args = ...

if args['format'] ~= nil then
    for _, part in ipairs(args['format']) do
        if part.is_nullable ~= nil then
            if part.is_nullable == 0 then
                part.is_nullable = false
            else
                part.is_nullable = true
            end
        else
            part.is_nullable = false
        end
    end
end

local space = box.space[name]

if (args.name ~= name) then
    space:rename(args.name)
end

if args['format'] ~= nil then
    space:format(args['format'])
end

local function create_index(space, index)
    local rc, res = pcall(space.create_index, space, index['name'], {
                          ['type'] = index['type'],
                          id = index['id'],
                          unique = index['unique'],
                          parts = index['parts'],
                          })
    if not rc then
      return nil, res
    end
    return true
end

local function alter_index(space, index)
    local origin = space.index[index.id]
    if origin.name ~= index.name then
        origin:rename(index.name)
    end
    local rc, res = pcall(origin.alter, origin, {
                          ['type'] = index['type'],
                          unique = index['unique'],
                          parts = index['parts'],
                          })
    if not rc then
        return nil, res
    end
    return true
end

if args['index'] ~= nil then
    local found = {}
    -- create or alter index
    for _, index in ipairs(args['index']) do
        if index.unique ~= nil then
            if index.unique == 0 then
                index.unique = false
                else
                index.unique = true
            end
        end
        for _, part in ipairs(index.parts or {}) do
            part[1] = part.name -- Convert input format
            part.name = nil
            part.fieldno = nil
            if part.is_nullable ~= nil then
                if part.is_nullable == 0 then
                    part.is_nullable = false
                else
                    part.is_nullable = true
                end
            else
                part.is_nullable = false
            end
        end
        
        local origin = space.index[index.id]
        if origin == nil then
            local rc, err = create_index(space, index)
            if rc == nil then
                return rc, err
            end
        else
            local rc, err = alter_index(space, index)
            if rc == nil then
                return rc, err
            end
        end
    
        found[index.name] = true
    end
    -- Remove index
    for name, index in pairs(space.index) do
        if type(name) == 'string' then
            if not found[name] then
                index:drop()
            end
        end
    end
end

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

local result = {
    name = space.name,
    id = space.id,
    field_count = space.field_count,
    format = space:format(),
    index = index(space),
    is_local = space.is_local,
    temporary = space.temporary,
    enabled = space.enabled,
    engine = space.engine,
}

return result
