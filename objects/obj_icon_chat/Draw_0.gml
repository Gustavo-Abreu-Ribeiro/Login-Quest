// 1. O Pai cuida do ícone
event_inherited();

// 2. Notificação do Chat apenas se já foi desbloqueado
if (global.game_day >= dia_desbloqueio) {
    
    if (variable_global_exists("mensagens_pendentes") && is_array(global.mensagens_pendentes)) {
        var _qtd = array_length(global.mensagens_pendentes);
        
        if (_qtd > 0) {
            var _nx = x + sprite_width - 4; 
            var _ny = y + 4;   
            
            draw_set_color(c_red);
            draw_circle(_nx, _ny, 8, false);
            draw_set_color(c_black);
            draw_circle(_nx, _ny, 8, true);
            
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle); 
            draw_text(_nx, _ny, string(_qtd));
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}