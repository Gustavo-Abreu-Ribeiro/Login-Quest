event_inherited();

// --- 1. CONTROLE DE SCROLL (Para o corpo do texto) ---
if (is_top_window && point_in_rectangle(mouse_x, mouse_y, x, y, x + win_width, y + win_height)) {
    if (mouse_wheel_down()) scroll_y -= 20;
    if (mouse_wheel_up()) scroll_y += 20;
}

// Só permite interagir (clicar) se esta for a janela da frente
if (is_top_window) {
    
    if (mouse_check_button_pressed(mb_left)) {
        
        // ==========================================
        // A. LÓGICA DO BOTÃO INSPECIONAR (Rodapé - SÓ DIA 2 EM DIANTE)
        // ==========================================
        if (global.game_day >= 2) {
            var _pad = 10;
            var _sx = round(x) + _pad;
            var _rodape_y = round(y) + win_height - 30; // Posição fixa no novo layout
            
            // Checa o clique no botão "[?] INSPECIONAR" do rodapé
            if (point_in_rectangle(mouse_x, mouse_y, _sx, _rodape_y, _sx + 90, _rodape_y + 20)) {
                
                if (!instance_exists(obj_window_source)) {
                    var _insp = instance_create_depth(x + 40, y + 40, -9999, obj_window_source);
                    _insp.title = "Source: " + meus_dados.remetente;
                    // Joga as informações confidenciais do e-mail na inspeção!
                    _insp.codigo_fonte_texto = "IP ORIGEM: " + meus_dados.ip_alvo + "\nDATA: " + meus_dados.data_envio + "\nPROTOCOL: 8080";
                    _insp.my_parent_email = id; 
                } else {
                    obj_window_source.depth = -1000;
                }
            }
        }
        
        // ==========================================
        // B. LÓGICA DO MARCA-TEXTO (O Remetente)
        // ==========================================
        if (array_length(evidencias_email) > 0) {
            var _ev = evidencias_email[0];
            
            draw_set_font(fnt_pixel);
            
            // O cabeçalho foi fixado no Draw na posição `_sy` (y + top_bar_height + pad)
            // A palavra "De: " ocupa um espaço, o remetente vem logo a seguir
            var _pad = 10;
            var _sy = round(y) + top_bar_height + _pad;
            
            var _largura_de = string_width("De: ");
            var _largura_remetente = string_width(meus_dados.remetente);
            
            // A Hitbox acompanha o texto do remetente exatamente onde ele é desenhado
            var _box_x = round(x) + _pad + _largura_de;
            var _box_y = _sy;
            var _box_w = _largura_remetente + 4; // Margem de clique
            var _box_h = 16; // Altura padrão da linha de texto
            
            // Verifica se o mouse clicou em cima do remetente
            if (point_in_rectangle(mouse_x, mouse_y, _box_x, _box_y, _box_x + _box_w, _box_y + _box_h)) {
                evidencias_email[0][6] = !evidencias_email[0][6]; // Marca/Desmarca (Amarelo)
            }
        }
    }
}