function map(v, in_min, in_max, out_min, out_max)
    if v < in_min then
        v = in_min
    end
    if v > in_max then
        v = in_max
    end
    return (v - in_min) * (out_max-out_min) / (in_max - in_min) + out_min
end


function differentialDrive(x,y,minJoystick,maxJoystick,minSpeed,maxSpeed)



 if x==0 and y==0 then
        return 0,0
    end

    z = math.sqrt((x^2)+(y^2))

    rad = math.acos(math.abs(x)/z)

    angle = math.deg(rad)

    tCoeff = -1 + (angle / 90) * 2
    turn = tCoeff * math.abs(math.abs(y) - math.abs(x))
    --	turn = round(turn * 100, 0) / 100 -- no idea what this line is for. let's see what happens if we ignore it
    turn = math.floor(turn/100)*100
    mov = math.max(math.abs(y),math.abs(x))

    if (x >=0 and y >=0) or (x < 0 and y < 0) then
        rawLeft = mov
        rawRight = turn
    else
        rawRight = mov
        rawLeft = turn
    end

    if y < 0 then
        rawLeft = rawLeft*-1
        rawRight = rawRight*-1
    end

    rightOut = map(rawRight, minJoystick, maxJoystick, minSpeed, maxSpeed)
    leftOut = map(rawLeft, minJoystick, maxJoystick, minSpeed, maxSpeed)

    return rightOut, leftOut
end
