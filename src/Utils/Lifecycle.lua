-- Small lifecycle/cleanup primitive shared by long-lived UI modules.
local Lifecycle = {}
Lifecycle.__index = Lifecycle

function Lifecycle.new()
    return setmetatable({_tasks = {}, _destroyed = false}, Lifecycle)
end

function Lifecycle:Add(taskValue)
    if self._destroyed then
        if typeof(taskValue) == "RBXScriptConnection" then taskValue:Disconnect()
        elseif typeof(taskValue) == "Instance" then taskValue:Destroy()
        elseif type(taskValue) == "function" then taskValue() end
        return taskValue
    end
    table.insert(self._tasks, taskValue)
    return taskValue
end

function Lifecycle:Connect(signal, callback)
    return self:Add(signal:Connect(callback))
end

function Lifecycle:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for index = #self._tasks, 1, -1 do
        local item = self._tasks[index]
        pcall(function()
            if typeof(item) == "RBXScriptConnection" then item:Disconnect()
            elseif typeof(item) == "Instance" then item:Destroy()
            elseif type(item) == "function" then item() end
        end)
        self._tasks[index] = nil
    end
end

return Lifecycle
