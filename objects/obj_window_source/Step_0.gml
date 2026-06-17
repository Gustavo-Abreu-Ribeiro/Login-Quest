event_inherited();

if (is_top_window) {
    var _pad = 6;
    var _inner_x = x + _pad;
    var _inner_y = y + top_bar_height + _pad + 2;
    var _inner_w = win_width - (_pad * 2);
    var _inner_h = win_height - top_bar_height - (_pad * 2) - 4;

    if (mouse_check_button_pressed(mb_left)) {
        
        // ==========================================
        // 1. CHECANDO O CLIQUE NO MARCA-TEXTO
        // ==========================================
        for (var i = 0; i < array_length(evidencias); i++) {
            var _ev = evidencias[i];
            if (point_in_rectangle(mouse_x, mouse_y, _inner_x + _ev[1], _inner_y + _ev[2], _inner_x + _ev[1] + _ev[3], _inner_y + _ev[2] + _ev[4])) {
                evidencias[i][6] = !evidencias[i][6]; // Liga/Desliga o amarelo
            }
        }
        
        // ==========================================
        // 2. CHECANDO O CLIQUE NO BOTÃO "GRAVAR"
        // ==========================================
        var _btn_w = 80;
        var _btn_h = 20;
        var _btn_x = _inner_x + _inner_w - _btn_w - 6; 
        var _btn_y = _inner_y + _inner_h - _btn_h - 6;
        
        if (point_in_rectangle(mouse_x, mouse_y, _btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h)) {
            
            // --- A MÁGICA DA PONTUAÇÃO ---
            var _pontos_rodada = 0;
            
            for (var i = 0; i < array_length(evidencias); i++) {
                var _ev = evidencias[i];
                if (_ev[6] == true && _ev[5] == true) {
                    _pontos_rodada += 100; // ACERTOU: Marcou uma ameaça real
                } else if (_ev[6] == true && _ev[5] == false) {
                    _pontos_rodada -= 50;  // ERROU: Marcou algo legítimo (Paranoia)
                }
            }
            
            global.player_score += _pontos_rodada; // Soma ao score total
            
            // --- FECHA TUDO E REGISTRA TAREFA ---
            if (variable_instance_exists(id, "my_parent_email")) {
                if (instance_exists(my_parent_email)) {
                    
                    // A CORREÇÃO ESTÁ AQUI: Avisa ao jogo que este e-mail foi resolvido!
                    var _registro = {
                        assunto: my_parent_email.meus_dados.assunto,
                        era_ameaca: my_parent_email.meus_dados.is_threat,
                        acao_jogador: "Bloqueou (Evidencia)"
                    };
                    array_push(global.emails_avaliados, _registro);
                    
                    // Manda o E-mail pai ser sugado pelo Firewall!
                    my_parent_email.anim_state = "sucking";
                    my_parent_email.dest_x = obj_firewall.x;
                    my_parent_email.dest_y = obj_firewall.y;
                }
            }
            
            // A própria janela de código faz um fade-out
            anim_state = "closing";
        }
    }
}