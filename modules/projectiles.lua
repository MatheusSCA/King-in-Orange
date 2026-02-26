-- modules/projectiles.lua
-- Funções de projéteis

function desenhar_projeteis()
    -- Desenha disparos do jogador
    for i, disparo in ipairs(disparos) do
        desenhar_projetil({disparo.x, disparo.y}, disparo.tipo, i)
    end
end

function atualizar_projeteis()
    atualizar_disparos_jogador()
end

function atualizar_disparos_jogador()
    local disparos_para_remover = {}
    
    for i, disparo in ipairs(disparos) do
        -- Atualizar posição
        disparo.x = disparo.x + disparo.velocidade
        
        -- Aplica multiplicador de dano
        local multiplicador_dano = dano_dobrado and 2 or 1
        
        -- Verifica se é um projétil da Carta 3
        if disparo.tipo == 'carta3' then
            -- Projétil da Carta 3 pode acertar múltiplos inimigos na mesma linha
            local linha_projetil = disparo.linha_origem
            
            if not disparo.inimigos_acertados then
                disparo.inimigos_acertados = {}
            end
            
            -- Verifica se atingiu o triângulo
            if VIDA_TRIANGULO > 0 and pos_triangulo[1] == linha_projetil then
                local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
                local tri_x1 = celula_triangulo.centro_x - tamanho_triangulo
                local tri_x2 = celula_triangulo.centro_x + tamanho_triangulo
                
                if disparo.x >= tri_x1 and disparo.x <= tri_x2 and
                   not disparo.inimigos_acertados["triangulo"] then
                    
                    local dano_final = disparo.dano * multiplicador_dano
                    VIDA_TRIANGULO = VIDA_TRIANGULO - dano_final
                    if VIDA_TRIANGULO < 0 then
                        VIDA_TRIANGULO = 0
                    end
                    
                    disparo.inimigos_acertados["triangulo"] = true
                    print("Carta 3: Triângulo atingido! Dano: " .. dano_final)
                end
            end
            
            -- Verifica se atingiu algum quadrado
            if VIDA_QUADRADO > 0 then
                for _, quad in ipairs(quadrados) do
                    if quad.vivo and quad.pos[1] == linha_projetil then
                        local celula_quadrado = GRID_CELULAS[quad.pos[1]][quad.pos[2]]
                        local quad_x1 = celula_quadrado.centro_x - tamanho_quadrado
                        local quad_x2 = celula_quadrado.centro_x + tamanho_quadrado
                        
                        if disparo.x >= quad_x1 and disparo.x <= quad_x2 and
                           not disparo.inimigos_acertados["quadrado" .. quad.id] then
                            
                            local dano_final = disparo.dano * multiplicador_dano
                            
                            -- Verifica imunidade
                            if quadrados_imunes and quadrados_imunes() then
                                print("Quadrado " .. quad.id .. " imune! Dano ignorado.")
                            else
                                aplicar_dano_quadrado_especifico(quad, dano_final)
                            end
                            
                            disparo.inimigos_acertados["quadrado" .. quad.id] = true
                        end
                    end
                end
            end
            
            -- Verifica se atingiu a bola inimiga
            if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[1] == linha_projetil then
                local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
                local bola_x1 = celula_bola_inimiga.centro_x - tamanho_bola_inimiga
                local bola_x2 = celula_bola_inimiga.centro_x + tamanho_bola_inimiga
                
                if disparo.x >= bola_x1 and disparo.x <= bola_x2 and
                   not disparo.inimigos_acertados["bola_inimiga"] then
                    
                    local dano_final = disparo.dano * multiplicador_dano
                    VIDA_BOLA_INIMIGA = VIDA_BOLA_INIMIGA - dano_final
                    if VIDA_BOLA_INIMIGA < 0 then
                        VIDA_BOLA_INIMIGA = 0
                    end
                    
                    disparo.inimigos_acertados["bola_inimiga"] = true
                    print("Carta 3: Bola inimiga atingida! Dano: " .. dano_final)
                end
            end
            
        elseif disparo.tipo == 'esfera' then
            -- Projétil da esfera - verifica se atingiu o jogador
            if VIDA_JOGADOR > 0 then
                local celula_bola = GRID_CELULAS[pos_bola[1]][pos_bola[2]]
                local bola_x1 = celula_bola.centro_x - tamanho_bola
                local bola_y1 = celula_bola.centro_y - tamanho_bola
                local bola_x2 = celula_bola.centro_x + tamanho_bola
                local bola_y2 = celula_bola.centro_y + tamanho_bola
                
                if disparo.x >= bola_x1 and disparo.x <= bola_x2 and
                   disparo.y >= bola_y1 and disparo.y <= bola_y2 then
                    
                    local jogador_imune = imune_dano or carta2_ativa or (jogador_imune_carta2 and jogador_imune_carta2())
                    
                    if not jogador_imune then
                        VIDA_JOGADOR = VIDA_JOGADOR - disparo.dano
                        if VIDA_JOGADOR < 0 then
                            VIDA_JOGADOR = 0
                        end
                        print("Jogador atingido por projétil da esfera! Dano: " .. disparo.dano)
                    else
                        print("Projétil da esfera bloqueado! Jogador imune.")
                    end
                    
                    table.insert(disparos_para_remover, i)
                end
            end
            
        else
            -- Projétil normal
            local acertou = false
            
            -- Verifica se atingiu o triângulo
            if VIDA_TRIANGULO > 0 and not acertou then
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
                    acertou = true
                    
                    if multiplicador_dano > 1 then
                        print("Dano dobrado! " .. dano_final .. " de dano no triângulo")
                    end
                end
            end
            
            -- Verifica se atingiu algum quadrado
            if VIDA_QUADRADO > 0 and not acertou then
                for _, quad in ipairs(quadrados) do
                    if quad.vivo then
                        local celula_quadrado = GRID_CELULAS[quad.pos[1]][quad.pos[2]]
                        local quad_x1 = celula_quadrado.centro_x - tamanho_quadrado
                        local quad_y1 = celula_quadrado.centro_y - tamanho_quadrado
                        local quad_x2 = celula_quadrado.centro_x + tamanho_quadrado
                        local quad_y2 = celula_quadrado.centro_y + tamanho_quadrado
                        
                        if disparo.x >= quad_x1 and disparo.x <= quad_x2 and
                           disparo.y >= quad_y1 and disparo.y <= quad_y2 then
                            
                            local dano_final = disparo.dano * multiplicador_dano
                            
                            -- Verifica imunidade
                            if quadrados_imunes and quadrados_imunes() then
                                print("Quadrados imunes! Dano ignorado.")
                            else
                                aplicar_dano_quadrado_especifico(quad, dano_final)
                            end
                            
                            table.insert(disparos_para_remover, i)
                            acertou = true
                            break
                        end
                    end
                end
            end
            
            -- Verifica se atingiu a bola inimiga
            if VIDA_BOLA_INIMIGA > 0 and not acertou then
                local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
                local bola_x1 = celula_bola_inimiga.centro_x - tamanho_bola_inimiga
                local bola_y1 = celula_bola_inimiga.centro_y - tamanho_bola_inimiga
                local bola_x2 = celula_bola_inimiga.centro_x + tamanho_bola_inimiga
                local bola_y2 = celula_bola_inimiga.centro_y + tamanho_bola_inimiga
                
                if disparo.x >= bola_x1 and disparo.x <= bola_x2 and
                   disparo.y >= bola_y1 and disparo.y <= bola_y2 then
                    
                    local dano_final = disparo.dano * multiplicador_dano
                    VIDA_BOLA_INIMIGA = VIDA_BOLA_INIMIGA - dano_final
                    if VIDA_BOLA_INIMIGA < 0 then
                        VIDA_BOLA_INIMIGA = 0
                    end
                    table.insert(disparos_para_remover, i)
                    acertou = true
                    
                    if multiplicador_dano > 1 then
                        print("Dano dobrado! " .. dano_final .. " de dano na bola inimiga")
                    else
                        print("Bola inimiga atingida! Dano: " .. dano_final)
                    end
                end
            end
        end
        
        -- Remove disparo se saiu da tela
        if disparo.x > LARGURA + 50 or disparo.x < -50 then
            if not contains(disparos_para_remover, i) then
                table.insert(disparos_para_remover, i)
            end
        end
    end
    
    -- Remove disparos marcados
    for i = #disparos_para_remover, 1, -1 do
        local idx = disparos_para_remover[i]
        table.remove(disparos, idx)
    end
end

-- Função auxiliar para verificar se tabela contém valor
function contains(tabela, valor)
    for _, v in ipairs(tabela) do
        if v == valor then
            return true
        end
    end
    return false
end

function desenhar_projeteis_carta8()
    if not carta8_ativa then return end
    
    for _, proj in ipairs(carta8_projeteis) do
        if proj.ativo then
            local x, y
            if proj.x_alvo and proj.y_alvo then
                x = proj.x_inicio + (proj.x_alvo - proj.x_inicio) * proj.progresso
                y = proj.y_inicio + (proj.y_alvo - proj.y_inicio) * proj.progresso
            else
                x = proj.x
                y = proj.y
            end
            
            local tamanho = CARTA8_TAMANHO_BASE * (1 + math.sin(proj.progresso * math.pi * 4) * CARTA8_TAMANHO_VARIACAO)
            
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.3)
            love.graphics.circle("fill", x, y, tamanho + 4)
            
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.9)
            love.graphics.circle("fill", x, y, tamanho)
            
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle("fill", x, y, tamanho / 2)
            
            love.graphics.setLineWidth(2)
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.6)
            love.graphics.line(x - tamanho, y, x + tamanho, y)
            love.graphics.line(x, y - tamanho, x, y + tamanho)
        end
    end
end

function desenhar_projetil(posicao, tipo, indice)
    local x, y = posicao[1], posicao[2]
    
    if tipo == "jogador" or tipo == "carta3" then
        if tipo == "carta3" then
            love.graphics.setColor(PRETO)
            love.graphics.circle("fill", x, y, 8)
            love.graphics.setColor(LARANJA_CLARO)
            love.graphics.circle("fill", x, y, 7)
            love.graphics.setColor(BRANCO)
            love.graphics.circle("fill", x, y, 4)
            
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.print(tostring(disparos[indice].linha_origem), x - 5, y - 15)
        else
            love.graphics.setColor(PRETO)
            love.graphics.circle("fill", x, y, 7)
            love.graphics.setColor(AZUL)
            love.graphics.circle("fill", x, y, 6)
            love.graphics.setColor(BRANCO)
            love.graphics.circle("fill", x, y, 3)
        end
    elseif tipo == "esfera" then
        love.graphics.setColor(PRETO)
        love.graphics.circle("fill", x, y, 8)
        love.graphics.setColor(LARANJA_CLARO)
        love.graphics.circle("fill", x, y, 7)
        love.graphics.setColor(1, 200/255, 100/255)
        love.graphics.circle("fill", x, y, 4)
        
        love.graphics.setColor(LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.3)
        love.graphics.circle("fill", x - 5, y, 5)
        love.graphics.circle("fill", x - 10, y, 3)
    elseif tipo == "grande" then
        love.graphics.setColor(PRETO)
        love.graphics.circle("fill", x, y, 15)
        love.graphics.setColor(ROXO_CLARO)
        love.graphics.circle("fill", x, y, 14)
        love.graphics.setColor(BRANCO)
        love.graphics.circle("fill", x, y, 8)
    end
end