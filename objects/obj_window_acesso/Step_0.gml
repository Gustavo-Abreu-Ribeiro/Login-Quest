event_inherited();

if (is_top_window && mouse_check_button_pressed(mb_left)) {
    var _pad = 10;
    var _sx = floor(x) + _pad;
    var _inner_w = win_width - (_pad * 2);
    var _btn_w = 90;
    var _btn_h = 24;
    var _by = y + win_height - _btn_h - _pad;
    
    // Coordenadas exatas dos botões desenhados no Draw
    var _bx1 = _sx; // Botão NEGAR (Esquerda)
    var _bx2 = _sx + _inner_w - _btn_w; // Botão CONCEDER (Direita)
    
    // ==========================================
    // CLIQUE EM "NEGAR"
    // ==========================================
    if (point_in_rectangle(mouse_x, mouse_y, _bx1, _by, _bx1 + _btn_w, _by + _btn_h)) {
        
        // Regista a ação para o relatório diário
        var _registro = {
            assunto: "Acesso a: " + meus_dados.pasta,
            era_ameaca: meus_dados.is_threat,
            acao_jogador: "Negou" // Bloqueou
        };
        array_push(global.emails_avaliados, _registro);
        
        // Lógica de Pontuação (Fator Humano)
        if (meus_dados.is_threat) {
            global.player_score += 100; // Muito bem! Bloqueou um ataque ou escalada de privilégios.
        } else {
            global.player_score -= 50;  // Erro! Impediu um funcionário legítimo de trabalhar.
        }
        
        anim_state = "closing"; // Aciona a animação de fechar a janela
    }
    
    // ==========================================
    // CLIQUE EM "CONCEDER"
    // ==========================================
    else if (point_in_rectangle(mouse_x, mouse_y, _bx2, _by, _bx2 + _btn_w, _by + _btn_h)) {
        
        // Regista a ação para o relatório diário
        var _registro = {
            assunto: "Acesso a: " + meus_dados.pasta,
            era_ameaca: meus_dados.is_threat,
            acao_jogador: "Aprovou" // Concedeu
        };
        array_push(global.emails_avaliados, _registro);
        
        // Lógica de Pontuação (Fator Humano)
        if (!meus_dados.is_threat) {
            global.player_score += 50;  // Correto. Ajudou a equipa a manter a produtividade.
        } else {
            global.player_score -= 100; // Desastre! Deu acesso aos invasores à base de dados.
        }
        
        anim_state = "closing"; // Aciona a animação de fechar a janela
    }
}