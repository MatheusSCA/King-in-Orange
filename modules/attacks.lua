-- modules/attacks.lua
-- Funções de ataques

ataque_triangulo_efeito = nil
tempo_ataque_triangulo_efeito = 0
DURACAO_EFEITO_TRIANGULO = 1.0

function atualizar_ataques(tempo_atual)
    -- Ataque do triângulo (apenas se estiver vivo)
    if VIDA_TRIANGULO > 0 then
        criar_ataque_triangulo()
        atualizar_ataque_triangulo()
    end
    
    -- Ataque do quadrado (apenas se estiver vivo)
    if VIDA_QUADRADO > 0 then
        criar_disparo_quadrado()
    end
end

function criar_ataque_triangulo()
    if VIDA_TRIANGULO <= 0 then
        return false
    end
    
    local tempo_atual = love.timer.getTime() * 1000
    
    if tempo_atual - tempo_ultimo_ataque_triangulo >= INTERVALO_ATAQUE_TRIANGULO then
        local coluna_ataque = love.math.random(1, 3)
        
        ataque_triangulo = {
            coluna = coluna_ataque,
            inicio = tempo_atual,
            dano = 90
        }
        
        tempo_ultimo_ataque_triangulo = tempo_atual
        triangulo_atacando = true
        return true
    end
    
    return false
end

function criar_disparo_quadrado()
    if VIDA_QUADRADO <= 0 then
        return false
    end
    
    local tempo_atual = love.timer.getTime() * 1000
    
    if tempo_atual - tempo_ultimo_disparo_quadrado >= intervalo_disparo_quadrado and 
       #disparos_quadrado < MAX_TIROS_QUADRADO then
        
        local celula_quadrado = GRID_CELULAS[pos_quadrado[1]][pos_quadrado[2]]
        local inicio_x = celula_quadrado.centro_x - tamanho_quadrado - 10
        local inicio_y = celula_quadrado.centro_y
        
        table.insert(disparos_quadrado, {
            x = inicio_x,
            y = inicio_y,
            velocidade = -8,
            tipo = 'quadrado',
            dano = 40
        })
        
        tempo_ultimo_disparo_quadrado = tempo_atual
        quadrado_atacando = true
        return true
    end
    
    return false
end

function atualizar_ataque_triangulo()
    if ataque_triangulo then
        local tempo_atual = love.timer.getTime() * 1000
        local tempo_decorrido = tempo_atual - ataque_triangulo.inicio
        
        if tempo_decorrido >= DURACAO_ATAQUE_TRIANGULO then
            -- Verifica se o jogador está na coluna do ataque
            if pos_bola[2] == ataque_triangulo.coluna and not imune_dano then
                -- A bola do jogador perde vida
                VIDA_JOGADOR = VIDA_JOGADOR - ataque_triangulo.dano
                if VIDA_JOGADOR < 0 then
                    VIDA_JOGADOR = 0
                end
                print("Bola do jogador atingida pelo ataque do triângulo! Dano: " .. ataque_triangulo.dano)
            end
            
            ataque_triangulo_efeito = {
                coluna = ataque_triangulo.coluna,
                inicio = tempo_atual
            }
            tempo_ataque_triangulo_efeito = tempo_atual
            
            coluna_transparente = ataque_triangulo.coluna
            tempo_coluna_transparente = tempo_atual
            
            ataque_triangulo = nil
            triangulo_atacando = false
            return true
        end
        
        return false
    end
    
    return true
end

function desenhar_ataque_triangulo()
    -- Efeito durante o ataque (pulsante)
    if ataque_triangulo then
        local tempo_atual = love.timer.getTime() * 1000
        local tempo_decorrido = tempo_atual - ataque_triangulo.inicio
        
        if tempo_decorrido < DURACAO_ATAQUE_TRIANGULO then
            local frequencia = 5 + (tempo_decorrido / DURACAO_ATAQUE_TRIANGULO) * 10
            local piscar = math.sin(tempo_decorrido * 0.01 * frequencia) > 0
            
            if piscar then
                local coluna_ataque = ataque_triangulo.coluna
                
                for linha = 1, NUM_LINHAS do
                    local celula = GRID_CELULAS[linha][coluna_ataque]
                    
                    love.graphics.setColor(1, 150/255, 0, 0.6)
                    love.graphics.rectangle("fill", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                    
                    love.graphics.setColor(1, 200/255, 100/255)
                    love.graphics.setLineWidth(4)
                    love.graphics.rectangle("line", 
                        celula.x, celula.y, 
                        celula.width, celula.height
                    )
                end
                
                local primeira_celula = GRID_CELULAS[1][coluna_ataque]
                local ultima_celula = GRID_CELULAS[NUM_LINHAS][coluna_ataque]
                
                local centro_x = primeira_celula.centro_x
                local y_inicio = primeira_celula.y
                local y_fim = ultima_celula.y + ultima_celula.height
                
                love.graphics.setColor(1, 1, 200/255)
                love.graphics.setLineWidth(2)
                for i = 1, 3 do
                    love.graphics.line(
                        centro_x - 2 + (i-1)*2, y_inicio,
                        centro_x - 2 + (i-1)*2, y_fim
                    )
                end
                
                for _, linha in ipairs({1, NUM_LINHAS}) do
                    local celula = GRID_CELULAS[linha][coluna_ataque]
                    local centro = {celula.centro_x, celula.centro_y}
                    
                    local raio = 10 + math.sin(tempo_decorrido * 0.02) * 5
                    love.graphics.setColor(1, 1, 100/255, 0.7)
                    love.graphics.circle("fill", centro[1], centro[2], raio)
                    
                    love.graphics.setColor(1, 1, 1, 0.8)
                    love.graphics.circle("fill", centro[1], centro[2], raio/2)
                end
            end
        end
    end
    
    -- Efeito APÓS o ataque (ciano sólido, similar à carta 3)
    if ataque_triangulo_efeito then
        local tempo_atual = love.timer.getTime() * 1000
        local tempo_decorrido = (tempo_atual - ataque_triangulo_efeito.inicio) / 1000
        
        if tempo_decorrido < DURACAO_EFEITO_TRIANGULO then
            local coluna_efeito = ataque_triangulo_efeito.coluna
            
            -- Efeito de fade out suave
            local opacidade = 0.7 * (1 - (tempo_decorrido / DURACAO_EFEITO_TRIANGULO))
            
            for linha = 1, NUM_LINHAS do
                local celula = GRID_CELULAS[linha][coluna_efeito]
                
                -- Efeito ciano (similar à carta 3)
                love.graphics.setColor(CIANO[1], CIANO[2], CIANO[3], opacidade * 0.5)
                love.graphics.rectangle("fill", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                -- Borda ciano mais forte
                love.graphics.setColor(0, 0.8, 1, opacidade)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", 
                    celula.x, celula.y, 
                    celula.width, celula.height
                )
                
                -- Efeito de brilho no centro
                local centro_x = celula.centro_x
                local centro_y = celula.centro_y
                local tamanho_brilho = 20 + math.sin(tempo_decorrido * 10) * 5
                
                love.graphics.setColor(1, 1, 1, opacidade * 0.3)
                love.graphics.circle("fill", centro_x, centro_y, tamanho_brilho)
                
                -- Texto "!" no centro (opcional)
                if opacidade > 0.3 then
                    local fonte_temp = fonte_instrucoes or love.graphics.newFont(24)
                    love.graphics.setFont(fonte_temp)
                    love.graphics.setColor(0, 0, 0, opacidade)
                    love.graphics.print("!", centro_x - fonte_temp:getWidth("!")/2, centro_y - fonte_temp:getHeight()/2)
                end
            end
            
            -- Linha vertical no centro da coluna (efeito de "corte")
            local primeira_celula = GRID_CELULAS[1][coluna_efeito]
            local ultima_celula = GRID_CELULAS[NUM_LINHAS][coluna_efeito]
            
            local centro_x = primeira_celula.centro_x
            local y_inicio = primeira_celula.y
            local y_fim = ultima_celula.y + ultima_celula.height
            
            love.graphics.setColor(0, 1, 1, opacidade * 0.8)
            love.graphics.setLineWidth(2)
            love.graphics.line(centro_x, y_inicio, centro_x, y_fim)
            
            -- Pontos brilhantes no topo e base
            love.graphics.setColor(1, 1, 1, opacidade)
            local raio_ponto = 8 * (1 - tempo_decorrido / DURACAO_EFEITO_TRIANGULO)
            love.graphics.circle("fill", centro_x, y_inicio + 10, raio_ponto)
            love.graphics.circle("fill", centro_x, y_fim - 10, raio_ponto)
            
        else
            -- Remove o efeito quando o tempo acabar
            ataque_triangulo_efeito = nil
        end
    end
end

function limpar_efeitos_ataque()
    ataque_triangulo_efeito = nil
    ataque_triangulo = nil
    triangulo_atacando = false
end