local RAYLIB = require("src.modules.thirdparty.raylib")
local GAME   = require("src.modules.game")

function main()
    local screenWidth, screenHeight = rl.GetScreenWidth(), rl.GetScreenHeight()

    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
    rl.InitWindow(screenWidth, screenHeight, "test")
    rl.SetWindowState(rl.FLAG_WINDOW_RESIZABLE)
    rl.SetWindowTitle("Dream_Factory")
    --rl.ToggleFullscreen()
    
    local image = rl.LoadImage("src\\assets\\icon\\window_icon.png")
    if image then
        rl.SetWindowIcon(image)
        rl.UnloadImage(image)
    end

    rl.SetTargetFPS(60)

    local camera = RAYLIB.Camera3D()
    camera.position = RAYLIB.Vector3({ 10.0, 2.0, 10.0 });
    --camera.target = RAYLIB.Vector3({ 0.0, 0.0, 0.0 });
    camera.up = RAYLIB.Vector3({ 0.0, 1.0, 0.0 });
    camera.fovy = 90.0;
    camera.projection = 0; --RAYLIB.CAMERA_PERSPECTIVE trust

    local game = GAME.init_game(RAYLIB, camera)

    while not rl.WindowShouldClose() do
        local tbf = rl.GetFrameTime()

       GAME.update_game(game, tbf)
       GAME.render_game(game, tbf)
    end

    rl.CloseWindow()
end

main()