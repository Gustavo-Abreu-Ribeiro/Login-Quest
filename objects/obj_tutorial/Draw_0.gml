// 1. Escurece o fundo
draw_set_color(c_black);
draw_set_alpha(0.85);
draw_rectangle(0, 0, room_width, room_height, false);

// 2. Desenha a caixa do Tutorial no centro (Aumentamos a altura!)
draw_set_alpha(1.0);
var _box_w = 340;
var _box_h = 250; // <-- AUMENTADO PARA 250
var _cx = (room_width / 2) - (_box_w / 2);
var _cy = (room_height / 2) - (_box_h / 2);

draw_set_color(c_white);
draw_rectangle(_cx, _cy, _cx + _box_w, _cy + _box_h, false);

draw_set_color(make_color_rgb(0, 50, 100)); // Borda azul
draw_rectangle(_cx, _cy, _cx + _box_w, _cy + _box_h, true);
draw_rectangle(_cx + 2, _cy + 2, _cx + _box_w - 2, _cy + _box_h - 2, true);

// 3. Desenha o Texto Dinâmico
draw_set_font(fnt_pixel);
draw_set_color(c_black);
draw_set_halign(fa_center);

// O "22" ali no meio é o espaçamento entre as linhas, dá um respiro na leitura
draw_text_ext(_cx + (_box_w / 2), _cy + 20, paginas[pagina_atual], 22, _box_w - 30);

// 4. Instrução para avançar
draw_set_color(c_dkgray);
var _alpha_pisca = abs(sin(current_time / 300));
draw_set_alpha(_alpha_pisca);
draw_text(_cx + (_box_w / 2), _cy + _box_h - 25, "[ CLIQUE PARA AVANCAR ]");

// Restaura os padrões
draw_set_alpha(1.0);
draw_set_halign(fa_left);