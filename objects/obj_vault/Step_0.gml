// Verifica APENAS no momento em que o jogador solta o botão do mouse
if (mouse_check_button_released(mb_left)) {
    
    // O mouse está em cima do cofre? E o jogador está segurando algo?
    if (position_meeting(mouse_x, mouse_y, id) && global.dragging_data != noone) {
        
        // Aqui acontece a lógica de aprovação/reprovação
        if (global.dragging_data.is_threat == true) {
            global.player_score += 100;
            // No futuro, chame o seu script de relatório diário aqui
            show_debug_message("SUCESSO: Ameaça (" + string(global.dragging_data.value) + ") bloqueada!");
        } else {
            global.reputation -= 20;
            show_debug_message("ERRO: O recurso (" + string(global.dragging_data.value) + ") era seguro e não deveria ser bloqueado.");
        }
        
        // Opcional: Destruir o obj_evidence original para sumir da tela
        with (obj_evidence) {
            if (is_being_dragged) {
                instance_destroy();
            }
        }
    }
    
    // Independente de ter soltado no cofre ou no vazio, limpa a variável global
    global.dragging_data = noone;
}