// 0. O ESCUDO DE OPACIDADE (Impede que herde bugs de outras janelas)
// ESCUDO ANTI-BUGS: Garante que a barra seja sempre opaca e visível
draw_set_alpha(1.0);
gpu_set_blendmode(bm_normal); // <--- A CORREÇÃO É AQUI! Use "gpu_"
depth = -99999; // Força ela a ficar na frente de qualquer outra coisa

// Se estiver oculta pelo relatório, não desenha nada
if (!visible) exit;

var _bar_y = room_height - bar_height;
// ... (o resto do seu código pode continuar exatamente igual!)
var _btn_size = 22; 
var _pad = 6;
var _x_offset = 6;

// 1. Fundo da Barra
draw_set_color(make_color_rgb(30, 35, 45));
draw_rectangle(0, _bar_y, room_width, room_height, false);
draw_set_color(make_color_rgb(60, 70, 90));
draw_line(0, _bar_y, room_width, _bar_y);

var _count = 0;
var _tooltip_text = "";
var _tooltip_x = 0;

for (var i = 0; i < instance_number(obj_window_parent); i++) {
    var _win = instance_find(obj_window_parent, i);
    
    if (_win.title != "") {
        var _bx = _x_offset + (_count * (_btn_size + _pad));
        var _by = _bar_y + 1;
        
        var _hover = point_in_rectangle(mouse_x, mouse_y, _bx, _by, _bx + _btn_size, _by + _btn_size);
        
        if (_hover) {
            _tooltip_text = _win.title;
            _tooltip_x = _bx + (_btn_size / 2);
        }
        
        // Cor do Fundo do Botão
        if (_win.visible && _win.is_top_window) draw_set_color(make_color_rgb(100, 110, 140)); // Ativo
        else if (_hover) draw_set_color(make_color_rgb(70, 80, 100)); // Hover
        else draw_set_color(make_color_rgb(45, 55, 70)); // Inativo
        
        draw_rectangle(_bx, _by, _bx + _btn_size, _by + _btn_size, false);
        
        // ==========================================
        // 2. DECIDE O QUE DESENHAR (Sprite ou Código)
        // ==========================================
        var _spr_para_desenhar = -1;
        var _desenhar_lupa = false;
        
        // Pega o nome real do objeto em texto (protege contra erros de compilação)
        var _nome_obj = object_get_name(_win.object_index);
        
        // --- ASSOCIA OS SPRITES ---
        if (_nome_obj == "obj_window_inbox" || _nome_obj == "obj_window_email") _spr_para_desenhar = spr_icon_email;
        else if (_nome_obj == "obj_window_scanner") _spr_para_desenhar = spr_scanner;
        else if (_nome_obj == "obj_window_logs") _spr_para_desenhar = spr_logs;
        else if (_nome_obj == "obj_window_chamados") _spr_para_desenhar = spr_chamados;
        else if (_nome_obj == "obj_window_manual") _spr_para_desenhar = spr_icon_manual;
        else if (_nome_obj == "obj_window_db" || _win.title == "Database") _spr_para_desenhar = spr_db; // <--- SEU spr_db AQUI!
        
        // --- DEFINE QUEM USA A LUPA ---
        if (_nome_obj == "obj_window_source" || string_pos("Controle de Acesso", _win.title) > 0 || string_pos("Security", _win.title) > 0) {
            _desenhar_lupa = true;
        }
        
        // --- RENDERIZA O ÍCONE FINAL ---
        if (_spr_para_desenhar != -1) {
            // Estica o Sprite oficial do jogo
            draw_sprite_stretched(_spr_para_desenhar, 0, _bx + 2, _by + 2, _btn_size - 4, _btn_size - 4);
        } 
        else {
            var _ix = _bx + 3;
            var _iy = _by + 3;
            var _iw = _btn_size - 6;
            var _ih = _btn_size - 6;
            
            draw_set_color(c_white);
            
            // A. Desenho da Lupa
            if (_desenhar_lupa) {
                draw_circle(_ix + (_iw / 2) - 1, _iy + (_ih / 2) - 1, 4, true); // Aro
                draw_line_width(_ix + _iw - 4, _iy + _ih - 4, _ix + _iw - 1, _iy + _ih - 1, 2); // Cabo
            }
            // B. Desenho Genérico (Documento) para qualquer outra janela futura não mapeada
            else {
                draw_rectangle(_ix + 1, _iy + 1, _ix + _iw - 1, _iy + _ih - 1, false);
                draw_set_color(c_black);
                draw_line(_ix + _iw - 4, _iy + 1, _ix + _iw - 1, _iy + 4);
                draw_line(_ix + _iw - 4, _iy + 1, _ix + _iw - 4, _iy + 4);
                draw_line(_ix + _iw - 4, _iy + 4, _ix + _iw - 1, _iy + 4);
            }
        }
        
        // 3. Sombra de Minimizado
        if (!_win.visible) {
            draw_set_color(c_black);
            draw_set_alpha(0.5);
            draw_rectangle(_bx, _by, _bx + _btn_size, _by + _btn_size, false);
            draw_set_alpha(1.0);
        }
        
        _count++;
    }
}

// 4. BALÃO DE TEXTO FLUTUANTE (Tooltip)
if (_tooltip_text != "") {
    draw_set_font(fnt_pixel);
    var _tw = string_width(_tooltip_text) + 12;
    var _th = string_height(_tooltip_text) + 6;
    var _tx = _tooltip_x - (_tw / 2);
    var _ty = _bar_y - _th - 6; 
    
    if (_tx < 2) _tx = 2; 
    
    draw_set_color(make_color_rgb(15, 20, 25));
    draw_rectangle(_tx, _ty, _tx + _tw, _ty + _th, false);
    draw_set_color(make_color_rgb(100, 110, 130));
    draw_rectangle(_tx, _ty, _tx + _tw, _ty + _th, true);
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_tx + 6, _ty + 3, _tooltip_text);
}
// ==========================================
// RELÓGIO DO SISTEMA NO CANTO DIREITO
// ==========================================
var _h = floor(obj_controller.hora_atual_minutos / 60);
var _m = floor(obj_controller.hora_atual_minutos mod 60);

// Formatação para sempre ter dois dígitos (ex: 09:05 ao invés de 9:5)
var _str_h = string(_h); if (string_length(_str_h) < 2) _str_h = "0" + _str_h;
var _str_m = string(_m); if (string_length(_str_m) < 2) _str_m = "0" + _str_m;
var _txt_relogio = _str_h + ":" + _str_m;

// Desenha no canto inferior direito
draw_set_font(fnt_pixel);
draw_set_color(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_middle);

draw_text(room_width - 15, _bar_y + (bar_height / 2), _txt_relogio);

// Reseta o alinhamento para não bugar o resto do jogo
draw_set_halign(fa_left);
draw_set_valign(fa_top);