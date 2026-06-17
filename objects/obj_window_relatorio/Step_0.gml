event_inherited();

if (is_top_window && point_in_rectangle(mouse_x, mouse_y, x, y, x + win_width, y + win_height)) {
    if (mouse_wheel_down()) scroll_y -= 20;
    if (mouse_wheel_up()) scroll_y += 20;
}

// Lógica de Avançar Dia
if (is_top_window && mouse_check_button_pressed(mb_left)) {
    var _btn_w = 120;
    var _btn_h = 24;
    var _btn_x = floor(x) + (win_width / 2) - (_btn_w / 2);
    var _btn_y = floor(y) + win_height - 35;
    
    if (point_in_rectangle(mouse_x, mouse_y, _btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h)) {
        global.game_day++;
        global.emails_avaliados = [];
        global.inbox = [];
        global.meta_diaria = 0;
        
        obj_controller.expediente_ativo = false;
        with (obj_controller) event_user(0);
        instance_destroy();
    }
}