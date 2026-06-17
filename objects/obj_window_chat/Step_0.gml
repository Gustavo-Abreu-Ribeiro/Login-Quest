event_inherited();

if (is_top_window && mouse_check_button_pressed(mb_left) && meus_dados != noone) {
    var _pad = 10;
    var _sx = floor(x) + _pad;
    var _inner_w = win_width - (_pad * 2);
    
    var _sy = floor(y) + top_bar_height + _pad;
    var _msg_y = _sy + 25;
    var _msg_h = string_height_ext(meus_dados.mensagem, 16, _inner_w - 20) + 10;
    
    var _btn_h = 24;
    
    // Verifica qual dos 3 botões foi clicado
    for (var i = 0; i < 3; i++) {
        var _btn_y = _msg_y + _msg_h + 15 + (i * (_btn_h + 8));
        
        if (point_in_rectangle(mouse_x, mouse_y, _sx, _btn_y, _sx + _inner_w, _btn_y + _btn_h)) {
            
            // Registo para o Relatório
            var _registro = {
                assunto: "Chat com " + meus_dados.remetente,
                era_ameaca: meus_dados.is_threat,
                acao_jogador: (i == meus_dados.resposta_correta) ? "Agiu Corretamente" : "Caiu na Engenharia Social"
            };
            array_push(global.emails_avaliados, _registro);
            
            // Pontuação
            if (i == meus_dados.resposta_correta) {
                global.player_score += 100; // Respondeu certo!
            } else {
                global.player_score -= 100; // Errou a resposta (deu a senha ou bloqueou o CEO à toa)
            }
            
            // Remove a mensagem atual e carrega a próxima (se houver)
            array_delete(global.mensagens_pendentes, 0, 1);
            
            if (array_length(global.mensagens_pendentes) > 0) {
                meus_dados = global.mensagens_pendentes[0]; // Carrega o próximo chat
            } else {
                anim_state = "closing"; // Fecha a janela se acabarem as mensagens
            }
            
            break;
        }
    }
}