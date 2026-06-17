Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Out = Join-Path $Root "docs_assets"
New-Item -ItemType Directory -Force -Path $Out | Out-Null

function New-Canvas($w, $h, $bg) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $g.Clear($bg)
    return @($bmp, $g)
}

function Brush($r, $g, $b) {
    return New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($r, $g, $b))
}

function PenC($r, $g, $b, $w = 1) {
    return New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($r, $g, $b), $w)
}

function FontC($size, $style = [System.Drawing.FontStyle]::Regular) {
    return New-Object System.Drawing.Font("Consolas", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-Text($g, $text, $x, $y, $size = 15, $color = @(20,20,20), $style = [System.Drawing.FontStyle]::Regular) {
    $font = FontC $size $style
    $brush = Brush $color[0] $color[1] $color[2]
    $g.DrawString($text, $font, $brush, [float]$x, [float]$y)
    $font.Dispose(); $brush.Dispose()
}

function Draw-Wrapped($g, $text, $x, $y, $maxWidth, $lineHeight = 22, $size = 15, $color = @(20,20,20)) {
    $font = FontC $size
    $brush = Brush $color[0] $color[1] $color[2]
    $words = $text -split "\s+"
    $line = ""
    $yy = $y
    foreach ($word in $words) {
        $test = if ($line.Length -eq 0) { $word } else { "$line $word" }
        if ($g.MeasureString($test, $font).Width -gt $maxWidth -and $line.Length -gt 0) {
            $g.DrawString($line, $font, $brush, [float]$x, [float]$yy)
            $line = $word
            $yy += $lineHeight
        } else {
            $line = $test
        }
    }
    if ($line.Length -gt 0) { $g.DrawString($line, $font, $brush, [float]$x, [float]$yy) }
    $font.Dispose(); $brush.Dispose()
}

function Draw-Button($g, $x, $y, $w, $h, $text, $fill, $fg = @(255,255,255)) {
    $b = Brush $fill[0] $fill[1] $fill[2]
    $p = PenC 30 30 30 2
    $g.FillRectangle($b, $x, $y, $w, $h)
    $g.DrawRectangle($p, $x, $y, $w, $h)
    $font = FontC 15 ([System.Drawing.FontStyle]::Bold)
    $tb = Brush $fg[0] $fg[1] $fg[2]
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($text, $font, $tb, (New-Object System.Drawing.RectangleF($x, $y, $w, $h)), $sf)
    $sf.Dispose(); $font.Dispose(); $tb.Dispose(); $b.Dispose(); $p.Dispose()
}

function Draw-Window($g, $x, $y, $w, $h, $title) {
    $shadow = Brush 0 0 0
    $frame = Brush 238 238 230
    $bar = Brush 42 61 94
    $border = PenC 30 30 30 2
    $g.FillRectangle($shadow, $x + 8, $y + 8, $w, $h)
    $g.FillRectangle($frame, $x, $y, $w, $h)
    $g.DrawRectangle($border, $x, $y, $w, $h)
    $g.FillRectangle($bar, $x, $y, $w, 30)
    Draw-Text $g $title ($x + 10) ($y + 6) 16 @(255,255,255) ([System.Drawing.FontStyle]::Bold)
    $close = Brush 180 70 70
    $g.FillRectangle($close, $x + $w - 24, $y + 7, 14, 14)
    $shadow.Dispose(); $frame.Dispose(); $bar.Dispose(); $border.Dispose(); $close.Dispose()
}

function Draw-Desktop($g) {
    $wall = Join-Path $Root "sprites\spr_wallpaper\626da9cc-98d4-4a62-9ed5-f8314f2bc06f.png"
    if (Test-Path $wall) {
        $img = [System.Drawing.Image]::FromFile($wall)
        $g.DrawImage($img, 0, 0, 1440, 810)
        $img.Dispose()
    } else {
        $g.Clear([System.Drawing.Color]::FromArgb(35, 82, 116))
    }
    $task = Brush 38 45 54
    $g.FillRectangle($task, 0, 810, 1440, 72)
    Draw-Text $g "Dia: 1" 24 24 18 @(255,255,255) ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "Tarefas do Turno: 0 / 6" 24 52 18 @(255,255,255)
    $task.Dispose()
}

function Draw-Icon($g, $path, $x, $y, $label) {
    if (Test-Path $path) {
        $img = [System.Drawing.Image]::FromFile($path)
        $g.DrawImage($img, $x, $y, 64, 64)
        $img.Dispose()
    } else {
        $b = Brush 245 245 245
        $p = PenC 20 20 20 2
        $g.FillRectangle($b, $x, $y, 64, 64)
        $g.DrawRectangle($p, $x, $y, 64, 64)
        $b.Dispose(); $p.Dispose()
    }
    Draw-Text $g $label ($x - 8) ($y + 68) 15 @(255,255,255)
}

function Save-Png($bmp, $g, $name) {
    $path = Join-Path $Out $name
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

function Screenshot-Base($name, $drawBlock) {
    $pair = New-Canvas 1440 882 ([System.Drawing.Color]::Black)
    $bmp = $pair[0]; $g = $pair[1]
    Draw-Desktop $g
    & $drawBlock $g
    Save-Png $bmp $g $name
}

Screenshot-Base "fig01_tela_principal.png" {
    param($g)
    Draw-Icon $g (Join-Path $Root "sprites\spr_chat\f241bb23-9b10-4ed1-8eab-c5f887b005d4.png") 48 96 "Chat"
    Draw-Icon $g (Join-Path $Root "sprites\spr_logs_1\159ae0f0-f775-4ae8-9ee1-8c3e5b860efd.png") 48 240 "Logs"
    Draw-Icon $g (Join-Path $Root "sprites\spr_scanner\b1d1354e-f473-4ccd-bad5-486b0a274d5f.png") 48 384 "Scanner"
    Draw-Icon $g (Join-Path $Root "sprites\spr_chamados_1\307cc18f-3be0-44ca-834e-d4543cfc760f.png") 48 528 "Chamados"
    Draw-Icon $g (Join-Path $Root "sprites\spr_icon_email_1\ae1daefc-5862-4291-a818-ff702d0908e6.png") 48 672 "E-mail"
    Draw-Icon $g (Join-Path $Root "sprites\spr_safe\fd0c9e96-b241-4443-9c5e-42fb93a79f19.png") 1296 24 "Pasta segura"
    Draw-Icon $g (Join-Path $Root "sprites\spr_icon_manual\52a1c5d6-2678-4298-9255-05866aafebac.png") 1296 240 "Manual"
    Draw-Icon $g (Join-Path $Root "sprites\spr_db_1\6f706c3a-cd32-45e0-bea5-4615bd14e25e.png") 1296 432 "Data Base"
    Draw-Icon $g (Join-Path $Root "sprites\spr_firewall\afe6614a-b0c1-4d29-b0c8-993ec0e5960a.png") 1296 624 "Firewall"
    Draw-Text $g "Login Quest - ambiente de trabalho da CyProtect" 420 824 20 @(255,255,255) ([System.Drawing.FontStyle]::Bold)
}

Screenshot-Base "fig02_tutorial.png" {
    param($g)
    $overlay = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210,0,0,0))
    $g.FillRectangle($overlay, 0, 0, 1440, 882)
    Draw-Window $g 210 72 1020 750 "Tutorial"
    Draw-Text $g "BEM-VINDO AO SOC DA CYPROTECT" 410 142 25 @(20,20,20) ([System.Drawing.FontStyle]::Bold)
    Draw-Wrapped $g "Voce e o novo analista de seguranca. Durante o expediente, novos eventos aparecem na caixa de entrada, nos chamados, no terminal de logs e no chat interno. Analise cada caso antes de aprovar, bloquear, isolar ou solicitar validacao." 300 205 840 28 20
    Draw-Wrapped $g "Dica: use o Manual para consultar criterios de rede confiavel, senhas fortes, hashes seguros e sinais de engenharia social." 300 390 840 28 20 @(40,60,90)
    Draw-Button $g 540 675 360 55 "CLIQUE PARA AVANCAR" @(50,120,70)
    $overlay.Dispose()
}

Screenshot-Base "fig03_caixa_entrada.png" {
    param($g)
    Draw-Window $g 330 150 780 520 "Caixa de Entrada"
    $items = @(
        @("diretoria@cyprotect.com", "Bem-vindo a equipe"),
        @("suporte-ti@cypr0tect.com", "URGENTE: Senha Expirada"),
        @("promocoes@amaz0n-store.net", "Voce ganhou um iPhone!"),
        @("rh@cyprotect.com", "Atualizacao de Cadastro"),
        @("secretaria@udf-academico.br.com", "Pendencia de Engenharia")
    )
    $y = 220
    foreach ($it in $items) {
        $b = Brush 255 255 255; $p = PenC 30 30 30 2
        $g.FillRectangle($b, 370, $y, 700, 82); $g.DrawRectangle($p, 370, $y, 700, 82)
        Draw-Text $g $it[0] 390 ($y + 12) 17 @(0,50,150) ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g $it[1] 390 ($y + 44) 17 @(15,15,15)
        $b.Dispose(); $p.Dispose(); $y += 92
    }
}

Screenshot-Base "fig04_leitura_email.png" {
    param($g)
    Draw-Window $g 270 120 900 600 "Ler: URGENTE: Senha Expirada"
    Draw-Text $g "De: suporte-ti@cypr0tect.com" 315 190 18 @(0,0,0) ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "Assunto: URGENTE: Senha Expirada" 315 230 18 @(0,0,0)
    $p = PenC 0 0 0 2; $g.DrawLine($p, 315, 275, 1125, 275)
    Draw-Wrapped $g "Sua senha expira em 2 horas. Clique aqui para redefinir imediatamente ou sua conta sera apagada." 315 305 780 28 20
    Draw-Button $g 315 640 240 50 "[?] INSPECIONAR" @(230,230,230) @(0,0,0)
    $p.Dispose()
}

Screenshot-Base "fig05_inspetor_source.png" {
    param($g)
    Draw-Window $g 180 80 760 570 "Ler: Nota Fiscal Pendente"
    Draw-Text $g "De: financeiro@cyprotect.com" 220 150 17 @(0,0,0)
    Draw-Text $g "Assunto: Nota Fiscal Pendente" 220 188 17 @(0,0,0)
    Draw-Wrapped $g "Segue a NF-e para validacao e pagamento imediato. Evite multas." 220 250 660 24 18
    Draw-Button $g 220 580 235 45 "[?] INSPECIONAR" @(230,230,230) @(0,0,0)
    Draw-Window $g 650 250 610 460 "Source: financeiro@cyprotect.com"
    $terminal = Brush 28 28 28; $g.FillRectangle($terminal, 680, 305, 550, 335)
    Draw-Text $g "Received: from mail.server.com" 700 330 15 @(40,220,40)
    Draw-Text $g "[177.40.12.9]" 700 360 15 @(40,220,40)
    Draw-Text $g "Return-Path: <voce@cyprotect.com>" 700 420 15 @(40,220,40)
    Draw-Text $g "<a href='http://external-link.net/login'>" 700 505 15 @(40,220,40)
    Draw-Button $g 1030 650 165 45 "GRAVAR" @(50,150,50)
    $terminal.Dispose()
}

Screenshot-Base "fig06_manual.png" {
    param($g)
    Draw-Window $g 270 80 900 690 "Manual de Seguranca"
    $hdr = Brush 40 50 80; $g.FillRectangle($hdr, 310, 150, 820, 40)
    Draw-Text $g "GUIA DE SEGURANCA" 326 160 17 @(255,255,255) ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "[< VOLTAR]" 320 220 17 @(50,50,50)
    Draw-Wrapped $g "DIA 3: DATA BASE E PRIVILEGIOS. Controle quem acessa o que na infraestrutura. Pedidos de senha devem ser negados quando usam padroes fracos como 123456, password ou dados pessoais. Pedidos de pasta exigem comparacao entre cargo, setor e necessidade." 320 270 770 27 19
    Draw-Wrapped $g "Um estagiario nao deve acessar balancos financeiros ou codigo-fonte. A decisao correta depende do contexto, nao apenas da urgencia informada." 320 520 770 27 19 @(40,60,90)
    $hdr.Dispose()
}

Screenshot-Base "fig07_chamados.png" {
    param($g)
    Draw-Window $g 315 145 810 520 "Chamados"
    Draw-Text $g "Tickets Pendentes: 3" 360 215 19 @(0,0,0) ([System.Drawing.FontStyle]::Bold)
    $tickets = @(
        @("ID #1042 - Redefinicao", "joao.gomes@cyprotect.com"),
        @("ID #1105 - Acesso", "julia.alves@cyprotect.com"),
        @("ID #1199 - Acesso", "carlos.ti@cyprotect.com")
    )
    $y = 265
    foreach ($t in $tickets) {
        $b = Brush 255 255 255; $p = PenC 90 90 90 2
        $g.FillRectangle($b, 360, $y, 720, 72); $g.DrawRectangle($p, 360, $y, 720, 72)
        Draw-Text $g $t[0] 375 ($y + 10) 17 @(0,0,0)
        Draw-Text $g $t[1] 375 ($y + 40) 17 @(50,50,150)
        $b.Dispose(); $p.Dispose(); $y += 88
    }
}

Screenshot-Base "fig08_avaliacao_senha.png" {
    param($g)
    Draw-Window $g 300 145 840 520 "Redefinicao de Senha"
    Draw-Wrapped $g "Requisicao: Funcionario do setor Financeiro solicitou redefinicao de senha. Usuario: joao.gomes@cyprotect.com" 345 215 750 25 18
    $b = Brush 255 255 255; $p = PenC 80 80 80 2
    $g.FillRectangle($b, 345, 335, 750, 105); $g.DrawRectangle($p, 345, 335, 750, 105)
    Draw-Text $g "Senha sugerida:" 365 360 18 @(0,0,0)
    Draw-Text $g "123456" 365 402 24 @(180,0,0) ([System.Drawing.FontStyle]::Bold)
    Draw-Button $g 345 585 235 55 "REPORTAR" @(200,50,50)
    Draw-Button $g 860 585 235 55 "APROVAR" @(50,150,50)
    $b.Dispose(); $p.Dispose()
}

Screenshot-Base "fig09_solicitacao_acesso.png" {
    param($g)
    Draw-Window $g 300 145 840 520 "Solicitacao de Acesso"
    Draw-Wrapped $g "Requisicao: O usuario solicitou privilegios de Administrador para o diretorio abaixo. Usuario: julia.alves@cyprotect.com" 345 215 750 25 18
    $b = Brush 255 255 255; $p = PenC 80 80 80 2
    $g.FillRectangle($b, 345, 335, 750, 105); $g.DrawRectangle($p, 345, 335, 750, 105)
    Draw-Text $g "Diretorio alvo:" 365 360 18 @(0,0,0)
    Draw-Text $g "Balanco_Financeiro_2026" 365 402 22 @(180,0,0) ([System.Drawing.FontStyle]::Bold)
    Draw-Button $g 345 585 235 55 "NEGAR" @(200,50,50)
    Draw-Button $g 860 585 235 55 "CONCEDER" @(50,150,50)
    $b.Dispose(); $p.Dispose()
}

Screenshot-Base "fig10_data_base.png" {
    param($g)
    Draw-Window $g 250 80 940 690 "Data Base"
    $rows = @(
        @("Joao Gomes (Financeiro)", "Email: joao.gomes@cyprotect.com", "Cargo: Analista | Acesso: Leitura/Escrita"),
        @("Marta Silva (RH)", "Email: marta.silva@cyprotect.com", "Cargo: Gerente | Acesso: Total"),
        @("Carlos TI (TI)", "Email: carlos.ti@cyprotect.com", "Cargo: Suporte N1 | Acesso: Administrador"),
        @("Julia Alves (Marketing)", "Email: julia.alves@cyprotect.com", "Cargo: Estagiaria | Acesso: Leitura"),
        @("Lucas Dev (Engenharia)", "Email: lucas.dev@cyprotect.com", "Cargo: Desenvolvedor | Acesso: Leitura/Escrita")
    )
    $y = 150
    for ($i=0; $i -lt $rows.Count; $i++) {
        $fill = if ($i % 2 -eq 0) { @(240,240,240) } else { @(255,255,255) }
        $b = Brush $fill[0] $fill[1] $fill[2]; $p = PenC 90 90 90 2
        $g.FillRectangle($b, 295, $y, 850, 95); $g.DrawRectangle($p, 295, $y, 850, 95)
        Draw-Text $g $rows[$i][0] 315 ($y + 10) 18 @(0,0,100) ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g $rows[$i][1] 315 ($y + 40) 17 @(0,0,0)
        Draw-Text $g $rows[$i][2] 315 ($y + 68) 16 @(90,90,90)
        $b.Dispose(); $p.Dispose(); $y += 105
    }
}

Screenshot-Base "fig11_scanner.png" {
    param($g)
    Draw-Window $g 360 150 720 520 "Scanner MD5"
    Draw-Text $g "Alvo: Curriculo_CV.exe" 548 235 20 @(0,0,0) ([System.Drawing.FontStyle]::Bold)
    $p = PenC 0 0 0 2; $g.DrawRectangle($p, 450, 305, 540, 32)
    $b = Brush 50 150 200; $g.FillRectangle($b, 453, 308, 534, 26)
    Draw-Text $g "HASH: E99A18C4" 585 380 22 @(180,0,0) ([System.Drawing.FontStyle]::Bold)
    Draw-Text $g "Consulte o Manual!" 585 425 18 @(70,70,70)
    Draw-Button $g 420 510 260 58 "ISOLAR" @(150,30,30)
    Draw-Button $g 760 510 260 58 "LIBERAR" @(30,150,30)
    $p.Dispose(); $b.Dispose()
}

Screenshot-Base "fig12_logs.png" {
    param($g)
    Draw-Window $g 330 150 780 520 "MOLDU_NET Logs"
    $term = Brush 15 20 15; $pen = PenC 0 200 0 2
    $g.FillRectangle($term, 375, 220, 690, 255); $g.DrawRectangle($pen, 375, 220, 690, 255)
    Draw-Text $g "TIMESTAMP: 03:14" 405 245 20 @(0,220,0)
    Draw-Text $g "USER:      admin" 405 300 20 @(0,220,0)
    Draw-Text $g "SRC_IP:    185.22.4.1" 405 355 20 @(0,220,0)
    Draw-Text $g "GEO_LOC:   RU" 405 410 20 @(0,220,0)
    Draw-Button $g 390 540 280 55 "PERMITIR" @(220,220,220) @(0,0,0)
    Draw-Button $g 770 540 280 55 "BLOQUEAR" @(255,180,180) @(0,0,0)
    $term.Dispose(); $pen.Dispose()
}

Screenshot-Base "fig13_chat.png" {
    param($g)
    Draw-Window $g 270 105 900 650 "Chat Interno"
    Draw-Text $g "Conversa com: Diretoria" 315 170 18 @(50,50,50) ([System.Drawing.FontStyle]::Bold)
    $bubble = Brush 220 240 255; $border = PenC 100 150 200 2
    $g.FillRectangle($bubble, 315, 230, 810, 170); $g.DrawRectangle($border, 315, 230, 810, 170)
    Draw-Wrapped $g "O sistema bloqueou meu acesso a pasta de balancos financeiros. Eu sou o CEO, preciso que voce me envie a senha de administrador do servidor IMEDIATAMENTE. E urgente!" 345 255 750 26 18
    Draw-Button $g 315 450 810 55 "1. Enviar Senha" @(240,240,240) @(0,0,0)
    Draw-Button $g 315 525 810 55 "2. Pedir PIN" @(240,240,240) @(0,0,0)
    Draw-Button $g 315 600 810 55 "3. Ignorar" @(240,240,240) @(0,0,0)
    $bubble.Dispose(); $border.Dispose()
}

Screenshot-Base "fig14_relatorio.png" {
    param($g)
    Draw-Window $g 255 90 930 680 "Relatorio de Turno"
    Draw-Text $g "RELATORIO DE TURNO - DIA 5" 305 160 20 @(0,0,0) ([System.Drawing.FontStyle]::Bold)
    $p = PenC 0 0 0 2; $g.DrawLine($p, 305, 205, 1135, 205)
    $rows = @(
        @("Senha: joao.gomes | Bloqueou", "ACERTOU!", @(0,150,0)),
        @("Acesso a: Balanco_Financeiro | Negou", "ACERTOU!", @(0,150,0)),
        @("Log: admin | Bloqueou IP", "ACERTOU!", @(0,150,0)),
        @("Chat com Diretoria | Agiu Corretamente", "ACERTOU!", @(0,150,0)),
        @("Nota Fiscal Pendente | Liberou Anexo", "ERRO! (Era Ameaca)", @(200,0,0))
    )
    $y = 230
    foreach ($r in $rows) {
        Draw-Text $g $r[0] 315 $y 17 @(0,0,0)
        Draw-Text $g $r[1] 930 $y 17 $r[2] ([System.Drawing.FontStyle]::Bold)
        $y += 45
    }
    $g.DrawLine($p, 305, 555, 1135, 555)
    Draw-Text $g "Reputacao: 85%" 315 585 19 @(0,0,0)
    Draw-Text $g "Score: 780 pts" 680 585 19 @(0,0,0)
    Draw-Button $g 540 660 360 58 "AVANCAR DIA" @(50,150,50)
    $p.Dispose()
}

Screenshot-Base "fig15_finalizacao.png" {
    param($g)
    Draw-Window $g 330 170 780 500 "Encerramento"
    Draw-Text $g "PARABENS! MISSAO CUMPRIDA." 470 260 25 @(50,150,50) ([System.Drawing.FontStyle]::Bold)
    Draw-Wrapped $g "Sobreviveu a semana na CyProtect. As suas analises rigorosas mantiveram a empresa a salvo de ciberataques." 405 335 630 30 21
    Draw-Button $g 520 560 400 60 "REINICIAR JOGO" @(50,100,200)
}

function Diagram-Box($g, $x, $y, $w, $h, $title, $body, $fill) {
    $b = Brush $fill[0] $fill[1] $fill[2]
    $p = PenC 40 40 40 2
    $g.FillRectangle($b, $x, $y, $w, $h)
    $g.DrawRectangle($p, $x, $y, $w, $h)
    Draw-Text $g $title ($x + 16) ($y + 14) 22 @(10,10,10) ([System.Drawing.FontStyle]::Bold)
    Draw-Wrapped $g $body ($x + 16) ($y + 52) ($w - 32) 25 18 @(20,20,20)
    $b.Dispose(); $p.Dispose()
}

function Arrow($g, $x1, $y1, $x2, $y2) {
    $p = PenC 35 35 35 4
    $p.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $g.DrawLine($p, $x1, $y1, $x2, $y2)
    $p.Dispose()
}

$pair = New-Canvas 1600 900 ([System.Drawing.Color]::FromArgb(250,250,248)); $bmp=$pair[0]; $g=$pair[1]
Draw-Text $g "Arquitetura funcional do Login Quest" 70 45 32 @(20,20,20) ([System.Drawing.FontStyle]::Bold)
Diagram-Box $g 70 130 390 210 "Apresentacao" "Janelas, icones, desktop, tutorial, manual, feedback visual e comandos por clique ou arraste." @(225,238,250)
Diagram-Box $g 605 130 390 210 "Logica de jogo" "Controle do expediente, sorteio de tarefas, progressao por dias, validacao de decisoes e pontuacao." @(232,244,232)
Diagram-Box $g 1140 130 390 210 "Dados internos" "Bases GML de e-mails, funcionarios, chamados, logs, chat, hashes e historico de decisoes." @(250,235,220)
Diagram-Box $g 335 525 390 210 "Avaliacao" "Registro de acertos, erros, reputacao, score, bonus e penalidades por tarefas ignoradas." @(245,238,255)
Diagram-Box $g 875 525 390 210 "Relatorio" "Resumo diario do turno e decisao de avancar dia, finalizar a semana ou reiniciar apos derrota." @(255,245,218)
Arrow $g 460 235 605 235; Arrow $g 995 235 1140 235; Arrow $g 800 340 590 525; Arrow $g 995 340 1070 525; Arrow $g 725 630 875 630
Save-Png $bmp $g "diag01_arquitetura.png"

$pair = New-Canvas 1600 900 ([System.Drawing.Color]::FromArgb(250,250,248)); $bmp=$pair[0]; $g=$pair[1]
Draw-Text $g "Fluxo principal do jogo" 70 45 32 @(20,20,20) ([System.Drawing.FontStyle]::Bold)
$steps = @(
    @("Inicio", "Abrir ambiente e iniciar expediente", 70, 170),
    @("Gerar tarefas", "Sortear e agendar e-mails, chamados, logs e chat", 430, 170),
    @("Analisar", "Jogador interpreta evidencias e consulta manual/DB", 790, 170),
    @("Decidir", "Aprovar, bloquear, negar, isolar, permitir ou pedir PIN", 1150, 170),
    @("Avaliar", "Sistema compara acao com classificacao da tarefa", 430, 520),
    @("Relatorio", "Apresentar acertos, erros, reputacao e score", 790, 520),
    @("Progredir", "Avancar dia, concluir campanha ou reiniciar", 1150, 520)
)
foreach ($s in $steps) { Diagram-Box $g $s[2] $s[3] 300 150 $s[0] $s[1] @(236,244,250) }
Arrow $g 370 245 430 245; Arrow $g 730 245 790 245; Arrow $g 1090 245 1150 245; Arrow $g 1300 320 580 520; Arrow $g 730 595 790 595; Arrow $g 1090 595 1150 595; Arrow $g 1300 670 1300 800; Arrow $g 1300 800 220 800; Arrow $g 220 800 220 320
Save-Png $bmp $g "diag02_fluxo_principal.png"

$pair = New-Canvas 1600 900 ([System.Drawing.Color]::FromArgb(250,250,248)); $bmp=$pair[0]; $g=$pair[1]
Draw-Text $g "Progressao dos desafios por dia" 70 45 32 @(20,20,20) ([System.Drawing.FontStyle]::Bold)
$days = @(
    @("Dia 1", "6 e-mails. Triagem basica entre comunicacoes legitimas e phishing evidente.", 70),
    @("Dia 2", "8 e-mails. Inclusao do inspetor de origem, IP alvo e sinais tecnicos.", 370),
    @("Dia 3", "6 e-mails + 5 chamados. Avaliacao de senhas e solicitacoes de acesso.", 670),
    @("Dia 4", "8 e-mails + 7 chamados. Anexos, scanner e interpretacao de hashes.", 970),
    @("Dia 5+", "5 e-mails + 5 chamados + 2 logs + 2 chats. Semana completa com engenharia social e rede.", 1270)
)
foreach ($d in $days) { Diagram-Box $g $d[2] 220 250 360 $d[0] $d[1] @(232,244,232) }
Arrow $g 320 400 370 400; Arrow $g 620 400 670 400; Arrow $g 920 400 970 400; Arrow $g 1220 400 1270 400
Draw-Wrapped $g "A progressao foi implementada no controlador do jogo: a cada novo dia, o sistema limpa filas, sorteia tarefas elegiveis, agenda entregas entre 09h00 e 15h30 e define a meta diaria de conclusao." 120 660 1360 30 22 @(40,40,40)
Save-Png $bmp $g "diag03_progressao.png"

$pair = New-Canvas 1600 900 ([System.Drawing.Color]::FromArgb(250,250,248)); $bmp=$pair[0]; $g=$pair[1]
Draw-Text $g "Fluxo de avaliacao de uma decisao" 70 45 32 @(20,20,20) ([System.Drawing.FontStyle]::Bold)
Diagram-Box $g 80 180 320 160 "Entrada" "Tarefa possui tipo, dados, nivel, indicador is_threat e metadados de apoio." @(225,238,250)
Diagram-Box $g 500 180 320 160 "Acao" "Jogador escolhe uma resposta ou arrasta a janela para destino funcional." @(232,244,232)
Diagram-Box $g 920 180 320 160 "Comparacao" "Sistema verifica se acao positiva foi aplicada a item seguro ou acao negativa a ameaca." @(250,235,220)
Diagram-Box $g 500 520 320 160 "Registro" "A decisao e armazenada em emails_avaliados para compor contador e relatorio." @(245,238,255)
Diagram-Box $g 920 520 320 160 "Feedback" "Atualiza score, reputacao, bonus/penalidade e resultado do relatorio diario." @(255,245,218)
Arrow $g 400 260 500 260; Arrow $g 820 260 920 260; Arrow $g 1080 340 660 520; Arrow $g 820 600 920 600
Save-Png $bmp $g "diag04_avaliacao.png"

Write-Output "Assets gerados em $Out"
