draw_set_alpha(image_alpha);
event_inherited();

// O round() aqui é a vacina contra a letra tremida!
var _pad = 10;
var _sx = round(x) + _pad;
var _sy = round(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

draw_set_font(fnt_pixel);

// --- 1. CABEÇALHO FIXO ---
draw_set_color(c_black);
draw_text(_sx, _sy, "De: " + meus_dados.remetente);
draw_text(_sx, _sy + 16, "Assunto: " + meus_dados.assunto);
draw_line(_sx, _sy + 35, _sx + _inner_w, _sy + 35);

// --- 2. SISTEMA DE SCROLL (SURFACE) ---
var _scroll_area_h = win_height - 90; 
var _max_largura = _inner_w - 4;
var _altura_texto = string_height_ext(meus_dados.corpo, 16, _max_largura);

var _max_scroll = max(0, _altura_texto - _scroll_area_h);
scroll_y = clamp(scroll_y, -_max_scroll, 0);

if (!surface_exists(surf_corpo)) {
    surf_corpo = surface_create(_inner_w, _scroll_area_h);
}

surface_set_target(surf_corpo);
draw_clear_alpha(c_black, 0); 
draw_set_color(c_black);
// Desenha o texto do corpo com quebra automática de linha
draw_text_ext(2, round(scroll_y) + 2, meus_dados.corpo, 16, _max_largura);
surface_reset_target();

draw_surface(surf_corpo, _sx, _sy + 40);

// --- 3. RODAPÉ FIXO (Anexos e Inspecionar) ---
var _rodape_y = round(y) + win_height - 30;
draw_set_color(c_black);
draw_line(_sx, _rodape_y - 5, _sx + _inner_w, _rodape_y - 5);

// ===============================================
// SISTEMA DO DIA 2: REVELA O BOTÃO DE INSPECIONAR
// ===============================================
if (global.game_day >= 2) {
    var _btn_insp_x = _sx;
    var _hover_insp = is_top_window && point_in_rectangle(mouse_x, mouse_y, _btn_insp_x, _rodape_y, _btn_insp_x + 90, _rodape_y + 20);
    
    draw_set_color(_hover_insp ? make_color_rgb(200, 200, 200) : c_white);
    draw_rectangle(_btn_insp_x, _rodape_y, _btn_insp_x + 90, _rodape_y + 20, false);
    draw_set_color(c_black);
    draw_rectangle(_btn_insp_x, _rodape_y, _btn_insp_x + 90, _rodape_y + 20, true);
    draw_text(_btn_insp_x + 5, _rodape_y + 3, "[?] INSPECIONAR");
}

// Se tiver anexo, desenha ao lado (ajusta o espaço se o Inspecionar estiver escondido)
if (variable_struct_exists(meus_dados, "anexo") && meus_dados.anexo != "") {
    draw_set_color(c_blue);
    var _anexo_x = (global.game_day >= 2) ? _sx + 100 : _sx;
    draw_text(_anexo_x, _rodape_y + 3, "[ANEXO]: " + meus_dados.anexo);
}

draw_set_alpha(1.0);