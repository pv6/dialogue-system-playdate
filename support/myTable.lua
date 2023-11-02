function table.append(tableA, tableB)
    if not tableA or not tableB then
        return
    end

    for i, item in ipairs(tableB) do
        table.insert(tableA, item)
    end
end
