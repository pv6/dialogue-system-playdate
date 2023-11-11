import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/dialogueNode"
import "DialogueSystem/dialogue/implementedNodes/rootDialogueNode"
import "DialogueSystem/storage/storage"


local ds<const> = dialogueSystem
local table<const> = table


class("Dialogue", {localBlackboardId = "-2"}, ds).extends()


function ds.Dialogue:init()
    self.actors = ds.Storage()
    self.blackboards = ds.Storage()
    self.maxId = 0
    self.editorVersion = "0.0.0"
    self.nodes = {}

    self.rootNode = ds.RootDialogueNode()
    self.rootNode.id = self:getNewMaxId()
    self:setRootNode(self.rootNode)
end


function ds.Dialogue:setRootNode(rootNode)
    self.rootNode = rootNode
    self:updateNodes()
end


function ds.Dialogue:getNode(id)
    return self.nodes[id]
end


function ds.Dialogue:getNodes(ids)
    local output = {}
    for i, id in ipairs(ids) do
        if self.nodes[id] then
            table.insert(output, self.nodes[id])
        end
    end
    return output
end


function ds.Dialogue:getNewMaxId()
    self.maxId += 1
    return self.maxId - 1
end


function ds.Dialogue:updateNodes()
    self.nodes = {}
    if self.rootNode then
        local nodeStack = {self.rootNode}
        while #nodeStack > 0 do
            local curNode = table.remove(nodeStack)

            self.nodes[curNode.id] = curNode

            for i, childNode in ipairs(curNode.children) do
                assert(childNode:isa(ds.DialogueNode))
                assert(not self.nodes[childNode.id])
                table.insert(nodeStack, childNode)
            end
        end
    end
end


function ds.Dialogue:getLocalBlackboard()
    return self.blackboards:getItem(ds.Dialogue.localBlackboardId)
end
