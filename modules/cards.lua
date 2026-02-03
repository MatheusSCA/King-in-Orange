-- modules/cards.lua
-- Sistema de cartas 
CARTAS = {
    {id = "A", custo = 0, copias = 1, descricao = "Copia próxima carta"},
    {id = "2", custo = 1, copias = 3, descricao = "Tiro grande na linha"},
    {id = "3", custo = 1, copias = 3, descricao = "Ataque em coluna"},
    {id = "4", custo = 2, copias = 2, descricao = "Imunidade por 5s"},
    {id = "5", custo = 3, copias = 1, descricao = "Cura 50% da vida"},
    {id = "6", custo = 2, copias = 2, descricao = "Conquista coluna inimiga"},
    {id = "7", custo = 1, copias = 1, descricao = "Efeito aleatório (1-7)"},
    {id = "8", custo = 1, copias = 1, descricao = "Armadilha em grade"},
    {id = "9", custo = 2, copias = 1, descricao = "Cede coluna para inimigo"},
    {id = "10", custo = 5, copias = 1, descricao = "Dano baseado em cartas usadas"}
}

-- Variáveis globais
deck_atual = {}
mao_atual = {}
cartas_selecionadas = {}
cartas_usadas = {}  -- CORREÇÃO: Inicializada como tabela vazia
custo_atual = 0
MAX_CUSTO = 5

cartas_efeitos_ativos = {}
colunas_conquistadas = {}
colunas_cedidas = {}
tempo_efeito_carta_4 = 0
imune_dano = false
bloqueado_movimento = false
bloqueado_ataque = false
inimigos_bloqueados = false
tempo_bloqueio = 0
ultima_carta_usada = nil
tempo_mostrar_carta = 0
DURACAO_MOSTRAR_CARTA = 2.0  -- 2 segundos para mostrar nome da carta

-- Variáveis específicas da carta 9
dano_dobrado = false
fases_dano_dobrado = 0
fase_atual_carta_9 = 1

--Lista de cartas mantidas entre fases de preparação
cartas_nao_selecionadas = {}

--Armadilha da carta 8
armadilha_carta_8 = nil

function inicializar_deck()
    deck_atual = {}
    cartas_nao_selecionadas = {}  -- Resetar cartas não selecionadas
    cartas_usadas = {}  -- CORREÇÃO: Resetar cartas usadas também
    
    for _, carta in ipairs(CARTAS) do
        for i = 1, carta.copias do
            table.insert(deck_atual, {
                id = carta.id,
                custo = carta.custo,
                descricao = carta.descricao,
                usada = false,
                carta_original = true  -- Marca como carta original do deck
            })
        end
    end
    
    -- Embaralhar deck
    for i = #deck_atual, 2, -1 do
        local j = love.math.random(i)
        deck_atual[i], deck_atual[j] = deck_atual[j], deck_atual[i]
    end
end

function entrar_fase_preparacao()
    print("=== ENTRANDO NA FASE DE PREPARAÇÃO ===")
    
    -- Primeiro, combinar cartas não selecionadas da fase anterior com novas do deck
    mao_atual = {}
    
    -- Primeiro, adiciona cartas não selecionadas da fase anterior
    local cartas_nao_selecionadas_count = #cartas_nao_selecionadas
    print("Cartas não selecionadas da fase anterior: " .. cartas_nao_selecionadas_count)
    
    for i = 1, cartas_nao_selecionadas_count do
        local carta = cartas_nao_selecionadas[i]
        if carta then
            -- IMPORTANTE: Usar a própria carta, não uma cópia
            table.insert(mao_atual, carta)
            print("  Adicionando carta não selecionada: " .. carta.id)
        end
    end
    
    -- Limpar cartas não selecionadas (elas já estão na mão)
    cartas_nao_selecionadas = {}
    
    -- Depois, adiciona novas cartas do deck até ter 6 cartas na mão
    print("Adicionando cartas do deck até ter 6...")
    while #mao_atual < 6 and #deck_atual > 0 do
        local carta = table.remove(deck_atual, 1)
        if carta then
            table.insert(mao_atual, carta)
            print("  Adicionando carta do deck: " .. carta.id)
        end
    end
    
    -- Resetar cartas selecionadas (começa vazio na nova fase de preparação)
    cartas_selecionadas = {}
    custo_atual = 0
    
    -- Resetar seleção
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
    
    -- IMPORTANTE: Primeiro salvar cartas não selecionadas
    cartas_nao_selecionadas = {}
    
    for _, carta in ipairs(mao_atual) do
        -- Verifica se a carta não foi selecionada
        local foi_selecionada = false
        for _, carta_selecionada in ipairs(cartas_selecionadas) do
            -- Compara IDs e custos para ver se é a mesma carta
            if carta.id == carta_selecionada.id and carta.custo == carta_selecionada.custo then
                foi_selecionada = true
                break
            end
        end
        
        if not foi_selecionada then
            -- Salva a carta não selecionada
            table.insert(cartas_nao_selecionadas, carta)
            print("  Salvando carta não selecionada: " .. carta.id)
        end
    end
    
    -- Aplica cartas selecionadas para uso no combate
    for i, carta in ipairs(cartas_selecionadas) do
        table.insert(cartas_efeitos_ativos, {
            id = carta.id,
            posicao = i
        })
    end
    
    -- NÃO limpar mao_atual aqui - ela será limpa automaticamente na próxima entrada
    -- Apenas manter as cartas selecionadas para uso no combate
    
    print("Resumo ao sair:")
    print("  Cartas selecionadas: " .. #cartas_selecionadas)
    print("  Cartas não selecionadas salvas: " .. #cartas_nao_selecionadas)
    print("  Cartas no deck: " .. #deck_atual)
    print("=== FIM DA SAÍDA DA FASE DE PREPARAÇÃO ===")
end

function selecionar_carta(indice)
    if indice < 1 or indice > #mao_atual then return false end
    
    local carta = mao_atual[indice]
    
    -- Verifica se já atingiu o máximo de cartas selecionadas
    if #cartas_selecionadas >= 5 then
        print("Máximo de 5 cartas selecionadas atingido!")
        return false
    end
    
    if custo_atual + carta.custo > MAX_CUSTO then
        print("Custo máximo excedido! Custo atual: " .. custo_atual .. ", Custo da carta: " .. carta.custo)
        return false  -- Excede custo máximo
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
    table.insert(mao_atual, carta)  -- Retorna para a mão
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
    
    -- Encontra a carta correspondente em cartas_selecionadas
    local carta_usada = nil
    for i, carta in ipairs(cartas_selecionadas) do
        if i == 1 then  -- Primeira carta na fila
            carta_usada = carta
            break
        end
    end
    
    if carta_usada then
        aplicar_efeito_carta(carta_usada.id)
        
        -- Marca como usada
        carta_usada.usada = true
        
        -- CORREÇÃO: Garantir que cartas_usadas existe
        if not cartas_usadas then
            cartas_usadas = {}
        end
        table.insert(cartas_usadas, carta_usada)
        
        -- Remove da lista de cartas selecionadas
        table.remove(cartas_selecionadas, 1)
        
        -- Registra última carta usada para mostrar nome
        ultima_carta_usada = carta_usada.id
        tempo_mostrar_carta = DURACAO_MOSTRAR_CARTA
        
        -- Marca a carta na lista de selecionadas como usada (para efeito visual)
        carta_usada.cor_usada = true
        carta_usada.tempo_usada = DURACAO_MOSTRAR_CARTA
        
        print("Carta " .. carta_usada.id .. " usada! Restam " .. #cartas_selecionadas .. " cartas na fila.")
    end
    
    return true
end

function aplicar_efeito_carta(id_carta)
    print("Usando carta: " .. id_carta)
    
    if id_carta == "A" then
        -- Carta Ás: Copia próxima carta
        if #cartas_efeitos_ativos > 0 then
            local proxima_carta = cartas_efeitos_ativos[1]
            
            -- EVITA RECURSÃO INFINITA: Se a próxima carta for A, não faz nada
            if proxima_carta.id == "A" then
                print("Carta A não pode copiar outra carta A! Efeito ignorado.")
                return
            end
            
            -- Copia o efeito da próxima carta
            print("Carta A copiando carta: " .. proxima_carta.id)
            
            if proxima_carta.id == "2" then
                criar_tiro_grande()
            elseif proxima_carta.id == "3" then
                atacar_coluna_3()
            elseif proxima_carta.id == "4" then
                tempo_efeito_carta_4 = 5
                imune_dano = true
            elseif proxima_carta.id == "5" then
                VIDA_JOGADOR = math.min(vida_maxima_jogador, VIDA_JOGADOR + (vida_maxima_jogador * 0.5))
            elseif proxima_carta.id == "6" then
                conquistar_coluna()
            elseif proxima_carta.id == "7" then
                aplicar_efeito_aleatorio()
            elseif proxima_carta.id == "8" then
                criar_armadilha_8()
            elseif proxima_carta.id == "9" then
                ceder_coluna_com_dano()
            elseif proxima_carta.id == "10" then
                aplicar_dano_carta_10()
            end
        else
            print("Nenhuma carta disponível para copiar!")
        end
    elseif id_carta == "2" then
        -- Tiro grande na linha
        criar_tiro_grande()
    elseif id_carta == "3" then
        -- Ataque em coluna
        atacar_coluna_3()
    elseif id_carta == "4" then
        -- Imunidade por 5s
        tempo_efeito_carta_4 = 5
        imune_dano = true
    elseif id_carta == "5" then
        -- Cura 50%
        VIDA_JOGADOR = math.min(vida_maxima_jogador, VIDA_JOGADOR + (vida_maxima_jogador * 0.5))
    elseif id_carta == "6" then
        -- Conquista coluna inimiga
        conquistar_coluna()
    elseif id_carta == "7" then
        -- Efeito aleatório
        aplicar_efeito_aleatorio()
    elseif id_carta == "8" then
        -- Armadilha em grade
        criar_armadilha_8()
    elseif id_carta == "9" then
        -- Cede coluna para inimigo + dobra dano por 2 fases
        ceder_coluna_com_dano()
    elseif id_carta == "10" then
        -- Dano baseado em cartas usadas
        aplicar_dano_carta_10()
    end
end

function criar_tiro_grande()
    local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
    local inicio_x = celula_bola.centro_x + tamanho_bola + 10
    local inicio_y = celula_bola.centro_y
    
    -- Aplica multiplicador de dano (carta 9)
    local multiplicador_dano = dano_dobrado and 2 or 1
    local dano_base = 50 * multiplicador_dano
    
    table.insert(disparos, {
        x = inicio_x,
        y = inicio_y,
        velocidade = 15,
        tipo = 'grande',
        dano = dano_base,
        tamanho = 20
    })
    
    if multiplicador_dano > 1 then
        print("Tiro grande com dano dobrado: " .. dano_base)
    end
end

function atacar_coluna_3()
    local coluna_ataque = math.min(6, pos_bola[2] + 3)
    
    -- Aplica multiplicador de dano (carta 9)
    local multiplicador_dano = dano_dobrado and 2 or 1
    local dano_base = 100 * multiplicador_dano
    
    -- Pisca coluna em ciano
    table.insert(cartas_efeitos_ativos, {
        id = "3_ataque",
        coluna = coluna_ataque,
        tempo = 0,
        duracao = 1
    })
    
    -- Causa dano se inimigos na coluna
    if coluna_ataque >= 4 and coluna_ataque <= 6 then
        if pos_triangulo[2] == coluna_ataque and VIDA_TRIANGULO > 0 then
            VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - dano_base)
            if multiplicador_dano > 1 then
                print("Ataque de coluna com dano dobrado: " .. dano_base)
            end
        end
        if pos_quadrado[2] == coluna_ataque and VIDA_QUADRADO > 0 then
            VIDA_QUADRADO = math.max(0, VIDA_QUADRADO - dano_base)
            if multiplicador_dano > 1 then
                print("Ataque de coluna com dano dobrado: " .. dano_base)
            end
        end
    end
end

function conquistar_coluna()
    local coluna_conquista = 3  -- Coluna que toca o jogador
    
    -- Verifica se tem inimigo na coluna
    local tem_inimigo = false
    if pos_triangulo[2] == coluna_conquista or pos_quadrado[2] == coluna_conquista then
        tem_inimigo = true
        -- Causa dano ao inimigo
        if pos_triangulo[2] == coluna_conquista then
            VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - 150)
        end
        if pos_quadrado[2] == coluna_conquista then
            VIDA_QUADRADO = math.max(0, VIDA_QUADRADO - 150)
        end
    end
    
    if not tem_inimigo then
        table.insert(colunas_conquistadas, {
            coluna = coluna_conquista,
            fase_restante = 2  -- Dura 2 fases de preparação
        })
    end
end

function ceder_coluna_com_dano()
    local coluna_cedida = 3  -- Coluna que toca o inimigo (coluna central do lado do jogador)
    
    -- Verifica se tem jogador na coluna
    local tem_jogador = (pos_bola[2] == coluna_cedida)
    
    if not tem_jogador then
        -- Adiciona coluna cedida
        table.insert(colunas_cedidas, {
            coluna = coluna_cedida,
            fase_restante = 2,  -- Dura 2 fases de preparação
            linha_original = 1  -- Marcação para referência
        })
        
        print("Coluna " .. coluna_cedida .. " cedida ao inimigo por 2 fases")
    else
        -- Jogador está na coluna, causa dano
        VIDA_JOGADOR = math.max(0, VIDA_JOGADOR - 100)
        print("Jogador na coluna, causando dano em vez de ceder")
    end
    
    -- Ativa dano dobrado por 2 fases
    dano_dobrado = true
    fases_dano_dobrado = 2
    fase_atual_carta_9 = fase_atual  -- Usar fase_atual do game_state
    
    print("Dano dobrado ativado por 2 fases!")
    
    -- Efeito visual
    table.insert(cartas_efeitos_ativos, {
        id = "9_efeito",
        tipo = "dano_dobrado",
        fases_restantes = 2
    })
end

function aplicar_efeito_aleatorio()
    local numero = love.math.random(1, 7)
    
    if numero == 1 then
        bloqueado_movimento = true
        bloqueado_ataque = true
        tempo_bloqueio = 4
    elseif numero == 7 then
        inimigos_bloqueados = true
        tempo_bloqueio = 4
    end
    
    -- Desenha número acima do jogador
    table.insert(cartas_efeitos_ativos, {
        id = "7_numero",
        numero = numero,
        tempo = 0,
        duracao = 2
    })
end

function criar_armadilha_8()
    -- Marca quadrado aleatório no lado inimigo
    local linha = love.math.random(1, 3)
    local coluna = love.math.random(4, 6)
    
    --Define a armadilha na variável global
    armadilha_carta_8 = {
        linha = linha,
        coluna = coluna,
        ativa = true,
        tempo = 0,
        duracao = 5  -- 5 segundos de duração
    }
    
    print("Armadilha criada na linha " .. linha .. ", coluna " .. coluna)
end

function ceder_coluna()
    -- Função antiga (mantida para compatibilidade)
    local coluna_cedida = 3  -- Coluna que toca o inimigo
    
    table.insert(colunas_cedidas, {
        coluna = coluna_cedida,
        fase_restante = 2  -- Dura 2 fases de preparação
    })
end

function aplicar_dano_carta_10()
    -- Conta cartas diferentes usadas
    local cartas_diferentes = {}
    for _, carta in ipairs(cartas_usadas) do
        if not cartas_diferentes[carta.id] then
            cartas_diferentes[carta.id] = true
        end
    end
    
    local x = 0
    for _ in pairs(cartas_diferentes) do
        x = x + 1
    end
    
    -- Aplica multiplicador de dano (carta 9)
    local multiplicador_dano = dano_dobrado and 2 or 1
    local dano = x * (x * 10) * multiplicador_dano
    
    -- Aplica dano aos inimigos
    if VIDA_TRIANGULO > 0 then
        VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - dano)
    end
    if VIDA_QUADRADO > 0 then
        VIDA_QUADRADO = math.max(0, VIDA_QUADRADO - dano)
    end
    
    if multiplicador_dano > 1 then
        print("Carta 10 com dano dobrado: " .. dano)
    end
end

function atualizar_cartas(dt)
    -- Atualiza imunidade carta 4
    if imune_dano then
        tempo_efeito_carta_4 = tempo_efeito_carta_4 - dt
        if tempo_efeito_carta_4 <= 0 then
            imune_dano = false
        end
    end

    -- Atualiza tempo para mostrar nome da carta
    if tempo_mostrar_carta > 0 then
        tempo_mostrar_carta = tempo_mostrar_carta - dt
        if tempo_mostrar_carta < 0 then
            tempo_mostrar_carta = 0
            ultima_carta_usada = nil
        end
    end
    
    -- Atualiza tempo das cartas usadas nas selecionadas
    for _, carta in ipairs(cartas_selecionadas) do
        if carta.tempo_usada then
            carta.tempo_usada = carta.tempo_usada - dt
            if carta.tempo_usada <= 0 then
                carta.cor_usada = false
                carta.tempo_usada = nil
            end
        end
    end
    
    -- Atualiza bloqueios
    if tempo_bloqueio > 0 then
        tempo_bloqueio = tempo_bloqueio - dt
        if tempo_bloqueio <= 0 then
            bloqueado_movimento = false
            bloqueado_ataque = false
            inimigos_bloqueados = false
        end
    end
    
    -- Atualiza efeitos temporários
    for i = #cartas_efeitos_ativos, 1, -1 do
        local efeito = cartas_efeitos_ativos[i]
        if efeito.tempo then
            efeito.tempo = efeito.tempo + dt
            if efeito.tempo >= efeito.duracao then
                table.remove(cartas_efeitos_ativos, i)
            end
        end
    end
    
    -- Atualiza colunas conquistadas
    for i = #colunas_conquistadas, 1, -1 do
        local coluna = colunas_conquistadas[i]
        if coluna then
            coluna.fase_restante = coluna.fase_restante - (dt / MAX_TEMPO_PREPARACAO) * 0.1
            
            if coluna.fase_restante <= 0 then
                table.remove(colunas_conquistadas, i)
                print("Coluna " .. coluna.coluna .. " voltou a ser do inimigo")
            end
        end
    end
    
    -- Atualiza colunas cedidas (verifica término do efeito)
    for i = #colunas_cedidas, 1, -1 do
        local coluna = colunas_cedidas[i]
        if coluna then
            coluna.fase_restante = coluna.fase_restante - (dt / MAX_TEMPO_PREPARACAO) * 0.1
            
            if coluna.fase_restante <= 0 then
                -- Efeito acabou, remove coluna cedida
                table.remove(colunas_cedidas, i)
                print("Coluna " .. coluna.coluna .. " voltou a ser do jogador")
                
                -- Se jogador estava na coluna cedida, empurra para esquerda e causa dano
                if pos_bola[2] == coluna.coluna then
                    VIDA_JOGADOR = math.max(0, VIDA_JOGADOR - 50)
                    mover_bola(-1, 0)  -- Tenta empurrar para esquerda
                    print("Jogador empurrado e sofreu dano!")
                end
            end
        end
    end
    
    -- Atualiza dano dobrado (baseado em fases, não tempo)
    if dano_dobrado then
        -- Verifica mudança de fase
        if fase_atual ~= fase_atual_carta_9 then
            fases_dano_dobrado = fases_dano_dobrado - 1
            fase_atual_carta_9 = fase_atual
            
            if fases_dano_dobrado <= 0 then
                dano_dobrado = false
                print("Dano dobrado desativado")
                
                -- Remove efeito visual
                for i = #cartas_efeitos_ativos, 1, -1 do
                    if cartas_efeitos_ativos[i].id == "9_efeito" then
                        table.remove(cartas_efeitos_ativos, i)
                    end
                end
            else
                print("Dano dobrado restante: " .. fases_dano_dobrado .. " fases")
            end
        end
    end
    
    --Atualiza armadilha da carta 8
    if armadilha_carta_8 and armadilha_carta_8.ativa then
        armadilha_carta_8.tempo = armadilha_carta_8.tempo + dt
        
        -- Verifica se inimigo entrou na armadilha
        if armadilha_carta_8.tempo < armadilha_carta_8.duracao then
            local linha = armadilha_carta_8.linha
            local coluna = armadilha_carta_8.coluna
            
            -- Verifica se triângulo está na armadilha
            if VIDA_TRIANGULO > 0 and pos_triangulo[1] == linha and pos_triangulo[2] == coluna then
                local dano = 80  -- Dano base da armadilha
                if dano_dobrado then
                    dano = dano * 2
                end
                VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - dano)
                armadilha_carta_8.ativa = false
                print("Triângulo atingido pela armadilha! Dano: " .. dano)
            end
            
            -- Verifica se quadrado está na armadilha
            if VIDA_QUADRADO > 0 and pos_quadrado[1] == linha and pos_quadrado[2] == coluna then
                local dano = 80  -- Dano base da armadilha
                if dano_dobrado then
                    dano = dano * 2
                end
                VIDA_QUADRADO = math.max(0, VIDA_QUADRADO - dano)
                armadilha_carta_8.ativa = false
                print("Quadrado atingido pela armadilha! Dano: " .. dano)
            end
        else
            -- Armadilha expirou
            armadilha_carta_8 = nil
            print("Armadilha expirou")
        end
    end
end

function atualizar_disparos_jogador()
    local disparos_para_remover = {}
    
    for i, disparo in ipairs(disparos) do
        disparo.x = disparo.x + disparo.velocidade
        
        -- Aplica multiplicador de dano (carta 9)
        local multiplicador_dano = 1
        if dano_dobrado then
            multiplicador_dano = 2
        end
        
        -- Verifica se atingiu o triângulo
        if VIDA_TRIANGULO > 0 then
            local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
            local tri_x1 = celula_triangulo.centro_x - tamanho_triangulo
            local tri_y1 = celula_triangulo.centro_y - tamanho_triangulo
            local tri_x2 = celula_triangulo.centro_x + tamanho_triangulo
            local tri_y2 = celula_triangulo.centro_y + tamanho_triangulo
            
            if disparo.x >= tri_x1 and disparo.x <= tri_x2 and
               disparo.y >= tri_y1 and disparo.y <= tri_y2 then
                
                local dano_final = disparo.dano * multiplicador_dano
                VIDA_TRIANGULO = VIDA_TRIANGULO - dano_final
                if VIDA_TRIANGULO < 0 then
                    VIDA_TRIANGULO = 0
                end
                table.insert(disparos_para_remover, i)
                
                if multiplicador_dano > 1 then
                    print("Dano dobrado! " .. dano_final .. " de dano no triângulo")
                end
            end
        end
        
        -- Verifica se atingiu o quadrado
        if VIDA_QUADRADO > 0 then
            local celula_quadrado = GRID_CELULAS[pos_quadrado[1]][pos_quadrado[2]]
            local quad_x1 = celula_quadrado.centro_x - tamanho_quadrado
            local quad_y1 = celula_quadrado.centro_y - tamanho_quadrado
            local quad_x2 = celula_quadrado.centro_x + tamanho_quadrado
            local quad_y2 = celula_quadrado.centro_y + tamanho_quadrado
            
            if disparo.x >= quad_x1 and disparo.x <= quad_x2 and
               disparo.y >= quad_y1 and disparo.y <= quad_y2 then
                
                local dano_final = disparo.dano * multiplicador_dano
                VIDA_QUADRADO = VIDA_QUADRADO - dano_final
                if VIDA_QUADRADO < 0 then
                    VIDA_QUADRADO = 0
                end
                table.insert(disparos_para_remover, i)
                
                if multiplicador_dano > 1 then
                    print("Dano dobrado! " .. dano_final .. " de dano no quadrado")
                end
            end
        end
        
        -- Remove disparo se saiu da tela
        if disparo.x > LARGURA then
            table.insert(disparos_para_remover, i)
        end
    end
    
    -- Remove disparos marcados
    for i = #disparos_para_remover, 1, -1 do
        local idx = disparos_para_remover[i]
        table.remove(disparos, idx)
    end
end

function desenhar_efeitos_carta_9()
    -- Desenha colunas cedidas
    for _, coluna in ipairs(colunas_cedidas) do
        for linha = 1, NUM_LINHAS do
            local celula = GRID_CELULAS[linha][coluna.coluna]
            
            -- Coluna cedida (cor do inimigo)
            love.graphics.setColor(LARANJA_ESCURO[1], LARANJA_ESCURO[2], LARANJA_ESCURO[3], 0.5)
            love.graphics.rectangle("fill", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
            
            -- Borda piscante
            local piscar = math.sin(love.timer.getTime() * 5) > 0
            if piscar then
                love.graphics.setColor(LARANJA_CLARO)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
            end
        end
    end
    
    -- Desenha indicador de dano dobrado
    if dano_dobrado then
        local fonte_temp = fonte_instrucoes or love.graphics.newFont(20)
        love.graphics.setFont(fonte_temp)
        
        -- Texto flutuante próximo ao jogador
        local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
        local x = celula_bola.centro_x
        local y = celula_bola.y - 60
        
        -- Fundo
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", x - 60, y - 15, 120, 30, 5)
        
        -- Borda
        love.graphics.setColor(AMARELO)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 60, y - 15, 120, 30, 5)
        
        -- Texto
        love.graphics.setColor(AMARELO)
        local texto = "DANO DOBRADO!"
        love.graphics.print(texto, x - fonte_temp:getWidth(texto)/2, y - fonte_temp:getHeight()/2)
        
        -- Contador de fases
        local texto_fases = fases_dano_dobrado .. " fase(s)"
        love.graphics.print(texto_fases, x - fonte_temp:getWidth(texto_fases)/2, y + 10)
    end
end

--Função para desenhar a armadilha da carta 8
function desenhar_armadilha_carta_8()
    if armadilha_carta_8 and armadilha_carta_8.ativa then
        local linha = armadilha_carta_8.linha
        local coluna = armadilha_carta_8.coluna
        local celula = GRID_CELULAS[linha][coluna]
        
        -- Efeito piscante para indicar tempo restante
        local tempo_restante = armadilha_carta_8.duracao - armadilha_carta_8.tempo
        local piscar = math.sin(love.timer.getTime() * 8) > 0 or tempo_restante < 1
        
        if piscar then
            -- Desenha listras na diagonal (cor do jogador - roxo)
            local largura_listra = 10
            local celula_x = celula.x
            local celula_y = celula.y
            local celula_width = celula.width
            local celula_height = celula.height
            
            -- Desenha fundo semi-transparente
            love.graphics.setColor(ROXO_ESCURO[1], ROXO_ESCURO[2], ROXO_ESCURO[3], 0.3)
            love.graphics.rectangle("fill", celula_x, celula_y, celula_width, celula_height)
            
            -- Desenha listras diagonais (roxo)
            love.graphics.setLineWidth(3)
            local num_listras = 8
            
            for i = -num_listras, num_listras do
                local offset = i * largura_listra * 2
                
                -- Listra principal (roxo escuro)
                love.graphics.setColor(ROXO_ESCURO[1], ROXO_ESCURO[2], ROXO_ESCURO[3], 0.8)
                love.graphics.line(
                    celula_x + offset, celula_y,
                    celula_x + offset + celula_width, celula_y + celula_height
                )
                
                -- Listra secundária (roxo claro)
                love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.6)
                love.graphics.line(
                    celula_x + offset + largura_listra, celula_y,
                    celula_x + offset + largura_listra + celula_width, celula_y + celula_height
                )
            end
            
            -- Borda piscante
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.9)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", celula_x, celula_y, celula_width, celula_height)
            
            -- Ícone de armadilha (caveira ou X) no centro
            local centro_x = celula.centro_x
            local centro_y = celula.centro_y
            local tamanho_icone = 20
            
            love.graphics.setColor(PRETO)
            love.graphics.setLineWidth(3)
            
            -- Desenha um X
            love.graphics.line(
                centro_x - tamanho_icone, centro_y - tamanho_icone,
                centro_x + tamanho_icone, centro_y + tamanho_icone
            )
            love.graphics.line(
                centro_x + tamanho_icone, centro_y - tamanho_icone,
                centro_x - tamanho_icone, centro_y + tamanho_icone
            )
            
            -- Contorno do X em roxo
            love.graphics.setColor(ROXO_CLARO)
            love.graphics.setLineWidth(1)
            love.graphics.line(
                centro_x - tamanho_icone - 1, centro_y - tamanho_icone - 1,
                centro_x + tamanho_icone + 1, centro_y + tamanho_icone + 1
            )
            love.graphics.line(
                centro_x + tamanho_icone + 1, centro_y - tamanho_icone - 1,
                centro_x - tamanho_icone - 1, centro_y + tamanho_icone + 1
            )
        end
    end
end

-- Funções auxiliares para compatibilidade
function desenhar_efeitos_cartas_ativos()
    -- Chama função de desenho da carta 9
    if desenhar_efeitos_carta_9 then
        desenhar_efeitos_carta_9()
    end
    
    --Chama função de desenho da armadilha da carta 8
    if desenhar_armadilha_carta_8 then
        desenhar_armadilha_carta_8()
    end
end

function desenhar_nome_carta_usada()
    if ultima_carta_usada and tempo_mostrar_carta > 0 then
        local fonte_temp = fonte_instrucoes or love.graphics.newFont(24)
        love.graphics.setFont(fonte_temp)
        
        -- Posição CENTRALIZADA acima do viewport
        local texto = "Carta usada: " .. ultima_carta_usada
        local x = OFFSET_X_VIEWPORT + (JOGO_LARGURA / 2) - (fonte_temp:getWidth(texto) / 2)
        local y = OFFSET_Y_VIEWPORT - 50  -- Acima do viewport
        
        -- Efeito de fade out
        local opacidade = math.min(1.0, tempo_mostrar_carta * 2)
        
        -- Fundo
        love.graphics.setColor(0, 0, 0, 0.7 * opacidade)
        love.graphics.rectangle("fill", x - 15, y - 10, 
            fonte_temp:getWidth(texto) + 30, 
            fonte_temp:getHeight() + 20, 8)
        
        -- Borda ciana
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 15, y - 10, 
            fonte_temp:getWidth(texto) + 30, 
            fonte_temp:getHeight() + 20, 8)
        
        -- Texto
        love.graphics.setColor(1, 1, 1, opacidade)
        love.graphics.print(texto, x, y)
        
        -- Ícone pequeno
        love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade * 0.8)
        love.graphics.circle("fill", x - 25, y + fonte_temp:getHeight()/2, 8)
        love.graphics.setColor(1, 1, 1, opacidade)
        love.graphics.circle("fill", x - 25, y + fonte_temp:getHeight()/2, 5)
    end
end

function resetar_cartas_para_preparacao()
    print("Resetando cartas - Limpando todas as seleções...")
    
    -- 1. Primeiro, devolver TODAS as cartas (selecionadas, mão e não selecionadas) para o deck
    local cartas_para_devolver = {}
    
    -- Adiciona cartas selecionadas
    for _, carta in ipairs(cartas_selecionadas) do
        table.insert(cartas_para_devolver, carta)
    end
    
    -- Adiciona cartas na mão
    for _, carta in ipairs(mao_atual) do
        table.insert(cartas_para_devolver, carta)
    end
    
    -- Adiciona cartas não selecionadas salvas
    for _, carta in ipairs(cartas_nao_selecionadas) do
        table.insert(cartas_para_devolver, carta)
    end
    
    -- 2. Embaralhar as cartas devolvidas de volta ao deck
    for _, carta in ipairs(cartas_para_devolver) do
        table.insert(deck_atual, carta)
    end
    
    -- Embaralhar o deck
    for i = #deck_atual, 2, -1 do
        local j = love.math.random(i)
        deck_atual[i], deck_atual[j] = deck_atual[j], deck_atual[i]
    end
    
    -- 3. Limpar todas as listas
    cartas_selecionadas = {}
    mao_atual = {}
    cartas_nao_selecionadas = {}  -- Limpar também as não selecionadas
    cartas_usadas = {}  -- CORREÇÃO: Limpar cartas usadas também
    custo_atual = 0
    
    -- 4. Pegar novas 6 cartas do deck para a próxima fase de preparação
    for i = 1, 6 do
        if #deck_atual > 0 then
            local carta = table.remove(deck_atual, 1)
            table.insert(mao_atual, carta)
        end
    end
    
    -- 5. Resetar seleção
    carta_selecionada = 1
    tipo_selecao = "mao"
    linha_selecionada = 1
    
    print("Reset completo de cartas realizado!")
    print("Novas cartas na mão: " .. #mao_atual)
    print("Cartas restantes no deck: " .. #deck_atual)
    print("Cartas selecionadas: " .. #cartas_selecionadas)
    print("Cartas não selecionadas: " .. #cartas_nao_selecionadas)
end

function remover_ultima_carta_selecionada()
    if #cartas_selecionadas == 0 then
        print("Nenhuma carta selecionada para remover!")
        return false
    end
    
    local ultima_carta = cartas_selecionadas[#cartas_selecionadas]
    table.insert(mao_atual, ultima_carta)  -- Retorna para a mão
    table.remove(cartas_selecionadas, #cartas_selecionadas)
    custo_atual = custo_atual - ultima_carta.custo
    
    print("Última carta (" .. ultima_carta.id .. ") removida da seleção. Custo total: " .. custo_atual .. "/5")
    return true
end