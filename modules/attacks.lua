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

function limpar_efeitos_ataque()
    ataque_triangulo_efeito = nil
    ataque_triangulo = nil
    triangulo_atacando = false
end