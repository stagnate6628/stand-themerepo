util.require_no_lag("natives-1640181023")

while true do
    if menu.is_open() then

        local x, y, w, h = menu.get_main_view_position_and_size()

        -- Header
        directx.draw_rect(x, (y - (20 / 1080)), w, (20 / 1080), { r = 3/255, g = 30/255, b = 43/255, a = 167/255 })
        directx.draw_text(x + (w /2), (y - (8 / 1080)), "Kiddion's Modest Menu v0.9.3", ALIGN_CENTRE, 0.444, { r = 200/255, g = 200/255, b = 200/255, a = 172/255 }, false)
        
         -- Footer
        directx.draw_rect(x, y + h - (1 / 1080), w, (20 / 1080), { r = 3/255, g = 30/255, b = 43/255, a = 167/255 })
        directx.draw_text(x + (w /2), y + h + (12 / 1080), menu.get_active_list_cursor_text(), ALIGN_CENTRE, 0.444, { r = 200/255, g = 200/255, b = 200/255, a = 172/255 }, false)
    end
    util.yield()
end

util.keep_running()
