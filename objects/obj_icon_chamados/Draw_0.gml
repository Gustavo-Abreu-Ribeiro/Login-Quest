// 1. O Pai cuida de desenhar o ícone APENAS se o dia estiver correto
event_inherited();

// 2. Só tenta desenhar a notificação se o ícone estiver desbloqueado!
if (global.game_day >= dia_desbloqueio) {
    
    // Proteção de variável
    if (variable_global_exists("chamados") && is_array(global.chamados)) {
        var _qtd = array_length(global.chamados);
        
        // Só desenha se tiver mais de 0 chamados
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
            
            // Repor alinhamento
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}