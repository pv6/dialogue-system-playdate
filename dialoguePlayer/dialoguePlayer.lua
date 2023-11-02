import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/logic/dialogueNodeLogic"
import "DialogueSystem/dialogue/implementedNodes/hearDialogueNode"
import "DialogueSystem/dialogue/implementedNodes/sayDialogueNode"
import "DialogueSystem/dialogue/implementedNodes/referenceDialogueNode"
import "DialogueSystem/support/myTable"


local ds<const> = dialogueSystem
local table<const> = table
local string<const> = string


class("DialoguePlayer", {}, ds).extends()


function ds.DialoguePlayer:init()
    self._actors = nil
    self._blackboards = nil
    self._dialogue = nil
    self._curNode = nil
    self._logicInput = ds.DialogueNodeLogicInput()
end


function ds.DialoguePlayer:play(dialogue, actors, blackboards)
    assert(dialogue)

    self._dialogue = dialogue
    self._actors = actors
    self._blackboards = blackboards

    assert(self:_isActorsValid())
    assert(self:_isBlackboardsValid())

    self._logicInput.actors = self._actors
    self._logicInput.blackboards = self._blackboards

    self:_setCurNode(dialogue.rootNode)

    -- TODO: emit 'playbackStarted' signal
end


function ds.DialoguePlayer:stop()
    -- TODO: emit 'playbackEnded' signal
end


function ds.DialoguePlayer:hear()
    if not self._curNode then
        return nil
    end

    -- find first valid child node
    for i, nextNode in ipairs(self:_getValidChildren(self._curNode.children)) do
        if nextNode:isa(ds.HearDialogueNode) then
            -- first valid node is hear node
            self:_setCurNode(nextNode)
            return self:_translateTextNode(nextNode)
        else
            -- first valid node is not hear node
            return nil
        end
    end

    -- no valid child nodes, dialogue is over
    self:_setCurNode(nil)
    return nil
end


function ds.DialoguePlayer:getSayOptions()
    if not self._curNode then
        return {}
    end

    local isContinuous = false
    local output = {}
    for i, nextNode in ipairs(self:_getValidChildren(self._curNode.children)) do
        -- find continuous valid say child nodes
        -- (non-valid say nodes don't break continuation)
        if nextNode:isa(ds.SayDialogueNode) then
            table.insert(output, self:_translateTextNode(nextNode))
            isContinuous = true
        -- only stop gathering say nodes, if encountered a valid non-say node
        elseif isContinuous then
            break
        end
    end

    return output
end


function ds.DialoguePlayer:canContinue()
    return self._curNode and #self:_getValidChildren(self._curNode.children) ~= 0
end


function ds.DialoguePlayer:say(sayOption)
    assert(self:_isSayOptionValid(sayOption))
    self._curNode = self._dialogue.nodes[sayOption.id]
end


function ds.DialoguePlayer:isOver()
    return not self._curNode
end


function ds.DialoguePlayer:getActorImplementation(actor)
    return self:_getActorImplementation(actor)
end


function ds.DialoguePlayer:getActorImplementationByName(actorName)
    return self:_getActorImplementation(actorName)
end


function ds.DialoguePlayer:_getActorImplementation(actor)
    if not actor or not self._actors:has(actor) then
        return nil
    end
    return self._actors:get(actor)
end


function ds.DialoguePlayer:_getValidChildren(children)
    local output = {}
    for i, nextNode in ipairs(children) do
        if self:_isNodeValid(nextNode) then
            if nextNode:isa(ds.ReferenceDialogueNode) then
                local referencedNode = self._dialogue.nodes[nextNode.referenced_node_id]
                if nextNode.jumpTo == ds.ReferenceDialogueNode.jumpToTypes.startOfNode and not referencedNode:isa(ds.RootDialogueNode) then
                    table.insert(output, referencedNode)
                else
                    local referencedChildren = table.shallowcopy(referencedNode.children)

                    -- avoid infinite loop
                    local index = table.indexOfElement(referencedChildren, nextNode)
                    if index then
                        table.remove(referencedChildren, nextNode)
                    end

                    table.append(output, self:_getValidChildren(referencedChildren))
                end
            else
                table.insert(output, nextNode)
            end
        end
    end

    return output
end


function ds.DialoguePlayer:_isSayOptionValid(sayNode)
    for i, option in ipairs(self:getSayOptions()) do
        if sayNode.id == option.id and self:_isNodeValid(sayNode) then
            return true
        end
    end
    return false
end


function ds.DialoguePlayer._multisplit(inputString, delimiters)
    local tokens = {inputString}

    for i, delimiter in ipairs(delimiters) do
        local newTokens = {}
        for i, token in ipairs(tokens) do
            local addedTokens = {}
            if delimiter == nil then
                delimiter = "%s"
            end
            for str in string.gmatch(token, "([^" .. delimiter .. "]+)") do
                table.insert(addedTokens, str)
            end

            table.append(newTokens, addedTokens)
        end
        tokens = newTokens
    end

    return tokens
end


function ds.DialoguePlayer:_translateTextNode(node)
    local output = table.shallowcopy(node)
    -- TODO: translate text
    local translatedText = output.text

    -- find bracketed code snippets
    local compiledText = ""
    local tokens = self._multisplit(translatedText, {"{", "}"})
    local codeIndex = string.sub(translatedText, 1, 1) == "{" and 1 or 0
    for i = 1, #tokens do
        if i % 2 ~= codeIndex then  -- regular text
            compiledText = compiledText .. tokens[i]
        else  -- code snippet
            -- TODO: run script
            --compiledText += tr(str(self._logicInput.execute_script(tokens[i])))
        end
    end

    output.text = compiledText
    return output
end


function ds.DialoguePlayer:_setCurNode(newCurNode)
    self._curNode = newCurNode
    if self._curNode then
        self._curNode.actionLogic:doAction(self._logicInput)
    end
end


function ds.DialoguePlayer:_isNodeValid(node)
    -- for reference nodes, check referenced node validity
    --if node:isa(ds.ReferenceDialogueNode) then
    if Object.isa(node, ds.ReferenceDialogueNode) then
        return self:_isNodeValid(_dialogue.nodes[node.referenced_node_id])
    end
    return node.conditionLogic:check(self._logicInput)
end


function ds.DialoguePlayer:_isActorsValid()
    for i, actorItem in ipairs(self._dialogue.actors:items()) do
        if not self._actors:has(actorItem) then
            return false
        end
    end
    return true
end


function ds.DialoguePlayer:_isBlackboardsValid()
    for i, template in ipairs(self._dialogue.blackboards:items()) do
        if not self._blackboards:has(template) or not self._blackboards:get(template):isValid(template) then
            return false
        end
    end
    return true
end
