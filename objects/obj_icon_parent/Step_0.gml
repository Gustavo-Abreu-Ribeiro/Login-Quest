if (global.game_day >= dia_desbloqueio){
// 1. Reduz o cronômetro do duplo clique constantemente
if (double_click_timer > 0) {
    double_click_timer--;
}

// 2. Verifica se o mouse foi clicado
if (mouse_check_button_pressed(mb_left)) {
    
    // O clique foi EM CIMA DESTE ÍCONE?
    if (position_meeting(mouse_x, mouse_y, id)) {
        
        selected = true; // Seleciona este ícone
        
        // Desmarca todos os outros ícones da tela
        with (obj_icon_parent) {
            if (id != other.id) selected = false;
        }
        
        // --- VERIFICA O DUPLO CLIQUE ---
        if (double_click_timer > 0) {
            // É UM DUPLO CLIQUE!
            if (target_window != noone) {
                // Checa se a janela já não está aberta (para não abrir 10 e-mails iguais)
                if (!instance_exists(target_window)) {
                    // Cria a janela no centro da tela
                    instance_create_depth(room_width/2 - 90, room_height/2 - 70, -1000, target_window);
                }
            }
            double_click_timer = 0; // Zera o timer
            selected = false;       // Tira a seleção visual após abrir
            
        } else {
            // É O PRIMEIRO CLIQUE. Dá início ao timer!
            double_click_timer = double_click_speed;
        }
        
    } else {
        // Se clicou no fundo da tela (longe de janelas e ícones), desmarca o ícone
        if (!position_meeting(mouse_x, mouse_y, obj_window_parent) && !position_meeting(mouse_x, mouse_y, obj_icon_parent)) {
            selected = false;
        }
    }
}
}