-- main.lua 
-- MÓDULOS DO JOGO:
require "modules.config" -- Configurações globais, cores, constantes
require "modules.grid"   --- Sistema de grid e células
require "modules.player"  --- Controles e funções do jogador
require "modules.enemies"           -- Inimigo esfera (fases 1 e 4)
require "modules.enemies_quadrado"  -- Inimigo quadrado (3 unidades)
require "modules.enemies_triangulo" -- Inimigo triângulo
require "modules.projectiles"      -- Sistema de projéteis
require "modules.attacks"          -- Ataques especiais
require "modules.ui"               -- Interface do usuário
require "modules.game_state" -- Estados do jogo (preparação/ação)
require "modules.cards"      -- Sistema de cartas e seus efeitos
require "modules.phases"     -- Fases de preparação e ação
require "modules.card_effects" -- Efeitos visuais das cartas
require "modules.fases"  -- Sistema de 4 fases do jogo

-- ESTADOS DO MENU
MENU_PRINCIPAL = "menu_principal"
MENU_JOGO = "jogo"
MENU_INSTRUCOES = "instrucoes"
MENU_CREDITOS = "creditos"
estado_atual = MENU_PRINCIPAL

-- Opções do menu
opcoes_menu = {"Start Game", "Instruções", "Créditos", "Sair"}
opcao_selecionada = 1
pagina_instrucoes = 1
MAX_PAGINAS_INSTRUCOES = 2

-- Cores para o menu
COR_TITULO1 = LARANJA_CLARO  -- "KING IN" em laranja
COR_TITULO2 = ROXO_CLARO     -- "ORANGE" em roxo
COR_MENU_SELECIONADO = ROXO_CLARO  -- Roxo para seleção
COR_MENU_NORMAL = BRANCO      -- Branco para opções normais
COR_INSTRUCOES = ROXO_CLARO   -- Instruções em roxo

-- Variáveis para animação do fundo do menu
MENU_SCROLL_Y = 0
MENU_SCROLL_VELOCIDADE = 30  -- pixels por segundo

-- Variáveis para viewport
JANELA_LARGURA = 1200
JANELA_ALTURA = 720
JOGO_LARGURA = 900
JOGO_ALTURA = 600
OFFSET_X_VIEWPORT = (JANELA_LARGURA - JOGO_LARGURA) / 2
OFFSET_Y_VIEWPORT = 100

-- Atualizar largura e altura para o jogo
LARGURA = JOGO_LARGURA
ALTURA = JOGO_ALTURA

-- Dimensões para retângulo de cartas à direita
RETANGULO_CARTAS_LARGURA = 150
RETANGULO_CARTAS_ALTURA = 600
RETANGULO_CARTAS_X = OFFSET_X_VIEWPORT + JOGO_LARGURA + 20
RETANGULO_CARTAS_Y = OFFSET_Y_VIEWPORT

-- Variáveis para início da partida
PARTIDA_INICIANDO = true
TEMPO_INICIO_PARTIDA = 0
DURACAO_APARECIMENTO_INIMIGOS = 3.0
INIMIGOS_APARECENDO = false

-- Constantes para telas de fim de jogo
TELA_DERROTA = "derrota"
TELA_VITORIA = "vitoria"
tela_fim_ativa = false
tela_fim_tipo = nil
tempo_tela_fim = 0

-- SISTEMA DE MÚSICA
MUSICA_MENU = "music/Juhani Junkala [Retro Game Music Pack] Title Screen.wav"
MUSICA_VITORIA = "music/Juhani Junkala [Retro Game Music Pack] Ending.wav"
MUSICA_DERROTA = "music/Juhani Junkala [Retro Game Music Pack] Ending.wav"
MUSICA_FASE1 = "music/Juhani Junkala [Retro Game Music Pack] Level 1.wav"
MUSICA_FASE2 = "music/Juhani Junkala [Retro Game Music Pack] Level 2.wav"
MUSICA_FASE3 = "music/Juhani Junkala [Retro Game Music Pack] Level 2.wav"
MUSICA_FASE4 = "music/Juhani Junkala [Retro Game Music Pack] Level 3.wav"

musica_atual = nil
musica_tocando = false
volume_musica = 0.2

function tocar_musica_por_estado()
    local arquivo_musica = nil
    
    if estado_atual == MENU_PRINCIPAL or estado_atual == MENU_INSTRUCOES or estado_atual == MENU_CREDITOS then
        arquivo_musica = MUSICA_MENU
    elseif tela_fim_ativa then
        if tela_fim_tipo == TELA_VITORIA then
            arquivo_musica = MUSICA_VITORIA
        elseif tela_fim_tipo == TELA_DERROTA then
            arquivo_musica = MUSICA_DERROTA
        end
    elseif estado_atual == MENU_JOGO and not MOSTRAR_TELA_FASE and not tela_fim_ativa then
        if fase_atual_jogo == FASE_1 then
            arquivo_musica = MUSICA_FASE1
        elseif fase_atual_jogo == FASE_2 or fase_atual_jogo == FASE_3 then
            arquivo_musica = MUSICA_FASE2
        elseif fase_atual_jogo == FASE_4 then
            arquivo_musica = MUSICA_FASE4
        end
    end
    
    if not arquivo_musica then
        if musica_tocando then
            parar_musica()
        end
        return
    end
    
    if musica_atual == arquivo_musica and musica_tocando then
        return
    end
    
    tocar_musica(arquivo_musica)
end

function tocar_musica(arquivo)
    if musica_tocando then
        love.audio.stop()
        musica_tocando = false
    end
    
    local sucesso, musica = pcall(function()
        return love.audio.newSource(arquivo, "stream")
    end)
    
    if sucesso then
        musica:setLooping(true)
        musica:setVolume(volume_musica)
        musica:play()
        musica_atual = arquivo
        musica_tocando = true
        print("Tocando música: " .. arquivo)
    else
        print("Erro ao carregar música: " .. arquivo)
        musica_atual = nil
        musica_tocando = false
    end
end

function parar_musica()
    if musica_tocando then
        love.audio.stop()
        musica_atual = nil
        musica_tocando = false
        print("Música parada")
    end
end

function set_volume_musica(volume)
    volume_musica = math.max(0, math.min(1, volume))
    if musica_tocando then
        for _, source in ipairs(love.audio.getSources()) do
            source:setVolume(volume_musica)
        end
    end
end

-- FUNÇÕES DE ATUALIZAÇÃO DE ATAQUES

function atualizar_todos_os_ataques(tempo_atual)
    atualizar_ataques(tempo_atual)
end

-- TELAS DE FIM DE JOGO

function mostrar_tela_derrota()
    tela_fim_ativa = true
    tela_fim_tipo = TELA_DERROTA
    tempo_tela_fim = 0
    print("Mostrando tela de derrota")
end

function mostrar_tela_vitoria()
    tela_fim_ativa = true
    tela_fim_tipo = TELA_VITORIA
    tempo_tela_fim = 0
    print("Mostrando tela de vitória")
end

function desenhar_tela_derrota()
    -- Fundo preto
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- Esfera roxa piscando em laranja no centro
    local tempo = love.timer.getTime()
    local piscar = math.sin(tempo * 8) > 0  -- Pisca rápido
    
    -- Tamanho da esfera (com leve pulsação)
    local tamanho_base = 150
    local pulsar = 1 + math.sin(tempo * 5) * 0.05
    local tamanho = tamanho_base * pulsar
    
    -- Posição central
    local x_centro = JANELA_LARGURA / 2
    local y_centro = JANELA_ALTURA / 2 - 50
    
    -- Sombra da esfera
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.circle("fill", x_centro + 5, y_centro + 5, tamanho)
    
    -- Cor da esfera (roxa com piscar laranja)
    if piscar then
        love.graphics.setColor(LARANJA_CLARO)
    else
        love.graphics.setColor(ROXO_CLARO)
    end
    love.graphics.circle("fill", x_centro, y_centro, tamanho)
    
    -- Brilho interno
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.circle("fill", x_centro - 30, y_centro - 30, tamanho / 3)
    
    -- Texto principal "SUA CHANCE FOI PERDIDA"
    love.graphics.setFont(fonte_pausa or love.graphics.newFont(72))
    
    -- Sombra do texto
    love.graphics.setColor(0, 0, 0, 0.7)
    local texto1 = "SUA CHANCE"
    local largura1 = love.graphics.getFont():getWidth(texto1)
    love.graphics.print(texto1, JANELA_LARGURA/2 - largura1/2 + 4, 200 + 4)
    
    local texto2 = "FOI PERDIDA"
    local largura2 = love.graphics.getFont():getWidth(texto2)
    love.graphics.print(texto2, JANELA_LARGURA/2 - largura2/2 + 4, 280 + 4)
    
    -- Texto principal (laranja)
    love.graphics.setColor(LARANJA_CLARO)
    love.graphics.print(texto1, JANELA_LARGURA/2 - largura1/2, 200)
    love.graphics.print(texto2, JANELA_LARGURA/2 - largura2/2, 280)
    
    -- Texto de instrução
    love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(32))
    love.graphics.setColor(ROXO_CLARO)
    local instrucao = "Pressione Z, X ou ENTER para voltar ao menu"
    local largura_inst = love.graphics.getFont():getWidth(instrucao)
    
    -- Efeito de piscar suave na instrução
    local opacidade_inst = 0.7 + math.sin(tempo * 3) * 0.3
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_inst)
    love.graphics.print(instrucao, JANELA_LARGURA/2 - largura_inst/2, 550)
end

function desenhar_tela_vitoria()
    -- Fundo preto
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- Esfera roxa no centro (sem piscar)
    local tempo = love.timer.getTime()
    
    -- Tamanho da esfera (com leve pulsação suave)
    local tamanho_base = 150
    local pulsar = 1 + math.sin(tempo * 3) * 0.03
    local tamanho = tamanho_base * pulsar
    
    -- Posição central
    local x_centro = JANELA_LARGURA / 2
    local y_centro = JANELA_ALTURA / 2 - 50
    
    -- Sombra da esfera
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.circle("fill", x_centro + 5, y_centro + 5, tamanho)
    
    -- Esfera roxa
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.circle("fill", x_centro, y_centro, tamanho)
    
    -- Brilho interno
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.circle("fill", x_centro - 30, y_centro - 30, tamanho / 3)
    
    -- Anéis concêntricos (efeito de "real")
    love.graphics.setColor(ROXO_ESCURO)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", x_centro, y_centro, tamanho + 10)
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", x_centro, y_centro, tamanho + 20)
    
    -- Pequenas partículas de luz ao redor
    for i = 1, 8 do
        local angulo = tempo * 2 + i * math.pi / 4
        local px = x_centro + math.cos(angulo) * (tamanho + 30)
        local py = y_centro + math.sin(angulo) * (tamanho + 30)
        
        love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.5)
        love.graphics.circle("fill", px, py, 5)
    end
    
    -- Texto principal "VOCÊ CONSEGUIU"
    love.graphics.setFont(fonte_pausa or love.graphics.newFont(72))
    
    -- Sombra do texto
    love.graphics.setColor(0, 0, 0, 0.7)
    local texto1 = "VOCÊ CONSEGUIU"
    local largura1 = love.graphics.getFont():getWidth(texto1)
    love.graphics.print(texto1, JANELA_LARGURA/2 - largura1/2 + 4, 150 + 4)
    
    -- Texto principal (roxo)
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.print(texto1, JANELA_LARGURA/2 - largura1/2, 150)
    
    -- Segundo texto "MAS O REI NÃO ESTÁ AQUI"
    love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(48))
    
    local texto2 = "MAS O REI"
    local largura2 = love.graphics.getFont():getWidth(texto2)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print(texto2, JANELA_LARGURA/2 - largura2/2 + 3, 320 + 3)
    love.graphics.setColor(LARANJA_CLARO)
    love.graphics.print(texto2, JANELA_LARGURA/2 - largura2/2, 320)
    
    local texto3 = "NÃO ESTÁ AQUI"
    local largura3 = love.graphics.getFont():getWidth(texto3)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print(texto3, JANELA_LARGURA/2 - largura3/2 + 3, 370 + 3)
    love.graphics.setColor(LARANJA_CLARO)
    love.graphics.print(texto3, JANELA_LARGURA/2 - largura3/2, 370)
    
    -- Texto de instrução
    love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(32))
    love.graphics.setColor(ROXO_CLARO)
    local instrucao = "Pressione Z, X ou ENTER para voltar ao menu"
    local largura_inst = love.graphics.getFont():getWidth(instrucao)
    
    -- Efeito de piscar suave na instrução
    local opacidade_inst = 0.7 + math.sin(tempo * 3) * 0.3
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_inst)
    love.graphics.print(instrucao, JANELA_LARGURA/2 - largura_inst/2, 500)
end

-- FUNÇÕES DO MENU PRINCIPAL

function desenhar_menu_principal()
    -- Fundo ciano escuro base
    love.graphics.setColor(CIANO_MUITO_ESCURO)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- GRADE PRINCIPAL EM MOVIMENTO (linhas diagonais)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.15)
    love.graphics.setLineWidth(1.5)
    
    -- Primeiro conjunto de diagonais (movendo para baixo)
    local espacamento = 50
    local offset_y = MENU_SCROLL_Y
    
    for i = -JANELA_ALTURA, JANELA_LARGURA * 1.5, espacamento do
        local y_inicio = offset_y
        local y_fim = offset_y + JANELA_ALTURA
        
        love.graphics.line(i, y_inicio, i + JANELA_ALTURA, y_fim)
    end
    
    -- Segundo conjunto de diagonais (oposto, também em movimento)
    for i = JANELA_LARGURA + JANELA_ALTURA, -JANELA_ALTURA * 1.5, -espacamento do
        local y_inicio = offset_y
        local y_fim = offset_y + JANELA_ALTURA
        
        love.graphics.line(i, y_inicio, i - JANELA_ALTURA, y_fim)
    end
    
    -- GRADE FINA SOBREPOSTA (linhas horizontais e verticais)
    love.graphics.setColor(0.7, 0.7, 0.7, 0.1)
    love.graphics.setLineWidth(1)
    
    -- Linhas horizontais (movendo para baixo)
    for y = -50, JANELA_ALTURA + 50, 40 do
        local y_pos = y + offset_y
        love.graphics.line(0, y_pos, JANELA_LARGURA, y_pos)
    end
    
    -- Linhas verticais (fixas, mas com fade baseado no scroll)
    for x = 0, JANELA_LARGURA, 40 do
        love.graphics.line(x, 0, x, JANELA_ALTURA)
    end
    
    -- PONTOS DE INTERSEÇÃO (movendo para baixo)
    love.graphics.setColor(0.9, 0.9, 0.9, 0.2)
    for x = 0, JANELA_LARGURA, 40 do
        for y = -50, JANELA_ALTURA + 50, 40 do
            local y_pos = y + offset_y
            love.graphics.circle("fill", x, y_pos, 2)
        end
    end
    
    -- EFEITO DE BRILHO CENTRAL (estático para não poluir)
    local center_x, center_y = JANELA_LARGURA/2, JANELA_ALTURA/2
    for i = 1, 3 do
        local radius = i * 100
        love.graphics.setColor(CIANO_MUITO_ESCURO[1], CIANO_MUITO_ESCURO[2] + 0.2, CIANO_MUITO_ESCURO[3] + 0.2, 0.03 / i)
        love.graphics.circle("fill", center_x, center_y, radius)
    end
    
    -- EFEITO DE NEBLINA NOS CANTOS (estático)
    love.graphics.setColor(0, 0.3, 0.5, 0.1)
    local cantos = {
        {0, 0}, {JANELA_LARGURA, 0}, {0, JANELA_ALTURA}, {JANELA_LARGURA, JANELA_ALTURA}
    }
    for _, canto in ipairs(cantos) do
        love.graphics.circle("fill", canto[1], canto[2], 200)
    end
    
    -- TÍTULO DO JOGO (com sombra)
    love.graphics.setFont(love.graphics.newFont(72))
    
    local texto_completo = "KING IN ORANGE"
    local largura_total = love.graphics.getFont():getWidth(texto_completo)
    local x_inicio = JANELA_LARGURA/2 - largura_total/2
    
    -- Primeira parte: "KING IN"
    local texto1 = "KING IN"
    local largura1 = love.graphics.getFont():getWidth(texto1)
    
    -- Sombra do título (mais escura)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print(texto1, x_inicio + 5, 150 + 5)
    
    -- Texto principal "KING IN" em laranja
    love.graphics.setColor(COR_TITULO1)
    love.graphics.print(texto1, x_inicio, 150)
    
    -- Segunda parte: "ORANGE"
    local texto2 = "ORANGE"
    local x2 = x_inicio + largura1 + 10
    
    -- Sombra
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print(texto2, x2 + 5, 150 + 5)
    
    -- Texto principal "ORANGE" em roxo
    love.graphics.setColor(COR_TITULO2)
    love.graphics.print(texto2, x2, 150)
    
    -- OPÇÕES DO MENU
    love.graphics.setFont(love.graphics.newFont(36))
    
    local y_inicio_menu = 350
    local espacamento_opcoes = 60
    
    for i, opcao in ipairs(opcoes_menu) do
        local cor = COR_MENU_NORMAL
        local largura_opcao = love.graphics.getFont():getWidth(opcao)
        local x_opcao = JANELA_LARGURA/2 - largura_opcao/2
        
        if i == opcao_selecionada then
            cor = COR_MENU_SELECIONADO
            
            -- Efeito de brilho pulsante ao redor da opção selecionada
            local pulso = 0.3 + math.sin(love.timer.getTime() * 5) * 0.2
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], pulso)
            love.graphics.circle("fill", 
                x_opcao - 20, 
                y_inicio_menu + (i-1) * espacamento_opcoes + 18, 
                25)
        end
        
        -- Sombra da opção
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.print(opcao, x_opcao + 3, y_inicio_menu + (i-1) * espacamento_opcoes + 3)
        
        -- Texto principal
        love.graphics.setColor(cor)
        love.graphics.print(opcao, x_opcao, y_inicio_menu + (i-1) * espacamento_opcoes)
        
        -- Indicador para opção selecionada
        if i == opcao_selecionada then
            love.graphics.setColor(COR_MENU_SELECIONADO)
            love.graphics.polygon("fill",
                x_opcao - 40, y_inicio_menu + (i-1) * espacamento_opcoes + 18 - 8,
                x_opcao - 20, y_inicio_menu + (i-1) * espacamento_opcoes + 18,
                x_opcao - 40, y_inicio_menu + (i-1) * espacamento_opcoes + 18 + 8
            )
        end
    end
    
    -- INSTRUÇÕES
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(COR_INSTRUCOES)
    
    local instrucoes = {
        "Use W/S ou Setas para navegar",
        "Pressione ENTER para selecionar"
    }
    
    for i, texto in ipairs(instrucoes) do
        -- Sombra das instruções
        love.graphics.setColor(0, 0, 0, 0.5)
        local largura_instrucao = love.graphics.getFont():getWidth(texto)
        love.graphics.print(texto, 
            JANELA_LARGURA/2 - largura_instrucao/2 + 2, 
            600 + (i-1) * 30 + 2)
        
        -- Texto principal
        love.graphics.setColor(COR_INSTRUCOES)
        love.graphics.print(texto, 
            JANELA_LARGURA/2 - largura_instrucao/2, 
            600 + (i-1) * 30)
    end
    
    -- VERSÃO
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.setFont(love.graphics.newFont(18))
    local texto_versao = "v1.0"
    local largura_versao = love.graphics.getFont():getWidth(texto_versao)
    love.graphics.print(texto_versao, JANELA_LARGURA - largura_versao - 20, JANELA_ALTURA - 30)
end

function atualizar_menu(dt)
    -- Função vazia
end

-- Função para processar inputs do menu
function processar_input_menu(key)
    if estado_atual == MENU_PRINCIPAL then
        if key == "w" or key == "up" then
            opcao_selecionada = opcao_selecionada - 1
            if opcao_selecionada < 1 then
                opcao_selecionada = #opcoes_menu
            end
            
        elseif key == "s" or key == "down" then
            opcao_selecionada = opcao_selecionada + 1
            if opcao_selecionada > #opcoes_menu then
                opcao_selecionada = 1
            end
            
        elseif key == "return" or key == "kpenter" then
            if opcao_selecionada == 1 then  -- Start Game
                estado_atual = MENU_JOGO
                -- Resetar para fase 1
                resetar_para_fase1()
                -- Mostrar tela da fase 1
                mostrar_tela_fase()
                print("Iniciando partida - Fase 1...")
                
            elseif opcao_selecionada == 2 then  -- Instruções
                estado_atual = MENU_INSTRUCOES
                pagina_instrucoes = 1
                print("Abrindo instruções - Página 1")
                
            elseif opcao_selecionada == 3 then  -- Créditos
                estado_atual = MENU_CREDITOS
                print("Abrindo créditos")
                
            elseif opcao_selecionada == 4 then  -- Sair
                love.event.quit()
            end
        elseif key == "escape" then
            if estado_atual == MENU_PRINCIPAL then
                love.event.quit()
            end
        end
        
    elseif estado_atual == MENU_INSTRUCOES then
        if key == "z" then
            -- Avançar página
            if pagina_instrucoes < MAX_PAGINAS_INSTRUCOES then
                pagina_instrucoes = pagina_instrucoes + 1
                print("Instruções - Página " .. pagina_instrucoes)
            end
        elseif key == "x" then
            -- Voltar página
            if pagina_instrucoes > 1 then
                pagina_instrucoes = pagina_instrucoes - 1
                print("Instruções - Página " .. pagina_instrucoes)
            end
        elseif key == "return" or key == "kpenter" or key == "escape" then
            -- Voltar ao menu principal
            estado_atual = MENU_PRINCIPAL
            print("Voltando ao menu principal")
        end
        
    elseif estado_atual == MENU_CREDITOS then
        if key == "return" or key == "kpenter" or key == "escape" or key == "z" or key == "x" then
            -- Voltar ao menu principal
            estado_atual = MENU_PRINCIPAL
            print("Voltando ao menu principal")
        end
    end
end

function desenhar_instrucoes()
    -- Fundo ciano escuro (como no menu)
    love.graphics.setColor(CIANO_MUITO_ESCURO)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- GRADE DE FUNDO (mesmo estilo do menu)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.1)
    love.graphics.setLineWidth(1)
    
    -- Linhas diagonais
    local espacamento = 50
    for i = -JANELA_ALTURA, JANELA_LARGURA * 1.5, espacamento do
        love.graphics.line(i, 0, i + JANELA_ALTURA, JANELA_ALTURA)
    end
    
    for i = JANELA_LARGURA + JANELA_ALTURA, -JANELA_ALTURA * 1.5, -espacamento do
        love.graphics.line(i, 0, i - JANELA_ALTURA, JANELA_ALTURA)
    end
    
    -- Título principal com borda
    local fonte_titulo = fonte_pausa or love.graphics.newFont(48)
    local titulo = "INSTRUÇÕES"
    local largura_titulo = fonte_titulo:getWidth(titulo)
    desenhar_texto_com_borda(fonte_titulo, titulo, JANELA_LARGURA/2 - largura_titulo/2, 40, ROXO_CLARO)
    
    -- Indicador de página com borda
    local fonte_pagina = fonte_instrucoes or love.graphics.newFont(20)
    local texto_pagina = "Página " .. pagina_instrucoes .. " de " .. MAX_PAGINAS_INSTRUCOES
    local largura_pagina = fonte_pagina:getWidth(texto_pagina)
    desenhar_texto_com_borda(fonte_pagina, texto_pagina, JANELA_LARGURA/2 - largura_pagina/2, 95, ROXO_CLARO)
    
    -- Linha divisória
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.setLineWidth(2)
    love.graphics.line(100, 120, JANELA_LARGURA - 100, 120)
    
    if pagina_instrucoes == 1 then
        -- PÁGINA 1: FASE DE PREPARAÇÃO - DOIS PARÁGRAFOS COM BORDA NAS PALAVRAS
        local y_inicio = 150
        
        -- Título da seção com borda
        local fonte_secao = fonte_instrucoes or love.graphics.newFont(22)
        local titulo_prep = "FASE DE PREPARAÇÃO"
        local largura_prep = fonte_secao:getWidth(titulo_prep)
        desenhar_texto_com_borda(fonte_secao, titulo_prep, JANELA_LARGURA/2 - largura_prep/2, y_inicio - 15, ROXO_CLARO)
        
        -- Texto introdutório com borda
        local fonte_intro = fonte_instrucoes or love.graphics.newFont(18)
        local intro = "Aqui você se prepara escolhendo cartas para a fase de ação"
        local largura_intro = fonte_intro:getWidth(intro)
        desenhar_texto_com_borda(fonte_intro, intro, JANELA_LARGURA/2 - largura_intro/2, y_inicio + 10, ROXO_CLARO)
        
        -- Posições das colunas
        local x_esq = 180
        local x_dir = 650
        local y_caixa = y_inicio + 45
        
        -- Conteúdo da coluna esquerda (todas as palavras com borda)
        local fonte_texto = fonte_instrucoes or love.graphics.newFont(18)
        
        local texto_esquerdo = {
            "• ESCOLHA DE CARTAS:",
            "  Selecione até 5 cartas",
            "  para usar na fase de ação",
            "",
            "• CUSTO:",
            "  Cada carta tem um custo (1-5)",
            "  Custo máximo por fase: 5",
            "",
            "• CARTAS ESPECIAIS:",
            "  Carta A - Copia a próxima carta",
            "  Demais cartas - Efeitos diversos"
        }
        
        for i, texto in ipairs(texto_esquerdo) do
            desenhar_texto_com_borda(fonte_texto, texto, x_esq, y_caixa + (i-1) * 22, ROXO_CLARO)
        end
        
        -- Conteúdo da coluna direita (todas as palavras com borda)
        local texto_direito = {
            "• CONTROLES:",
            "  A/← - Selecionar esquerda",
            "  D/→ - Selecionar direita",
            "  Z - Selecionar/Deselecionar",
            "  X - Cancelar última carta",
            "  C - Voltar à fase de ação",
            "  ESPAÇO - Resetar baralho",
            "",
            "• DICA:",
            "  Planeje suas cartas",
            "  com antecedência!"
        }
        
        for i, texto in ipairs(texto_direito) do
            desenhar_texto_com_borda(fonte_texto, texto, x_dir, y_caixa + (i-1) * 22, ROXO_CLARO)
        end
        
    elseif pagina_instrucoes == 2 then
        -- PÁGINA 2: FASE DE AÇÃO - DOIS PARÁGRAFOS COM BORDA NAS PALAVRAS
        local y_inicio = 150
        
        -- Título da seção com borda
        local fonte_secao = fonte_instrucoes or love.graphics.newFont(22)
        local titulo_acao = "FASE DE AÇÃO"
        local largura_acao = fonte_secao:getWidth(titulo_acao)
        desenhar_texto_com_borda(fonte_secao, titulo_acao, JANELA_LARGURA/2 - largura_acao/2, y_inicio - 15, ROXO_CLARO)
        
        -- Posições das colunas
        local x_esq = 180
        local x_dir = 650
        local y_caixa = y_inicio + 25
        
        -- Conteúdo da coluna esquerda (todas as palavras com borda)
        local fonte_texto = fonte_instrucoes or love.graphics.newFont(18)
        
        local texto_esquerdo = {
            "• MOVIMENTO:",
            "  W/↑ - Mover para cima",
            "  S/↓ - Mover para baixo",
            "  A/← - Mover para esquerda",
            "  D/→ - Mover para direita",
            "",
            "• ATAQUE:",
            "  Z / Clique - Atirar",
            "",
            "• CARTAS:",
            "  X - Usar próxima carta",
            "  Painel direito mostra fila"
        }
        
        for i, texto in ipairs(texto_esquerdo) do
            desenhar_texto_com_borda(fonte_texto, texto, x_esq, y_caixa + (i-1) * 22, ROXO_CLARO)
        end
        
        -- Conteúdo da coluna direita (todas as palavras com borda)
        local texto_direito = {
            "• BARRA DE CUSTOMIZAÇÃO:",
            "  Enche automaticamente",
            "  Pressione C quando cheia",
            "  para entrar em preparação",
            "",
            "• ÁREAS DE PERIGO:",
            "  NÃO PISE NOS QUADRADOS",
            "  QUE PISCAM LARANJA!",
            "  Isso é onde os inimigos",
            "  irão atacar",
            "",
            "  Fique atento aos avisos!"
        }
        
        for i, texto in ipairs(texto_direito) do
            desenhar_texto_com_borda(fonte_texto, texto, x_dir, y_caixa + (i-1) * 22, ROXO_CLARO)
        end
        
        -- Ícone de alerta com borda
        local tempo = love.timer.getTime()
        local piscar = math.sin(tempo * 8) > 0
        
        if piscar then
            local fonte_alerta = fonte_instrucoes or love.graphics.newFont(30)
            desenhar_texto_com_borda(fonte_alerta, "!!!", 130, 520, ROXO_CLARO)
            desenhar_texto_com_borda(fonte_alerta, "!!!", JANELA_LARGURA - 160, 520, ROXO_CLARO)
        end
    end
    
    -- Navegação entre páginas
    local fonte_nav = fonte_instrucoes or love.graphics.newFont(18)
    local y_nav = 640
    
    if pagina_instrucoes > 1 then
        local texto_anterior = "X - Página anterior"
        desenhar_texto_com_borda(fonte_nav, texto_anterior, 100, y_nav, ROXO_CLARO)
    end
    
    if pagina_instrucoes < MAX_PAGINAS_INSTRUCOES then
        local texto_proxima = "Z - Próxima página"
        desenhar_texto_com_borda(fonte_nav, texto_proxima, JANELA_LARGURA - 280, y_nav, ROXO_CLARO)
    end
    
    -- Instrução para voltar
    local texto_voltar = "ENTER / ESC - Voltar ao menu"
    local largura_voltar = fonte_nav:getWidth(texto_voltar)
    desenhar_texto_com_borda(fonte_nav, texto_voltar, JANELA_LARGURA/2 - largura_voltar/2, 680, ROXO_CLARO)
    
    -- Desenhar setas indicativas
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.setLineWidth(3)
    
    -- Seta esquerda (se não estiver na primeira página)
    if pagina_instrucoes > 1 then
        love.graphics.polygon("fill",
            50, y_nav + 10,
            70, y_nav + 3,
            70, y_nav + 17
        )
    end
    
    -- Seta direita (se não estiver na última página)
    if pagina_instrucoes < MAX_PAGINAS_INSTRUCOES then
        love.graphics.polygon("fill",
            JANELA_LARGURA - 50, y_nav + 10,
            JANELA_LARGURA - 70, y_nav + 3,
            JANELA_LARGURA - 70, y_nav + 17
        )
    end
end

-- TELA DE CRÉDITOS
function desenhar_creditos()
    -- Fundo ciano escuro (como no menu)
    love.graphics.setColor(CIANO_MUITO_ESCURO)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- GRADE DE FUNDO (mesmo estilo do menu)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.1)
    love.graphics.setLineWidth(1)
    
    -- Linhas diagonais
    local espacamento = 50
    for i = -JANELA_ALTURA, JANELA_LARGURA * 1.5, espacamento do
        love.graphics.line(i, 0, i + JANELA_ALTURA, JANELA_ALTURA)
    end
    
    for i = JANELA_LARGURA + JANELA_ALTURA, -JANELA_ALTURA * 1.5, -espacamento do
        love.graphics.line(i, 0, i - JANELA_ALTURA, JANELA_ALTURA)
    end
    
    -- Título principal com borda
    local fonte_titulo = fonte_pausa or love.graphics.newFont(48)
    local titulo = "CRÉDITOS"
    local largura_titulo = fonte_titulo:getWidth(titulo)
    desenhar_texto_com_borda(fonte_titulo, titulo, JANELA_LARGURA/2 - largura_titulo/2, 80, LARANJA_CLARO)
    
    -- Caixa de conteúdo
    local largura_caixa = 800
    local altura_caixa = 350
    local x_caixa = JANELA_LARGURA/2 - largura_caixa/2
    local y_caixa = 200
    
    -- Fundo da caixa
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", x_caixa, y_caixa, largura_caixa, altura_caixa, 15)
    
    -- Borda da caixa
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x_caixa, y_caixa, largura_caixa, altura_caixa, 15)
    
    -- Texto dos créditos
    local fonte_creditos = fonte_instrucoes or love.graphics.newFont(28)
    local y_texto = y_caixa + 50
    local espacamento_creditos = 50
    
    -- Programação
    desenhar_texto_com_borda(fonte_creditos, "Programação e direção:", x_caixa + 50, y_texto, LARANJA_CLARO)
    desenhar_texto_com_borda(fonte_creditos, "Matheus Santos da Costa Alves", x_caixa + 50, y_texto + 35, ROXO_CLARO)
    
    -- Músicas
    desenhar_texto_com_borda(fonte_creditos, "Músicas:", x_caixa + 50, y_texto + 100, LARANJA_CLARO)
    desenhar_texto_com_borda(fonte_creditos, "Juhani Junkala", x_caixa + 50, y_texto + 135, ROXO_CLARO)
    desenhar_texto_com_borda(fonte_creditos, "via https://subspaceaudio.itch.io/indie-game-music-loops", x_caixa + 50, y_texto + 170, ROXO_CLARO)
    
    -- Aviso comercial
    desenhar_texto_com_borda(fonte_creditos, "produto sem fim comerciais", x_caixa + 50, y_texto + 250, ROXO_CLARO)
    
    -- Instrução para voltar
    local fonte_inst = fonte_instrucoes or love.graphics.newFont(24)
    local texto_voltar = "Pressione Z, X, ENTER ou ESC para voltar ao menu"
    local largura_voltar = fonte_inst:getWidth(texto_voltar)
    
    -- Efeito de piscar suave
    local tempo = love.timer.getTime()
    local opacidade_inst = 0.7 + math.sin(tempo * 3) * 0.3
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_inst)
    love.graphics.setFont(fonte_inst)
    love.graphics.print(texto_voltar, JANELA_LARGURA/2 - largura_voltar/2, 600)
end

-- FUNÇÃO DE RESET COMPLETO DO JOGO
function resetar_jogo_completo()
    VIDA_JOGADOR = vida_maxima_jogador
    
    -- Resetar para fase 1
    resetar_para_fase1()
    
    disparos = {}
    disparos_quadrado = {}
    cartas_selecionadas = {}
    cartas_usadas = {}
    custo_atual = 0
    cartas_efeitos_ativos = {}
    colunas_conquistadas = {}
    colunas_cedidas = {}
    dano_dobrado = false
    fases_dano_dobrado = 0
    imune_dano = false
    bloqueado_movimento = false
    bloqueado_ataque = false
    inimigos_bloqueados = false
    tempo_bloqueio = 0
    
    -- Resetar variáveis da Carta 2
    carta2_ativa = false
    carta2_pos_original = nil
    carta2_pos_visual = nil
    carta2_coluna_ataque = nil
    carta2_tempo_restante = 0
    efeito_espada.ativo = false
    efeito_espada.particulas = {}
    
    -- Resetar variáveis das novas cartas
    carta6_ativa = false
    carta6_inimigos_atingidos = {}
    carta9_ativa = false
    carta9_inimigos_atingidos = {}
    carta8_ativa = false
    carta8_projeteis = {}
    carta8_inimigos_atingidos = {}
    
    -- Resetar variáveis de efeitos de carta
    carta_em_efeito = false
    carta_efeito_tipo = nil
    carta_efeito_dados = {}
    
    armadilha_carta_8 = nil
    
    cartas_nao_selecionadas = {}
    
    mao_atual = {}
    
    inicializar_deck()
    resetar_efeitos_ataque()
    resetar_variaveis_cartas()
    
    -- Resetar todos os inimigos
    inicializar_esfera()
    inicializar_quadrados()
    inicializar_triangulo()
    
    PARTIDA_INICIANDO = false
    INIMIGOS_APARECENDO = false
    MOSTRAR_PREPARADO = false
    tempo_preparado = 0
    barra_customizacao = 0
    
    -- Resetar tela de fim
    tela_fim_ativa = false
    tela_fim_tipo = nil
    
    print("Jogo resetado para fase 1!")
end

-- FUNÇÕES DE DESENHO DO JOGO

-- Função para desenhar efeito de aparecimento dos inimigos
function desenhar_aparecimento_inimigos()
    if INIMIGOS_APARECENDO then
        -- Fundo preto semi-transparente
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
        
        -- Efeito visual dos inimigos aparecendo
        local progresso = TEMPO_INICIO_PARTIDA / DURACAO_APARECIMENTO_INIMIGOS
        
        -- Mostrar apenas os inimigos da fase atual
        if fase_atual_jogo == FASE_1 or fase_atual_jogo == FASE_4 then
            if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[1] > 0 then
                local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
                local tamanho_atual = tamanho_bola_inimiga * progresso
                local pulso = 1 + math.sin(love.timer.getTime() * 6 + 2) * 0.2
                
                love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], progresso)
                love.graphics.circle("fill",
                    celula_bola_inimiga.centro_x,
                    celula_bola_inimiga.centro_y,
                    tamanho_atual * pulso
                )
            end
        end
        
        if fase_atual_jogo == FASE_2 or fase_atual_jogo == FASE_3 then
            -- Mostrar quadrados ou triângulo dependendo da fase
            if inimigo_fase2 == "quadrado" or inimigo_nao_selecionado_fase2 == "quadrado" then
                for _, quad in ipairs(quadrados) do
                    if quad.vivo and quad.pos[1] > 0 then
                        local celula_quadrado = GRID_CELULAS[quad.pos[1]][quad.pos[2]]
                        local tamanho_atual = tamanho_quadrado * progresso
                        local pulso = 1 + math.sin(love.timer.getTime() * 8 + quad.id) * 0.2
                        
                        love.graphics.setColor(QUADRADO_COR_NORMAL[1], QUADRADO_COR_NORMAL[2], QUADRADO_COR_NORMAL[3], progresso)
                        love.graphics.rectangle("fill",
                            celula_quadrado.centro_x - tamanho_atual * pulso/2,
                            celula_quadrado.centro_y - tamanho_atual * pulso/2,
                            tamanho_atual * pulso,
                            tamanho_atual * pulso
                        )
                    end
                end
            end
            
            if inimigo_fase2 == "triangulo" or inimigo_nao_selecionado_fase2 == "triangulo" then
                if VIDA_TRIANGULO > 0 and pos_triangulo[1] > 0 then
                    local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
                    local tamanho_atual = tamanho_triangulo * progresso
                    local pulso = 1 + math.sin(love.timer.getTime() * 10) * 0.2
                    
                    love.graphics.setColor(TRIANGULO_COR_NORMAL[1], TRIANGULO_COR_NORMAL[2], TRIANGULO_COR_NORMAL[3], progresso)
                    love.graphics.polygon("fill",
                        celula_triangulo.centro_x, celula_triangulo.centro_y - tamanho_atual * pulso,
                        celula_triangulo.centro_x + tamanho_atual * pulso, celula_triangulo.centro_y + tamanho_atual * pulso/2,
                        celula_triangulo.centro_x - tamanho_atual * pulso, celula_triangulo.centro_y + tamanho_atual * pulso/2
                    )
                end
            end
        end
    end
end

-- Função para desenhar a bola do jogador
function desenhar_bola_jogador()
    if VIDA_JOGADOR > 0 then
        local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
        desenhar_bola(ROXO_CLARO, 
            {celula_bola.centro_x, celula_bola.centro_y}, 
            tamanho_bola, animacao_bola)
        desenhar_seta_direita({celula_bola.centro_x, celula_bola.centro_y})
    end
end

-- Função para desenhar todos os inimigos
function desenhar_todos_inimigos()
    -- Desenha esfera (enemies.lua)
    if (fase_atual_jogo == FASE_1 or fase_atual_jogo == FASE_4) and esfera_esta_viva() then
        desenhar_esfera()
        desenhar_efeitos_preparacao_esfera()
        desenhar_efeito_transparencia_esfera()
    end
    
    -- Desenha quadrados (enemies_quadrado.lua)
    if (fase_atual_jogo == FASE_2 or fase_atual_jogo == FASE_3) and quadrado_esta_vivo() then
        desenhar_quadrados()
        desenhar_efeitos_preparacao_quadrados()
        desenhar_efeito_transparencia_quadrados()
    end
    
    -- Desenha triângulo (enemies_triangulo.lua) - APENAS O DESENHO BÁSICO
    if (fase_atual_jogo == FASE_2 or fase_atual_jogo == FASE_3) and triangulo_esta_vivo() then
        desenhar_triangulo()
        -- Os efeitos do triângulo são desenhados separadamente na função desenhar_jogo_normal
    end
end

-- Função auxiliar para desenhar o jogo
function desenhar_jogo_normal()
    if INIMIGOS_APARECENDO then
        desenhar_aparecimento_inimigos()
        return
    end
    
    -- Desenhar retângulo de cartas
    desenhar_retangulo_cartas()
    
    -- Configurar viewport
    love.graphics.setScissor(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT, JOGO_LARGURA, JOGO_ALTURA)
    love.graphics.translate(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT)
    
    -- Fundo e grid (agora desenha_fundo_abstracto cobre toda a área com ciano)
    desenhar_fundo_abstracto()
    desenhar_grid()
    aplicar_efeito_transparencia()
    
    -- Desenhar efeitos do triângulo
    if desenhar_efeitos_triangulo then
        desenhar_efeitos_triangulo()
    end
    
    if desenhar_projeteis_triangulo then
        desenhar_projeteis_triangulo()
    end
    
    -- Desenhar efeito ciano da fase 4
    if desenhar_efeito_ciano_fase4 then
        desenhar_efeito_ciano_fase4()
    end
    
    -- Desenhar projéteis da fase 4 da esfera
    if desenhar_projeteis_fase4 then
        desenhar_projeteis_fase4()
    end
    
    -- Desenhar outros efeitos de ataque (se houver)
    if desenhar_efeitos_ataque then
        desenhar_efeitos_ataque()
    end
    
    -- Desenha efeitos de carta
    if desenhar_armadilha_carta_8 then
        desenhar_armadilha_carta_8()
    end
    if desenhar_efeito_carta2 then
        desenhar_efeito_carta2()
    end
    if desenhar_jogador_carta2 then
        desenhar_jogador_carta2()
    end
    if desenhar_efeito_horizontal then
        desenhar_efeito_horizontal()
    end
    if desenhar_projeteis_carta8 then
        desenhar_projeteis_carta8()
    end
    
    -- Projéteis e personagens
    desenhar_projeteis()
    desenhar_todos_inimigos()
    desenhar_bola_jogador()
    
    -- UI dentro da viewport
    desenhar_ui()
    
    -- Barra de customização
    if fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        desenhar_barra_customizacao()
    end
    
    -- Remover viewport
    love.graphics.origin()
    love.graphics.setScissor()
    
    -- Elementos em tela cheia
    if fase_atual == FASE_PREPARACAO then
        desenhar_fase_preparacao()
    end
    if MOSTRAR_PREPARADO and fase_atual == FASE_ACAO then
        desenhar_preparado()
    end
    if desenhar_efeitos_carta then
        desenhar_efeitos_carta()
    end
    if JOGO_PAUSADO then
        desenhar_botao_pause()
    end
    
    -- Mostrar número da fase no canto superior esquerdo
    if estado_atual == MENU_JOGO and not MOSTRAR_TELA_FASE then
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.setColor(get_cor_fase())
        local texto_fase = "FASE " .. fase_atual_jogo
        love.graphics.print(texto_fase, 20, 20)
    end
end

function desenhar_retangulo_cartas()
    local fonte_inst = fonte_instrucoes or love.graphics.newFont(16)
    love.graphics.setFont(fonte_inst)
    
    if fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        -- RETÂNGULO DE CARTAS (À DIREITA DO VIEWPORT)
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.2)
        love.graphics.rectangle("fill", 
            RETANGULO_CARTAS_X, RETANGULO_CARTAS_Y, 
            RETANGULO_CARTAS_LARGURA, RETANGULO_CARTAS_ALTURA, 10)
        
        -- Borda do retângulo
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.8)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", 
            RETANGULO_CARTAS_X, RETANGULO_CARTAS_Y, 
            RETANGULO_CARTAS_LARGURA, RETANGULO_CARTAS_ALTURA, 10)
        
        -- Título do retângulo
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 1)
        local titulo = "CARTAS"
        local largura_titulo = fonte_inst:getWidth(titulo)
        love.graphics.print(titulo, 
            RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - largura_titulo)/2, 
            RETANGULO_CARTAS_Y + 15)
        
        -- Desenhar cartas selecionadas na ordem
        local tamanho_carta = 50
        local espacamento = 15
        local x_cartas = RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - tamanho_carta)/2
        local y_inicio = RETANGULO_CARTAS_Y + 50
        local max_cartas_visiveis = math.floor((RETANGULO_CARTAS_ALTURA - 120) / (tamanho_carta + espacamento))
        
        if #cartas_selecionadas > 0 then
            for i = 1, math.min(#cartas_selecionadas, max_cartas_visiveis) do
                local carta = cartas_selecionadas[i]
                local y = y_inicio + (i-1) * (tamanho_carta + espacamento)
                
                local cor_fundo, cor_borda
                if carta.cor_usada then
                    cor_fundo = {CIANO[1], CIANO[2], CIANO[3], 0.7}
                    cor_borda = {0, 0.8, 1, 1}
                elseif carta.id == "A" then
                    cor_fundo = ROXO_ESCURO
                    cor_borda = ROXO_CLARO
                else
                    cor_fundo = LARANJA_ESCURO
                    cor_borda = LARANJA_CLARO
                end
                
                love.graphics.setColor(cor_fundo[1], cor_fundo[2], cor_fundo[3], cor_fundo[4] or 1)
                love.graphics.rectangle("fill", x_cartas, y, tamanho_carta, tamanho_carta, 5)
                
                love.graphics.setColor(cor_borda[1], cor_borda[2], cor_borda[3], cor_borda[4] or 1)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", x_cartas, y, tamanho_carta, tamanho_carta, 5)
                
                local fonte_carta = fonte_instrucoes or love.graphics.newFont(20)
                love.graphics.setFont(fonte_carta)
                
                love.graphics.setColor(PRETO)
                local largura_texto = fonte_carta:getWidth(carta.id)
                local altura_texto = fonte_carta:getHeight()
                love.graphics.print(carta.id, 
                    x_cartas + (tamanho_carta - largura_texto)/2, 
                    y + (tamanho_carta - altura_texto)/2)
                
                if i == 1 then
                    love.graphics.setColor(VERDE)
                    love.graphics.setLineWidth(2)
                    love.graphics.polygon("fill", 
                        x_cartas + tamanho_carta/2, y - 8,
                        x_cartas + tamanho_carta/2 - 5, y - 3,
                        x_cartas + tamanho_carta/2 + 5, y - 3
                    )
                end
            end
            
            local y_contador = y_inicio + math.min(#cartas_selecionadas, max_cartas_visiveis) * (tamanho_carta + espacamento) + 10
            love.graphics.setColor(BRANCO)
            local texto_contador = "Selecionadas: " .. #cartas_selecionadas
            love.graphics.print(texto_contador, 
                RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - fonte_inst:getWidth(texto_contador))/2,
                y_contador)
        else
            love.graphics.setColor(BRANCO)
            local mensagem_vazio = "Nenhuma\ncarta\nselecionada"
            love.graphics.printf(mensagem_vazio,
                RETANGULO_CARTAS_X + 10,
                RETANGULO_CARTAS_Y + RETANGULO_CARTAS_ALTURA/2 - 30,
                RETANGULO_CARTAS_LARGURA - 20,
                "center")
        end
        
        -- QUADRADO DO DECK
        local tamanho_quadrado = 60
        local x_quadrado = RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - tamanho_quadrado)/2
        local y_quadrado = RETANGULO_CARTAS_Y + RETANGULO_CARTAS_ALTURA - tamanho_quadrado - 20
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.3)
        love.graphics.rectangle("fill", x_quadrado, y_quadrado, tamanho_quadrado, tamanho_quadrado, 8)
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x_quadrado, y_quadrado, tamanho_quadrado, tamanho_quadrado, 8)
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 1)
        local fonte_deck = fonte_instrucoes or love.graphics.newFont(14)
        love.graphics.setFont(fonte_deck)
        local texto_deck = "DECK"
        local largura_texto_deck = fonte_deck:getWidth(texto_deck)
        love.graphics.print(texto_deck, 
            x_quadrado + (tamanho_quadrado - largura_texto_deck)/2, 
            y_quadrado + 8)
        
        local cartas_restantes = #deck_atual
        
        local fonte_numero = fonte_vida or love.graphics.newFont(24)
        love.graphics.setFont(fonte_numero)
        love.graphics.setColor(BRANCO)
        local texto_numero = tostring(cartas_restantes)
        local largura_numero = fonte_numero:getWidth(texto_numero)
        local altura_numero = fonte_numero:getHeight()
        love.graphics.print(texto_numero, 
            x_quadrado + (tamanho_quadrado - largura_numero)/2, 
            y_quadrado + (tamanho_quadrado - altura_numero)/2 + 5)
        
        love.graphics.setFont(fonte_deck)
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.8)
        local texto_restantes = "restantes"
        local largura_restantes = fonte_deck:getWidth(texto_restantes)
        love.graphics.print(texto_restantes, 
            x_quadrado + (tamanho_quadrado - largura_restantes)/2, 
            y_quadrado + tamanho_quadrado - 20)
    elseif fase_atual == FASE_PREPARACAO then
        -- DURANTE FASE DE PREPARAÇÃO: Mostrar informações do deck
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.2)
        love.graphics.rectangle("fill", 
            RETANGULO_CARTAS_X, RETANGULO_CARTAS_Y, 
            RETANGULO_CARTAS_LARGURA, RETANGULO_CARTAS_ALTURA, 10)
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.8)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", 
            RETANGULO_CARTAS_X, RETANGULO_CARTAS_Y, 
            RETANGULO_CARTAS_LARGURA, RETANGULO_CARTAS_ALTURA, 10)
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 1)
        local titulo = "INFORMAÇÕES"
        local largura_titulo = fonte_inst:getWidth(titulo)
        love.graphics.print(titulo, 
            RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - largura_titulo)/2, 
            RETANGULO_CARTAS_Y + 15)
        
        love.graphics.setColor(BRANCO)
        local y_info = RETANGULO_CARTAS_Y + 50
        local espacamento_info = 25
        
        local infos = {
            "Custo atual:",
            "  " .. custo_atual .. "/5",
            "",
            "Cartas na mão:",
            "  " .. #mao_atual,
            "",
            "Cartas selecionadas:",
            "  " .. #cartas_selecionadas,
            "",
            "Cartas no deck:",
            "  " .. #deck_atual,
            "",
            "Cartas usadas:",
            "  " .. #cartas_usadas
        }
        
        for i, texto in ipairs(infos) do
            if i == 1 or i == 4 or i == 7 or i == 10 or i == 13 then
                love.graphics.setColor(CIANO)
            else
                love.graphics.setColor(BRANCO)
            end
            love.graphics.print(texto, RETANGULO_CARTAS_X + 10, y_info)
            y_info = y_info + espacamento_info
        end
    end
end

-- FUNÇÕES DE ATUALIZAÇÃO DO JOGO

-- Função para atualizar IA de todos os inimigos
function atualizar_ia_inimigos(tempo_atual, dt)
    -- Atualiza animações
    animacao_bola = animacao_bola + 1
    animacao_triangulo = animacao_triangulo + 1
    animacao_quadrado = animacao_quadrado + 1
    if VIDA_BOLA_INIMIGA > 0 then
        animacao_bola_inimiga = animacao_bola_inimiga + 1
    end
    
    -- Atualizar IA da esfera se estiver viva e na fase correta
    if (fase_atual_jogo == FASE_1 or fase_atual_jogo == FASE_4) and esfera_esta_viva() then
        atualizar_ia_esfera(tempo_atual, dt)
    end
    
    -- Atualizar IA dos quadrados se estiverem vivos e na fase correta
    if (fase_atual_jogo == FASE_2 or fase_atual_jogo == FASE_3) and quadrado_esta_vivo() then
        atualizar_ia_quadrados(tempo_atual, dt)
        remover_quadrados_mortos()
    end
    
    -- Atualizar IA do triângulo se estiver vivo e na fase correta
    if (fase_atual_jogo == FASE_2 or fase_atual_jogo == FASE_3) and triangulo_esta_vivo() then
        atualizar_ia_triangulo(tempo_atual, dt)
    end
end

-- FUNÇÕES DO LOVE2D

function love.load()
    love.window.setMode(JANELA_LARGURA, JANELA_ALTURA)
    love.window.setTitle("King in Orange")
    
    -- Configurar fontes padrão
    fonte_pausa = love.graphics.newFont(72)
    fonte_instrucoes = love.graphics.newFont(24)
    fonte_vida = love.graphics.newFont(48)
    
    -- Inicializa sistemas básicos
    criar_grid()
    inicializar_jogador()
    
    -- Inicializa todos os inimigos
    inicializar_esfera()
    inicializar_quadrados()
    inicializar_triangulo()
    
    inicializar_deck()
    
    -- Iniciar no menu principal
    estado_atual = MENU_PRINCIPAL
    opcao_selecionada = 1
    PARTIDA_INICIANDO = false
    INIMIGOS_APARECENDO = false
    
    -- Tocar música do menu
    tocar_musica(MUSICA_MENU)
    
    print("Menu principal carregado!")
    print("Use W/S ou Setas para navegar, ENTER para selecionar")
    print("Sistema de 4 fases ativado!")
    print("Módulos separados para cada inimigo!")
end

function love.update(dt)
    -- Verificar música baseada no estado atual
    tocar_musica_por_estado()
    
    if estado_atual == MENU_PRINCIPAL then
        atualizar_menu(dt)
        -- Atualizar scroll do menu
        MENU_SCROLL_Y = MENU_SCROLL_Y + MENU_SCROLL_VELOCIDADE * dt
        if MENU_SCROLL_Y > 100 then
            MENU_SCROLL_Y = MENU_SCROLL_Y - 100
        end
        return
    end
    
    -- Verificar se está em tela de fim
    if tela_fim_ativa then
        return
    end
    
    -- Atualizar tela de fase
    atualizar_tela_fase(dt)
    
    -- Se estiver mostrando tela de fase, não atualiza o jogo
    if MOSTRAR_TELA_FASE then
        return
    end
    
    local tempo_atual = love.timer.getTime() * 1000
    
    -- Efeitos de carta
    if carta_em_efeito then
        if atualizar_efeitos_carta then
            atualizar_efeitos_carta(dt)
        end
        return
    end
    
    -- Atualizar efeitos de ataque
    if atualizar_efeitos_ataque then
        atualizar_efeitos_ataque(dt)
    end
    
    -- Controle do início da partida
    if PARTIDA_INICIANDO then
        TEMPO_INICIO_PARTIDA = TEMPO_INICIO_PARTIDA + dt
        INIMIGOS_APARECENDO = true
        bloqueado_movimento = true
        bloqueado_ataque = true
        inimigos_bloqueados = true
        
        if TEMPO_INICIO_PARTIDA >= DURACAO_APARECIMENTO_INIMIGOS then
            PARTIDA_INICIANDO = false
            INIMIGOS_APARECENDO = false
            TEMPO_INICIO_PARTIDA = 0
            bloqueado_movimento = false
            bloqueado_ataque = false
            inimigos_bloqueados = false
            mudar_fase(FASE_PREPARACAO)
            print("Inimigos apareceram! Iniciando fase de preparação...")
        end
        return
    end
    
    -- Atualiza fases
    atualizar_fase(dt)
    
    if JOGO_PAUSADO or fase_atual == FASE_PREPARACAO or (MOSTRAR_PREPARADO and fase_atual == FASE_ACAO) then
        return
    end
    
    -- Atualiza cartas
    atualizar_cartas(dt)
    
    -- Controles do jogador
    if not bloqueado_movimento and VIDA_JOGADOR > 0 then
        atualizar_jogador(tempo_atual)
    end
    
    -- IA dos inimigos
    if not inimigos_bloqueados then
        atualizar_ia_inimigos(tempo_atual, dt)
    end
    
    -- Ataques
    if not JOGO_PAUSADO and fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        atualizar_todos_os_ataques(tempo_atual)
    end
    
    -- Projéteis
    atualizar_projeteis()
    
    -- Verifica se o jogador morreu
    if VIDA_JOGADOR <= 0 then
        mostrar_tela_derrota()
        return
    end
    
    -- Verifica se a fase foi concluída
    if fase_concluida() then
        if fase_atual_jogo < 4 then
            avancar_fase()
            mostrar_tela_fase()
            -- Resetar barra de customização para nova fase
            barra_customizacao = 0
        else
            -- Fase 4 concluída - VITÓRIA!
            print("Parabéns! Você completou todas as fases!")
            mostrar_tela_vitoria()
        end
    end
end

function love.draw()
    if estado_atual == MENU_PRINCIPAL then
        desenhar_menu_principal()
        return
    elseif estado_atual == MENU_INSTRUCOES then
        desenhar_instrucoes()
        return
    elseif estado_atual == MENU_CREDITOS then
        desenhar_creditos()
        return
    end
    
    -- Verificar se está mostrando tela de fim
    if tela_fim_ativa then
        if tela_fim_tipo == TELA_DERROTA then
            desenhar_tela_derrota()
        elseif tela_fim_tipo == TELA_VITORIA then
            desenhar_tela_vitoria()
        end
        return
    end
    
    -- Desenhar tela de fase se necessário
    if MOSTRAR_TELA_FASE then
        desenhar_tela_fase()
        return
    end
    
    -- Desenhar jogo normal
    desenhar_jogo_normal()
end

function love.keypressed(key)
    -- Verificar se está em tela de fim
    if tela_fim_ativa then
        if key == "z" or key == "x" or key == "return" or key == "kpenter" then
            -- Voltar para o menu principal
            tela_fim_ativa = false
            tela_fim_tipo = nil
            estado_atual = MENU_PRINCIPAL
            opcao_selecionada = 1
            -- Resetar o jogo para uma nova partida
            resetar_jogo_completo()
            print("Voltando ao menu principal...")
        end
        return
    end
    
    -- Processar input do menu primeiro
    if estado_atual == MENU_PRINCIPAL or estado_atual == MENU_INSTRUCOES or estado_atual == MENU_CREDITOS then
        processar_input_menu(key)
        return
    end
    
    -- Se estiver na tela de fase
    if MOSTRAR_TELA_FASE then
        if key == "z" then
            MOSTRAR_TELA_FASE = false
            -- Inicia o aparecimento dos inimigos
            PARTIDA_INICIANDO = true
            INIMIGOS_APARECENDO = true
        elseif key == "y" and fase_atual_jogo < 4 then
            -- Pular para próxima fase
            avancar_fase()
            resetar_variaveis_fase()
            -- Mostrar nova tela de fase
            mostrar_tela_fase()
        end
        return
    end
    
    -- Pular aparecimento dos inimigos
    if INIMIGOS_APARECENDO and key == "space" then
        PARTIDA_INICIANDO = false
        INIMIGOS_APARECENDO = false
        TEMPO_INICIO_PARTIDA = 0
        bloqueado_movimento = false
        bloqueado_ataque = false
        inimigos_bloqueados = false
        mudar_fase(FASE_PREPARACAO)
        return
    end
    
    -- Pular "Preparado?"
    if MOSTRAR_PREPARADO then
        if key ~= "escape" then
            MOSTRAR_PREPARADO = false
            tempo_preparado = 0
            return
        end
    end
    
    -- Resto dos controles
    if key == "escape" then
        if fase_atual == FASE_PREPARACAO then
            mudar_fase(FASE_ACAO)
        else
            JOGO_PAUSADO = not JOGO_PAUSADO
        end
    elseif key == "z" then
        tecla_z_pressionada = true
        if fase_atual == FASE_PREPARACAO then
            if tipo_selecao == "mao" then
                if carta_selecionada >= 1 and carta_selecionada <= #mao_atual then
                    selecionar_carta(carta_selecionada)
                    if #mao_atual > 0 then
                        carta_selecionada = math.min(carta_selecionada, #mao_atual)
                    elseif #cartas_selecionadas > 0 then
                        tipo_selecao = "selecionadas"
                        carta_selecionada = 1
                    end
                end
            end
        end
    elseif key == "x" and fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        usar_proxima_carta()
    elseif key == "c" and fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        if barra_customizacao >= MAX_BARRA_CUSTOMIZACAO then
            mudar_fase(FASE_PREPARACAO)
        else
            print("Barra de customização ainda não está cheia!")
        end
    elseif key == "r" then
        resetar_jogo_completo()
    elseif key == "m" then
        estado_atual = MENU_PRINCIPAL
        opcao_selecionada = 1
        print("Voltando ao menu principal...")
    elseif fase_atual == FASE_PREPARACAO then
        if key == "a" or key == "left" then
            mover_selecao_horizontal("esquerda")
        elseif key == "d" or key == "right" then
            mover_selecao_horizontal("direita")
        elseif key == "x" then
            if #cartas_selecionadas > 0 then
                local ultima_carta = #cartas_selecionadas
                remover_carta_selecionada(ultima_carta)
                if #cartas_selecionadas > 0 then
                    carta_selecionada = math.min(carta_selecionada, #cartas_selecionadas)
                elseif #mao_atual > 0 then
                    tipo_selecao = "mao"
                    carta_selecionada = 1
                end
            end
        elseif key == "c" then
            mudar_fase(FASE_ACAO)
        elseif key == "space" then
            resetar_cartas()
        end
    end
end

function love.keyreleased(key)
    if key == "z" then
        tecla_z_pressionada = false
    end
end

function love.mousepressed(x, y, button)
    local mouse_x_viewport = x - OFFSET_X_VIEWPORT
    local mouse_y_viewport = y - OFFSET_Y_VIEWPORT
    
    if button == 1 then
        if fase_atual == FASE_PREPARACAO then
            verificar_clique_preparacao(x, y)
        elseif fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
            if mouse_x_viewport >= 0 and mouse_x_viewport <= JOGO_LARGURA and
               mouse_y_viewport >= 0 and mouse_y_viewport <= JOGO_ALTURA then
                mouse_pressionado = true
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        mouse_pressionado = false
    end
end