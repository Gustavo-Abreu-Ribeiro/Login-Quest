draw_set_alpha(image_alpha);
event_inherited(); 

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);
var _inner_h = win_height - top_bar_height - (_pad * 2);

draw_set_font(fnt_pixel);

// --- CÁLCULO DO SCROLL ---
var _card_h = 55; // Altura de cada "ficha" de funcionário

var _folga_rodape = 20; // 20 pixels de espaço vazio no fundo da lista
var _espaco_total = (array_length(global.db_funcionarios) * _card_h) + _folga_rodape;

db_max_scroll = max(0, _espaco_total - _inner_h);

// ==========================================
// MÁSCARA DE CORTE (TESOURA DO SCROLL)
// ==========================================
gpu_set_scissor(_sx, _sy, _inner_w, _inner_h);

for (var i = 0; i < array_length(global.db_funcionarios); i++) {
    var _func = global.db_funcionarios[i];
    
    // Y do cartão subtraído do scroll
    var _card_y = _sy + (i * _card_h) - db_scroll_y; 
    
    // Fundo do cartão alternando cores (efeito zebrado para facilitar leitura)
    draw_set_color((i % 2 == 0) ? make_color_rgb(240, 240, 240) : c_white);
    draw_rectangle(_sx, _card_y, _sx + _inner_w, _card_y + _card_h - 4, false);
    
    // Borda do cartão
    draw_set_color(c_dkgray);
    draw_rectangle(_sx, _card_y, _sx + _inner_w, _card_y + _card_h - 4, true);
    
    // Textos da Ficha
    draw_set_color(make_color_rgb(0, 0, 100)); // Nome em azul escuro
    draw_text(_sx + 4, _card_y + 2, _func.nome + " (" + _func.setor + ")");
    
    draw_set_color(c_black);
    draw_text(_sx + 4, _card_y + 16, "Email: " + _func.email);
    
    draw_set_color(make_color_rgb(100, 100, 100)); // Cargo e acesso em cinza
    draw_text(_sx + 4, _card_y + 30, "Cargo: " + _func.cargo + " | Acesso: " + _func.acesso);
}

// Desliga a tesoura
// CÓDIGO NOVO (Restaura a tela inteira)
gpu_set_scissor(0, 0, room_width, room_height);

draw_set_alpha(1.0);