-- main.lua (atualizado para incluir bola inimiga)
require "modules.config"
require "modules.grid"
require "modules.player"
require "modules.enemies"
require "modules.projectiles"
require "modules.attacks"
require "modules.ui"
require "modules.game_state"
require "modules.cards"
require "modules.phases"

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

-- Função para atualizar todos os ataques
function atualizar_todos_os_ataques(tempo_atual)
    -- Sistema antigo (compatibilidade)
    atualizar_ataques(tempo_atual)
end

-- Função para resetar o jogo completamente
function resetar_jogo_completo()
    VIDA_JOGADOR = vida_maxima_jogador
    VIDA_TRIANGULO = 500
    VIDA_QUADRADO = 500
    VIDA_BOLA_INIMIGA = 600  --Resetar vida da bola inimiga
    
    pos_bola = {1, 1}
    pos_triangulo = {1, 4}
    pos_quadrado = {2, 5}
    pos_bola_inimiga = {3, 6}  --Resetar posição da bola inimiga
    
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
    
    -- Limpar armadilha da carta 8
    armadilha_carta_8 = nil
    
    -- INICIALIZAR cartas_nao_selecionadas vazia
    cartas_nao_selecionadas = {}
    
    -- Resetar mão atual
    mao_atual = {}
    
    inicializar_deck()
    resetar_efeitos_ataque()
    resetar_variaveis_cartas()
    
    -- Iniciar aparecimento dos inimigos
    PARTIDA_INICIANDO = true
    TEMPO_INICIO_PARTIDA = 0
    INIMIGOS_APARECENDO = true
    
    -- NÃO chamar mudar_fase aqui - a fase será definida após aparecimento
    MOSTRAR_PREPARADO = false
    tempo_preparado = 0
    barra_customizacao = 0
    
    print("Nova partida iniciada! Inimigos aparecendo...")
    print("Deck recriado do zero com todas as cartas.")
end

-- Função para desenhar efeito de aparecimento dos inimigos (atualizada)
function desenhar_aparecimento_inimigos()
    if INIMIGOS_APARECENDO then
        -- Fundo preto semi-transparente
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
        
        -- Efeito visual dos inimigos aparecendo
        local progresso = TEMPO_INICIO_PARTIDA / DURACAO_APARECIMENTO_INIMIGOS
        
        -- Triângulo aparecendo
        if pos_triangulo[1] > 0 then
            local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
            local tamanho_atual = tamanho_triangulo * progresso
            
            -- Efeito de pulso
            local pulso = 1 + math.sin(love.timer.getTime() * 10) * 0.2
            
            love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], progresso)
            love.graphics.polygon("fill",
                celula_triangulo.centro_x, celula_triangulo.centro_y - tamanho_atual * pulso,
                celula_triangulo.centro_x + tamanho_atual * pulso, celula_triangulo.centro_y + tamanho_atual * pulso/2,
                celula_triangulo.centro_x - tamanho_atual * pulso, celula_triangulo.centro_y + tamanho_atual * pulso/2
            )
        end
        
        -- Quadrado aparecendo
        if pos_quadrado[1] > 0 then
            local celula_quadrado = GRID_CELULAS[pos_quadrado[1]][pos_quadrado[2]]
            local tamanho_atual = tamanho_quadrado * progresso
            
            -- Efeito de pulso
            local pulso = 1 + math.sin(love.timer.getTime() * 8 + 1) * 0.2
            
            love.graphics.setColor(AMARELO[1], AMARELO[2], AMARELO[3], progresso)
            love.graphics.rectangle("fill",
                celula_quadrado.centro_x - tamanho_atual * pulso/2,
                celula_quadrado.centro_y - tamanho_atual * pulso/2,
                tamanho_atual * pulso,
                tamanho_atual * pulso
            )
        end
        
        --Bola inimiga aparecendo
        if pos_bola_inimiga[1] > 0 then
            local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
            local tamanho_atual = tamanho_bola_inimiga * progresso
            
            -- Efeito de pulso
            local pulso = 1 + math.sin(love.timer.getTime() * 6 + 2) * 0.2
            
            love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], progresso)
            love.graphics.circle("fill",
                celula_bola_inimiga.centro_x,
                celula_bola_inimiga.centro_y,
                tamanho_atual * pulso
            )
        end
        
        -- Texto central (opcional, se quiser algo sutil)
        if progresso > 0.5 then
            local fonte_temp = fonte_instrucoes or love.graphics.newFont(20)
            love.graphics.setFont(fonte_temp)
            love.graphics.setColor(1, 1, 1, (progresso - 0.5) * 2)
            local texto = "Prepare-se..."
            love.graphics.print(texto, 
                JANELA_LARGURA/2 - fonte_temp:getWidth(texto)/2,
                JANELA_ALTURA/2 - 100)
        end
    end
end

-- Funções do Love2D
function love.load()
    -- Configurar janela maior
    love.window.setMode(JANELA_LARGURA, JANELA_ALTURA)
    love.window.setTitle("King in Orange")
    
    -- Inicializa sistemas
    criar_grid()
    inicializar_jogador()
    inicializar_inimigos()
    inicializar_deck()
    
    -- Iniciar com inimigos aparecendo
    PARTIDA_INICIANDO = true
    TEMPO_INICIO_PARTIDA = 0
    INIMIGOS_APARECENDO = true
    
    print("Jogo carregado com sucesso!")
    print("Novo inimigo: Bola Laranja adicionada!")
    print("Janela: " .. JANELA_LARGURA .. "x" .. JANELA_ALTURA)
    print("Viewport: " .. JOGO_LARGURA .. "x" .. JOGO_ALTURA)
    print("Controles: WASD/Setas para mover, Z/Mouse para atirar, X para usar carta, ESC para pausar")
    print("C para entrar na fase de preparação (quando a barra estiver cheia)")
    print("R para resetar o jogo")
end

function love.update(dt)
    local tempo_atual = love.timer.getTime() * 1000
    
    -- Atualizar efeitos de ataque
    if atualizar_efeitos_ataque then
        atualizar_efeitos_ataque(dt)
    end
    
    -- Controle do início da partida
    if PARTIDA_INICIANDO then
        TEMPO_INICIO_PARTIDA = TEMPO_INICIO_PARTIDA + dt
        INIMIGOS_APARECENDO = true
        
        -- Bloqueia todas as ações durante o aparecimento dos inimigos
        bloqueado_movimento = true
        bloqueado_ataque = true
        inimigos_bloqueados = true
        
        if TEMPO_INICIO_PARTIDA >= DURACAO_APARECIMENTO_INIMIGOS then
            -- Fim do aparecimento dos inimigos
            PARTIDA_INICIANDO = false
            INIMIGOS_APARECENDO = false
            TEMPO_INICIO_PARTIDA = 0
            
            -- Libera jogador, mas mantém inimigos bloqueados
            bloqueado_movimento = false
            bloqueado_ataque = false
            inimigos_bloqueados = false
            
            -- Vai direto para fase de preparação
            mudar_fase(FASE_PREPARACAO)
            print("Inimigos apareceram! Iniciando fase de preparação...")
        end
        
        -- Não atualiza nada mais durante o aparecimento
        return
    end
    
    -- Atualiza fases
    atualizar_fase(dt)
    
    -- Atualiza animações
    animacao_bola = animacao_bola + 1
    animacao_triangulo = animacao_triangulo + 1
    animacao_quadrado = animacao_quadrado + 1
    
    --Atualizar animação da bola inimiga
    if VIDA_BOLA_INIMIGA > 0 then
        animacao_bola_inimiga = animacao_bola_inimiga + 1
    end
    
    if JOGO_PAUSADO or fase_atual == FASE_PREPARACAO or (MOSTRAR_PREPARADO and fase_atual == FASE_ACAO) then
        return
    end
    
    -- Atualiza cartas
    atualizar_cartas(dt)
    
    -- Controles do jogador (se não bloqueado)
    if not bloqueado_movimento and VIDA_JOGADOR > 0 then
        atualizar_jogador(tempo_atual)
    end
    
    -- IA dos inimigos (removida - inimigos não se movem)
    if not inimigos_bloqueados then
        atualizar_ia_inimigos(tempo_atual)
    end
    
    -- Ataques
    if not JOGO_PAUSADO and fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        atualizar_todos_os_ataques(tempo_atual)
    end
    
    -- Projéteis
    atualizar_projeteis()
    
    -- Remove inimigos se HP chegou a zero
    remover_inimigo_se_morto()
    
    -- Verifica se o jogo acabou
    if VIDA_JOGADOR <= 0 then
        mudar_fase(FASE_FIM)
        print("Game Over!")
    elseif VIDA_TRIANGULO <= 0 and VIDA_QUADRADO <= 0 and VIDA_BOLA_INIMIGA <= 0 then
        print("Vitória! Todos os inimigos derrotados!")
    end
end

function love.draw()
    -- Desenhar aparecimento dos inimigos se estiver ocorrendo
    if INIMIGOS_APARECENDO then
        desenhar_aparecimento_inimigos()
        return  -- Não desenha mais nada durante o aparecimento
    end
    
    -- Limpar tela com preto
    love.graphics.setColor(PRETO)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- Desenhar retângulo de cartas à direita do viewport
    desenhar_retangulo_cartas()
    
    -- Configurar viewport (área onde o jogo será desenhado)
    love.graphics.setScissor(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT, JOGO_LARGURA, JOGO_ALTURA)
    love.graphics.translate(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT)
    
    -- Fundo com linhas brancas (efeito abstracto)
    desenhar_fundo_abstracto()
    
    -- Grid e elementos do jogo
    desenhar_grid()
    aplicar_efeito_transparencia()
    
    -- Desenhar ataques do triângulo (do módulo attacks)
    if desenhar_ataque_triangulo then
        desenhar_ataque_triangulo()
    end
    
    -- Desenhar efeitos de ataque dos inimigos
    if desenhar_efeitos_ataque then
        desenhar_efeitos_ataque()
    end
    
    -- Desenha armadilha da carta 8 (se existir)
    if desenhar_armadilha_carta_8 then
        desenhar_armadilha_carta_8()
    end
    
    -- Desenha projéteis
    desenhar_projeteis()
    
    -- Desenha personagens (inclui a nova bola inimiga)
    if desenhar_personagens_completos then
        desenhar_personagens_completos()
    else
        desenhar_personagens()
    end
    
    -- Desenha UI (dentro da viewport)
    desenhar_ui()
    
    -- Barra de customização (apenas fase de ação e não durante "Preparado?")
    if fase_atual == FASE_ACAO and not MOSTRAR_PREPARADO then
        desenhar_barra_customizacao()
    end
    
    -- Remover transformação para desenhar fora da viewport
    love.graphics.origin()
    love.graphics.setScissor()
    
    -- Desenhar elementos que devem aparecer em tela cheia
    if fase_atual == FASE_PREPARACAO then
        desenhar_fase_preparacao()
    end
    
    if MOSTRAR_PREPARADO and fase_atual == FASE_ACAO then
        desenhar_preparado()
    end
    
    if desenhar_efeitos_carta_9 then
        love.graphics.setScissor(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT, JOGO_LARGURA, JOGO_ALTURA)
        love.graphics.translate(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT)
        desenhar_efeitos_carta_9()
        love.graphics.origin()
        love.graphics.setScissor()
    end
    
    if JOGO_PAUSADO then
        desenhar_botao_pause()
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
        
        -- Desenhar cartas selecionadas na ordem (de cima para baixo)
        local tamanho_carta = 50
        local espacamento = 15
        local x_cartas = RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - tamanho_carta)/2
        local y_inicio = RETANGULO_CARTAS_Y + 50
        local max_cartas_visiveis = math.floor((RETANGULO_CARTAS_ALTURA - 120) / (tamanho_carta + espacamento))
        
        if #cartas_selecionadas > 0 then
            -- Desenha as cartas selecionadas
            for i = 1, math.min(#cartas_selecionadas, max_cartas_visiveis) do
                local carta = cartas_selecionadas[i]
                local y = y_inicio + (i-1) * (tamanho_carta + espacamento)
                
                -- Cor da carta baseada no tipo
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
                
                -- Fundo da carta
                love.graphics.setColor(cor_fundo[1], cor_fundo[2], cor_fundo[3], cor_fundo[4] or 1)
                love.graphics.rectangle("fill", x_cartas, y, tamanho_carta, tamanho_carta, 5)
                
                -- Borda
                love.graphics.setColor(cor_borda[1], cor_borda[2], cor_borda[3], cor_borda[4] or 1)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", x_cartas, y, tamanho_carta, tamanho_carta, 5)
                
                -- Símbolo da carta
                local fonte_carta = fonte_instrucoes or love.graphics.newFont(20)
                love.graphics.setFont(fonte_carta)
                
                love.graphics.setColor(PRETO)
                local largura_texto = fonte_carta:getWidth(carta.id)
                local altura_texto = fonte_carta:getHeight()
                love.graphics.print(carta.id, 
                    x_cartas + (tamanho_carta - largura_texto)/2, 
                    y + (tamanho_carta - altura_texto)/2)
                
                -- Indicador de "próxima carta" (primeira da fila)
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
            
            -- Contador de cartas selecionadas
            local y_contador = y_inicio + math.min(#cartas_selecionadas, max_cartas_visiveis) * (tamanho_carta + espacamento) + 10
            love.graphics.setColor(BRANCO)
            local texto_contador = "Selecionadas: " .. #cartas_selecionadas
            love.graphics.print(texto_contador, 
                RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - fonte_inst:getWidth(texto_contador))/2,
                y_contador)
        else
            -- Mensagem quando não há cartas selecionadas
            love.graphics.setColor(BRANCO)
            local mensagem_vazio = "Nenhuma\ncarta\nselecionada"
            love.graphics.printf(mensagem_vazio,
                RETANGULO_CARTAS_X + 10,
                RETANGULO_CARTAS_Y + RETANGULO_CARTAS_ALTURA/2 - 30,
                RETANGULO_CARTAS_LARGURA - 20,
                "center")
        end
        
        -- QUADRADO FINAL: CARTAS RESTANTES NO BARALHO
        local tamanho_quadrado = 60
        local x_quadrado = RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - tamanho_quadrado)/2
        local y_quadrado = RETANGULO_CARTAS_Y + RETANGULO_CARTAS_ALTURA - tamanho_quadrado - 20
        
        -- Fundo do quadrado
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.3)
        love.graphics.rectangle("fill", x_quadrado, y_quadrado, tamanho_quadrado, tamanho_quadrado, 8)
        
        -- Borda
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x_quadrado, y_quadrado, tamanho_quadrado, tamanho_quadrado, 8)
        
        -- Texto "DECK"
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 1)
        local fonte_deck = fonte_instrucoes or love.graphics.newFont(14)
        love.graphics.setFont(fonte_deck)
        local texto_deck = "DECK"
        local largura_texto_deck = fonte_deck:getWidth(texto_deck)
        love.graphics.print(texto_deck, 
            x_quadrado + (tamanho_quadrado - largura_texto_deck)/2, 
            y_quadrado + 8)
        
        -- Número de cartas no baralho
        local total_cartas = #deck_atual + #mao_atual + #cartas_selecionadas + #cartas_usadas
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
        
        -- Texto "restantes"
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
        
        -- Título
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 1)
        local titulo = "INFORMAÇÕES"
        local largura_titulo = fonte_inst:getWidth(titulo)
        love.graphics.print(titulo, 
            RETANGULO_CARTAS_X + (RETANGULO_CARTAS_LARGURA - largura_titulo)/2, 
            RETANGULO_CARTAS_Y + 15)
        
        -- Estatísticas do deck
        love.graphics.setColor(BRANCO)
        local y_info = RETANGULO_CARTAS_Y + 50
        local espacamento_info = 25
        
        local infos = {
            "Costo atual:",
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

function love.keypressed(key)
    -- Pular aparecimento dos inimigos
    if INIMIGOS_APARECENDO and key == "space" then
        PARTIDA_INICIANDO = false
        INIMIGOS_APARECENDO = false
        TEMPO_INICIO_PARTIDA = 0
        bloqueado_movimento = false
        bloqueado_ataque = false
        inimigos_bloqueados = false
        mudar_fase(FASE_PREPARACAO)
        print("Aparecimento dos inimigos pulado. Iniciando fase de preparação...")
        return
    end
    
    -- Primeiro verifica se está mostrando "Preparado?" para pular
    if MOSTRAR_PREPARADO then
        if key ~= "escape" then
            MOSTRAR_PREPARADO = false
            tempo_preparado = 0
            return
        end
    end
    
    if key == "escape" then
        if fase_atual == FASE_PREPARACAO then
            mudar_fase(FASE_ACAO)
        else
            JOGO_PAUSADO = not JOGO_PAUSADO
        end
    elseif key == "z" then
        tecla_z_pressionada = true
        
        -- Adicionar funcionalidade Z na fase de preparação
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
    elseif key == "c" and fase_atual == FASE_ACAO and not MOSTRAR_PREPARado then
        if barra_customizacao >= MAX_BARRA_CUSTOMIZACAO then
            mudar_fase(FASE_PREPARACAO)
        else
            print("Barra de customização ainda não está cheia!")
        end
    elseif key == "r" then
        resetar_jogo_completo()
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