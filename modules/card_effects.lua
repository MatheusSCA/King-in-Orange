-- modules/card_effects.lua
-- Efeitos visuais unificados para todas as cartas

-- VARIÁVEIS COMPARTILHADAS
carta_em_efeito = false
carta_efeito_tipo = nil  -- "carta7" ou "carta10"
carta_efeito_tempo = 0
carta_efeito_duracao = 1.5
carta_efeito_dados = {}  -- Dados específicos de cada carta

-- FUNÇÕES DE ATIVAÇÃO

function ativar_efeito_carta7(numero_sorteado)
    carta_em_efeito = true
    carta_efeito_tipo = "carta7"
    carta_efeito_tempo = 0
    carta_efeito_duracao = 1.5
    carta_efeito_dados = {
        numero = numero_sorteado,
        preparacao_completa = (numero_sorteado == 7),
        barra_original = barra_customizacao
    }
    
    -- Se não for 7, aplica o efeito normal
    if numero_sorteado == 1 then
        bloqueado_movimento = true
        bloqueado_ataque = true
        tempo_bloqueio = CARTA7_BLOQUEIO_TEMPO
    end
    
    print("Efeito Carta 7 ativado - Número: " .. numero_sorteado)
end

function ativar_efeito_carta10(dano_calculado, cartas_unicas)
    carta_em_efeito = true
    carta_efeito_tipo = "carta10"
    carta_efeito_tempo = 0
    carta_efeito_duracao = 1.5
    carta_efeito_dados = {
        dano = dano_calculado,
        cartas_unicas = cartas_unicas,
        contagem = #cartas_unicas
    }
    
    print("Efeito Carta 10 ativado - Dano: " .. dano_calculado .. " (x=" .. #cartas_unicas .. ")")
end

-- ATUALIZAÇÃO

function atualizar_efeitos_carta(dt)
    if carta_em_efeito then
        carta_efeito_tempo = carta_efeito_tempo + dt
        
        -- Finaliza o efeito
        if carta_efeito_tempo >= carta_efeito_duracao then
            finalizar_efeito_carta()
        end
    end
end

function finalizar_efeito_carta()
    if carta_efeito_tipo == "carta7" then
        -- Aplica o efeito da Carta 7 no final da animação
        if carta_efeito_dados.preparacao_completa then
            barra_customizacao = MAX_BARRA_CUSTOMIZACAO
            print("Carta 7: Barra de preparação completada!")
        end
    elseif carta_efeito_tipo == "carta10" then
        -- Aplica o dano da Carta 10 no final da animação
        aplicar_dano_carta10_final()
    end
    
    -- Reseta as variáveis
    carta_em_efeito = false
    carta_efeito_tipo = nil
    carta_efeito_dados = {}
    print("Efeito de carta finalizado")
end

function aplicar_dano_carta10_final()
    local dano = carta_efeito_dados.dano
    local inimigos_atingidos = {}
    
    -- Aplica dano a todos os inimigos vivos
    if VIDA_TRIANGULO > 0 then
        VIDA_TRIANGULO = math.max(0, VIDA_TRIANGULO - dano)
        table.insert(inimigos_atingidos, "Triângulo")
        print("Carta 10: Triângulo sofreu " .. dano .. " de dano!")
    end
    
    if VIDA_QUADRADO > 0 then
        VIDA_QUADRADO = math.max(0, VIDA_QUADRADO - dano)
        table.insert(inimigos_atingidos, "Quadrado")
        print("Carta 10: Quadrado sofreu " .. dano .. " de dano!")
    end
    
    if VIDA_BOLA_INIMIGA > 0 then
        VIDA_BOLA_INIMIGA = math.max(0, VIDA_BOLA_INIMIGA - dano)
        table.insert(inimigos_atingidos, "Bola Inimiga")
        print("Carta 10: Bola Inimiga sofreu " .. dano .. " de dano!")
    end
    
    -- Armazena quais inimigos foram atingidos para o efeito visual
    carta_efeito_dados.inimigos_atingidos = inimigos_atingidos
end

-- FUNÇÕES DE DESENHO - CARTA 7

function desenhar_efeito_carta7()
    if not (carta_em_efeito and carta_efeito_tipo == "carta7") then return end
    
    -- Fundo preto semi-transparente
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- Quadrado central para o número
    local largura_quadrado = 300
    local altura_quadrado = 300
    local x_quad = JANELA_LARGURA/2 - largura_quadrado/2
    local y_quad = JANELA_ALTURA/2 - altura_quadrado/2
    
    -- Fundo do quadrado
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", x_quad, y_quad, largura_quadrado, altura_quadrado, 20)
    
    -- Borda que muda de cor se for 7
    local numero = carta_efeito_dados.numero
    if numero == 7 then
        local tempo = love.timer.getTime() * 3
        local r = math.sin(tempo) * 0.5 + 0.5
        local g = math.sin(tempo + 2) * 0.5 + 0.5
        local b = math.sin(tempo + 4) * 0.5 + 0.5
        love.graphics.setColor(r, g, b, 1)
    else
        love.graphics.setColor(LARANJA_CLARO)
    end
    
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", x_quad, y_quad, largura_quadrado, altura_quadrado, 20)
    
    -- Texto "CARTA 7"
    local fonte_titulo = fonte_pausa or love.graphics.newFont(36)
    love.graphics.setFont(fonte_titulo)
    love.graphics.setColor(CIANO)
    local texto_titulo = "CARTA 7"
    local largura_titulo = fonte_titulo:getWidth(texto_titulo)
    love.graphics.print(texto_titulo, 
        x_quad + largura_quadrado/2 - largura_titulo/2, 
        y_quad + 40)
    
    -- Número sorteado (grande)
    local fonte_numero = love.graphics.newFont(120)
    love.graphics.setFont(fonte_numero)
    
    if numero == 7 then
        local brilho = 0.7 + math.sin(love.timer.getTime() * 10) * 0.3
        love.graphics.setColor(1, brilho, 0, 1)
    else
        love.graphics.setColor(BRANCO)
    end
    
    local texto_numero = tostring(numero)
    local largura_numero = fonte_numero:getWidth(texto_numero)
    love.graphics.print(texto_numero, 
        x_quad + largura_quadrado/2 - largura_numero/2, 
        y_quad + altura_quadrado/2 - 40)
    
    -- Texto descritivo
    local fonte_desc = fonte_instrucoes or love.graphics.newFont(24)
    love.graphics.setFont(fonte_desc)
    love.graphics.setColor(BRANCO)
    
    local descricao
    if numero == 1 then
        descricao = "Jogador bloqueado!"
    elseif numero == 7 then
        descricao = "BARRA DE PREPARAÇÃO COMPLETA!"
        love.graphics.setColor(VERDE)
    else
        descricao = "Número sem efeito especial"
    end
    
    local largura_desc = fonte_desc:getWidth(descricao)
    love.graphics.print(descricao, 
        x_quad + largura_quadrado/2 - largura_desc/2, 
        y_quad + altura_quadrado - 60)
    
    -- Desenha o efeito da barra se for número 7
    if numero == 7 then
        desenhar_efeito_barra_carta7()
    end
end

function desenhar_efeito_barra_carta7()
    local largura_barra = 300
    local altura_barra = 20
    local x = JANELA_LARGURA/2 - largura_barra/2
    local y = JANELA_ALTURA/2 + 150
    
    -- Título
    local fonte_temp = fonte_instrucoes or love.graphics.newFont(20)
    love.graphics.setFont(fonte_temp)
    love.graphics.setColor(CIANO)
    local texto_titulo = "EFEITO DA CARTA 7"
    local largura_titulo = fonte_temp:getWidth(texto_titulo)
    love.graphics.print(texto_titulo, x + largura_barra/2 - largura_titulo/2, y - 30)
    
    -- Fundo da barra
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, largura_barra, altura_barra, 5)
    
    -- Efeito de piscar
    local piscar = math.sin(love.timer.getTime() * CARTA7_ANIMACAO_VELOCIDADE) > 0
    local valor_atual = carta_efeito_dados.barra_original
    local largura_atual = largura_barra * (valor_atual / MAX_BARRA_CUSTOMIZACAO)
    
    if piscar then
        love.graphics.setColor(VERDE[1], VERDE[2], VERDE[3], 1)
        love.graphics.rectangle("fill", x, y, largura_barra, altura_barra, 5)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", x, y, largura_barra, altura_barra/2, 5)
    else
        if valor_atual > 0 then
            love.graphics.setColor(ROXO_CLARO)
            love.graphics.rectangle("fill", x, y, largura_atual, altura_barra, 5)
        end
        if largura_atual < largura_barra then
            love.graphics.setColor(0.5, 0.5, 0.5, 0.3)
            love.graphics.rectangle("fill", x + largura_atual, y, largura_barra - largura_atual, altura_barra, 5)
        end
    end
    
    -- Borda
    love.graphics.setColor(BRANCO)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, largura_barra, altura_barra, 5)
    
    -- Setas
    local num_setas = 3
    for i = 1, num_setas do
        local t = i / (num_setas + 1)
        local x_seta = x + largura_barra * t
        local y_seta = y - 15
        
        if piscar then
            love.graphics.setColor(VERDE)
        else
            love.graphics.setColor(CIANO)
        end
        
        love.graphics.polygon("fill", 
            x_seta, y_seta,
            x_seta - 8, y_seta - 8,
            x_seta + 8, y_seta - 8
        )
    end
    
    -- Texto explicativo
    love.graphics.setFont(fonte_temp)
    love.graphics.setColor(VERDE)
    local texto_explicativo = "COMPLETANDO BARRA..."
    local largura_explicativo = fonte_temp:getWidth(texto_explicativo)
    love.graphics.print(texto_explicativo, 
        x + largura_barra/2 - largura_explicativo/2, 
        y + altura_barra + 15)
end

-- FUNÇÕES DE DESENHO - CARTA 10

function desenhar_efeito_carta10()
    if not (carta_em_efeito and carta_efeito_tipo == "carta10") then return end
    
    -- Fundo preto semi-transparente
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- Área do grid (para desenhar dentro do viewport)
    love.graphics.setScissor(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT, JOGO_LARGURA, JOGO_ALTURA)
    love.graphics.translate(OFFSET_X_VIEWPORT, OFFSET_Y_VIEWPORT)
    
    -- FAZER AS ZONAS INIMIGAS PISCAREM EM ROXO
    local piscar = math.sin(love.timer.getTime() * 8) > 0  -- Pisca rápido
    
    for linha = 1, NUM_LINHAS do
        for coluna = 4, NUM_COLUNAS do  -- Apenas colunas inimigas (4-6)
            local celula = GRID_CELULAS[linha][coluna]
            
            -- Cor roxa com opacidade variável
            local opacidade = 0.7
            if piscar then
                opacidade = 0.9
            end
            
            love.graphics.setColor(ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], opacidade)
            love.graphics.rectangle("fill", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
            
            -- Borda mais forte
            love.graphics.setColor(ROXO_ESCURO[1], ROXO_ESCURO[2], ROXO_ESCURO[3], opacidade * 1.2)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", 
                celula.x, celula.y, 
                celula.width, celula.height
            )
        end
    end
    
    -- Reset da transformação
    love.graphics.origin()
    love.graphics.setScissor()
    
    -- QUADRADO CENTRAL COM INFORMAÇÕES DA CARTA 10
    local largura_quadrado = 400
    local altura_quadrado = 300
    local x_quad = JANELA_LARGURA/2 - largura_quadrado/2
    local y_quad = JANELA_ALTURA/2 - altura_quadrado/2
    
    -- Fundo do quadrado
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", x_quad, y_quad, largura_quadrado, altura_quadrado, 20)
    
    -- Borda roxa
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", x_quad, y_quad, largura_quadrado, altura_quadrado, 20)
    
    -- Título
    local fonte_titulo = fonte_pausa or love.graphics.newFont(36)
    love.graphics.setFont(fonte_titulo)
    love.graphics.setColor(ROXO_CLARO)
    local texto_titulo = "CARTA 10"
    local largura_titulo = fonte_titulo:getWidth(texto_titulo)
    love.graphics.print(texto_titulo, 
        x_quad + largura_quadrado/2 - largura_titulo/2, 
        y_quad + 30)
    
    -- Fórmula do dano
    local fonte_desc = fonte_instrucoes or love.graphics.newFont(20)
    love.graphics.setFont(fonte_desc)
    love.graphics.setColor(BRANCO)
    local texto_formula = "Dano = x² × 10"
    local largura_formula = fonte_desc:getWidth(texto_formula)
    love.graphics.print(texto_formula, 
        x_quad + largura_quadrado/2 - largura_formula/2, 
        y_quad + 80)
    
    -- Cartas únicas usadas
    local x_unicas = x_quad + 30
    local y_unicas = y_quad + 120
    love.graphics.setColor(CIANO)
    love.graphics.print("Cartas únicas usadas:", x_unicas, y_unicas)
    
    love.graphics.setColor(BRANCO)
    local cartas_texto = ""
    for i, carta_id in ipairs(carta_efeito_dados.cartas_unicas) do
        cartas_texto = cartas_texto .. carta_id
        if i < #carta_efeito_dados.cartas_unicas then
            cartas_texto = cartas_texto .. ", "
        end
    end
    love.graphics.print(cartas_texto, x_unicas + 20, y_unicas + 25)
    
    -- Valor de x (número de cartas únicas)
    local x_valor = carta_efeito_dados.contagem
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.print("x = " .. x_valor, x_unicas, y_unicas + 55)
    
    -- Cálculo do dano
    love.graphics.setColor(AMARELO)
    love.graphics.print(x_valor .. "² × 10 = " .. (x_valor * x_valor * 10), x_unicas, y_unicas + 85)
    
    -- Dano final (grande)
    local fonte_dano = love.graphics.newFont(64)
    love.graphics.setFont(fonte_dano)
    
    -- Efeito de brilho no dano
    local brilho = 0.7 + math.sin(love.timer.getTime() * 10) * 0.3
    love.graphics.setColor(1, brilho, 0, 1)
    
    local texto_dano = tostring(carta_efeito_dados.dano) .. "!"
    local largura_dano = fonte_dano:getWidth(texto_dano)
    love.graphics.print(texto_dano, 
        x_quad + largura_quadrado/2 - largura_dano/2, 
        y_quad + altura_quadrado - 60)
    
    -- Inimigos que serão atingidos
    local fonte_pequena = love.graphics.newFont(16)
    love.graphics.setFont(fonte_pequena)
    love.graphics.setColor(VERMELHO)
    local texto_inimigos = "ATINGINDO TODOS OS INIMIGOS!"
    if VIDA_TRIANGULO <= 0 and VIDA_QUADRADO <= 0 and VIDA_BOLA_INIMIGA <= 0 then
        texto_inimigos = "NENHUM INIMIGO VIVO!"
    end
    local largura_inimigos = fonte_pequena:getWidth(texto_inimigos)
    love.graphics.print(texto_inimigos, 
        x_quad + largura_quadrado/2 - largura_inimigos/2, 
        y_quad + altura_quadrado - 20)
end

-- FUNÇÃO PRINCIPAL DE DESENHO

function desenhar_efeitos_carta()
    if not carta_em_efeito then return end
    
    if carta_efeito_tipo == "carta7" then
        desenhar_efeito_carta7()
    elseif carta_efeito_tipo == "carta10" then
        desenhar_efeito_carta10()
    end
end