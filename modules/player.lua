-- modules/player.lua
-- Funções do jogador

function inicializar_jogador()
    -- Inicializa posição
    pos_bola = {1, 1}
end

function atualizar_jogador(tempo_atual)
    if VIDA_JOGADOR > 0 and not bloqueado_movimento then
        if tempo_atual - ultimo_movimento_bola > 200 then
            if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
                mover_bola(0, -1)
            elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
                mover_bola(0, 1)
            elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
                mover_bola(-1, 0)
            elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
                mover_bola(1, 0)
            end
        end
        
        -- Sistema de disparos do jogador
        if (tecla_z_pressionada or mouse_pressionado) and not bloqueado_ataque then
            criar_disparo_jogador()
        end
    end
end

function mover_bola(dx, dy)
    local nova_linha = pos_bola[1] + dy
    local nova_coluna = pos_bola[2] + dx
    
    if nova_linha >= 1 and nova_linha <= NUM_LINHAS and 
       nova_coluna >= 1 and nova_coluna <= NUM_COLUNAS then
        
        -- Verifica se a nova célula é coluna cedida
        local eh_coluna_cedida = false
        for _, coluna_cedida in ipairs(colunas_cedidas) do
            if nova_coluna == coluna_cedida.coluna then
                eh_coluna_cedida = true
                break
            end
        end
        
        -- Não pode mover para coluna cedida
        if eh_coluna_cedida then
            print("Não pode mover para coluna cedida!")
            return false
        end
        
        -- Verifica tipo normal
        if GRID_CELULAS[nova_linha][nova_coluna].tipo == 'azul' then
            pos_bola = {nova_linha, nova_coluna}
            ultimo_movimento_bola = love.timer.getTime() * 1000
            return true
        end
    end
    
    return false
end

function criar_disparo_jogador()
    local tempo_atual = love.timer.getTime() * 1000
    
    if tempo_atual - tempo_ultimo_disparo >= intervalo_disparo then
        pode_atirar = true
    end
    
    if pode_atirar then
        local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
        local inicio_x = celula_bola.centro_x + tamanho_bola + 10
        local inicio_y = celula_bola.centro_y
        
        -- Aplica multiplicador de dano (carta 9)
        local multiplicador_dano = dano_dobrado and 2 or 1
        local dano_base = 1 * multiplicador_dano
        
        table.insert(disparos, {
            x = inicio_x,
            y = inicio_y,
            velocidade = 20,
            tipo = 'jogador',
            dano = dano_base
        })
        
        tempo_ultimo_disparo = tempo_atual
        pode_atirar = false
    end
end

function desenhar_seta_direita(posicao, tamanho)
    tamanho = tamanho or 15
    local x, y = posicao[1], posicao[2]
    x = x + tamanho_bola + 10
    
    love.graphics.setColor(BRANCO)
    love.graphics.polygon("fill", 
        x, y,
        x - tamanho, y - tamanho/2,
        x - tamanho, y + tamanho/2
    )
end

function desenhar_bola(cor, posicao, tamanho, frame)
    local x, y = posicao[1], posicao[2]
    local tamanho_animado = tamanho + math.sin(frame * 0.1) * 2
    
    -- Calcula a saúde atual como porcentagem
    local saude_percentual = VIDA_JOGADOR / vida_maxima_jogador
    
    -- EFEITO CIANO quando imune (carta 4)
    if imune_dano then
        -- Efeito ciano piscante
        local piscar = math.sin(frame * 0.2) > 0
        
        if piscar then
            -- Bola com efeito ciano brilhante
            love.graphics.setColor(PRETO)
            love.graphics.circle("fill", x, y, tamanho_animado + 5)
            
            love.graphics.setColor(CIANO)
            love.graphics.circle("fill", x, y, tamanho_animado + 2)
            
            love.graphics.setColor(BRANCO)
            love.graphics.circle("fill", x, y, tamanho_animado - 3)
            
            love.graphics.setColor(CIANO)
            love.graphics.circle("fill", 
                x - tamanho_animado/4, y - tamanho_animado/4,
                tamanho_animado/4 + 2
            )
            
            -- Efeito de brilho externo
            love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], 0.3)
            for i = 1, 3 do
                local raio = tamanho_animado + 5 + i * 3
                love.graphics.circle("line", x, y, raio)
            end
        else
            -- Bola normal (mas com borda ciano)
            love.graphics.setColor(PRETO)
            love.graphics.circle("fill", x, y, tamanho_animado)
            
            -- Cor da bola baseada na saúde
            local cor_bola = {
                cor[1] * saude_percentual,  -- Vermelho
                cor[2] * saude_percentual,  -- Verde
                cor[3] * saude_percentual   -- Azul
            }
            
            love.graphics.setColor(cor_bola)
            love.graphics.circle("fill", x, y, tamanho_animado - 3)
            
            -- Centro mais escuro quando ferido
            local brilho_centro = 0.5 + (saude_percentual * 0.5)  -- Varia de 0.5 a 1.0
            love.graphics.setColor(brilho_centro, brilho_centro, 100/255 * brilho_centro)
            love.graphics.circle("fill", 
                x - tamanho_animado/4, y - tamanho_animado/4,
                tamanho_animado/4
            )
        end
    else
        -- Desenho normal com efeito de saúde
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
        
        -- Centro mais escuro quando ferido
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
    end
    
    -- Efeito de "sangue/energia" escorrendo quando muito ferido
    if saude_percentual < 0.5 then
        local intensidade = 1.0 - (saude_percentual * 2)  -- Mais intenso quanto menor a saúde
        
        -- Gota de "sangue" escorrendo
        local gota_tamanho = tamanho_animado/6 * intensidade
        local gota_y = y + tamanho_animado/2
        
        love.graphics.setColor(ROXO_ESCURO[1], ROXO_ESCURO[2], ROXO_ESCURO[3], 0.7 * intensidade)
        love.graphics.circle("fill", x, gota_y, gota_tamanho)
        
        -- Conexão da gota com a bola
        love.graphics.setColor(ROXO_ESCURO[1], ROXO_ESCURO[2], ROXO_ESCURO[3], 0.5 * intensidade)
        love.graphics.setLineWidth(2)
        love.graphics.line(x, y + tamanho_animado/3, x, gota_y - gota_tamanho/2)
    end
end