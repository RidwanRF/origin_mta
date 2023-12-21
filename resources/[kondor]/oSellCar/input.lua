local inputs = {
    ['playerAdd'] = {
        maxLength = 50,
        placeholder = 'Névrészlet / ID'
    },
    ['bank'] = {
        maxLength = 10,
        placeholder = 'Összeg',
        number = true,
    },
    ['addVehicle'] = {
        maxLength = 10,
        placeholder = 'Vételár',
        number = true,
    }
}
local cursor = ''
Timer(function()
    cursor = cursor == '|' and '' or '|'
end, 500, 0)

for name, value in pairs(inputs) do 
    local gui = GuiEdit(-1000, -1000, 100, 20, '', false)
    if value.maxLength then 
        gui.maxLength = value.maxLength
    end

    addEventHandler('onClientGUIChanged', gui, function()
        local text = source.text
        
        if value.number then 
            if not tonumber(text) then 
                source.text = ''
            end
        end
    end)

    value.gui = gui
end

function getInputValue(editName)
    return (inputs[editName] and inputs[editName].gui) and inputs[editName].gui.text or ''
end

function getInputText(editName)
    if inputs[editName] then 
        local value = getInputValue(editName)
        if inputs[editName].active then 
            return value .. cursor
        else 
            return value:len() <= 0 and (inputs[editName].placeholder or '') or value
        end
    end
    return ''
end

function setInputActive(editName)
    if inputs[editName] and inputs[editName].gui then 
        guiSetInputMode("no_binds_when_editing")
        inputs[editName].gui:bringToFront()
        inputs[editName].active = true
    end
end

function clearInputs()
    for _, input in pairs(inputs) do 
        input.active = false
    end
end

addEventHandler('onClientClick', root, function(button, state)
    if button == 'left' and state == 'down' then 
        clearInputs()
    end
end, false, 'high')