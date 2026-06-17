// --- Evento Create do obj_window_parent ---
event_inherited();

dragging = false;
offset_x = 0;
offset_y = 0;
cantralizou = false;
// Ajustando para o seu padrão
win_width = 240;       // Aumentei um pouco (metade da largura da tela)
win_height = 160;      
title = "Janela";
top_bar_height = 12;   // Conforme sua borda de cima

// Botão Fechar (X) - Agora com 8x8
close_btn_size = 8;    
close_btn_padding =5; // Espaçamento para centralizar (12 - 8 = 4 / 2 = 2)
hover_close = false;
is_top_window = false; // Removi o 'var' e coloquei aqui para todos os filhos poderem ler
// --- VARIÁVEIS DE ANIMAÇÃO ---
anim_state = "opening"; // Estados: "opening", "idle", "closing", "sucking"
image_alpha = 0;        // Começa 100% invisível
dest_x = x;             // Coordenadas para onde vai voar
dest_y = y;

// ==========================================
// NASCER SEMPRE NO TOPO (Z-ORDER AUTOMÁTICO)
// ==========================================
// Quando eu (nova janela) nascer, empurro TODAS as outras janelas para trás
with (obj_window_parent) {
    if (id != other.id) {
        depth += 10; 
    }
}

// E eu assumo a posição mais à frente de todas!
depth = -1000;