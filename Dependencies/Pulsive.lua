menu.action(menu.my_root(), "Load Recommended Settings", {}, "If this is your first time using, you need to run this for the best experience.", function()
    for v in ("blur 0;borderwidth 4;borderrounded on;tabswidth 56;tabsposition top;tabsalignment centre;tabslefticon on;tabsname off;tabsrighticon off;menuwidth 392;primary 00000000;commandinfotextposition bottom;spacer 4"):gmatch("[^%;]+") do
        local n, a = v:match("(.+) (.+)")
        menu.trigger_command(menu.ref_by_command_name(n), a)
        -- util.toast(v)
        util.yield()
    end
    util.toast("Done! I recommend saving your state now (i.e \"savemain\" in the command box).")
end)
menu.action(menu.my_root(), "Load Recommended Font Settings", {}, "This is for use with the provided font file.", function()
    for v in ("bigtextscale 21;bigtextxoffset -3;bigtextyoffset 0;smalltextscale 16;smalltextxoffset -2;smalltextyoffset 2;addressbartextscale 16;addressbartextxoffset -2;addressbartextyoffset 2"):gmatch("[^%;]+") do
        local n, a = v:match("(.+) (.+)")
        menu.trigger_command(menu.ref_by_command_name(n), a)
        util.yield()
    end
    util.toast("Done! I recommend saving your state now (i.e \"savemain\" in the command box).")
end)
local clr = {r=1,g=0,b=1,a=1}
menu.rainbow(
menu.colour(menu.my_root(), "Primary Colour", {"primarycol"}, "", clr, true, function(val)
    clr = val
end)
)
local hx_fmt = "%02x%02x%02x%02x"
local spacer_ref = menu.ref_by_path("Stand>Settings>Appearance>Spacer Size", 24)
local scroll_ref = menu.ref_by_path("Stand>Settings>Appearance>Scrollbar>Width", 24)
local tab_tog_ref = menu.ref_by_path("Stand>Settings>Appearance>Tabs>Tabs", 24)
local tab_wid_ref = menu.ref_by_path("Stand>Settings>Appearance>Tabs>Width", 24)
local tab_pos_ref = menu.ref_by_path("Stand>Settings>Appearance>Tabs>Position", 24)
local addr_ref = menu.ref_by_path("Stand>Settings>Appearance>Address Bar>Address Bar", 24)
local addr_height_ref = menu.ref_by_path("Stand>Settings>Appearance>Address Bar>Height", 24)
local border_ref_hex = menu.ref_by_path("Stand>Settings>Appearance>Border>Colour", 24)
local bg_ref_hex = menu.ref_by_command_name("background", 24)
-- local bg_ref_r = menu.ref_by_path("Stand>Settings>Appearance>Colours>Background Colour>Red", 24)
-- local bg_ref_g = menu.ref_by_path("Stand>Settings>Appearance>Colours>Background Colour>Green", 24)
-- local bg_ref_b = menu.ref_by_path("Stand>Settings>Appearance>Colours>Background Colour>Blue", 24)
-- local bg_ref_a = menu.ref_by_path("Stand>Settings>Appearance>Colours>Background Colour>Opacity", 24)
local bg_clr = {r=0.1,g=0.1,b=0.1,a=1}
menu.rainbow(
menu.colour(menu.my_root(), "Background Colour", {"bgcol"}, "", bg_clr, false, function(val)
    bg_clr = val
end)
)
local pulsel = true
menu.toggle(menu.my_root(),"Reset Animation on Selection Change", {}, "", function(st) pulsel = st end, pulsel)
local animsp = 1
menu.slider(menu.my_root(),"Animation Speed", {"animationspeed"}, "", -2147483648, 2147483647, 100, 20, function(val) animsp = val/100 end)
local timer = os.clock()
local last_slot
util.create_tick_handler(function()
    local hx = hx_fmt:format(
    math.floor(bg_clr.r*255),
    math.floor(bg_clr.g*255),
    math.floor(bg_clr.b*255),
    math.floor(bg_clr.a*255))
    menu.trigger_command(bg_ref_hex, hx)
    menu.trigger_command(border_ref_hex, hx)
    if not menu.is_open() then
        return true
    end
    local sl = menu.get_active_list_cursor_text(true,true)
    if last_slot ~= sl and pulsel then
        timer = os.clock()
    end
    last_slot = sl
    local spacer = menu.get_value(spacer_ref)
    local spacer_x = spacer/1920
    local spacer_y = spacer/1080
    local tab_wid = menu.get_value(tab_wid_ref)/1920
    local addr_h = menu.get_value(addr_height_ref)/1080
    local menu_x, menu_y, menu_w, menu_h = menu.get_main_view_position_and_size()
    local menu_w_pix = menu_w*1920
    for i=0,menu_w_pix-1 do
        local pct = i / menu_w_pix
        pct = ((pct - (os.clock()-timer)*animsp)%1)*clr.a
        -- pct = math.abs((pct - (os.clock()-timer)*animsp)%2-1)*clr.a
        local fd = {
            r=bg_clr.r*(1-pct) + clr.r*pct,
            g=bg_clr.g*(1-pct) + clr.g*pct,
            b=bg_clr.b*(1-pct) + clr.b*pct,
            a=1
        }
        directx.draw_rect(i/1920+menu_x,menu_y,1/1920,menu_h,fd)
    end
    for i=1,math.ceil(menu_h/(32/1080)-1) do
        directx.draw_rect(menu_x,menu_y + i*32/1080-2/1080,menu_w,4/1080,clr)
    end
    directx.draw_rect(menu_x,menu_y,menu_w,2/1080,clr)
    directx.draw_rect(menu_x,menu_y+menu_h-2/1080,menu_w,2/1080,clr)
    local tab_cnt = 7
    if menu.get_edition() == 0 then
        tab_cnt = 8
    end
    local addr_offs = 0
    local addr_offs_l = 0
    local addr_offs_r = 0
    if menu.get_value(tab_tog_ref) == 1 then
        local tab_pos = menu.get_value(tab_pos_ref)
        if tab_pos == 1 then -- top
            addr_offs = 32/1080 + spacer_y
            directx.draw_rect(menu_x,menu_y-spacer_y-32/1080,tab_wid*tab_cnt,32/1080,bg_clr)
            for i=0,tab_cnt-1 do
                directx.draw_rect(menu_x+tab_wid*i,menu_y-spacer_y-3/1080,tab_wid,3/1080,clr)
                directx.draw_rect(menu_x+tab_wid*i + tab_wid/2 - 8/1920,menu_y-spacer_y-3/1080,16/1920,3/1080,clr)

            end
            -- local tab_tot_wid = tab_wid*7+spacer_x
            -- local tab_wid_pix = tab_tot_wid * 1920
            -- directx.draw_rect(menu_x,menu_y-spacer_y-32/1080,menu_w,32/1080,clr)
        elseif tab_pos == 5 then -- left
            directx.draw_rect(menu_x - tab_wid - spacer_x,menu_y,tab_wid,32/1080*tab_cnt,clr)
            addr_offs_l = tab_wid + spacer_x
        elseif tab_pos == 6 then -- right
            directx.draw_rect(menu_x + menu_w + spacer_x,menu_y,tab_wid,32/1080*tab_cnt,clr)
            addr_offs_r = tab_wid + spacer_x
        end
    end
    if menu.get_value(addr_ref) == 1 then
        local addr_x = menu_x - addr_offs_l
        local addr_y = menu_y - addr_offs - spacer_y - addr_h
        local addr_w = menu_w + addr_offs_l + addr_offs_r
        local addr_h_pix = addr_h*1080
        for i=0,addr_h_pix-1 do
            local pct = i/addr_h_pix
            pct = pct*0.8+0.2
            pct = pct*clr.a*0.7
            local fd = {
                r=bg_clr.r*(1-pct) + clr.r*pct,
                g=bg_clr.g*(1-pct) + clr.g*pct,
                b=bg_clr.b*(1-pct) + clr.b*pct,
                a=1
            }
            directx.draw_rect(addr_x, addr_y + i/1080,addr_w,1/1080,fd)
        end
        -- directx.draw_rect(menu_x - addr_offs_l,menu_y - addr_offs - spacer_y - addr_h,menu_w + addr_offs_l + addr_offs_r,addr_h,clr)
    end
    return true
end)