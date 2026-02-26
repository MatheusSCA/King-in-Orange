-- modules/enemies_quadrado.lua
-- Módulo específico para o inimigo quadrado (3 unidades sincronizadas com vida individual de 600 cada)

-- Estados do quadrado (coletivo)
QUADRADO_ESTADO_MOVENDO = "movendo"
QUADRADO_ESTADO_PREPARANDO = "preparando"
QUADRADO_ESTADO_ATACANDO = "atacando"
QUADRADO_ESTADO_IMUNE = "imune"
QUADRADO_ESTADO_RECUO = "recuo"


-- Variáveis de estado coletivo
VIDA_QUADRADO = 1800  -- Vida total (600 * 3)
quadrado_estado = QUADRADO_ESTADO_MOVENDO
quadrado_tempo_estado = 0
quadrado_movimentos_restantes = 0
quadrado_ultimo_movimento = 0

-- Estrutura para cada quadrado individual (cada um com 450 de vida)
quadrados = {
    {
        pos = {1, 4},           -- Posição inicial (linha, coluna)
        vivo = true,
        id = 1,
        vida = 450,              -- Cada quadrado tem 450 de vida
        area_ataque = nil,       -- Área que este quadrado vai atacar {linha, coluna}
        efeito_transparencia = nil,
        tempo_transparencia = 0
    },
    {
        pos = {2, 5},
        vivo = true,
        id = 2,
        vida = 450,
        area_ataque = nil,
        efeito_transparencia = nil,
        tempo_transparencia = 0
    },
    {
        pos = {3, 6},
        vivo = true,
        id = 3,
        vida = 450,
        area_ataque = nil,
        efeito_transparencia = nil,
        tempo_transparencia = 0
    }
}

function inicializar_quadrados()
    quadrados = {
        {
            pos = {1, 4},
            vivo = true,
            id = 1,
            vida = 600,
            area_ataque = nil,
            efeito_transparencia = nil,
            tempo_transparencia = 0
        },
        {
            pos = {2, 5},
            vivo = true,
            id = 2,
            vida = 600,
            area_ataque = nil,
            efeito_transparencia = nil,
            tempo_transparencia = 0
        },
        {
            pos = {3, 6},
            vivo = true,
            id = 3,
            vida = 600,
            area_ataque = nil,
            efeito_transparencia = nil,
            tempo_transparencia = 0
        }
    }
    
    VIDA_QUADRADO = 1800
    resetar_estado_quadrados()
end

function resetar_estado_quadrados()
    quadrado_estado = QUADRADO_ESTADO_MOVENDO
    quadrado_tempo_estado = 0
    quadrado_movimentos_restantes = 0
    quadrado_ultimo_movimento = 0
    
    for _, quad in ipairs(quadrados) do
        quad.area_ataque = nil
        quad.efeito_transparencia = nil
        quad.tempo_transparencia = 0
    end
end

function resetar_quadrados_para_fase()
    inicializar_quadrados()
end

function desativar_quadrados()
    for _, quad in ipairs(quadrados) do
        quad.vivo = false
        quad.pos = {-1, -1}
    end
    VIDA_QUADRADO = 0
end

function quadrado_esta_vivo()
    for _, quad in ipairs(quadrados) do
        if quad.vivo then
            return true
        end
    end
    return false
end

-- Função para verificar se uma posição está ocupada por outro quadrado vivo
function posicao_ocupada(linha, coluna, quadrado_ignorado)
    for _, quad in ipairs(quadrados) do
        if quad.vivo and quad.id ~= quadrado_ignorado and quad.pos[1] == linha and quad.pos[2] == coluna then
            return true
        end
    end
    return false
end

-- Função para escolher áreas de ataque diferentes para cada quadrado
function escolher_areas_ataque()
    local areas_disponiveis = {}
    
    -- Criar lista de todas as áreas do jogador (9 posições)
    for linha = 1, 3 do
        for coluna = 1, 3 do
            table.insert(areas_disponiveis, {linha = linha, coluna = coluna})
        end
    end
    
    -- Embaralhar áreas
    for i = #areas_disponiveis, 2, -1 do
        local j = love.math.random(i)
        areas_disponiveis[i], areas_disponiveis[j] = areas_disponiveis[j], areas_disponiveis[i]
    end
    
    -- Atribuir áreas diferentes para cada quadrado vivo
    local idx = 1
    for _, quad in ipairs(quadrados) do
        if quad.vivo and idx <= #areas_disponiveis then
            quad.area_ataque = areas_disponiveis[idx]
            idx = idx + 1
        end
    end
end

-- Função para encontrar uma direção válida para um quadrado específico
function encontrar_direcao_valida(quad, direcao_desejada)
    local dx, dy = direcao_desejada[1], direcao_desejada[2]
    
    -- Tentar a direção desejada primeiro
    local nova_linha = quad.pos[1] + dy
    local nova_coluna = quad.pos[2] + dx
    
    -- Verificar limites e se a posição está ocupada
    if nova_linha >= 1 and nova_linha <= 3 and 
       nova_coluna >= 4 and nova_coluna <= 6 and
       not posicao_ocupada(nova_linha, nova_coluna, quad.id) then
        return {dx, dy}
    end
    
    -- Se a direção desejada não for válida, tentar outras direções (exceto a desejada)
    local direcoes_alternativas = {
        {0, -1},  -- cima
        {0, 1},   -- baixo
        {-1, 0},  -- esquerda
        {1, 0},   -- direita
        {0, 0}    -- parado
    }
    
    -- Remover a direção desejada da lista de alternativas
    local alternativas = {}
    for _, dir in ipairs(direcoes_alternativas) do
        if not (dir[1] == dx and dir[2] == dy) then
            table.insert(alternativas, dir)
        end
    end
    
    -- Embaralhar alternativas
    for i = #alternativas, 2, -1 do
        local j = love.math.random(i)
        alternativas[i], alternativas[j] = alternativas[j], alternativas[i]
    end
    
    -- Tentar cada alternativa
    for _, dir in ipairs(alternativas) do
        local alt_linha = quad.pos[1] + dir[2]
        local alt_coluna = quad.pos[2] + dir[1]
        
        if alt_linha >= 1 and alt_linha <= 3 and 
           alt_coluna >= 4 and alt_coluna <= 6 and
           not posicao_ocupada(alt_linha, alt_coluna, quad.id) then
            return dir
        end
    end
    
    -- Se nenhuma direção for válida, ficar parado
    return {0, 0}
end

-- Função para mover todos os quadrados na mesma direção (sem sobreposição)
function mover_todos_quadrados()
    -- Escolher uma direção primária para todos
    local direcoes_primarias = {
        {0, -1},  -- cima
        {0, 1},   -- baixo
        {-1, 0},  -- esquerda
        {1, 0},   -- direita
        {0, 0}    -- parado
    }
    
    local dir_idx = love.math.random(1, #direcoes_primarias)
    local dx_primario, dy_primario = direcoes_primarias[dir_idx][1], direcoes_primarias[dir_idx][2]
    
    local moveu_algum = false
    local novas_posicoes = {}
    
    -- Primeiro, calcular as novas posições desejadas
    for _, quad in ipairs(quadrados) do
        if quad.vivo then
            local direcao = encontrar_direcao_valida(quad, {dx_primario, dy_primario})
            local nova_linha = quad.pos[1] + direcao[2]
            local nova_coluna = quad.pos[2] + direcao[1]
            
            novas_posicoes[quad.id] = {
                linha = nova_linha,
                coluna = nova_coluna,
                moveu = (direcao[1] ~= 0 or direcao[2] ~= 0)
            }
        end
    end
    
    -- Verificar conflitos entre as novas posições
    local conflito = true
    local tentativas = 0
    local max_tentativas = 10
    
    while conflito and tentativas < max_tentativas do
        conflito = false
        
        -- Verificar se duas novas posições são iguais
        for i = 1, #quadrados do
            for j = i+1, #quadrados do
                local q1 = quadrados[i]
                local q2 = quadrados[j]
                
                if q1.vivo and q2.vivo then
                    local pos1 = novas_posicoes[q1.id]
                    local pos2 = novas_posicoes[q2.id]
                    
                    if pos1.linha == pos2.linha and pos1.coluna == pos2.coluna then
                        conflito = true
                        -- Resolver conflito: um dos dois fica parado
                        if love.math.random(2) == 1 then
                            novas_posicoes[q1.id] = {linha = q1.pos[1], coluna = q1.pos[2], moveu = false}
                        else
                            novas_posicoes[q2.id] = {linha = q2.pos[1], coluna = q2.pos[2], moveu = false}
                        end
                        break
                    end
                end
            end
            if conflito then break end
        end
        
        tentativas = tentativas + 1
    end
    
    -- Aplicar as novas posições
    for _, quad in ipairs(quadrados) do
        if quad.vivo then
            local nova_pos = novas_posicoes[quad.id]
            quad.pos[1] = nova_pos.linha
            quad.pos[2] = nova_pos.coluna
            if nova_pos.moveu then
                moveu_algum = true
            end
        end
    end
    
    return moveu_algum
end

-- Função principal de atualização da IA dos quadrados (sincronizada)
function atualizar_ia_quadrados(tempo_atual, dt)
    -- Verificar se todos os quadrados estão mortos
    local todos_mortos = true
    for _, quad in ipairs(quadrados) do
        if quad.vivo then
            todos_mortos = false
            break
        end
    end
    
    if todos_mortos then
        VIDA_QUADRADO = 0
        return
    end
    
    -- Atualizar efeitos de transparência individuais
    for _, quad in ipairs(quadrados) do
        if quad.vivo and quad.efeito_transparencia then
            quad.tempo_transparencia = quad.tempo_transparencia + dt
            if quad.tempo_transparencia >= QUADRADO_TEMPO_TRANSPARENCIA then
                quad.efeito_transparencia = nil
                quad.tempo_transparencia = 0
            end
        end
    end
    
    -- ESTADOS COLETIVOS
    
    -- Estado de preparação
    if quadrado_estado == QUADRADO_ESTADO_PREPARANDO then
        quadrado_tempo_estado = quadrado_tempo_estado + dt
        
        if quadrado_tempo_estado >= QUADRADO_TEMPO_PREPARACAO then
            realizar_ataque_todos_quadrados()
        end
        return
    end
    
    -- Estado de ataque (instantâneo)
    if quadrado_estado == QUADRADO_ESTADO_ATACANDO then
        quadrado_estado = QUADRADO_ESTADO_RECUO
        quadrado_tempo_estado = 0
        quadrado_movimentos_restantes = QUADRADO_NUM_MOVIMENTOS
        return
    end
    
    -- Estado de recuo (todos se movem juntos)
    if quadrado_estado == QUADRADO_ESTADO_RECUO then
        if tempo_atual - quadrado_ultimo_movimento >= QUADRADO_INTERVALO_MOVIMENTO then
            local moveu = mover_todos_quadrados()
            if moveu then
                quadrado_ultimo_movimento = tempo_atual
                quadrado_movimentos_restantes = quadrado_movimentos_restantes - 1
            end
        end
        
        if quadrado_movimentos_restantes <= 0 then
            quadrado_estado = QUADRADO_ESTADO_IMUNE
            quadrado_tempo_estado = 0
        end
        return
    end
    
    -- Estado de imunidade (todos juntos)
    if quadrado_estado == QUADRADO_ESTADO_IMUNE then
        quadrado_tempo_estado = quadrado_tempo_estado + dt
        
        if quadrado_tempo_estado >= QUADRADO_TEMPO_IMUNIDADE then
            quadrado_estado = QUADRADO_ESTADO_MOVENDO
            quadrado_tempo_estado = 0
        end
        return
    end
    
    -- Estado MOVENDO (movimento normal e preparação para ataque)
    if quadrado_estado == QUADRADO_ESTADO_MOVENDO then
        -- Mover todos juntos a cada intervalo
        if tempo_atual - quadrado_ultimo_movimento >= QUADRADO_INTERVALO_MOVIMENTO then
            mover_todos_quadrados()
            quadrado_ultimo_movimento = tempo_atual
        end
        
        -- Decidir se vão atacar (2% de chance por frame a 60fps)
        if love.math.random() < 0.02 * dt * 60 then
            -- Iniciar preparação para ataque (todos juntos)
            quadrado_estado = QUADRADO_ESTADO_PREPARANDO
            quadrado_tempo_estado = 0
            
            -- Escolher áreas de ataque diferentes para cada quadrado
            escolher_areas_ataque()
            print("Quadrados iniciando preparação para ataque!")
        end
    end
end

function realizar_ataque_todos_quadrados()
    -- Todos os quadrados atacam ao mesmo tempo
    local jogador_atingido = false
    
    for _, quad in ipairs(quadrados) do
        if quad.vivo and quad.area_ataque then
            -- Verifica se o jogador está na área de ataque deste quadrado
            if pos_bola[1] == quad.area_ataque.linha and pos_bola[2] == quad.area_ataque.coluna then
                -- Verifica se o jogador não está imune
                if not imune_dano and not carta2_ativa then
                    VIDA_JOGADOR = VIDA_JOGADOR - QUADRADO_DANO
                    if VIDA_JOGADOR < 0 then
                        VIDA_JOGADOR = 0
                    end
                    jogador_atingido = true
                end
            end
            
            -- Configurar efeito de transparência na área atacada
            quad.efeito_transparencia = quad.area_ataque
            quad.tempo_transparencia = 0
            quad.area_ataque = nil  -- Limpa após o ataque
        end
    end
    
    if jogador_atingido then
        print("Quadrados: Jogador atingido! Dano: " .. QUADRADO_DANO)
    else
        print("Quadrados: Ataque realizado - jogador não estava nas áreas atacadas")
    end
    
    -- Mudar para estado de ataque
    quadrado_estado = QUADRADO_ESTADO_ATACANDO
end

-- Função para aplicar dano a um quadrado específico
function aplicar_dano_quadrado_especifico(quad, dano)
    if quadrado_estado == QUADRADO_ESTADO_IMUNE then
        print("Quadrado " .. quad.id .. " imune! Dano ignorado.")
        return false
    end
    
    quad.vida = quad.vida - dano
    if quad.vida <= 0 then
        quad.vivo = false
        quad.vida = 0
        print("Quadrado " .. quad.id .. " morreu!")
    else
        print("Quadrado " .. quad.id .. " sofreu " .. dano .. " de dano. Vida restante: " .. quad.vida)
    end
    
    -- Atualizar vida total
    VIDA_QUADRADO = 0
    for _, q in ipairs(quadrados) do
        if q.vivo then
            VIDA_QUADRADO = VIDA_QUADRADO + q.vida
        end
    end
    
    return true
end

-- Função para aplicar dano em área (distribuído entre os quadrados vivos)
function aplicar_dano_area_quadrados(dano)
    if quadrado_estado == QUADRADO_ESTADO_IMUNE then
        print("Quadrados imunes! Dano em área ignorado.")
        return false
    end
    
    -- Contar quantos quadrados vivos
    local vivos = 0
    for _, quad in ipairs(quadrados) do
        if quad.vivo then
            vivos = vivos + 1
        end
    end
    
    if vivos == 0 then return false end
    
    -- Distribuir dano igualmente entre os vivos
    local dano_por_quadrado = math.floor(dano / vivos)
    local dano_restante = dano - (dano_por_quadrado * vivos)
    
    for i, quad in ipairs(quadrados) do
        if quad.vivo then
            -- Cada quadrado recebe sua parte
            local dano_atual = dano_por_quadrado
            
            -- O primeiro quadrado recebe o resto para totalizar o dano correto
            if i == 1 then
                dano_atual = dano_atual + dano_restante
            end
            
            quad.vida = quad.vida - dano_atual
            if quad.vida <= 0 then
                quad.vivo = false
                quad.vida = 0
                print("Quadrado " .. quad.id .. " morreu devido a dano em área!")
            end
        end
    end
    
    -- Atualizar vida total
    VIDA_QUADRADO = 0
    for _, quad in ipairs(quadrados) do
        if quad.vivo then
            VIDA_QUADRADO = VIDA_QUADRADO + quad.vida
        end
    end
    
    print("Dano em área aplicado aos quadrados: " .. dano .. " distribuído")
    return true
end

-- Funções de desenho (com números de vida na cor laranja)
function desenhar_quadrados()
    for _, quad in ipairs(quadrados) do
        if quad.vivo and quad.pos[1] > 0 then
            local celula_quadrado = GRID_CELULAS[quad.pos[1]][quad.pos[2]]
            local x, y = celula_quadrado.centro_x, celula_quadrado.centro_y
            
            -- Cor baseada no estado coletivo
            local cor_base = QUADRADO_COR_NORMAL
            
            if quadrado_estado == QUADRADO_ESTADO_IMUNE then
                local piscar = math.sin(love.timer.getTime() * 15) > 0
                if piscar then
                    cor_base = QUADRADO_COR_IMUNE
                end
            end
            
            desenhar_quadrado_simples(cor_base, {x, y}, tamanho_quadrado)
            
            -- Desenhar vida acima de cada quadrado (LARANJA)
            local fonte_vida = love.graphics.newFont(16)
            love.graphics.setFont(fonte_vida)
            
            -- Sombra do texto (preta)
            love.graphics.setColor(PRETO)
            love.graphics.print(math.floor(quad.vida), x - 14, y - tamanho_quadrado - 14)
            
            -- Texto de vida (LARANJA)
            love.graphics.setColor(LARANJA_CLARO)
            love.graphics.print(math.floor(quad.vida), x - 15, y - tamanho_quadrado - 15)
        end
    end
end

function desenhar_quadrado_simples(cor, posicao, tamanho)
    local x, y = posicao[1], posicao[2]
    
    -- Sombra simples
    love.graphics.setColor(PRETO)
    love.graphics.rectangle("fill", 
        x - tamanho/2, y - tamanho/2,
        tamanho, tamanho
    )
    
    -- Corpo principal
    love.graphics.setColor(cor)
    love.graphics.rectangle("fill",
        x - tamanho/2 + 2, y - tamanho/2 + 2,
        tamanho - 4, tamanho - 4
    )
end

function desenhar_efeitos_preparacao_quadrados()
    if quadrado_estado == QUADRADO_ESTADO_PREPARANDO then
        -- Piscar as áreas alvo em laranja
        local piscar = math.sin(love.timer.getTime() * 10) > 0
        
        if piscar then
            for _, quad in ipairs(quadrados) do
                if quad.vivo and quad.area_ataque then
                    local celula = GRID_CELULAS[quad.area_ataque.linha][quad.area_ataque.coluna]
                    
                    love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.6)
                    love.graphics.rectangle("fill", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                    
                    love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.9)
                    love.graphics.setLineWidth(4)
                    love.graphics.rectangle("line", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                end
            end
        end
    end
end

function desenhar_efeito_transparencia_quadrados()
    for _, quad in ipairs(quadrados) do
        if quad.vivo and quad.efeito_transparencia then
            local opacidade = 0.5 * (1 - quad.tempo_transparencia / QUADRADO_TEMPO_TRANSPARENCIA)
            
            local celula = GRID_CELULAS[quad.efeito_transparencia.linha][quad.efeito_transparencia.coluna]
            
            love.graphics.setColor(1, 1, 1, opacidade)
            love.graphics.rectangle("fill", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
            
            love.graphics.setColor(1, 1, 1, opacidade/2)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
        end
    end
end

-- Função utilitária
function encontrar_quadrado_na_posicao(linha, coluna)
    for _, quad in ipairs(quadrados) do
        if quad.vivo and quad.pos[1] == linha and quad.pos[2] == coluna then
            return quad
        end
    end
    return nil
end

function remover_quadrados_mortos()
    for _, quad in ipairs(quadrados) do
        if not quad.vivo then
            quad.pos = {-1, -1}
        end
    end
end

-- Função para verificar se os quadrados estão imunes
function quadrados_imunes()
    return quadrado_estado == QUADRADO_ESTADO_IMUNE
end