using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer


function pollEvent!()
    #SDL2.Event() = [SDL2.Event(NTuple{56, Uint8}(zeros(56,1)))]
    SDL_Event() = Array{UInt8}(zeros(56))
    e = SDL_Event()
    success = (SDL2.PollEvent(e) != 0)
    return e,success
end

function getEventType(e::Array{UInt8})
    # HAHA This is still pretty janky, but I guess that's all you can do w/ unions.
    bitcat(UInt32, e[4:-1:1])
end

function getEventType(e::SDL2.Event)
    e._Event[1]
end

function bitcat(outType::Type{T}, arr)::T where T<:Number
    out = zero(outType)
    for x in arr
        out = out << (sizeof(x)*8)
        out |= convert(T, x)  # the `convert` prevents signed T from promoting to Int64.
    end
    out
end

function drawinit()
    SDL2.init()

    win = SDL2.CreateWindow("Hello World!", Int32(100), Int32(100), Int32(800), Int32(600),
        UInt32(SDL2.WINDOW_SHOWN))
    SDL2.SetWindowResizable(win,true)

    renderer = SDL2.CreateRenderer(win, Int32(-1),
        UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))

    return renderer
end

function drawsetcolor(renderer,r,g,b,a=255)
    SDL2.SetRenderDrawColor(renderer,r,g,b,a)
end

function drawclear(renderer)
    SDL2.RenderClear(renderer)
end

function drawline(renderer,x1,y1,x2,y2)
    SDL2.RenderDrawLine(renderer,trunc(Int,x1),trunc(Int,y1),trunc(Int,x2),trunc(Int,y2))
end

function drawloop(renderer, updatefunction)
    running = true

    while running
        SDL2.PumpEvents()

        updatefunction()

        SDL2.RenderPresent(renderer)

        e,_ = pollEvent!()
        t = getEventType(e)
        if t == SDL2.QUIT
            running = false
        end
    end

    SDL2.Quit()

end
