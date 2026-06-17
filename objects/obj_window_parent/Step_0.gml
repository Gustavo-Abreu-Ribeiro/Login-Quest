// ==========================================
// 0. PROTEÇÃO ANTI-CRASH (A Mágica da Herança)
// ==========================================
// Garante que a variável exista para qualquer janela filha antes de tentar lê-la
if (!variable_instance_exists(id, "centralizou")) {
    centralizou = false;
}

// ==========================================
// 1. POSICIONAMENTO EM CASCATA (Cascading)
// ==========================================
if (!centralizou && win_width > 0) {
    // 1. Calcula o centro perfeito da tela (o padrão)
    var _base_x = floor((room_width / 2) - (win_width / 2));
    var _base_y = floor(((room_height - 24) / 2) - (win_height / 2));
    
    // 2. Conta quantas janelas filhas já existem abertas agora
    var _qtd_janelas = instance_number(obj_window_parent) - 1; 
    
    // 3. Desloca 20 pixels (x e y) por janela. O "min" trava em 60 para não sumir da tela!
    var _offset = min(_qtd_janelas * 20, 60);
    
    // 4. Aplica a posição
    x = _base_x + _offset;
    y = _base_y + _offset;
    
    centralizou = true;
}
// ==========================================
// MÁQUINA DE ANIMAÇÕES
// ==========================================
// Se a janela estiver minimizada, ignora todo o código de arrastar e clicar!
if (!visible) exit;

if (anim_state == "opening") {
    image_alpha = lerp(image_alpha, 1, 0.15); // Vai aparecendo suavemente
    if (image_alpha >= 0.99) {
        image_alpha = 1;
        anim_state = "idle"; // Terminou de abrir, agora o jogador pode usar
    }
} 
else if (anim_state == "closing") {
    image_alpha = lerp(image_alpha, 0, 0.2);  // Vai sumindo
    if (image_alpha <= 0.01) instance_destroy();
} 
else if (anim_state == "sucking") {
    // Voa até o destino (Cofre ou Pasta)
    x = lerp(x, dest_x, 0.2);
    y = lerp(y, dest_y, 0.2);
    
    // Encolhe a janela para dar efeito de ser "engolida"
    win_width = lerp(win_width, 10, 0.2);
    win_height = lerp(win_height, 10, 0.2);
    
    // Vai sumindo junto
    image_alpha = lerp(image_alpha, 0, 0.15);
    
    if (image_alpha <= 0.01) instance_destroy();
}

// SE A JANELA ESTIVER ANIMANDO, O JOGADOR NÃO PODE CLICAR NELA!
if (anim_state != "idle") {
    hover_close = false;
    dragging = false;
    exit; // Aborta o resto do código do Step para evitar bugs
}

// --- 1. O RADAR DE HIERARQUIA (Z-ORDER) ---
is_top_window = false;
var _top_id = noone;
var _lowest_depth = 999999;


with (obj_window_parent) {
    if (point_in_rectangle(mouse_x, mouse_y, x, y, x + win_width, y + win_height)) {
        if (depth < _lowest_depth || (depth == _lowest_depth && id > _top_id)) {
            _lowest_depth = depth;
            _top_id = id;
        }
    }
}

if (_top_id == id) {
    is_top_window = true;
}

// --- 2. LÓGICA DO BOTÃO FECHAR ---
var _btn_x = (x + win_width) - close_btn_size - close_btn_padding;
var _btn_y = y + close_btn_padding;

if (is_top_window && point_in_rectangle(mouse_x, mouse_y, _btn_x, _btn_y, _btn_x + close_btn_size, _btn_y + close_btn_size)) {
    hover_close = true; 
    
    if (mouse_check_button_pressed(mb_left)) {
        
        // NOVO: Se a janela fechada for um e-mail, conta como tarefa concluída (Ignorada)
        if (object_index == obj_window_email) {
            var _registro = {
                assunto: meus_dados.assunto,
                era_ameaca: meus_dados.is_threat,
                acao_jogador: "Ignorou"
            };
            array_push(global.emails_avaliados, _registro);
            
            // Pequena punição por deixar um e-mail sem tratamento no SOC
            global.player_score -= 20; 
        }
        
        anim_state = "closing"; 
        exit;
    }
} else {
    hover_close = false; 
}

// --- 3. LÓGICA DE CLIQUE E ARRASTE ---
if (mouse_check_button_pressed(mb_left)) {
    if (is_top_window) {
        depth = -1000; 
        with (obj_window_parent) {
            if (id != other.id) depth += 10; 
        }
        
        if (point_in_rectangle(mouse_x, mouse_y, x, y, x + win_width, y + top_bar_height)) {
            dragging = true;
            // A função floor() "corta" as frações. Impede o sub-pixel rendering.
            offset_x = x - floor(mouse_x);
            offset_y = y - floor(mouse_y);
        }
    }
}

// --- 4. MOVIMENTAÇÃO E JULGAMENTO ---
if (dragging) {
    // Garante que o X e o Y da janela NUNCA sejam números quebrados
    x = floor(mouse_x) + offset_x;
    y = floor(mouse_y) + offset_y;
    
    // Soltar a janela... (O seu código de Firewall continua a partir daqui)
    
    // Soltar a janela... (O resto do seu código de soltar no firewall continua aqui)
    if (mouse_check_button_released(mb_left)) {
        dragging = false; 
        
        show_debug_message("-> Mouse solto!");
        
        if (object_index == obj_window_email) {
            
            show_debug_message("-> A janela é um E-mail válido!");
            
            // ==========================================
            // DESTINO 1: FIREWALL
            // ==========================================
            if (instance_exists(obj_firewall) && point_in_rectangle(mouse_x, mouse_y, obj_firewall.bbox_left, obj_firewall.bbox_top, obj_firewall.bbox_right, obj_firewall.bbox_bottom)) {
                
                show_debug_message("-> Encostou no Firewall!");
                
                var _registro = {
                    assunto: meus_dados.assunto,
                    era_ameaca: meus_dados.is_threat,
                    acao_jogador: "Bloqueou"
                };
                array_push(global.emails_avaliados, _registro);
                
                if (meus_dados.is_threat == true) {
                    global.player_score += 100; 
                } else {
                    global.player_score -= 50;  
                }
                
                if (instance_exists(obj_window_source)) obj_window_source.anim_state = "closing";
                
                anim_state = "sucking";
                dest_x = obj_firewall.x;
                dest_y = obj_firewall.y;
                
            } 
            // ==========================================
            // DESTINO 2: PASTA SEGURA
            // ==========================================
            else if (instance_exists(obj_safe_folder) && point_in_rectangle(mouse_x, mouse_y, obj_safe_folder.bbox_left, obj_safe_folder.bbox_top, obj_safe_folder.bbox_right, obj_safe_folder.bbox_bottom)) {
                
                show_debug_message("-> Encostou na Pasta Segura!");
                
                var _registro = {
                    assunto: meus_dados.assunto,
                    era_ameaca: meus_dados.is_threat,
                    acao_jogador: "Aprovou"
                };
                array_push(global.emails_avaliados, _registro);
                
                if (meus_dados.is_threat == false) {
                    global.player_score += 50;  
                } else {
                    global.player_score -= 100; 
                }
                
                if (instance_exists(obj_window_source)) obj_window_source.anim_state = "closing";
                
                anim_state = "sucking";
                dest_x = obj_safe_folder.x;
                dest_y = obj_safe_folder.y;
            }
            // ==========================================
            // DESTINO 3: SCANNER DE MALWARE
            // ==========================================
            else {
                var _scanner = instance_nearest(mouse_x, mouse_y, obj_window_scanner);
                
                // Se o Scanner existir e o mouse foi solto DENTRO da área dinâmica da janela dele
                if (_scanner != noone && point_in_rectangle(mouse_x, mouse_y, _scanner.x, _scanner.y, _scanner.x + _scanner.win_width, _scanner.y + _scanner.win_height)) {
                    
                    if (variable_struct_exists(meus_dados, "anexo") && meus_dados.anexo != "") {
                        show_debug_message("-> Anexo enviado para o Scanner!");
                        
                        // Alimenta o Scanner com os dados do e-mail
                        _scanner.scanning = true;
                        _scanner.scan_progress = 0;
                        _scanner.scan_file = meus_dados.anexo;
                        _scanner.current_hash = meus_dados.hash;
                        _scanner.scan_threat = meus_dados.is_threat;
						_scanner.scan_assunto = meus_dados.assunto;
                        
                        // Animações de fechar/ser engolido
                        if (instance_exists(obj_window_source)) obj_window_source.anim_state = "closing";
                        
                        anim_state = "sucking";
                        dest_x = _scanner.x + (_scanner.win_width / 2);
                        dest_y = _scanner.y + (_scanner.win_height / 2);
                        
                    } else {
                        show_debug_message("-> Este e-mail não contém anexos.");
                    }
                }
            }
            
        } else {
            show_debug_message("-> ERRO: Esta janela NÃO é o obj_window_email. Ela é: " + object_get_name(object_index));
        }
    }
}
x = round(x);
y = round(y);