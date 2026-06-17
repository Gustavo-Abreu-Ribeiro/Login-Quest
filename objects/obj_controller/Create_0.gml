// ==========================================
// 1. CONFIGURAÇÃO DE TELA (Resolução Perfeita)
// ==========================================
var _base_w = 480;
var _base_h = 294; // Os 270 originais + 24 da barra de tarefas

// A MÁGICA: Ajusta a Room e a Câmera para não esticar os pixels!
room_width = _base_w;
room_height = _base_h;
camera_set_view_size(view_camera[0], _base_w, _base_h);

gpu_set_texfilter(false); // Mantém a pixel art nítida
window_set_size(_base_w * 4, _base_h * 4);
surface_resize(application_surface, _base_w, _base_h);
alarm[0] = 1;

// ==========================================
// 2. SISTEMA DE TEMPO (O RELÓGIO DA EMPRESA)
// ==========================================
// O expediente vai das 09:00 (540 min) às 17:00 (1020 min)
hora_atual_minutos = 9 * 60; 
hora_fim_minutos = 17 * 60;  
velocidade_tempo = 0.044; 
expediente_ativo = false; 

// A FILA DEVE EXISTIR ANTES DE TUDO
fila_emails = [];
fila_chamados = [];
fila_logs = [];
fila_chat = [];

// ==========================================
// 3. CONFIGURAÇÕES INICIAIS GLOBAIS
// ==========================================
global.game_day = 1;          
global.player_score = 0;      
global.reputation = 100;      

global.inbox = [];              
global.chamados = [];
global.logs_do_dia = [];
global.mensagens_pendentes = [];
global.emails_avaliados = [];   
global.meta_diaria = 0;         

randomize(); // Garante que a aleatoriedade seja diferente a cada vez que abrir o jogo

// ==========================================
// 4. BANCO DE DADOS: E-MAILS (Com is_story)
// ==========================================
global.db_emails = [
    // --- HISTÓRIA (Acontecem só 1 vez na campanha) ---
    { level: 1, usado: false, is_story: true, remetente: "diretoria@cyprotect.com", assunto: "Bem-vindo a equipe", corpo: "Bem-vindo ao SOC da CyProtect. Confiamos em voce para manter nossa rede segura.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.5", data_envio: "14/04 09:30" },
    { level: 1, usado: false, is_story: true, remetente: "rh@cyprotect.com", assunto: "Aprovacao de Viagem", corpo: "Sua folga para a viagem de 4 dias para o Rio de Janeiro foi aprovada no sistema. Aproveite!", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.12", data_envio: "14/04 11:00" },
    { level: 1, usado: false, is_story: true, remetente: "infra@cyprotect.com", assunto: "Cooler Gamdias Boreas", corpo: "Vi no log que voce conseguiu fazer o sistema reconhecer o hardware, mas as temperaturas continuam discrepantes. Ah, e vi que fez o Passo 1 do LED, ja repassei que nao funcionou.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.21", data_envio: "14/04 14:15" },
    { level: 2, usado: false, is_story: true, remetente: "dev-team@cyprotect.com", assunto: "Script GML Interface", corpo: "Subi o script GML para o sistema de scroll e os manuais do Login Quest. Da um pull no repositorio e testa.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.44", data_envio: "15/04 10:20" },
    { level: 2, usado: false, is_story: true, remetente: "academico@udf.edu.br", assunto: "Relatorio de Historia", corpo: "Seu relatorio 'Aula 09/04/2026' sobre a autonomia da Ciencia da Computacao foi recebido com sucesso no portal.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "172.16.1.10", data_envio: "15/04 15:45" },
    { level: 3, usado: false, is_story: true, remetente: "parcerias@nexusflow.net", assunto: "Proposta Edge Computing", corpo: "Temos uma proposta de integracao para distribuicao de assets via delta-updates na OmniAssets. Segue NDA.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.1.50", data_envio: "16/04 14:30" },

    // --- GENÉRICOS / ROTINA (Podem reciclar para preencher cota - is_story: false) ---
    { level: 1, usado: false, is_story: false, remetente: "rh@cyprotect.com", assunto: "Atualizacao de Cadastro", corpo: "Por favor, acesse o sistema interno para atualizar seus dados cadastrais deste ano.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.12", data_envio: "14/04 09:00" },
    { level: 2, usado: false, is_story: false, remetente: "sistema@cyprotect.com", assunto: "Backup Concluido", corpo: "O backup semanal dos servidores foi concluido com sucesso as 03:00 AM.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.5", data_envio: "15/04 03:00" },
    { level: 2, usado: false, is_story: false, remetente: "no-reply@cyprotect.com", assunto: "Relatorio de Ponto", corpo: "Seu relatorio mensal de horas ja esta disponivel no portal.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "172.16.0.4", data_envio: "15/04 16:00" }, 
    
    // --- AMEAÇAS PHISHING (Recicláveis) ---
    { level: 1, usado: false, is_story: false, remetente: "suporte-ti@cypr0tect.com", assunto: "URGENTE: Senha Expirada", corpo: "Sua senha expira em 2 horas. Clique aqui para redefinir imediatamente ou sua conta sera apagada.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "185.10.2.44", data_envio: "14/04 09:15" }, 
    { level: 1, usado: false, is_story: false, remetente: "promocoes@amaz0n-store.net", assunto: "Voce ganhou um iPhone!", corpo: "Parabens! Voce foi o funcionario sorteado da semana. Pague apenas o frete.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "200.15.40.1", data_envio: "14/04 10:00" },
    { level: 1, usado: false, is_story: false, remetente: "secretaria@udf-academico.br.com", assunto: "Pendencia de Engenharia", corpo: "Prezado aluno, sua matricula no curso de Engenharia de Software foi suspensa. Regularize no link.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "198.51.100.1", data_envio: "14/04 13:45" },
    { level: 2, usado: false, is_story: false, remetente: "ceo@cyprotect.com", assunto: "Transferencia Confidencial", corpo: "Preciso que libere um pagamento urgente para um novo fornecedor. Nao comente com ninguem.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "185.22.40.1", data_envio: "15/04 08:45" }, 
    { level: 2, usado: false, is_story: false, remetente: "financeiro@cyprotect.com", assunto: "Nota Fiscal Pendente", corpo: "Segue a NF-e para validacao e pagamento imediato. Evite multas.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "177.40.12.9", data_envio: "15/04 11:20" }, 

    // --- ANEXOS E MALWARES (Level 4+) ---
    { level: 4, usado: false, is_story: false, remetente: "financeiro@cyprotect.com", assunto: "Relatorio de Custos", corpo: "Segue o relatorio de custos do trimestre para analise da diretoria.", is_threat: false, email_alvo: "voce@cyprotect.com", ip_alvo: "10.0.0.22", data_envio: "17/04 11:00", anexo: "Custos_Q3.pdf", hash: "A1B2C3D4" }, 
    { level: 4, usado: false, is_story: false, remetente: "candidato@mail.com", assunto: "Curriculo - Vaga TI", corpo: "Ola, segue meu curriculo para a vaga de analista de seguranca.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "45.33.12.8", data_envio: "17/04 11:30", anexo: "Curriculo_CV.exe", hash: "E99A18C4" },
    { level: 4, usado: false, is_story: true, remetente: "comite@sbgames2026.org", assunto: "Revisao Short Paper", corpo: "Segue o PDF com a avaliacao do juri tecnico para o evento.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "188.16.2.10", data_envio: "17/04 16:40", anexo: "SBGames_Review.scr", hash: "D4D4F99A" },
    { level: 4, usado: false, is_story: false, remetente: "ryu-dev@emulador.net", assunto: "Patch de Firmware", corpo: "Saiu a atualizacao para corrigir os erros de OS logs.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "88.21.34.11", data_envio: "17/04 17:05", anexo: "Ryujinx_Fix.exe", hash: "1F2E3D4C" },
    { level: 4, usado: false, is_story: false, remetente: "fornecedor@techvendas.com", assunto: "Boleto Atualizado", corpo: "Houve um erro no faturamento. Segue boleto corrigido com vencimento para hoje.", is_threat: true, email_alvo: "voce@cyprotect.com", ip_alvo: "201.30.1.5", data_envio: "18/04 14:10", anexo: "Boleto_Tech.zip", hash: "B0B0C1C1" }
];

// ==========================================
// 5. BANCO DE DADOS: FUNCIONÁRIOS
// ==========================================
global.db_funcionarios = [
    { nome: "Joao Gomes", email: "joao.gomes@cyprotect.com", setor: "Financeiro", cargo: "Analista", acesso: "Leitura/Escrita" },
    { nome: "Marta Silva", email: "marta.silva@cyprotect.com", setor: "RH", cargo: "Gerente", acesso: "Total" },
    { nome: "Carlos TI", email: "carlos.ti@cyprotect.com", setor: "TI", cargo: "Suporte N1", acesso: "Administrador" },
    { nome: "Julia Alves", email: "julia.alves@cyprotect.com", setor: "Marketing", cargo: "Estagiaria", acesso: "Leitura" },
    { nome: "Lucas Dev", email: "lucas.dev@cyprotect.com", setor: "Engenharia", cargo: "Desenvolvedor", acesso: "Leitura/Escrita" },
    { nome: "Diretoria", email: "admin@cyprotect.com", setor: "Diretoria", cargo: "CEO", acesso: "Total" }
];

// ==========================================
// 6. BANCO DE DADOS: CHAMADOS (TI e Acessos)
// ==========================================
global.db_chamados = [
    // Senhas - Ameaças
    { id: 1042, type: "senha", level: 3, usuario: "joao.gomes@cyprotect.com", setor: "Financeiro", senha_tentativa: "123456", is_threat: true }, 
    { id: 1045, type: "senha", level: 3, usuario: "julia.alves@cyprotect.com", setor: "Marketing", senha_tentativa: "julia2026", is_threat: true }, 
    { id: 1050, type: "senha", level: 3, usuario: "admin@cyprotect.com", setor: "Diretoria", senha_tentativa: "Admin@123", is_threat: true },
    { id: 1055, type: "senha", level: 4, usuario: "carlos.ti@cyprotect.com", setor: "TI", senha_tentativa: "password", is_threat: true },
    
    // Senhas - Seguras
    { id: 1088, type: "senha", level: 3, usuario: "marta.silva@cyprotect.com", setor: "RH", senha_tentativa: "M@rt&_S1lv4!99", is_threat: false }, 
    { id: 1092, type: "senha", level: 3, usuario: "carlos.ti@cyprotect.com", setor: "TI", senha_tentativa: "C4rl0s_T3ch#0X", is_threat: false },
    { id: 1095, type: "senha", level: 3, usuario: "joao.gomes@cyprotect.com", setor: "Financeiro", senha_tentativa: "Fin@nc3_J040!x", is_threat: false },
    { id: 1098, type: "senha", level: 4, usuario: "lucas.dev@cyprotect.com", setor: "Engenharia", senha_tentativa: "N3xus_Fl0w!26", is_threat: false },

    // Pastas - Ameaças (Shadow IT e Acessos Indevidos)
    { id: 1105, type: "acesso", level: 3, usuario: "julia.alves@cyprotect.com", setor: "Marketing", pasta: "Balanco_Financeiro_2026", is_threat: true }, 
    { id: 1110, type: "acesso", level: 3, usuario: "joao.gomes@cyprotect.com", setor: "Financeiro", pasta: "Logs_Servidor_Root", is_threat: true }, 
    { id: 1115, type: "acesso", level: 4, usuario: "marta.silva@cyprotect.com", setor: "RH", pasta: "Codigos_Fonte_Engine", is_threat: true }, 
    
    // Pastas - Seguras
    { id: 1199, type: "acesso", level: 3, usuario: "carlos.ti@cyprotect.com", setor: "TI", pasta: "Logs_do_Servidor", is_threat: false }, 
    { id: 1205, type: "acesso", level: 3, usuario: "admin@cyprotect.com", setor: "Diretoria", pasta: "Balanco_Financeiro_2026", is_threat: false }, 
    { id: 1210, type: "acesso", level: 4, usuario: "marta.silva@cyprotect.com", setor: "RH", pasta: "Folha_Pagamento_Abril", is_threat: false },
    { id: 1212, type: "acesso", level: 4, usuario: "lucas.dev@cyprotect.com", setor: "Engenharia", pasta: "Repo_Controle_Acesso", is_threat: false }
];

// ==========================================
// 7. BANCOS AVANÇADOS (Logs e Chat)
// ==========================================
global.db_logs = [
    // --- LEGÍTIMOS (Horário comercial, IPs internos ou BR) ---
    { level: 5, time: "08:15", user: "marta.silva", ip: "172.16.0.45", loc: "BR", is_threat: false },
    { level: 5, time: "08:42", user: "lucas.dev",   ip: "172.16.1.12", loc: "BR", is_threat: false },
    { level: 5, time: "09:05", user: "julia.alves", ip: "10.0.1.15",   loc: "BR", is_threat: false },
    { level: 5, time: "11:20", user: "joao.gomes",  ip: "10.0.0.22",   loc: "BR", is_threat: false },
    { level: 5, time: "14:50", user: "carlos.ti",   ip: "10.0.0.44",   loc: "BR", is_threat: false },
    { level: 5, time: "16:10", user: "admin",       ip: "10.0.0.5",    loc: "BR", is_threat: false },
    
    // --- AMEAÇAS (Horários bizarros, IPs externos, países suspeitos) ---
    { level: 5, time: "01:45", user: "julia.alves", ip: "45.33.12.8",  loc: "CN", is_threat: true },
    { level: 5, time: "03:14", user: "admin",       ip: "185.22.4.1",  loc: "RU", is_threat: true },
    { level: 5, time: "04:22", user: "finance_adm", ip: "203.0.113.1", loc: "KP", is_threat: true },
    { level: 5, time: "10:05", user: "root_sys",    ip: "198.51.100.2",loc: "UNK", is_threat: true },
    { level: 5, time: "12:30", user: "marta.silva", ip: "193.122.4.5", loc: "NG", is_threat: true },
    { level: 5, time: "23:55", user: "dev_backup",  ip: "88.21.34.11", loc: "RO", is_threat: true }
];

global.db_chat = [
    // --- LEGÍTIMOS (Pedidos reais do dia a dia de TI) ---
    { level: 5, remetente: "Carlos TI", mensagem: "Cara, a instabilidade na rede da ilha 3 derrubou o processo de logs aqui no meu terminal. Você consegue reiniciar o serviço por aí pra gente não perder o histórico da manhã?", opcoes: ["1. Reiniciar Servico", "2. Bloquear Terminal", "3. Pedir PIN"], resposta_correta: 0, is_threat: false },
    { level: 5, remetente: "Marta Silva", mensagem: "A folha de pagamento precisa ser aprovada e enviada para o banco até as 14h, mas o IP do financeiro está bloqueado na firewall. Libera o acesso urgente, por favor.", opcoes: ["1. Liberar IP", "2. Bloquear IP", "3. Pedir PIN"], resposta_correta: 0, is_threat: false },
    { level: 5, remetente: "Lucas Dev", mensagem: "Fala meu querido, o GML do sistema de scroll do 'Login Quest' tá dando conflito no merge lá no GitHub. Consegue dar uma olhada e aprovar o pull request pra eu continuar a interface?", opcoes: ["1. Aprovar Merge", "2. Rejeitar Merge", "3. Pedir PIN"], resposta_correta: 0, is_threat: false },
    
    // --- AMEAÇAS (Engenharia Social / Phishing Direto) ---
    { level: 5, remetente: "Diretoria", mensagem: "O sistema bloqueou meu acesso à pasta de balanços financeiros. Eu sou o CEO, preciso que você me envie a senha de administrador do servidor IMEDIATAMENTE. É urgente!", opcoes: ["1. Enviar Senha", "2. Pedir PIN", "3. Ignorar"], resposta_correta: 1, is_threat: true },
    { level: 5, remetente: "Dev Team", mensagem: "A API do OmniAssets caiu no meio de uma sincronização de delta-updates. Passa a chave SSH primária para eu subir o backup antes que a gente perca os assets dos clientes.", opcoes: ["1. Enviar Chave", "2. Negar e Reportar", "3. Pedir PIN"], resposta_correta: 1, is_threat: true },
    { level: 5, remetente: "Suporte", mensagem: "Identificamos anomalias de login vinculadas ao seu RGM acadêmico de acesso na UDF. Para evitar a suspensão da sua rede no SOC, confirme sua senha atual.", opcoes: ["1. Confirmar Senha", "2. Reportar Phishing", "3. Ignorar"], resposta_correta: 1, is_threat: true }
];
// ==========================================
// 8. INICIA O SORTEIO (SEMPRE POR ÚLTIMO!)
// ==========================================
event_user(0);