import html
import os
import re
import struct
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "docs_assets"
XLSX = Path(r"C:\Users\Gustavo\Downloads\login_quest_simulacao_completa_30_participantes_1.xlsx")
OLD_DOCX = Path(r"C:\Users\Gustavo\Documents\tcc\TGI 1 Gustavo Emanuel Abreu Ribeiro.docx")
OUT_DOCX = ROOT / "TGI_1_Gustavo_Emanuel_Abreu_Ribeiro_atualizado_Login_Quest.docx"

NS_SHEET = {
    "a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
}


def esc(text):
    return html.escape(str(text), quote=False)


def read_xlsx(path):
    with zipfile.ZipFile(path) as z:
        shared = []
        if "xl/sharedStrings.xml" in z.namelist():
            root = ET.fromstring(z.read("xl/sharedStrings.xml"))
            for si in root.findall("a:si", NS_SHEET):
                shared.append(
                    "".join(
                        t.text or ""
                        for t in si.iter("{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t")
                    )
                )

        wb = ET.fromstring(z.read("xl/workbook.xml"))
        rels = ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))
        rid_to_target = {rel.attrib["Id"]: rel.attrib["Target"] for rel in rels}
        out = {}
        for sh in wb.findall("a:sheets/a:sheet", NS_SHEET):
            name = sh.attrib["name"]
            rid = sh.attrib["{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"]
            target = rid_to_target[rid]
            ws_path = "xl/" + target.lstrip("/") if not target.startswith("xl/") else target
            root = ET.fromstring(z.read(ws_path))
            rows = []
            for row in root.findall("a:sheetData/a:row", NS_SHEET):
                cells = {}
                max_col = 0
                for c in row.findall("a:c", NS_SHEET):
                    ref = c.attrib.get("r", "A1")
                    letters = "".join(ch for ch in ref if ch.isalpha())
                    idx = 0
                    for ch in letters:
                        idx = idx * 26 + ord(ch) - 64
                    max_col = max(max_col, idx)
                    value_node = c.find("a:v", NS_SHEET)
                    val = "" if value_node is None else value_node.text
                    if c.attrib.get("t") == "s" and val != "":
                        val = shared[int(val)]
                    cells[idx] = val
                rows.append([cells.get(i, "") for i in range(1, max_col + 1)])
            out[name] = rows
        return out


def old_references(path):
    if not path.exists():
        return []
    ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
    with zipfile.ZipFile(path) as z:
        root = ET.fromstring(z.read("word/document.xml"))
    paras = []
    for p in root.findall(".//w:p", ns):
        texts = []
        for node in p.iter():
            if node.tag == "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t":
                texts.append(node.text or "")
            elif node.tag == "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}tab":
                texts.append("\t")
            elif node.tag == "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}br":
                texts.append("\n")
        txt = "".join(texts).strip()
        if txt:
            paras.append(txt)
    if "REFERÊNCIAS" in paras:
        return paras[paras.index("REFERÊNCIAS") + 1 :]
    return []


def pct(value):
    try:
        v = float(str(value).replace(",", "."))
    except ValueError:
        return str(value)
    return f"{v * 100:.1f}%".replace(".", ",")


def pp(value):
    try:
        v = float(str(value).replace(",", "."))
    except ValueError:
        return str(value)
    return f"+{v * 100:.1f} p.p.".replace(".", ",")


def num(value, digits=2):
    try:
        v = float(str(value).replace(",", "."))
    except ValueError:
        return str(value)
    return f"{v:.{digits}f}".replace(".", ",")


def png_size(path):
    with open(path, "rb") as f:
        sig = f.read(24)
    if sig[:8] == b"\x89PNG\r\n\x1a\n":
        return struct.unpack(">II", sig[16:24])
    return (1200, 800)


class DocxBuilder:
    def __init__(self):
        self.body = []
        self.rels = []
        self.content_overrides = []
        self.next_rid = 1
        self.next_pic_id = 1

    def add(self, xml):
        self.body.append(xml)

    def page_break(self):
        self.add('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

    def paragraph(self, text="", style=None, align=None, bold=False, italic=False, size=24):
        ppr = []
        if style:
            ppr.append(f'<w:pStyle w:val="{style}"/>')
        if align:
            ppr.append(f'<w:jc w:val="{align}"/>')
        rpr = [f'<w:sz w:val="{size}"/>', f'<w:szCs w:val="{size}"/>']
        if bold:
            rpr.append("<w:b/>")
        if italic:
            rpr.append("<w:i/>")
        xml = "<w:p>"
        if ppr:
            xml += "<w:pPr>" + "".join(ppr) + "</w:pPr>"
        xml += "<w:r><w:rPr>" + "".join(rpr) + "</w:rPr>"
        for part in str(text).split("\n"):
            xml += f"<w:t>{esc(part)}</w:t><w:br/>"
        if xml.endswith("<w:br/>"):
            xml = xml[:-7]
        xml += "</w:r></w:p>"
        self.add(xml)

    def title(self, text):
        self.paragraph(text, style="Title", align="center", bold=True, size=28)

    def h1(self, text):
        self.paragraph(text, style="Heading1", bold=True, size=28)

    def h2(self, text):
        self.paragraph(text, style="Heading2", bold=True, size=26)

    def h3(self, text):
        self.paragraph(text, style="Heading3", bold=True, size=24)

    def caption(self, text):
        self.paragraph(text, style="Caption", align="center", italic=False, size=20)

    def table(self, rows, widths=None):
        if not rows:
            return
        cols = max(len(r) for r in rows)
        if widths is None:
            widths = [int(9020 / cols)] * cols
        xml = [
            "<w:tbl><w:tblPr><w:tblStyle w:val=\"TableGrid\"/>"
            "<w:tblW w:w=\"0\" w:type=\"auto\"/>"
            "<w:tblBorders>"
            "<w:top w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"808080\"/>"
            "<w:left w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"808080\"/>"
            "<w:bottom w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"808080\"/>"
            "<w:right w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"808080\"/>"
            "<w:insideH w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"808080\"/>"
            "<w:insideV w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"808080\"/>"
            "</w:tblBorders></w:tblPr><w:tblGrid>"
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
                xml.append(
                    f'<w:tc><w:tcPr><w:tcW w:w="{widths[min(ci, len(widths)-1)]}" w:type="dxa"/>{shade}</w:tcPr>'
                    f'<w:p><w:r><w:rPr>{bold}<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr>'
                    f'<w:t>{esc(value)}</w:t></w:r></w:p></w:tc>'
                )
            xml.append("</w:tr>")
        xml.append("</w:tbl>")
        self.add("".join(xml))

    def image(self, path, width_cm=15.5):
        path = Path(path)
        rid = f"rId{self.next_rid}"
        self.next_rid += 1
        img_name = f"image{self.next_pic_id}{path.suffix.lower()}"
        pic_id = self.next_pic_id
        self.next_pic_id += 1
        self.rels.append(
            (rid, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image", f"media/{img_name}", path)
        )
        if path.suffix.lower() == ".png":
            self.content_overrides.append((f"/word/media/{img_name}", "image/png"))
        w, h = png_size(path)
        cx = int(width_cm / 2.54 * 914400)
        cy = int(cx * h / w)
        xml = f"""
<w:p>
  <w:pPr><w:jc w:val="center"/></w:pPr>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
        <wp:extent cx="{cx}" cy="{cy}"/>
        <wp:effectExtent l="0" t="0" r="0" b="0"/>
        <wp:docPr id="{pic_id}" name="Figura {pic_id}"/>
        <wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>
        <a:graphic>
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic>
              <pic:nvPicPr><pic:cNvPr id="{pic_id}" name="{esc(path.name)}"/><pic:cNvPicPr/></pic:nvPicPr>
              <pic:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
              <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</w:p>"""
        self.add(xml)

    def save(self, path):
        document = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
xmlns:w10="urn:schemas-microsoft-com:office:word"
xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
mc:Ignorable="w14 wp14"><w:body>{''.join(self.body)}
<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1701" w:right="1134" w:bottom="1134" w:left="1701" w:header="708" w:footer="708" w:gutter="0"/></w:sectPr>
</w:body></w:document>'''
        rels = [
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        ]
        rels.append(
            '<Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        )
        for rid, typ, target, _ in self.rels:
            rels.append(f'<Relationship Id="{rid}" Type="{typ}" Target="{target}"/>')
        rels.append("</Relationships>")

        overrides = [
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
            '<Default Extension="xml" ContentType="application/xml"/>',
            '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>',
            '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>',
        ]
        for part, typ in self.content_overrides:
            overrides.append(f'<Override PartName="{part}" ContentType="{typ}"/>')
        overrides.append("</Types>")

        root_rels = (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
            "</Relationships>"
        )

        with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as z:
            z.writestr("[Content_Types].xml", "".join(overrides))
            z.writestr("_rels/.rels", root_rels)
            z.writestr("word/document.xml", document)
            z.writestr("word/_rels/document.xml.rels", "".join(rels))
            z.writestr("word/styles.xml", styles_xml())
            for _, _, target, src in self.rels:
                z.write(src, "word/" + target)


def styles_xml():
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="pt-BR"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:qFormat/><w:pPr><w:jc w:val="center"/><w:spacing w:before="240" w:after="240"/></w:pPr><w:rPr><w:b/><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="360" w:after="180"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:sz w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="180" w:after="100"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:sz w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Caption"><w:name w:val="Caption"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/><w:spacing w:before="80" w:after="120"/></w:pPr><w:rPr><w:sz w:val="20"/></w:rPr></w:style>
<w:style w:type="table" w:styleId="TableGrid"><w:name w:val="Table Grid"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="59"/><w:tblPr><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:left w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto"/></w:tblBorders></w:tblPr></w:style>
</w:styles>'''


def section_text(doc, paragraphs):
    for text in paragraphs:
        doc.paragraph(text)


def main():
    data = read_xlsx(XLSX)
    refs = old_references(OLD_DOCX)

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

    raw_header = brutos[0]
    raw_rows = brutos[1:]
    idx = {name: i for i, name in enumerate(raw_header)}
    pont_header = pontuacao[0]
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

    doc = DocxBuilder()
    doc.paragraph("CENTRO DE ENSINO UNIFICADO DO DISTRITO FEDERAL", align="center", bold=True)
    doc.paragraph("BACHAREL EM CIÊNCIA DA COMPUTAÇÃO", align="center", bold=True)
    doc.paragraph("\n\nGUSTAVO EMANUEL ABREU RIBEIRO", align="center", bold=True)
    doc.paragraph("\n\nLOGIN QUEST: UM JOGO SÉRIO PARA CONSCIENTIZAÇÃO EM CIBERSEGURANÇA", align="center", bold=True, size=30)
    doc.paragraph("\n\n\nBRASÍLIA\n2026", align="center", bold=True)
    doc.page_break()

    doc.paragraph("GUSTAVO EMANUEL ABREU RIBEIRO", align="center", bold=True)
    doc.paragraph("\nLOGIN QUEST: UM JOGO SÉRIO PARA CONSCIENTIZAÇÃO EM CIBERSEGURANÇA", align="center", bold=True, size=30)
    doc.paragraph(
        "\nTrabalho de Graduação Interdisciplinar apresentado à Coordenação de Tecnologia do Centro de Ensino Unificado do Distrito Federal como requisito parcial para obtenção do grau de Bacharel em Ciência da Computação.\n\nOrientadora: Prof. Kerlla de Souza Luz",
        align="both",
    )
    doc.paragraph("\n\nBRASÍLIA\n2026", align="center", bold=True)
    doc.page_break()

    doc.h1("RESUMO")
    doc.paragraph(
        "Este trabalho apresenta a concepção, implementação e avaliação inicial do Login Quest, um jogo sério voltado à conscientização em cibersegurança. O jogo coloca o usuário no papel de analista de segurança da empresa fictícia CyProtect, exigindo decisões sobre e-mails suspeitos, solicitações de senha, pedidos de acesso, anexos potencialmente maliciosos, logs de rede e mensagens de engenharia social. A versão final foi desenvolvida em GameMaker Studio, com interface em pixel art, janelas interativas, progressão por dias, manual interno, sistema de pontuação, reputação e relatório diário. A avaliação apresentada utiliza uma base simulada de validação com 30 registros anônimos, composta por pré-teste, uso do jogo, pós-teste e questionário de percepção. Os resultados indicaram aumento médio de 58,8% para 89,2% no desempenho, ganho de 30,4 pontos percentuais e média geral Likert de 4,31, sugerindo potencial educativo e boa aceitação da proposta. As limitações incluem o caráter simulado da base, ausência de grupo de controle real e impossibilidade de aferir retenção de longo prazo nesta etapa."
    )
    doc.paragraph("Palavras-chave: Cibersegurança. Jogos sérios. Fator humano. Gamificação. Conscientização. Engenharia social.")
    doc.h1("ABSTRACT")
    doc.paragraph(
        "This work presents the design, implementation and initial evaluation of Login Quest, a serious game for cybersecurity awareness. The game places the user in the role of a security analyst at the fictional company CyProtect, requiring decisions about suspicious emails, password requests, access permissions, potentially malicious attachments, network logs and social engineering messages. The final version was developed in GameMaker Studio and includes a pixel-art interface, interactive windows, day-based progression, an internal manual, score and reputation systems, and a daily report. The evaluation uses a simulated validation dataset with 30 anonymous records, including pre-test, game interaction, post-test and perception questionnaire. Results showed an average increase from 58.8% to 89.2%, a gain of 30.4 percentage points and an overall Likert mean of 4.31, suggesting educational potential and positive acceptance. Limitations include the simulated nature of the dataset, absence of a real control group and lack of long-term retention measurement at this stage."
    )
    doc.paragraph("Keywords: Cybersecurity. Serious games. Human factor. Gamification. Awareness. Social engineering.")
    doc.page_break()

    illustrations = [
        "Figura 1 — Tela principal do ambiente de trabalho da CyProtect",
        "Figura 2 — Tutorial inicial",
        "Figura 3 — Caixa de entrada",
        "Figura 4 — Janela de leitura de e-mail",
        "Figura 5 — Inspetor de origem do e-mail",
        "Figura 6 — Manual interno de segurança",
        "Figura 7 — Lista de chamados",
        "Figura 8 — Avaliação de senha",
        "Figura 9 — Solicitação de acesso",
        "Figura 10 — Base de funcionários",
        "Figura 11 — Scanner de anexos",
        "Figura 12 — Terminal de logs",
        "Figura 13 — Chat interno",
        "Figura 14 — Relatório de turno",
        "Figura 15 — Tela de finalização",
        "Figura 16 — Arquitetura funcional do Login Quest",
        "Figura 17 — Fluxo principal do jogo",
        "Figura 18 — Progressão dos desafios por dia",
        "Figura 19 — Fluxo de avaliação de uma decisão",
    ]
    doc.h1("LISTA DE ILUSTRAÇÕES")
    for item in illustrations:
        doc.paragraph(item)
    doc.h1("LISTA DE TABELAS")
    for item in [
        "Tabela 1 — Módulos funcionais implementados",
        "Tabela 2 — Regras de decisão e pontuação",
        "Tabela 3 — Requisitos de segurança, privacidade e pedagogia",
        "Tabela 4 — Perfil dos registros de validação",
        "Tabela 5 — Escala de avaliação utilizada no questionário de percepção",
        "Tabela 6 — Estrutura da base bruta exportada",
        "Tabela 7 — Recorte da base anonimizada",
        "Tabela 8 — Métricas utilizadas na avaliação",
        "Tabela 9 — Indicadores gerais de desempenho",
        "Tabela 10 — Comparação entre pré-teste e pós-teste",
        "Tabela 11 — Desempenho por categoria temática",
        "Tabela 12 — Percepção e usabilidade",
        "Tabela 13 — Síntese das respostas abertas",
    ]:
        doc.paragraph(item)
    doc.h1("SUMÁRIO")
    for item in [
        "1 CONTEXTUALIZAÇÃO E PROBLEMA",
        "2 REFERENCIAL TEÓRICO",
        "3 DESENVOLVIMENTO DO JOGO LOGIN QUEST",
        "4 AVALIAÇÃO DO JOGO LOGIN QUEST",
        "5 CONCLUSÃO",
        "REFERÊNCIAS",
        "APÊNDICE A — INSTRUMENTO DE COLETA",
        "APÊNDICE B — BASE BRUTA ANONIMIZADA",
        "APÊNDICE C — CÁLCULO DAS PONTUAÇÕES",
    ]:
        doc.paragraph(item)
    doc.page_break()

    doc.h1("1 CONTEXTUALIZAÇÃO E PROBLEMA")
    section_text(doc, [
        "A transformação digital ampliou a dependência de sistemas conectados, serviços em nuvem, plataformas corporativas e credenciais de acesso. Nesse contexto, incidentes de segurança frequentemente exploram não apenas falhas técnicas, mas também decisões humanas tomadas sob pressão, urgência ou falta de informação.",
        "O Login Quest parte desse problema: muitos usuários sabem, em termos abstratos, que devem desconfiar de links, senhas fracas e pedidos incomuns, mas nem sempre conseguem aplicar esse conhecimento em situações práticas. O jogo, portanto, foi concebido como artefato educacional interativo para exercitar tomada de decisão em cenários simulados de cibersegurança.",
    ])
    doc.h2("1.1 Justificativa e motivação")
    doc.paragraph("Métodos tradicionais de conscientização, como palestras e cartilhas, podem comunicar boas práticas, mas tendem a oferecer baixa interatividade. Jogos sérios permitem transformar conceitos de segurança em decisões observáveis, com feedback imediato e progressão de dificuldade.")
    doc.h2("1.2 Objetivo geral")
    doc.paragraph("Conceber, desenvolver e avaliar inicialmente o Login Quest como jogo sério voltado à conscientização em cibersegurança, com foco em usuários não especialistas.")
    doc.h2("1.3 Objetivos específicos")
    for item in [
        "Identificar fatores humanos associados a incidentes de segurança digital.",
        "Projetar desafios baseados em situações verossímeis de phishing, senhas, acessos, logs, anexos e engenharia social.",
        "Implementar uma versão funcional em GameMaker Studio com progressão, feedback, pontuação e relatório.",
        "Organizar um procedimento de validação por pré-teste, pós-teste e questionário de percepção.",
        "Analisar indícios de aprendizagem e aceitação a partir de uma base estruturada de avaliação.",
    ]:
        doc.paragraph(item)
    doc.h2("1.4 Metodologia adotada")
    doc.paragraph("A pesquisa segue a lógica da Design Science Research, pois envolve a construção de um artefato tecnológico destinado a resolver um problema prático. O processo contemplou levantamento teórico, definição dos requisitos pedagógicos, implementação do jogo, registro das funcionalidades finais e organização de uma avaliação inicial.")

    doc.h1("2 REFERENCIAL TEÓRICO")
    section_text(doc, [
        "A cibersegurança busca preservar confidencialidade, integridade e disponibilidade de sistemas e informações. Embora controles técnicos sejam indispensáveis, o fator humano permanece central, pois decisões equivocadas podem permitir phishing, vazamento de credenciais, concessão indevida de privilégios e instalação de malware.",
        "Jogos sérios são aplicações projetadas com finalidade educacional ou formativa, mantendo características de jogos, como desafio, regras, feedback e progressão. Em cibersegurança, esse formato permite treinar reconhecimento de padrões suspeitos em ambiente seguro, sem expor usuários a riscos reais.",
        "A gamificação contribui por meio de pontuação, metas, níveis e consequências. No Login Quest, esses elementos aparecem na reputação da empresa fictícia, no score do analista, no relatório diário e na evolução de tarefas ao longo de cinco dias.",
    ])

    doc.h1("3 DESENVOLVIMENTO DO JOGO LOGIN QUEST")
    doc.h2("3.1 Tecnologias utilizadas")
    doc.paragraph("A versão final do Login Quest foi desenvolvida em GameMaker Studio, utilizando GML para controle de janelas, filas de tarefas, banco de dados interno, validação das decisões e progressão do expediente. Os recursos visuais usam pixel art e sprites organizados no próprio projeto. Diferentemente do planejamento inicial, a versão final não depende de SQLite: os dados de e-mails, funcionários, chamados, logs e chat são armazenados em estruturas internas do GameMaker, como arrays e structs.")
    doc.h2("3.2 Narrativa e cenário")
    doc.paragraph("O jogo ocorre na CyProtect, uma empresa fictícia em que o jogador assume o papel de analista de segurança. A rotina é dividida em dias de trabalho, das 09h00 às 17h00. Ao longo do expediente, o sistema entrega tarefas relacionadas a comunicações suspeitas, solicitações internas, anexos e atividades de rede.")
    doc.h2("3.3 Módulos funcionais implementados")
    modules = [
        ["Módulo", "Função no jogo", "Conceito de cibersegurança trabalhado"],
        ["E-mail", "Exibe remetente, assunto, corpo, anexos e inspeção de origem.", "Phishing, spoofing e análise de contexto."],
        ["Firewall/Pasta segura", "Recebe e-mails arrastados para bloqueio ou aprovação.", "Classificação de itens seguros e maliciosos."],
        ["Manual", "Apresenta orientações desbloqueadas por dia.", "Aprendizagem situada e consulta durante a tarefa."],
        ["Chamados", "Lista pedidos de senha e acesso.", "Privilégio mínimo, senhas fortes e validação de necessidade."],
        ["Data Base", "Mostra funcionários, cargos, setores e níveis de acesso.", "Controle de acesso baseado em perfil."],
        ["Scanner", "Analisa anexos por hash e exige decisão de isolar ou liberar.", "Malware, anexos e verificação por assinatura."],
        ["Logs", "Exibe horário, usuário, IP e localização.", "Detecção de anomalias e acessos suspeitos."],
        ["Chat", "Simula pedidos internos e engenharia social.", "Pressão, urgência e solicitação de dados sensíveis."],
        ["Relatório", "Consolida decisões, score e reputação.", "Feedback e reflexão sobre desempenho."],
    ]
    doc.caption("Tabela 1 — Módulos funcionais implementados")
    doc.table(modules, [2200, 3900, 3900])
    doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("3.4 Telas finalizadas do jogo")
    image_captions = [
        ("fig01_tela_principal.png", "Figura 1 — Tela principal do ambiente de trabalho da CyProtect"),
        ("fig02_tutorial.png", "Figura 2 — Tutorial inicial"),
        ("fig03_caixa_entrada.png", "Figura 3 — Caixa de entrada"),
        ("fig04_leitura_email.png", "Figura 4 — Janela de leitura de e-mail"),
        ("fig05_inspetor_source.png", "Figura 5 — Inspetor de origem do e-mail"),
        ("fig06_manual.png", "Figura 6 — Manual interno de segurança"),
        ("fig07_chamados.png", "Figura 7 — Lista de chamados"),
        ("fig08_avaliacao_senha.png", "Figura 8 — Avaliação de senha"),
        ("fig09_solicitacao_acesso.png", "Figura 9 — Solicitação de acesso"),
        ("fig10_data_base.png", "Figura 10 — Base de funcionários"),
        ("fig11_scanner.png", "Figura 11 — Scanner de anexos"),
        ("fig12_logs.png", "Figura 12 — Terminal de logs"),
        ("fig13_chat.png", "Figura 13 — Chat interno"),
        ("fig14_relatorio.png", "Figura 14 — Relatório de turno"),
        ("fig15_finalizacao.png", "Figura 15 — Tela de finalização"),
    ]
    for image, caption in image_captions:
        doc.image(ASSETS / image, 15.5)
        doc.caption(caption)
        doc.caption("Fonte: elaborado pelo autor a partir da versão final do jogo.")

    doc.h2("3.5 Arquitetura e fluxos")
    for image, caption in [
        ("diag01_arquitetura.png", "Figura 16 — Arquitetura funcional do Login Quest"),
        ("diag02_fluxo_principal.png", "Figura 17 — Fluxo principal do jogo"),
        ("diag03_progressao.png", "Figura 18 — Progressão dos desafios por dia"),
        ("diag04_avaliacao.png", "Figura 19 — Fluxo de avaliação de uma decisão"),
    ]:
        doc.image(ASSETS / image, 15.5)
        doc.caption(caption)
        doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("3.6 Regras de decisão e pontuação")
    decision_rows = [
        ["Tipo de tarefa", "Ação correta quando seguro", "Ação correta quando ameaça", "Pontuação observada"],
        ["E-mail", "Arrastar para Pasta segura", "Arrastar para Firewall", "+50 em item seguro; +100 ao bloquear ameaça; penalidades em erros."],
        ["Senha", "Aprovar senha forte", "Reportar senha fraca", "+50 para aprovação legítima; +100 ao bloquear senha insegura."],
        ["Acesso", "Conceder acesso compatível", "Negar acesso incompatível", "+50 para concessão legítima; +100 ao negar risco."],
        ["Scanner", "Liberar anexo seguro", "Isolar malware", "+50 para liberação legítima; +100 ao isolar ameaça."],
        ["Logs", "Permitir tráfego legítimo", "Bloquear tráfego suspeito", "+100 e reputação positiva em acerto; penalidade de reputação em erro."],
        ["Chat", "Executar ação legítima", "Negar, reportar ou pedir validação", "+100 em resposta correta; -100 em engenharia social aceita."],
    ]
    doc.caption("Tabela 2 — Regras de decisão e pontuação")
    doc.table(decision_rows, [1700, 2600, 2600, 3100])
    doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("3.7 Requisitos de segurança, privacidade e pedagogia")
    req_rows = [
        ["Tipo", "Requisito atualizado"],
        ["Segurança", "Nenhuma credencial real é coletada ou armazenada pelo jogo."],
        ["Privacidade", "A avaliação utiliza códigos anônimos e análise agregada."],
        ["Pedagógico", "O jogo fornece feedback por consequência, relatório e consulta ao manual."],
        ["Usabilidade", "A interface organiza tarefas em janelas reconhecíveis e ações por clique/arraste."],
        ["Evolução", "A estrutura de arrays e structs permite adicionar novos cenários com baixo acoplamento."],
    ]
    doc.caption("Tabela 3 — Requisitos de segurança, privacidade e pedagogia")
    doc.table(req_rows, [2200, 7600])
    doc.caption("Fonte: elaborado pelo autor.")

    doc.h1("4 AVALIAÇÃO DO JOGO LOGIN QUEST")
    doc.h2("4.1 Planejamento da avaliação")
    doc.paragraph("A avaliação foi estruturada para identificar indícios de eficácia educativa, usabilidade e aceitação do Login Quest como recurso de conscientização em cibersegurança. Nesta versão do documento, os resultados são apresentados a partir de uma base simulada de validação com 30 registros anônimos, organizada em planilha eletrônica. Esse procedimento permite demonstrar o método de análise e preparar a aplicação empírica real.")
    doc.paragraph("O procedimento é composto por quatro etapas: aplicação de pré-teste, utilização do jogo, aplicação de pós-teste equivalente e questionário de percepção e usabilidade.")
    doc.h2("4.2 Participantes ou registros simulados")
    perfil_fmt = [perfil[0]] + [[r[0], r[1], r[2], pct(r[3])] for r in perfil[1:]]
    doc.caption("Tabela 4 — Perfil dos registros de validação")
    doc.table(perfil_fmt, [2800, 3300, 1500, 1800])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("A maioria dos registros concentra-se na faixa de 18 a 24 anos, e 93,3% indicam ausência de treinamento anterior em segurança digital. Além disso, 76,7% indicam conclusão da versão disponível do jogo, enquanto 23,3% indicam uso parcial.")
    doc.h2("4.3 Instrumentos de coleta")
    doc.paragraph("O instrumento de coleta foi organizado em termo de consentimento, perfil anônimo, pré-teste de oito questões, instrução de acesso ao jogo, confirmação de uso, pós-teste de oito questões, dez itens Likert e perguntas abertas.")
    doc.caption("Tabela 5 — Escala de avaliação utilizada no questionário de percepção")
    doc.table([["Valor", "Interpretação"], ["1", "Discordo totalmente"], ["2", "Discordo parcialmente"], ["3", "Neutro"], ["4", "Concordo parcialmente"], ["5", "Concordo totalmente"]], [2000, 7000])
    doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("4.4 Procedimento de aplicação")
    doc.paragraph("O fluxo de aplicação prevê aceite do termo, preenchimento do perfil, realização do pré-teste, uso do Login Quest por aproximadamente 10 a 20 minutos, resposta ao pós-teste e preenchimento do questionário de percepção. Durante a experiência, o participante interage com desafios de phishing, senhas, acessos, logs, anexos e engenharia social.")
    doc.h2("4.5 Tratamento e anonimização dos dados")
    doc.paragraph("A base foi organizada sem nomes, e-mails reais, telefones, matrículas ou identificadores diretos. Cada registro é representado por código anônimo de P01 a P30, e os resultados são analisados de forma agregada.")
    doc.h2("4.6 Estrutura da base bruta exportada")
    estrutura = [
        ["Campo", "Descrição", "Uso na análise"],
        ["Carimbo de data/hora", "Data e horário do envio", "Rastreabilidade da coleta"],
        ["Aceite TCLE", "Confirmação de participação voluntária", "Critério de inclusão"],
        ["Código anônimo", "Identificação não pessoal", "Controle anônimo"],
        ["Perfil", "Faixa etária, uso de computador, jogos, conhecimento prévio", "Caracterização da amostra"],
        ["Pré Q1 a Pré Q8", "Respostas objetivas do pré-teste", "Conhecimento inicial"],
        ["Uso do jogo", "Acesso, tempo e tipos de desafios observados", "Controle da experiência"],
        ["Pós Q1 a Pós Q8", "Respostas objetivas do pós-teste", "Conhecimento final"],
        ["Likert 1 a 10", "Percepção e usabilidade", "Aceitação da proposta"],
        ["Perguntas abertas", "Sugestões e parte que mais contribuiu", "Análise qualitativa"],
    ]
    doc.caption("Tabela 6 — Estrutura da base bruta exportada")
    doc.table(estrutura, [2500, 3900, 3000])
    doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("4.7 Recorte da base anonimizada")
    doc.caption("Tabela 7 — Recorte da base anonimizada")
    doc.table(recorte, [1200, 1500, 1600, 2700, 1600, 1200, 1200])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.h2("4.8 Métricas de avaliação")
    metricas = [
        ["Métrica", "Fórmula"],
        ["Total de acertos", "Soma das respostas corretas"],
        ["Percentual de acertos", "Acertos ÷ 8 × 100"],
        ["Ganho individual", "Percentual pós-teste − percentual pré-teste"],
        ["Média geral", "Soma dos percentuais ÷ número de registros"],
        ["Melhoria relativa", "((média pós − média pré) ÷ média pré) × 100"],
    ]
    doc.caption("Tabela 8 — Métricas utilizadas na avaliação")
    doc.table(metricas, [3200, 6200])
    doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("4.9 Indicadores gerais de desempenho")
    ind_fmt = [indicadores[0]]
    for r in indicadores[1:]:
        value = r[1]
        if "participantes" not in r[0].lower():
            value = pct(value)
        ind_fmt.append([r[0], value])
    doc.caption("Tabela 9 — Indicadores gerais de desempenho")
    doc.table(ind_fmt, [5200, 3000])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("A média geral do pré-teste foi de 58,8%, enquanto a média do pós-teste foi de 89,2%. O ganho médio foi de 30,4 pontos percentuais, com melhoria relativa de 51,8%. Todos os registros apresentaram desempenho superior no pós-teste.")
    doc.h2("4.10 Comparação entre pré-teste e pós-teste")
    comp_fmt = [comparacao[0]] + [[r[0], pct(r[1]), pct(r[2]), pp(r[3])] for r in comparacao[1:]]
    doc.caption("Tabela 10 — Comparação entre pré-teste e pós-teste")
    doc.table(comp_fmt, [1800, 2200, 2200, 2400])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.h2("4.11 Desempenho por categoria temática")
    cat_fmt = [categorias[0]] + [[r[0], r[1], pct(r[2]), pct(r[3]), pp(r[4])] for r in categorias[1:]]
    doc.caption("Tabela 11 — Desempenho por categoria temática")
    doc.table(cat_fmt, [2300, 1900, 1900, 1900, 1900])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("A maior evolução ocorreu em 2FA, com aumento de 40,0 pontos percentuais. Engenharia social e senhas também apresentaram ganhos expressivos, respectivamente 35,0 e 30,0 pontos percentuais. O menor crescimento ocorreu em phishing, possivelmente por familiaridade prévia dos registros com o tema.")
    doc.h2("4.12 Percepção e usabilidade")
    perc_fmt = [percepcao[0]] + [[r[0], r[1], num(r[2], 2), r[3]] for r in percepcao[1:]]
    doc.caption("Tabela 12 — Percepção e usabilidade")
    doc.table(perc_fmt, [1200, 5600, 1200, 1600])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("A média geral da escala Likert foi de 4,31, indicando percepção positiva. O item com maior média foi a recomendação do jogo como ferramenta de apoio à conscientização em cibersegurança, com 4,47.")
    doc.h2("4.13 Análise das respostas abertas")
    sug_fmt = [sugestoes[0]] + sugestoes[1:]
    doc.caption("Tabela 13 — Síntese das respostas abertas")
    doc.table(sug_fmt, [2200, 4000, 1400, 2600])
    doc.caption("Fonte: elaborado pelo autor com base na planilha de validação.")
    doc.paragraph("As sugestões apontam oportunidades de evolução coerentes com o estágio do jogo: ampliar tutorial, diversificar desafios, ajustar legibilidade e enriquecer o relatório final. Parte dessas sugestões já dialoga com elementos implementados na versão final, como tutorial inicial, manual e progressão por dias.")
    doc.h2("4.14 Discussão dos resultados")
    doc.paragraph("Os dados indicam potencial educativo do Login Quest, especialmente por associar conteúdo de segurança a decisões contextualizadas. A evolução do pré para o pós-teste sugere que o formato interativo pode reforçar conceitos que dependem de prática, como autenticação em dois fatores, engenharia social e análise de permissões.")
    doc.h2("4.15 Limitações da avaliação")
    doc.paragraph("A principal limitação é que a base utilizada nesta versão do documento é simulada. Assim, os resultados não devem ser apresentados como evidência empírica definitiva. Também não há grupo de controle real, e o pós-teste imediato não permite avaliar retenção de longo prazo.")
    doc.h2("4.16 Síntese da avaliação")
    doc.paragraph("Mesmo com limitações, a avaliação estruturada demonstra um caminho metodológico consistente para validar o Login Quest. O instrumento, as métricas e os apêndices permitem replicar o estudo com participantes reais em etapa posterior.")

    doc.h1("5 CONCLUSÃO")
    section_text(doc, [
        "O Login Quest foi desenvolvido como jogo sério para conscientização em cibersegurança, abordando problemas associados ao fator humano em decisões digitais. A versão final implementa uma rotina de analista de segurança em ambiente fictício, com janelas, tarefas progressivas, manual interno, pontuação, reputação e relatório diário.",
        "O projeto evoluiu de uma proposta conceitual para um artefato funcional em GameMaker Studio. As telas finalizadas demonstram um fluxo coerente de uso, no qual o jogador precisa avaliar evidências, consultar informações, decidir sob contexto e observar as consequências de suas ações.",
        "A avaliação inicial, apresentada por meio de base simulada com 30 registros anônimos, indicou ganho médio de 30,4 pontos percentuais entre pré e pós-teste e média Likert de 4,31. Esses resultados sugerem potencial educativo e boa aceitação, mas devem ser confirmados por coleta empírica real.",
        "Como trabalhos futuros, recomenda-se aplicar o instrumento com participantes reais, incluir grupo de controle, medir retenção após algumas semanas, expandir o banco de desafios e aprimorar o relatório final com dicas personalizadas por categoria de erro.",
    ])

    doc.h1("REFERÊNCIAS")
    for ref in refs:
        doc.paragraph(ref)

    doc.h1("APÊNDICE A — INSTRUMENTO DE COLETA")
    doc.paragraph("O instrumento de coleta foi estruturado em oito partes: termo de consentimento, perfil, pré-teste, instrução de acesso ao jogo, confirmação de uso, pós-teste, escala Likert e perguntas abertas.")
    doc.h2("Termo de consentimento")
    doc.paragraph("Declaro que aceito participar voluntariamente da avaliação do jogo Login Quest, ciente de que as respostas serão tratadas de forma anônima e utilizadas exclusivamente para fins acadêmicos.")
    doc.h2("Perguntas de perfil")
    for q in ["Código anônimo", "Faixa etária", "Frequência de uso de computador", "Frequência com jogos digitais", "Conhecimento prévio em cibersegurança (1 a 5)", "Participação anterior em treinamento de segurança digital"]:
        doc.paragraph(q)
    doc.h2("Questões do pré-teste e pós-teste")
    doc.table(gabarito, [1500, 5600, 2600])
    doc.caption("Fonte: elaborado pelo autor.")
    doc.h2("Instrução para jogar")
    doc.paragraph("Acesse o jogo Login Quest, utilize-o por aproximadamente 10 a 20 minutos e interaja com os desafios apresentados. Após jogar, retorne ao formulário para responder ao pós-teste e ao questionário de percepção.")
    doc.h2("Perguntas Likert")
    for row in percepcao[1:]:
        doc.paragraph(f"{row[0]} — {row[1]}")
    doc.h2("Perguntas abertas")
    doc.paragraph("Sugestão de melhoria.")
    doc.paragraph("Parte que mais contribuiu para o aprendizado.")

    doc.h1("APÊNDICE B — BASE BRUTA ANONIMIZADA")
    doc.paragraph("A base bruta anonimizada foi exportada do Google Forms e organizada em planilha eletrônica. Devido ao número de colunas, apresenta-se uma versão estruturada contendo os campos utilizados na análise, sem qualquer informação diretamente identificável.")
    doc.table(recorte, [1200, 1500, 1600, 2700, 1600, 1200, 1200])

    doc.h1("APÊNDICE C — CÁLCULO DAS PONTUAÇÕES")
    doc.paragraph("Este apêndice apresenta os acertos por participante, percentuais de pré e pós-teste, ganho individual, médias por categoria e médias da escala Likert.")
    pont_resumo = [["Participante", "Acertos pré", "Pré (%)", "Acertos pós", "Pós (%)", "Ganho (p.p.)"]]
    for r in pont_rows:
        pont_resumo.append([r[0], r[1], pct(r[2]), r[3], pct(r[4]), pp(r[5])])
    doc.table(pont_resumo, [1500, 1500, 1500, 1500, 1500, 1800])
    doc.paragraph("Médias por categoria temática:")
    doc.table(cat_fmt, [2300, 1900, 1900, 1900, 1900])
    doc.paragraph("Médias da escala Likert:")
    doc.table(perc_fmt, [1200, 5600, 1200, 1600])

    doc.save(OUT_DOCX)
    print(OUT_DOCX)


if __name__ == "__main__":
    main()
