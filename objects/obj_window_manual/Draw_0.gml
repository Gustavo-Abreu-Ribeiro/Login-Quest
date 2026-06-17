draw_set_alpha(image_alpha);
event_inherited(); 

var _pad = 10;
var _sx = floor(x) + _pad;
var _sy = floor(y) + top_bar_height + _pad;
var _inner_w = win_width - (_pad * 2);

// ==========================================
// CABEÇALHO DA PÁGINA (Fixo)
// ==========================================
draw_set_color(make_color_rgb(40, 50, 80)); 
draw_rectangle(_sx - 4, _sy - 2, _sx + _inner_w + 4, _sy + 14, false);

draw_set_color(c_white);
draw_set_font(fnt_pixel);
var _secao_nome = (pagina_atual == "indice") ? "ÍNDICE GERAL" : "GUIA DE SEGURANÇA";
draw_text(_sx + 2, _sy, _secao_nome);

draw_set_color(c_dkgray);
draw_line(_sx - 4, _sy + 18, _sx + _inner_w + 4, _sy + 18);

var _content_y = _sy + 25;

// ==========================================
// CONTEÚDO: ÍNDICE DINÂMICO
// ==========================================
if (pagina_atual == "indice") {
    var _row_h = 22;
    
    // Lista de tópicos dinâmicos
    var _topicos = [];
    array_push(_topicos, "1. Triagem (Basico)");
    if (global.game_day >= 2) array_push(_topicos, "2. Inspecao de IPs");
    if (global.game_day >= 3) array_push(_topicos, "3. Acessos e DB");
    if (global.game_day >= 4) array_push(_topicos, "4. Scanner (Hashes)");
    if (global.game_day >= 5) array_push(_topicos, "5. Logs da Rede");
    
    for (var i = 0; i < array_length(_topicos); i++) {
        var _item_y = _content_y + (i * _row_h);
        var _hover = is_top_window && point_in_rectangle(mouse_x, mouse_y, _sx, _item_y, _sx + _inner_w, _item_y + _row_h);
        
        if (_hover) {
            draw_set_color(make_color_rgb(220, 220, 220));
            draw_rectangle(_sx - 2, _item_y - 2, _sx + _inner_w, _item_y + 16, false);
            draw_set_color(c_black);
        } else {
            draw_set_color(make_color_rgb(50, 50, 50));
        }
        
        draw_text(_sx, _item_y, "> " + _topicos[i]);
    }
}

// ==========================================
// CONTEÚDO: PÁGINAS DO MANUAL
// ==========================================
else {
    // 1. Botão Voltar (Fixo)
    var _hover_v = is_top_window && point_in_rectangle(mouse_x, mouse_y, _sx, _content_y, _sx + 70, _content_y + 16);
    draw_set_color(_hover_v ? c_black : c_dkgray);
    draw_text(_sx, _content_y, "[< VOLTAR]");

    // 2. Textos do Tutorial Detalhados (PT-BR)
    var _tutorial = "";
    
    if (pagina_atual == "pagina_1") {
        _tutorial = "DIA 1: TRIAGEM DE COMUNICAÇÕES\n\nVocê é a primeira barreira contra engenharia social.\n\n[ COMO PROCEDER ]\n1. Leia atentamente o REMETENTE e o ASSUNTO.\n2. Invasores usam domínios falsos trocando letras por números (ex: amaz0n, cypr0tect) ou oferecem prêmios absurdos.\n3. Arraste a janela de e-mails seguros para a PASTA SEGURA.\n4. Arraste e-mails de Phishing para o FIREWALL.\n\nATENÇÃO: Um e-mail malicioso aprovado derruba nossa reputação no mercado!";
    } 
    else if (pagina_atual == "pagina_2") {
        _tutorial = "DIA 2: INSPEÇÃO DE FONTES\n\nAtaques avançados conseguem falsificar o nome do remetente.\n\n[ COMO PROCEDER ]\n1. Clique no botão '?' no rodapé do e-mail para abrir o INSPETOR.\n2. Verifique o campo IP_ALVO.\n\n[ REDE CONFIÁVEL ]\n- Matriz Local: 10.0.X.X\n- Filiais Internas: 172.16.X.X até 172.31.X.X\n\nQualquer IP que comece diferente (ex: 185.X, 200.X, 198.X) é uma invasão externa. Jogue no Firewall imediatamente!";
    }
    else if (pagina_atual == "pagina_3") {
        _tutorial = "DIA 3: DATA BASE E PRIVILÉGIOS\n\nControle quem acessa o quê na infraestrutura.\n\n[ COMO PROCEDER ]\n1. Acompanhe os alertas e abra os apps 'Data Base' e 'Chamados'.\n\n2. PEDIDOS DE SENHA: Exija senhas fortes (letras, números e símbolos especiais como @, #, !). Senhas fracas como '1234' ou 'senha' devem ter o acesso Negado.\n\n3. PEDIDOS DE PASTA: Verifique na Data Base se o cargo do funcionário condiz com a pasta. Um estagiário não deve acessar Balanços ou Código Fonte. Negue pedidos incompatíveis.";
    }
    else if (pagina_atual == "pagina_4") {
        _tutorial = "DIA 4: ANÁLISE DE MALWARE\n\nInterceptação de arquivos infectados anexados aos e-mails.\n\n[ COMO PROCEDER ]\n1. E-mails com [ANEXO] no texto devem ser arrastados para o aplicativo 'Scanner MD5'.\n2. Aguarde a extração da assinatura Hash do arquivo.\n\n[ HASHES SEGUROS ]\n- Atualizador de Sistema: A1B2C3D4\n- Documentos e Relatórios: F8E9D0C1\n\nSe o Scanner retornar qualquer Hash diferente destas (em arquivos .exe, .zip ou .scr), considere como MALWARE. Clique em ISOLAR no painel do scanner.";
    }
    else if (pagina_atual == "pagina_5") {
        _tutorial = "DIA 5: TERMINAL DE LOGS E CHAT\n\nMonitoramento em tempo real do tráfego interno.\n\n[ LOGS DE REDE ]\n- Horário Seguro: 08:00 às 18:00. Bloqueie logins de madrugada.\n- Origem Homologada: BR (Brasil). Bloqueie conexões de países suspeitos (RU, CN, KP).\n\n[ CHAT INTERNO ]\n- A Diretoria ou a equipe de TI NUNCA pedirão senhas ou chaves SSH via chat.\n- Se alguém exigir dados sensíveis usando senso de urgência, é Engenharia Social. Negue a solicitação ou Peça o PIN de segurança.";
    }

    // 3. Renderização com Scroll e Tesoura (Scissor)
    var _view_y = _content_y + 25;
    var _view_h = win_height - (_view_y - y) - 10;
    
    var _texto_altura = string_height_ext(_tutorial, 16, _inner_w - 4);
    manual_max_scroll = max(0, _texto_altura - _view_h + 20);

    gpu_set_scissor(_sx, _view_y, _inner_w, _view_h);
    
    draw_set_color(c_black);
    draw_text_ext(_sx, _view_y - manual_scroll_y, _tutorial, 16, _inner_w - 4);
    
    gpu_set_scissor(0, 0, room_width, room_height);
}

draw_set_alpha(1.0);