function table.append(tableA, tableB)
    for i, item in ipairs(tableB) do
        table.insert(tableA, item)
    end
end
