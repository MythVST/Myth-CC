running = true
pos = {}
pos.i = 1
map = fs.open("map.jsList","w+")
term.clear()
term.setCursorPos(1,1)
print("Press SPACE to mark location. press TAB to quit")
while running do
    event, key = os.pullEvent("key")
    if key == keys.space then
        --mark
        pos.x,pos.y,pos.z = gps.locate()
        map.writeLine(textutils.serialiseJSON(pos))
        print("Marked position x:"..pos.x.." y:"..pos.y.." in map at index "..pos.i)
        pos.i = pos.i+1
        print("To end mapping and save to file, press TAB")
    elseif key == keys.tab then
        running = false
    end
end
map.close()
