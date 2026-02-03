-- modules/ui.lua (versão atualizada)
-- Funções de interface do usuário

function desenhar_personagens()
    -- Esta função é mantida para compatibilidade, mas será substituída por desenhar_personagens_completos
    desenhar_personagens_completos()
end

function desenhar_ui()
    desenhar_numeros_vida()
    desenhar_nome_carta_usada()
end

function desenhar_texto_com_borda(fonte, texto, x, y, cor)
    if fonte == nil then
        local fonte_temp = love.graphics.getFont()
        if fonte_temp == nil then
            fonte_temp = love.graphics.newFont(12)
        end
        love.graphics.setFont(fonte_temp)
    else
        love.graphics.setFont(fonte)
    end
    
    -- Desenha borda
    love.graphics.setColor(PRETO)
    love.graphics.print(texto, x-1, y-1)
    love.graphics.print(texto, x+1, y-1)
    love.graphics.print(texto, x-1, y+1)
    love.graphics.print(texto, x+1, y+1)
    
    -- Desenha texto principal
    love.graphics.setColor(cor)
    love.graphics.print(texto, x, y)
end

function desenhar_numeros_vida()
    local fonte_para_usar = fonte_vida or love.graphics.newFont(48)
    
    -- Vida do jogador
    local texto_jogador = VIDA_JOGADOR
    desenhar_texto_com_borda(fonte_para_usar, texto_jogador, 
        OFFSET_X + 50, OFFSET_Y - 100, ROXO_CLARO)
    
    -- Vida do triângulo
    if VIDA_TRIANGULO > 0 and pos_triangulo[1] > 0 then
        local celula_triangulo = GRID_CELULAS[pos_triangulo[1]][pos_triangulo[2]]
        local texto_vida_triangulo = tostring(VIDA_TRIANGULO)
        local largura_texto_triangulo = fonte_para_usar:getWidth(texto_vida_triangulo)
        local pos_x_triangulo = celula_triangulo.centro_x - largura_texto_triangulo / 2
        
        local pos_y_triangulo
        if pos_triangulo[1] == 3 then
            pos_y_triangulo = celula_triangulo.y - 45
        else
            pos_y_triangulo = celula_triangulo.y + celula_triangulo.height + 30
        end
        
        desenhar_texto_com_borda(fonte_para_usar, texto_vida_triangulo, 
            pos_x_triangulo, pos_y_triangulo, LARANJA_CLARO)
    end
    
    -- Vida do quadrado
    if VIDA_QUADRADO > 0 and pos_quadrado[1] > 0 then
        local celula_quadrado = GRID_CELULAS[pos_quadrado[1]][pos_quadrado[2]]
        local texto_vida_quadrado = tostring(VIDA_QUADRADO)
        local largura_texto_quadrado = fonte_para_usar:getWidth(texto_vida_quadrado)
        local pos_x_quadrado = celula_quadrado.centro_x - largura_texto_quadrado / 2
        
        local pos_y_quadrado
        if pos_quadrado[1] == 3 then
            pos_y_quadrado = celula_quadrado.y - 45
        else
            pos_y_quadrado = celula_quadrado.y + celula_quadrado.height + 30
        end
        
        desenhar_texto_com_borda(fonte_para_usar, texto_vida_quadrado, 
            pos_x_quadrado, pos_y_quadrado, AMARELO)
    end
    
    --Vida da bola inimiga
    if VIDA_BOLA_INIMIGA > 0 and pos_bola_inimiga[1] > 0 then
        local celula_bola_inimiga = GRID_CELULAS[pos_bola_inimiga[1]][pos_bola_inimiga[2]]
        local texto_vida_bola_inimiga = tostring(VIDA_BOLA_INIMIGA)
        local largura_texto_bola_inimiga = fonte_para_usar:getWidth(texto_vida_bola_inimiga)
        local pos_x_bola_inimiga = celula_bola_inimiga.centro_x - largura_texto_bola_inimiga / 2
        
        local pos_y_bola_inimiga
        if pos_bola_inimiga[1] == 3 then
            pos_y_bola_inimiga = celula_bola_inimiga.y - 45
        else
            pos_y_bola_inimiga = celula_bola_inimiga.y + celula_bola_inimiga.height + 30
        end
        
        desenhar_texto_com_borda(fonte_para_usar, texto_vida_bola_inimiga, 
            pos_x_bola_inimiga, pos_y_bola_inimiga, LARANJA_CLARO)
    end
end

function desenhar_botao_pause()
    if JOGO_PAUSADO then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
        
        local fonte_pausa_usar = fonte_pausa or love.graphics.newFont(72)
        local fonte_instrucoes_usar = fonte_instrucoes or love.graphics.newFont(24)
        
        local texto = "PAUSADO"
        local largura_texto = fonte_pausa_usar:getWidth(texto)
        desenhar_texto_com_borda(fonte_pausa_usar, texto, 
            JANELA_LARGURA/2 - largura_texto/2, JANELA_ALTURA/2 - 50, BRANCO)
        
        local instrucao = "Pressione ESC para continuar"
        largura_texto = fonte_instrucoes_usar:getWidth(instrucao)
        desenhar_texto_com_borda(fonte_instrucoes_usar, instrucao,
            JANELA_LARGURA/2 - largura_texto/2, JANELA_ALTURA/2 + 30, BRANCO)
    end
end