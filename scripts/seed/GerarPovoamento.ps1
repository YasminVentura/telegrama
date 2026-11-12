<#
.SYNOPSIS
    Gerador Automatizado de Dados em Massa para o Projeto Telegrama (Banco de Dados II)
.DESCRIPTION
    Gera scripts SQL e NoSQL em alta velocidade:
      - 5.000 Usuários no PostgreSQL (telegrama_auth)
      - 5.000 Perfis e Preferências no PostgreSQL (telegrama_profile)
      - 25.000 Relações de Seguidores no PostgreSQL (telegrama_profile)
      - 100.000 Postagens no MongoDB (telegrama_posts) com comentários e curtidas
.OUTPUTS
    - scripts/seed/01_carga_auth.sql
    - scripts/seed/02_carga_profile.sql
    - scripts/seed/03_carga_posts.json
#>

param(
    [int]$TotalUsuarios = 5000,
    [int]$TotalSeguidores = 25000,
    [int]$TotalPosts = 100000
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  TELEGRAMA - GERADOR DE CARGA EM MASSA (PERSISTENCIA POLIGLOTA) " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Total de Usuários : $TotalUsuarios"
Write-Host "Total de Seguidores: $TotalSeguidores"
Write-Host "Total de Postagens : $TotalPosts (Entidade Principal MongoDB)"
Write-Host "Diretório de saída: $ScriptDir"
Write-Host "----------------------------------------------------------"

$NomesBase = @(
    "Alice Silva", "Bruno Souza", "Carla Dias", "Daniel Oliveira", "Eduardo Santos",
    "Fernanda Lima", "Gabriel Costa", "Helena Martins", "Igor Ferreira", "Julia Rocha",
    "Lucas Mendes", "Mariana Barbosa", "Nicolas Castro", "Olivia Ribeiro", "Pedro Alves",
    "Rafaela Gomes", "Samuel Duarte", "Tatiana Moreira", "Vinicius Freitas", "Yasmin Ramos",
    "Arthur Nogueira", "Beatriz Farias", "Caio Cardoso", "Debora Carvalho", "Enzo Pereira",
    "Fabiana Teixeira", "Guilherme Correia", "Isabela Pires", "Joao Victor", "Larissa Moraes"
)

$BioTemplates = @(
    "Explorando frequências e construindo o futuro da web.",
    "Engenheiro de software focado em microsserviços e bancos poliglotas.",
    "Pesquisador de dados, entusiasta de NoSQL e café expresso.",
    "Desenvolvendo ideias no Telegrama. Transmitindo em sinal aberto.",
    "Arquiteto de sistemas distribuídos | Java & MongoDB lover.",
    "Designer de interfaces retrô e aficionado por ficção científica.",
    "Apenas mais um nó nesta rede descentralizada.",
    "Segurança da informação, criptografia e privacidade em primeiro lugar."
)

$PostTextos = @(
    "Testando a nova frequência da rede Telegrama. O sinal está limpo e estável!",
    "A persistência poliglota com PostgreSQL e MongoDB resolveu nosso gargalo de concorrência.",
    "O que vocês acham da arquitetura Database-per-Service para redes sociais?",
    "Mais um dia otimizando índices B-Tree e multikey indexes no banco.",
    "Transmissão iniciada na zona 4. Todo nó conectado deve responder ao ping.",
    "Implementando cache de referência de sessão com Redis para derrubar a latência a 1ms.",
    "Diferença brutal de performance entre um COLLSCAN e um IXSCAN de índice composto!",
    "Café, código e replicação distribuída. Bom dia para quem é do backend!",
    "Nova funcionalidade de reposts atômicos quase pronta no post-service.",
    "Alguém mais participando do congresso de banco de dados neste fim de semana?",
    "A consistência eventual tem seus desafios, mas o ganho em disponibilidade compensa.",
    "Monitorando métricas de throughput no Docker Compose: tudo nos conformes."
)

$Cidades = @("São Paulo, SP", "Rio de Janeiro, RJ", "Belo Horizonte, MG", "Curitiba, PR", "Porto Alegre, RS", "Recife, PE", "Salvador, BA", "Brasília, DF", "Florianópolis, SC", "Fortaleza, CE")
$Avatares = @(
    "lib/assets/images/avatars/avatar_1.webp",
    "lib/assets/images/avatars/avatar_2.webp",
    "lib/assets/images/avatars/avatar_3.webp",
    "lib/assets/images/avatars/avatar_4.webp",
    "lib/assets/images/avatars/avatar_5.webp"
)
$CoresBanner = @("#2E4F3E", "#1F3A4B", "#4A2E4F", "#4F3A2E", "#2A2A2A", "#1D4ED8", "#047857", "#B45309")
$Temas = @("RETRO_GREEN", "CYBER_DARK", "NEON_AMBER", "MONOCHROME")

# Senha padrão criptografada em BCrypt para a senha '123456'
$SenhaBCryptPadrao = "`$2a`$10`$eACCYoNOHEqgkVE8aWnATO3qE7WODErGQzL6GZ8lq0m8o6C7xS4rS"

# 1. Gerar Lista de Usuários em Memória
Write-Host "1/4: Gerando $TotalUsuarios usuários em memória..." -ForegroundColor Yellow
$Usuarios = New-Object System.Collections.Generic.List[PSCustomObject]
$Random = New-Object System.Random(42) # Seed fixa para reprodutibilidade

for ($i = 1; $i -le $TotalUsuarios; $i++) {
    $uuid = [System.Guid]::NewGuid().ToString()
    $nomeBase = $NomesBase[$Random.Next($NomesBase.Count)]
    $sufixo = $i
    $nome = "$nomeBase $sufixo"
    $nodeId = "@user_$i"
    $email = "user_$i@telegrama.zone"
    $bio = $BioTemplates[$Random.Next($BioTemplates.Count)]
    $loc = $Cidades[$Random.Next($Cidades.Count)]
    $avatar = $Avatares[$Random.Next($Avatares.Count)]
    $banner = $CoresBanner[$Random.Next($CoresBanner.Count)]
    $role = if ($i -eq 1) { "ADMIN" } else { "USER" }
    $tema = $Temas[$Random.Next($Temas.Count)]
    
    # Data aleatória entre os últimos 180 dias
    $diasAtras = $Random.Next(1, 180)
    $criadoEm = (Get-Date).AddDays(-$diasAtras).AddMinutes($Random.Next(0, 1440)).ToString("yyyy-MM-dd HH:mm:ss")

    $u = [PSCustomObject]@{
        Id = $uuid
        Nome = $nome
        NodeId = $nodeId
        Email = $email
        Senha = $SenhaBCryptPadrao
        Bio = $bio
        Localizacao = $loc
        AvatarUrl = $avatar
        BannerColor = $banner
        Role = $role
        Tema = $tema
        CriadoEm = $criadoEm
    }
    $Usuarios.Add($u)
}

# ------------------------------------------------------------------------------
# 2. Gerar Arquivo SQL: 01_carga_auth.sql
# ------------------------------------------------------------------------------
$FileAuth = Join-Path $ScriptDir "01_carga_auth.sql"
Write-Host "2/4: Escrevendo arquivo SQL do auth ($FileAuth)..." -ForegroundColor Yellow

$swAuth = [System.IO.StreamWriter]::new($FileAuth, $false, [System.Text.Encoding]::UTF8)
try {
    $swAuth.WriteLine("-- CARGA DE USUARIOS PARA telegrama_auth ($TotalUsuarios registros)")
    $swAuth.WriteLine("BEGIN;")
    
    $batchSize = 1000
    for ($i = 0; $i -lt $Usuarios.Count; $i += $batchSize) {
        $swAuth.WriteLine("INSERT INTO usuarios (id, nome, node_id, email, senha, termos_aceitos, perfil, criado_em, atualizado_em) VALUES")
        $limite = [Math]::Min($i + $batchSize, $Usuarios.Count)
        for ($j = $i; $j -lt $limite; $j++) {
            $u = $Usuarios[$j]
            $virgula = if ($j -eq ($limite - 1)) { ";" } else { "," }
            $swAuth.WriteLine("('$($u.Id)', '$($u.Nome)', '$($u.NodeId)', '$($u.Email)', '$($u.Senha)', TRUE, '$($u.Role)', '$($u.CriadoEm)', '$($u.CriadoEm)')$virgula")
        }
    }
    $swAuth.WriteLine("COMMIT;")
} finally {
    $swAuth.Dispose()
}

# ------------------------------------------------------------------------------
# 3. Gerar Arquivo SQL: 02_carga_profile.sql (Perfis, Preferências, Seguidores)
# ------------------------------------------------------------------------------
$FileProfile = Join-Path $ScriptDir "02_carga_profile.sql"
Write-Host "3/4: Escrevendo arquivo SQL do profile ($FileProfile)..." -ForegroundColor Yellow

$swProf = [System.IO.StreamWriter]::new($FileProfile, $false, [System.Text.Encoding]::UTF8)
try {
    $swProf.WriteLine("-- CARGA DE PERFIS E GRAFO DE SEGUIDORES PARA telegrama_profile")
    $swProf.WriteLine("BEGIN;")

    # Inserção de Perfis
    $swProf.WriteLine("-- 1. Perfis de Usuarios")
    for ($i = 0; $i -lt $Usuarios.Count; $i += $batchSize) {
        $swProf.WriteLine("INSERT INTO perfis_usuarios (id, nome, node_id, email, bio, localizacao, avatar_url, banner_color, perfil, criado_em, atualizado_em) VALUES")
        $limite = [Math]::Min($i + $batchSize, $Usuarios.Count)
        for ($j = $i; $j -lt $limite; $j++) {
            $u = $Usuarios[$j]
            $virgula = if ($j -eq ($limite - 1)) { ";" } else { "," }
            $bioEscaped = $u.Bio.Replace("'", "''")
            $locEscaped = $u.Localizacao.Replace("'", "''")
            $swProf.WriteLine("('$($u.Id)', '$($u.Nome)', '$($u.NodeId)', '$($u.Email)', '$bioEscaped', '$locEscaped', '$($u.AvatarUrl)', '$($u.BannerColor)', '$($u.Role)', '$($u.CriadoEm)', '$($u.CriadoEm)')$virgula")
        }
    }

    # Inserção de Preferências (1:1)
    $swProf.WriteLine("-- 2. Preferencias dos Usuarios")
    for ($i = 0; $i -lt $Usuarios.Count; $i += $batchSize) {
        $swProf.WriteLine("INSERT INTO usuario_preferencias (id, usuario_id, private_frequency_mode, direct_transmissions, broadcast_node_activity, push_transmissions, acoustic_echos, zone_broadcast_alerts, two_factor_auth, theme, avatar_url, banner_color) VALUES")
        $limite = [Math]::Min($i + $batchSize, $Usuarios.Count)
        for ($j = $i; $j -lt $limite; $j++) {
            $u = $Usuarios[$j]
            $prefId = [System.Guid]::NewGuid().ToString()
            $virgula = if ($j -eq ($limite - 1)) { ";" } else { "," }
            $swProf.WriteLine("('$prefId', '$($u.Id)', FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, '$($u.Tema)', '$($u.AvatarUrl)', '$($u.BannerColor)')$virgula")
        }
    }

    # Inserção de Grafo de Seguidores (N:M)
    $swProf.WriteLine("-- 3. Grafo de Seguidores ($TotalSeguidores relacionamentos)")
    $paresUnicos = New-Object "System.Collections.Generic.HashSet[string]"
    $seguidoresGerados = 0
    $tentativas = 0

    $swProf.WriteLine("INSERT INTO seguidores (id, seguidor_id, seguido_id, criado_em) VALUES")
    
    while ($seguidoresGerados -lt $TotalSeguidores -and $tentativas -lt ($TotalSeguidores * 3)) {
        $tentativas++
        $idxSeguidor = $Random.Next($TotalUsuarios)
        $idxSeguido = $Random.Next($TotalUsuarios)
        if ($idxSeguidor -eq $idxSeguido) { continue }

        $chave = "$idxSeguidor-$idxSeguido"
        if ($paresUnicos.Add($chave)) {
            $seguidoresGerados++
            $relId = [System.Guid]::NewGuid().ToString()
            $uSeguidor = $Usuarios[$idxSeguidor]
            $uSeguido = $Usuarios[$idxSeguido]
            $dataRel = (Get-Date).AddDays(-$Random.Next(1, 90)).ToString("yyyy-MM-dd HH:mm:ss")
            $virgula = if ($seguidoresGerados -eq $TotalSeguidores) { ";" } else { "," }
            $swProf.WriteLine("('$relId', '$($uSeguidor.Id)', '$($uSeguido.Id)', '$dataRel')$virgula")
        }
    }
    
    $swProf.WriteLine("COMMIT;")
} finally {
    $swProf.Dispose()
}

# ------------------------------------------------------------------------------
# 4. Gerar Arquivo JSON para MongoDB: 03_carga_posts.json (100.000 Postagens)
# ------------------------------------------------------------------------------
$FilePosts = Join-Path $ScriptDir "03_carga_posts.json"
Write-Host "4/4: Gerando 100.000 documentos para o MongoDB ($FilePosts)..." -ForegroundColor Yellow

$swPosts = [System.IO.StreamWriter]::new($FilePosts, $false, [System.Text.Encoding]::UTF8)
try {
    for ($p = 1; $p -le $TotalPosts; $p++) {
        $uAutor = $Usuarios[$Random.Next($TotalUsuarios)]
        $texto = $PostTextos[$Random.Next($PostTextos.Count)]
        
        # Gerar algumas curtidas reais usando outros usuários
        $qtdCurtidas = $Random.Next(0, 8)
        $listaCurtidas = @()
        for ($c = 0; $c -lt $qtdCurtidas; $c++) {
            $uCurtiu = $Usuarios[$Random.Next($TotalUsuarios)]
            $listaCurtidas += "`"$($uCurtiu.NodeId)`""
        }
        $curtidasJson = "[" + ($listaCurtidas -join ",") + "]"

        # Gerar comentários embutidos (0 a 3 comentários)
        $qtdComentarios = $Random.Next(0, 4)
        $comentariosArr = @()
        for ($k = 0; $k -lt $qtdComentarios; $k++) {
            $uComentou = $Usuarios[$Random.Next($TotalUsuarios)]
            $comentId = [System.Guid]::NewGuid().ToString()
            $comentTexto = "Concordo totalmente com você, $($uAutor.NodeId)!"
            $comentData = (Get-Date).AddMinutes(-$Random.Next(5, 5000)).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            $comentariosArr += "{`"id`":`"$comentId`",`"parentId`":null,`"autorId`":`"$($uComentou.Id)`",`"autorNodeId`":`"$($uComentou.NodeId)`",`"autorNome`":`"$($uComentou.Nome)`",`"autorAvatarUrl`":`"$($uComentou.AvatarUrl)`",`"conteudo`":`"$comentTexto`",`"curtidas`":[],`"criadoEm`":{`"`$date`":`"$comentData`"}}"
        }
        $comentariosJson = "[" + ($comentariosArr -join ",") + "]"

        $dataPostIso = (Get-Date).AddDays(-$Random.Next(0, 120)).AddMinutes(-$Random.Next(0, 1440)).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

        $jsonDoc = "{`"autorId`":`"$($uAutor.Id)`",`"autorNodeId`":`"$($uAutor.NodeId)`",`"autorNome`":`"$($uAutor.Nome)`",`"autorAvatarUrl`":`"$($uAutor.AvatarUrl)`",`"conteudo`":`"$texto`",`"curtidas`":$curtidasJson,`"salvos`":[],`"reposts`":[],`"comentarios`":$comentariosJson,`"quantidadeCurtidas`":$qtdCurtidas,`"quantidadeComentarios`":$qtdComentarios,`"quantidadeReposts`":0,`"criadoEm`":{`"`$date`":`"$dataPostIso`"},`"atualizadoEm`":{`"`$date`":`"$dataPostIso`"}}"
        
        $swPosts.WriteLine($jsonDoc)

        if ($p % 20000 -eq 0) {
            Write-Host "  ... gerados $p / $TotalPosts posts ..." -ForegroundColor DarkGray
        }
    }
} finally {
    $swPosts.Dispose()
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  SUCESSO! TODOS OS ARQUIVOS FORAM GERADOS COM PERFEIÇÃO  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "1. PostgreSQL Auth:   $FileAuth"
Write-Host "2. PostgreSQL Profile:$FileProfile"
Write-Host "3. MongoDB Posts:     $FilePosts (100.000 Documentos JSON Lines)"

