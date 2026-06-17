event_inherited();

if (is_top_window && mouse_check_button_pressed(mb_left)) {
    var _pad = 10;
    var _sx = floor(x) + _pad;
    var _inner_w = win_width - (_pad * 2);
    var _btn_w = 90;
    var _btn_h = 24;
    var _by = y + win_height - _btn_h - _pad;
    
    var _bx1 = _sx; // Reportar
    var _bx2 = _sx + _inner_w - _btn_w; // Aprovar
    
    // CLIQUE EM REPORTAR
    if (point_in_rectangle(mouse_x, mouse_y, _bx1, _by, _bx1 + _btn_w, _by + _btn_h)) {
        var _registro = {
            assunto: "Senha: " + meus_dados.usuario,
            era_ameaca: meus_dados.is_threat,
            acao_jogador: "Bloqueou"
        };
        array_push(global.emails_avaliados, _registro);
        
        if (meus_dados.is_threat) global.player_score += 100; else global.player_score -= 50;
        anim_state = "closing"; // Fecha a janela
    }
    
    // CLIQUE EM APROVAR
    else if (point_in_rectangle(mouse_x, mouse_y, _bx2, _by, _bx2 + _btn_w, _by + _btn_h)) {
        var _registro = {
            assunto: "Senha: " + meus_dados.usuario,
            era_ameaca: meus_dados.is_threat,
            acao_jogador: "Aprovou"
        };
        array_push(global.emails_avaliados, _registro);
        
        if (!meus_dados.is_threat) global.player_score += 50; else global.player_score -= 100;
        anim_state = "closing"; // Fecha a janela
    }
}