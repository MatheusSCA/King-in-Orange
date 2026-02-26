-- modules/enemies_triangulo.lua
-- Módulo específico para o inimigo triângulo com novo comportamento

-- Estados do triângulo
TRIANGULO_ESTADO_PERSEGUINDO = "perseguindo"
TRIANGULO_ESTADO_PREPARANDO_COLUNA = "preparando_coluna"
TRIANGULO_ESTADO_COLUNA_ATIVA = "coluna_ativa"
TRIANGULO_ESTADO_PERSEGUINDO_LINHA = "perseguindo_linha"
TRIANGULO_ESTADO_PARADO_PREPARANDO = "parado_preparando"
TRIANGULO_ESTADO_LANCANDO_PROJETIL = "lancando_projetil"
TRIANGULO_ESTADO_RECUO = "recuo"

-- Variáveis do triângulo (usando as variáveis globais existentes)
-- VIDA_TRIANGULO já existe globalmente com valor 500
-- pos_triangulo já existe globalmente
-- tamanho_triangulo já existe globalmente
-- animacao_triangulo já existe globalmente

-- Variáveis de estado (novas)
triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO
triangulo_tempo_estado = 0
triangulo_ultimo_movimento = 0

-- Variáveis para colunas 1 e 3 (MODIFICADO)
coluna_1_ativa = false
coluna_3_ativa = false
coluna_1_tempo_restante = 0
coluna_3_tempo_restante = 0
coluna_1_dano_aplicado = false  
coluna_3_dano_aplicado = false  

-- Variáveis para perseguição de linha
linha_perseguida = 1
direcao_perseguida = 0  -- 1 = baixo, -1 = cima
modo_perseguicao_linha = false  -- Flag para indicar que está no modo de perseguição de linha
coluna_alvo_perseguida = 2  -- Coluna que está sendo perseguida (pode mudar)

-- Projéteis do triângulo
projeteis_triangulo = {}

function inicializar_triangulo()
    -- Usar as variáveis globais existentes
    VIDA_TRIANGULO = TRIANGULO_VIDA_MAXIMA
    pos_triangulo = {1, 5}
    resetar_estado_triangulo()
end

function resetar_triangulo_para_fase()
    inicializar_triangulo()
end

function desativar_triangulo()
    VIDA_TRIANGULO = 0
    pos_triangulo = {-1, -1}
    resetar_estado_triangulo()
end

function triangulo_esta_vivo()
    return VIDA_TRIANGULO > 0 and pos_triangulo[1] > 0
end

function resetar_estado_triangulo()
    triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO
    triangulo_tempo_estado = 0
    triangulo_ultimo_movimento = 0
    
    coluna_1_ativa = false
    coluna_3_ativa = false
    coluna_1_tempo_restante = 0
    coluna_3_tempo_restante = 0
    coluna_1_dano_aplicado = false  
    coluna_3_dano_aplicado = false  
    
    linha_perseguida = 1
    direcao_perseguida = 0
    modo_perseguicao_linha = false
    coluna_alvo_perseguida = 2
    projeteis_triangulo = {}
end

-- Função para mover o triângulo em pulinhos (sempre na coluna 5)
function mover_triangulo_em_pulinho(tempo_atual)
    -- Só move se estiver em estado que permite movimento
    if triangulo_estado == TRIANGULO_ESTADO_PERSEGUINDO or 
       triangulo_estado == TRIANGULO_ESTADO_PREPARANDO_COLUNA or
       triangulo_estado == TRIANGULO_ESTADO_COLUNA_ATIVA or
       triangulo_estado == TRIANGULO_ESTADO_PERSEGUINDO_LINHA then
        
        -- Verificar se já passou o intervalo de movimento
        if tempo_atual - triangulo_ultimo_movimento >= TRIANGULO_INTERVALO_MOVIMENTO then
            local linha_alvo = pos_bola[1]
            local moveu = false
            
            if pos_triangulo[1] < linha_alvo then
                pos_triangulo[1] = pos_triangulo[1] + 1
                moveu = true
            elseif pos_triangulo[1] > linha_alvo then
                pos_triangulo[1] = pos_triangulo[1] - 1
                moveu = true
            end
            
            if moveu then
                triangulo_ultimo_movimento = tempo_atual
                return true
            end
        end
    end
    return false
end

-- Função para verificar se o jogador está em uma coluna de ataque
function jogador_em_coluna_ataque()
    return pos_bola[2] == 1 or pos_bola[2] == 3
end

-- Função principal de atualização da IA do triângulo
function atualizar_ia_triangulo(tempo_atual, dt)
    if not triangulo_esta_vivo() then return end
    
    -- Atualizar projéteis (passar dt)
    if dt then
        atualizar_projeteis_triangulo(dt)
    end
    
    -- Atualizar tempo das colunas ativas (MODIFICADO)
    if coluna_1_ativa and dt then
        coluna_1_tempo_restante = coluna_1_tempo_restante - dt
        
        -- Aplicar dano APENAS UMA VEZ se o jogador estiver na coluna e o dano ainda não foi aplicado
        if pos_bola[2] == 1 and not imune_dano and not carta2_ativa and not coluna_1_dano_aplicado then
            VIDA_JOGADOR = VIDA_JOGADOR - TRIANGULO_DANO_COLUNA
            if VIDA_JOGADOR < 0 then
                VIDA_JOGADOR = 0
            end
            coluna_1_dano_aplicado = true  -- Marca que o dano já foi aplicado
            print("Jogador atingido pela área laranja da coluna 1! Dano: " .. TRIANGULO_DANO_COLUNA)
        end
        
        -- Quando o tempo acabar, desativa a coluna
        if coluna_1_tempo_restante <= 0 then
            coluna_1_ativa = false
            coluna_1_dano_aplicado = false  -- Reset para a próxima vez
        end
    end
    
    if coluna_3_ativa and dt then
        coluna_3_tempo_restante = coluna_3_tempo_restante - dt
        
        -- Aplicar dano APENAS UMA VEZ se o jogador estiver na coluna e o dano ainda não foi aplicado
        if pos_bola[2] == 3 and not imune_dano and not carta2_ativa and not coluna_3_dano_aplicado then
            VIDA_JOGADOR = VIDA_JOGADOR - TRIANGULO_DANO_COLUNA
            if VIDA_JOGADOR < 0 then
                VIDA_JOGADOR = 0
            end
            coluna_3_dano_aplicado = true  -- Marca que o dano já foi aplicado
            print("Jogador atingido pela área laranja da coluna 3! Dano: " .. TRIANGULO_DANO_COLUNA)
        end
        
        -- Quando o tempo acabar, desativa a coluna
        if coluna_3_tempo_restante <= 0 then
            coluna_3_ativa = false
            coluna_3_dano_aplicado = false  -- Reset para a próxima vez
        end
    end
    
    -- Máquina de estados
    if triangulo_estado == TRIANGULO_ESTADO_PERSEGUINDO then
        -- Estado padrão: persegue o jogador na coluna 5
        
        -- Movimento em pulinhos
        mover_triangulo_em_pulinho(tempo_atual)
        
        -- Verificar posição do jogador para decidir ação
        if jogador_em_coluna_ataque() then
            -- Jogador nas colunas 1 ou 3: iniciar preparação
            triangulo_estado = TRIANGULO_ESTADO_PREPARANDO_COLUNA
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = false
            
        elseif pos_bola[2] == 2 and not modo_perseguicao_linha then
            -- Jogador na coluna 2 e não está em modo de perseguição: iniciar perseguição de linha
            triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO_LINHA
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = true
            linha_perseguida = pos_bola[1]
            coluna_alvo_perseguida = 2
            -- Determinar direção da linha perseguida
            if linha_perseguida < pos_triangulo[1] then
                direcao_perseguida = -1  -- Para cima
            elseif linha_perseguida > pos_triangulo[1] then
                direcao_perseguida = 1   -- Para baixo
            else
                direcao_perseguida = 0
            end
        end
        
    elseif triangulo_estado == TRIANGULO_ESTADO_PREPARANDO_COLUNA then
        -- Preparando ataque nas colunas 1 e 3
        if dt then
            triangulo_tempo_estado = triangulo_tempo_estado + dt
        end
        
        -- Continua se movendo em pulinhos durante preparação
        mover_triangulo_em_pulinho(tempo_atual)
        
        if triangulo_tempo_estado >= TRIANGULO_TEMPO_PREPARACAO then
            -- Ativar colunas 1 e 3
            coluna_1_ativa = true
            coluna_3_ativa = true
            coluna_1_tempo_restante = TRIANGULO_TEMPO_ATIVO
            coluna_3_tempo_restante = TRIANGULO_TEMPO_ATIVO
            coluna_1_dano_aplicado = false  
            coluna_3_dano_aplicado = false  
            
            triangulo_estado = TRIANGULO_ESTADO_COLUNA_ATIVA
            triangulo_tempo_estado = 0
        end
        
    elseif triangulo_estado == TRIANGULO_ESTADO_COLUNA_ATIVA then
        -- Colunas ativas causando dano (apenas uma vez)
        if dt then
            triangulo_tempo_estado = triangulo_tempo_estado + dt
        end
        
        -- Movimento em pulinhos durante colunas ativas
        mover_triangulo_em_pulinho(tempo_atual)
        
        -- Quando o tempo acabar, voltar ao estado normal
        if not coluna_1_ativa and not coluna_3_ativa then
            triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = false
        end
        
        -- Se o jogador entrar na coluna 2 durante colunas ativas, iniciar perseguição
        if pos_bola[2] == 2 and not modo_perseguicao_linha then
            triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO_LINHA
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = true
            linha_perseguida = pos_bola[1]
            coluna_alvo_perseguida = 2
            if linha_perseguida < pos_triangulo[1] then
                direcao_perseguida = -1
            elseif linha_perseguida > pos_triangulo[1] then
                direcao_perseguida = 1
            else
                direcao_perseguida = 0
            end
        end
        
    elseif triangulo_estado == TRIANGULO_ESTADO_PERSEGUINDO_LINHA then
        -- Perseguindo a linha do jogador (continua mesmo se ele sair da coluna 2)
        if dt then
            triangulo_tempo_estado = triangulo_tempo_estado + dt
        end
        
        -- Calcular tempo restante
        local tempo_restante = TRIANGULO_TEMPO_PERSEGUICAO - triangulo_tempo_estado
        
        -- Atualizar linha alvo (sempre a linha atual do jogador)
        linha_perseguida = pos_bola[1]
        
        -- Atualizar direção
        if linha_perseguida < pos_triangulo[1] then
            direcao_perseguida = -1
        elseif linha_perseguida > pos_triangulo[1] then
            direcao_perseguida = 1
        else
            direcao_perseguida = 0
        end
        
        -- Movimento em pulinhos apenas se ainda não está no período de parada
        if tempo_restante > TRIANGULO_TEMPO_PARAR_ANTES then
            mover_triangulo_em_pulinho(tempo_atual)
        else
            -- Parou de se mover para dar chance ao jogador
            -- Apenas não se move
        end
        
        -- Verificar se já perseguiu por tempo suficiente
        if triangulo_tempo_estado >= TRIANGULO_TEMPO_PERSEGUICAO then
            triangulo_estado = TRIANGULO_ESTADO_PARADO_PREPARANDO
            triangulo_tempo_estado = 0
        end
        
        -- Verificar se jogador entrou em coluna de ataque durante perseguição
        if jogador_em_coluna_ataque() then
            -- Cancelar perseguição e iniciar ataque de coluna
            triangulo_estado = TRIANGULO_ESTADO_PREPARANDO_COLUNA
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = false
        end
        
    elseif triangulo_estado == TRIANGULO_ESTADO_PARADO_PREPARANDO then
        -- Estado de preparação final antes de lançar o projétil (parado)
        if dt then
            triangulo_tempo_estado = triangulo_tempo_estado + dt
        end
        
        -- Não se move neste estado
        
        -- Pequena pausa antes de lançar para dar tempo ao jogador
        if triangulo_tempo_estado >= 0.5 then  -- Meio segundo de preparação final
            triangulo_estado = TRIANGULO_ESTADO_LANCANDO_PROJETIL
            triangulo_tempo_estado = 0
        end
        
    elseif triangulo_estado == TRIANGULO_ESTADO_LANCANDO_PROJETIL then
        -- Lançar projétil
        local acertou = lancar_projetil_triangulo()
        
        if acertou then
            -- Volta ao estado normal (o projétil já aplicou os efeitos)
            triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO
            modo_perseguicao_linha = false
        else
            triangulo_estado = TRIANGULO_ESTADO_RECUO
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = false
        end
        
        -- Desativar colunas 1 e 3 se estiverem ativas
        if coluna_1_ativa or coluna_3_ativa then
            coluna_1_ativa = false
            coluna_3_ativa = false
            coluna_1_tempo_restante = 0
            coluna_3_tempo_restante = 0
            coluna_1_dano_aplicado = false
            coluna_3_dano_aplicado = false
        end
        
    elseif triangulo_estado == TRIANGULO_ESTADO_RECUO then
        -- Estado de recuo após errar o projétil
        if dt then
            triangulo_tempo_estado = triangulo_tempo_estado + dt
        end
        
        -- Não se move durante o recuo
        if triangulo_tempo_estado >= TRIANGULO_TEMPO_RECUO then
            triangulo_estado = TRIANGULO_ESTADO_PERSEGUINDO
            triangulo_tempo_estado = 0
            modo_perseguicao_linha = false
        end
    end
end

-- Função para lançar projétil do triângulo (lança)
function lancar_projetil_triangulo()
    local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
    local x_inicio = celula_triangulo.centro_x - tamanho_triangulo - 10
    local y_inicio = celula_triangulo.centro_y
    
    -- Criar projétil
    local projetil = {
        x = x_inicio,
        y = y_inicio,
        velocidade = -TRIANGULO_VELOCIDADE_PROJETIL,
        tipo = 'lanca_triangulo',
        dano = TRIANGULO_DANO_PROJETIL,
        linha_origem = pos_triangulo[1],
        ativo = true,
        acertou = false
    }
    
    table.insert(projeteis_triangulo, projetil)
    
    -- Verificar se acertou instantaneamente (jogador na mesma linha e à esquerda)
    if pos_bola[1] == pos_triangulo[1] and pos_bola[2] < pos_triangulo[2] then
        aplicar_efeito_projetil_triangulo(projetil)
        return true
    end
    
    return false
end

-- Função para aplicar efeito do projétil no jogador
function aplicar_efeito_projetil_triangulo(projetil)
    if projetil.acertou then return end
    
    -- Verificar imunidades
    if imune_dano or carta2_ativa then
        return
    end
    
    -- Aplicar dano
    VIDA_JOGADOR = VIDA_JOGADOR - projetil.dano
    if VIDA_JOGADOR < 0 then
        VIDA_JOGADOR = 0
    end
    
    -- Empurrar jogador para coluna 1 (se não estiver já)
    if pos_bola[2] > 1 then
        pos_bola[2] = 1
    end
    
    -- Bloquear movimento do jogador
    bloqueado_movimento = true
    tempo_bloqueio = TRIANGULO_TEMPO_BLOQUEIO_JOGADOR
    
    projetil.acertou = true
end

-- Função para atualizar projéteis do triângulo
function atualizar_projeteis_triangulo(dt)
    for i = #projeteis_triangulo, 1, -1 do
        local proj = projeteis_triangulo[i]
        
        -- Atualizar posição
        proj.x = proj.x + proj.velocidade * dt * 60  -- Multiplicar por 60 para compensar dt
        
        -- Verificar colisão com jogador
        if not proj.acertou and VIDA_JOGADOR > 0 then
            local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
            local bola_x1 = celula_bola.centro_x - tamanho_bola
            local bola_y1 = celula_bola.centro_y - tamanho_bola
            local bola_x2 = celula_bola.centro_x + tamanho_bola
            local bola_y2 = celula_bola.centro_y + tamanho_bola
            
            if proj.x >= bola_x1 and proj.x <= bola_x2 and
               proj.y >= bola_y1 and proj.y <= bola_y2 then
                aplicar_efeito_projetil_triangulo(proj)
            end
        end
        
        -- Remover se saiu da tela
        if proj.x < -50 then
            table.remove(projeteis_triangulo, i)
        end
    end
end

-- Função para desenhar o triângulo
function desenhar_triangulo()
    if VIDA_TRIANGULO > 0 and pos_triangulo[1] > 0 then
        local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
        local x, y = celula_triangulo.centro_x, celula_triangulo.centro_y
        local tamanho_animado = TRIANGULO_TAMANHO + math.sin(animacao_triangulo * 0.1) * 3
        
        -- Sombra
        love.graphics.setColor(PRETO)
        love.graphics.polygon("fill",
            x - tamanho_animado / 2, y,
            x + tamanho_animado / 2, y - tamanho_animado / 2,
            x + tamanho_animado / 2, y + tamanho_animado / 2
        )
        
        -- Corpo principal
        love.graphics.setColor(TRIANGULO_COR_NORMAL)
        love.graphics.polygon("fill",
            x - tamanho_animado / 2 + 2, y,
            x + tamanho_animado / 2 - 2, y - tamanho_animado / 2 + 2,
            x + tamanho_animado / 2 - 2, y + tamanho_animado / 2 - 2
        )
        
    end
end

-- Função para desenhar os efeitos visuais do triângulo 
function desenhar_efeitos_triangulo()
    -- Desenhar efeito de preparação nas colunas 1 e 3
    if triangulo_estado == TRIANGULO_ESTADO_PREPARANDO_COLUNA then
        -- Piscar colunas 1 e 3 em laranja escuro
        local piscar = math.sin(love.timer.getTime() * 8) > 0
        
        if piscar then
            for _, coluna in ipairs({1, 3}) do
                for linha = 1, NUM_LINHAS do
                    local celula = GRID_CELULAS[linha][coluna]
                    love.graphics.setColor(TRIANGULO_COR_ESCURA[1], TRIANGULO_COR_ESCURA[2], TRIANGULO_COR_ESCURA[3], 0.6)
                    love.graphics.rectangle("fill", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                    
                    love.graphics.setColor(TRIANGULO_COR_ESCURA[1], TRIANGULO_COR_ESCURA[2], TRIANGULO_COR_ESCURA[3], 0.9)
                    love.graphics.setLineWidth(4)
                    love.graphics.rectangle("line", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                end
            end
        end
        
    -- Desenhar colunas ativas (causando dano) - MODIFICADO: só desenha se estiver ativa
    elseif coluna_1_ativa or coluna_3_ativa then
        if coluna_1_ativa then
            for linha = 1, NUM_LINHAS do
                local celula = GRID_CELULAS[linha][1]
                love.graphics.setColor(TRIANGULO_COR_ESCURA[1], TRIANGULO_COR_ESCURA[2], TRIANGULO_COR_ESCURA[3], 0.8)
                love.graphics.rectangle("fill", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                love.graphics.setColor(TRIANGULO_COR_ESCURA[1], TRIANGULO_COR_ESCURA[2], TRIANGULO_COR_ESCURA[3], 1)
                love.graphics.setLineWidth(4)
                love.graphics.rectangle("line", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                -- Símbolo de perigo (só aparece se o dano ainda não foi aplicado)
                if not coluna_1_dano_aplicado then
                    love.graphics.setColor(BRANCO)
                    love.graphics.setFont(love.graphics.newFont(24))
                    love.graphics.print("!", celula.centro_x - 10, celula.centro_y - 15)
                end
            end
        end
        
        if coluna_3_ativa then
            for linha = 1, NUM_LINHAS do
                local celula = GRID_CELULAS[linha][3]
                love.graphics.setColor(TRIANGULO_COR_ESCURA[1], TRIANGULO_COR_ESCURA[2], TRIANGULO_COR_ESCURA[3], 0.8)
                love.graphics.rectangle("fill", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                love.graphics.setColor(TRIANGULO_COR_ESCURA[1], TRIANGULO_COR_ESCURA[2], TRIANGULO_COR_ESCURA[3], 1)
                love.graphics.setLineWidth(4)
                love.graphics.rectangle("line", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                -- Símbolo de perigo (só aparece se o dano ainda não foi aplicado)
                if not coluna_3_dano_aplicado then
                    love.graphics.setColor(BRANCO)
                    love.graphics.setFont(love.graphics.newFont(24))
                    love.graphics.print("!", celula.centro_x - 10, celula.centro_y - 15)
                end
            end
        end
    end
    
    -- Desenhar efeito de perseguição de linha (sempre na coluna alvo)
    if modo_perseguicao_linha or triangulo_estado == TRIANGULO_ESTADO_PERSEGUINDO_LINHA or
       triangulo_estado == TRIANGULO_ESTADO_PARADO_PREPARANDO then
        
        -- Calcular tempo restante para a barra de progresso
        local tempo_restante = 0
        local tempo_total = 0
        
        if triangulo_estado == TRIANGULO_ESTADO_PERSEGUINDO_LINHA then
            tempo_restante = TRIANGULO_TEMPO_PERSEGUICAO - triangulo_tempo_estado
            tempo_total = TRIANGULO_TEMPO_PERSEGUICAO
        elseif triangulo_estado == TRIANGULO_ESTADO_PARADO_PREPARANDO then
            tempo_restante = 0.5 - triangulo_tempo_estado  -- Contagem regressiva final
            tempo_total = 0.5
        end
        
        -- Calcular progresso (0 a 1, onde 0 = tempo acabando, 1 = tempo cheio)
        local progresso = 0
        if tempo_total > 0 then
            progresso = tempo_restante / tempo_total
        end
        
        -- Velocidade de piscar aumenta conforme se aproxima do fim
        local velocidade_piscar = 12
        if tempo_restante <= TRIANGULO_TEMPO_PARAR_ANTES then
            velocidade_piscar = 20  -- Piscar mais rápido no final
        end
        if triangulo_estado == TRIANGULO_ESTADO_PARADO_PREPARANDO then
            velocidade_piscar = 30  -- Piscar muito rápido na preparação final
        end
        
        local piscar = math.sin(love.timer.getTime() * velocidade_piscar) > 0
        
        if piscar then
            local celula = GRID_CELULAS[linha_perseguida][coluna_alvo_perseguida]
            love.graphics.setColor(TRIANGULO_COR_CIANO[1], TRIANGULO_COR_CIANO[2], TRIANGULO_COR_CIANO[3], 0.5)
            love.graphics.rectangle("fill", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
            
            love.graphics.setColor(TRIANGULO_COR_CIANO[1], TRIANGULO_COR_CIANO[2], TRIANGULO_COR_CIANO[3], 0.8)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
        end
        
        -- Mostrar direção da perseguição
        if direcao_perseguida ~= 0 and triangulo_estado ~= TRIANGULO_ESTADO_PARADO_PREPARANDO then
            local seta_x = GRID_CELULAS[pos_triangulo[1]][5].centro_x
            local seta_y = GRID_CELULAS[pos_triangulo[1]][5].centro_y
            
            love.graphics.setColor(TRIANGULO_COR_CIANO)
            if direcao_perseguida == -1 then  -- Para cima
                love.graphics.polygon("fill",
                    seta_x, seta_y - 40,
                    seta_x - 10, seta_y - 25,
                    seta_x + 10, seta_y - 25
                )
            else  -- Para baixo
                love.graphics.polygon("fill",
                    seta_x, seta_y + 40,
                    seta_x - 10, seta_y + 25,
                    seta_x + 10, seta_y + 25
                )
            end
        end
        
        -- Desenhar BARRA DE CARREGAMENTO LARANJA em cima do triângulo (substituindo o tempo em segundos)
        if tempo_restante > 0 and triangulo_esta_vivo() then
            local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
            local x_tri, y_tri = celula_triangulo.centro_x, celula_triangulo.centro_y
            
            -- Configurações da barra
            local largura_barra = 80
            local altura_barra = 8
            local x_barra = x_tri - largura_barra / 2
            local y_barra = y_tri - TRIANGULO_TAMANHO - 20
            
            -- Fundo da barra (preto)
            love.graphics.setColor(PRETO)
            love.graphics.rectangle("fill", x_barra, y_barra, largura_barra, altura_barra, 4)
            
            -- Barra de progresso (laranja)
            local largura_progresso = largura_barra * progresso
            love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.9)
            love.graphics.rectangle("fill", x_barra, y_barra, largura_progresso, altura_barra, 4)
            
            -- Borda da barra
            love.graphics.setColor(BRANCO)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", x_barra, y_barra, largura_barra, altura_barra, 4)
            
            -- Pequeno texto indicativo (opcional)
            if triangulo_estado == TRIANGULO_ESTADO_PARADO_PREPARANDO then
                love.graphics.setColor(LARANJA_CLARO)
                love.graphics.setFont(love.graphics.newFont(12))
                love.graphics.print("LANÇA!", x_barra + 20, y_barra - 15)
            end
        end
    end
end

-- Função para desenhar projéteis do triângulo
function desenhar_projeteis_triangulo()
    for _, proj in ipairs(projeteis_triangulo) do
        if proj.ativo then
            -- Desenhar lança
            local x, y = proj.x, proj.y
            
            -- Corpo da lança
            love.graphics.setColor(PRETO)
            love.graphics.rectangle("fill", x - 10, y - 3, 20, 6)
            
            love.graphics.setColor(LARANJA_CLARO)
            love.graphics.rectangle("fill", x - 8, y - 2, 16, 4)
            
            -- Ponta da lança
            love.graphics.setColor(PRETO)
            love.graphics.polygon("fill",
                x + 10, y,
                x + 15, y - 5,
                x + 15, y + 5
            )
            
            love.graphics.setColor(LARANJA_ESCURO)
            love.graphics.polygon("fill",
                x + 8, y,
                x + 13, y - 4,
                x + 13, y + 4
            )
        end
    end
end

-- Função para limpar efeitos
function limpar_efeitos_triangulo()
    resetar_estado_triangulo()
end