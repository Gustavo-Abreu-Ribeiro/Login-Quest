if (expediente_ativo) {
    
    // 1. O Relógio Corre
    hora_atual_minutos += velocidade_tempo;
    
    // ==========================================
    // 2. AS 4 ENGRENAGENS DE ENTREGA (Spawns)
    // ==========================================
    for (var i = array_length(fila_emails) - 1; i >= 0; i--) {
        if (hora_atual_minutos >= fila_emails[i].minuto_spawn) {
            array_push(global.inbox, fila_emails[i]);
            array_delete(fila_emails, i, 1);
        }
    }
    
    for (var i = array_length(fila_chamados) - 1; i >= 0; i--) {
        if (hora_atual_minutos >= fila_chamados[i].minuto_spawn) {
            array_push(global.chamados, fila_chamados[i]);
            array_delete(fila_chamados, i, 1);
        }
    }
    
    for (var i = array_length(fila_logs) - 1; i >= 0; i--) {
        if (hora_atual_minutos >= fila_logs[i].minuto_spawn) {
            array_push(global.logs_do_dia, fila_logs[i]);
            array_delete(fila_logs, i, 1);
        }
    }
    
    for (var i = array_length(fila_chat) - 1; i >= 0; i--) {
        if (hora_atual_minutos >= fila_chat[i].minuto_spawn) {
            array_push(global.mensagens_pendentes, fila_chat[i]);
            array_delete(fila_chat, i, 1);
        }
    }
    
    // ==========================================
    // 3. VERIFICA O FIM DO DIA
    // ==========================================
    var _tarefas_concluidas = array_length(global.emails_avaliados);
    var _tudo_resolvido = (global.meta_diaria > 0 && _tarefas_concluidas >= global.meta_diaria);
    var _tempo_esgotado = (hora_atual_minutos >= hora_fim_minutos);
    
    if (_tudo_resolvido || _tempo_esgotado) {
        expediente_ativo = false;
        
        if (_tudo_resolvido && !_tempo_esgotado) {
            var _minutos_poupados = hora_fim_minutos - hora_atual_minutos;
            var _bonus = floor(_minutos_poupados * 0.5);
            global.player_score += _bonus;
            
            array_push(global.emails_avaliados, { 
                assunto: "BONUS DE EFICIENCIA", era_ameaca: false, acao_jogador: "+" + string(_bonus) + " PTS" 
            });
            
        } else if (_tempo_esgotado) {
            // PUNIÇÃO GERAL: Soma TUDO que ficou pendente em todas as caixas!
            var _ignorados = array_length(global.inbox) + array_length(global.chamados) + array_length(global.logs_do_dia) + array_length(global.mensagens_pendentes);
            if (_ignorados > 0) {
                global.player_score -= (_ignorados * 50); 
                global.reputation = clamp(global.reputation - (_ignorados * 10), 0, 100); 
            }
        }
        
        if (_tempo_esgotado) hora_atual_minutos = hora_fim_minutos; 
        
        if (!instance_exists(obj_window_relatorio)) {
            with(obj_window_parent) instance_destroy(); 
            instance_create_depth(room_width/2, room_height/2, -9999, obj_window_relatorio);
        }
    }
}

// ==========================================
// DEBUG / CHEAT CODE: Pular Dia (Tecla F8)
// ==========================================
if (keyboard_check_pressed(vk_f8)) {
    global.game_day++;
    global.inbox = [];
    global.chamados = [];
    global.logs_do_dia = [];
    global.mensagens_pendentes = [];
    global.emails_avaliados = [];
    fila_emails = [];
    fila_chamados = [];
    fila_logs = [];
    fila_chat = [];
    global.meta_diaria = 0;
    
    with (obj_window_parent) instance_destroy();
    
    expediente_ativo = false;
    event_user(0);
}