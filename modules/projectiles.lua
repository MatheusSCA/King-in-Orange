-- modules/projectiles.lua
-- Funções de projéteis

function desenhar_projeteis()
    -- Desenha disparos do jogador
    for _, disparo in ipairs(disparos) do
        desenhar_projetil({disparo.x, disparo.y}, disparo.tipo)
    end
    
    -- Desenha disparos do quadrado
    for _, disparo in ipairs(disparos_quadrado) do
        desenhar_projetil({disparo.x, disparo.y}, disparo.tipo)
    end
end

function atualizar_projeteis()
    atualizar_disparos_jogador()
    atualizar_disparos_quadrado()
end

function atualizar_disparos_jogador()
    local disparos_para_remover = {}
    
    for i, disparo in ipairs(disparos) do
        disparo.x = disparo.x + disparo.velocidade
        
        -- Aplica multiplicador de dano se carta 9 ativa
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
        
        --Verifica se atingiu a bola inimiga
        if VIDA_BOLA_INIMIGA > 0 then
            local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
            local bola_inimiga_x1 = celula_bola_inimiga.centro_x - tamanho_bola_inimiga
            local bola_inimiga_y1 = celula_bola_inimiga.centro_y - tamanho_bola_inimiga
            local bola_inimiga_x2 = celula_bola_inimiga.centro_x + tamanho_bola_inimiga
            local bola_inimiga_y2 = celula_bola_inimiga.centro_y + tamanho_bola_inimiga
            
            if disparo.x >= bola_inimiga_x1 and disparo.x <= bola_inimiga_x2 and
               disparo.y >= bola_inimiga_y1 and disparo.y <= bola_inimiga_y2 then
                
                local dano_final = disparo.dano * multiplicador_dano
                VIDA_BOLA_INIMIGA = VIDA_BOLA_INIMIGA - dano_final
                if VIDA_BOLA_INIMIGA < 0 then
                    VIDA_BOLA_INIMIGA = 0
                end
                table.insert(disparos_para_remover, i)
                
                if multiplicador_dano > 1 then
                    print("Dano dobrado! " .. dano_final .. " de dano na bola inimiga")
                else
                    print("Bola inimiga atingida! Dano: " .. dano_final)
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

function atualizar_disparos_quadrado()
    local disparos_quadrado_para_remover = {}
    
    for i, disparo in ipairs(disparos_quadrado) do
        disparo.x = disparo.x + disparo.velocidade
        
        -- Verifica se atingiu o jogador (se não está imune)
        local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
        local bola_x1 = celula_bola.centro_x - tamanho_bola
        local bola_y1 = celula_bola.centro_y - tamanho_bola
        local bola_x2 = celula_bola.centro_x + tamanho_bola
        local bola_y2 = celula_bola.centro_y + tamanho_bola
        
        local atingiu_jogador = false
        if disparo.x >= bola_x1 and disparo.x <= bola_x2 and
           disparo.y >= bola_y1 and disparo.y <= bola_y2 then
            atingiu_jogador = true
            
            -- Apenas causa dano se não estiver imune
            if not imune_dano then
                VIDA_JOGADOR = VIDA_JOGADOR - disparo.dano
                if VIDA_JOGADOR < 0 then
                    VIDA_JOGADOR = 0
                end
            end
            
            table.insert(disparos_quadrado_para_remover, i)
            quadrado_atacando = false
            
            -- Se jogador está imune, mostra mensagem de efeito visual
            if imune_dano then
                print("Projétil bloqueado! Jogador imune.")
            end
        end
        
        if disparo.x < 0 then
            table.insert(disparos_quadrado_para_remover, i)
            quadrado_atacando = false
        end
    end
    
    for i = #disparos_quadrado_para_remover, 1, -1 do
        local idx = disparos_quadrado_para_remover[i]
        table.remove(disparos_quadrado, idx)
    end
end

function desenhar_projetil(posicao, tipo)
    local x, y = posicao[1], posicao[2]
    
    if tipo == "jogador" then
        love.graphics.setColor(PRETO)
        love.graphics.circle("fill", x, y, 7)
        love.graphics.setColor(AZUL)
        love.graphics.circle("fill", x, y, 6)
        love.graphics.setColor(BRANCO)
        love.graphics.circle("fill", x, y, 3)
    elseif tipo == "grande" then
        love.graphics.setColor(PRETO)
        love.graphics.circle("fill", x, y, 15)
        love.graphics.setColor(ROXO_CLARO)
        love.graphics.circle("fill", x, y, 14)
        love.graphics.setColor(BRANCO)
        love.graphics.circle("fill", x, y, 8)
    elseif tipo == "quadrado" then
        love.graphics.setColor(PRETO)
        love.graphics.circle("fill", x, y, 6)
        love.graphics.setColor(AMARELO)
        love.graphics.circle("fill", x, y, 5)
        love.graphics.setColor(BRANCO)
        love.graphics.circle("fill", x, y, 2)
    end
end