event_inherited();

var _pad = 10;
var _sx = round(x) + _pad;
var _sy = round(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);
var _inner_h = win_height - top_bar_height - (_pad * 2);
var _item_h = 40; // Altura do "botão" de cada e-mail

// 1. SISTEMA DE SCROLL (Bolinha do Mouse)
// Certifique-se de ter 'scroll_y = 0;' no Evento Create!
if (!variable_instance_exists(id, "scroll_y")) scroll_y = 0;

if (is_top_window && point_in_rectangle(mouse_x, mouse_y, x, y, x + win_width, y + win_height)) {
    if (mouse_wheel_down()) scroll_y -= 20;
    if (mouse_wheel_up()) scroll_y += 20;
}

// Trava o Scroll com uma "gordurinha" no final
var _max_scroll = max(0, (array_length(global.inbox) * _item_h) - _inner_h + 30);
scroll_y = clamp(scroll_y, -_max_scroll, 0);

// 2. CLICAR NO E-MAIL PARA LER
if (is_top_window && mouse_check_button_pressed(mb_left)) {
    // Garante que o jogador clicou DENTRO da área segura da janela
    if (point_in_rectangle(mouse_x, mouse_y, _sx, _sy, _sx + _inner_w, _sy + _inner_h)) {
        
        for (var i = 0; i < array_length(global.inbox); i++) {
            // A posição Y de cada botão precisa somar o scroll_y!
            var _item_y = _sy + (i * _item_h) + scroll_y;
            
            // Se clicou exatamente em cima deste e-mail
            if (point_in_rectangle(mouse_x, mouse_y, _sx, _item_y, _sx + _inner_w, _item_y + _item_h - 4)) {
                
                // Abre a janela de leitura
                var _novo_email = instance_create_depth(x + 20, y + 20, -9999, obj_window_email);
                _novo_email.meus_dados = global.inbox[i];
                _novo_email.title = "Ler: " + global.inbox[i].assunto;
                
                // Tira o e-mail da caixa de entrada
                array_delete(global.inbox, i, 1);
                break; // Sai do loop para não clicar em dois ao mesmo tempo
            }
        }
    }
}