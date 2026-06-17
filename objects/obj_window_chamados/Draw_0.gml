draw_set_alpha(image_alpha);
event_inherited(); // Desenha a moldura do pai

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

draw_set_font(fnt_pixel);
draw_set_color(c_black);
draw_text(_sx, _sy, "Tickets Pendentes: " + string(array_length(global.chamados)));

var _list_y = _sy + 20;

// Se não houver mais chamados
if (array_length(global.chamados) == 0) {
    draw_set_color(c_dkgray);
    draw_text(_sx, _list_y + 10, "Nenhum chamado pendente.");
} else {
    // Desenha cada chamado como uma "linha" clicável
    for (var i = 0; i < array_length(global.chamados); i++) {
        var _ticket = global.chamados[i];
        var _item_y = _list_y + (i * 35); // Espaçamento entre os tickets
        
        // Efeito de Hover (passar o rato por cima)
        var _hover = is_top_window && point_in_rectangle(mouse_x, mouse_y, _sx, _item_y, _sx + _inner_w, _item_y + 30);
        
        draw_set_color(_hover ? make_color_rgb(220, 220, 220) : c_white);
        draw_rectangle(_sx, _item_y, _sx + _inner_w, _item_y + 30, false);
        
        draw_set_color(c_dkgray);
        draw_rectangle(_sx, _item_y, _sx + _inner_w, _item_y + 30, true);
        
        draw_set_color(c_black);
        draw_text(_sx + 4, _item_y + 4, "ID #" + string(_ticket.id) + " - Redefinicao");
        draw_set_color(make_color_rgb(50, 50, 150)); // Azul escuro para o nome
        draw_text(_sx + 4, _item_y + 16, _ticket.usuario);
    }
}
draw_set_alpha(1.0);