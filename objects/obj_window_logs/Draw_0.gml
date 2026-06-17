draw_set_alpha(image_alpha);
event_inherited();

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

draw_set_font(fnt_pixel);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Se a fila de logs acabou
if (array_length(global.logs_do_dia) <= 0) {
    draw_set_color(make_color_rgb(0, 180, 0)); // Verde Terminal
    draw_text_ext(_sx + 5, _sy + 20, "MOLDU_NET: Conexoes estáveis.\nNenhum pacote suspeito na fila.", 16, _inner_w);
} 
else {
    // Pega o primeiro log ativo da fila
    var _log = global.logs_do_dia[0];
    
    // --- CAIXA DO TERMINAL (Estilo Linux/Hacker) ---
    draw_set_color(make_color_rgb(15, 20, 15));
    draw_rectangle(_sx, _sy, _sx + _inner_w, _sy + 85, false);
    draw_set_color(make_color_rgb(0, 200, 0));
    draw_rectangle(_sx, _sy, _sx + _inner_w, _sy + 85, true);
    
    // Textos do Log
    draw_text(_sx + 8, _sy + 6,  "TIMESTAMP: " + _log.time);
    draw_text(_sx + 8, _sy + 24, "USER:      " + _log.user);
    draw_text(_sx + 8, _sy + 42, "SRC_IP:    " + _log.ip);
    draw_text(_sx + 8, _sy + 60, "GEO_LOC:   " + _log.loc);
    
    // --- BOTÕES DE TOMADA DE DECISÃO ---
    var _btn_w = 100;
    var _btn_h = 22;
    var _by = _sy + 100;
    var _bx_permitir = _sx + 5;
    var _bx_bloquear = _sx + _inner_w - _btn_w - 5;
    
    var _hover_p = is_top_window && point_in_rectangle(mouse_x, mouse_y, _bx_permitir, _by, _bx_permitir + _btn_w, _by + _btn_h);
    var _hover_b = is_top_window && point_in_rectangle(mouse_x, mouse_y, _bx_bloquear, _by, _bx_bloquear + _btn_w, _by + _btn_h);
    
    draw_set_halign(fa_center);
    
    // Desenho do Botão PERMITIR (Verde escuro /反馈 claro)
    draw_set_color(_hover_p ? make_color_rgb(180, 235, 180) : make_color_rgb(220, 220, 220));
    draw_rectangle(_bx_permitir, _by, _bx_permitir + _btn_w, _by + _btn_h, false);
    draw_set_color(c_black);
    draw_rectangle(_bx_permitir, _by, _bx_permitir + _btn_w, _by + _btn_h, true);
    draw_text(_bx_permitir + (_btn_w / 2), _by + 5, "PERMITIR");
    
    // Desenho do Botão BLOQUEAR (Vermelho / Feedback claro)
    draw_set_color(_hover_b ? make_color_rgb(255, 180, 180) : make_color_rgb(220, 220, 220));
    draw_rectangle(_bx_bloquear, _by, _bx_bloquear + _btn_w, _by + _btn_h, false);
    draw_set_color(c_black);
    draw_rectangle(_bx_bloquear, _by, _bx_bloquear + _btn_w, _by + _btn_h, true);
    draw_text(_bx_bloquear + (_btn_w / 2), _by + 5, "BLOQUEAR");
    
    draw_set_halign(fa_left);
}

draw_set_alpha(1.0);