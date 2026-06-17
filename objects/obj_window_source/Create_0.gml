event_inherited();

title = "Inspecionar Email";
win_width = 280;  
win_height = 200; // Aumentei 20 pixels na altura para compensar as novas linhas

// ========================================================
// 1. VARIÁVEIS DA AMEAÇA
// ========================================================
var _email_alvo = "diretor_geral@rh-cypr0tect.com.br";
var _ip_alvo = "145.22.40.1";
var _data_alvo = "Hoje, 08:42 AM";

// ========================================================
// 2. CONSTRUINDO O TEXTO (Novo Layout)
// ========================================================
// Colocamos o \n DEPOIS dos rótulos. Assim, as evidências ganham uma linha inteira só pra elas!
raw_header = "Return-Path:\n<" + _email_alvo + ">\nReceived: from\n[" + _ip_alvo + "]\nDate:\n" + _data_alvo;

raw_html = "<div class='email'>\n  <p>Bem-vindo ao sistema.</p>\n  <a href='http://" + _ip_alvo + "/auth'>\n    Fique atento às ameaças.\n  </a>\n</div>";


// ========================================================
// 3. A LISTA DE EVIDÊNCIAS (Alinhada com o draw_text_ext)
// ========================================================
draw_set_font(fnt_pixel); 

var _pad_w = 4;  // Reduzi a gordurinha porque agora as medidas serão mais precisas
var _x_base = 6; // É o "+ 6" que você usa no X do draw_text_ext
var _y_base = 6; // É o "+ 6" que você usa no Y do draw_text_ext

// O SEGREDO: O exato mesmo número que você usa no seu draw_text_ext!
var _sep = 12; 

evidencias = [
    // [Texto, X, Y, Largura, Altura, Ameaça?, Selecionado?]
    
    // 1. Domínio Falso (Linha 1) - Multiplicamos _sep por 1
    [
        _email_alvo, 
        _x_base + string_width("<"),      
        _y_base + (_sep * 1),          
        string_width(_email_alvo) + _pad_w, 
        _sep, // Altura exata da linha
        true, false
    ], 
    
    // 2. IP (Linha 3) - Multiplicamos _sep por 3
    [
        _ip_alvo, 
        _x_base + string_width("["),      
        _y_base + (_sep * 3),          
        string_width(_ip_alvo) + _pad_w, 
        _sep, 
        true, false
    ],        
    
    // 3. Data (Linha 5) - Multiplicamos _sep por 5
    [
        _data_alvo, 
        _x_base,                          
        _y_base + (_sep * 5),          
        string_width(_data_alvo) + _pad_w, 
        _sep, 
        false, false
    ]   
];