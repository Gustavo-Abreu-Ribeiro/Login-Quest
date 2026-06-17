event_inherited();
win_width = 340;
win_height = 280;
title = "Chat Interno - CyProtect";

// Carrega a primeira mensagem da lista automaticamente, se existir
meus_dados = noone;
if (array_length(global.mensagens_pendentes) > 0) {
    meus_dados = global.mensagens_pendentes[0];
}