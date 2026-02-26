-- modules/phases.lua
-- Controle das fases de preparação e ação

-- Variáveis para seleção por teclado
carta_selecionada = 1
tipo_selecao = "mao"  -- "mao" ou "selecionadas"
linha_selecionada = 1
max_linhas_mao = 1  -- Cartas na mão estão em 1 linha
max_linhas_selecionadas = 1  -- Cartas selecionadas estão em 1 linha

--Função para obter descrição da carta baseado no ID
function obter_descricao_carta(id_carta)
    local descricoes = {
        ["A"] = "Copia próxima carta",
        ["2"] = "Ataque a Coluna a 2 casa",
        ["3"] = "Tiro em linha",
        ["4"] = "Imunidade por 5s",
        ["5"] = "Cura 50% da vida",
        ["6"] = "Empure Inimigos na sua frente",
        ["7"] = "Tente sua Sorte",
        ["8"] = "2 projeteis que empurram inimigos",
        ["9"] = "Puxe Inimigos para frente",
        ["10"] = "Dano baseado em cartas usadas"
    }
    return descricoes[id_carta] or "Efeito especial"
end

function desenhar_fase_preparacao()
    -- Fundo semi-transparente sobre toda a janela
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, JANELA_LARGURA, JANELA_ALTURA)
    
    -- Título (centralizado na janela)
    local fonte_titulo = fonte_pausa or love.graphics.newFont(48)
    love.graphics.setFont(fonte_titulo)
    love.graphics.setColor(ROXO_CLARO)
    local titulo = "FASE DE PREPARAÇÃO"
    love.graphics.print(titulo, JANELA_LARGURA/2 - fonte_titulo:getWidth(titulo)/2, 50)
    
    -- Instruções principais
    local fonte_inst = fonte_instrucoes or love.graphics.newFont(20)
    love.graphics.setFont(fonte_inst)
    love.graphics.setColor(BRANCO)
    local instrucao = "Selecione até 5 cartas (Custo máximo: 5)"
    love.graphics.print(instrucao, JANELA_LARGURA/2 - fonte_inst:getWidth(instrucao)/2, 120)
    
    -- Custo atual
    local texto_custo = "Custo: " .. custo_atual .. "/5"
    love.graphics.print(texto_custo, JANELA_LARGURA/2 - fonte_inst:getWidth(texto_custo)/2, 150)
    
    -- Cartas disponíveis (centralizadas na janela)
    desenhar_cartas_disponiveis()
    
    -- Cartas selecionadas (centralizadas na janela)
    desenhar_cartas_selecionadas()
    
    --Desenhar descrição da carta selecionada
    desenhar_descricao_carta_selecionada()
    
    -- Botões (centralizados na janela)
    desenhar_botoes_preparacao()
    
    -- Instruções de controle da fase de preparação
    desenhar_instrucoes_preparacao()
end

--Função para desenhar descrição da carta selecionada
function desenhar_descricao_carta_selecionada()
    local fonte_desc = fonte_instrucoes or love.graphics.newFont(18)
    love.graphics.setFont(fonte_desc)
    
    -- Determinar qual carta está selecionada
    local carta_atual = nil
    local id_carta = ""
    local descricao = ""
    
    if tipo_selecao == "mao" and carta_selecionada >= 1 and carta_selecionada <= #mao_atual then
        carta_atual = mao_atual[carta_selecionada]
    elseif tipo_selecao == "selecionadas" and carta_selecionada >= 1 and carta_selecionada <= #cartas_selecionadas then
        carta_atual = cartas_selecionadas[carta_selecionada]
    end
    
    -- Se encontrou uma carta, obter descrição
    if carta_atual then
        id_carta = carta_atual.id
        descricao = obter_descricao_carta(id_carta)
        
        -- Posicionar a descrição na parte inferior central da tela
        local largura_maxima = 500
        local altura_desc = 80
        local x = JANELA_LARGURA/2 - largura_maxima/2
        local y = 650
        
        -- Fundo semi-transparente
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", x, y, largura_maxima, altura_desc, 10)
        
        -- Borda com cor baseada no tipo da carta
        local cor_borda
        if id_carta == "A" then
            cor_borda = ROXO_CLARO
        else
            cor_borda = LARANJA_CLARO
        end
        
        love.graphics.setColor(cor_borda)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, largura_maxima, altura_desc, 10)
        
        -- Título da carta
        love.graphics.setColor(BRANCO)
        local titulo = "Carta " .. id_carta
        love.graphics.print(titulo, x + 20, y + 15)
        
        -- Descrição
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf(descricao, x + 20, y + 40, largura_maxima - 40, "left")
        
        -- Custo (no canto superior direito)
        love.graphics.setColor(AMARELO)
        local texto_custo = "Custo: " .. carta_atual.custo
        love.graphics.print(texto_custo, x + largura_maxima - 100, y + 15)
    end
end

function desenhar_cartas_disponiveis()
    -- Centralizar na janela completa
    local total_largura_cartas = 6 * 100 + 5 * 20  -- 6 cartas * 100px + 5 espaços * 20px
    local inicio_x = JANELA_LARGURA/2 - total_largura_cartas/2
    local inicio_y = 200
    local espacamento = 120
    local cartas_por_linha = 6
    
    local fonte_carta = fonte_vida or love.graphics.newFont(36)
    love.graphics.setFont(fonte_carta)
    
    for i, carta in ipairs(mao_atual) do
        local coluna = ((i-1) % cartas_por_linha) + 1
        local linha = math.floor((i-1) / cartas_por_linha) + 1
        local x = inicio_x + (coluna-1) * espacamento
        local y = inicio_y + (linha-1) * 160
        
        -- CORES DIFERENTES PARA DIFERENTES CARTAS
        local cor_fundo, cor_borda
        
        if carta.id == "A" then
            -- Carta A: Roxa
            if tipo_selecao == "mao" and carta_selecionada == i then
                cor_fundo = ROXO_CLARO
                cor_borda = BRANCO
            else
                cor_fundo = ROXO_ESCURO
                cor_borda = ROXO_CLARO
            end
        else
            -- Outras cartas: Laranja
            if tipo_selecao == "mao" and carta_selecionada == i then
                cor_fundo = LARANJA_CLARO
                cor_borda = BRANCO
            else
                cor_fundo = LARANJA_ESCURO
                cor_borda = LARANJA_CLARO
            end
        end
        
        -- Fundo da carta
        love.graphics.setColor(cor_fundo)
        love.graphics.rectangle("fill", x, y, 100, 140, 10)
        
        -- Borda
        love.graphics.setColor(cor_borda)
        if tipo_selecao == "mao" and carta_selecionada == i then
            love.graphics.setLineWidth(4)
        else
            love.graphics.setLineWidth(3)
        end
        love.graphics.rectangle("line", x, y, 100, 140, 10)
        
        -- Símbolo (sempre preto para contraste)
        love.graphics.setColor(PRETO)
        love.graphics.print(carta.id, x + 40, y + 50)
        
        -- Custo
        love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(16))
        love.graphics.setColor(AMARELO)
        love.graphics.print("Custo: " .. carta.custo, x + 20, y + 110)
        
        -- Número da carta
        love.graphics.setColor(BRANCO)
        love.graphics.print(i, x + 45, y + 10)
    end
    
    -- Atualizar máximo de linhas
    max_linhas_mao = math.ceil(#mao_atual / cartas_por_linha)
end

function desenhar_cartas_selecionadas()
    if #cartas_selecionadas == 0 then return end
    
    -- Centralizar na janela completa
    local num_cartas = math.min(5, #cartas_selecionadas)
    local total_largura = num_cartas * 100 + (num_cartas - 1) * 20
    local inicio_x = JANELA_LARGURA/2 - total_largura/2
    local inicio_y = 400
    local cartas_por_linha = 5
    
    local fonte_carta = fonte_vida or love.graphics.newFont(36)
    love.graphics.setFont(fonte_carta)
    
    for i, carta in ipairs(cartas_selecionadas) do
        local coluna = ((i-1) % cartas_por_linha) + 1
        local linha = math.floor((i-1) / cartas_por_linha) + 1
        local x = inicio_x + (coluna-1) * 120
        local y = inicio_y + (linha-1) * 160
        
        -- CORES DIFERENTES BASEADAS NA CARTA
        local cor_fundo, cor_borda
        
        if carta.id == "A" then
            -- Carta A: Roxa
            if tipo_selecao == "selecionadas" and carta_selecionada == i then
                cor_fundo = {ROXO_CLARO[1], ROXO_CLARO[2], ROXO_CLARO[3], 0.9}
                cor_borda = BRANCO
            else
                cor_fundo = ROXO_ESCURO
                cor_borda = ROXO_CLARO
            end
        else
            -- Outras cartas: Laranja
            if tipo_selecao == "selecionadas" and carta_selecionada == i then
                cor_fundo = {LARANJA_CLARO[1], LARANJA_CLARO[2], LARANJA_CLARO[3], 0.9}
                cor_borda = BRANCO
            else
                cor_fundo = LARANJA_ESCURO
                cor_borda = LARANJA_CLARO
            end
        end
        
        -- Fundo da carta selecionada
        love.graphics.setColor(cor_fundo)
        love.graphics.rectangle("fill", x, y, 100, 140, 10)
        
        -- Borda
        love.graphics.setColor(cor_borda)
        if tipo_selecao == "selecionadas" and carta_selecionada == i then
            love.graphics.setLineWidth(4)
        else
            love.graphics.setLineWidth(3)
        end
        love.graphics.rectangle("line", x, y, 100, 140, 10)
        
        -- Símbolo (sempre preto)
        love.graphics.setColor(PRETO)
        love.graphics.print(carta.id, x + 40, y + 50)
        
        -- Posição na seleção
        love.graphics.setFont(fonte_instrucoes or love.graphics.newFont(16))
        love.graphics.setColor(BRANCO)
        love.graphics.print("Pos: " .. i, x + 30, y + 110)
        
        -- Custo pequeno no canto inferior esquerdo
        love.graphics.setColor(AMARELO)
        love.graphics.print("C" .. carta.custo, x + 5, y + 120)
    end
    
    -- Atualizar máximo de linhas
    max_linhas_selecionadas = math.ceil(#cartas_selecionadas / cartas_por_linha)
end

function desenhar_botoes_preparacao()
    local fonte_botao = fonte_instrucoes or love.graphics.newFont(24)
    love.graphics.setFont(fonte_botao)
    
    -- Botão Pronto (centralizado na janela)
    local pronto_x = JANELA_LARGURA/2 - 200
    local pronto_y = 550
    local pronto_largura = 150
    local pronto_altura = 50
    
    if tipo_selecao == "botao_pronto" then
        love.graphics.setColor(VERDE)
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(VERDE)
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("fill", pronto_x, pronto_y, pronto_largura, pronto_altura, 10)
    love.graphics.setColor(BRANCO)
    love.graphics.rectangle("line", pronto_x, pronto_y, pronto_largura, pronto_altura, 10)
    love.graphics.print("PRONTO", pronto_x + 30, pronto_y + 15)
    
    -- Botão Reset (centralizado na janela)
    local reset_x = JANELA_LARGURA/2 + 50
    local reset_y = 550
    local reset_largura = 150
    local reset_altura = 50
    
    if tipo_selecao == "botao_reset" then
        love.graphics.setColor(VERMELHO)
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(VERMELHO)
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("fill", reset_x, reset_y, reset_largura, reset_altura, 10)
    love.graphics.setColor(BRANCO)
    love.graphics.rectangle("line", reset_x, reset_y, reset_largura, reset_altura, 10)
    love.graphics.print("RESET", reset_x + 40, reset_y + 15)
end

--Função para desenhar instruções específicas da fase de preparação
function desenhar_instrucoes_preparacao()
    local fonte_inst = fonte_instrucoes or love.graphics.newFont(18)
    love.graphics.setFont(fonte_inst)
    love.graphics.setColor(BRANCO)
    
    local instrucoes = {
        "CONTROLES NA PREPARAÇÃO:",
        "A/←: Selecionar carta esquerda",
        "D/→: Selecionar carta direita",
        "Z: Selecionar carta para uso",
        "X: Cancelar última carta selecionada",
        "C: Voltar à fase de ação",
        "ESPAÇO: Resetar baralho e voltar à ação"
    }
    
    -- Posição no lado direito da tela
    local x = JANELA_LARGURA - 300
    local y = 200
    
    -- Fundo semi-transparente
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x - 15, y - 15, 290, 310, 8)  -- Aumentei a altura para 310
    
    -- Borda
    love.graphics.setColor(ROXO_CLARO)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x - 15, y - 15, 290, 310, 8)
    
    -- Texto das instruções
    for i, texto in ipairs(instrucoes) do
        if i == 1 then
            love.graphics.setColor(ROXO_CLARO)
            love.graphics.print(texto, x, y + (i-1) * 25)
            love.graphics.setColor(BRANCO)
        elseif texto == "" then
            -- Linha vazia (espaço)
        else
            love.graphics.print(texto, x + 5, y + (i-1) * 25)
        end
    end
end

function mover_selecao_horizontal(direcao)
    local cartas_por_linha = 6
    local max_cartas
    
    if tipo_selecao == "mao" then
        max_cartas = #mao_atual
        cartas_por_linha = 6
    elseif tipo_selecao == "selecionadas" then
        max_cartas = #cartas_selecionadas
        cartas_por_linha = 5
    elseif tipo_selecao == "botao_pronto" or tipo_selecao == "botao_reset" then
        -- Alternar entre botões
        if tipo_selecao == "botao_pronto" then
            tipo_selecao = "botao_reset"
        else
            tipo_selecao = "botao_pronto"
        end
        return
    end
    
    if max_cartas == 0 then return end
    
    -- Calcular posição atual na grade
    local cartas_na_linha_atual = math.min(cartas_por_linha, max_cartas - ((linha_selecionada-1) * cartas_por_linha))
    
    -- Mover horizontalmente
    if direcao == "direita" then
        carta_selecionada = carta_selecionada + 1
        if carta_selecionada > (linha_selecionada-1) * cartas_por_linha + cartas_na_linha_atual then
            carta_selecionada = (linha_selecionada-1) * cartas_por_linha + 1
        end
    elseif direcao == "esquerda" then
        carta_selecionada = carta_selecionada - 1
        if carta_selecionada < (linha_selecionada-1) * cartas_por_linha + 1 then
            carta_selecionada = (linha_selecionada-1) * cartas_por_linha + cartas_na_linha_atual
        end
    end
    
    -- Garantir que está dentro dos limites
    carta_selecionada = math.max(1, math.min(carta_selecionada, max_cartas))
end

function confirmar_selecao()
    -- Esta função agora é obsoleta com os novos controles
    -- Mas a mantemos para compatibilidade com cliques do mouse
    if tipo_selecao == "mao" then
        -- Selecionar carta da mão
        if carta_selecionada >= 1 and carta_selecionada <= #mao_atual then
            selecionar_carta(carta_selecionada)
        end
    elseif tipo_selecao == "selecionadas" then
        -- Remover carta selecionada
        if carta_selecionada >= 1 and carta_selecionada <= #cartas_selecionadas then
            remover_carta_selecionada(carta_selecionada)
        end
    elseif tipo_selecao == "botao_pronto" then
        -- Clicar no botão Pronto
        mudar_fase(FASE_ACAO)
    elseif tipo_selecao == "botao_reset" then
        -- Clicar no botão Reset
        resetar_cartas()
    end
end

function verificar_clique_preparacao(x, y)
    -- Botão Pronto
    local pronto_x = JANELA_LARGURA/2 - 200
    local pronto_y = 550
    local pronto_largura = 150
    local pronto_altura = 50
    
    if x >= pronto_x and x <= pronto_x + pronto_largura and
       y >= pronto_y and y <= pronto_y + pronto_altura then
        mudar_fase(FASE_ACAO)
        return true
    end
    
    -- Botão Reset
    local reset_x = JANELA_LARGURA/2 + 50
    local reset_y = 550
    local reset_largura = 150
    local reset_altura = 50
    
    if x >= reset_x and x <= reset_x + reset_largura and
       y >= reset_y and y <= reset_y + reset_altura then
        resetar_cartas()
        return true
    end
    
    -- Seleção de cartas disponíveis
    local total_largura_cartas = 6 * 100 + 5 * 20
    local inicio_x = JANELA_LARGURA/2 - total_largura_cartas/2
    local inicio_y = 200
    local espacamento = 120
    local cartas_por_linha = 6
    
    for i = 1, #mao_atual do
        local coluna = ((i-1) % cartas_por_linha) + 1
        local linha = math.floor((i-1) / cartas_por_linha) + 1
        local carta_x = inicio_x + (coluna-1) * espacamento
        local carta_y = inicio_y + (linha-1) * 160
        
        if x >= carta_x and x <= carta_x + 100 and
           y >= carta_y and y <= carta_y + 140 then
            selecionar_carta(i)
            return true
        end
    end
    
    -- Remover cartas selecionadas
    if #cartas_selecionadas > 0 then
        local num_cartas = math.min(5, #cartas_selecionadas)
        local total_largura = num_cartas * 100 + (num_cartas - 1) * 20
        local inicio_x_sel = JANELA_LARGURA/2 - total_largura/2
        local inicio_y_sel = 400
        local cartas_por_linha_sel = 5
        
        for i = 1, #cartas_selecionadas do
            local coluna = ((i-1) % cartas_por_linha_sel) + 1
            local linha = math.floor((i-1) / cartas_por_linha_sel) + 1
            local carta_x = inicio_x_sel + (coluna-1) * 120
            local carta_y = inicio_y_sel + (linha-1) * 160
            
            if x >= carta_x and x <= carta_x + 100 and
               y >= carta_y and y <= carta_y + 140 then
                remover_carta_selecionada(i)
                return true
            end
        end
    end
    
    return false
end

function resetar_cartas()
    print("=== RESETANDO CARTAS VIA FASE DE PREPARAÇÃO ===")
    
    -- Chama a função que limpa TODAS as cartas e as devolve ao deck
    resetar_cartas_para_preparacao()
    
    -- Após resetar o baralho, VOLTA PARA A FASE DE AÇÃO
    -- Na próxima vez que entrar na preparação, virá um baralho novo
    print("Voltando para fase de ação com baralho resetado...")
    mudar_fase(FASE_ACAO)
end