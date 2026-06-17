draw_set_alpha(image_alpha);
event_inherited();

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

draw_set_font(fnt_pixel);
draw_set_halign(fa_left);

// --- 1. CABEÇALHO DA REQUISIÇÃO ---
draw_set_color(c_black);
var _req_texto = "Requisicao: Funcionario do setor " + meus_dados.setor + " solicitou redefinicao de senha.\nUsuario: " + meus_dados.usuario;
draw_text_ext(_sx, _sy, _req_texto, 14, _inner_w);

// --- 2. CAIXA DA SENHA ---
var _box_y = _sy + 45;
draw_set_color(c_white);
draw_rectangle(_sx, _box_y, _sx + _inner_w, _box_y + 40, false);
draw_set_color(c_dkgray);
draw_rectangle(_sx, _box_y, _sx + _inner_w, _box_y + 40, true);

draw_set_color(c_black);
draw_text(_sx + 4, _box_y + 4, "Senha sugerida:");
draw_set_color(make_color_rgb(180, 0, 0)); // Vermelho escuro para destacar
draw_text(_sx + 4, _box_y + 20, meus_dados.senha_tentativa);

// --- 3. BOTÕES (Reportar / Aprovar) ---
var _btn_w = 90;
var _btn_h = 24;
var _by = y + win_height - _btn_h - _pad;

// Botão Reportar (Esquerda)
var _bx1 = _sx;
var _hover1 = is_top_window && point_in_rectangle(mouse_x, mouse_y, _bx1, _by, _bx1 + _btn_w, _by + _btn_h);
draw_set_color(_hover1 ? make_color_rgb(255, 100, 100) : make_color_rgb(200, 50, 50));
draw_rectangle(_bx1, _by, _bx1 + _btn_w, _by + _btn_h, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(_bx1 + (_btn_w / 2), _by + 6, "REPORTAR");

// Botão Aprovar (Direita)
var _bx2 = _sx + _inner_w - _btn_w;
var _hover2 = is_top_window && point_in_rectangle(mouse_x, mouse_y, _bx2, _by, _bx2 + _btn_w, _by + _btn_h);
draw_set_color(_hover2 ? make_color_rgb(100, 200, 100) : make_color_rgb(50, 150, 50));
draw_rectangle(_bx2, _by, _bx2 + _btn_w, _by + _btn_h, false);
draw_set_color(c_white);
draw_text(_bx2 + (_btn_w / 2), _by + 6, "APROVAR");

draw_set_halign(fa_left);
draw_set_alpha(1.0);