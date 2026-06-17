draw_set_alpha(image_alpha);
event_inherited();

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

draw_set_font(fnt_pixel);
draw_set_halign(fa_center);

// --- MENSAGEM DE VITÓRIA OU DERROTA ---
if (status == "win") {
    draw_set_color(make_color_rgb(50, 150, 50)); // Verde
    draw_text(_sx + (_inner_w / 2), _sy + 20, "PARABENS! MISSAO CUMPRIDA.");
    draw_set_color(c_black);
    draw_text_ext(_sx + (_inner_w / 2), _sy + 50, "Sobreviveu a semana na CyProtect. As suas analises rigorosas mantiveram a empresa a salvo de ciberataques!", 16, _inner_w - 20);
} else {
    draw_set_color(make_color_rgb(200, 50, 50)); // Vermelho
    draw_text(_sx + (_inner_w / 2), _sy + 20, "GAME OVER: DEMISSAO.");
    draw_set_color(c_black);
    draw_text_ext(_sx + (_inner_w / 2), _sy + 50, "A sua pontuacao de seguranca caiu para niveis criticos. A empresa sofreu uma violacao de dados e o seu contrato foi rescindido.", 16, _inner_w - 20);
}

// --- BOTÃO REINICIAR ---
var _btn_w = 140; var _btn_h = 30;
var _bx = _sx + (_inner_w / 2) - (_btn_w / 2);
var _by = y + win_height - _btn_h - _pad;

var _hover = is_top_window && point_in_rectangle(mouse_x, mouse_y, _bx, _by, _bx + _btn_w, _by + _btn_h);
draw_set_color(_hover ? make_color_rgb(100, 150, 255) : make_color_rgb(50, 100, 200));
draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, false);

draw_set_color(c_white);
draw_text(_bx + (_btn_w / 2), _by + 8, "REINICIAR JOGO");
draw_set_halign(fa_left); // Repor o alinhamento padrão

draw_set_alpha(1.0);