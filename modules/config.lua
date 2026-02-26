-- modules/config.lua
-- Configurações globais do jogo

LARGURA = 900
ALTURA = 600
FPS = 60

-- Cores
PRETO = {0, 0, 0}
BRANCO = {1, 1, 1}
ROXO_ESCURO = {178/255, 28/255, 161/255}
ROXO_CLARO = {214/255, 69/255, 200/255}
LARANJA_ESCURO = {1, 150/255, 0}
LARANJA_CLARO = {247/255, 143/255, 46/255}
CINZA = {100/255, 100/255, 120/255}
VERMELHO = {1, 50/255, 50/255}
VERDE = {50/255, 1, 50/255}
AZUL = {50/255, 150/255, 1}
AMARELO = {1, 1, 0}
CIANO = {0, 1, 1}
CIANO_CLARO = {0.5, 1, 1}
CIANO_ESCURO = {0, 0.7, 0.9}
CIANO_NEON = {0, 1, 1}

--Ciano mais escuro para o fundo (ajustado para ser mais vibrante)
CIANO_MUITO_ESCURO = {0, 0.6, 0.8}  -- Aumentei o brilho para cobrir melhor

-- Cores adicionais para cartas
ROXO_MEIO = {150/255, 50/255, 180/255, 1}
LARANJA_MEIO = {220/255, 120/255, 60/255, 1}

-- CONSTANTES DO TRIÂNGULO 
TRIANGULO_COR_NORMAL = LARANJA_CLARO
TRIANGULO_COR_ESCURA = LARANJA_ESCURO
TRIANGULO_COR_CIANO = CIANO
TRIANGULO_TAMANHO = 42  
TRIANGULO_VIDA_MAXIMA = 500
TRIANGULO_DANO_COLUNA = 30  -- REDUZIDO de 90 para 30 
TRIANGULO_DANO_PROJETIL = 70
TRIANGULO_TEMPO_PREPARACAO = 2.0      -- Tempo que as colunas 1/3 ficam piscando
TRIANGULO_TEMPO_ATIVO = 3.0           -- Tempo que as colunas 1/3 ficam ativas causando dano
TRIANGULO_TEMPO_PERSEGUICAO = 3.0     -- tempo perseguindo antes de lançar projétil
TRIANGULO_TEMPO_PARAR_ANTES = 1.2     -- tempo antes do fim que para de se mover
TRIANGULO_TEMPO_BLOQUEIO_JOGADOR = 3.0 -- Tempo que jogador fica bloqueado após ser atingido
TRIANGULO_TEMPO_RECUO = 5.0           -- Tempo que triângulo fica sem se mover após errar
TRIANGULO_VELOCIDADE_PROJETIL = 15    -- Velocidade da lança
TRIANGULO_INTERVALO_MOVIMENTO = 400   -- Intervalo entre movimentos em ms (igual ao jogador)

-- CONSTANTES DO QUADRADO
QUADRADO_TEMPO_PREPARACAO = 2.0      -- Tempo de preparação (piscar laranja)
QUADRADO_TEMPO_TRANSPARENCIA = 1.2   -- Tempo que a área fica transparente após ataque
QUADRADO_DANO = 90                    -- Dano causado pelo ataque
QUADRADO_TEMPO_IMUNIDADE = 3.0        -- Tempo de imunidade após ataque
QUADRADO_INTERVALO_MOVIMENTO = 400    -- Intervalo entre movimentos em ms
QUADRADO_NUM_MOVIMENTOS = 2           -- Número de movimentos após ataque
QUADRADO_COR_NORMAL = LARANJA_CLARO   -- Cor laranja para o quadrado
QUADRADO_COR_IMUNE = CIANO            -- Cor ciano quando imune

-- Grid
NUM_COLUNAS = 6
NUM_LINHAS = 3
LARGURA_CELULA = 120
ALTURA_CELULA = 150
OFFSET_X = (LARGURA - (NUM_COLUNAS * LARGURA_CELULA)) / 2
OFFSET_Y = 120

-- Estado do jogo
JOGO_PAUSADO = false
fonte_pausa = nil
fonte_instrucoes = nil
fonte_vida = nil

-- Grid células
GRID_CELULAS = {}

-- Objetos
tamanho_bola = 40
tamanho_triangulo = 42  -- AUMENTADO para manter consistência com TRIANGULO_TAMANHO
tamanho_quadrado = 26
tamanho_bola_inimiga = 35

-- Posições iniciais
pos_bola = {1, 1}
pos_triangulo = {1, 4}
pos_bola_inimiga = {3, 6}

-- Sistema de vida
vida_maxima_jogador = 800
VIDA_JOGADOR = vida_maxima_jogador
VIDA_TRIANGULO = 500
VIDA_BOLA_INIMIGA = 600

-- Sistema de disparos
disparos = {}
tempo_ultimo_disparo = 0
intervalo_disparo = 200
pode_atirar = true
mouse_pressionado = false
tecla_z_pressionada = false

-- Variáveis de animação
animacao_bola = 0
animacao_triangulo = 0
animacao_quadrado = 0
animacao_bola_inimiga = 0
ultimo_movimento_bola = 0

-- IA dos inimigos
ULTIMO_MOVIMENTO_TRIANGULO = 0
INTERVALO_MOVIMENTO_TRIANGULO = 800

-- Sistema de ataque do triângulo
ataque_triangulo = nil
DURACAO_ATAQUE_TRIANGULO = 2000
DURACAO_TRANSPARENCIA = 1000
INTERVALO_ATAQUE_TRIANGULO = 3000
tempo_ultimo_ataque_triangulo = 0
triangulo_atacando = false
coluna_transparente = nil
tempo_coluna_transparente = 0

-- Constantes para telas de fim de jogo
TELA_DERROTA = "derrota"
TELA_VITORIA = "vitoria"
tela_fim_ativa = false
tela_fim_tipo = nil
tempo_tela_fim = 0

-- Função para carregar fontes
function carregar_fontes()
    local sucesso, mega_man_font = pcall(function()
        return love.graphics.newFont("font/mega_man.ttf", 36)
    end)
    
    if not sucesso then
        print("Fonte Mega Man não encontrada em font/mega_man.ttf, tentando alternativas...")
        
        sucesso, mega_man_font = pcall(function()
            return love.graphics.newFont("mega_man.ttf", 36)
        end)
        
        if not sucesso then
            sucesso, mega_man_font = pcall(function()
                return love.graphics.newFont("Mega-Man-Battle-Network.ttf", 36)
            end)
        end
        
        if not sucesso then
            print("Não foi possível carregar a fonte Mega Man, usando fonte padrão do sistema")
            fonte_pausa = love.graphics.newFont(72)
            fonte_instrucoes = love.graphics.newFont(36)
            fonte_vida = love.graphics.newFont(48)
            return
        end
    end
    
    fonte_pausa = love.graphics.newFont("font/mega_man.ttf", 72)
    fonte_instrucoes = love.graphics.newFont("font/mega_man.ttf", 24)
    fonte_vida = love.graphics.newFont("font/mega_man.ttf", 48)
    
    print("Fonte Mega Man carregada com sucesso!")
end

-- Função para desenhar fundo abstracto com linhas (AGORA COBRE TODA A ÁREA)
function desenhar_fundo_abstracto()
    -- Fundo ciano que cobre TODA a área do jogo (não apenas o grid)
    love.graphics.setColor(CIANO_MUITO_ESCURO)
    love.graphics.rectangle("fill", 0, 0, LARGURA, ALTURA)
    
    -- Linhas brancas diagonais estilo "rede abstrata" (mais escuras)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.2)  -- Mais escuro e mais transparente
    love.graphics.setLineWidth(1.2)
    
    -- Primeiro conjunto de diagonais (cobrindo toda a área)
    local espacamento = 60
    for i = -ALTURA, LARGURA * 1.5, espacamento do
        love.graphics.line(i, 0, i + ALTURA, ALTURA)
    end
    
    -- Segundo conjunto de diagonais
    for i = LARGURA + ALTURA, -ALTURA * 1.5, -espacamento do
        love.graphics.line(i, 0, i - ALTURA, ALTURA)
    end
    
    -- Grid fino sobreposto (mais escuro) - cobrindo toda a área
    love.graphics.setColor(0.7, 0.7, 0.7, 0.1)
    love.graphics.setLineWidth(0.8)
    
    -- Linhas horizontais (cobrindo toda a altura)
    for y = 0, ALTURA, 50 do
        love.graphics.line(0, y, LARGURA, y)
    end
    
    -- Linhas verticais (cobrindo toda a largura)
    for x = 0, LARGURA, 50 do
        love.graphics.line(x, 0, x, ALTURA)
    end
    
    -- Pontos de interseção (mais sutis) - cobrindo toda a área
    love.graphics.setColor(0.9, 0.9, 0.9, 0.25)
    for x = 0, LARGURA, 100 do
        for y = 0, ALTURA, 100 do
            love.graphics.circle("fill", x, y, 1.5)
        end
    end
    
    -- Efeito de brilho central (mais sutil)
    local center_x, center_y = LARGURA/2, ALTURA/2
    for i = 1, 3 do
        local radius = i * 80
        love.graphics.setColor(CIANO_MUITO_ESCURO[1], CIANO_MUITO_ESCURO[2] + 0.2, CIANO_MUITO_ESCURO[3] + 0.2, 0.03 / i)
        love.graphics.circle("fill", center_x, center_y, radius)
    end
    
    -- Efeito de "neblina" nos cantos
    love.graphics.setColor(0, 0.3, 0.5, 0.1)
    local cantos = {
        {0, 0}, {LARGURA, 0}, {0, ALTURA}, {LARGURA, ALTURA}
    }
    for _, canto in ipairs(cantos) do
        love.graphics.circle("fill", canto[1], canto[2], 200)
    end
end

-- Função para desenhar o grid (MODIFICADA - REMOVIDO O FUNDO PRETO)
function desenhar_grid()
    -- REMOVIDO: Fundo preto ao redor do grid
    -- love.graphics.setColor(30/255, 30/255, 50/255, 0.8)
    -- love.graphics.rectangle("fill",
    --     OFFSET_X - 20, OFFSET_Y - 20,
    --     NUM_COLUNAS * LARGURA_CELULA + 40,
    --     NUM_LINHAS * ALTURA_CELULA + 40
    -- )
    
    -- Desenha cada célula do grid
    for linha = 1, NUM_LINHAS do
        for coluna = 1, NUM_COLUNAS do
            local celula = GRID_CELULAS[linha][coluna]
            
            -- Verifica se é coluna cedida pela carta 9 (agora usando a variável global)
            local eh_coluna_cedida = false
            if colunas_cedidas then  -- Verifica se a variável existe
                for _, coluna_cedida in ipairs(colunas_cedidas) do
                    if coluna == coluna_cedida.coluna then
                        eh_coluna_cedida = true
                        break
                    end
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
