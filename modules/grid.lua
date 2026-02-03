-- modules/grid.lua
-- Funções relacionadas ao grid

function criar_grid()
    for linha = 1, NUM_LINHAS do
        local linha_celulas = {}
        for coluna = 1, NUM_COLUNAS do
            local cor_fundo, cor_borda, tipo
            
            -- Determina cor baseado na coluna
            if coluna < 4 then  -- Lado esquerdo (do jogador)
                cor_fundo = ROXO_ESCURO
                cor_borda = ROXO_CLARO
                tipo = "azul"
            else  -- Lado direito (do inimigo)
                cor_fundo = LARANJA_ESCURO
                cor_borda = LARANJA_CLARO
                tipo = "vermelho"
            end
            
            -- Calcula posição da célula
            local x = OFFSET_X + (coluna - 1) * LARGURA_CELULA
            local y = OFFSET_Y + (linha - 1) * ALTURA_CELULA
            
            linha_celulas[coluna] = {
                x = x,
                y = y,
                width = LARGURA_CELULA,
                height = ALTURA_CELULA,
                cor_fundo = cor_fundo,
                cor_borda = cor_borda,
                tipo = tipo,
                centro_x = x + LARGURA_CELULA / 2,
                centro_y = y + ALTURA_CELULA / 2,
                linha = linha,
                coluna = coluna,
                transparente = false,
                tempo_transparente = 0
            }
        end
        GRID_CELULAS[linha] = linha_celulas
    end
end

function desenhar_grid()
    -- Fundo do grid
    love.graphics.setColor(30/255, 30/255, 50/255, 0.8)
    love.graphics.rectangle("fill",
        OFFSET_X - 20, OFFSET_Y - 20,
        NUM_COLUNAS * LARGURA_CELULA + 40,
        NUM_LINHAS * ALTURA_CELULA + 40
    )
    
    -- Desenha cada célula do grid
    for linha = 1, NUM_LINHAS do
        for coluna = 1, NUM_COLUNAS do
            local celula = GRID_CELULAS[linha][coluna]
            
            -- Verifica se é coluna cedida pela carta 9
            local eh_coluna_cedida = false
            for _, coluna_cedida in ipairs(colunas_cedidas) do
                if coluna == coluna_cedida.coluna then
                    eh_coluna_cedida = true
                    break
                end
            end
            
            -- Determina cor baseado no tipo e se é cedida
            local cor_fundo, cor_borda
            
            if eh_coluna_cedida then
                -- Coluna cedida: mostra como área inimiga
                cor_fundo = LARANJA_ESCURO
                cor_borda = LARANJA_CLARO
            else
                -- Normal
                if coluna < 4 then  -- Lado esquerdo (do jogador)
                    cor_fundo = ROXO_ESCURO
                    cor_borda = ROXO_CLARO
                else  -- Lado direito (do inimigo)
                    cor_fundo = LARANJA_ESCURO
                    cor_borda = LARANJA_CLARO
                end
            end
            
            -- Aplica as cores
            love.graphics.setColor(cor_fundo)
            love.graphics.rectangle("fill", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
            
            love.graphics.setColor(cor_borda)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
            
            love.graphics.setLineWidth(1)
            for i = 1, 2 do
                -- Linhas horizontais
                love.graphics.setColor(
                    celula.cor_borda[1]/2,
                    celula.cor_borda[2]/2,
                    celula.cor_borda[3]/2
                )
                love.graphics.line(
                    celula.x, celula.y + i * ALTURA_CELULA/3,
                    celula.x + celula.width, celula.y + i * ALTURA_CELULA/3
                )
                
                -- Linhas verticais
                love.graphics.line(
                    celula.x + i * LARGURA_CELULA/3, celula.y,
                    celula.x + i * LARGURA_CELULA/3, celula.y + celula.height
                )
            end
        end
    end
    
    -- Linha divisória central
    love.graphics.setColor(PRETO)
    love.graphics.setLineWidth(4)
    love.graphics.line(
        OFFSET_X + 3 * LARGURA_CELULA, OFFSET_Y - 10,
        OFFSET_X + 3 * LARGURA_CELULA, OFFSET_Y + NUM_LINHAS * ALTURA_CELULA + 10
    )
end

function aplicar_efeito_transparencia()
    if coluna_transparente then
        local tempo_atual = love.timer.getTime() * 1000
        local tempo_decorrido = tempo_atual - tempo_coluna_transparente
        
        if tempo_decorrido < DURACAO_TRANSPARENCIA then
            local opacidade = 0.6 * (1 - tempo_decorrido / DURACAO_TRANSPARENCIA)
            
            for linha = 1, NUM_LINHAS do
                local celula = GRID_CELULAS[linha][coluna_transparente]
                
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
        else
            coluna_transparente = nil
        end
    end
end