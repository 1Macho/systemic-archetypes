include("rendering.jl")

mutable struct Lightray
    x::Float64
    y::Float64
    angle::Float64
end

mutable struct Tree
    x::Float64
    y::Float64
    growth::Float64
end

function drawlightray(r, lightray)
    drawsetcolor(r, 255, 255, 255)
    x2 = lightray.x + cos(lightray.angle) * 20
    y2 = lightray.y - sin(lightray.angle) * 20
    drawline(r, lightray.x, lightray.y, x2, y2)
end

function drawtree(r, x, y, size, depth, angle, setofrays)
    if (depth > 0)
        drawsetcolor(r, 255, 255, 0)
        angleinc = 0.6
        langle = angle + angleinc
        rangle = angle - angleinc
        eplx = x - cos(langle)*size
        eply = y - sin(langle)*size
        eprx = x - cos(rangle)*size
        epry = y - sin(rangle)*size
        drawline(r,x,y,eplx,eply)
        drawline(r,x,y,eprx,epry)
        accum = 0
        accum = accum + drawtree(r,eplx,eply,size/1.6,depth-1,langle,setofrays)
        accum = accum + drawtree(r,eprx,epry,size/1.6,depth-1,rangle,setofrays)
        return accum
    else
        drawsetcolor(r, 0, 255, 0)
        drawline(r,x-10,y-10,x+10,y-10)
        drawline(r,x-10,y+10,x+10,y+10)
        drawline(r,x-10,y-10,x-10,y+10)
        drawline(r,x+10,y-10,x+10,y+10)
        accum = 0
        todelete = Set()
        for ray in setofrays
            if (ray.x > x-10 && ray.x < x + 10 && ray.y > y-10 && ray.y < y+10)
                accum = accum + 1
                push!(todelete,ray)
            end
        end
        for ray in todelete
            delete!(setofrays,ray)
        end
        return accum
    end
end

function lerp(a,b,progress)
    initialresult = (b-a)*progress
    return a+initialresult
end

function createrays!(ox,oy,set,angle,size)
    for i in 1:2
        epointx = ox + cos(angle) * size
        epointy = oy - sin(angle) * size
        lpointx = epointx + cos(angle+pi/2) * size
        lpointy = epointy - sin(angle+pi/2) * size
        rpointx = epointx + cos(angle-pi/2) * size
        rpointy = epointy - sin(angle-pi/2) * size
        progress = rand(Float32)
        xfinal = lerp(lpointx, rpointx, progress)
        yfinal = lerp(lpointy, rpointy, progress)
        rayangle = angle + pi
        push!(set,Lightray(xfinal,yfinal,rayangle))
    end
end

function updaterays!(setofrays,treebaseline,lox,loy,lsize,progress,r)
    createrays!(400,400,setofrays,progress,600)
    for thisray in setofrays
        drawlightray(r,thisray)
        thisray.x = thisray.x + cos(thisray.angle) * 5
        thisray.y = thisray.y - sin(thisray.angle) * 5
        if thisray.y > treebaseline
            delete!(setofrays,thisray)
        end
        if thisray.x > lox + lsize + 100
            delete!(setofrays,thisray)
        end
        if thisray.x < lox - lsize - 100
            delete!(setofrays,thisray)
        end
        if thisray.y < loy - lsize - 100
            delete!(setofrays,thisray)
        end
    end
end

function updatetree!(tree,r,setofrays)
    size = lerp(40,80,tree.growth)
    depth = trunc(Int,lerp(2,5,tree.growth))
    if depth > 6
        depth = 6
    end
    tree.growth = tree.growth + drawtree(r,tree.x,tree.y,size,depth,pi/2,setofrays)/(100*(tree.growth+0.1))
    tree.growth = tree.growth - 0.0005 * tree.growth
    if tree.growth < 0
        tree.growth = 0
    end
end

function treelightsim()
    r = drawinit()
    progress = 0
    setofrays = Set()
    treebaseline = 700
    tree1 = Tree(300, treebaseline, 0)
    tree2 = Tree(400, treebaseline, 0)
    lox = 400
    loy = 400
    lsize = 600
    function todraw()
        for i in 1:4
            progress += 0.001
            drawsetcolor(r, 0, 0, 0)
            drawclear(r)
            drawsetcolor(r, 255, 255, 255)
            updatetree!(tree1,r,setofrays)
            updatetree!(tree2,r,setofrays)
            updaterays!(setofrays,treebaseline,lox,loy,lsize,progress,r)
        end
    end
    drawloop(r, todraw)
end
