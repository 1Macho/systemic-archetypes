include("rendering.jl")

function drawtree(r, x, y, size, depth, angle)
    if (depth > 0)
        drawsetcolor(r, 255, 255, 0)
        angleinc = 0.4
        langle = angle + angleinc
        rangle = angle - angleinc
        eplx = x - cos(langle)*size
        eply = y - sin(langle)*size
        eprx = x - cos(rangle)*size
        epry = y - sin(rangle)*size
        drawline(r,x,y,eplx,eply)
        drawline(r,x,y,eprx,epry)
        drawtree(r,eplx,eply,size/1.8,depth-1,langle)
        drawtree(r,eprx,epry,size/1.8,depth-1,rangle)
    else
        drawsetcolor(r, 0, 255, 0)
        drawline(r,x-10,y-10,x+10,y-10)
        drawline(r,x-10,y+10,x+10,y+10)
        drawline(r,x-10,y-10,x-10,y+10)
        drawline(r,x+10,y-10,x+10,y+10)
    end
end

function lerp(a,b,progress)
    initialresult = (b-a)*progress
    return a+initialresult
end

function treelightsim()
    r = drawinit()
    progress = 0
    function todraw()
        progress += 0.001
        drawsetcolor(r, 0, 0, 0)
        drawclear(r)
        drawsetcolor(r, 255, 255, 255)
        size = lerp(70,200,progress)
        depth = trunc(Int,lerp(2,5,progress))
        drawtree(r,300,600,size,depth,3.1416/2)
    end
    drawloop(r, todraw)
end
