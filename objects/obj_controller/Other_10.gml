// ==========================================
// 1. LIMPEZA MATINAL DAS MESAS
// ==========================================
global.inbox = [];
global.chamados = [];
global.logs_do_dia = [];
global.mensagens_pendentes = [];
global.emails_avaliados = [];

fila_emails = [];
fila_chamados = [];
fila_logs = [];
fila_chat = [];

global.meta_diaria = 0; 

// ==========================================
// 2. SISTEMA DE COTAS DINÂMICAS (DIFICULDADE)
// ==========================================
var _meta_emails = 6;
var _meta_chamados = 0;
var _meta_logs = 0;
var _meta_chat = 0;

if (global.game_day == 2) { _meta_emails = 8; }
if (global.game_day == 3) { _meta_emails = 6; _meta_chamados = 5; } 
if (global.game_day == 4) { _meta_emails = 8; _meta_chamados = 7; } 
if (global.game_day >= 5) { _meta_emails = 5; _meta_chamados = 5; _meta_logs = 2; _meta_chat = 2; } // 14 Tarefas de 4 tipos!

var _tarefas_mistas = []; 
// ==========================================
// 3. SORTEIO DE E-MAILS (Reciclagem Anti-Repetição)
// ==========================================
var _emails_disponiveis = [];

// Puxa os e-mails novos do dia
for (var i = 0; i < array_length(global.db_emails); i++) {
    if (!global.db_emails[i].usado && global.db_emails[i].level <= global.game_day) {
        array_push(_emails_disponiveis, global.db_emails[i]);
    }
}

// Se faltar e-mail para a meta, recicla APENAS os genéricos (is_story == false)
if (array_length(_emails_disponiveis) < _meta_emails) {
    for (var i = 0; i < array_length(global.db_emails); i++) {
        var _em = global.db_emails[i];
        if (_em.usado && _em.level <= global.game_day && !_em.is_story) {
            array_push(_emails_disponiveis, _em);
        }
    }
}

_emails_disponiveis = array_shuffle(_emails_disponiveis);
for (var i = 0; i < min(_meta_emails, array_length(_emails_disponiveis)); i++) {
    _emails_disponiveis[i].usado = true;
    var _clone = json_parse(json_stringify(_emails_disponiveis[i]));
    _clone.lido = false;
    array_push(_tarefas_mistas, { tipo: "email", dados: _clone });
}

// ==========================================
// 4. SORTEIO DE CHAMADOS
// ==========================================
if (_meta_chamados > 0) {
    var _chamados_disp = [];
    for (var i = 0; i < array_length(global.db_chamados); i++) {
        if (global.db_chamados[i].level <= global.game_day) array_push(_chamados_disp, global.db_chamados[i]);
    }
    _chamados_disp = array_shuffle(_chamados_disp);
    for (var i = 0; i < min(_meta_chamados, array_length(_chamados_disp)); i++) {
        array_push(_tarefas_mistas, { tipo: "chamado", dados: json_parse(json_stringify(_chamados_disp[i])) });
    }
}

// ==========================================
// 5. SORTEIO DE LOGS E CHAT (DIA 5+)
// ==========================================
if (_meta_logs > 0) {
    var _logs_disp = array_shuffle(global.db_logs); // Logs não se esgotam
    for (var i = 0; i < min(_meta_logs, array_length(_logs_disp)); i++) {
        array_push(_tarefas_mistas, { tipo: "log", dados: json_parse(json_stringify(_logs_disp[i])) });
    }
}

if (_meta_chat > 0) {
    var _chat_disp = array_shuffle(global.db_chat); // Mensagens não se esgotam
    for (var i = 0; i < min(_meta_chat, array_length(_chat_disp)); i++) {
        array_push(_tarefas_mistas, { tipo: "chat", dados: json_parse(json_stringify(_chat_disp[i])) });
    }
}

// ==========================================
// 6. AGENDAMENTO MATEMÁTICO GARANTIDO
// ==========================================
_tarefas_mistas = array_shuffle(_tarefas_mistas);
var _qtd_total = array_length(_tarefas_mistas);

// A meta vira estritamente o que foi carregado no baralho
global.meta_diaria = _qtd_total;

if (_qtd_total > 0) {
    var _hora_inicio = 9 * 60; // Começa a entregar às 09:00
    var _hora_ultimo_spawn = 15.5 * 60; // 15:30 (Última entrega obrigatória)
    var _janela_de_entregas = _hora_ultimo_spawn - _hora_inicio;
    
    // Divide o tempo perfeitamente para preencher do início ao fim
    // O "- 1" garante que o primeiro item caia às 09h00 e o último exatamente às 15h30.
    var _divisor = (_qtd_total > 1) ? (_qtd_total - 1) : 1;
    var _intervalo_base = _janela_de_entregas / _divisor; 

    show_debug_message("--- CRONOGRAMA DO DIA " + string(global.game_day) + " ---");

    for (var i = 0; i < _qtd_total; i++) {
        var _item = _tarefas_mistas[i].dados;
        var _tipo = _tarefas_mistas[i].tipo;
        
        // Posição cravada no tempo (sem variações aleatórias que buguem o final do dia)
        _item.minuto_spawn = _hora_inicio + round(i * _intervalo_base);
        
        // Guarda na gaveta certa esperando o relógio bater
        if (_tipo == "email") array_push(fila_emails, _item);
        else if (_tipo == "chamado") array_push(fila_chamados, _item);
        else if (_tipo == "log") array_push(fila_logs, _item);
        else if (_tipo == "chat") array_push(fila_chat, _item);
        
        // ==========================================
        // MODO DEBUG: X-RAY PARA VOCÊ (O DESENVOLVEDOR)
        // ==========================================
        var _h = floor(_item.minuto_spawn / 60);
        var _m = _item.minuto_spawn % 60;
        var _hora_formatada = string(_h) + ":" + (_m < 10 ? "0" : "") + string(_m);
        
        // Isso vai aparecer no seu console (Output) do GameMaker para você validar os horários!
        show_debug_message("-> " + _hora_formatada + " | Spawn de " + string_upper(_tipo));
    }
    show_debug_message("----------------------------------");
}

// ==========================================
// 8. CONTROLO DO TUTORIAL E INÍCIO DO DIA
// ==========================================
if (global.game_day == 1) {
    // Trava o relógio e invoca a sobreposição de Tutorial
    expediente_ativo = false; 
    instance_create_depth(0, 0, -999999, obj_tutorial);
} else {
    // Nos outros dias, o expediente começa normalmente às 09:00
    hora_atual_minutos = 9 * 60;
    expediente_ativo = true;
}