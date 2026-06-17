import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOLS))

from generate_tcc_docx import (  # noqa: E402
    ASSETS,
    DocxBuilder,
    old_references,
    pct,
    pp,
    num,
    read_xlsx,
)


ROOT = TOOLS.parent
XLSX = Path(r"C:\Users\Gustavo\Downloads\login_quest_simulacao_completa_30_participantes_1.xlsx")
SOURCE_DOCX = Path(r"D:\tcc\TGI 1 Gustavo Emanuel Abreu Ribeiro.docx")
OUT_WORKSPACE = ROOT / "TGI_1_Gustavo_Emanuel_Abreu_Ribeiro_expandido_Login_Quest.docx"


def add_bullets(doc, items):
    for item in items:
        doc.paragraph(f"- {item}")


def add_source(doc, text="Fonte: elaborado pelo autor."):
    doc.caption(text)


def add_table(doc, caption, rows, widths, source="Fonte: elaborado pelo autor."):
    doc.caption(caption)
    doc.table(rows, widths)
    add_source(doc, source)


def build_recorte(brutos, pontuacao):
    raw_header = brutos[0]
    raw_rows = brutos[1:]
    idx = {name: i for i, name in enumerate(raw_header)}
    pont_rows = pontuacao[1:]
    recorte = [["Participante", "Faixa etária", "Conhecimento prévio", "Acesso ao jogo", "Tempo de uso", "Pré-teste", "Pós-teste"]]
    for rr, pr in zip(raw_rows, pont_rows):
        recorte.append([
            pr[0],
            rr[idx["Faixa etária"]],
            rr[idx["Conhecimento prévio em cibersegurança (1-5)"]],
            rr[idx["Conseguiu acessar e jogar?"]].replace("Sim, ", "").replace(" da versão disponível.", ""),
            rr[idx["Tempo aproximado de uso"]],
            pct(pr[2]),
            pct(pr[4]),
        ])
    return recorte


def main():
    data = read_xlsx(XLSX)
    refs = old_references(SOURCE_DOCX)

    perfil = data["Tabelas - Perfil"]
    resultados = data["Tabelas - Resultados"]
    percepcao = data["Tabelas - Percepção"]
    sugestoes = data["Tabelas - Sugestões"]
    pontuacao = data["Pontuação"]
    brutos = data["Dados brutos - Forms"]
    gabarito = data["Gabarito"]

    indicadores = resultados[:10]
    comparacao = resultados[10:42]
    categorias = resultados[42:]
    recorte = build_recorte(brutos, pontuacao)

    doc = DocxBuilder()

    # CAPA
    doc.paragraph("CENTRO DE ENSINO UNIFICADO DO DISTRITO FEDERAL", align="center", bold=True)
    doc.paragraph("BACHAREL EM CIÊNCIA DA COMPUTAÇÃO", align="center", bold=True)
    doc.paragraph("\n\n\nGUSTAVO EMANUEL ABREU RIBEIRO", align="center", bold=True)
    doc.paragraph("\n\nLOGIN QUEST: UM JOGO SÉRIO PARA CONSCIENTIZAÇÃO EM CIBERSEGURANÇA", align="center", bold=True, size=30)
    doc.paragraph("\n\n\n\nBRASÍLIA\n2026", align="center", bold=True)
    doc.page_break()

    doc.paragraph("GUSTAVO EMANUEL ABREU RIBEIRO", align="center", bold=True)
    doc.paragraph("\nLOGIN QUEST: UM JOGO SÉRIO PARA CONSCIENTIZAÇÃO EM CIBERSEGURANÇA", align="center", bold=True, size=30)
    doc.paragraph(
        "\nTrabalho de Graduação Interdisciplinar apresentado à Coordenação de Tecnologia do Centro de Ensino Unificado do Distrito Federal como requisito parcial para obtenção do grau de Bacharel em Ciência da Computação.\n\nOrientadora: Prof. Kerlla de Souza Luz",
        align="both",
    )
    doc.paragraph("\n\n\nBRASÍLIA\n2026", align="center", bold=True)
    doc.page_break()

    doc.h1("RESUMO")
    doc.paragraph(
        "Este trabalho apresenta o desenvolvimento e a avaliação inicial do Login Quest, um jogo sério voltado à conscientização em cibersegurança. A proposta parte da constatação de que muitos incidentes digitais exploram decisões humanas, como clicar em links suspeitos, reutilizar senhas, aprovar acessos incompatíveis ou atender solicitações urgentes sem validação. Para responder a esse problema, o jogo coloca o usuário no papel de um analista de segurança da empresa fictícia CyProtect, simulando uma rotina de trabalho baseada em e-mails, chamados, banco de funcionários, scanner de anexos, terminal de logs, chat corporativo e relatório diário."
    )
    doc.paragraph(
        "A versão final foi implementada em GameMaker Studio, com linguagem GML, interface em pixel art, janelas arrastáveis, ações por clique, progressão por dias, manual interno, pontuação, reputação e feedback ao fim de cada expediente. O conteúdo pedagógico aborda phishing, engenharia social, senhas fortes, autenticação em dois fatores, princípio do menor privilégio, análise de logs, identificação de IPs suspeitos e interpretação de anexos potencialmente maliciosos. A avaliação foi estruturada com pré-teste, uso do jogo, pós-teste e questionário de percepção em escala Likert, utilizando base simulada de validação com 30 registros anônimos. Os resultados indicaram aumento médio de 58,8% para 89,2% no desempenho, ganho de 30,4 pontos percentuais e média geral Likert de 4,31. Conclui-se que o Login Quest apresenta potencial como ferramenta complementar para educação em cibersegurança, especialmente por transformar conceitos técnicos em decisões práticas e contextualizadas."
    )
    doc.paragraph("Palavras-chave: Cibersegurança. Jogos sérios. Fator humano. Gamificação. Engenharia social. Phishing.")
    doc.h1("ABSTRACT")
    doc.paragraph(
        "This work presents the development and initial evaluation of Login Quest, a serious game aimed at cybersecurity awareness. The proposal is based on the fact that many digital incidents exploit human decisions, such as clicking suspicious links, reusing passwords, approving incompatible access requests or responding to urgent messages without validation. The game places the user in the role of a security analyst at the fictional company CyProtect, simulating a work routine based on emails, support tickets, employee database, attachment scanner, network logs, corporate chat and daily report."
    )
    doc.paragraph(
        "The final version was implemented in GameMaker Studio using GML, with a pixel-art interface, draggable windows, click-based actions, day-based progression, internal manual, score, reputation and end-of-shift feedback. The pedagogical content addresses phishing, social engineering, strong passwords, two-factor authentication, least privilege, log analysis, suspicious IP identification and potentially malicious attachments. The evaluation was structured with pre-test, game use, post-test and Likert perception questionnaire, using a simulated validation dataset with 30 anonymous records. Results showed an average increase from 58.8% to 89.2%, a gain of 30.4 percentage points and an overall Likert mean of 4.31. Login Quest therefore shows potential as a complementary cybersecurity education tool, especially by transforming technical concepts into practical and contextualized decisions."
    )
    doc.paragraph("Keywords: Cybersecurity. Serious games. Human factor. Gamification. Social engineering. Phishing.")
    doc.page_break()

    doc.h1("LISTA DE ILUSTRAÇÕES")
    for i, title in enumerate([
        "Tela principal do ambiente de trabalho da CyProtect",
        "Tutorial inicial",
        "Caixa de entrada",
        "Janela de leitura de e-mail",
        "Inspetor de origem do e-mail",
        "Manual interno de segurança",
        "Lista de chamados",
        "Avaliação de senha",
        "Solicitação de acesso",
        "Base de funcionários",
        "Scanner de anexos",
        "Terminal de logs",
        "Chat interno",
        "Relatório de turno",
        "Tela de finalização",
        "Arquitetura funcional do Login Quest",
        "Fluxo principal do jogo",
        "Progressão dos desafios por dia",
        "Fluxo de avaliação de uma decisão",
    ], 1):
        doc.paragraph(f"Figura {i} — {title}")
    doc.h1("LISTA DE TABELAS")
    for i, title in enumerate([
        "Relação entre problemas de cibersegurança e mecânicas do jogo",
        "Módulos funcionais implementados",
        "Progressão de dificuldade por dia",
        "Regras de decisão e pontuação",
        "Requisitos de segurança, privacidade, usabilidade e pedagogia",
        "Perfil dos registros de validação",
        "Escala de avaliação utilizada no questionário de percepção",
        "Estrutura da base bruta exportada",
        "Recorte da base anonimizada",
        "Métricas utilizadas na avaliação",
        "Indicadores gerais de desempenho",
        "Comparação entre pré-teste e pós-teste",
        "Desempenho por categoria temática",
        "Percepção e usabilidade",
        "Síntese das respostas abertas",
    ], 1):
        doc.paragraph(f"Tabela {i} — {title}")
    doc.h1("LISTA DE ABREVIATURAS E SIGLAS")
    for sigla in [
        "2FA — Two-Factor Authentication, ou autenticação em duas etapas.",
        "DSR — Design Science Research.",
        "GML — GameMaker Language.",
        "IP — Internet Protocol.",
        "SOC — Security Operations Center.",
        "TCLE — Termo de Consentimento Livre e Esclarecido.",
        "UML — Unified Modeling Language.",
    ]:
        doc.paragraph(sigla)
    doc.h1("SUMÁRIO")
    for item in [
        "1 CONTEXTUALIZAÇÃO E PROBLEMA",
        "1.1 Justificativa e motivação",
        "1.2 Objetivos",
        "1.3 Metodologia adotada",
        "1.4 Visão geral do artefato",
        "2 REFERENCIAL TEÓRICO",
        "2.1 Cibersegurança e fator humano",
        "2.2 Engenharia social, phishing e credenciais",
        "2.3 Jogos sérios e gamificação",
        "2.4 Avaliação de jogos sérios",
        "2.5 Trabalhos correlatos",
        "3 DESENVOLVIMENTO DO JOGO LOGIN QUEST",
        "3.1 Tecnologias utilizadas",
        "3.2 Narrativa e proposta pedagógica",
        "3.3 Arquitetura funcional",
        "3.4 Módulos e telas implementadas",
        "3.5 Progressão e regras do jogo",
        "3.6 Requisitos do sistema",
        "4 AVALIAÇÃO DO JOGO LOGIN QUEST",
        "5 CONCLUSÃO",
        "REFERÊNCIAS",
        "APÊNDICES",
    ]:
        doc.paragraph(item)
    doc.page_break()

    # CAPÍTULO 1
    doc.h1("1 CONTEXTUALIZAÇÃO E PROBLEMA")
    for p in [
        "A transformação digital modificou profundamente a forma como pessoas, empresas e instituições lidam com informação. Atividades cotidianas que antes ocorriam em ambientes físicos ou isolados passaram a depender de contas digitais, sistemas integrados, autenticação remota, bancos de dados, plataformas acadêmicas, serviços financeiros e canais de comunicação instantânea. Esse cenário amplia a produtividade, mas também aumenta a superfície de ataque disponível para agentes maliciosos.",
        "Nesse contexto, a cibersegurança deixou de ser um tema restrito a especialistas e passou a fazer parte da rotina de usuários comuns. Um colaborador que recebe um e-mail falso, um estudante que reutiliza a mesma senha em diferentes plataformas ou um funcionário que aprova um acesso sem verificar a necessidade real pode comprometer informações sensíveis. O risco, portanto, não se limita à infraestrutura técnica: ele envolve também percepção, julgamento, hábito e comportamento.",
        "Grande parte dos ataques contemporâneos combina elementos técnicos com manipulação humana. Mensagens de phishing podem utilizar remetentes parecidos com domínios legítimos, anexos disfarçados de documentos, senso de urgência e promessas de benefício. Da mesma forma, solicitações de acesso podem explorar confiança, hierarquia ou pressa para induzir a aprovação indevida. Por isso, a conscientização em segurança precisa ir além de explicar conceitos; ela deve treinar a capacidade de reconhecer sinais de risco em situações concretas.",
        "O problema abordado por este trabalho é a dificuldade de transformar conhecimentos básicos de cibersegurança em decisões práticas. Usuários podem saber que senhas fracas são perigosas, mas ainda assim aprovar uma senha previsível quando o sistema não apresenta consequências claras. Podem reconhecer que não se deve compartilhar credenciais, mas ceder diante de uma mensagem que simula urgência ou autoridade. Essa distância entre conhecimento teórico e decisão contextualizada motivou o desenvolvimento do Login Quest.",
        "O Login Quest foi concebido como um jogo sério, isto é, um artefato interativo que utiliza elementos de jogos com finalidade educacional. A proposta consiste em simular um ambiente de trabalho no qual o usuário atua como analista de segurança da empresa fictícia CyProtect. Durante o expediente, o jogador recebe e-mails, chamados, logs e mensagens internas, devendo classificar ameaças, aprovar itens legítimos, negar solicitações incompatíveis e consultar evidências antes de decidir.",
    ]:
        doc.paragraph(p)
    doc.h2("1.1 Justificativa e motivação")
    for p in [
        "A principal motivação deste projeto é oferecer uma forma mais ativa de aprendizagem em cibersegurança. Treinamentos tradicionais, como palestras, cartilhas e vídeos obrigatórios, são importantes para transmissão inicial de conteúdo, mas frequentemente colocam o usuário em posição passiva. Em muitos casos, o participante apenas recebe recomendações, sem experimentar as consequências de uma decisão incorreta.",
        "Jogos sérios permitem trabalhar o mesmo conteúdo de modo mais prático, pois inserem o usuário em um ambiente simulado, com metas, regras, feedback e progressão. No caso do Login Quest, cada decisão afeta pontuação, reputação e relatório do turno. Assim, o jogador percebe que bloquear um e-mail legítimo também tem custo, enquanto liberar uma ameaça pode comprometer a segurança da empresa. Essa ambiguidade aproxima a experiência do contexto real de trabalho, no qual nem toda decisão é óbvia.",
        "Outro fator que justifica o projeto é a relevância do fator humano na segurança digital. Mesmo com ferramentas automatizadas, firewalls, antivírus, autenticação multifatorial e políticas corporativas, muitos incidentes começam por uma ação humana inadequada. A educação do usuário, portanto, é parte essencial de qualquer estratégia defensiva. Ao transformar boas práticas em desafios, o jogo busca apoiar esse processo de conscientização.",
    ]:
        doc.paragraph(p)
    doc.h2("1.2 Objetivos")
    doc.h3("1.2.1 Objetivo geral")
    doc.paragraph("Conceber, implementar e avaliar inicialmente o Login Quest, um jogo sério voltado à conscientização em cibersegurança, com foco na tomada de decisão diante de e-mails suspeitos, senhas, solicitações de acesso, anexos, logs e engenharia social.")
    doc.h3("1.2.2 Objetivos específicos")
    add_bullets(doc, [
        "Identificar conteúdos de cibersegurança associados ao fator humano e adequados a um jogo educacional.",
        "Projetar uma narrativa e uma interface capazes de representar uma rotina simulada de análise de segurança.",
        "Implementar módulos funcionais de e-mail, manual, chamados, banco de funcionários, scanner, logs, chat e relatório.",
        "Definir regras de pontuação, reputação e progressão que reforcem decisões corretas e penalizem escolhas inseguras.",
        "Criar instrumentos de avaliação compostos por pré-teste, pós-teste, questionário Likert e perguntas abertas.",
        "Analisar indícios de eficácia educativa, usabilidade e aceitação a partir de uma base estruturada de validação.",
    ])
    doc.h2("1.3 Metodologia adotada")
    for p in [
        "A pesquisa foi organizada conforme a lógica da Design Science Research, abordagem adequada para trabalhos que desenvolvem artefatos tecnológicos destinados a resolver problemas práticos. Nesse tipo de pesquisa, o conhecimento é produzido tanto pela fundamentação teórica quanto pela construção e avaliação do artefato.",
        "O desenvolvimento do Login Quest ocorreu em ciclos. Inicialmente, foram definidos o problema, o público-alvo, os conteúdos de segurança e a proposta narrativa. Em seguida, foram elaborados protótipos de interface e fluxos de interação. Posteriormente, a versão funcional foi implementada em GameMaker Studio, incorporando janelas, objetos, sprites, bases internas de dados e regras de avaliação.",
        "Após a implementação, foi organizada uma estratégia de validação baseada em pré-teste e pós-teste. Esse modelo permite comparar o desempenho do participante antes e depois da experiência com o jogo. Além disso, foram incluídas perguntas de percepção e usabilidade para avaliar clareza, engajamento, realismo dos desafios e utilidade percebida.",
    ]:
        doc.paragraph(p)
    doc.h2("1.4 Visão geral do artefato")
    doc.paragraph("O artefato final é um jogo 2D de interface desktop simulada. A tela principal apresenta ícones de aplicativos, como e-mail, chat, logs, scanner, chamados, manual e banco de dados. Ao iniciar o expediente, tarefas são entregues gradualmente entre 09h00 e 15h30, e o jogador deve concluí-las antes do fim do turno. O sistema registra cada decisão e apresenta um relatório diário com acertos, erros, pontuação e reputação.")
    add_table(doc, "Tabela 1 — Relação entre problemas de cibersegurança e mecânicas do jogo", [
        ["Problema educacional", "Mecânica implementada", "Resultado esperado"],
        ["Reconhecer phishing", "Análise de remetente, assunto, corpo e inspeção de origem", "Identificar sinais de fraude antes de aprovar mensagens"],
        ["Evitar senhas fracas", "Chamados de redefinição com senhas sugeridas", "Diferenciar senhas previsíveis de senhas robustas"],
        ["Controlar privilégios", "Solicitações de acesso comparadas com cargo e setor", "Aplicar princípio do menor privilégio"],
        ["Detectar malware", "Scanner de anexos e consulta de hashes", "Isolar arquivos suspeitos e liberar documentos legítimos"],
        ["Avaliar logs", "Terminal com horário, usuário, IP e localização", "Bloquear acessos anômalos e permitir tráfego legítimo"],
        ["Resistir à engenharia social", "Chat com pedidos urgentes e dados sensíveis", "Validar identidade e negar solicitações inseguras"],
    ], [2900, 3600, 3600])

    # CAPÍTULO 2
    doc.h1("2 REFERENCIAL TEÓRICO")
    doc.h2("2.1 Cibersegurança e fator humano")
    for p in [
        "A cibersegurança compreende práticas, processos e tecnologias voltados à proteção de sistemas, redes e dados contra acesso não autorizado, alteração indevida, indisponibilidade e vazamento de informações. Em ambientes corporativos, essa proteção envolve controles técnicos, políticas internas, monitoramento, resposta a incidentes e treinamento de usuários.",
        "Apesar da importância dos mecanismos técnicos, o fator humano permanece um componente crítico. Usuários podem cometer erros por falta de conhecimento, excesso de confiança, pressa, fadiga ou interpretação inadequada de sinais de risco. Também podem ser manipulados por atacantes que exploram emoções, autoridade, reciprocidade, medo ou urgência.",
        "A conscientização em cibersegurança deve, portanto, desenvolver não apenas memória de regras, mas julgamento. O usuário precisa saber observar contexto, origem, permissões solicitadas, horário, linguagem, anexos e coerência com a função desempenhada. O Login Quest foi construído justamente para exercitar esse julgamento por meio de cenários simulados.",
    ]:
        doc.paragraph(p)
    doc.h2("2.2 Engenharia social, phishing e credenciais")
    for p in [
        "Engenharia social é o uso de técnicas de manipulação para induzir pessoas a revelar informações, executar ações ou conceder acessos. Em vez de atacar diretamente uma barreira técnica, o agressor explora a confiança ou o comportamento da vítima. Pedidos com aparência de urgência, mensagens de autoridade e solicitações de sigilo são exemplos comuns.",
        "O phishing é uma das manifestações mais conhecidas desse tipo de ataque. Ele costuma envolver e-mails ou mensagens que se passam por instituições legítimas, solicitam clique em links, download de anexos ou fornecimento de credenciais. Sinais como domínios parecidos, erros de escrita, promessas exageradas e ameaça de bloqueio imediato ajudam a identificar tentativas suspeitas.",
        "Credenciais também são alvo recorrente. Senhas fracas, reutilizadas ou baseadas em dados pessoais reduzem significativamente a segurança das contas. A autenticação em duas etapas melhora a proteção ao exigir um segundo fator, mas não elimina a necessidade de atenção do usuário. Por isso, o jogo combina desafios de senhas, 2FA e engenharia social em diferentes momentos da progressão.",
    ]:
        doc.paragraph(p)
    doc.h2("2.3 Jogos sérios e gamificação")
    for p in [
        "Jogos sérios são desenvolvidos com objetivos que ultrapassam o entretenimento. Eles podem ser utilizados em educação, treinamento profissional, saúde, simulação militar, segurança e outras áreas. A característica central é a presença de uma finalidade instrucional integrada à experiência de jogo.",
        "A gamificação, por sua vez, consiste na aplicação de elementos típicos de jogos em contextos não necessariamente lúdicos. Pontuação, níveis, desafios, feedback, recompensas e progressão são exemplos desses elementos. Quando aplicados de forma adequada, podem aumentar engajamento e tornar o aprendizado mais significativo.",
        "No Login Quest, a gamificação não aparece apenas como decoração visual. Ela está ligada à lógica do sistema: o jogador recebe metas diárias, precisa administrar tempo, ganha ou perde pontos, altera a reputação da empresa fictícia e recebe relatório de desempenho. Assim, as mecânicas reforçam o conteúdo pedagógico.",
    ]:
        doc.paragraph(p)
    doc.h2("2.4 Avaliação de jogos sérios")
    for p in [
        "A avaliação de jogos sérios pode considerar diferentes dimensões: aprendizagem, usabilidade, engajamento, satisfação, adequação pedagógica e transferência para situações reais. Uma abordagem comum é comparar desempenho antes e depois da experiência, utilizando pré-teste e pós-teste com questões equivalentes.",
        "Além dos testes objetivos, questionários de percepção ajudam a compreender se o usuário considerou a ferramenta clara, útil e envolvente. Perguntas abertas também são relevantes, pois revelam problemas de interface, sugestões de conteúdo e interpretações que números isolados não capturam.",
        "Neste trabalho, a avaliação foi estruturada para observar indícios iniciais de eficácia educativa e aceitação. A intenção não é afirmar generalização ampla, mas demonstrar se o artefato possui potencial e se o método de validação está organizado para uma aplicação empírica posterior.",
    ]:
        doc.paragraph(p)
    doc.h2("2.5 Trabalhos correlatos")
    for p in [
        "Trabalhos correlatos em jogos sérios mostram que ambientes interativos podem apoiar o ensino de conteúdos abstratos. Jogos de lógica de programação, segurança, redes e privacidade têm em comum a tentativa de aproximar teoria e prática por meio de desafios. Em cibersegurança, esse aspecto é especialmente importante, pois o usuário precisa reconhecer ameaças em contexto.",
        "Soluções como jogos de conscientização sobre phishing, jogos de tabuleiro sobre segurança e simulações de administração de redes indicam que o aprendizado pode ser favorecido quando o participante precisa decidir e observar consequências. O Login Quest se diferencia ao simular um ambiente de trabalho em formato desktop, reunindo múltiplos tipos de tarefa em uma mesma rotina.",
        "Enquanto alguns jogos focam em um único tema, como phishing ou senhas, o Login Quest combina categorias progressivas. O jogador começa com e-mails e evolui para inspeção de origem, chamados, acessos, anexos, logs e chat. Essa progressão busca representar a complexidade crescente de um ambiente corporativo.",
    ]:
        doc.paragraph(p)

    # CAPÍTULO 3
    doc.h1("3 DESENVOLVIMENTO DO JOGO LOGIN QUEST")
    doc.h2("3.1 Tecnologias utilizadas")
    for p in [
        "O jogo foi implementado em GameMaker Studio, engine voltada ao desenvolvimento de jogos 2D. A escolha se justifica pela integração entre editor visual, sistema de salas, objetos, eventos e linguagem GML. Esses recursos permitem criar protótipos funcionais de forma rápida, sem perder controle sobre lógica de jogo, desenho de interface e gerenciamento de estados.",
        "A linguagem GML foi utilizada para estruturar o comportamento dos objetos, como janelas, ícones, controlador de expediente, relatório, scanner, chat e chamados. A lógica do jogo está distribuída em eventos Create, Step, Draw, CleanUp e eventos de usuário. Essa organização é adequada ao modelo do GameMaker, no qual cada objeto responde continuamente à interação do jogador.",
        "A interface visual utiliza pixel art, sprites e fontes bitmap. O estilo foi escolhido por combinar simplicidade visual com boa leitura dos elementos funcionais. Como o foco do jogo está na tomada de decisão, a interface evita excesso de elementos decorativos e prioriza janelas, botões, textos e ícones reconhecíveis.",
        "O planejamento inicial mencionava SQLite como possível armazenamento local. Na versão final, entretanto, o projeto não utiliza um banco relacional externo. Os dados necessários à simulação foram implementados diretamente em GML, por meio de arrays e structs. Essa solução é suficiente para o escopo do jogo, reduz dependências e facilita a distribuição do projeto como artefato acadêmico.",
    ]:
        doc.paragraph(p)
    doc.h2("3.2 Narrativa e proposta pedagógica")
    for p in [
        "A narrativa do Login Quest se passa na CyProtect, uma empresa fictícia de tecnologia que precisa fortalecer sua postura de segurança. O jogador assume a função de novo analista de segurança e recebe responsabilidades ao longo de uma semana de trabalho. Essa escolha narrativa aproxima o jogo de um contexto profissional, mas mantém liberdade para simplificar situações e torná-las adequadas ao aprendizado.",
        "O expediente simulado vai das 09h00 às 17h00. Durante esse período, diferentes eventos aparecem em filas: e-mails, chamados, logs e mensagens de chat. O jogador não recebe todas as tarefas de uma vez; elas são agendadas ao longo do dia, criando sensação de rotina operacional e exigindo atenção contínua.",
        "O objetivo pedagógico é fazer com que o jogador aprenda pela análise de evidências. Em vez de apresentar apenas uma pergunta direta, o jogo oferece dados como remetente, domínio, IP, hash, cargo do funcionário, pasta solicitada, horário de login e localização. A decisão correta depende da interpretação desses sinais.",
    ]:
        doc.paragraph(p)
    doc.h2("3.3 Arquitetura funcional")
    doc.image(ASSETS / "diag01_arquitetura.png", 15.5)
    doc.caption("Figura 1 — Arquitetura funcional do Login Quest")
    add_source(doc)
    for p in [
        "A arquitetura funcional do Login Quest pode ser compreendida em cinco partes principais. A camada de apresentação reúne o desktop, os ícones, as janelas e os elementos visuais. A camada de lógica de jogo controla o expediente, a ordem de entrega das tarefas, as decisões do jogador, a progressão de dias e a finalização do jogo.",
        "A camada de dados internos armazena os cenários simulados. O projeto contém listas de e-mails, funcionários, chamados, logs e mensagens de chat. Cada item possui atributos próprios, como nível, remetente, assunto, corpo, usuário, setor, senha sugerida, pasta, IP, localização, hash e indicador de ameaça.",
        "A camada de avaliação registra as decisões tomadas. Sempre que o jogador aprova, bloqueia, nega, concede, isola, libera ou responde a uma mensagem, o sistema cria um registro com o assunto, a natureza da tarefa e a ação do jogador. Esses registros alimentam o contador diário e o relatório.",
        "Por fim, o relatório sintetiza a experiência do dia. Ele mostra quais ações foram corretas ou incorretas, apresenta pontuação, reputação e permite avançar para o próximo dia. Essa etapa é essencial para transformar a ação em reflexão, aproximando a mecânica de jogo do objetivo educativo.",
    ]:
        doc.paragraph(p)
    doc.h2("3.4 Módulos e telas implementadas")
    modules = [
        ["Módulo", "Descrição detalhada", "Aprendizagem associada"],
        ["Desktop", "Tela principal com ícones laterais, pasta segura, firewall, manual, banco de dados e barra inferior.", "Organização do ambiente de trabalho e acesso aos recursos."],
        ["Tutorial", "Sobreposição inicial que apresenta o papel do jogador e orienta a primeira interação.", "Reduzir barreira de entrada e contextualizar a missão."],
        ["E-mail", "Janela com remetente, assunto, corpo, anexos e botão de inspeção a partir do segundo dia.", "Phishing, remetentes falsos e análise de conteúdo."],
        ["Inspetor", "Exibe origem técnica, IP, data e estrutura semelhante a código-fonte da mensagem.", "Verificação de evidências técnicas e domínios suspeitos."],
        ["Manual", "Guia interno com tópicos liberados conforme a progressão.", "Aprendizagem consultiva durante a tarefa."],
        ["Chamados", "Lista solicitações internas de senha e acesso.", "Triagem de pedidos operacionais."],
        ["Senha", "Mostra setor, usuário e senha sugerida, exigindo aprovar ou reportar.", "Critérios de senha forte e rejeição de padrões fracos."],
        ["Acesso", "Mostra usuário e diretório alvo, exigindo negar ou conceder.", "Privilégio mínimo e compatibilidade entre cargo e recurso."],
        ["Data Base", "Lista funcionários, e-mails, setores, cargos e níveis de acesso.", "Consulta de evidências antes de autorizar permissões."],
        ["Scanner", "Recebe e-mails com anexos, extrai hash e exige isolar ou liberar.", "Noção de malware, anexos e assinatura."],
        ["Logs", "Mostra timestamp, usuário, IP e localização, com decisão de permitir ou bloquear.", "Identificação de anomalias de acesso."],
        ["Chat", "Simula mensagens internas com opções de resposta.", "Resistência a engenharia social e validação de identidade."],
        ["Relatório", "Apresenta ações, acertos, erros, reputação e score.", "Feedback e consolidação do aprendizado."],
    ]
    add_table(doc, "Tabela 2 — Módulos funcionais implementados", modules, [1800, 5000, 3300])

    screen_info = [
        ("fig01_tela_principal.png", "Figura 2 — Tela principal do ambiente de trabalho da CyProtect", "A tela principal simula um sistema operacional corporativo simples. Os ícones representam ferramentas de trabalho do analista, enquanto a pasta segura e o firewall funcionam como destinos para classificar e-mails. A presença do contador de dia e tarefas orienta o jogador sobre seu progresso no expediente."),
        ("fig02_tutorial.png", "Figura 3 — Tutorial inicial", "O tutorial introduz a missão do jogador, explica que as decisões devem ser tomadas com base em evidências e sinaliza a necessidade de consultar ferramentas auxiliares. Essa etapa é importante porque evita que o participante interprete o jogo apenas como uma sequência de perguntas isoladas."),
        ("fig03_caixa_entrada.png", "Figura 4 — Caixa de entrada", "A caixa de entrada lista mensagens pendentes, exibindo remetente e assunto. A interface reproduz a triagem inicial de e-mails, em que muitas decisões começam com a leitura de sinais superficiais antes da análise detalhada."),
        ("fig04_leitura_email.png", "Figura 5 — Janela de leitura de e-mail", "A janela de leitura apresenta o conteúdo da mensagem. O jogador deve observar remetente, assunto, corpo e, quando disponível, anexos. A partir do segundo dia, o botão de inspeção incentiva análise técnica além da aparência textual."),
        ("fig05_inspetor_source.png", "Figura 6 — Inspetor de origem do e-mail", "O inspetor funciona como uma camada de evidência. Ele mostra dados técnicos como IP de origem e estrutura da mensagem. Esse recurso reforça que ataques podem parecer legítimos na superfície, exigindo investigação complementar."),
        ("fig06_manual.png", "Figura 7 — Manual interno de segurança", "O manual reúne orientações desbloqueadas conforme os dias avançam. Ele não substitui a decisão do jogador, mas funciona como apoio pedagógico, permitindo consultar regras sobre redes confiáveis, senhas, permissões, hashes, logs e engenharia social."),
        ("fig07_chamados.png", "Figura 8 — Lista de chamados", "A lista de chamados representa demandas internas de suporte e acesso. O jogador precisa abrir cada item e avaliar se a solicitação corresponde a uma necessidade legítima ou se representa risco operacional."),
        ("fig08_avaliacao_senha.png", "Figura 9 — Avaliação de senha", "A tela de senha apresenta uma proposta de redefinição. Senhas como 123456, password ou padrões com nome e ano devem ser reportadas, enquanto senhas longas, variadas e menos previsíveis podem ser aprovadas."),
        ("fig09_solicitacao_acesso.png", "Figura 10 — Solicitação de acesso", "A solicitação de acesso exige comparação entre usuário, setor e diretório. Esse tipo de desafio trabalha privilégio mínimo, necessidade real e risco de escalonamento indevido."),
        ("fig10_data_base.png", "Figura 11 — Base de funcionários", "A base de funcionários permite consultar cargo, setor e nível de acesso. Ela torna a decisão menos intuitiva e mais investigativa, pois o jogador precisa buscar evidências antes de aprovar permissões."),
        ("fig11_scanner.png", "Figura 12 — Scanner de anexos", "O scanner recebe anexos enviados a partir de e-mails. Após a extração do hash, o jogador deve consultar o manual e decidir se libera ou isola o arquivo. A mecânica reforça cuidado com extensões executáveis, compactados e scripts."),
        ("fig12_logs.png", "Figura 13 — Terminal de logs", "O terminal apresenta dados de conexão em formato simplificado: horário, usuário, IP e localização. Logins de madrugada, países suspeitos e usuários inesperados devem ser tratados como sinais de risco."),
        ("fig13_chat.png", "Figura 14 — Chat interno", "O chat simula comunicação corporativa e ataques de engenharia social. Algumas mensagens são legítimas, outras exploram urgência, autoridade ou pedido de credenciais. O jogador deve escolher a resposta mais segura."),
        ("fig14_relatorio.png", "Figura 15 — Relatório de turno", "O relatório mostra o histórico das decisões e identifica acertos e erros. Essa tela fecha o ciclo pedagógico, pois transforma a jogabilidade em feedback explícito sobre o desempenho."),
        ("fig15_finalizacao.png", "Figura 16 — Tela de finalização", "A finalização indica sucesso ou falha conforme reputação e desempenho. Essa consequência narrativa reforça o impacto das decisões acumuladas durante a semana simulada."),
    ]
    for image, caption, description in screen_info:
        doc.image(ASSETS / image, 15.5)
        doc.caption(caption)
        add_source(doc, "Fonte: elaborado pelo autor a partir da versão final do jogo.")
        doc.paragraph(description)

    doc.h2("3.5 Fluxo principal do jogo")
    doc.image(ASSETS / "diag02_fluxo_principal.png", 15.5)
    doc.caption("Figura 17 — Fluxo principal do jogo")
    add_source(doc)
    for p in [
        "O fluxo principal inicia quando o jogador acessa o ambiente e começa o expediente. O controlador do jogo limpa as filas do dia anterior, seleciona tarefas compatíveis com o nível atual e agenda a entrega dos eventos ao longo do turno. Em seguida, o jogador analisa cada tarefa, utiliza ferramentas de apoio e toma uma decisão.",
        "Cada decisão segue um ciclo comum: entrada de dados, interpretação, ação, validação, registro e feedback. Esse padrão garante consistência entre diferentes tipos de desafio. Mesmo que a interface mude, a lógica educativa permanece a mesma: observar evidências, escolher uma ação e receber consequência.",
        "O fim do dia ocorre quando todas as tarefas são resolvidas ou quando o horário chega a 17h00. Caso ainda existam itens pendentes, o sistema aplica penalidade por tarefas ignoradas. Caso o jogador conclua antes do horário final, recebe bônus de eficiência.",
    ]:
        doc.paragraph(p)
    doc.h2("3.6 Progressão de dificuldade")
    doc.image(ASSETS / "diag03_progressao.png", 15.5)
    doc.caption("Figura 18 — Progressão dos desafios por dia")
    add_source(doc)
    progress_rows = [
        ["Dia", "Tarefas", "Novos conceitos", "Objetivo pedagógico"],
        ["1", "6 e-mails", "Triagem básica e phishing evidente", "Ensinar leitura inicial de remetente e assunto."],
        ["2", "8 e-mails", "Inspeção de origem e IP", "Mostrar que mensagens podem exigir evidência técnica."],
        ["3", "6 e-mails + 5 chamados", "Senhas e permissões", "Introduzir controle de acesso e critérios de senha forte."],
        ["4", "8 e-mails + 7 chamados", "Anexos e hashes", "Treinar cuidado com arquivos maliciosos."],
        ["5+", "5 e-mails + 5 chamados + 2 logs + 2 chats", "Logs e engenharia social", "Integrar múltiplas fontes de risco em rotina mais complexa."],
    ]
    add_table(doc, "Tabela 3 — Progressão de dificuldade por dia", progress_rows, [900, 2400, 3100, 3600])
    doc.h2("3.7 Fluxo de avaliação de uma decisão")
    doc.image(ASSETS / "diag04_avaliacao.png", 15.5)
    doc.caption("Figura 19 — Fluxo de avaliação de uma decisão")
    add_source(doc)
    doc.paragraph("O fluxo de avaliação compara a ação do jogador com o campo interno que define se a tarefa é ameaça ou item legítimo. A regra geral é: ações positivas, como aprovar, liberar, permitir ou conceder, são corretas quando o item é seguro; ações negativas, como bloquear, reportar, negar ou isolar, são corretas quando o item é ameaça. Essa lógica foi generalizada para diferentes módulos, permitindo que o relatório diário avalie e exiba resultados de forma uniforme.")
    decision_rows = [
        ["Tipo de tarefa", "Ação segura quando legítimo", "Ação segura quando ameaça", "Consequência de erro"],
        ["E-mail", "Mover para Pasta segura", "Mover para Firewall", "Liberar phishing ou bloquear comunicação legítima."],
        ["Senha", "Aprovar senha robusta", "Reportar senha fraca", "Permitir credencial insegura ou impedir acesso válido."],
        ["Acesso", "Conceder permissão compatível", "Negar permissão incompatível", "Escalonar privilégio indevido ou bloquear trabalho legítimo."],
        ["Scanner", "Liberar anexo seguro", "Isolar arquivo malicioso", "Executar malware ou reter documento válido."],
        ["Logs", "Permitir conexão normal", "Bloquear conexão anômala", "Permitir invasão ou interromper tráfego legítimo."],
        ["Chat", "Executar pedido legítimo", "Validar, negar ou reportar pedido sensível", "Ceder a engenharia social ou atrapalhar operação real."],
    ]
    add_table(doc, "Tabela 4 — Regras de decisão e pontuação", decision_rows, [1700, 2800, 2800, 3300])
    doc.h2("3.8 Requisitos do sistema")
    req_rows = [
        ["Categoria", "Requisito", "Implementação na versão final"],
        ["Segurança", "Não coletar dados sensíveis reais", "Todos os dados do jogo são fictícios e internos."],
        ["Privacidade", "Evitar identificação direta de participantes", "Avaliação organizada por códigos P01 a P30."],
        ["Pedagógico", "Fornecer feedback ao jogador", "Relatório diário, pontuação, reputação e consequências."],
        ["Usabilidade", "Manter interface reconhecível", "Janelas, ícones, botões e ações por arraste/clique."],
        ["Progressão", "Aumentar complexidade gradualmente", "Novos módulos liberados por dia."],
        ["Manutenção", "Permitir adição de novos cenários", "Dados estruturados em arrays/structs em GML."],
    ]
    add_table(doc, "Tabela 5 — Requisitos de segurança, privacidade, usabilidade e pedagogia", req_rows, [1700, 3600, 4700])

    # CAPÍTULO 4
    doc.h1("4 AVALIAÇÃO DO JOGO LOGIN QUEST")
    doc.h2("4.1 Planejamento da avaliação")
    for p in [
        "A avaliação do Login Quest foi planejada para verificar indícios de eficácia educativa, usabilidade e aceitação. Como o jogo tem finalidade pedagógica, a avaliação não se limita a perguntar se o participante gostou da experiência; ela também compara desempenho antes e depois do contato com o artefato.",
        "O procedimento adotado contém quatro etapas principais: aplicação de um pré-teste de conhecimento, utilização do jogo, aplicação de um pós-teste equivalente e questionário de percepção/usabilidade. Essa sequência permite observar tanto variação objetiva de desempenho quanto avaliação subjetiva da experiência.",
        "Nesta versão do trabalho, os resultados são apresentados a partir de uma base simulada de validação com 30 registros anônimos. Essa base permite demonstrar como os dados seriam organizados e analisados em uma aplicação real, incluindo tabelas, indicadores e apêndices. Por rigor metodológico, os resultados são tratados como indícios iniciais e não como generalização definitiva.",
    ]:
        doc.paragraph(p)
    doc.h2("4.2 Participantes ou registros de validação")
    perfil_fmt = [perfil[0]] + [[r[0], r[1], r[2], pct(r[3])] for r in perfil[1:]]
    add_table(doc, "Tabela 6 — Perfil dos registros de validação", perfil_fmt, [3000, 3200, 1500, 1700], "Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("Observa-se predominância de registros na faixa etária de 18 a 24 anos, que correspondem a 60,0% da amostra simulada. Também se verifica que 93,3% indicam ausência de treinamento anterior em segurança digital, condição relevante para uma avaliação de conscientização inicial. Quanto ao acesso ao jogo, 76,7% registraram uso até o final da versão disponível e 23,3% uso parcial.")
    doc.h2("4.3 Instrumentos de coleta")
    doc.paragraph("O instrumento de coleta foi estruturado em seções. A primeira corresponde ao termo de consentimento; a segunda caracteriza o perfil do participante; a terceira mede conhecimento prévio; a quarta orienta o acesso ao jogo; a quinta confirma a experiência; a sexta mede o conhecimento posterior; a sétima avalia percepção e usabilidade; e a última coleta respostas abertas.")
    add_table(doc, "Tabela 7 — Escala de avaliação utilizada no questionário de percepção", [
        ["Valor", "Interpretação"],
        ["1", "Discordo totalmente"],
        ["2", "Discordo parcialmente"],
        ["3", "Neutro"],
        ["4", "Concordo parcialmente"],
        ["5", "Concordo totalmente"],
    ], [2000, 7000])
    doc.h2("4.4 Procedimento de aplicação")
    doc.paragraph("O procedimento prevê que o participante acesse o formulário, aceite o termo e responda ao perfil e ao pré-teste. Depois, utiliza o Login Quest por aproximadamente 10 a 20 minutos. Durante esse período, interage com tarefas de análise de e-mails, senhas, acessos, logs, scanner e chat. Após a experiência, retorna ao formulário para responder ao pós-teste, ao questionário Likert e às perguntas abertas.")
    doc.h2("4.5 Tratamento e anonimização dos dados")
    doc.paragraph("A base foi organizada sem nomes, e-mails pessoais, telefones, matrículas ou qualquer informação diretamente identificável. Os registros foram numerados de P01 a P30, e a análise foi realizada de forma agregada. Essa escolha preserva a privacidade dos respondentes e mantém o foco nos resultados educacionais.")
    doc.h2("4.6 Estrutura da base bruta")
    estrutura = [
        ["Campo", "Descrição", "Uso na análise"],
        ["Carimbo de data/hora", "Data e horário do envio", "Rastreabilidade"],
        ["Aceite TCLE", "Consentimento de participação", "Critério de inclusão"],
        ["Código anônimo", "Identificação P01 a P30", "Controle sem identificação direta"],
        ["Perfil", "Faixa etária, uso de computador, jogos e conhecimento prévio", "Caracterização da amostra"],
        ["Pré Q1 a Pré Q8", "Questões objetivas antes do jogo", "Conhecimento inicial"],
        ["Uso do jogo", "Acesso, tempo e desafios observados", "Controle da experiência"],
        ["Pós Q1 a Pós Q8", "Questões objetivas após o jogo", "Conhecimento posterior"],
        ["Likert 1 a 10", "Percepção e usabilidade", "Aceitação e experiência de uso"],
        ["Perguntas abertas", "Sugestões e contribuição percebida", "Análise qualitativa"],
    ]
    add_table(doc, "Tabela 8 — Estrutura da base bruta exportada", estrutura, [2600, 3900, 3100])
    doc.h2("4.7 Recorte da base anonimizada")
    add_table(doc, "Tabela 9 — Recorte da base anonimizada", recorte, [1200, 1500, 1600, 2700, 1600, 1200, 1200], "Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.h2("4.8 Métricas de avaliação")
    metricas = [
        ["Métrica", "Fórmula ou critério"],
        ["Total de acertos", "Soma das respostas corretas"],
        ["Percentual de acertos", "Acertos ÷ 8 × 100"],
        ["Ganho individual", "Percentual pós-teste − percentual pré-teste"],
        ["Média geral", "Soma dos percentuais ÷ número de registros"],
        ["Melhoria relativa", "((média pós − média pré) ÷ média pré) × 100"],
        ["Média Likert", "Soma das respostas do item ÷ número de registros"],
    ]
    add_table(doc, "Tabela 10 — Métricas utilizadas na avaliação", metricas, [3300, 6100])
    doc.h2("4.9 Indicadores gerais de desempenho")
    ind_fmt = [indicadores[0]]
    for r in indicadores[1:]:
        value = r[1]
        if "participantes" not in r[0].lower():
            value = pct(value)
        ind_fmt.append([r[0], value])
    add_table(doc, "Tabela 11 — Indicadores gerais de desempenho", ind_fmt, [5300, 3000], "Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("A média geral do pré-teste foi de 58,8%, enquanto a média do pós-teste foi de 89,2%. O ganho médio, portanto, foi de 30,4 pontos percentuais. A melhoria relativa foi de 51,8%, o que indica aumento expressivo em relação ao desempenho inicial.")
    doc.paragraph("Outro aspecto relevante é a elevação do menor resultado observado. No pré-teste, o menor desempenho foi de 37,5%; no pós-teste, o menor desempenho passou a 75,0%. Esse deslocamento sugere que os registros com menor conhecimento inicial também se beneficiaram da experiência simulada.")
    doc.h2("4.10 Comparação entre pré-teste e pós-teste")
    comp_fmt = [comparacao[0]] + [[r[0], pct(r[1]), pct(r[2]), pp(r[3])] for r in comparacao[1:]]
    add_table(doc, "Tabela 12 — Comparação entre pré-teste e pós-teste", comp_fmt, [1800, 2200, 2200, 2400], "Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("Todos os registros apresentaram ganho positivo, variando entre 25,0 e 37,5 pontos percentuais. Esse resultado é coerente com a proposta do jogo, pois a experiência oferece feedback e expõe o participante a exemplos práticos logo antes do pós-teste. Ainda assim, por se tratar de base simulada, os valores devem ser interpretados como demonstração da análise planejada.")
    doc.h2("4.11 Desempenho por categoria temática")
    cat_fmt = [categorias[0]] + [[r[0], r[1], pct(r[2]), pct(r[3]), pp(r[4])] for r in categorias[1:]]
    add_table(doc, "Tabela 13 — Desempenho por categoria temática", cat_fmt, [2300, 1900, 1900, 1900, 1900], "Fonte: elaborado pelo autor com base na planilha de validação.")
    for p in [
        "A maior evolução ocorreu na categoria 2FA, com aumento de 40,0 pontos percentuais. Esse resultado é pedagogicamente relevante porque a autenticação em duas etapas costuma ser compreendida de forma abstrata por muitos usuários. Ao inserir o tema em situações de decisão, o jogo ajuda a demonstrar seu papel como camada adicional de proteção.",
        "A categoria engenharia social apresentou ganho de 35,0 pontos percentuais. Esse dado dialoga diretamente com a proposta do Login Quest, pois o jogo enfatiza pedidos urgentes, mensagens de autoridade e solicitações de dados sensíveis. A melhora nessa categoria sugere que a simulação pode fortalecer a capacidade de desconfiar e validar solicitações.",
        "As categorias senhas e logs/acessos também apresentaram evolução expressiva. Em senhas, a melhora está associada à distinção entre padrões fracos e combinações mais robustas. Em logs e acessos, o ganho indica maior atenção a contexto, horário, origem e permissões. Phishing apresentou menor crescimento, mas ainda positivo, possivelmente porque parte dos participantes já possuía familiaridade prévia com o tema.",
    ]:
        doc.paragraph(p)
    doc.h2("4.12 Percepção e usabilidade")
    perc_fmt = [percepcao[0]] + [[r[0], r[1], num(r[2], 2), r[3]] for r in percepcao[1:]]
    add_table(doc, "Tabela 14 — Percepção e usabilidade", perc_fmt, [1200, 5600, 1200, 1600], "Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("A média geral da escala Likert foi de 4,31, o que representa percepção positiva. As maiores médias ocorreram nos itens de recomendação, clareza das instruções e manutenção do interesse. Isso sugere que a experiência foi percebida como compreensível e engajadora.")
    doc.paragraph("A avaliação positiva da interface é relevante porque o jogo depende de múltiplas janelas e ferramentas. Se a navegação fosse confusa, o conteúdo pedagógico poderia ser prejudicado. Os resultados indicam que, na base analisada, a organização visual não impediu a realização das tarefas.")
    doc.h2("4.13 Análise das respostas abertas")
    add_table(doc, "Tabela 15 — Síntese das respostas abertas", [sugestoes[0]] + sugestoes[1:], [2200, 4000, 1400, 2600], "Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("As respostas abertas reforçam oportunidades de melhoria. A principal categoria foi tutorial e instruções, com oito ocorrências. Embora a versão final já inclua tutorial e manual, esse resultado indica que futuras versões podem apresentar orientações mais interativas, talvez com uma primeira tarefa guiada.")
    doc.paragraph("Outra categoria relevante foi quantidade de desafios. Os participantes demonstraram interesse em mais fases e maior variedade de cenários. Isso confirma a escalabilidade do projeto, pois a arquitetura baseada em bases internas permite adicionar novos itens sem reconstruir a lógica principal.")
    doc.h2("4.14 Discussão dos resultados")
    for p in [
        "A avaliação indica que o Login Quest é coerente com sua finalidade educacional. O jogo não apresenta cibersegurança como lista de regras isoladas; ele coloca o usuário diante de decisões contextualizadas, nas quais cada escolha tem consequência. Essa característica é importante para desenvolver raciocínio prático.",
        "Os resultados de desempenho sugerem que a exposição ao jogo pode contribuir para melhora imediata do conhecimento. Entretanto, o ganho observado deve ser interpretado com cautela, pois o pós-teste foi aplicado logo após a experiência. Para confirmar retenção, seria necessário aplicar novo teste após alguns dias ou semanas.",
        "A percepção positiva reforça que o formato de jogo sério é aceito pelos registros analisados. A média Likert superior a 4 em todos os itens indica que os participantes consideraram a ferramenta clara, útil e relacionada a situações reais. Esse ponto é essencial, pois uma ferramenta educativa pouco aceita tende a ter baixa adesão.",
        "As sugestões abertas não invalidam a proposta; ao contrário, indicam caminhos de amadurecimento. Mais tutorial, mais desafios, melhor legibilidade e relatório mais detalhado são melhorias compatíveis com uma evolução natural do produto.",
    ]:
        doc.paragraph(p)
    doc.h2("4.15 Limitações da avaliação")
    for p in [
        "A primeira limitação é o uso de uma base simulada de validação. Embora a planilha esteja estruturada como se fosse uma coleta real e permita demonstrar o método de análise, ela não substitui uma pesquisa empírica com participantes reais.",
        "A segunda limitação é a ausência de grupo de controle. Sem comparação com cartilha, palestra ou vídeo, não é possível afirmar que o jogo seja superior a métodos tradicionais. O que se observa é apenas o ganho entre pré e pós-teste dentro do próprio procedimento.",
        "A terceira limitação é o caráter imediato do pós-teste. Os resultados indicam aprendizagem ou reforço de curto prazo, mas não demonstram retenção de longo prazo. Uma etapa futura deve incluir teste posterior, aplicado dias ou semanas após o uso do jogo.",
        "A quarta limitação envolve a autopercepção. Itens Likert são úteis para avaliar aceitação, mas dependem da percepção subjetiva do participante. Por isso, devem ser analisados em conjunto com dados objetivos de desempenho e registros de interação no jogo.",
    ]:
        doc.paragraph(p)
    doc.h2("4.16 Síntese da avaliação")
    doc.paragraph("De forma geral, a avaliação estruturada do Login Quest apresentou resultados positivos na base simulada: ganho médio de 30,4 pontos percentuais, melhoria em todas as categorias temáticas e média Likert geral de 4,31. Esses dados indicam potencial educativo e boa aceitação, mas exigem confirmação por estudo empírico real, com amostra maior, grupo de controle e teste de retenção.")

    # CONCLUSÃO
    doc.h1("5 CONCLUSÃO")
    for p in [
        "Este trabalho apresentou o desenvolvimento do Login Quest, um jogo sério voltado à conscientização em cibersegurança. A proposta foi motivada pela necessidade de treinar usuários para reconhecer riscos em situações práticas, considerando que o fator humano permanece como uma das principais fragilidades da segurança digital.",
        "A versão final do jogo implementa um ambiente de trabalho simulado, no qual o jogador atua como analista da CyProtect. Ao longo de dias progressivos, o sistema apresenta e-mails, chamados, pedidos de senha, solicitações de acesso, anexos, logs e mensagens de chat. Cada módulo foi planejado para trabalhar um aspecto específico da segurança, mas todos compartilham a mesma lógica pedagógica: observar evidências, decidir e receber feedback.",
        "Do ponto de vista técnico, o projeto demonstrou a viabilidade de construir um jogo educacional completo em GameMaker Studio. A implementação utiliza GML, objetos, eventos, sprites e bases internas estruturadas em arrays e structs. Essa organização permitiu criar um artefato funcional, com interface em janelas, progressão por dias, sistema de pontuação, reputação e relatório.",
        "A avaliação inicial, baseada em planilha simulada com 30 registros anônimos, indicou resultados favoráveis. O desempenho médio passou de 58,8% para 89,2%, com ganho de 30,4 pontos percentuais. A percepção dos participantes também foi positiva, com média geral Likert de 4,31. Esses resultados sugerem que o Login Quest possui potencial como ferramenta complementar de educação em cibersegurança.",
        "Apesar disso, o trabalho reconhece limitações importantes. A base utilizada nesta versão é simulada, não houve grupo de controle real e não foi avaliada retenção de longo prazo. Portanto, os resultados devem ser entendidos como demonstração metodológica e indício preliminar, não como prova definitiva de eficácia.",
        "Como trabalhos futuros, recomenda-se aplicar o instrumento com participantes reais, comparar o jogo com métodos tradicionais, coletar métricas automáticas de interação, expandir o banco de desafios, adicionar novos cenários de ameaças digitais e desenvolver um relatório final mais personalizado. Também é possível evoluir o Login Quest para versões web ou mobile, ampliando seu alcance educacional.",
        "Conclui-se que o Login Quest atende ao objetivo de transformar conteúdos de cibersegurança em uma experiência interativa, prática e contextualizada. O artefato aproxima o usuário de situações realistas de decisão e reforça a ideia de que segurança digital depende não apenas de tecnologia, mas também de atenção, análise e comportamento responsável.",
    ]:
        doc.paragraph(p)

    doc.h1("REFERÊNCIAS")
    if refs:
        for ref in refs:
            doc.paragraph(ref)
    else:
        for ref in [
            "YOYO GAMES. GameMaker Manual. Disponível em: https://manual.gamemaker.io. Acesso em: 29 maio 2026.",
            "MITNICK, Kevin. The Art of Deception. Wiley, 2002.",
            "VERIZON. Data Breach Investigations Report. Verizon, 2024.",
        ]:
            doc.paragraph(ref)

    # APÊNDICES
    doc.h1("APÊNDICE A — INSTRUMENTO DE COLETA")
    doc.paragraph("Este apêndice apresenta a estrutura do instrumento utilizado para coleta. O formulário foi pensado para preservar anonimato, medir conhecimento antes e depois da experiência e registrar percepção de uso.")
    doc.h2("Termo de consentimento")
    doc.paragraph("Declaro que aceito participar voluntariamente da avaliação do jogo Login Quest, ciente de que as respostas serão tratadas de forma anônima e utilizadas exclusivamente para fins acadêmicos. Declaro também compreender que não serão coletados dados diretamente identificáveis.")
    doc.h2("Perfil do participante")
    add_bullets(doc, [
        "Código anônimo do participante.",
        "Faixa etária.",
        "Frequência de uso de computador.",
        "Frequência com jogos digitais.",
        "Conhecimento prévio em cibersegurança, em escala de 1 a 5.",
        "Participação anterior em treinamento sobre segurança digital.",
    ])
    doc.h2("Pré-teste e pós-teste")
    doc.table(gabarito, [1500, 5600, 2600])
    add_source(doc)
    doc.h2("Instrução para jogar")
    doc.paragraph("Acesse o jogo Login Quest, utilize-o por aproximadamente 10 a 20 minutos e interaja com os desafios apresentados. Após jogar, retorne ao formulário para responder ao pós-teste e ao questionário de percepção.")
    doc.h2("Perguntas Likert")
    for row in percepcao[1:]:
        doc.paragraph(f"{row[0]} — {row[1]}")
    doc.h2("Perguntas abertas")
    add_bullets(doc, [
        "Que melhoria você sugere para o jogo?",
        "Qual parte do jogo mais contribuiu para seu aprendizado?",
    ])

    doc.h1("APÊNDICE B — BASE BRUTA ANONIMIZADA")
    doc.paragraph("A base bruta anonimizada foi exportada do formulário e organizada em planilha eletrônica. Devido ao número de colunas, apresenta-se a seguir uma versão estruturada com os campos utilizados na análise, sem informações diretamente identificáveis.")
    doc.table(recorte, [1200, 1500, 1600, 2700, 1600, 1200, 1200])

    doc.h1("APÊNDICE C — CÁLCULO DAS PONTUAÇÕES")
    doc.paragraph("Este apêndice apresenta os acertos por participante, percentuais de pré e pós-teste, ganho individual, médias por categoria e médias da escala Likert.")
    pont_resumo = [["Participante", "Acertos pré", "Pré (%)", "Acertos pós", "Pós (%)", "Ganho (p.p.)"]]
    for r in pontuacao[1:]:
        pont_resumo.append([r[0], r[1], pct(r[2]), r[3], pct(r[4]), pp(r[5])])
    doc.table(pont_resumo, [1500, 1500, 1500, 1500, 1500, 1800])
    doc.paragraph("Médias por categoria temática:")
    doc.table(cat_fmt, [2300, 1900, 1900, 1900, 1900])
    doc.paragraph("Médias da escala Likert:")
    doc.table(perc_fmt, [1200, 5600, 1200, 1600])

    doc.save(OUT_WORKSPACE)
    print(OUT_WORKSPACE)


if __name__ == "__main__":
    main()
