-- modules/cards.lua
-- Sistema de cartas 

-- CONSTANTES GLOBAIS (FÁCEIS DE AJUSTAR)
-- Constantes da Carta 2
CARTA2_DURACAO = 0.8              -- Duração do efeito em segundos
CARTA2_DANO = 250                  -- Dano causado
CARTA2_AVANCO_VISUAL = 2           -- Colunas à frente para posição visual
CARTA2_AVANCO_ATAQUE = 3           -- Colunas à frente para área de ataque
CARTA2_FRAME_ANIMACAO = 30         -- Velocidade da animação
CARTA2_PROGRESSO_VELOCIDADE = 8    -- Velocidade do progresso
CARTA2_BRILHO_VELOCIDADE = 20      -- Velocidade do brilho
CARTA2_PARTICULAS_VELOCIDADE = 400 -- Velocidade das partículas
CARTA2_PARTICULAS_VIDA = 0.3       -- Vida inicial das partículas
CARTA2_PARTICULAS_DESAPARECE = 4   -- Velocidade que partículas desaparecem
CARTA2_NOVAS_PARTICULAS_CHANCE = 30 -- Chance de gerar novas partículas
CARTA2_NOVAS_PARTICULAS_VEL = 500  -- Velocidade das novas partículas
CARTA2_TAMANHO_BASE = 20           -- Tamanho base do efeito
CARTA2_TEXTO_ATIVO = "CORTE!"      -- Texto do efeito

-- Constantes da Carta 3
CARTA3_AVANCO = 3                  -- Colunas à frente para ataque
CARTA3_DANO = 150                   -- Dano causado
CARTA3_VELOCIDADE = 15              -- Velocidade do disparo 

-- Constantes da Carta 4
CARTA4_DURACAO = 5                  -- Duração da imunidade em segundos

-- Constantes da Carta 5
CARTA5_CURA_PERCENTUAL = 0.5        -- Percentual de cura (50% = 0.5)

-- Constantes da Carta 6
CARTA6_DURACAO = 0.8                -- Duração do efeito
CARTA6_COLUNAS = {4, 5}             -- Colunas afetadas
CARTA6_DIRECAO = 1                  -- 1 = direita
CARTA6_DANO = 100                     -- Dano causado
CARTA6_BLOQUEIO = 2.0                -- Tempo de bloqueio em segundos
CARTA6_FRAME_ANIMACAO = 30           -- Velocidade da animação
CARTA6_PROGRESSO_VELOCIDADE = 8      -- Velocidade do progresso
CARTA6_BRILHO_VELOCIDADE = 20        -- Velocidade do brilho
CARTA6_PARTICULAS_VELOCIDADE = 300   -- Velocidade das partículas
CARTA6_PARTICULAS_VIDA = 0.3         -- Vida inicial das partículas
CARTA6_TEXTO_ATIVO = "EMPURRAO!"     -- Texto do efeito
CARTA6_NUM_PARTICULAS = 20           -- Número de partículas iniciais

-- Constantes da Carta 7 (aleatória)
CARTA7_BLOQUEIO_TEMPO = 4            -- Tempo de bloqueio em segundos
CARTA7_TEXTO_DURACAO = 2             -- Duração do texto
CARTA7_ANIMACAO_VELOCIDADE = 8       -- Velocidade da animação da barra

-- Constantes da Carta 8
CARTA8_DURACAO = 3                 -- Duração total do efeito
CARTA8_VELOCIDADE = 1.5              -- Velocidade dos projéteis (menor = mais lento)
CARTA8_DANO = 300                      -- Dano causado
CARTA8_AVANCO_COLUNA = 6              -- Colunas à frente para o alvo
CARTA8_BLOQUEIO = 2.0                 -- Tempo de bloqueio em segundos
CARTA8_TAMANHO_BASE = 18              -- Tamanho base do projétil
CARTA8_TAMANHO_VARIACAO = 0.3         -- Variação de tamanho
CARTA8_TEXTO_ATIVO = "PUXADA!"        -- Texto do efeito

-- Constantes da Carta 9
CARTA9_DURACAO = 0.8                  -- Duração do efeito
CARTA9_COLUNAS = {5, 6}               -- Colunas afetadas
CARTA9_DIRECAO = -1                   -- -1 = esquerda
CARTA9_DANO = 100                       -- Dano causado
CARTA9_BLOQUEIO = 2.0                  -- Tempo de bloqueio em segundos
CARTA9_FRAME_ANIMACAO = 30             -- Velocidade da animação
CARTA9_PROGRESSO_VELOCIDADE = 8        -- Velocidade do progresso
CARTA9_BRILHO_VELOCIDADE = 20          -- Velocidade do brilho
CARTA9_PARTICULAS_VELOCIDADE = 300     -- Velocidade das partículas
CARTA9_PARTICULAS_VIDA = 0.3           -- Vida inicial das partículas

-- Constantes da Carta 10
CARTA10_MULTIPLICADOR = 100             -- Multiplicador para o dano (x * 100)

-- Constantes gerais
MAX_CUSTO = 5
DURACAO_MOSTRAR_CARTA = 2.0


-- DEFINIÇÃO DAS CARTAS
CARTAS = {
    {id = "A", custo = 0, copias = 1, descricao = "Copia próxima carta"},
    {id = "2", custo = 1, copias = 3, descricao = "Tiro grande na linha"},
    {id = "3", custo = 1, copias = 3, descricao = "Ataque em coluna"},
    {id = "4", custo = 2, copias = 2, descricao = "Imunidade por " .. CARTA4_DURACAO .. "s"},
    {id = "5", custo = 3, copias = 1, descricao = "Cura " .. (CARTA5_CURA_PERCENTUAL*100) .. "% da vida"},
    {id = "6", custo = 2, copias = 2, descricao = "Empurra inimigos das colunas da frente para direita"},
    {id = "7", custo = 1, copias = 1, descricao = "Efeito aleatório (1-7)"},
    {id = "8", custo = 1, copias = 1, descricao = "Projéteis que puxam inimigos para sua linha"},
    {id = "9", custo = 2, copias = 1, descricao = "Puxa inimigos das colunas de trás para esquerda"},
    {id = "10", custo = 5, copias = 1, descricao = "Dano baseado em cartas usadas"}
}


-- VARIÁVEIS GLOBAIS
deck_atual = {}
mao_atual = {}
cartas_selecionadas = {}
cartas_usadas = {}
custo_atual = 0

cartas_efeitos_ativos = {}
tempo_efeito_carta_4 = 0
imune_dano = false
bloqueado_movimento = false
bloqueado_ataque = false
inimigos_bloqueados = false
tempo_bloqueio = 0
ultima_carta_usada = nil
tempo_mostrar_carta = 0
colunas_cedidas = colunas_cedidas or {}  -- Garante que existe

-- Lista de cartas mantidas entre fases de preparação
cartas_nao_selecionadas = {}


-- VARIÁVEIS DA CARTA 2
carta2_ativa = false
carta2_pos_original = nil
carta2_pos_visual = nil
carta2_coluna_ataque = nil
carta2_tempo_restante = 0
carta2_linhas_afetadas = {}
carta2_frame_animacao = 0

-- Efeito visual da lâmina (carta 2)
efeito_espada = {
    ativo = false,
    x = 0,
    y = 0,
    largura = 0,
    altura = 0,
    progresso = 0,
    direcao = 1,
    brilho = 0,
    linha_ataque = 1,
    particulas = {}
}


-- VARIÁVEIS DA CARTA 6
carta6_ativa = false
carta6_tempo_restante = 0
carta6_frame_animacao = 0
carta6_inimigos_atingidos = {}


-- VARIÁVEIS DA CARTA 9
carta9_ativa = false
carta9_tempo_restante = 0
carta9_frame_animacao = 0
carta9_inimigos_atingidos = {}


-- VARIÁVEIS DA CARTA 8
carta8_ativa = false
carta8_projeteis = {}
carta8_tempo_restante = 0
carta8_linha_origem = 1
carta8_inimigos_atingidos = {}


-- EFEITO VISUAL COMPARTILHADO (CARTAS 6 E 9)
efeito_onda_horizontal = {
    ativo = false,
    x = 0,
    y = 0,
    largura = 0,
    altura = 0,
    progresso = 0,
    direcao = 1,  -- 1 = direita, -1 = esquerda
    brilho = 0,
    colunas = {},
    particulas = {}
}


-- FUNÇÕES DO DECK
function inicializar_deck()
    deck_atual = {}
    cartas_nao_selecionadas = {}
    cartas_usadas = {}
    
    for _, carta in ipairs(CARTAS) do
        for i = 1, carta.copias do
            table.insert(deck_atual, {
                id = carta.id,
                custo = carta.custo,
                descricao = carta.descricao,
                usada = false,
                carta_original = true
            })
        end
    end
    
    for i = #deck_atual, 2, -1 do
        local j = love.math.random(i)
        deck_atual[i], deck_atual[j] = deck_atual[j], deck_atual[i]
    end
end

function entrar_fase_preparacao()
    print("=== ENTRANDO NA FASE DE PREPARAÇÃO ===")
    
    mao_atual = {}
    
    local cartas_nao_selecionadas_count = #cartas_nao_selecionadas
    print("Cartas não selecionadas da fase anterior: " .. cartas_nao_selecionadas_count)
    
    for i = 1, cartas_nao_selecionadas_count do
        local carta = cartas_nao_selecionadas[i]
        if carta then
            table.insert(mao_atual, carta)
            print("  Adicionando carta não selecionada: " .. carta.id)
        end
    end
    
    cartas_nao_selecionadas = {}
    
    print("Adicionando cartas do deck até ter 6...")
    while #mao_atual < 6 and #deck_atual > 0 do
        local carta = table.remove(deck_atual, 1)
        if carta then
            table.insert(mao_atual, carta)
            print("  Adicionando carta do deck: " .. carta.id)
        end
    end
    
    cartas_selecionadas = {}
    custo_atual = 0
    
    carta_selecionada = 1
    tipo_selecao = "mao"
    linha_selecionada = 1
    
    print("Resultado: " .. #mao_atual .. " cartas na mão")
    print("  " .. cartas_nao_selecionadas_count .. " cartas não selecionadas da fase anterior")
    print("  " .. (#mao_atual - cartas_nao_selecionadas_count) .. " cartas novas do deck")
    print("=== FIM DA ENTRADA NA FASE DE PREPARAÇÃO ===")
end

function sair_fase_preparacao()
    print("=== SAINDO DA FASE DE PREPARAÇÃO ===")
    
    cartas_nao_selecionadas = {}
    
    for _, carta in ipairs(mao_atual) do
        local foi_selecionada = false
        for _, carta_selecionada in ipairs(cartas_selecionadas) do
            if carta.id == carta_selecionada.id and carta.custo == carta_selecionada.custo then
                foi_selecionada = true
                break
            end
        end
        
        if not foi_selecionada then
            table.insert(cartas_nao_selecionadas, carta)
            print("  Salvando carta não selecionada: " .. carta.id)
        end
    end
    
    for i, carta in ipairs(cartas_selecionadas) do
        table.insert(cartas_efeitos_ativos, {
            id = carta.id,
            posicao = i
        })
    end
    
    print("Resumo ao sair:")
    print("  Cartas selecionadas: " .. #cartas_selecionadas)
    print("  Cartas não selecionadas salvas: " .. #cartas_nao_selecionadas)
    print("  Cartas no deck: " .. #deck_atual)
    print("=== FIM DA SAÍDA DA FASE DE PREPARAÇÃO ===")
end

function selecionar_carta(indice)
    if indice < 1 or indice > #mao_atual then return false end
    
    local carta = mao_atual[indice]
    
    if #cartas_selecionadas >= 5 then
        print("Máximo de 5 cartas selecionadas atingido!")
        return false
    end
    
    if custo_atual + carta.custo > MAX_CUSTO then
        print("Custo máximo excedido! Custo atual: " .. custo_atual .. ", Custo da carta: " .. carta.custo)
        return false
    end
    
    table.insert(cartas_selecionadas, carta)
    table.remove(mao_atual, indice)
    custo_atual = custo_atual + carta.custo
    
    print("Carta " .. carta.id .. " selecionada. Custo total: " .. custo_atual .. "/5")
    return true
end

function remover_carta_selecionada(indice)
    if indice < 1 or indice > #cartas_selecionadas then return false end
    
    local carta = cartas_selecionadas[indice]
    table.insert(mao_atual, carta)
    table.remove(cartas_selecionadas, indice)
    custo_atual = custo_atual - carta.custo
    
    print("Carta " .. carta.id .. " removida da seleção. Custo total: " .. custo_atual .. "/5")
    return true
end

function usar_proxima_carta()
    if #cartas_efeitos_ativos == 0 then 
        print("Nenhuma carta disponível para usar!")
        ultima_carta_usada = nil
        return false 
    end
    
    local carta_efeito = table.remove(cartas_efeitos_ativos, 1)
    
    local carta_usada = nil
    for i, carta in ipairs(cartas_selecionadas) do
        if i == 1 then
            carta_usada = carta
            break
        end
    end
    
    if carta_usada then
        aplicar_efeito_carta(carta_usada.id)
        
        carta_usada.usada = true
        
        if not cartas_usadas then
            cartas_usadas = {}
        end
        
        -- Adiciona a carta usada à lista de cartas usadas
        table.insert(cartas_usadas, carta_usada)
        
        -- Remove a carta da lista de selecionadas
        table.remove(cartas_selecionadas, 1)
        
        ultima_carta_usada = carta_usada.id
        tempo_mostrar_carta = DURACAO_MOSTRAR_CARTA
        
        carta_usada.cor_usada = true
        carta_usada.tempo_usada = DURACAO_MOSTRAR_CARTA
        
        print("Carta " .. carta_usada.id .. " usada! Restam " .. #cartas_selecionadas .. " cartas na fila.")
        print("Cartas usadas até agora: " .. #cartas_usadas)
        print("Cartas restantes no deck: " .. #deck_atual)
    end
    
    return true
end

function aplicar_efeito_carta(id_carta)
    print("Usando carta: " .. id_carta)
    
    if id_carta == "A" then
        if #cartas_efeitos_ativos > 0 then
            local proxima_carta = cartas_efeitos_ativos[1]
            
            if proxima_carta.id == "A" then
                print("Carta A não pode copiar outra carta A! Efeito ignorado.")
                return
            end
            
            print("Carta A copiando carta: " .. proxima_carta.id)
            
            if proxima_carta.id == "2" then
                criar_tiro_grande()
            elseif proxima_carta.id == "3" then
                atacar_coluna_3()
            elseif proxima_carta.id == "4" then
                tempo_efeito_carta_4 = CARTA4_DURACAO
                imune_dano = true
            elseif proxima_carta.id == "5" then
                VIDA_JOGADOR = math.min(vida_maxima_jogador, VIDA_JOGADOR + (vida_maxima_jogador * CARTA5_CURA_PERCENTUAL))
            elseif proxima_carta.id == "6" then
                ativar_carta_6()
            elseif proxima_carta.id == "7" then
                aplicar_efeito_aleatorio()
            elseif proxima_carta.id == "8" then
                ativar_carta_8()
            elseif proxima_carta.id == "9" then
                ativar_carta_9()
            elseif proxima_carta.id == "10" then
                aplicar_dano_carta_10()
            end
        else
            print("Nenhuma carta disponível para copiar!")
        end
    elseif id_carta == "2" then
        criar_tiro_grande()
    elseif id_carta == "3" then
        atacar_coluna_3()
    elseif id_carta == "4" then
        tempo_efeito_carta_4 = CARTA4_DURACAO
        imune_dano = true
    elseif id_carta == "5" then
        VIDA_JOGADOR = math.min(vida_maxima_jogador, VIDA_JOGADOR + (vida_maxima_jogador * CARTA5_CURA_PERCENTUAL))
    elseif id_carta == "6" then
        ativar_carta_6()
    elseif id_carta == "7" then
        aplicar_efeito_aleatorio()
    elseif id_carta == "8" then
        ativar_carta_8()
    elseif id_carta == "9" then
        ativar_carta_9()
    elseif id_carta == "10" then
        aplicar_dano_carta_10()
    end
end


-- CARTA 2
function criar_tiro_grande()
    if carta2_ativa then
        print("Carta 2 já está em uso!")
        return
    end
    
    carta2_pos_original = {pos_bola[1], pos_bola[2]}
    carta2_pos_visual = {pos_bola[1], math.min(6, pos_bola[2] + CARTA2_AVANCO_VISUAL)}
    carta2_coluna_ataque = math.min(6, pos_bola[2] + CARTA2_AVANCO_ATAQUE)
    
    carta2_linhas_afetadas = {1, 2, 3}
    carta2_ativa = true
    carta2_tempo_restante = CARTA2_DURACAO
    
    local celula_alvo = GRID_CELULAS[pos_bola[1]][carta2_coluna_ataque]
    efeito_espada.ativo = true
    efeito_espada.x = celula_alvo.x
    efeito_espada.y = OFFSET_Y
    efeito_espada.largura = LARGURA_CELULA
    efeito_espada.altura = NUM_LINHAS * ALTURA_CELULA
    efeito_espada.linha_ataque = pos_bola[1]
    efeito_espada.progresso = 0
    efeito_espada.brilho = 0
    efeito_espada.direcao = 1
    efeito_espada.particulas = {}
    
    for i = 1, 15 do
        table.insert(efeito_espada.particulas, {
            x = celula_alvo.x + LARGURA_CELULA/2,
            y = OFFSET_Y + (pos_bola[1] - 1) * ALTURA_CELULA + ALTURA_CELULA/2,
            vx = (math.random() - 0.5) * CARTA2_PARTICULAS_VELOCIDADE,
            vy = (math.random() - 0.5) * CARTA2_PARTICULAS_VELOCIDADE,
            vida = CARTA2_PARTICULAS_VIDA + math.random() * 0.3
        })
    end
    
    local dano_aplicado = false
    
    -- Triângulo
    if VIDA_TRIANGULO > 0 and pos_triangulo[2] == carta2_coluna_ataque then
        VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - CARTA2_DANO)
        dano_aplicado = true
        print("Triângulo atingido pela Carta 2! Dano: " .. CARTA2_DANO)
    end
    
    -- Quadrados (agora são 3 unidades)
    if VIDA_QUADRADO > 0 then
        for _, quad in ipairs(quadrados) do
            if quad.vivo and quad.pos[2] == carta2_coluna_ataque then
                if quadrados_imunes and quadrados_imunes() then
                    print("Carta 2: Quadrado " .. quad.id .. " imune! Dano ignorado.")
                else
                    aplicar_dano_quadrado_especifico(quad, CARTA2_DANO)
                    dano_aplicado = true
                    print("Quadrado " .. quad.id .. " atingido pela Carta 2! Dano: " .. CARTA2_DANO)
                end
            end
        end
    end
    
    -- Bola inimiga
    if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[2] == carta2_coluna_ataque then
        VIDA_BOLA_INIMIGA = math.max(0, VIDA_BOLA_INIMIGA - CARTA2_DANO)
        dano_aplicado = true
        print("Bola inimiga atingida pela Carta 2! Dano: " .. CARTA2_DANO)
    end
    
    if not dano_aplicado then
        print("Nenhum inimigo na coluna de ataque")
    end
    
    print("Carta 2 ativada! Jogador imune por " .. CARTA2_DURACAO .. " segundos")
end


-- CARTA 3
function atacar_coluna_3()
    -- Criar projétil especial da Carta 3
    local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
    
    -- Criar o projétil com velocidade mais lenta para visualização
    local novo_disparo = {
        x = celula_bola.centro_x + tamanho_bola + 10,
        y = celula_bola.centro_y,
        velocidade = CARTA3_VELOCIDADE,
        tipo = 'carta3',
        dano = CARTA3_DANO,
        linha_origem = pos_bola[1],
        pode_acertar_multiplos = true,
        inimigos_acertados = {}
    }
    
    table.insert(disparos, novo_disparo)
    
    print("Carta 3: Projétil criado na posição (" .. novo_disparo.x .. ", " .. novo_disparo.y .. ")")
    print("Carta 3: Linha de origem: " .. pos_bola[1])
    print("Carta 3: Total de projéteis agora: " .. #disparos)
end

-- CARTA 6
function ativar_carta_6()
    if carta6_ativa then
        print("Carta 6 já está em uso!")
        return
    end
    
    carta6_ativa = true
    carta6_tempo_restante = CARTA6_DURACAO
    carta6_inimigos_atingidos = {}
    carta6_frame_animacao = 0
    
    local colunas_afetadas = CARTA6_COLUNAS
    
    -- Configurar efeito visual horizontal
    local primeira_celula = GRID_CELULAS[1][4]
    local ultima_celula = GRID_CELULAS[3][5]
    
    efeito_onda_horizontal.ativo = true
    efeito_onda_horizontal.x = primeira_celula.x
    efeito_onda_horizontal.y = OFFSET_Y
    efeito_onda_horizontal.largura = (ultima_celula.x + ultima_celula.width) - primeira_celula.x
    efeito_onda_horizontal.altura = NUM_LINHAS * ALTURA_CELULA
    efeito_onda_horizontal.progresso = 0
    efeito_onda_horizontal.direcao = CARTA6_DIRECAO
    efeito_onda_horizontal.brilho = 0
    efeito_onda_horizontal.colunas = colunas_afetadas
    efeito_onda_horizontal.particulas = {}
    
    -- Criar partículas iniciais
    for i = 1, CARTA6_NUM_PARTICULAS do
        table.insert(efeito_onda_horizontal.particulas, {
            x = primeira_celula.x + math.random() * efeito_onda_horizontal.largura,
            y = OFFSET_Y + math.random() * (NUM_LINHAS * ALTURA_CELULA),
            vx = (math.random() - 0.5) * CARTA6_PARTICULAS_VELOCIDADE,
            vy = (math.random() - 0.5) * CARTA6_PARTICULAS_VELOCIDADE,
            vida = CARTA6_PARTICULAS_VIDA + math.random() * 0.3
        })
    end
    
    -- Processa triângulo
    if VIDA_TRIANGULO > 0 then
        local coluna = pos_triangulo[2]
        
        for _, coluna_afetada in ipairs(colunas_afetadas) do
            if coluna == coluna_afetada then
                local nova_coluna = math.min(6, coluna + 1)
                
                VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - CARTA6_DANO)
                
                if nova_coluna ~= coluna then
                    pos_triangulo[2] = nova_coluna
                    print("Triângulo empurrado para coluna " .. nova_coluna)
                end
                
                table.insert(carta6_inimigos_atingidos, {
                    tipo = "triangulo",
                    tempo_bloqueio = CARTA6_BLOQUEIO
                })
                
                break
            end
        end
    end
    
    -- Processa quadrados
    if VIDA_QUADRADO > 0 then
        for _, quad in ipairs(quadrados) do
            if quad.vivo then
                local coluna = quad.pos[2]
                
                for _, coluna_afetada in ipairs(colunas_afetadas) do
                    if coluna == coluna_afetada then
                        local nova_coluna = math.min(6, coluna + 1)
                        
                        if quadrados_imunes and quadrados_imunes() then
                            print("Carta 6: Quadrado " .. quad.id .. " imune! Dano ignorado.")
                        else
                            aplicar_dano_quadrado_especifico(quad, CARTA6_DANO)
                        end
                        
                        if nova_coluna ~= coluna then
                            quad.pos[2] = nova_coluna
                            print("Quadrado " .. quad.id .. " empurrado para coluna " .. nova_coluna)
                        end
                        
                        table.insert(carta6_inimigos_atingidos, {
                            tipo = "quadrado_" .. quad.id,
                            tempo_bloqueio = CARTA6_BLOQUEIO
                        })
                        
                        break
                    end
                end
            end
        end
    end
    
    -- Processa bola inimiga
    if VIDA_BOLA_INIMIGA > 0 then
        local coluna = pos_bola_inimiga[2]
        
        for _, coluna_afetada in ipairs(colunas_afetadas) do
            if coluna == coluna_afetada then
                local nova_coluna = math.min(6, coluna + 1)
                
                VIDA_BOLA_INIMIGA = math.max(0, VIDA_BOLA_INIMIGA - CARTA6_DANO)
                
                if nova_coluna ~= coluna then
                    pos_bola_inimiga[2] = nova_coluna
                    print("Bola inimiga empurrada para coluna " .. nova_coluna)
                end
                
                table.insert(carta6_inimigos_atingidos, {
                    tipo = "bola_inimiga",
                    tempo_bloqueio = CARTA6_BLOQUEIO
                })
                
                break
            end
        end
    end
    
    -- Aplica bloqueio de movimento aos inimigos atingidos
    if #carta6_inimigos_atingidos > 0 then
        inimigos_bloqueados = true
        tempo_bloqueio = CARTA6_BLOQUEIO
    end
    
    print("Carta 6 ativada! Inimigos nas colunas " .. CARTA6_COLUNAS[1] .. "-" .. CARTA6_COLUNAS[2] .. " empurrados para direita")
end

-- CARTA 7 - EFEITO ALEATÓRIO
function aplicar_efeito_aleatorio()
    local numero_sorteado = love.math.random(1, 7)
    print("Carta 7 - Número sorteado: " .. numero_sorteado)
    
    -- Ativar efeito visual (mostra o número na tela)
    ativar_efeito_carta7(numero_sorteado)
    
    -- APENAS o número 7 tem efeito (encher a barra)
    if numero_sorteado == 7 then
        print("Carta 7 - NÚMERO 7: Barra de customização será completada!")
    else
        print("Carta 7 - Número " .. numero_sorteado .. ": Sem efeito (apenas visual)")
    end
end


-- CARTA 9
function ativar_carta_9()
    if carta9_ativa then
        print("Carta 9 já está em uso!")
        return
    end
    
    carta9_ativa = true
    carta9_tempo_restante = CARTA9_DURACAO
    carta9_inimigos_atingidos = {}
    carta9_frame_animacao = 0
    
    local colunas_afetadas = CARTA9_COLUNAS
    
    -- Configurar efeito visual horizontal
    local primeira_celula = GRID_CELULAS[1][5]
    local ultima_celula = GRID_CELULAS[3][6]
    
    efeito_onda_horizontal.ativo = true
    efeito_onda_horizontal.x = primeira_celula.x
    efeito_onda_horizontal.y = OFFSET_Y
    efeito_onda_horizontal.largura = (ultima_celula.x + ultima_celula.width) - primeira_celula.x
    efeito_onda_horizontal.altura = NUM_LINHAS * ALTURA_CELULA
    efeito_onda_horizontal.progresso = 0
    efeito_onda_horizontal.direcao = CARTA9_DIRECAO
    efeito_onda_horizontal.brilho = 0
    efeito_onda_horizontal.colunas = colunas_afetadas
    efeito_onda_horizontal.particulas = {}
    
    -- Criar partículas iniciais
    for i = 1, CARTA6_NUM_PARTICULAS do
        table.insert(efeito_onda_horizontal.particulas, {
            x = primeira_celula.x + math.random() * efeito_onda_horizontal.largura,
            y = OFFSET_Y + math.random() * (NUM_LINHAS * ALTURA_CELULA),
            vx = (math.random() - 0.5) * CARTA9_PARTICULAS_VELOCIDADE,
            vy = (math.random() - 0.5) * CARTA9_PARTICULAS_VELOCIDADE,
            vida = CARTA9_PARTICULAS_VIDA + math.random() * 0.3
        })
    end
    
    -- Processa triângulo
    if VIDA_TRIANGULO > 0 then
        local coluna = pos_triangulo[2]
        
        for _, coluna_afetada in ipairs(colunas_afetadas) do
            if coluna == coluna_afetada then
                local nova_coluna = math.max(1, coluna - 1)
                
                VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - CARTA9_DANO)
                
                if nova_coluna ~= coluna then
                    pos_triangulo[2] = nova_coluna
                    print("Triângulo puxado para coluna " .. nova_coluna)
                end
                
                table.insert(carta9_inimigos_atingidos, {
                    tipo = "triangulo",
                    tempo_bloqueio = CARTA9_BLOQUEIO
                })
                
                break
            end
        end
    end
    
    -- Processa quadrados
    if VIDA_QUADRADO > 0 then
        for _, quad in ipairs(quadrados) do
            if quad.vivo then
                local coluna = quad.pos[2]
                
                for _, coluna_afetada in ipairs(colunas_afetadas) do
                    if coluna == coluna_afetada then
                        local nova_coluna = math.max(4, coluna - 1)
                        
                        if quadrados_imunes and quadrados_imunes() then
                            print("Carta 9: Quadrado " .. quad.id .. " imune! Dano ignorado.")
                        else
                            aplicar_dano_quadrado_especifico(quad, CARTA9_DANO)
                        end
                        
                        if nova_coluna ~= coluna then
                            quad.pos[2] = nova_coluna
                            print("Quadrado " .. quad.id .. " puxado para coluna " .. nova_coluna)
                        end
                        
                        table.insert(carta9_inimigos_atingidos, {
                            tipo = "quadrado_" .. quad.id,
                            tempo_bloqueio = CARTA9_BLOQUEIO
                        })
                        
                        break
                    end
                end
            end
        end
    end
    
    -- Processa bola inimiga
    if VIDA_BOLA_INIMIGA > 0 then
        local coluna = pos_bola_inimiga[2]
        
        for _, coluna_afetada in ipairs(colunas_afetadas) do
            if coluna == coluna_afetada then
                local nova_coluna = math.max(1, coluna - 1)
                
                VIDA_BOLA_INIMIGA = math.max(0, VIDA_BOLA_INIMIGA - CARTA9_DANO)
                
                if nova_coluna ~= coluna then
                    pos_bola_inimiga[2] = nova_coluna
                    print("Bola inimiga puxada para coluna " .. nova_coluna)
                end
                
                table.insert(carta9_inimigos_atingidos, {
                    tipo = "bola_inimiga",
                    tempo_bloqueio = CARTA9_BLOQUEIO
                })
                
                break
            end
        end
    end
    
    -- Aplica bloqueio de movimento aos inimigos atingidos
    if #carta9_inimigos_atingidos > 0 then
        inimigos_bloqueados = true
        tempo_bloqueio = CARTA9_BLOQUEIO
    end
    
    print("Carta 9 ativada! Inimigos nas colunas " .. CARTA9_COLUNAS[1] .. "-" .. CARTA9_COLUNAS[2] .. " puxados para esquerda")
end


-- CARTA 8 
function ativar_carta_8()
    if carta8_ativa then
        print("Carta 8 já está em uso!")
        return
    end
    
    carta8_ativa = true
    carta8_tempo_restante = CARTA8_DURACAO
    carta8_linha_origem = pos_bola[1]
    carta8_inimigos_atingidos = {}
    carta8_projeteis = {}
    
    local celula_origem = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
    
    -- Coluna alvo (última coluna inimiga)
    local coluna_alvo = 6  -- Sempre a última coluna
    
    -- Cria projétil para cima (se não estiver na linha 1)
    if pos_bola[1] > 1 then
        local celula_alvo_cima = GRID_CELULAS[pos_bola[1] - 1][coluna_alvo]
        local proj = {
            x = celula_origem.centro_x,
            y = celula_origem.centro_y,
            x_inicio = celula_origem.centro_x,
            y_inicio = celula_origem.centro_y,
            x_alvo = celula_alvo_cima.centro_x,
            y_alvo = celula_alvo_cima.centro_y,
            progresso = 0,
            velocidade = CARTA8_VELOCIDADE,
            ativo = true,
            linha_alvo = pos_bola[1] - 1,
            coluna_alvo = coluna_alvo
        }
        table.insert(carta8_projeteis, proj)
        print("Carta 8: Projétil criado para linha " .. (pos_bola[1] - 1))
    end
    
    -- Cria projétil para baixo (se não estiver na linha 3)
    if pos_bola[1] < 3 then
        local celula_alvo_baixo = GRID_CELULAS[pos_bola[1] + 1][coluna_alvo]
        local proj = {
            x = celula_origem.centro_x,
            y = celula_origem.centro_y,
            x_inicio = celula_origem.centro_x,
            y_inicio = celula_origem.centro_y,
            x_alvo = celula_alvo_baixo.centro_x,
            y_alvo = celula_alvo_baixo.centro_y,
            progresso = 0,
            velocidade = CARTA8_VELOCIDADE,
            ativo = true,
            linha_alvo = pos_bola[1] + 1,
            coluna_alvo = coluna_alvo
        }
        table.insert(carta8_projeteis, proj)
        print("Carta 8: Projétil criado para linha " .. (pos_bola[1] + 1))
    end
    
    print("Carta 8 ativada! Projéteis lançados para coluna " .. coluna_alvo)
end

function atualizar_carta8(dt)
    if carta8_ativa then
        carta8_tempo_restante = carta8_tempo_restante - dt
        
        -- Atualiza projéteis
        for i = #carta8_projeteis, 1, -1 do
            local proj = carta8_projeteis[i]
            if proj.ativo then
                -- Avança o progresso
                proj.progresso = proj.progresso + dt * proj.velocidade
                
                -- Calcula posição atual (interpolação linear)
                proj.x = proj.x_inicio + (proj.x_alvo - proj.x_inicio) * proj.progresso
                proj.y = proj.y_inicio + (proj.y_alvo - proj.y_inicio) * proj.progresso
                
                -- Quando atinge o alvo
                if proj.progresso >= 1 then
                    proj.ativo = false
                    
                    -- Quando o projétil atinge o alvo, puxa inimigos para a linha de origem
                    local linha_origem = carta8_linha_origem
                    local coluna_alvo = proj.coluna_alvo
                    
                    -- Verifica inimigos na coluna alvo
                    local inimigo_atingido = false
                    
                    -- Triângulo
                    if VIDA_TRIANGULO > 0 and pos_triangulo[2] == coluna_alvo then
                        if pos_triangulo[1] ~= linha_origem then
                            pos_triangulo[1] = linha_origem
                            print("Carta 8: Triângulo puxado para linha " .. linha_origem)
                        end
                        VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - CARTA8_DANO)
                        inimigo_atingido = true
                        
                        table.insert(carta8_inimigos_atingidos, {
                            tipo = "triangulo",
                            tempo_bloqueio = CARTA8_BLOQUEIO
                        })
                        print("Carta 8: Triângulo sofreu " .. CARTA8_DANO .. " de dano!")
                    end
                    
                    -- Quadrados
                    if VIDA_QUADRADO > 0 then
                        for _, quad in ipairs(quadrados) do
                            if quad.vivo and quad.pos[2] == coluna_alvo then
                                if quadrados_imunes and quadrados_imunes() then
                                    print("Carta 8: Quadrado " .. quad.id .. " imune! Dano ignorado.")
                                else
                                    if quad.pos[1] ~= linha_origem then
                                        quad.pos[1] = linha_origem
                                        print("Carta 8: Quadrado " .. quad.id .. " puxado para linha " .. linha_origem)
                                    end
                                    aplicar_dano_quadrado_especifico(quad, CARTA8_DANO)
                                    inimigo_atingido = true
                                    
                                    table.insert(carta8_inimigos_atingidos, {
                                        tipo = "quadrado_" .. quad.id,
                                        tempo_bloqueio = CARTA8_BLOQUEIO
                                    })
                                    print("Carta 8: Quadrado " .. quad.id .. " sofreu " .. CARTA8_DANO .. " de dano!")
                                end
                            end
                        end
                    end
                    
                    -- Bola inimiga
                    if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[2] == coluna_alvo then
                        if pos_bola_inimiga[1] ~= linha_origem then
                            pos_bola_inimiga[1] = linha_origem
                            print("Carta 8: Bola inimiga puxada para linha " .. linha_origem)
                        end
                        VIDA_BOLA_INIMIGA = math.max(0, VIDA_BOLA_INIMIGA - CARTA8_DANO)
                        inimigo_atingido = true
                        
                        table.insert(carta8_inimigos_atingidos, {
                            tipo = "bola_inimiga",
                            tempo_bloqueio = CARTA8_BLOQUEIO
                        })
                        print("Carta 8: Bola inimiga sofreu " .. CARTA8_DANO .. " de dano!")
                    end
                    
                    if not inimigo_atingido then
                        print("Carta 8: Nenhum inimigo na coluna " .. coluna_alvo)
                    end
                end
            else
                table.remove(carta8_projeteis, i)
            end
        end
        
        -- Aplica bloqueio aos inimigos atingidos
        if #carta8_inimigos_atingidos > 0 then
            inimigos_bloqueados = true
            tempo_bloqueio = CARTA8_BLOQUEIO
        end
        
        if carta8_tempo_restante <= 0 then
            carta8_ativa = false
            carta8_projeteis = {}
        end
    end
end


-- CARTA 10
function aplicar_dano_carta_10()
    -- Conta cartas únicas usadas
    local cartas_diferentes = {}
    for _, carta in ipairs(cartas_usadas) do
        if not cartas_diferentes[carta.id] then
            cartas_diferentes[carta.id] = true
        end
    end
    
    local x = 0
    local cartas_unicas = {}
    for id, _ in pairs(cartas_diferentes) do
        x = x + 1
        table.insert(cartas_unicas, id)
    end
    
    local dano = x * CARTA10_MULTIPLICADOR
    
    print("Carta 10 - Dano calculado: " .. dano .. " (x=" .. x .. ")")
    
    -- Ativar efeito visual com pausa (NÃO aplica dano ainda)
    ativar_efeito_carta10(dano, cartas_unicas)
end


-- ATUALIZAÇÕES DAS CARTAS
function atualizar_cartas(dt)
    -- Atualiza todas as cartas ativas
    atualizar_carta2(dt)
    atualizar_carta6(dt)
    atualizar_carta8(dt)
    atualizar_carta9(dt)
    
    if imune_dano then
        tempo_efeito_carta_4 = tempo_efeito_carta_4 - dt
        if tempo_efeito_carta_4 <= 0 then
            imune_dano = false
        end
    end

    if tempo_mostrar_carta > 0 then
        tempo_mostrar_carta = tempo_mostrar_carta - dt
        if tempo_mostrar_carta < 0 then
            tempo_mostrar_carta = 0
            ultima_carta_usada = nil
        end
    end
    
    for _, carta in ipairs(cartas_selecionadas) do
        if carta.tempo_usada then
            carta.tempo_usada = carta.tempo_usada - dt
            if carta.tempo_usada <= 0 then
                carta.cor_usada = false
                carta.tempo_usada = nil
            end
        end
    end
    
    if tempo_bloqueio > 0 then
        tempo_bloqueio = tempo_bloqueio - dt
        if tempo_bloqueio <= 0 then
            bloqueado_movimento = false
            bloqueado_ataque = false
            inimigos_bloqueados = false
        end
    end
    
    for i = #cartas_efeitos_ativos, 1, -1 do
        local efeito = cartas_efeitos_ativos[i]
        if efeito.tempo then
            efeito.tempo = efeito.tempo + dt
            if efeito.tempo >= efeito.duracao then
                table.remove(cartas_efeitos_ativos, i)
            end
        end
    end
end

function atualizar_carta2(dt)
    if carta2_ativa then
        carta2_tempo_restante = carta2_tempo_restante - dt
        carta2_frame_animacao = carta2_frame_animacao + dt * CARTA2_FRAME_ANIMACAO
        
        if efeito_espada.ativo then
            efeito_espada.progresso = math.min(1, efeito_espada.progresso + dt * CARTA2_PROGRESSO_VELOCIDADE)
            efeito_espada.brilho = 0.5 + math.sin(carta2_frame_animacao * CARTA2_BRILHO_VELOCIDADE) * 0.5
            
            for i = #efeito_espada.particulas, 1, -1 do
                local p = efeito_espada.particulas[i]
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                p.vida = p.vida - dt * CARTA2_PARTICULAS_DESAPARECE
                
                if p.vida <= 0 then
                    table.remove(efeito_espada.particulas, i)
                end
            end
            
            if math.random() < dt * CARTA2_NOVAS_PARTICULAS_CHANCE and carta2_pos_original then
                local celula_alvo = GRID_CELULAS[carta2_pos_original[1]][carta2_coluna_ataque]
                if celula_alvo then
                    for i = 1, 5 do
                        table.insert(efeito_espada.particulas, {
                            x = celula_alvo.x + math.random() * LARGURA_CELULA,
                            y = OFFSET_Y + (carta2_pos_original[1] - 1) * ALTURA_CELULA + math.random() * ALTURA_CELULA,
                            vx = (math.random() - 0.5) * CARTA2_NOVAS_PARTICULAS_VEL,
                            vy = (math.random() - 0.5) * CARTA2_NOVAS_PARTICULAS_VEL,
                            vida = 0.2 + math.random() * 0.2
                        })
                    end
                end
            end
        end
        
        if carta2_tempo_restante <= 0 then
            carta2_ativa = false
            carta2_pos_original = nil
            carta2_pos_visual = nil
            carta2_coluna_ataque = nil
            efeito_espada.ativo = false
            efeito_espada.particulas = {}
        end
    end
end

function atualizar_carta6(dt)
    if carta6_ativa then
        carta6_tempo_restante = carta6_tempo_restante - dt
        carta6_frame_animacao = carta6_frame_animacao + dt * CARTA6_FRAME_ANIMACAO
        
        if efeito_onda_horizontal.ativo then
            efeito_onda_horizontal.progresso = math.min(1, efeito_onda_horizontal.progresso + dt * CARTA6_PROGRESSO_VELOCIDADE)
            efeito_onda_horizontal.brilho = 0.5 + math.sin(carta6_frame_animacao * CARTA6_BRILHO_VELOCIDADE) * 0.5
            
            for i = #efeito_onda_horizontal.particulas, 1, -1 do
                local p = efeito_onda_horizontal.particulas[i]
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                p.vida = p.vida - dt * 4
                
                if p.vida <= 0 then
                    table.remove(efeito_onda_horizontal.particulas, i)
                end
            end
            
            if math.random() < dt * 30 then
                for i = 1, 5 do
                    table.insert(efeito_onda_horizontal.particulas, {
                        x = efeito_onda_horizontal.x + math.random() * efeito_onda_horizontal.largura,
                        y = efeito_onda_horizontal.y + math.random() * efeito_onda_horizontal.altura,
                        vx = (math.random() - 0.5) * 500,
                        vy = (math.random() - 0.5) * 500,
                        vida = 0.2 + math.random() * 0.2
                    })
                end
            end
        end
        
        if carta6_tempo_restante <= 0 then
            carta6_ativa = false
            efeito_onda_horizontal.ativo = false
            efeito_onda_horizontal.particulas = {}
        end
    end
end

function atualizar_carta9(dt)
    if carta9_ativa then
        carta9_tempo_restante = carta9_tempo_restante - dt
        carta9_frame_animacao = carta9_frame_animacao + dt * CARTA9_FRAME_ANIMACAO
        
        if efeito_onda_horizontal.ativo then
            efeito_onda_horizontal.progresso = math.min(1, efeito_onda_horizontal.progresso + dt * CARTA9_PROGRESSO_VELOCIDADE)
            efeito_onda_horizontal.brilho = 0.5 + math.sin(carta9_frame_animacao * CARTA9_BRILHO_VELOCIDADE) * 0.5
            
            for i = #efeito_onda_horizontal.particulas, 1, -1 do
                local p = efeito_onda_horizontal.particulas[i]
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                p.vida = p.vida - dt * 4
                
                if p.vida <= 0 then
                    table.remove(efeito_onda_horizontal.particulas, i)
                end
            end
            
            if math.random() < dt * 30 then
                for i = 1, 5 do
                    table.insert(efeito_onda_horizontal.particulas, {
                        x = efeito_onda_horizontal.x + math.random() * efeito_onda_horizontal.largura,
                        y = efeito_onda_horizontal.y + math.random() * efeito_onda_horizontal.altura,
                        vx = (math.random() - 0.5) * 500,
                        vy = (math.random() - 0.5) * 500,
                        vida = 0.2 + math.random() * 0.2
                    })
                end
            end
        end
        
        if carta9_tempo_restante <= 0 then
            carta9_ativa = false
            efeito_onda_horizontal.ativo = false
            efeito_onda_horizontal.particulas = {}
        end
    end
end

function jogador_imune_carta2()
    return carta2_ativa
end


-- FUNÇÕES DE DESENHO
function desenhar_efeito_carta2()
    if not carta2_ativa or not efeito_espada.ativo or not carta2_pos_original then return end
    
    local x = efeito_espada.x
    local y = OFFSET_Y
    local largura = efeito_espada.largura
    local altura = efeito_espada.altura
    local progresso = efeito_espada.progresso
    local brilho = efeito_espada.brilho
    
    local linha_jogador = carta2_pos_original[1]
    local y_linha_jogador = OFFSET_Y + (linha_jogador - 1) * ALTURA_CELULA
    
    local largura_visivel = largura * math.sin(progresso * math.pi)
    if largura_visivel < 0 then largura_visivel = 0 end
    
    local x_inicio = x + (largura - largura_visivel) / 2
    
    -- Lâmina principal
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.9 * brilho)
    love.graphics.rectangle("fill", x_inicio, y_linha_jogador, largura_visivel, ALTURA_CELULA)
    
    -- Versões mais transparentes nas outras linhas
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.3 * brilho)
    for l = 1, NUM_LINHAS do
        if l ~= linha_jogador then
            local y_linha = OFFSET_Y + (l - 1) * ALTURA_CELULA
            love.graphics.rectangle("fill", x_inicio, y_linha, largura_visivel, ALTURA_CELULA)
        end
    end
    
    -- Borda brilhante
    love.graphics.setColor(1, 1, 1, 0.9 * brilho)
    love.graphics.setLineWidth(4)
    for l = 1, NUM_LINHAS do
        local y_linha = OFFSET_Y + (l - 1) * ALTURA_CELULA
        love.graphics.rectangle("line", x_inicio, y_linha, largura_visivel, ALTURA_CELULA)
    end
    
    -- Linhas de energia
    love.graphics.setLineWidth(2)
    local num_linhas = 10
    for i = 0, num_linhas - 1 do
        local offset = (carta2_frame_animacao * 300 + i * 20) % (ALTURA_CELULA + 50) - 50
        local y_linha_energia = y_linha_jogador + offset
        
        love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.7 * brilho)
        love.graphics.line(
            x_inicio, y_linha_energia,
            x_inicio + largura_visivel, y_linha_energia + 40
        )
    end
    
    -- Brilho pulsante
    local raio_pulso = 20 + math.sin(carta2_frame_animacao * 30) * 10
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.5 * brilho)
    love.graphics.circle("fill", x + largura/2, y_linha_jogador + ALTURA_CELULA/2, raio_pulso)
    
    -- Partículas
    for _, p in ipairs(efeito_espada.particulas) do
        love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], p.vida * brilho)
        love.graphics.circle("fill", p.x, p.y, 4)
    end
    
    -- Texto
    if progresso > 0.2 and progresso < 0.6 then
        local fonte_temp = fonte_instrucoes or love.graphics.newFont(48)
        love.graphics.setFont(fonte_temp)
        love.graphics.setColor(1, 1, 1, brilho)
        local texto = CARTA2_TEXTO_ATIVO
        local largura_texto = fonte_temp:getWidth(texto)
        love.graphics.print(texto, 
            x + largura/2 - largura_texto/2,
            y_linha_jogador + ALTURA_CELULA/2 - fonte_temp:getHeight()/2
        )
    end
end

function desenhar_jogador_carta2()
    if not carta2_ativa or not carta2_pos_original then return end
    
    local celula_original = GRID_CELULAS[carta2_pos_original[1]][carta2_pos_original[2]]
    local x_orig, y_orig = celula_original.centro_x, celula_original.centro_y
    
    -- Contorno da hitbox original
    love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.9)
    love.graphics.setLineWidth(4)
    love.graphics.circle("line", x_orig, y_orig, tamanho_bola + 10)
    
    -- Sombra
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.circle("fill", x_orig + 3, y_orig + 3, tamanho_bola)
    
    -- Bola translúcida
    local opacidade_orig = 0.3 + math.sin(carta2_frame_animacao * 10) * 0.1
    love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_orig)
    love.graphics.circle("fill", x_orig, y_orig, tamanho_bola - 3)
    
    -- Centro
    love.graphics.setColor(1, 1, 1, opacidade_orig * 0.8)
    love.graphics.circle("fill", 
        x_orig - tamanho_bola/4, y_orig - tamanho_bola/4,
        tamanho_bola/4
    )
    
    -- Efeito fantasma
    for i = 1, 5 do
        local offset = math.sin(carta2_frame_animacao * 12 + i) * 10
        love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_orig * 0.2)
        love.graphics.circle("fill", x_orig + offset, y_orig - offset, tamanho_bola - 8)
    end
    
    -- Esfera fantasma
    if carta2_pos_visual then
        local celula_visual = GRID_CELULAS[carta2_pos_visual[1]][carta2_pos_visual[2]]
        if celula_visual then
            local x_vis, y_vis = celula_visual.centro_x, celula_visual.centro_y
            local opacidade_vis = 0.9 + math.sin(carta2_frame_animacao * 15) * 0.1
            
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_vis * 0.5)
            love.graphics.circle("fill", x_vis, y_vis, tamanho_bola + 12)
            
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_vis)
            love.graphics.circle("fill", x_vis, y_vis, tamanho_bola - 2)
            
            love.graphics.setColor(1, 1, 1, opacidade_vis)
            love.graphics.circle("fill", 
                x_vis - tamanho_bola/4, y_vis - tamanho_bola/4,
                tamanho_bola/4
            )
            
            -- Linha de teletransporte
            love.graphics.setLineWidth(2)
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade_vis * 0.6)
            love.graphics.line(x_orig, y_orig, x_vis, y_vis)
            
            -- Setas
            local angulo = math.atan2(y_vis - y_orig, x_vis - x_orig)
            for i = 1, 4 do
                local t = i / 5
                local px = x_orig + (x_vis - x_orig) * t
                local py = y_orig + (y_vis - y_orig) * t
                
                love.graphics.push()
                love.graphics.translate(px, py)
                love.graphics.rotate(angulo)
                love.graphics.polygon("fill", 
                    0, 0,
                    -12, -6,
                    -12, 6
                )
                love.graphics.pop()
            end
            
            -- Texto "FANTASMA"
            local fonte_temp = fonte_instrucoes or love.graphics.newFont(18)
            love.graphics.setFont(fonte_temp)
            love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade_vis)
            local texto = "FANTASMA"
            love.graphics.print(texto, 
                x_vis - fonte_temp:getWidth(texto)/2,
                y_vis - tamanho_bola - 25
            )
        end
    end
    
    -- Texto "IMUNE"
    local fonte_temp = fonte_instrucoes or love.graphics.newFont(16)
    love.graphics.setFont(fonte_temp)
    love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.8)
    local texto = "IMUNE"
    love.graphics.print(texto, 
        x_orig - fonte_temp:getWidth(texto)/2,
        y_orig - tamanho_bola - 20
    )
    
    -- Indicador de ataque
    if carta2_coluna_ataque and carta2_pos_original then
        local celula_ataque = GRID_CELULAS[carta2_pos_original[1]][carta2_coluna_ataque]
        if celula_ataque then
            love.graphics.setColor(VERMELHO[1], VERMELHO[2], VERMELHO[3], 0.8)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", 
                celula_ataque.x, celula_ataque.y, 
                celula_ataque.width, celula_ataque.height
            )
            
            love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(14))
            love.graphics.print("ATAQUE", 
                celula_ataque.x + 10, 
                celula_ataque.y + 10
            )
        end
    end
end

function desenhar_efeito_horizontal()
    if not efeito_onda_horizontal.ativo then return end
    
    local x = efeito_onda_horizontal.x
    local y = efeito_onda_horizontal.y
    local largura = efeito_onda_horizontal.largura
    local altura = efeito_onda_horizontal.altura
    local progresso = efeito_onda_horizontal.progresso
    local brilho = efeito_onda_horizontal.brilho
    local direcao = efeito_onda_horizontal.direcao
    
    -- Animação de onda horizontal
    local altura_visivel = altura * math.sin(progresso * math.pi)
    if altura_visivel < 0 then altura_visivel = 0 end
    
    local y_inicio = y + (altura - altura_visivel) / 2
    
    -- Onda principal
    love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.7 * brilho)
    love.graphics.rectangle("fill", x, y_inicio, largura, altura_visivel)
    
    -- Borda brilhante
    love.graphics.setColor(1, 1, 1, 0.8 * brilho)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", x, y_inicio, largura, altura_visivel)
    
    -- Linhas de energia horizontais
    love.graphics.setLineWidth(2)
    local num_linhas = 10
    for i = 0, num_linhas - 1 do
        local offset = (carta6_frame_animacao * 200 + i * 30) % (largura + 50) - 50
        local x_linha = x + offset
        
        love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.6 * brilho)
        love.graphics.line(
            x_linha, y_inicio,
            x_linha + 40, y_inicio + altura_visivel
        )
    end
    
    -- Setas indicando direção
    local num_setas = 5
    for i = 1, num_setas do
        local t = i / (num_setas + 1)
        local x_seta = x + largura * t
        local y_seta = y_inicio + altura_visivel / 2
        
        love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.8 * brilho)
        
        if direcao == 1 then  -- direita
            love.graphics.polygon("fill", 
                x_seta, y_seta,
                x_seta - 15, y_seta - 8,
                x_seta - 15, y_seta + 8
            )
        else  -- esquerda
            love.graphics.polygon("fill", 
                x_seta, y_seta,
                x_seta + 15, y_seta - 8,
                x_seta + 15, y_seta + 8
            )
        end
    end
    
    -- Partículas
    for _, p in ipairs(efeito_onda_horizontal.particulas) do
        love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], p.vida * brilho)
        love.graphics.circle("fill", p.x, p.y, 3)
    end
    
    -- Texto
    if progresso > 0.2 and progresso < 0.6 then
        local fonte_temp = fonte_instrucoes or love.graphics.newFont(48)
        love.graphics.setFont(fonte_temp)
        love.graphics.setColor(1, 1, 1, brilho)
        local texto = CARTA6_TEXTO_ATIVO
        local largura_texto = fonte_temp:getWidth(texto)
        love.graphics.print(texto, 
            x + largura/2 - largura_texto/2,
            y + altura/2 - fonte_temp:getHeight()/2
        )
    end
end

function desenhar_nome_carta_usada()
    if ultima_carta_usada and tempo_mostrar_carta > 0 then
        local fonte_temp = fonte_instrucoes or love.graphics.newFont(24)
        love.graphics.setFont(fonte_temp)
        
        local texto = "Carta usada: " .. ultima_carta_usada
        local x = OFFSET_X_VIEWPORT + (JOGO_LARGURA / 2) - (fonte_temp:getWidth(texto) / 2)
        local y = OFFSET_Y_VIEWPORT - 50
        
        local opacidade = math.min(1.0, tempo_mostrar_carta * 2)
        
        love.graphics.setColor(0, 0, 0, 0.7 * opacidade)
        love.graphics.rectangle("fill", x - 15, y - 10, 
            fonte_temp:getWidth(texto) + 30, 
            fonte_temp:getHeight() + 20, 8)
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 15, y - 10, 
            fonte_temp:getWidth(texto) + 30, 
            fonte_temp:getHeight() + 20, 8)
        
        love.graphics.setColor(1, 1, 1, opacidade)
        love.graphics.print(texto, x, y)
        
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade * 0.8)
        love.graphics.circle("fill", x - 25, y + fonte_temp:getHeight()/2, 8)
        love.graphics.setColor(1, 1, 1, opacidade)
        love.graphics.circle("fill", x - 25, y + fonte_temp:getHeight()/2, 5)
    end
end

function resetar_cartas_para_preparacao()
    print("=== RESETANDO CARTAS PARA PRÓXIMA PREPARAÇÃO ===")
    
    -- Criar uma lista com TODAS as cartas que precisam voltar ao deck
    local cartas_para_devolver = {}
    
    -- Adicionar cartas selecionadas
    for _, carta in ipairs(cartas_selecionadas) do
        table.insert(cartas_para_devolver, carta)
        print("  Devolvendo carta selecionada: " .. carta.id)
    end
    
    -- Adicionar cartas na mão atual
    for _, carta in ipairs(mao_atual) do
        table.insert(cartas_para_devolver, carta)
        print("  Devolvendo carta da mão: " .. carta.id)
    end
    
    -- Adicionar cartas não selecionadas da fase anterior
    for _, carta in ipairs(cartas_nao_selecionadas) do
        table.insert(cartas_para_devolver, carta)
        print("  Devolvendo carta não selecionada: " .. carta.id)
    end
    
    -- Adicionar cartas usadas (se houver)
    for _, carta in ipairs(cartas_usadas) do
        -- Criar uma nova carta baseada na usada (para não manter referências)
        local nova_carta = {
            id = carta.id,
            custo = carta.custo,
            descricao = carta.descricao,
            usada = false,
            carta_original = true
        }
        table.insert(cartas_para_devolver, nova_carta)
        print("  Devolvendo carta usada: " .. carta.id)
    end
    
    -- Limpar todas as listas
    cartas_selecionadas = {}
    mao_atual = {}
    cartas_nao_selecionadas = {}
    cartas_usadas = {}
    cartas_efeitos_ativos = {}
    custo_atual = 0
    
    -- Devolver todas as cartas ao deck
    for _, carta in ipairs(cartas_para_devolver) do
        table.insert(deck_atual, carta)
    end
    
    print("Total de cartas devolvidas ao deck: " .. #cartas_para_devolver)
    print("Tamanho do deck após devolução: " .. #deck_atual)
    
    -- Embaralhar o deck
    for i = #deck_atual, 2, -1 do
        local j = love.math.random(i)
        deck_atual[i], deck_atual[j] = deck_atual[j], deck_atual[i]
    end
    
    print("Deck embaralhado!")
    
    -- Resetar variáveis de seleção
    carta_selecionada = 1
    tipo_selecao = "mao"
    linha_selecionada = 1
    
    print("=== FIM DO RESET DE CARTAS ===")
end
function remover_ultima_carta_selecionada()
    if #cartas_selecionadas == 0 then
        print("Nenhuma carta selecionada para remover!")
        return false
    end
    
    local ultima_carta = cartas_selecionadas[#cartas_selecionadas]
    table.insert(mao_atual, ultima_carta)
    table.remove(cartas_selecionadas, #cartas_selecionadas)
    custo_atual = custo_atual - ultima_carta.custo
    
    print("Última carta (" .. ultima_carta.id .. ") removida da seleção. Custo total: " .. custo_atual .. "/5")
    return true
end