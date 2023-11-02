import "CoreLibs/object"

import "DialogueSystem/support/myTable"


local namespace<const> = {}
local table<const> = table


class("Signal").extends()

class("Listener", {}, namespace).extends()


local weekTableMeta<const> = {__mode = "k"}


function namespace.Listener:init(instance)
    self.methods = {}
    self.numOfMethods = 0

    -- store methods as weak references
    setmetatable(self.methods, weekTableMeta)
end


function namespace.Listener:hasMethod(method)
    return self.methods[method] ~= nil
end


function namespace.Listener:addMethod(method, args)
    if self:hasMethod(method) then
        return
    end
    self.methods[method] = args or {}
    self.numOfMethods += 1
end


function namespace.Listener:removeMethod(method)
    if not self:hasMethod(method) then
        return
    end
    self.methods[method] = nil
    self.numOfMethods -= 1
end


function Signal:init()
    self._listeners = {}
    self._listenersCopy = {}

    -- store instances as weak references
    setmetatable(self._listeners, weekTableMeta)
    setmetatable(self._listenersCopy, weekTableMeta)
end


function Signal:isConnected(instance, method)
    local listener<const> = self:_getListener(instance)
    return listener ~= nil and listener:hasMethod(method)
end


function Signal:connect(instance, method, ...)
    local listener = self:_getListener(instance)
    if listener == nil then
        listener = self:_addListener(instance)
    end

    if not listener:hasMethod(method) then
        local arg<const> = table.pack(...)
        listener:addMethod(method, arg)
    end
end


function Signal:disconnect(instance, method)
    local listener<const> = self:_getListener(instance)
    if listener == nil then
        return
    end

    listener:removeMethod(method)

    if listener.numOfMethods == 0 then
        self:_removeListener(listener)
    end
end


function Signal:emit(...)
    local arg<const> = table.pack(...)

    -- use copy of listeners in case new listeners subscribe during callback
    table.shallowcopy(self._listeners, self._listenersCopy)
    for instance, listener in pairs(self._listenersCopy) do
        for method, args in pairs(listener.methods) do
            local argCopy<const> = arg and table.shallowcopy(arg) or {}
            table.append(argCopy, args)
            method(instance, table.unpack(argCopy))
        end
    end
end


function Signal:_addListener(instance)
    local listener<const> = namespace.Listener()
    self._listeners[instance] = listener

    return listener
end


function Signal:_removeListener(listener)
    self._listeners[instance] = nil
end


function Signal:_getListener(instance)
    return self._listeners[instance]
end
