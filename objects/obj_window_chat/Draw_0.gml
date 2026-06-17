draw_set_alpha(image_alpha);
event_inherited();

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

draw_set_font(fnt_pixel);

if (meus_dados == noone) {
    draw_set_color(c_black);
    draw_text(_sx, _sy + 50, "Nao ha novas mensagens.");
    draw_set_alpha(1.0);
    exit;
}

// --- 1. CABEÇALHO DO CHAT ---
draw_set_color(c_dkgray);
draw_text(_sx, _sy, "Conversa com: " + meus_dados.remetente);
draw_line(_sx, _sy + 15, _sx + _inner_w, _sy + 15);

// --- 2. BOLHA DE MENSAGEM ---
var _msg_y = _sy + 25;
var _msg_h = string_height_ext(meus_dados.mensagem, 16, _inner_w - 20) + 10;

draw_set_color(make_color_rgb(220, 240, 255)); // Azul clarinho (estilo WhatsApp/Teams)
draw_rectangle(_sx, _msg_y, _sx + _inner_w, _msg_y + _msg_h, false);
draw_set_color(make_color_rgb(100, 150, 200));
draw_rectangle(_sx, _msg_y, _sx + _inner_w, _msg_y + _msg_h, true);

draw_set_color(c_black);
draw_text_ext(_sx + 10, _msg_y + 5, meus_dados.mensagem, 16, _inner_w - 20);

// --- 3. BOTÕES DE RESPOSTA (Múltipla Escolha) ---
var _btn_h = 24;
for (var i = 0; i < 3; i++) {
    var _btn_y = _msg_y + _msg_h + 15 + (i * (_btn_h + 8));
    
    var _hover = is_top_window && point_in_rectangle(mouse_x, mouse_y, _sx, _btn_y, _sx + _inner_w, _btn_y + _btn_h);
    
    draw_set_color(_hover ? make_color_rgb(200, 200, 200) : make_color_rgb(240, 240, 240));
    draw_rectangle(_sx, _btn_y, _sx + _inner_w, _btn_y + _btn_h, false);
    draw_set_color(c_dkgray);
    draw_rectangle(_sx, _btn_y, _sx + _inner_w, _btn_y + _btn_h, true);
    
    draw_set_color(c_black);
    draw_text(_sx + 5, _btn_y + 4, meus_dados.opcoes[i]);
}

win_height = (_msg_y - y) + _msg_h + 15 + (3 * (_btn_h + 8)) + 20;

draw_set_alpha(1.0);