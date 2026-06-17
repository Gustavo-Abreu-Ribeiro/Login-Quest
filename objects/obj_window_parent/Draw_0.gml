// Se estiver minimizada, não desenha nem a sombra!
if (!visible) exit;
// --- Evento Draw do obj_window_parent ---

// 1. Moldura
draw_sprite_stretched(spr_window_frame, 0, floor(x), floor(y), win_width, win_height);

// 2. Título (Alinhamento rigoroso)
draw_set_font(fnt_pixel);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
// Desenha o texto 2 pixels abaixo do topo para centralizar nos 12px da barra
draw_text(floor(x) + 4, floor(y) + 2, title);

// 3. Botão Fechar (Canto superior direito)
// X final da janela - tamanho do botão - padding
var _btn_x = (floor(x) + win_width) - close_btn_size - 4; 
var _btn_y = floor(y) + close_btn_padding;

if (hover_close) {
    draw_sprite_ext(spr_win_close, 0, _btn_x, _btn_y, 1, 1, 0, c_white, 1);
} else {
    draw_sprite_ext(spr_win_close, 0, _btn_x, _btn_y, 1, 1, 0, c_gray, 1);
}