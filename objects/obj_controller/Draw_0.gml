// Exibe o progresso do dia no canto superior esquerdo da tela
draw_set_font(fnt_pixel);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _tarefas_feitas = array_length(global.emails_avaliados);
draw_text(10, 10, "Dia: " + string(global.game_day));
draw_text(10, 22, "Tarefas do Turno: " + string(_tarefas_feitas) + " / " + string(global.meta_diaria));