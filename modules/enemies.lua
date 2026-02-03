-- modules/enemies.lua
-- Funções dos inimigos (versão sem IA)

-- Variáveis para efeitos visuais
local efeitos_ataque_triangulo = {}
local efeitos_ataque_quadrado = {}

-- Variáveis para controle de ataque rápido
local ataque_velocidade = 5
local ataque_temporizador = 0
local ataque_em_progresso = false
local triangulo_atacante = nil
local posicao_inicial_ataque = nil
local direcao_ataque = nil
local tempo_total_ataque = 0

function inicializar_inimigos()
    pos_triangulo = {1, 4}
    pos_quadrado = {2, 5}
    pos_bola_inimiga = {3, 6}  
    
    -- Inicializar variáveis de ataque rápido
    ataque_temporizador = 0
    ataque_em_progresso = false
    triangulo_atacante = nil
    posicao_inicial_ataque = nil
    direcao_ataque = nil
    tempo_total_ataque = 0
    
    -- Limpar efeitos
    efeitos_ataque_triangulo = {}
    efeitos_ataque_quadrado = {}
end

function adicionar_efeito_preparacao(linha, coluna, tipo, duracao)
    table.insert(efeitos_ataque_triangulo, {
        linha = linha,
        coluna = coluna,
        tipo = tipo,
        tempo = 0,
        duracao = duracao,
        cor = LARANJA_CLARO
    })
end

function atualizar_efeitos_ataque(dt)
    -- Atualizar efeitos de triângulo
    for i = #efeitos_ataque_triangulo, 1, -1 do
        local efeito = efeitos_ataque_triangulo[i]
        efeito.tempo = efeito.tempo + dt
        if efeito.tempo >= efeito.duracao then
            table.remove(efeitos_ataque_triangulo, i)
        end
    end
    
    -- Atualizar efeitos de quadrado
    for i = #efeitos_ataque_quadrado, 1, -1 do
        local efeito = efeitos_ataque_quadrado[i]
        efeito.tempo = efeito.tempo + dt
        if efeito.tempo >= efeito.duracao then
            table.remove(efeitos_ataque_quadrado, i)
        end
    end
end

function desenhar_efeitos_ataque()
    -- Efeitos de preparação do triângulo
    for _, efeito in ipairs(efeitos_ataque_triangulo) do
        local celula = GRID_CELULAS[efeito.linha][efeito.coluna]
        local progresso = efeito.tempo / efeito.duracao
        
        if efeito.tipo == "preparacao" then
            -- Piscar laranja durante preparação
            local piscar = math.sin(love.timer.getTime() * 10) > 0
            if piscar then
                love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.5)
                love.graphics.rectangle("fill", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.8)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
            end
        end
    end
    
    -- Efeitos de ataque do quadrado
    for _, efeito in ipairs(efeitos_ataque_quadrado) do
        local celula = GRID_CELULAS[efeito.linha][efeito.coluna]
        local progresso = efeito.tempo / efeito.duracao
        
        if efeito.tipo == "preparacao_coluna" then
            -- Piscar laranja na coluna
            local piscar = math.sin(love.timer.getTime() * 8) > 0
            if piscar then
                for linha = 1, NUM_LINHAS do
                    local celula_coluna = GRID_CELULAS[linha][efeito.coluna]
                    love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.4)
                    love.graphics.rectangle("fill", 
                        celula_coluna.x, celula_coluna.y, 
                        celula_coluna.width, celula_coluna.height
                    )
                end
            end
        end
    end
end

function atualizar_ia_inimigos(tempo_atual)
    -- Apenas atualiza animações
    animacao_triangulo = animacao_triangulo + 1
    animacao_quadrado = animacao_quadrado + 1
    animacao_bola_inimiga = animacao_bola_inimiga + 1  --Atualizar animação da bola inimiga
    
    return
end

function desenhar_personagens_completos()
    -- Desenha a bola do jogador
    if VIDA_JOGADOR > 0 then
        local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
        desenhar_bola(ROXO_CLARO, 
            {celula_bola.centro_x, celula_bola.centro_y}, 
            tamanho_bola, animacao_bola)
        desenhar_seta_direita({celula_bola.centro_x, celula_bola.centro_y})
    end
    
    -- Desenha o triângulo (apenas se estiver vivo e no grid)
    if VIDA_TRIANGULO > 0 and pos_triangulo[1] > 0 and pos_triangulo[2] > 0 then
        local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
        desenhar_triangulo(LARANJA_CLARO,
            {celula_triangulo.centro_x, celula_triangulo.centro_y},
            tamanho_triangulo, animacao_triangulo)
    end
    
    -- Desenha o quadrado (apenas se estiver vivo e no grid)
    if VIDA_QUADRADO > 0 and pos_quadrado[1] > 0 and pos_quadrado[2] > 0 then
        local celula_quadrado = GRID_CELULAS[pos_quadrado[1]][pos_quadrado[2]]
        desenhar_quadrado(AMARELO,
            {celula_quadrado.centro_x, celula_quadrado.centro_y},
            tamanho_quadrado, animacao_quadrado)
    end
    
    --Desenha a bola inimiga (apenas se estiver viva)
    if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[1] > 0 and pos_bola_inimiga[2] > 0 then
        local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
        desenhar_bola_inimiga(LARANJA_CLARO,
            {celula_bola_inimiga.centro_x, celula_bola_inimiga.centro_y},
            tamanho_bola_inimiga, animacao_bola_inimiga)
    end
end

-- Função para desenhar a bola inimiga (atualizada para mostrar dano)
function desenhar_bola_inimiga(cor, posicao, tamanho, frame)
    local x, y = posicao[1], posicao[2]
    local tamanho_animado = tamanho + math.sin(frame * 0.1) * 2  -- Mesma animação da bola do jogador
    
    -- Calcula a saúde atual como porcentagem (600 é a vida máxima da bola inimiga)
    local saude_percentual = VIDA_BOLA_INIMIGA / 600
    
    -- Desenho similar à bola do jogador, mas em laranja
    love.graphics.setColor(PRETO)
    love.graphics.circle("fill", x, y, tamanho_animado)
    
    -- Cor da bola baseada na saúde (fica mais escura conforme perde vida)
    local cor_bola = {
        cor[1] * saude_percentual,  -- Vermelho
        cor[2] * saude_percentual,  -- Verde
        cor[3] * saude_percentual   -- Azul
    }
    
    love.graphics.setColor(cor_bola)
    love.graphics.circle("fill", x, y, tamanho_animado - 3)
    
    -- Centro mais claro quando saudável, mais escuro quando ferido
    local brilho_centro = 0.5 + (saude_percentual * 0.5)  -- Varia de 0.5 a 1.0
    love.graphics.setColor(brilho_centro, brilho_centro, 100/255 * brilho_centro)
    love.graphics.circle("fill", 
        x - tamanho_animado/4, y - tamanho_animado/4,
        tamanho_animado/4
    )
    
    -- Efeito visual quando a saúde está baixa (abaixo de 30%)
    if saude_percentual < 0.3 then
        -- Piscar vermelho quando saúde baixa
        local piscar = math.sin(frame * 0.3) > 0
        if piscar then
            love.graphics.setColor(VERMELHO[1], VERMELHO[2], VERMELHO[3], 0.3)
            love.graphics.circle("line", x, y, tamanho_animado + 3)
            love.graphics.circle("line", x, y, tamanho_animado + 6)
        end
    end
    
    -- Efeito de "sangue/energia" escorrendo quando muito ferido
    if saude_percentual < 0.5 then
        local intensidade = 1.0 - (saude_percentual * 2)  -- Mais intenso quanto menor a saúde
        
        -- Gota de "sangue" escorrendo
        local gota_tamanho = tamanho_animado/6 * intensidade
        local gota_y = y + tamanho_animado/2
        
        love.graphics.setColor(LARANJA_ESCURO[1], LARANJA_ESCURO[2], LARANJA_ESCURO[3], 0.7 * intensidade)
        love.graphics.circle("fill", x, gota_y, gota_tamanho)
        
        -- Conexão da gota com a bola
        love.graphics.setColor(LARANJA_ESCURO[1], LARANJA_ESCURO[2], LARANJA_ESCURO[3], 0.5 * intensidade)
        love.graphics.setLineWidth(2)
        love.graphics.line(x, y + tamanho_animado/3, x, gota_y - gota_tamanho/2)
    end
    
    -- Setinha para esquerda (oposta à do jogador)
    desenhar_seta_esquerda(posicao, 15)
end

-- Função para desenhar seta para esquerda
function desenhar_seta_esquerda(posicao, tamanho_seta)
    tamanho_seta = tamanho_seta or 15
    local x, y = posicao[1], posicao[2]
    x = x - tamanho_bola_inimiga - 10  -- Lado oposto ao do jogador
    
    love.graphics.setColor(BRANCO)
    love.graphics.polygon("fill", 
        x, y,
        x + tamanho_seta, y - tamanho_seta/2,
        x + tamanho_seta, y + tamanho_seta/2
    )
end

function desenhar_triangulo(cor, posicao, tamanho, frame)
    local x, y = posicao[1], posicao[2]
    local tamanho_animado = tamanho + math.sin(frame * 0.1) * 3
    
    -- Desenho normal (sem IA, sem efeitos de bloqueio)
    love.graphics.setColor(PRETO)
    love.graphics.polygon("fill",
        x - tamanho_animado / 2, y,
        x + tamanho_animado / 2, y - tamanho_animado / 2,
        x + tamanho_animado / 2, y + tamanho_animado / 2
    )
    
    love.graphics.setColor(cor)
    love.graphics.polygon("fill",
        x - tamanho_animado / 2 + 2, y,
        x + tamanho_animado / 2 - 2, y - tamanho_animado / 2 + 2,
        x + tamanho_animado / 2 - 2, y + tamanho_animado / 2 - 2
    )
end

function desenhar_quadrado(cor, posicao, tamanho, frame)
    local x, y = posicao[1], posicao[2]
    local tamanho_animado = tamanho + math.sin(frame * 0.08) * 2
    
    -- Desenho normal (sem IA, sem efeitos de bloqueio)
    love.graphics.setColor(PRETO)
    love.graphics.rectangle("fill", 
        x - tamanho_animado/2, y - tamanho_animado/2,
        tamanho_animado, tamanho_animado
    )
    
    love.graphics.setColor(cor)
    love.graphics.rectangle("fill",
        x - tamanho_animado/2 + 2, y - tamanho_animado/2 + 2,
        tamanho_animado - 4, tamanho_animado - 4
    )
    
    love.graphics.setColor(1, 1, 100/255)
    love.graphics.rectangle("fill",
        x - tamanho_animado/4, y - tamanho_animado/4,
        tamanho_animado/2, tamanho_animado/2
    )
end

function remover_inimigo_se_morto()
    -- Remove triângulo se morto
    if VIDA_TRIANGULO <= 0 then
        VIDA_TRIANGULO = 0
        pos_triangulo = {-1, -1}
    end
    
    -- Remove quadrado se morto
    if VIDA_QUADRADO <= 0 then
        VIDA_QUADRADO = 0
        pos_quadrado = {-1, -1}
    end
    
    -- Remove bola inimiga se morta
    if VIDA_BOLA_INIMIGA <= 0 then
        VIDA_BOLA_INIMIGA = 0
        pos_bola_inimiga = {-1, -1}
    end
end

function mover_triangulo(dx, dy)
    -- Função mantida para compatibilidade, mas não é usada (sem IA)
    return false
end

function mover_quadrado(dx, dy)
    -- A fazer
    return false
end

-- Exportar funções principais
return {
    inicializar_inimigos = inicializar_inimigos,
    atualizar_ia_inimigos = atualizar_ia_inimigos,
    desenhar_personagens_completos = desenhar_personagens_completos,
    remover_inimigo_se_morto = remover_inimigo_se_morto,
    mover_triangulo = mover_triangulo,
    mover_quadrado = mover_quadrado,
    
    -- Funções para efeitos visuais
    atualizar_efeitos_ataque = atualizar_efeitos_ataque,
    desenhar_efeitos_ataque = desenhar_efeitos_ataque,
    adicionar_efeito_preparacao = adicionar_efeito_preparacao,
    
    --Funções para bola inimiga
    desenhar_bola_inimiga = desenhar_bola_inimiga,
    desenhar_seta_esquerda = desenhar_seta_esquerda,
    
    -- Variáveis para efeitos
    efeitos_ataque_triangulo = efeitos_ataque_triangulo,
    efeitos_ataque_quadrado = efeitos_ataque_quadrado
}