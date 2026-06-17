event_inherited();

// 1. Barra de Carregamento
if (scanning && scan_progress < 100) {
    scan_progress += 1; // Velocidade da análise
}

// 2. Lógica dos Botões (Apenas quando o scan termina a 100%)
if (scanning && scan_progress >= 100 && is_top_window) {
    
    if (mouse_check_button_pressed(mb_left)) {
        var _sx = round(x);
        var _sy = round(y) + top_bar_height;
        var _cx = _sx + (win_width / 2);
        var _by = _sy + 80; // Altura onde os botões estão desenhados

        // --- BOTÃO DA ESQUERDA: ISOLAR MALWARE ---
        if (point_in_rectangle(mouse_x, mouse_y, _cx - 100, _by, _cx - 10, _by + 24)) {
            array_push(global.emails_avaliados, {
                assunto: scan_assunto,
                era_ameaca: scan_threat,
                acao_jogador: "Isolou Malware"
            });
            
            if (scan_threat) global.player_score += 100; else global.player_score -= 50;
            scanning = false; // Desliga o scanner para o próximo anexo
        }
        
        // --- BOTÃO DA DIREITA: LIBERAR ANEXO ---
        if (point_in_rectangle(mouse_x, mouse_y, _cx + 10, _by, _cx + 100, _by + 24)) {
            array_push(global.emails_avaliados, {
                assunto: scan_assunto,
                era_ameaca: scan_threat,
                acao_jogador: "Liberou Anexo"
            });
            
            if (!scan_threat) global.player_score += 50; else global.player_score -= 100;
            scanning = false; // Desliga o scanner
        }
    }
}