import "CoreLibs/object"


local namespace<const> = {}

class("Signal").extends()

class("Listener", {}, namespace).extends()


function namespace.Listener:init(instance)
    self.instance = instance
    self.methodList = {}
end


function namespace.Listener:getMethodIndex(method)
    return table.indexOfElement(self.methodList, method)
end


function namespace.Listener:addMethod(method)
    table.insert(self.methodList, method)
end


function namespace.Listener:removeMethod(method)
    local methodIndex<const> = self:getMethodIndex(method)
    if methodIndex ~= nil then
        table.remove(self.methodList, methodIndex)
    end
end


function Signal:init()
    self._listenerList = {}
    self._instanceToIndex = {}
end


function Signal:isConnected(instance, method)
    local listener<const> = self:_getListener(instance)
    return listener ~= nil and listener:getMethodIndex(method) ~= nil
end


function Signal:connect(instance, method)
    local listener = self:_getListener(instance)
    if listener == nil then
        listener = self:_addListener(instance)
    end

    local methodIndex<const> = listener:getMethodIndex(method)
    if methodIndex == nil then
        listener.addMethod(method)
    end
end


function Signal:disconnect(instance, method)
    local listener<const> = self:_getListener(instance)
    if listener == nil then
        return
    end

    listener:removeMethod(method)

    if #listener.methods == 0 then
        self:_removeListener(listener)
    end
end


function Signal:emit(...)
    for i, listener in ipairs(self._listenerList) do
        for j, method in ipairs(listener.methodList) do
            method(listener.instance, table.unpack(arg))
        end
    end
end


function Signal:_addListener(instance)
    local listener<const> = namespace.Listener(instance)

    table.insert(self._listenerList, listener)

    self._instanceToIndex[instance] = #self._listenerList

    return listener
end


function Signal:_removeListener(listener)
    local listenerIndex<const> = self._instanceToIndex[listener.instance]

    self._instanceToIndex[listenerIndex] = nil
    table.remove(self._listenerList, listenerIndex)

    -- update indices
    for i, listener in ipairs(self._listenerList) do
        self._instanceToIndex[listener.instance] = i
    end
end


function Signal:_getListener(instance)
    local listenerIndex = self._instanceToIndex[instance]
    if listenerIndex == nil then
        return nil
    end
    return self._listenerList[listenerIndex]
end
