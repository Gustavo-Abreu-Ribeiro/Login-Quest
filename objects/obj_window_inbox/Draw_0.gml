if (!variable_instance_exists(id, "scroll_y")) scroll_y = 0;
draw_set_alpha(image_alpha);
event_inherited();

var _pad = 10;
var _sx = round(x) + _pad;
var _sy = round(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);
var _inner_h = win_height - top_bar_height - (_pad * 2);
var _item_h = 40;

draw_set_font(fnt_pixel);

// ==========================================
// A TESOURA DO SCROLL
// ==========================================
gpu_set_scissor(_sx, _sy, _inner_w, _inner_h);

for (var i = 0; i < array_length(global.inbox); i++) {
    var _em = global.inbox[i];
    
    // O Y visual também acompanha o scroll_y
    var _item_y = round(_sy + (i * _item_h) + scroll_y);
    
    // Verifica se o mouse está por cima para fazer o efeito de Hover
    var _hover = (is_top_window && point_in_rectangle(mouse_x, mouse_y, _sx, _item_y, _sx + _inner_w, _item_y + _item_h - 4));
    
    // Fundo do botão de e-mail
    draw_set_color(_hover ? make_color_rgb(220, 220, 220) : c_white);
    draw_rectangle(_sx, _item_y, _sx + _inner_w, _item_y + _item_h - 4, false);
    
    // Borda
    draw_set_color(c_black);
    draw_rectangle(_sx, _item_y, _sx + _inner_w, _item_y + _item_h - 4, true);
    
    // Remetente (Em azulzinho)
    draw_set_color(make_color_rgb(0, 50, 150));
    draw_text(_sx + 4, _item_y + 2, _em.remetente);
    
    // Assunto (Preto e cortado se for longo)
    draw_set_color(c_black);
    var _assunto_curto = string_copy(_em.assunto, 1, 24);
    if (string_length(_em.assunto) > 24) _assunto_curto += "...";
    draw_text(_sx + 4, _item_y + 18, _assunto_curto);
}

// Desliga a tesoura para não bugar o resto do jogo
gpu_set_scissor(0, 0, room_width, room_height);

// ==========================================
// SE A CAIXA ESTIVER VAZIA
// ==========================================
if (array_length(global.inbox) == 0) {
    draw_set_color(c_dkgray);
    draw_set_halign(fa_center);
    draw_text(_sx + (_inner_w / 2), _sy + (_inner_h / 2) - 10, "Caixa Vazia.");
    draw_set_halign(fa_left);
}

draw_set_alpha(1.0);