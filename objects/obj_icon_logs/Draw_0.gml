// 1. O Pai cuida de desenhar o ícone se o dia estiver correto
event_inherited();

// 2. Notificação de Logs se já foi desbloqueado (Dia 5)
if (global.game_day >= dia_desbloqueio) {
    
    if (variable_global_exists("logs_do_dia") && is_array(global.logs_do_dia)) {
        var _qtd = array_length(global.logs_do_dia);
        
        if (_qtd > 0) {
            var _nx = x + sprite_width - 4; 
            var _ny = y + 4;   
            
            // Círculo Vermelho
            draw_set_color(c_red);
            draw_circle(_nx, _ny, 8, false);
            
            // Borda Preta
            draw_set_color(c_black);
            draw_circle(_nx, _ny, 8, true);
            
            // Texto (Quantidade)
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle); 
            draw_text(_nx, _ny, string(_qtd));
            
            // Repor padrões
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}