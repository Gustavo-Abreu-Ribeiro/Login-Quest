// OBRIGATÓRIO: Puxa todo o código do pai primeiro
event_inherited();
win_width = 300;
win_height = 200; // Tamanho fixo e elegante
scroll_y = 0;
surf_corpo = -1;  // A variável da nossa "mini-tela"
is_inspected = false; 

// Estrutura que o Controller vai preencher
meus_dados = {
    remetente: "Carregando...",
    assunto: "Carregando...",
    corpo: "Carregando...",
    is_threat: false,
    email_alvo: "",
    ip_alvo: "",
    anexo: ""
};

draw_set_font(fnt_pixel);

var _pad = 6; 
var _start_x = _pad;
var _start_y = top_bar_height + _pad + 2; 

// Array de evidência (Sincronizado com o tamanho da fonte do GameMaker)
evidencias_email = [
    [
        "", // O texto vem dinâmico agora
        _start_x + string_width("De: ") + 4, // X
        _start_y + 4,                        // Y
        100,                                 // Largura (será calculada dinamicamente no Draw/Step)
        12,                                  // Altura
        true, false                          // É ameaça? / Selecionado?
    ]
];