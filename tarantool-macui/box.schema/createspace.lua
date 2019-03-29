local args = ...

local log = require('log')
log.info(args)
log.info('alter')

local opts = {}
if args['engine'] ~= nil then
    opts['engine'] = args['engine']
end
if args['field_count'] ~= nil then
    opts['field_count'] = args['field_count']
end
if args['format'] ~= nil then
    opts['format'] = args['format']
    for _, part in ipairs(opts['format']) do
        if part.is_nullable == 0 then
            part.is_nullable = false
            else
            part.is_nullable = true
        end
    end
end
if args['id'] ~= nil then
    opts['id'] = args['id']
end
if args['is_local'] ~= nil then
    opts['is_local'] = args['is_local'] ~= 0
end
if args['temporary'] ~= nil then
    opts['temporary'] = args['temporary'] ~= 0
end
if args['user'] ~= nil then
    opts['user'] = args['user']
end

local space = box.schema.space.create(args.name, opts)

if args['index'] ~= nil then
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
            if tonumber(part.name) ~= nil then
                part[1] = tonumber(part.name)
            end
            part.name = nil
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
        local rc, res = pcall(space.create_index, space,
                              index['name'],
                              {
                                ['type'] = index['type'],
                                id = index['id'],
                                unique = index['unique'],
                                parts = index['parts'],
        })
        if not rc then
            space:drop()
            return nil, res
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
