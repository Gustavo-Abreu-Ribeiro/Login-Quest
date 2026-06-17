event_inherited();

// Só processa as ações se houver logs pendentes e se a janela estiver no topo
if (is_top_window && array_length(global.logs_do_dia) > 0) {
    
    if (mouse_check_button_pressed(mb_left)) {
        var _pad = 10;
        var _sx = floor(x) + _pad;
        var _inner_w = win_width - (_pad * 2);
        var _sy = floor(y) + top_bar_height + _pad;
        
        var _btn_w = 100;
        var _btn_h = 22;
        var _by = _sy + 100; // Posição Y dos botões
        
        var _bx_permitir = _sx + 5;
        var _bx_bloquear = _sx + _inner_w - _btn_w - 5;
        
        var _decisao = 0; // 1 = Permitir, 2 = Bloquear
        
        if (point_in_rectangle(mouse_x, mouse_y, _bx_permitir, _by, _bx_permitir + _btn_w, _by + _btn_h)) _decisao = 1;
        if (point_in_rectangle(mouse_x, mouse_y, _bx_bloquear, _by, _bx_bloquear + _btn_w, _by + _btn_h)) _decisao = 2;
        
        if (_decisao > 0) {
            var _log_atual = global.logs_do_dia[0];
            
            // --- CÁLCULO DE ACERTO/ERRO ---
            var _acertou = false;
            if (_decisao == 1 && _log_atual.is_threat == false) _acertou = true;  // Permitiniu tráfego seguro
            if (_decisao == 2 && _log_atual.is_threat == true) _acertou = true;   // Bloqueou tráfego hacker
            
            if (_acertou) {
                global.player_score += 100;
                global.reputation = clamp(global.reputation + 5, 0, 100);
            } else {
                global.player_score -= 100;
                global.reputation = clamp(global.reputation - 20, 0, 100); // Erro de infraestrutura custa caro
            }
            
            // --- REGISTRA A TAREFA CONCLUÍDA ---
            var _registro = {
                assunto: "Log: " + _log_atual.user,
                era_ameaca: _log_atual.is_threat,
                acao_jogador: (_decisao == 1) ? "Permitiu IP" : "Bloqueou IP"
            };
            array_push(global.emails_avaliados, _registro); // Envia para o contador diário
            
            // --- REMOVE O LOG PROCESSADO DA FILA ---
            array_delete(global.logs_do_dia, 0, 1);
        }
    }
}