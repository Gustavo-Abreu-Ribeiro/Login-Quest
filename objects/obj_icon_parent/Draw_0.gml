if (global.game_day >= dia_desbloqueio) {
    // ==========================================
    // 1. CAIXA DE SELEÇÃO (Fundo Azul)
    // ==========================================
    if (selected) {
        draw_set_alpha(0.4); // Deixa 40% transparente
        draw_set_color(make_color_rgb(0, 0, 170)); // Azul clássico
        
        // Desenha um quadrado levemente maior que o sprite
        draw_rectangle(x - 2, y - 2, x + sprite_width + 2, y + sprite_height + 2, false);
        
        draw_set_alpha(1.0); // OBRIGATÓRIO: Retorna a transparência ao normal!
    }

    // ==========================================
    // 2. DESENHO DO ÍCONE
    // ==========================================
    draw_self();

    // ==========================================
    // 3. NOME DO ÍCONE (Fonte Menor e Ajustada)
    // ==========================================
    if (variable_instance_exists(id, "icon_name")) {
        draw_set_font(fnt_pixel_pequena); // Usa a fonte menor que você criou
        draw_set_color(c_white);
        draw_set_halign(fa_center); // Centraliza o texto no meio do ícone
        draw_set_valign(fa_top);

        // Calcula o meio (X) e a base colada no ícone (Y)
        var _cx = floor(x + (sprite_width / 2));
        var _cy = floor(y + sprite_height); // Sem o +4 para ficar mais colado
        
        draw_text(_cx, _cy, icon_name);
        
        // Reseta os alinhamentos e cores para o padrão do jogo
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
    }
}