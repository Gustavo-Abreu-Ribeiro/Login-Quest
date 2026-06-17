draw_set_alpha(image_alpha);
event_inherited();

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);
draw_set_font(fnt_pixel);

// --- CABEÇALHO ---
draw_set_color(c_black);
draw_set_halign(fa_left);
draw_text(_sx, _sy, "RELATORIO DE TURNO - DIA " + string(global.game_day));
draw_line(_sx, _sy + 18, _sx + _inner_w, _sy + 18);

// --- SURFACE DA LISTA (SCROLL) ---
var _scroll_area_h = win_height - 110; 
var _total_tarefas = array_length(global.emails_avaliados);
var _altura_lista = _total_tarefas * 16; 

var _max_scroll = max(0, _altura_lista - _scroll_area_h);
scroll_y = clamp(scroll_y, -_max_scroll, 0);

if (!surface_exists(surf_lista)) surf_lista = surface_create(_inner_w, _scroll_area_h);

surface_set_target(surf_lista);
draw_clear_alpha(c_black, 0);

var _linha_y = scroll_y + 2;

for (var i = 0; i < _total_tarefas; i++) {
    var _reg = global.emails_avaliados[i];
    var _acao = _reg.acao_jogador;
    var _ameaca = _reg.era_ameaca;
    var _acertou = false;
    
    // 1. O "Radar" Inteligente (converte tudo para minúsculas para facilitar a busca)
    var _acao_low = string_lower(_acao);
    
    // Procura pedaços de palavras. Assim "Bloqueou", "Bloqueou Acesso" ou "Negou" funcionam iguais!
    var _foi_positivo = (string_pos("aprov", _acao_low) != 0 || string_pos("liber", _acao_low) != 0 || string_pos("permit", _acao_low) != 0 || string_pos("autoriz", _acao_low) != 0);
    var _foi_negativo = (string_pos("bloque", _acao_low) != 0 || string_pos("isol", _acao_low) != 0 || string_pos("neg", _acao_low) != 0 || string_pos("recus", _acao_low) != 0);
    
    // 2. A Lógica Universal (Serve para E-mails, Senhas, Pastas e IP)
    if (_foi_positivo && _ameaca == false) _acertou = true;
    if (_foi_negativo && _ameaca == true) _acertou = true;
    
    // Regras Absolutas
    if (string_pos("+", _acao) != 0) _acertou = true; // Bônus é sempre acerto
    if (_acao_low == "ignorou") _acertou = false;     // Abandonar tarefa é sempre erro

    // 3. Justificativas Abrangentes (Faz sentido para Cyber Security e Suporte TI)
    var _motivo = _ameaca ? "(Era Inseguro/Ameaca)" : "(Era Seguro/Legitimo)";
    
    if (string_pos("+", _acao) != 0) _motivo = "(Bonus)";
    if (_acao_low == "ignorou") _motivo = "(Abandonada)";

    // ... (DAQUI PARA BAIXO O SEU CÓDIGO DE DESENHAR O TEXTO CONTINUA IGUAL)
    var _assunto_curto = string_copy(_reg.assunto, 1, 16);
    if (string_length(_reg.assunto) > 16) _assunto_curto += "..";
    var _txt_acao = _assunto_curto + " | " + _acao;
    
    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_text(0, _linha_y, _txt_acao);
    
    draw_set_halign(fa_right);
    if (_acertou) {
        draw_set_color(make_color_rgb(0, 150, 0)); 
        draw_text(_inner_w, _linha_y, "ACERTOU!");
    } else {
        draw_set_color(c_red); 
        draw_text(_inner_w, _linha_y, "ERRO! " + _motivo);
    }
    _linha_y += 16; 
}
surface_reset_target();

// Desenha a lista rolável na tela
draw_surface(surf_lista, _sx, _sy + 25);
draw_set_halign(fa_left);

// --- RODAPÉ DE PONTUAÇÃO E BOTÃO ---
var _rodape_y = floor(y) + win_height - 65; 
draw_set_color(c_black);
draw_line(_sx, _rodape_y, _sx + _inner_w, _rodape_y);
draw_text(_sx, _rodape_y + 5, "Reputacao: " + string(global.reputation) + "%");
draw_text(_sx + 150, _rodape_y + 5, "Score: " + string(global.player_score) + " pts");

var _btn_w = 120;
var _btn_h = 24;
var _btn_x = (_sx + (_inner_w / 2)) - (_btn_w / 2);
var _btn_y = floor(y) + win_height - 35;
var _hover = is_top_window && point_in_rectangle(mouse_x, mouse_y, _btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h);

draw_set_color(_hover ? make_color_rgb(100, 200, 100) : make_color_rgb(50, 150, 50));
draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, false);
draw_set_color(c_black);
draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, true);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(_btn_x + (_btn_w / 2), _btn_y + 5, "AVANCAR DIA");
draw_set_halign(fa_left);

draw_set_alpha(1.0);