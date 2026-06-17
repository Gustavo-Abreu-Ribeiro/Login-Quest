event_inherited();

// Lógica de clicar no botão "REINICIAR JOGO"
if (is_top_window && mouse_check_button_pressed(mb_left)) {
    var _pad = 10;
    var _sx = floor(x) + _pad;
    var _inner_w = win_width - (_pad * 2);
    
    var _btn_w = 140; var _btn_h = 30;
    var _bx = _sx + (_inner_w / 2) - (_btn_w / 2);
    var _by = y + win_height - _btn_h - _pad;
    
    if (point_in_rectangle(mouse_x, mouse_y, _bx, _by, _bx + _btn_w, _by + _btn_h)) {
        game_restart(); // Reinicia o jogo completamente do zero!
    }
}