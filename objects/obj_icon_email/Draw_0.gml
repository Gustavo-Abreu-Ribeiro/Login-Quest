event_inherited()
// Evento Draw do obj_icon_email
// --- No início do Draw do obj_icon_email ---

// Verifica se a Caixa de Entrada já está na tela
if (instance_exists(obj_window_inbox)) {
    // Desenha o ícone escurecido (cinza) para indicar que já está aberto
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_gray, 0.8);
} else {
    draw_self(); // Desenha normal se estiver fechado
}

// ... (Aqui continua o seu código da bolinha vermelha e do número de e-mails)
draw_self(); // Desenha a pastinha / ícone do e-mail normalmente

// 1. Conta os e-mails não lidos
var _nao_lidos = 0;
for (var i = 0; i < array_length(global.inbox); i++) {
    if (global.inbox[i].lido == false) {
        _nao_lidos++;
    }
}

// 2. Desenha a notificação se houver e-mails novos
if (_nao_lidos > 0) {
    var _badge_x = x + sprite_width - 4; // Canto superior direito do ícone
    var _badge_y = y + 4;
    
    // Desenha a bolinha vermelha
    draw_set_color(c_red);
    draw_circle(_badge_x, _badge_y, 8, false);
    
    // Desenha o número de e-mails em branco
    draw_set_color(c_white);
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_badge_x, _badge_y, string(_nao_lidos));
    
    // Reseta alinhamentos
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}