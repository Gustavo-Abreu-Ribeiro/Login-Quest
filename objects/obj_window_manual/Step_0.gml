event_inherited();

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

// ==========================================
// LÓGICA DE CLIQUE: ÍNDICE
// ==========================================
if (is_top_window && mouse_check_button_pressed(mb_left)) {
    
    var _content_y = _sy + 25;
    
    if (pagina_atual == "indice") {
        var _row_h = 22;
        
        // Verifica quantos tópicos existem no dia atual
        var _max_topicos = min(global.game_day, 5); // Limite de 5 tópicos (5 dias)
        
        for (var i = 0; i < _max_topicos; i++) {
            var _item_y = _content_y + (i * _row_h);
            
            // Se clicou na linha de um tópico
            if (point_in_rectangle(mouse_x, mouse_y, _sx, _item_y, _sx + _inner_w, _item_y + _row_h)) {
                pagina_atual = "pagina_" + string(i + 1); // Muda para pagina_1, pagina_2...
                manual_scroll_y = 0; // Reseta o scroll ao trocar de página
                break;
            }
        }
    }
    // ==========================================
    // LÓGICA DE CLIQUE: BOTÃO VOLTAR
    // ==========================================
    else {
        // Botão voltar fica no topo (posição fixa)
        if (point_in_rectangle(mouse_x, mouse_y, _sx, _content_y, _sx + 70, _content_y + 16)) {
            pagina_atual = "indice";
            manual_scroll_y = 0;
        }
    }
}

// ==========================================
// LÓGICA DE SCROLL (Apenas nas páginas de texto)
// ==========================================
if (is_top_window && pagina_atual != "indice") {
    if (mouse_wheel_up()) manual_scroll_y -= 25;
    if (mouse_wheel_down()) manual_scroll_y += 25;
    manual_scroll_y = clamp(manual_scroll_y, 0, manual_max_scroll);
}