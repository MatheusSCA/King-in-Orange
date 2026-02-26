-- modules/fases.lua
-- Sistema de fases do jogo

-- Estados das fases
FASE_1 = 1  -- Esfera
FASE_2 = 2  -- Quadrado OU Triângulo (aleatório)
FASE_3 = 3  -- Inimigo não selecionado na fase 2
FASE_4 = 4  -- Esfera novamente

fase_atual_jogo = FASE_1
proxima_fase = FASE_2

-- Controle de seleção de inimigo para fase 2
inimigo_fase2 = nil  -- "quadrado" ou "triangulo" (escolhido aleatoriamente)
inimigo_nao_selecionado_fase2 = nil  -- O inimigo que não apareceu na fase 2

-- Mostrar tela de fase
MOSTRAR_TELA_FASE = false
TEMPO_TELA_FASE = 0
DURACAO_TELA_FASE = 2.0  -- 2 segundos mostrando a fase
TEXTO_FASE = ""

-- Textos descritivos para cada fase
function get_texto_fase()
    if fase_atual_jogo == FASE_1 then
        return "FASE 1 - ESFERA"
    elseif fase_atual_jogo == FASE_2 then
        if inimigo_fase2 == "quadrado" then
            return "FASE 2 - QUADRADO"
        elseif inimigo_fase2 == "triangulo" then
            return "FASE 2 - TRIÂNGULO"
        else
            return "FASE 2 - SORTEANDO INIMIGO..."
        end
    elseif fase_atual_jogo == FASE_3 then
        if inimigo_nao_selecionado_fase2 == "quadrado" then
            return "FASE 3 - QUADRADO"
        elseif inimigo_nao_selecionado_fase2 == "triangulo" then
            return "FASE 3 - TRIÂNGULO"
        end
        return "FASE 3 - INIMIGO RESTANTE"
    elseif fase_atual_jogo == FASE_4 then
        return "FASE 4 - ESFERA FINAL"
    end
    return "FASE DESCONHECIDA"
end

-- Função para sortear inimigo da fase 2
function sortear_inimigo_fase2()
    local random = love.math.random(1, 2)
    if random == 1 then
        inimigo_fase2 = "quadrado"
        inimigo_nao_selecionado_fase2 = "triangulo"
    else
        inimigo_fase2 = "triangulo"
        inimigo_nao_selecionado_fase2 = "quadrado"
    end
    print("Fase 2: Inimigo sorteado = " .. inimigo_fase2)
end

-- Função para avançar para a próxima fase
function avancar_fase()
    if fase_atual_jogo == FASE_1 then
        fase_atual_jogo = FASE_2
        proxima_fase = FASE_3
        -- Sortear inimigo para fase 2
        sortear_inimigo_fase2()
    elseif fase_atual_jogo == FASE_2 then
        fase_atual_jogo = FASE_3
        proxima_fase = FASE_4
    elseif fase_atual_jogo == FASE_3 then
        fase_atual_jogo = FASE_4
        proxima_fase = FASE_1  -- Volta para fase 1 após fase 4
    elseif fase_atual_jogo == FASE_4 then
        fase_atual_jogo = FASE_1
        proxima_fase = FASE_2
    end
    
    -- Resetar variáveis da fase
    resetar_variaveis_fase()
    
    print("Avançando para fase " .. fase_atual_jogo)
end

-- Função para resetar variáveis específicas da fase
function resetar_variaveis_fase()
    if fase_atual_jogo == FASE_1 then
        -- Fase 1: Apenas esfera
        desativar_triangulo()
        desativar_quadrados()
        resetar_esfera_para_fase()
        
    elseif fase_atual_jogo == FASE_2 then
        -- Fase 2: Quadrado OU Triângulo (aleatório)
        desativar_esfera()
        
        if inimigo_fase2 == "quadrado" then
            desativar_triangulo()
            resetar_quadrados_para_fase()  -- Reinicia os 3 quadrados
        elseif inimigo_fase2 == "triangulo" then
            desativar_quadrados()
            resetar_triangulo_para_fase()
        end
        
    elseif fase_atual_jogo == FASE_3 then
        -- Fase 3: Inimigo não selecionado na fase 2
        desativar_esfera()
        
        if inimigo_nao_selecionado_fase2 == "quadrado" then
            desativar_triangulo()
            resetar_quadrados_para_fase()
        elseif inimigo_nao_selecionado_fase2 == "triangulo" then
            desativar_quadrados()
            resetar_triangulo_para_fase()
        end
        
    elseif fase_atual_jogo == FASE_4 then
        -- Fase 4: Esfera novamente com DOBRO de vida e novos ataques
        desativar_triangulo()
        desativar_quadrados()
        -- Usar a nova função de inicialização da fase 4 (NÃO escolhe ataques ainda)
        if inicializar_esfera_fase4 then
            inicializar_esfera_fase4()
        else
            resetar_esfera_para_fase()
        end
    end
    
    TEXTO_FASE = get_texto_fase()
end

function fase_concluida()
    if fase_atual_jogo == FASE_1 then
        return VIDA_BOLA_INIMIGA <= 0
    elseif fase_atual_jogo == FASE_2 then
        if inimigo_fase2 == "quadrado" then
            return not quadrado_esta_vivo()  -- Verifica se todos os quadrados morreram
        elseif inimigo_fase2 == "triangulo" then
            return VIDA_TRIANGULO <= 0
        end
    elseif fase_atual_jogo == FASE_3 then
        if inimigo_nao_selecionado_fase2 == "quadrado" then
            return not quadrado_esta_vivo()
        elseif inimigo_nao_selecionado_fase2 == "triangulo" then
            return VIDA_TRIANGULO <= 0
        end
    elseif fase_atual_jogo == FASE_4 then
        return VIDA_BOLA_INIMIGA <= 0
    end
    return false
end

function get_cor_fase()
    if fase_atual_jogo == FASE_1 then
        return LARANJA_CLARO
    elseif fase_atual_jogo == FASE_2 then
        return AMARELO  -- Amarelo para o quadrado
    elseif fase_atual_jogo == FASE_3 then
        if inimigo_nao_selecionado_fase2 == "quadrado" then
            return AMARELO
        else
            return ROXO_CLARO  -- Roxo para o triângulo
        end
    else
        return CIANO
    end
end

-- Função para iniciar a tela de fase
function mostrar_tela_fase()
    MOSTRAR_TELA_FASE = true
    TEMPO_TELA_FASE = 0
    -- Atualizar texto da fase
    TEXTO_FASE = get_texto_fase()
end

-- Função para atualizar a tela de fase
function atualizar_tela_fase(dt)
    if MOSTRAR_TELA_FASE then
        TEMPO_TELA_FASE = TEMPO_TELA_FASE + dt
        if TEMPO_TELA_FASE >= DURACAO_TELA_FASE then
            MOSTRAR_TELA_FASE = false
            TEMPO_TELA_FASE = 0
            -- Inicia o aparecimento dos inimigos
            PARTIDA_INICIANDO = true
            INIMIGOS_APARECENDO = true
        end
    end
end

-- Função para desenhar a tela de fase
function desenhar_tela_fase()
    if MOSTRAR_TELA_FASE then
        -- Fundo preto semi-transparente
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
        
        -- Quadrado central
        local largura_quad = 700
        local altura_quad = 350
        local x_quad = JANELA_LARGURA/2 - largura_quad/2
        local y_quad = JANELA_ALTURA/2 - altura_quad/2
        
        -- Fundo do quadrado
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", x_quad, y_quad, largura_quad, altura_quad, 20)
        
        -- Borda que muda conforme a fase
        local cor_borda
        if fase_atual_jogo == FASE_1 then
            cor_borda = LARANJA_CLARO  -- Esfera
        elseif fase_atual_jogo == FASE_2 then
            cor_borda = AMARELO  -- Quadrado/Triângulo
        elseif fase_atual_jogo == FASE_3 then
            cor_borda = ROXO_CLARO  -- Inimigo restante
        else
            cor_borda = CIANO  -- Esfera final
        end
        
        love.graphics.setColor(cor_borda)
        love.graphics.setLineWidth(6)
        love.graphics.rectangle("line", x_quad, y_quad, largura_quad, altura_quad, 20)
        
        -- Texto "FASE"
        love.graphics.setFont(fonte_pausa or love.graphics.newFont(64))
        love.graphics.setColor(cor_borda)
        local texto_fase = "FASE " .. fase_atual_jogo
        local largura_fase = love.graphics.getFont():getWidth(texto_fase)
        love.graphics.print(texto_fase, 
            JANELA_LARGURA/2 - largura_fase/2, 
            y_quad + 50)
        
        -- Descrição da fase
        love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(32))
        love.graphics.setColor(BRANCO)
        
        -- Quebrar texto em múltiplas linhas
        local linhas = {}
        
        -- Dividir TEXTO_FASE em palavras e agrupar em linhas
        local palavras = {}
        for palavra in TEXTO_FASE:gmatch("%S+") do
            table.insert(palavras, palavra)
        end
        
        local linha_atual = ""
        for i, palavra in ipairs(palavras) do
            if #linha_atual + #palavra + 1 <= 30 then
                if #linha_atual == 0 then
                    linha_atual = palavra
                else
                    linha_atual = linha_atual .. " " .. palavra
                end
            else
                table.insert(linhas, linha_atual)
                linha_atual = palavra
            end
        end
        if #linha_atual > 0 then
            table.insert(linhas, linha_atual)
        end
        
        -- Desenhar linhas
        local y_texto = y_quad + 150
        for i, linha in ipairs(linhas) do
            local largura_linha = love.graphics.getFont():getWidth(linha)
            love.graphics.print(linha, 
                JANELA_LARGURA/2 - largura_linha/2, 
                y_texto + (i-1) * 40)
        end
        
        -- Instrução
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.setColor(1, 1, 1, 0.7)
        local texto_inst = "Pressione Z para começar"
        local largura_inst = love.graphics.getFont():getWidth(texto_inst)
        love.graphics.print(texto_inst, 
            JANELA_LARGURA/2 - largura_inst/2, 
            y_quad + 280)
        
        -- Instrução para pular fase (Y)
        if fase_atual_jogo < 4 then
            local texto_pular = "Pressione Y para pular para próxima fase"
            love.graphics.setColor(ROXO_CLARO)
            love.graphics.print(texto_pular, 
                JANELA_LARGURA/2 - love.graphics.getFont():getWidth(texto_pular)/2, 
                y_quad + 310)
        end
    end
end

-- Função para verificar se todos os inimigos da fase atual estão mortos
function fase_concluida()
    if fase_atual_jogo == FASE_1 then
        return VIDA_BOLA_INIMIGA <= 0
    elseif fase_atual_jogo == FASE_2 then
        if inimigo_fase2 == "quadrado" then
            return VIDA_QUADRADO <= 0
        elseif inimigo_fase2 == "triangulo" then
            return VIDA_TRIANGULO <= 0
        end
    elseif fase_atual_jogo == FASE_3 then
        if inimigo_nao_selecionado_fase2 == "quadrado" then
            return VIDA_QUADRADO <= 0
        elseif inimigo_nao_selecionado_fase2 == "triangulo" then
            return VIDA_TRIANGULO <= 0
        end
    elseif fase_atual_jogo == FASE_4 then
        return VIDA_BOLA_INIMIGA <= 0
    end
    return false
end

-- Função para resetar o jogo para a fase 1
function resetar_para_fase1()
    fase_atual_jogo = FASE_1
    proxima_fase = FASE_2
    inimigo_fase2 = nil
    inimigo_nao_selecionado_fase2 = nil
    resetar_variaveis_fase()
end

-- Função para obter a cor da borda da fase atual
function get_cor_fase()
    if fase_atual_jogo == FASE_1 then
        return LARANJA_CLARO
    elseif fase_atual_jogo == FASE_2 then
        return AMARELO
    elseif fase_atual_jogo == FASE_3 then
        return ROXO_CLARO
    else
        return CIANO
    end
end