-- modules/enemies.lua
-- Módulo específico para o inimigo esfera

-- CONSTANTES DA ESFERA (FASE 1)
ESFERA_TEMPO_PREPARACAO_1 = 1.2
ESFERA_TEMPO_PREPARACAO_2 = 1.8
ESFERA_TEMPO_COOLDOWN = 2
ESFERA_DANO_PROJETIL = 40
ESFERA_DANO_COLUNA = 150
ESFERA_VELOCIDADE_PROJETIL = 20
ESFERA_TEMPO_TRANSPARENCIA = 1.2
ESFERA_INTERVALO_MOVIMENTO = 800
ESFERA_INTERVALO_RECUO = 400

-- CONSTANTES DA ESFERA (FASE 4)
ESFERA_FASE4_VIDA = 1200  -- Dobro da vida (600 * 2)
ESFERA_FASE4_TEMPO_PREPARACAO = 1.2  -- Tempo de preparação (piscar)
ESFERA_FASE4_TEMPO_RECUO = 4.0  -- Tempo de recuo entre padrões (não ataca)
ESFERA_FASE4_DANO_ATAQUE_1 = 50  -- Dano do primeiro ataque
ESFERA_FASE4_DANO_ATAQUE_2 = 150  -- Dano do ataque na coluna 2
ESFERA_FASE4_DANO_PROJETIL = 50  -- Dano dos projéteis
ESFERA_FASE4_DANO_PROJETIL_FINAL = 120  -- Dano do projétil final
ESFERA_FASE4_TEMPO_BLOQUEIO = 2.0  -- Tempo que jogador fica bloqueado
ESFERA_FASE4_EFEITO_CIANO_DURACAO = 1.5  -- Duração do efeito ciano após ataques

-- Estados da esfera (fase 1)
ESFERA_ESTADO_MOVENDO = "movendo"
ESFERA_ESTADO_PREPARANDO_ATAQUE_1 = "preparando_ataque_1"
ESFERA_ESTADO_PREPARANDO_ATAQUE_2 = "preparando_ataque_2"
ESFERA_ESTADO_ATACANDO_1 = "atacando_1"
ESFERA_ESTADO_ATACANDO_2 = "atacando_2"
ESFERA_ESTADO_COOLDOWN = "cooldown"

-- Estados da FASE 4
ESFERA_FASE4_ESTADO_PADRAO_1_PREP_1 = "padrao1_prep_1"  -- Preparando primeiro ataque (empurrão)
ESFERA_FASE4_ESTADO_PADRAO_1_PREP_2 = "padrao1_prep_2"  -- Preparando segundo ataque (coluna 2)
ESFERA_FASE4_ESTADO_PADRAO_2_PREP = "padrao2_prep"      -- Preparando projéteis
ESFERA_FASE4_ESTADO_PADRAO_2_MOVE = "padrao2_move"      -- Movendo para linha do jogador
ESFERA_FASE4_ESTADO_PADRAO_2_TIRO = "padrao2_tiro"      -- Tiro final
ESFERA_FASE4_ESTADO_RECUO = "recuo"                     -- Período sem atacar

-- Padrões da fase 4
PADRAO_1 = "padrao_1"
PADRAO_2 = "padrao_2"

-- Variáveis da esfera
VIDA_BOLA_INIMIGA = 600
tamanho_bola_inimiga = 35
pos_bola_inimiga = {3, 6}
animacao_bola_inimiga = 0

-- Variáveis de estado (fase 1)
esfera_estado = ESFERA_ESTADO_MOVENDO
esfera_tempo_estado = 0
esfera_proximo_ataque = nil
esfera_linha_alvo = 1
esfera_coluna_alvo = 1
esfera_ataque_realizado = false
esfera_coluna_ataque = nil
esfera_efeito_coluna_transparente = nil
esfera_tempo_transparente = 0
esfera_ultimo_log = 0
esfera_ultimo_movimento = 0
esfera_efeitos_preparacao = {}

-- VARIÁVEIS DA FASE 4
esfera_fase4_ativa = false  -- Indica se está na fase 4
esfera_fase4_padrao_atual = nil  -- Padrão atual (PADRAO_1 ou PADRAO_2)
esfera_fase4_estado = nil  -- Estado dentro do padrão
esfera_fase4_timer = 0  -- Timer para controles de tempo
esfera_fase4_pos_original = nil  -- Posição original da esfera
esfera_fase4_projeteis = {}  -- Projéteis especiais
esfera_fase4_imune = false  -- Se a esfera está imune (não usado por enquanto)
esfera_fase4_bloqueio_jogador = false  -- Se o jogador está bloqueado
esfera_fase4_tempo_bloqueio = 0  -- Tempo restante de bloqueio
esfera_fase4_efeito_ciano_colunas = {}  -- Colunas com efeito ciano
esfera_fase4_efeito_ciano_tempo = 0  -- Tempo restante do efeito ciano
esfera_fase4_dados_ataque = {}  -- Dados do próximo ataque (colunas/linhas afetadas)

-- Áreas de preparação para efeitos visuais
esfera_fase4_area_preparacao = {}  -- Áreas que vão piscar {tipo, linhas, colunas}
esfera_fase4_preparando = false  -- Se está em fase de preparação visual

jogador_imune_carta2 = jogador_imune_carta2 or function() return false end

function inicializar_esfera()
    VIDA_BOLA_INIMIGA = 600
    pos_bola_inimiga = {3, 6}
    resetar_esfera_estado()
    esfera_fase4_ativa = false
end

function resetar_esfera_estado()
    esfera_estado = ESFERA_ESTADO_MOVENDO
    esfera_tempo_estado = 0
    esfera_proximo_ataque = nil
    esfera_ataque_realizado = false
    esfera_linha_alvo = 1
    esfera_coluna_alvo = 1
    esfera_coluna_ataque = nil
    esfera_efeito_coluna_transparente = nil
    esfera_tempo_transparente = 0
    esfera_efeitos_preparacao = {}
    esfera_ultimo_log = 0
    esfera_ultimo_movimento = 0
    pos_bola_inimiga = {3, 6}
    
    -- Resetar variáveis da fase 4
    esfera_fase4_padrao_atual = nil
    esfera_fase4_estado = nil
    esfera_fase4_timer = 0
    esfera_fase4_pos_original = nil
    esfera_fase4_projeteis = {}
    esfera_fase4_imune = false
    esfera_fase4_bloqueio_jogador = false
    esfera_fase4_tempo_bloqueio = 0
    esfera_fase4_efeito_ciano_colunas = {}
    esfera_fase4_efeito_ciano_tempo = 0
    esfera_fase4_area_preparacao = {}
    esfera_fase4_preparando = false
    esfera_fase4_dados_ataque = {}
end

function resetar_esfera_para_fase()
    inicializar_esfera()
end

function desativar_esfera()
    VIDA_BOLA_INIMIGA = 0
    pos_bola_inimiga = {-1, -1}
    resetar_esfera_estado()
end

function esfera_esta_viva()
    return VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[1] > 0
end

-- FUNÇÃO PARA INICIALIZAR FASE 4
function inicializar_esfera_fase4()
    print("=== INICIALIZANDO ESFERA FASE 4 ===")
    VIDA_BOLA_INIMIGA = ESFERA_FASE4_VIDA
    pos_bola_inimiga = {3, 6}
    esfera_fase4_ativa = true
    resetar_esfera_estado()
    
    -- Escolher primeiro padrão aleatoriamente
    if love.math.random(2) == 1 then
        esfera_fase4_padrao_atual = PADRAO_1
        print("Padrão inicial: PADRÃO 1")
    else
        esfera_fase4_padrao_atual = PADRAO_2
        print("Padrão inicial: PADRÃO 2")
    end
    
    -- Iniciar no estado de movimentação
    esfera_fase4_estado = ESFERA_ESTADO_MOVENDO
    esfera_fase4_timer = 0
    
    print("Esfera fase 4 inicializada")
end

-- FUNÇÃO PARA ESCOLHER PRÓXIMO PADRÃO
function escolher_proximo_padrao()
    if esfera_fase4_padrao_atual == PADRAO_1 then
        esfera_fase4_padrao_atual = PADRAO_2
        print("Trocando para PADRÃO 2")
    else
        esfera_fase4_padrao_atual = PADRAO_1
        print("Trocando para PADRÃO 1")
    end
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_RECUO
    esfera_fase4_timer = 0
end

-- FUNÇÃO PARA LIMPAR PREPARAÇÃO VISUAL
function limpar_preparacao_visual()
    esfera_fase4_area_preparacao = {}
    esfera_fase4_preparando = false
end

-- ============================================
-- FUNÇÕES DE MOVIMENTO
-- ============================================

function mover_esfera_perseguindo()
    -- Perseguir o jogador (movimento normal)
    local dx = 0
    local dy = 0
    
    if pos_bola_inimiga[1] < pos_bola[1] then
        dy = 1
    elseif pos_bola_inimiga[1] > pos_bola[1] then
        dy = -1
    end
    
    if dy == 0 then
        if pos_bola_inimiga[2] < pos_bola[2] then
            dx = 1
        elseif pos_bola_inimiga[2] > pos_bola[2] then
            dx = -1
        end
    end
    
    if dx == 0 and dy == 0 then
        return false
    end
    
    local nova_linha = pos_bola_inimiga[1] + dy
    local nova_coluna = pos_bola_inimiga[2] + dx
    
    if nova_linha >= 1 and nova_linha <= 3 and nova_coluna >= 4 and nova_coluna <= 6 then
        pos_bola_inimiga[1] = nova_linha
        pos_bola_inimiga[2] = nova_coluna
        return true
    end
    
    return false
end

function mover_esfera_fugindo()
    -- Fugir do jogador: mover na direção oposta
    local dx = 0
    local dy = 0
    
    -- Determinar direção oposta à posição do jogador
    if pos_bola_inimiga[1] < pos_bola[1] then
        -- Esfera está acima do jogador, quer descer? NÃO, quer SUBIR (fugir para longe)
        dy = -1
    elseif pos_bola_inimiga[1] > pos_bola[1] then
        -- Esfera está abaixo do jogador, quer subir? NÃO, quer DESCER (fugir para longe)
        dy = 1
    end
    
    -- Se está na mesma linha, tenta fugir horizontalmente
    if dy == 0 then
        if pos_bola_inimiga[2] < pos_bola[2] then
            -- Esfera está à esquerda do jogador, quer ir para direita? NÃO, quer ESQUERDA (fugir)
            dx = -1
        elseif pos_bola_inimiga[2] > pos_bola[2] then
            -- Esfera está à direita do jogador, quer ir para esquerda? NÃO, quer DIREITA (fugir)
            dx = 1
        end
    end
    
    -- Se não conseguiu determinar direção de fuga, tenta se afastar para os cantos
    if dx == 0 and dy == 0 then
        -- Já está longe? Tenta ir para o canto mais distante
        if pos_bola_inimiga[1] == 1 then
            dy = 1  -- Se está na linha 1, desce
        elseif pos_bola_inimiga[1] == 3 then
            dy = -1  -- Se está na linha 3, sobe
        end
        
        if pos_bola_inimiga[2] == 4 then
            dx = 1  -- Se está na coluna 4, vai para 5 ou 6
        elseif pos_bola_inimiga[2] == 6 then
            dx = -1  -- Se está na coluna 6, vai para 5 ou 4
        end
    end
    
    -- Tentar mover na direção calculada
    if dx ~= 0 or dy ~= 0 then
        local nova_linha = pos_bola_inimiga[1] + dy
        local nova_coluna = pos_bola_inimiga[2] + dx
        
        -- Verificar limites (colunas 4-6 apenas)
        if nova_linha >= 1 and nova_linha <= 3 and 
           nova_coluna >= 4 and nova_coluna <= 6 then
            pos_bola_inimiga[1] = nova_linha
            pos_bola_inimiga[2] = nova_coluna
            return true
        end
    end
    
    -- Se não conseguiu fugir, tenta qualquer movimento disponível
    local direcoes = {
        {0, -1}, {0, 1},  -- cima, baixo
        {-1, 0}, {1, 0}   -- esquerda, direita
    }
    
    -- Embaralhar direções para tentar todas
    for i = #direcoes, 2, -1 do
        local j = love.math.random(i)
        direcoes[i], direcoes[j] = direcoes[j], direcoes[i]
    end
    
    for _, dir in ipairs(direcoes) do
        local teste_linha = pos_bola_inimiga[1] + dir[2]
        local teste_coluna = pos_bola_inimiga[2] + dir[1]
        
        if teste_linha >= 1 and teste_linha <= 3 and 
           teste_coluna >= 4 and teste_coluna <= 6 then
            pos_bola_inimiga[1] = teste_linha
            pos_bola_inimiga[2] = teste_coluna
            return true
        end
    end
    
    return false
end

-- ============================================
-- PADRÃO 1 - ATAQUES BASEADOS EM COLUNAS
-- ============================================

function padrao1_iniciar_prep_1()
    local coluna_jogador_inicio = pos_bola[2]
    local colunas_que_piscam = {}
    
    -- Definir quais colunas vão piscar baseado na posição do jogador NO INÍCIO
    if coluna_jogador_inicio == 1 then
        -- Jogador começou na coluna 1: colunas 1 e 2 piscam
        colunas_que_piscam = {1, 2}
        print("Padrão 1 - Jogador começou na coluna 1, preparando ataque nas colunas 1 e 2")
        
    elseif coluna_jogador_inicio == 3 then
        -- Jogador começou na coluna 3: colunas 3 e 2 piscam
        colunas_que_piscam = {3, 2}
        print("Padrão 1 - Jogador começou na coluna 3, preparando ataque nas colunas 3 e 2")
        
    else
        -- Jogador começou na coluna 2: apenas coluna 2 pisca
        colunas_que_piscam = {2}
        print("Padrão 1 - Jogador começou na coluna 2, preparando ataque na coluna 2")
    end
    
    -- Configurar área visual
    esfera_fase4_area_preparacao = {
        tipo = "colunas",
        colunas = colunas_que_piscam
    }
    
    -- Armazenar as colunas que estão piscando para usar no momento do ataque
    esfera_fase4_dados_ataque = {
        tipo = "padrao1_atk1",
        colunas_afetadas = colunas_que_piscam
    }
    
    -- Parar movimento da esfera
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_PADRAO_1_PREP_1
    esfera_fase4_timer = 0
    esfera_fase4_preparando = true
end

function padrao1_executar_atk_1()
    local coluna_jogador_agora = pos_bola[2]
    local jogador_imune = imune_dano or carta2_ativa or (jogador_imune_carta2 and jogador_imune_carta2())
    local colunas_afetadas = esfera_fase4_dados_ataque.colunas_afetadas or {}
    
    print("Executando ataque 1 do padrão 1 - Jogador agora na coluna " .. coluna_jogador_agora)
    print("Colunas afetadas pelo ataque: " .. table.concat(colunas_afetadas, ", "))
    
    -- Verificar se o jogador está em alguma das colunas que piscaram
    local jogador_em_coluna_afetada = false
    for _, coluna in ipairs(colunas_afetadas) do
        if coluna_jogador_agora == coluna then
            jogador_em_coluna_afetada = true
            break
        end
    end
    
    if jogador_em_coluna_afetada and not jogador_imune then
        -- Jogador está em coluna afetada, aplicar dano
        VIDA_JOGADOR = VIDA_JOGADOR - ESFERA_FASE4_DANO_ATAQUE_1
        print("Jogador sofreu " .. ESFERA_FASE4_DANO_ATAQUE_1 .. " de dano")
        
        -- Mover para coluna 2 (sempre, independente de onde estava)
        if coluna_jogador_agora ~= 2 then
            pos_bola[2] = 2
            print("Jogador movido para coluna 2")
        end
        
        -- Bloquear movimento do jogador por 2s
        esfera_fase4_bloqueio_jogador = true
        esfera_fase4_tempo_bloqueio = ESFERA_FASE4_TEMPO_BLOQUEIO
        bloqueado_movimento = true
        print("Jogador bloqueado por " .. ESFERA_FASE4_TEMPO_BLOQUEIO .. "s")
        
    elseif jogador_em_coluna_afetada then
        print("Jogador estava em coluna afetada mas está imune, dano ignorado!")
    else
        print("Jogador não está em nenhuma coluna afetada, ataque errou!")
    end
    
    -- Limpar preparação visual
    limpar_preparacao_visual()
    
    -- Avançar para preparação do segundo ataque
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_PADRAO_1_PREP_2
    esfera_fase4_timer = 0
end

function padrao1_iniciar_prep_2()
    -- Segunda preparação: coluna 2 pisca
    esfera_fase4_area_preparacao = {
        tipo = "colunas",
        colunas = {2}
    }
    
    -- Armazenar que a coluna 2 será afetada
    esfera_fase4_dados_ataque = {
        tipo = "padrao1_atk2",
        colunas_afetadas = {2}
    }
    
    print("Padrão 1 - Preparando ataque na coluna 2")
    
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_PADRAO_1_PREP_2
    esfera_fase4_timer = 0
    esfera_fase4_preparando = true
end

function padrao1_executar_atk_2()
    local coluna_jogador_agora = pos_bola[2]
    local jogador_imune = imune_dano or carta2_ativa or (jogador_imune_carta2 and jogador_imune_carta2())
    
    print("Executando ataque 2 do padrão 1 - Jogador na coluna " .. coluna_jogador_agora)
    
    -- Aplicar dano apenas se jogador estiver na coluna 2 (que piscou)
    if coluna_jogador_agora == 2 then
        if not jogador_imune then
            VIDA_JOGADOR = VIDA_JOGADOR - ESFERA_FASE4_DANO_ATAQUE_2
            print("Jogador na coluna 2 sofreu dano de 150! Vida restante: " .. VIDA_JOGADOR)
        else
            print("Jogador na coluna 2 mas está imune, dano ignorado!")
        end
    else
        print("Jogador não está na coluna 2, ataque errou!")
    end
    
    -- Efeito ciano na coluna 2
    esfera_fase4_efeito_ciano_colunas = {2}
    esfera_fase4_efeito_ciano_tempo = ESFERA_FASE4_EFEITO_CIANO_DURACAO
    
    -- Limpar preparação visual
    limpar_preparacao_visual()
    esfera_fase4_dados_ataque = {}
    
    -- Padrão 1 concluído, entrar em recuo
    escolher_proximo_padrao()
end

-- ============================================
-- PADRÃO 2 - ATAQUES BASEADOS EM LINHAS
-- ============================================

function padrao2_iniciar_prep()
    local linha_esfera = pos_bola_inimiga[1]
    local linhas_alvo = {}
    
    -- Determinar linhas alvo (acima e abaixo da esfera)
    if linha_esfera > 1 then
        table.insert(linhas_alvo, linha_esfera - 1)
    end
    if linha_esfera < 3 then
        table.insert(linhas_alvo, linha_esfera + 1)
    end
    
    -- Configurar área visual
    esfera_fase4_area_preparacao = {
        tipo = "linhas",
        linhas = linhas_alvo
    }
    
    -- Armazenar as linhas que estão piscando para usar no momento do ataque
    esfera_fase4_dados_ataque = {
        tipo = "padrao2_projeteis",
        linhas_afetadas = linhas_alvo,
        linha_origem = linha_esfera,
        coluna_origem = pos_bola_inimiga[2]
    }
    
    print("Padrão 2 - Preparando projéteis nas linhas " .. table.concat(linhas_alvo, ", "))
    
    -- Parar movimento da esfera
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_PADRAO_2_PREP
    esfera_fase4_timer = 0
    esfera_fase4_pos_original = {linha_esfera, pos_bola_inimiga[2]}
    esfera_fase4_preparando = true
end

function padrao2_lancar_projeteis()
    local dados = esfera_fase4_dados_ataque
    local linha_esfera = dados.linha_origem
    local coluna_esfera = dados.coluna_origem
    local celula_esfera = GRID_CELULAS[linha_esfera][coluna_esfera]
    local linhas_alvo = dados.linhas_afetadas
    
    print("Padrão 2 - Lançando projéteis para as linhas: " .. table.concat(linhas_alvo, ", "))
    
    -- Lançar projéteis apenas para as linhas que piscaram
    for _, linha_alvo in ipairs(linhas_alvo) do
        local proj = {
            x = celula_esfera.centro_x,
            y = celula_esfera.centro_y,
            x_inicio = celula_esfera.centro_x,
            y_inicio = celula_esfera.centro_y,
            x_alvo = GRID_CELULAS[linha_alvo][1].centro_x,
            y_alvo = GRID_CELULAS[linha_alvo][1].centro_y,
            progresso = 0,
            velocidade = 1.5,
            ativo = true,
            linha_alvo = linha_alvo,
            coluna_alvo = 1,
            dano = ESFERA_FASE4_DANO_PROJETIL,
            linha_origem = linha_esfera,
            coluna_origem = coluna_esfera,
            acertou = false
        }
        table.insert(esfera_fase4_projeteis, proj)
        print("Projétil lançado para linha " .. linha_alvo)
    end
    
    -- Limpar preparação visual
    limpar_preparacao_visual()
    
    -- Avançar para estado de movimento
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_PADRAO_2_MOVE
    esfera_fase4_timer = 0
end

function padrao2_mover_para_jogador()
    -- Mover esfera para linha do jogador
    pos_bola_inimiga[1] = pos_bola[1]
    print("Esfera moveu para linha " .. pos_bola[1])
    
    -- Preparar tiro final
    esfera_fase4_estado = ESFERA_FASE4_ESTADO_PADRAO_2_TIRO
    esfera_fase4_timer = 0
end

function padrao2_tiro_final()
    local celula_esfera = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
    
    -- Lançar projétil final
    local novo_disparo = {
        x = celula_esfera.centro_x - tamanho_bola_inimiga - 10,
        y = celula_esfera.centro_y,
        velocidade = -ESFERA_VELOCIDADE_PROJETIL,
        tipo = 'esfera',
        dano = ESFERA_FASE4_DANO_PROJETIL_FINAL,
        linha_origem = pos_bola_inimiga[1],
        pode_acertar_multiplos = false,
        inimigos_acertados = {}
    }
    table.insert(disparos, novo_disparo)
    print("Tiro final de dano 120 disparado!")
    
    -- Padrão 2 concluído, entrar em recuo
    escolher_proximo_padrao()
end

-- ============================================
-- FUNÇÃO PRINCIPAL DE ATUALIZAÇÃO
-- ============================================

function atualizar_ia_esfera(tempo_atual, dt)
    if VIDA_BOLA_INIMIGA <= 0 then return end
    
    -- Atualizar efeitos
    if esfera_fase4_efeito_ciano_tempo > 0 then
        esfera_fase4_efeito_ciano_tempo = esfera_fase4_efeito_ciano_tempo - dt
        if esfera_fase4_efeito_ciano_tempo <= 0 then
            esfera_fase4_efeito_ciano_colunas = {}
        end
    end
    
    if esfera_efeito_coluna_transparente then
        esfera_tempo_transparente = esfera_tempo_transparente + dt
        if esfera_tempo_transparente >= ESFERA_TEMPO_TRANSPARENCIA then
            esfera_efeito_coluna_transparente = nil
            esfera_tempo_transparente = 0
        end
    end
    
    if esfera_fase4_bloqueio_jogador then
        esfera_fase4_tempo_bloqueio = esfera_fase4_tempo_bloqueio - dt
        if esfera_fase4_tempo_bloqueio <= 0 then
            esfera_fase4_bloqueio_jogador = false
            bloqueado_movimento = false
            print("Jogador não está mais bloqueado")
        end
    end
    
    -- Atualizar projéteis da fase 4
    if #esfera_fase4_projeteis > 0 then
        for i = #esfera_fase4_projeteis, 1, -1 do
            local proj = esfera_fase4_projeteis[i]
            proj.progresso = proj.progresso + dt * proj.velocidade
            proj.x = proj.x_inicio + (proj.x_alvo - proj.x_inicio) * proj.progresso
            proj.y = proj.y_inicio + (proj.y_alvo - proj.y_inicio) * proj.progresso
            
            if proj.progresso >= 1 and not proj.acertou then
                proj.ativo = false
                
                -- Verificar se o jogador está na linha alvo do projétil
                -- (a linha que piscou durante a preparação)
                if pos_bola[1] == proj.linha_alvo then
                    local jogador_imune = imune_dano or carta2_ativa or (jogador_imune_carta2 and jogador_imune_carta2())
                    
                    if not jogador_imune then
                        -- Aplicar dano
                        VIDA_JOGADOR = VIDA_JOGADOR - proj.dano
                        print("Jogador atingido por projétil na linha " .. proj.linha_alvo .. "! Dano: " .. proj.dano)
                        
                        -- Mover jogador para linha de origem da esfera
                        if proj.linha_origem then
                            pos_bola[1] = proj.linha_origem
                            print("Jogador puxado para linha " .. proj.linha_origem)
                            
                            -- Bloquear movimento do jogador
                            esfera_fase4_bloqueio_jogador = true
                            esfera_fase4_tempo_bloqueio = ESFERA_FASE4_TEMPO_BLOQUEIO
                            bloqueado_movimento = true
                        end
                        
                        proj.acertou = true
                    else
                        print("Jogador imune, projétil bloqueado!")
                    end
                else
                    print("Projétil atingiu linha " .. proj.linha_alvo .. " mas jogador não estava lá")
                end
                
                table.remove(esfera_fase4_projeteis, i)
            elseif proj.progresso >= 1 then
                table.remove(esfera_fase4_projeteis, i)
            end
        end
    end
    
    -- FASE 4
    if esfera_fase4_ativa then
        -- Incrementar timer
        esfera_fase4_timer = esfera_fase4_timer + dt
        
        -- Máquina de estados da fase 4
        if esfera_fase4_estado == ESFERA_ESTADO_MOVENDO then
            -- Movimento normal de PERSEGUIÇÃO
            if tempo_atual - esfera_ultimo_movimento >= ESFERA_INTERVALO_MOVIMENTO then
                mover_esfera_perseguindo()
                esfera_ultimo_movimento = tempo_atual
            end
            
            -- Verificar se pode iniciar ataque (a cada 3 segundos)
            if esfera_fase4_timer >= 3.0 then
                if esfera_fase4_padrao_atual == PADRAO_1 then
                    padrao1_iniciar_prep_1()
                else
                    padrao2_iniciar_prep()
                end
            end
            
        elseif esfera_fase4_estado == ESFERA_FASE4_ESTADO_PADRAO_1_PREP_1 then
            -- Preparação do primeiro ataque do padrão 1 (1.2s) - PARADA
            if esfera_fase4_timer >= ESFERA_FASE4_TEMPO_PREPARACAO then
                padrao1_executar_atk_1()
            end
            
        elseif esfera_fase4_estado == ESFERA_FASE4_ESTADO_PADRAO_1_PREP_2 then
            -- Preparação do segundo ataque do padrão 1 (1.2s) - PARADA
            if esfera_fase4_timer >= ESFERA_FASE4_TEMPO_PREPARACAO then
                padrao1_executar_atk_2()
            end
            
        elseif esfera_fase4_estado == ESFERA_FASE4_ESTADO_PADRAO_2_PREP then
            -- Preparação do padrão 2 (1.2s) - PARADA
            if esfera_fase4_timer >= ESFERA_FASE4_TEMPO_PREPARACAO then
                padrao2_lancar_projeteis()
            end
            
        elseif esfera_fase4_estado == ESFERA_FASE4_ESTADO_PADRAO_2_MOVE then
            -- Pequena pausa antes de mover (0.5s)
            if esfera_fase4_timer >= 0.5 then
                padrao2_mover_para_jogador()
            end
            
        elseif esfera_fase4_estado == ESFERA_FASE4_ESTADO_PADRAO_2_TIRO then
            -- Pequena pausa antes do tiro final (0.5s)
            if esfera_fase4_timer >= 0.5 then
                padrao2_tiro_final()
            end
            
        elseif esfera_fase4_estado == ESFERA_FASE4_ESTADO_RECUO then
            -- Período de recuo (4s) - FUGE DO JOGADOR
            if esfera_fase4_timer < ESFERA_FASE4_TEMPO_RECUO then
                -- Durante o recuo, a esfera FUGE
                if tempo_atual - esfera_ultimo_movimento >= ESFERA_INTERVALO_MOVIMENTO then
                    mover_esfera_fugindo()
                    esfera_ultimo_movimento = tempo_atual
                end
            else
                -- Fim do recuo: volta a perseguir
                esfera_fase4_estado = ESFERA_ESTADO_MOVENDO
                esfera_fase4_timer = 0
                print("Recuo terminado, voltando a PERSEGUIR o jogador")
            end
        end
        
        return
    end
    
    -- FASE 1 (original)
    if esfera_estado == ESFERA_ESTADO_COOLDOWN then
        esfera_tempo_estado = esfera_tempo_estado + dt
        
        if tempo_atual - esfera_ultimo_movimento >= ESFERA_INTERVALO_RECUO then
            local moveu = mover_esfera_para_tras()
            if moveu then
                esfera_ultimo_movimento = tempo_atual
            end
        end
        
        if esfera_tempo_estado >= ESFERA_TEMPO_COOLDOWN then
            esfera_estado = ESFERA_ESTADO_MOVENDO
            esfera_tempo_estado = 0
            esfera_proximo_ataque = nil
        end
        return
    end
    
    if esfera_estado == ESFERA_ESTADO_PREPARANDO_ATAQUE_1 or 
       esfera_estado == ESFERA_ESTADO_PREPARANDO_ATAQUE_2 then
        esfera_tempo_estado = esfera_tempo_estado + dt
        
        local tempo_preparacao = (esfera_estado == ESFERA_ESTADO_PREPARANDO_ATAQUE_1) and 
                                  ESFERA_TEMPO_PREPARACAO_1 or ESFERA_TEMPO_PREPARACAO_2
        
        if esfera_tempo_estado >= tempo_preparacao then
            if esfera_estado == ESFERA_ESTADO_PREPARANDO_ATAQUE_1 then
                realizar_ataque_projetil_esfera()
            else
                realizar_ataque_coluna_esfera()
            end
            esfera_efeitos_preparacao = {}
        end
        return
    end
    
    if esfera_estado == ESFERA_ESTADO_ATACANDO_1 or esfera_estado == ESFERA_ESTADO_ATACANDO_2 then
        esfera_estado = ESFERA_ESTADO_COOLDOWN
        esfera_tempo_estado = 0
        return
    end
    
    if esfera_estado == ESFERA_ESTADO_MOVENDO then
        esfera_linha_alvo = pos_bola[1]
        esfera_coluna_alvo = pos_bola[2]
        
        if tempo_atual - esfera_ultimo_movimento >= ESFERA_INTERVALO_MOVIMENTO then
            local moveu = mover_esfera_em_salto()
            if moveu then
                esfera_ultimo_movimento = tempo_atual
            end
        end
        
        local ataque_possivel = esfera_pode_atacar()
        
        if ataque_possivel then
            if esfera_proximo_ataque == nil then
                if ataque_possivel == "ataque_1" then
                    esfera_proximo_ataque = 1
                elseif ataque_possivel == "ataque_2" then
                    esfera_proximo_ataque = 2
                end
            end
            
            if esfera_proximo_ataque == 1 and ataque_possivel == "ataque_1" then
                esfera_estado = ESFERA_ESTADO_PREPARANDO_ATAQUE_1
                esfera_tempo_estado = 0
                table.insert(esfera_efeitos_preparacao, {
                    tipo = "linha",
                    linha = esfera_linha_alvo,
                    coluna = esfera_coluna_alvo,
                    tempo = 0,
                    duracao = ESFERA_TEMPO_PREPARACAO_1
                })
            elseif esfera_proximo_ataque == 2 and ataque_possivel == "ataque_2" then
                esfera_estado = ESFERA_ESTADO_PREPARANDO_ATAQUE_2
                esfera_tempo_estado = 0
                esfera_coluna_ataque = pos_bola[2]
                table.insert(esfera_efeitos_preparacao, {
                    tipo = "coluna",
                    linha = esfera_linha_alvo,
                    coluna = esfera_coluna_ataque,
                    tempo = 0,
                    duracao = ESFERA_TEMPO_PREPARACAO_2
                })
            end
        end
    end
end

-- FUNÇÕES ORIGINAIS DA FASE 1
function esfera_pode_atacar()
    if pos_bola_inimiga[1] == pos_bola[1] then
        return "ataque_1"
    elseif pos_bola[2] == 1 then
        return "ataque_2"
    else
        return false
    end
end

function mover_esfera_em_salto()
    local dx = 0
    local dy = 0
    
    if pos_bola_inimiga[1] < pos_bola[1] then
        dy = 1
    elseif pos_bola_inimiga[1] > pos_bola[1] then
        dy = -1
    end
    
    if dy == 0 then
        if pos_bola_inimiga[2] < pos_bola[2] then
            dx = 1
        elseif pos_bola_inimiga[2] > pos_bola[2] then
            dx = -1
        end
    end
    
    if dx == 0 and dy == 0 then
        return false
    end
    
    local nova_linha = pos_bola_inimiga[1] + dy
    local nova_coluna = pos_bola_inimiga[2] + dx
    
    if nova_linha >= 1 and nova_linha <= 3 and nova_coluna >= 4 and nova_coluna <= 6 then
        pos_bola_inimiga[1] = nova_linha
        pos_bola_inimiga[2] = nova_coluna
        return true
    end
    
    return false
end

function mover_esfera_para_tras()
    if pos_bola_inimiga[2] < 6 then
        local nova_coluna = pos_bola_inimiga[2] + 1
        if nova_coluna <= 6 then
            pos_bola_inimiga[2] = nova_coluna
            return true
        end
    end
    return false
end

function realizar_ataque_projetil_esfera()
    local celula_esfera = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
    
    local novo_disparo = {
        x = celula_esfera.centro_x - tamanho_bola_inimiga - 10,
        y = celula_esfera.centro_y,
        velocidade = -ESFERA_VELOCIDADE_PROJETIL,
        tipo = 'esfera',
        dano = ESFERA_DANO_PROJETIL,
        linha_origem = pos_bola_inimiga[1],
        pode_acertar_multiplos = false,
        inimigos_acertados = {}
    }
    
    table.insert(disparos, novo_disparo)
    esfera_estado = ESFERA_ESTADO_ATACANDO_1
    esfera_proximo_ataque = nil
end

function realizar_ataque_coluna_esfera()
    local coluna_ataque = esfera_coluna_ataque
    
    if pos_bola[2] == coluna_ataque then
        local jogador_imune = imune_dano or carta2_ativa or (jogador_imune_carta2 and jogador_imune_carta2())
        if not jogador_imune then
            VIDA_JOGADOR = VIDA_JOGADOR - ESFERA_DANO_COLUNA
            if VIDA_JOGADOR < 0 then
                VIDA_JOGADOR = 0
            end
            print("Jogador atingido por ataque de coluna! Dano: " .. ESFERA_DANO_COLUNA)
        end
    end
    
    esfera_efeito_coluna_transparente = coluna_ataque
    esfera_tempo_transparente = 0
    esfera_estado = ESFERA_ESTADO_ATACANDO_2
    esfera_proximo_ataque = nil
    esfera_coluna_ataque = nil
end

-- FUNÇÕES DE DESENHO
function desenhar_esfera()
    if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[1] > 0 then
        local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
        local x, y = celula_bola_inimiga.centro_x, celula_bola_inimiga.centro_y
        local tamanho_animado = tamanho_bola_inimiga + math.sin(animacao_bola_inimiga * 0.1) * 2
        local saude_percentual = VIDA_BOLA_INIMIGA / (esfera_fase4_ativa and ESFERA_FASE4_VIDA or 600)
        
        love.graphics.setColor(PRETO)
        love.graphics.circle("fill", x, y, tamanho_animado)
        
        local cor_bola = {
            LARANJA_CLARO[1] * saude_percentual,
            LARANJA_CLARO[2] * saude_percentual,
            LARANJA_CLARO[3] * saude_percentual
        }
        
        love.graphics.setColor(cor_bola)
        love.graphics.circle("fill", x, y, tamanho_animado - 3)
        
        local brilho_centro = 0.5 + (saude_percentual * 0.5)
        love.graphics.setColor(brilho_centro, brilho_centro, 100/255 * brilho_centro)
        love.graphics.circle("fill", 
            x - tamanho_animado/4, y - tamanho_animado/4,
            tamanho_animado/4
        )
        
        desenhar_seta_esquerda({x, y}, 15)
        
        -- Mostrar indicador do padrão atual na fase 4
        if esfera_fase4_ativa then
            love.graphics.setFont(love.graphics.newFont(14))
            if esfera_fase4_padrao_atual == PADRAO_1 then
                love.graphics.setColor(LARANJA_CLARO)
                love.graphics.print("P1", x - 20, y - 50)
            else
                love.graphics.setColor(LARANJA_CLARO)
                love.graphics.print("P2", x - 20, y - 50)
            end
            
            -- Indicador de recuo
            if esfera_fase4_estado == ESFERA_FASE4_ESTADO_RECUO then
                love.graphics.setColor(CIANO)
                love.graphics.print("RECUO", x - 25, y - 70)
            end
            
            -- Indicador de preparação
            if esfera_fase4_preparando then
                love.graphics.setColor(LARANJA_CLARO)
                love.graphics.print("!", x - 5, y - 90)
            end
        end
    end
end

function desenhar_efeitos_preparacao_esfera()
    -- Preparação visual da fase 4 (piscar laranja)
    if esfera_fase4_preparando and next(esfera_fase4_area_preparacao) then
        local piscar = math.sin(love.timer.getTime() * 16) > 0  -- Piscar rápido (8 vezes por segundo)
        
        if piscar then
            local area = esfera_fase4_area_preparacao
            
            if area.tipo == "colunas" then
                -- Piscar colunas específicas
                for _, coluna in ipairs(area.colunas) do
                    for linha = 1, NUM_LINHAS do
                        local celula = GRID_CELULAS[linha][coluna]
                        love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.7)
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
                
            elseif area.tipo == "linhas" then
                -- Piscar linhas específicas
                for _, linha in ipairs(area.linhas) do
                    for coluna = 1, 3 do
                        local celula = GRID_CELULAS[linha][coluna]
                        love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.7)
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
    
    -- Preparação original da fase 1
    for _, efeito in ipairs(esfera_efeitos_preparacao) do
        if efeito.tipo == "linha" then
            local piscar = math.sin(love.timer.getTime() * 15) > 0
            if piscar then
                for coluna = 1, 3 do
                    local celula = GRID_CELULAS[efeito.linha][coluna]
                    love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.6)
                    love.graphics.rectangle("fill", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                end
            end
        elseif efeito.tipo == "coluna" then
            local piscar = math.sin(love.timer.getTime() * 12) > 0
            if piscar then
                for linha = 1, NUM_LINHAS do
                    local celula = GRID_CELULAS[linha][efeito.coluna]
                    love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.6)
                    love.graphics.rectangle("fill", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                end
            end
        end
    end
end

function desenhar_efeito_transparencia_esfera()
    if esfera_efeito_coluna_transparente then
        for linha = 1, NUM_LINHAS do
            local celula = GRID_CELULAS[linha][esfera_efeito_coluna_transparente]
            local opacidade = 0.5 * (1 - esfera_tempo_transparente / ESFERA_TEMPO_TRANSPARENCIA)
            
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

function desenhar_efeito_ciano_fase4()
    if esfera_fase4_efeito_ciano_tempo > 0 and #esfera_fase4_efeito_ciano_colunas > 0 then
        local opacidade = 0.8 * (esfera_fase4_efeito_ciano_tempo / ESFERA_FASE4_EFEITO_CIANO_DURACAO)
        
        for _, coluna in ipairs(esfera_fase4_efeito_ciano_colunas) do
            for linha = 1, NUM_LINHAS do
                local celula = GRID_CELULAS[linha][coluna]
                
                love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade * 0.5)
                love.graphics.rectangle("fill", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade)
                love.graphics.setLineWidth(4)
                love.graphics.rectangle("line", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
            end
        end
    end
end

function desenhar_projeteis_fase4()
    for _, proj in ipairs(esfera_fase4_projeteis) do
        if proj.ativo then
            local x, y = proj.x, proj.y
            local tamanho = 12 + math.sin(proj.progresso * math.pi * 6) * 3
            
            love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.3)
            love.graphics.circle("fill", x, y, tamanho + 4)
            
            love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.9)
            love.graphics.circle("fill", x, y, tamanho)
            
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle("fill", x, y, tamanho / 2)
        end
    end
end

function desenhar_seta_esquerda(posicao, tamanho_seta)
    tamanho_seta = tamanho_seta or 15
    local x, y = posicao[1], posicao[2]
    x = x - tamanho_bola_inimiga - 10
    
    love.graphics.setColor(BRANCO)
    love.graphics.polygon("fill", 
        x, y,
        x + tamanho_seta, y - tamanho_seta/2,
        x + tamanho_seta, y + tamanho_seta/2
    )
end