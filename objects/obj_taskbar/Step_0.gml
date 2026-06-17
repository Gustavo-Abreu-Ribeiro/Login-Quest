
// Força a barra de tarefas a NUNCA ir para trás das janelas ou papel de parede
depth = -99999;// 1. A MÁGICA: Se o relatório ou a tela final abrirem, a barra some!
if (instance_exists(obj_window_relatorio) || instance_exists(obj_window_endgame)) {
    visible = false;
    exit;
} else {
    visible = true;
}

var _bar_y = room_height - bar_height;
var _btn_size = 20; // Botões quadrados perfeitos
var _pad = 6;
var _x_offset = 6;

if (mouse_check_button_pressed(mb_left)) {
    var _count = 0;
    
    for (var i = 0; i < instance_number(obj_window_parent); i++) {
        var _win = instance_find(obj_window_parent, i);
        
        if (_win.title != "") {
            var _bx = _x_offset + (_count * (_btn_size + _pad));
            var _by = _bar_y + 2;
            
            // Verifica clique no quadradinho
            if (point_in_rectangle(mouse_x, mouse_y, _bx, _by, _bx + _btn_size, _by + _btn_size)) {
                
                if (_win.visible == false) {
                    _win.visible = true;
                    with (obj_window_parent) { depth += 10; is_top_window = false; }
                    _win.depth = -1000;
                    _win.is_top_window = true;
                } else {
                    if (_win.is_top_window) {
                        _win.visible = false;
                        _win.is_top_window = false; 
                    } else {
                        with (obj_window_parent) { depth += 10; is_top_window = false; }
                        _win.depth = -1000;
                        _win.is_top_window = true;
                    }
                }
                break;
            }
            _count++;
        }
    }
}