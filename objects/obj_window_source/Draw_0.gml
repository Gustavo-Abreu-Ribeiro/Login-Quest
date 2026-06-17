draw_set_alpha(image_alpha);

// 1. Chama o Pai (Moldura e Barra)
event_inherited();

// 2. Medidas da tela interna
var _pad = 6;
var _start_x = floor(x) + _pad;
var _start_y = floor(y) + top_bar_height + _pad + 2;
var _inner_w = win_width - (_pad * 2);
var _inner_h = win_height - top_bar_height - (_pad * 2) - 4;

draw_set_color(make_color_rgb(30, 30, 30));
draw_rectangle(_start_x, _start_y, _start_x + _inner_w, _start_y + _inner_h, false);
draw_set_color(c_dkgray);
draw_rectangle(_start_x, _start_y, _start_x + _inner_w, _start_y + _inner_h, true);

// ==========================================
// 3. VARIÁVEIS DO BANCO (Puxando dados do Pai)
// ==========================================
var _ip = "0.0.0.0";
var _mail = "desconhecido";
var _data = "00/00/0000 00:00";
var _corpo = "..."; // Receberá o texto do e-mail

if (variable_instance_exists(id, "my_parent_email") && instance_exists(my_parent_email)) {
    var _ref = my_parent_email.meus_dados;
    _ip = _ref.ip_alvo;
    _mail = _ref.email_alvo;
    _corpo = _ref.corpo; // PUXA O CORPO DO E-MAIL AQUI!
    
    if (variable_struct_exists(_ref, "data_envio")) {
        _data = _ref.data_envio;
    }
}

// ==========================================
// 4. O MARCA-TEXTO (Dinâmico e Alinhado)
// ==========================================
draw_set_font(fnt_pixel);

// Lista de textos para medição (IP, Data, E-mail)
var _tamanhos_texto = ["[" + _ip + "]", _data, "<" + _mail + ">"]; 

for (var i = 0; i < array_length(evidencias); i++) {
    var _ev = evidencias[i];
    if (_ev[6]) {
        draw_set_color(c_yellow);
        draw_set_alpha(0.3 * image_alpha);
        
        var _x_inicial = _start_x + 6;
        var _x_final = _x_inicial + string_width(_tamanhos_texto[i]);
        
        // Mantém a altura fixa ajustada (-2 pixels como pedido)
        var _y_inicial = _start_y + _ev[2] + 2; 
        var _y_final = _start_y + _ev[2] + _ev[4]; 
        
        draw_rectangle(_x_inicial, _y_inicial, _x_final, _y_final, false);
        draw_set_alpha(image_alpha);
    }
}

// ==========================================
// 5. O TEXTO DO CÓDIGO FONTE (HTML SINCRONIZADO)
// ==========================================
draw_set_color(make_color_rgb(33, 173, 20)); 

// Montagem do Header (Sua estrutura de quebra de linha)
var _header = "Received: from mail.server.com\n[" + _ip + "]\n";
_header += "Date:\n" + _data + "\n";
_header += "Return-Path:\n<" + _mail + ">";

// Montagem do HTML correspondendo ao corpo do e-mail
var _html = "<html><body>\n";
_html += "  <p>" + _corpo + "</p>\n"; // O HTML agora mostra o que está no e-mail!
_html += "  <a href='http://external-link.net/login'>CLICK HERE</a>\n";
_html += "</body></html>";

// Desenha com espaçamento 12
draw_text_ext(_start_x + 6, _start_y + 6, _header + "\n------------------------\n" + _html, 12, _inner_w - 12);

// ==========================================
// 6. BOTÃO GRAVAR
// ==========================================
var _btn_w = 80; var _btn_h = 20;
var _bx = _start_x + _inner_w - _btn_w - 6; 
var _by = _start_y + _inner_h - _btn_h - 6;

var _h = is_top_window && point_in_rectangle(mouse_x, mouse_y, _bx, _by, _bx + _btn_w, _by + _btn_h);
draw_set_color(_h ? make_color_rgb(100, 200, 100) : make_color_rgb(50, 150, 50));
draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, false);
draw_set_color(c_white);
draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, true);

draw_set_halign(fa_center);
draw_text(_bx + (_btn_w / 2), _by + 4, "GRAVAR");
draw_set_halign(fa_left); 

draw_set_alpha(1.0);