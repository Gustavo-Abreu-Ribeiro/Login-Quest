event_inherited();

if (is_top_window && mouse_check_button_pressed(mb_left)) {
    var _pad = 10;
    var _sx = floor(x) + _pad;
    var _sy = floor(y) + top_bar_height + _pad;
    var _inner_w = win_width - (_pad * 2);
    var _list_y = _sy + 20;
    
    for (var i = 0; i < array_length(global.chamados); i++) {
        var _item_y = _list_y + (i * 35);
        
        // Se o jogador clicou neste ticket específico
       if (point_in_rectangle(mouse_x, mouse_y, _sx, _item_y, _sx + _inner_w, _item_y + 30)) {
            
            var _ticket_clicado = global.chamados[i];
            var _inst = noone;
            
            // LÊ O TIPO PARA ABRIR A JANELA CERTA
            if (_ticket_clicado.type == "senha") {
                _inst = instance_create_depth(x + 30, y + 30, -1000, obj_window_senha);
            } else if (_ticket_clicado.type == "acesso") {
                _inst = instance_create_depth(x + 30, y + 30, -1000, obj_window_acesso);
            }
            
            if (_inst != noone) {
                _inst.meus_dados = _ticket_clicado;
            }
            
            array_delete(global.chamados, i, 1);
            break; 
        }
    }
}
