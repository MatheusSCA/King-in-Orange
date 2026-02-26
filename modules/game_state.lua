-- modules/game_state.lua
-- Gerenciamento de estados do jogo e fases

FASE_ACAO = "acao"
FASE_PREPARACAO = "preparacao"
FASE_PAUSADA = "pausada"
FASE_INICIO = "inicio"
FASE_FIM = "fim"

fase_atual = FASE_ACAO
tempo_fase_preparacao = 0
MAX_TEMPO_PREPARACAO = 15  -- segundos para carregar barra

barra_customizacao = 0
MAX_BARRA_CUSTOMIZACAO = 100

tempo_preparado = 0
MOSTRAR_PREPARADO = false
DURACAO_PREPARADO = 1.0  -- 1 segundo

function mudar_fase(nova_fase)
    fase_anterior = fase_atual
    fase_atual = nova_fase
    
    print("Mudando de fase: " .. fase_anterior .. " -> " .. nova_fase)
    
    if nova_fase == FASE_PREPARACAO then
        tempo_fase_preparacao = 0
        barra_customizacao = 0
        
        -- Chama a função do módulo cards para preparar a mão com 6 cartas do deck
        if entrar_fase_preparacao then
            entrar_fase_preparacao()
        else
            print("ERRO: função entrar_fase_preparacao não encontrada!")
        end
        
    elseif nova_fase == FASE_ACAO then
        if fase_anterior == FASE_PREPARACAO then
            -- Ao voltar da fase de preparação, mostra "Preparado?"
            MOSTRAR_PREPARADO = true
            tempo_preparado = 0
            
            -- Chama a função do módulo cards para salvar cartas não selecionadas
            if sair_fase_preparacao then
                sair_fase_preparacao()
            else
                print("ERRO: função sair_fase_preparacao não encontrada!")
            end
            
            -- Se estiver na fase 4, escolher novos ataques para a esfera
            if fase_atual_jogo == FASE_4 and escolher_ataques_para_fase4 then
                escolher_ataques_para_fase4()
            end
        end
    end
end

function atualizar_fase(dt)
    if fase_atual == FASE_ACAO and not JOGO_PAUSADO then
        -- Atualiza mensagem "Preparado?" (bloqueia ações enquanto mostra)
        if MOSTRAR_PREPARADO then
            tempo_preparado = tempo_preparado + dt
            if tempo_preparado >= DURACAO_PREPARADO then
                MOSTRAR_PREPARADO = false
            end
            return  -- Não atualiza barra nem ações enquanto mostra "Preparado?"
        end
        
        -- Atualiza barra de customização MAS NÃO MUDA AUTOMATICAMENTE DE FASE
        if barra_customizacao < MAX_BARRA_CUSTOMIZACAO then
            barra_customizacao = barra_customizacao + (MAX_BARRA_CUSTOMIZACAO / MAX_TEMPO_PREPARACAO) * dt
            -- REMOVIDO: mudança automática de fase quando a barra enche
            -- Apenas limita no máximo
            if barra_customizacao > MAX_BARRA_CUSTOMIZACAO then
                barra_customizacao = MAX_BARRA_CUSTOMIZACAO
            end
        end
    elseif fase_atual == FASE_PREPARACAO then
        tempo_fase_preparacao = tempo_fase_preparacao + dt
    end
end

function desenhar_barra_customizacao()
    -- Só desenha a barra se não estiver mostrando "Preparado?"
    if MOSTRAR_PREPARADO then return end
    
    local largura_barra = 300
    local altura_barra = 20
    local x = LARGURA/2 - largura_barra/2
    local y = 40  -- Aumentado de 20 para 40 (abaixo dos controles)
    
    -- Fundo da barra
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, largura_barra, altura_barra, 5)
    
    -- Barra preenchida
    local percentual = barra_customizacao / MAX_BARRA_CUSTOMIZACAO
    local largura_preenchida = largura_barra * percentual
    
    -- Muda a cor quando estiver cheia
    if barra_customizacao >= MAX_BARRA_CUSTOMIZACAO then
        love.graphics.setColor(VERDE)  -- Verde quando cheia
    else
        love.graphics.setColor(ROXO_CLARO)
    end
    love.graphics.rectangle("fill", x, y, largura_preenchida, altura_barra, 5)
    
    -- Borda
    love.graphics.setColor(BRANCO)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, largura_barra, altura_barra, 5)
    
    -- Texto
    local texto = "BARRA DE CUSTOMIZAÇÃO"
    local fonte_temp = fonte_instrucoes or love.graphics.newFont(16)
    love.graphics.setFont(fonte_temp)
    love.graphics.setColor(BRANCO)
    love.graphics.print(texto, x + largura_barra/2 - fonte_temp:getWidth(texto)/2, y - 25)
    
    -- Instrução quando cheia
    if barra_customizacao >= MAX_BARRA_CUSTOMIZACAO then
        local instrucao = "Pressione C para entrar na fase de preparação"
        love.graphics.setColor(VERDE)
        love.graphics.print(instrucao, x + largura_barra/2 - fonte_temp:getWidth(instrucao)/2, y + altura_barra + 10)
    end
end

function desenhar_preparado()
    if MOSTRAR_PREPARADO then
        -- Fundo preto semi-transparente que cobre toda a tela
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
        
        -- Quadrado central para o texto
        local largura_quadrado = 400
        local altura_quadrado = 150
        local x_quad = JANELA_LARGURA/2 - largura_quadrado/2
        local y_quad = JANELA_ALTURA/2 - altura_quadrado/2
        
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", x_quad, y_quad, largura_quadrado, altura_quadrado, 15)
        
        -- Borda do quadrado
        love.graphics.setColor(ROXO_CLARO)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x_quad, y_quad, largura_quadrado, altura_quadrado, 15)
        
        -- Texto "PREPARADO?" grande
        local texto = "PREPARADO?"
        local fonte_temp = fonte_pausa or love.graphics.newFont(64)
        love.graphics.setFont(fonte_temp)
        love.graphics.setColor(ROXO_CLARO)
        
        -- Sombra do texto
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.print(texto, 
            x_quad + largura_quadrado/2 - fonte_temp:getWidth(texto)/2 + 3,
            y_quad + altura_quadrado/2 - fonte_temp:getHeight()/2 + 3)
        
        -- Texto principal
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(texto, 
            x_quad + largura_quadrado/2 - fonte_temp:getWidth(texto)/2,
            y_quad + altura_quadrado/2 - fonte_temp:getHeight()/2)
        
        -- Texto secundário (instrução)
        local texto_sec = "Aperte qualquer tecla para continuar..."
        local fonte_sec = fonte_instrucoes or love.graphics.newFont(20)
        love.graphics.setFont(fonte_sec)
        love.graphics.setColor(1, 1, 1, 0.7)
        
        -- Efeito de piscar
        local piscar = math.sin(love.timer.getTime() * 5) > 0
        if piscar then
            love.graphics.print(texto_sec, 
                x_quad + largura_quadrado/2 - fonte_sec:getWidth(texto_sec)/2,
                y_quad + altura_quadrado/2 + 60)
        end
    end
end

-- Função para pular a mensagem "Preparado?" se o jogador aperte qualquer tecla
function pular_preparado()
    if MOSTRAR_PREPARADO then
        MOSTRAR_PREPARADO = false
        tempo_preparado = 0
        return true
    end
    return false
end

function resetar_efeitos_ataque()
    ataque_triangulo_efeito = nil
    tempo_ataque_triangulo_efeito = 0
    ataque_triangulo = nil
    triangulo_atacando = false
    coluna_transparente = nil
    tempo_coluna_transparente = 0
end

function resetar_variaveis_cartas()
    -- Reseta variáveis relacionadas a cartas usadas
    if ultima_carta_usada then
        ultima_carta_usada = nil
        tempo_mostrar_carta = 0
    end
    
    -- Reseta cores das cartas selecionadas
    if cartas_selecionadas then
        for _, carta in ipairs(cartas_selecionadas) do
            carta.cor_usada = false
            carta.tempo_usada = nil
        end
    end
end

-- Função para verificar se pode entrar na fase de preparação
function pode_entrar_preparacao()
    return barra_customizacao >= MAX_BARRA_CUSTOMIZACAO
end