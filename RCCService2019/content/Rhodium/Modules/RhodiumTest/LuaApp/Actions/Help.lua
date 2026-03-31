local function getAllActions(instance, result, path, visited)
	visited = visited or {}
	path = path or {}
	if visited[instance] then
		return
	end
	visited[instance] = true
	if type(instance) == "userdata" then
		if instance.ClassName == "Folder" then
			for i, child in ipairs(instance:GetChildren()) do
				table.insert(path, instance.Name)
				getAllActions(child, result, path, visited)
				table.remove(path)
			end
		elseif instance.ClassName == "ModuleScript" then
			table.insert(path, instance.Name)
			instance = require(instance)
			getAllActions(instance, result, path, visited)
			table.remove(path)
		end
	elseif type(instance) == "table" then
		for key, value in pairs(instance) do
			table.insert(path, key)
			getAllActions(value, result, path, visited)
			table.remove(path)
		end
	elseif type(instance) == "function" then
		local line = table.concat(path, ".", 2)
		table.insert(result, line)
	end
end

return function()
	print("All Actions:")
	local result = {}
	getAllActions(script.Parent, result)
	table.sort(result)
	print(table.concat(result, "\n"))
end