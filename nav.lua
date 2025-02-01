--init
if not fs.find("diffdrive.lua")[1] then
shell.run("wget https://raw.githubusercontent.com/MythVST/Myth-CC/refs/heads/main/diffdrive.lua diffdrive.lua")
end

Left = peripheral.wrap("left")
Right = peripheral.wrap("right")
require("diffdrive")


--Step 1:
--create a table with sets of coordinates
list = fs.open("disk/map.jsList","r")
line = true
local coords = {}
while line do
line = list.readLine()
print(line)
if line then lInit = textutils.unserializeJSON(line) end
table.insert(coords,{lInit.x,lInit.z})
end
--set up a function to convert current position and target position into a vector

function vectorize(posX,posY,tarX,tarY)

    deltaX = tarX - posX
    deltaY = tarY - posY

    angle = math.deg(math.atan2(deltaY,deltaX))
    magnitude = math.sqrt((deltaX^2)+(deltaY^2))

    return angle, magnitude, deltaX, deltaY
end

--set up a function to convert the vector into joystick data

function joystickinate(angle,magnitude)

    joyX = math.sin(math.rad(angle))*magnitude
    joyY = math.cos(math.rad(angle))*magnitude
    return joyX, joyY

end

--set up a loop to navigate to each position sequentially

function getYaw(rw,rx,ry,rz)

    local sinY = 2 * (rw * ry + rz * rx)
    local cosY = 1 - 2 * (ry * ry + rz * rz)
    radYaw = math.atan(sinY, cosY)
    degYaw = radYaw*-(180/math.pi)
    if degYaw <= -0 then
        degYaw = degYaw+360
    end
    return degYaw
end


for i=1, #coords do
    inrange = false
    while not inrange do --within a 10 block radius of the point
    sXYZ = ship.getWorldspacePosition()
    rot = ship.getQuaternion()
    sYaw = getYaw(rot.w,rot.x,rot.y,rot.z)
    tX,tZ = coords[i][1], coords[i][2]
    nAngle, nMag = vectorize(sXYZ.x,sXYZ.z,tX,tZ)
    dX, dY = joystickinate(sYaw-nAngle,math.min(nMag*4,100))
    lSpeed, rSpeed = differentialDrive(dX,dY,-100,100,-128,128)
    leftSpeed = ((lSpeed*-1) + Left.getTargetSpeed())/2
    rightSpeed = ((rSpeed*-1) + Right.getTargetSpeed())/2
    Left.setTargetSpeed(leftSpeed)
    Right.setTargetSpeed(rightSpeed)
    inrange = nMag < 3
    --code
    term.clear()
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.gray)
    term.clearLine()
    print(i)
    term.setBackgroundColor(colors.black)
    print("Distance: "..math.floor(nMag))
    print("Angle: "..nAngle)
    print(dX)
    print(dY)

    end
end
Left.setTargetSpeed(0)
Right.setTargetSpeed(0)

