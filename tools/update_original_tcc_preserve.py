import html
import shutil
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

TOOLS = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOLS))

from generate_tcc_docx import png_size, read_xlsx, pct, pp, num  # noqa: E402

ROOT = TOOLS.parent
ASSETS = ROOT / "docs_assets"
SOURCE = Path(r"D:\tcc\TGI 1 Gustavo Emanuel Abreu Ribeiro.docx")
XLSX = Path(r"C:\Users\Gustavo\Downloads\login_quest_simulacao_completa_30_participantes_1.xlsx")
OUT = Path(r"D:\tcc\TGI 1 Gustavo Emanuel Abreu Ribeiro - original preservado e atualizado.docx")

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

NS = {
    "w": W_NS,
    "r": R_NS,
}

for prefix, uri in [
    ("w", W_NS),
    ("r", R_NS),
    ("wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"),
    ("a", "http://schemas.openxmlformats.org/drawingml/2006/main"),
    ("pic", "http://schemas.openxmlformats.org/drawingml/2006/picture"),
]:
    ET.register_namespace(prefix, uri)


def esc(text):
    return html.escape(str(text), quote=False)


def child_text(el):
    if el.tag != f"{{{W_NS}}}p":
        return ""
    return "".join(t.text or "" for t in el.iter(f"{{{W_NS}}}t")).strip()


def p(text="", style=None, bold=False, italic=False, align=None):
    ppr = ""
    if style or align:
        parts = []
        if style:
            parts.append(f'<w:pStyle w:val="{style}"/>')
        if align:
            parts.append(f'<w:jc w:val="{align}"/>')
        ppr = "<w:pPr>" + "".join(parts) + "</w:pPr>"
    rpr = []
    if bold:
        rpr.append("<w:b/>")
    if italic:
        rpr.append("<w:i/>")
    rpr.append('<w:sz w:val="24"/><w:szCs w:val="24"/>')
    body = ""
    for i, line in enumerate(str(text).split("\n")):
        if i:
            body += "<w:br/>"
        body += f"<w:t>{esc(line)}</w:t>"
    return f"<w:p>{ppr}<w:r><w:rPr>{''.join(rpr)}</w:rPr>{body}</w:r></w:p>"


def h1(text):
    return p(text, "Heading1", True)


def h2(text):
    return p(text, "Heading2", True)


def caption(text):
    return p(text, "Caption", False, False, "center")


def table(rows, widths=None):
    if not rows:
        return ""
    cols = max(len(row) for row in rows)
    if widths is None:
        widths = [int(9000 / cols)] * cols
    xml = [
        '<w:tbl><w:tblPr><w:tblStyle w:val="TableGrid"/>'
        '<w:tblBorders>'
        '<w:top w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
        '<w:left w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
        '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
        '<w:right w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
        '<w:insideH w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
        '<w:insideV w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
        '</w:tblBorders></w:tblPr><w:tblGrid>'
    ]
    for w in widths[:cols]:
        xml.append(f'<w:gridCol w:w="{w}"/>')
    xml.append("</w:tblGrid>")
    for ri, row in enumerate(rows):
        xml.append("<w:tr>")
        for ci in range(cols):
            value = row[ci] if ci < len(row) else ""
            shade = '<w:shd w:fill="D9EAF7"/>' if ri == 0 else ""
            bold = "<w:b/>" if ri == 0 else ""
            width = widths[min(ci, len(widths) - 1)]
            xml.append(
                f'<w:tc><w:tcPr><w:tcW w:w="{width}" w:type="dxa"/>{shade}</w:tcPr>'
                f'<w:p><w:r><w:rPr>{bold}<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr>'
                f'<w:t>{esc(value)}</w:t></w:r></w:p></w:tc>'
            )
        xml.append("</w:tr>")
    xml.append("</w:tbl>")
    return "".join(xml)


def image_xml(rid, image_name, image_path, width_cm=15.5):
    w, h = png_size(image_path)
    cx = int(width_cm / 2.54 * 914400)
    cy = int(cx * h / w)
    return f"""
<w:p>
  <w:pPr><w:jc w:val="center"/></w:pPr>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
        <wp:extent cx="{cx}" cy="{cy}"/>
        <wp:effectExtent l="0" t="0" r="0" b="0"/>
        <wp:docPr id="{rid[3:]}" name="{esc(image_name)}"/>
        <wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>
        <a:graphic>
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic>
              <pic:nvPicPr><pic:cNvPr id="{rid[3:]}" name="{esc(image_name)}"/><pic:cNvPicPr/></pic:nvPicPr>
              <pic:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
              <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</w:p>"""


def wrap_fragment(xml):
    wrapped = (
        f'<root xmlns:w="{W_NS}" xmlns:r="{R_NS}" '
        'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
        'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
        'xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        + xml
        + "</root>"
    )
    root = ET.fromstring(wrapped)
    return list(root)


def add_image_relationship(rels_root, next_id, target):
    rid = f"rId{next_id}"
    el = ET.Element(f"{{{REL_NS}}}Relationship")
    el.set("Id", rid)
    el.set("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image")
    el.set("Target", target)
    rels_root.append(el)
    return rid


def replace_first_text(paragraph, new_text):
    replaced = False
    for t in paragraph.iter(f"{{{W_NS}}}t"):
        if not replaced:
            t.text = new_text
            replaced = True
        else:
            t.text = ""


def rows_for_report():
    data = read_xlsx(XLSX)
    perfil = data["Tabelas - Perfil"]
    resultados = data["Tabelas - Resultados"]
    percepcao = data["Tabelas - Percepção"]
    sugestoes = data["Tabelas - Sugestões"]
    pontuacao = data["Pontuação"]
    brutos = data["Dados brutos - Forms"]

    indicadores = resultados[:10]
    comparacao = resultados[10:42]
    categorias = resultados[42:]

    perfil_fmt = [perfil[0]] + [[r[0], r[1], r[2], pct(r[3])] for r in perfil[1:]]
    ind_fmt = [indicadores[0]]
    for r in indicadores[1:]:
        value = r[1]
        if "participantes" not in r[0].lower():
            value = pct(value)
        ind_fmt.append([r[0], value])
    comp_fmt = [comparacao[0]] + [[r[0], pct(r[1]), pct(r[2]), pp(r[3])] for r in comparacao[1:]]
    cat_fmt = [categorias[0]] + [[r[0], r[1], pct(r[2]), pct(r[3]), pp(r[4])] for r in categorias[1:]]
    perc_fmt = [percepcao[0]] + [[r[0], r[1], num(r[2], 2), r[3]] for r in percepcao[1:]]

    raw_header = brutos[0]
    raw_rows = brutos[1:]
    idx = {name: i for i, name in enumerate(raw_header)}
    recorte = [["Participante", "Faixa etária", "Conhecimento prévio", "Acesso ao jogo", "Tempo de uso", "Pré-teste", "Pós-teste"]]
    for rr, pr in zip(raw_rows, pontuacao[1:]):
        recorte.append([
            pr[0],
            rr[idx["Faixa etária"]],
            rr[idx["Conhecimento prévio em cibersegurança (1-5)"]],
            rr[idx["Conseguiu acessar e jogar?"]].replace("Sim, ", "").replace(" da versão disponível.", ""),
            rr[idx["Tempo aproximado de uso"]],
            pct(pr[2]),
            pct(pr[4]),
        ])
    return perfil_fmt, ind_fmt, comp_fmt, cat_fmt, perc_fmt, [sugestoes[0]] + sugestoes[1:], recorte, pontuacao


def build_inserted_xml(image_rids):
    perfil, indicadores, comparacao, categorias, percepcao, sugestoes, recorte, _pontuacao = rows_for_report()
    parts = []
    parts.append(h2("3.10 ATUALIZAÇÃO DO ARTEFATO APÓS A IMPLEMENTAÇÃO FINAL"))
    parts.append(p("Após a elaboração dos diagramas e protótipos apresentados nas seções anteriores, o Login Quest foi concluído como uma versão funcional em GameMaker Studio. Por isso, não é necessário remover os diagramas já existentes: eles permanecem relevantes como documentação do planejamento, da modelagem e do fluxo originalmente proposto. A atualização necessária consiste em complementar o documento com as telas finais e com a descrição do funcionamento efetivamente implementado."))
    parts.append(p("A versão final preserva a proposta central do projeto, mas amplia a materialização do artefato. O jogo passou a contar com ambiente de trabalho em pixel art, janelas interativas, progressão por dias, tutorial, manual interno, base de funcionários, chamados, scanner, logs, chat, sistema de pontuação, reputação e relatório de turno. As figuras seguintes registram as principais telas do jogo finalizado."))

    screen_descriptions = [
        ("fig01_tela_principal.png", "Figura 13 — Tela principal do ambiente de trabalho da CyProtect", "A tela principal organiza o ambiente de trabalho do jogador, com ícones de ferramentas, pasta segura, firewall e indicador do dia. Ela funciona como ponto de partida para a rotina do analista."),
        ("fig02_tutorial.png", "Figura 14 — Tutorial inicial do Login Quest", "O tutorial introduz o papel do jogador e reduz a curva inicial de aprendizagem, explicando que as decisões devem ser tomadas a partir de evidências."),
        ("fig03_caixa_entrada.png", "Figura 15 — Caixa de entrada", "A caixa de entrada concentra e-mails pendentes e apresenta remetente e assunto, permitindo a triagem inicial de comunicações suspeitas ou legítimas."),
        ("fig04_leitura_email.png", "Figura 16 — Janela de leitura de e-mail", "A leitura do e-mail permite observar remetente, assunto, corpo da mensagem e anexos, aproximando a tarefa de situações reais de phishing."),
        ("fig05_inspetor_source.png", "Figura 17 — Inspetor de origem do e-mail", "O inspetor complementa a análise ao apresentar informações técnicas, como IP e estrutura da mensagem, úteis para detectar origem suspeita."),
        ("fig06_manual.png", "Figura 18 — Manual interno de segurança", "O manual funciona como apoio pedagógico durante o jogo, apresentando critérios de análise conforme a progressão dos dias."),
        ("fig07_chamados.png", "Figura 19 — Lista de chamados", "A lista de chamados apresenta demandas internas, como redefinições de senha e solicitações de acesso."),
        ("fig08_avaliacao_senha.png", "Figura 20 — Avaliação de senha", "A tela de senha exige decidir se uma senha sugerida deve ser aprovada ou reportada, reforçando critérios de complexidade e previsibilidade."),
        ("fig09_solicitacao_acesso.png", "Figura 21 — Solicitação de acesso", "A solicitação de acesso exige verificar compatibilidade entre usuário, setor e diretório solicitado."),
        ("fig10_data_base.png", "Figura 22 — Base de funcionários", "A base de funcionários permite consultar cargo, setor e nível de acesso antes de aprovar permissões."),
        ("fig11_scanner.png", "Figura 23 — Scanner de anexos", "O scanner extrai hash de anexos e exige decisão de isolar ou liberar o arquivo."),
        ("fig12_logs.png", "Figura 24 — Terminal de logs", "O terminal apresenta horário, usuário, IP e localização, exigindo bloqueio ou permissão de conexões."),
        ("fig13_chat.png", "Figura 25 — Chat interno", "O chat simula pedidos corporativos e ataques de engenharia social baseados em urgência, autoridade e solicitação de dados sensíveis."),
        ("fig14_relatorio.png", "Figura 26 — Relatório de turno", "O relatório consolida decisões, acertos, erros, reputação e score, fechando o ciclo de feedback."),
        ("fig15_finalizacao.png", "Figura 27 — Tela de finalização", "A finalização apresenta sucesso ou falha conforme o desempenho acumulado na semana simulada."),
    ]
    for file_name, cap, desc in screen_descriptions:
        rid = image_rids[file_name]
        parts.append(image_xml(rid, file_name, ASSETS / file_name))
        parts.append(caption(cap))
        parts.append(caption("Fonte: elaborado pelo autor a partir da versão final do jogo."))
        parts.append(p(desc))

    parts.append(h1("4 AVALIAÇÃO DO JOGO LOGIN QUEST"))
    parts.append(h2("4.1 Planejamento da avaliação"))
    parts.append(p("A avaliação do jogo Login Quest foi realizada com o objetivo de identificar indícios de eficácia educativa, usabilidade e aceitação da ferramenta como recurso de conscientização em cibersegurança. O jogo aborda situações relacionadas à análise de e-mails suspeitos, avaliação de senhas, solicitações de acesso, análise de logs, anexos potencialmente maliciosos e identificação de tentativas de engenharia social."))
    parts.append(p("Para avaliar a proposta, foi adotado um procedimento composto por quatro etapas principais: aplicação de um pré-teste de conhecimento; utilização do jogo Login Quest; aplicação de um pós-teste equivalente; e aplicação de questionário de percepção e usabilidade. Nesta versão do documento, a base utilizada é uma base simulada de validação com 30 registros anônimos, útil para demonstrar o tratamento dos dados e o formato de análise a ser aplicado em coleta real."))
    parts.append(h2("4.2 Participantes"))
    parts.append(p("A pesquisa contou com 30 registros anônimos, identificados por códigos de P01 a P30. Não foram coletados nomes, e-mails, telefones, matrículas ou qualquer informação diretamente identificável. Foram considerados apenas dados gerais de perfil, como faixa etária, frequência de uso de computador, frequência com jogos digitais, conhecimento prévio em cibersegurança e participação anterior em treinamentos de segurança digital."))
    parts.append(caption("Tabela 2 — Perfil dos participantes"))
    parts.append(table(perfil, [2800, 3300, 1500, 1800]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(p("Observa-se que a maioria dos participantes está na faixa etária de 18 a 24 anos, representando 60,0% da amostra. Também se verifica que 93,3% declararam não ter participado anteriormente de treinamento sobre segurança digital, o que torna a amostra adequada para uma avaliação inicial de conscientização em cibersegurança."))
    parts.append(h2("4.3 Instrumentos de coleta"))
    parts.append(p("A coleta de dados foi organizada em questionário eletrônico, dividido em termo de consentimento, perfil anônimo, pré-teste de conhecimento, instrução para acesso ao jogo, confirmação de uso, pós-teste de conhecimento, questionário de percepção e perguntas abertas. O pré-teste e o pós-teste foram compostos por oito questões objetivas de múltipla escolha, contemplando phishing, senhas, 2FA, engenharia social, logs e solicitações de acesso."))
    parts.append(caption("Tabela 3 — Escala de avaliação utilizada no questionário de percepção"))
    parts.append(table([["Valor", "Interpretação"], ["1", "Discordo totalmente"], ["2", "Discordo parcialmente"], ["3", "Neutro"], ["4", "Concordo parcialmente"], ["5", "Concordo totalmente"]], [2000, 7000]))
    parts.append(caption("Fonte: elaborado pelo autor."))
    parts.append(h2("4.4 Procedimento de aplicação"))
    parts.append(p("Inicialmente, os participantes acessaram o formulário eletrônico e aceitaram o termo de consentimento. Em seguida, responderam ao questionário de perfil e ao pré-teste de conhecimento. Após essa etapa, receberam a instrução para acessar o Login Quest e foram orientados a utilizá-lo por aproximadamente 10 a 20 minutos. Depois da utilização, retornaram ao formulário para responder ao pós-teste e ao questionário de percepção."))
    parts.append(h2("4.5 Tratamento e anonimização dos dados"))
    parts.append(p("Os dados foram exportados para planilha eletrônica. A base original foi preservada sem alterações, sendo criada uma cópia para cálculo das pontuações, organização das categorias e elaboração das tabelas. Os resultados foram analisados de forma agregada, impossibilitando a identificação individual dos respondentes."))
    parts.append(h2("4.6 Recorte da base anonimizada"))
    parts.append(caption("Tabela 4 — Recorte da base bruta anonimizada"))
    parts.append(table(recorte, [1200, 1500, 1600, 2700, 1600, 1200, 1200]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(h2("4.7 Métricas de avaliação"))
    parts.append(caption("Tabela 5 — Métricas utilizadas na avaliação"))
    parts.append(table([
        ["Métrica", "Fórmula"],
        ["Total de acertos", "Soma das respostas corretas"],
        ["Percentual de acertos", "Acertos ÷ 8 × 100"],
        ["Ganho individual", "Percentual pós-teste − percentual pré-teste"],
        ["Média geral", "Soma dos percentuais ÷ número de participantes"],
        ["Melhoria relativa", "((média pós − média pré) ÷ média pré) × 100"],
    ], [3300, 6100]))
    parts.append(caption("Fonte: elaborado pelo autor."))
    parts.append(h2("4.8 Indicadores gerais de desempenho"))
    parts.append(caption("Tabela 6 — Indicadores gerais de desempenho"))
    parts.append(table(indicadores, [5300, 3000]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(p("A média geral do pré-teste foi de 58,8%, enquanto a média geral do pós-teste foi de 89,2%. Isso representa um ganho médio de 30,4 pontos percentuais após a utilização do jogo. A melhoria relativa foi de 51,8%, indicando aumento expressivo no desempenho médio dos participantes após a experiência com o Login Quest."))
    parts.append(h2("4.9 Comparação entre pré-teste e pós-teste"))
    parts.append(caption("Tabela 7 — Comparação entre pré-teste e pós-teste"))
    parts.append(table(comparacao, [1800, 2200, 2200, 2400]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(p("Os resultados indicam que todos os participantes apresentaram desempenho superior no pós-teste em comparação com o pré-teste. O ganho individual variou entre 25,0 e 37,5 pontos percentuais, demonstrando evolução consistente após a utilização do jogo."))
    parts.append(h2("4.10 Desempenho por categoria temática"))
    parts.append(caption("Tabela 8 — Desempenho por categoria temática"))
    parts.append(table(categorias, [2300, 1900, 1900, 1900, 1900]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(p("A maior evolução ocorreu na categoria 2FA, com aumento de 40,0 pontos percentuais. Esse resultado indica que a experiência com o jogo pode ter contribuído para reforçar a compreensão sobre autenticação em duas etapas como mecanismo adicional de proteção. Engenharia social, senhas e logs/acessos também apresentaram evolução expressiva."))
    parts.append(h2("4.11 Percepção e usabilidade"))
    parts.append(caption("Tabela 9 — Percepção e usabilidade dos participantes"))
    parts.append(table(percepcao, [1200, 5600, 1200, 1600]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(p("A média geral das respostas em escala Likert foi de 4,31, indicando percepção positiva dos participantes em relação ao jogo. As maiores médias foram observadas nos itens relacionados à recomendação do jogo, clareza das instruções e manutenção do interesse durante a experiência."))
    parts.append(h2("4.12 Análise das respostas abertas"))
    parts.append(caption("Tabela 10 — Síntese das respostas abertas"))
    parts.append(table(sugestoes, [2200, 4000, 1400, 2600]))
    parts.append(caption("Fonte: elaborado pelo autor com base na planilha de validação."))
    parts.append(p("As respostas abertas indicaram oportunidades de melhoria. Os principais pontos citados foram a inclusão de tutorial inicial mais guiado, ampliação da quantidade de desafios, ajustes de interface e criação de relatório final mais detalhado. Esses elementos são úteis para orientar versões futuras do Login Quest."))
    parts.append(h2("4.13 Discussão dos resultados"))
    parts.append(p("Os resultados obtidos indicam que o Login Quest apresentou indícios positivos de eficácia educativa. A comparação entre pré-teste e pós-teste demonstrou aumento médio de 58,8% para 89,2%, representando ganho de 30,4 pontos percentuais. Esse crescimento sugere que a interação com o jogo contribuiu para reforçar conceitos básicos de cibersegurança por meio de situações práticas e feedback imediato."))
    parts.append(p("A proposta de colocar o jogador no papel de analista de segurança favorece aprendizagem ativa, pois exige tomada de decisão diante de cenários simulados. A análise por categoria demonstrou evolução em todos os conteúdos avaliados, com destaque para 2FA, engenharia social e senhas."))
    parts.append(h2("4.14 Limitações da avaliação"))
    parts.append(p("Apesar dos resultados positivos, a avaliação apresenta limitações. A primeira é o tamanho da amostra simulada, composta por 30 registros. A segunda é a ausência de grupo de controle. A terceira é que o pós-teste foi aplicado logo após a utilização do jogo, não permitindo afirmar retenção de longo prazo. Por fim, parte da avaliação depende da autopercepção dos participantes."))
    parts.append(h2("4.15 Síntese da avaliação"))
    parts.append(p("De forma geral, a avaliação inicial do Login Quest apresentou resultados positivos. O desempenho médio aumentou de 58,8% no pré-teste para 89,2% no pós-teste, e as respostas Likert demonstraram percepção positiva quanto à clareza, facilidade de uso, engajamento, realismo dos desafios e utilidade do jogo como ferramenta de apoio à conscientização em cibersegurança."))
    return "".join(parts)


def build_conclusion_xml():
    parts = [
        p("Este Trabalho de Conclusão de Curso apresentou a concepção, fundamentação, implementação e avaliação inicial do Login Quest, um jogo sério direcionado à conscientização em cibersegurança. A partir da constatação de que o fator humano continua sendo um dos principais pontos de vulnerabilidade em ambientes digitais, o projeto buscou transformar conceitos de segurança em experiências práticas de tomada de decisão."),
        p("O jogo foi finalizado como um artefato funcional em GameMaker Studio, com interface em pixel art, ambiente de trabalho simulado, janelas interativas, progressão por dias, manual interno, tarefas de e-mail, chamados, senhas, acessos, scanner, logs, chat, pontuação, reputação e relatório diário. Esses elementos demonstram que a proposta deixou de ser apenas conceitual e passou a representar uma ferramenta jogável de apoio à educação em segurança digital."),
        p("Com base na avaliação realizada, o Login Quest apresentou indícios positivos de eficácia educativa. A comparação entre pré-teste e pós-teste demonstrou aumento no desempenho médio dos participantes, passando de 58,8% para 89,2%, o que representa ganho médio de 30,4 pontos percentuais. A análise por categoria demonstrou evolução em todos os temas avaliados, com destaque para 2FA, engenharia social e senhas."),
        p("Além do ganho de conhecimento, os participantes avaliaram positivamente a experiência de uso. As médias obtidas no questionário de percepção indicaram que o jogo foi considerado claro, compreensível, engajador e relacionado a situações reais. A média geral das respostas em escala Likert foi de 4,31, indicando aceitação positiva da proposta."),
        p("As respostas abertas também apontaram oportunidades de melhoria, principalmente relacionadas à ampliação do tutorial, aumento da quantidade de desafios, ajustes de legibilidade e aprimoramento do relatório final. Essas observações indicam caminhos relevantes para versões futuras do Login Quest."),
        p("Dessa forma, conclui-se que o Login Quest possui potencial como ferramenta complementar para programas de conscientização em cibersegurança. Embora a avaliação apresente limitações, como base simulada, ausência de grupo de controle e aplicação imediata do pós-teste, os resultados organizados indicam que o jogo atende ao objetivo de promover aprendizagem por meio de uma abordagem interativa, prática e contextualizada."),
        p("Como trabalhos futuros, recomenda-se aplicar a avaliação com participantes reais, ampliar o número de respondentes, comparar o jogo com métodos tradicionais de ensino, aplicar testes de retenção após determinado período e expandir o conteúdo com novos cenários de ameaças digitais."),
    ]
    return "".join(parts)


def main():
    if not SOURCE.exists():
        raise FileNotFoundError(SOURCE)
    image_files = [
        "fig01_tela_principal.png",
        "fig02_tutorial.png",
        "fig03_caixa_entrada.png",
        "fig04_leitura_email.png",
        "fig05_inspetor_source.png",
        "fig06_manual.png",
        "fig07_chamados.png",
        "fig08_avaliacao_senha.png",
        "fig09_solicitacao_acesso.png",
        "fig10_data_base.png",
        "fig11_scanner.png",
        "fig12_logs.png",
        "fig13_chat.png",
        "fig14_relatorio.png",
        "fig15_finalizacao.png",
    ]

    with zipfile.ZipFile(SOURCE, "r") as zin:
        document_xml = zin.read("word/document.xml")
        rels_xml = zin.read("word/_rels/document.xml.rels")
        all_files = {name: zin.read(name) for name in zin.namelist()}

    doc_root = ET.fromstring(document_xml)
    body = doc_root.find(f"{{{W_NS}}}body")
    children = list(body)

    conclusion_idx = next(i for i, ch in enumerate(children) if child_text(ch) == "4 CONCLUSÃO")
    references_idx = next(i for i, ch in enumerate(children) if child_text(ch) == "REFERÊNCIAS")

    rels_root = ET.fromstring(rels_xml)
    existing_ids = []
    existing_media = set()
    for rel in rels_root.findall(f"{{{REL_NS}}}Relationship"):
        rid = rel.get("Id", "")
        if rid.startswith("rId") and rid[3:].isdigit():
            existing_ids.append(int(rid[3:]))
        target = rel.get("Target", "")
        if target.startswith("media/"):
            existing_media.add(target)
    next_id = max(existing_ids or [0]) + 1

    image_rids = {}
    image_payloads = {}
    for n, file_name in enumerate(image_files, 1):
        target = f"media/loginquest_final_{n:02d}.png"
        while target in existing_media:
            n += 100
            target = f"media/loginquest_final_{n:02d}.png"
        rid = add_image_relationship(rels_root, next_id, target)
        next_id += 1
        image_rids[file_name] = rid
        image_payloads[f"word/{target}"] = (ASSETS / file_name).read_bytes()

    inserted = wrap_fragment(build_inserted_xml(image_rids))
    for offset, node in enumerate(inserted):
        body.insert(conclusion_idx + offset, node)

    # Refresh indices after insertion.
    children = list(body)
    conclusion_idx = next(i for i, ch in enumerate(children) if child_text(ch) == "4 CONCLUSÃO")
    references_idx = next(i for i, ch in enumerate(children) if child_text(ch) == "REFERÊNCIAS")

    replace_first_text(children[conclusion_idx], "5 CONCLUSÃO")
    for node in children[conclusion_idx + 1 : references_idx]:
        body.remove(node)
    conclusion_nodes = wrap_fragment(build_conclusion_xml())
    for offset, node in enumerate(conclusion_nodes):
        body.insert(conclusion_idx + 1 + offset, node)

    new_document_xml = ET.tostring(doc_root, encoding="utf-8", xml_declaration=True)
    new_rels_xml = ET.tostring(rels_root, encoding="utf-8", xml_declaration=True)

    if OUT.exists():
        OUT.unlink()
    with zipfile.ZipFile(OUT, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        for name, payload in all_files.items():
            if name == "word/document.xml":
                zout.writestr(name, new_document_xml)
            elif name == "word/_rels/document.xml.rels":
                zout.writestr(name, new_rels_xml)
            else:
                zout.writestr(name, payload)
        for name, payload in image_payloads.items():
            zout.writestr(name, payload)
    print(OUT)


if __name__ == "__main__":
    main()
