draw_set_alpha(image_alpha);
event_inherited();

var _sx = round(x);
var _sy = round(y) + top_bar_height;
var _cx = _sx + (win_width / 2);

draw_set_font(fnt_pixel);
draw_set_halign(fa_center);

if (!scanning) {
    draw_set_color(c_dkgray);
    draw_text(_cx, _sy + 35, "Aguardando anexo...");
    draw_text(_cx, _sy + 55, "(Arraste o e-mail ate aqui)");
} else {
    draw_set_color(c_black);
    var _nome_curto = string_copy(scan_file, 1, 15);
    if (string_length(scan_file) > 15) _nome_curto += "...";
    draw_text(_cx, _sy + 5, "Alvo: " + _nome_curto);
    
    // Barra de Progresso
    var _bar_w = 180;
    var _bx = _cx - (_bar_w / 2);
    draw_set_color(c_black);
    draw_rectangle(_bx, _sy + 25, _bx + _bar_w, _sy + 35, true);
    draw_set_color(make_color_rgb(50, 150, 200));
    draw_rectangle(_bx + 1, _sy + 26, _bx + (_bar_w * (scan_progress / 100)) - 1, _sy + 34, false);

    if (scan_progress < 100) {
        draw_set_color(c_dkgray);
        draw_text(_cx, _sy + 50, "Extraindo assinatura Hash...");
    } else {
        // --- RESULTADO: MOSTRA A HASH E OS BOTÕES ---
        draw_set_color(make_color_rgb(180, 0, 0)); // Vermelho para destacar a Hash
        draw_text(_cx, _sy + 45, "HASH: " + current_hash);
        
        draw_set_color(c_dkgray);
        draw_text(_cx, _sy + 60, "Consulte o Manual!");

        var _by = _sy + 80;
        var _btn_h = 24;

        // Botão [ ISOLAR ] (Vermelho)
        var _hover_iso = (is_top_window && point_in_rectangle(mouse_x, mouse_y, _cx - 100, _by, _cx - 10, _by + _btn_h));
        draw_set_color(_hover_iso ? make_color_rgb(200, 50, 50) : make_color_rgb(150, 30, 30));
        draw_rectangle(_cx - 100, _by, _cx - 10, _by + _btn_h, false);
        draw_set_color(c_white);
        draw_text(_cx - 55, _by + 6, "ISOLAR");
        draw_set_color(c_black);
        draw_rectangle(_cx - 100, _by, _cx - 10, _by + _btn_h, true);

        // Botão [ LIBERAR ] (Verde)
        var _hover_lib = (is_top_window && point_in_rectangle(mouse_x, mouse_y, _cx + 10, _by, _cx + 100, _by + _btn_h));
        draw_set_color(_hover_lib ? make_color_rgb(50, 200, 50) : make_color_rgb(30, 150, 30));
        draw_rectangle(_cx + 10, _by, _cx + 100, _by + _btn_h, false);
        draw_set_color(c_white);
        draw_text(_cx + 55, _by + 6, "LIBERAR");
        draw_set_color(c_black);
        draw_rectangle(_cx + 10, _by, _cx + 100, _by + _btn_h, true);
    }
}

draw_set_halign(fa_left); // Previne bugs no resto do jogo
draw_set_alpha(1.0);