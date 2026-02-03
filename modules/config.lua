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

--Ciano mais escuro para o fundo
CIANO_MUITO_ESCURO = {0, 0.5, 0.7}

-- Cores adicionais para cartas
ROXO_MEIO = {150/255, 50/255, 180/255, 1}
LARANJA_MEIO = {220/255, 120/255, 60/255, 1}

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
tamanho_triangulo = 32
tamanho_quadrado = 26

--Bola inimiga
tamanho_bola_inimiga = 35

-- Posições iniciais
pos_bola = {1, 1}
pos_triangulo = {1, 4}
pos_quadrado = {2, 5}

--Posição da bola inimiga
pos_bola_inimiga = {3, 6}

-- Sistema de vida
vida_maxima_jogador = 800
VIDA_JOGADOR = vida_maxima_jogador
VIDA_TRIANGULO = 500
VIDA_QUADRADO = 500

--Vida da bola inimiga
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

--Animação da bola inimiga
animacao_bola_inimiga = 0

ultimo_movimento_bola = 0

-- IA dos inimigos (mantido para compatibilidade)
ULTIMO_MOVIMENTO_TRIANGULO = 0
ULTIMO_MOVIMENTO_QUADRADO = 0
INTERVALO_MOVIMENTO_TRIANGULO = 800
INTERVALO_MOVIMENTO_QUADRADO = 600

-- Sistema de ataque do triângulo
ataque_triangulo = nil
DURACAO_ATAQUE_TRIANGULO = 2000
DURACAO_TRANSPARENCIA = 1000
INTERVALO_ATAQUE_TRIANGULO = 3000
tempo_ultimo_ataque_triangulo = 0
triangulo_atacando = false
coluna_transparente = nil
tempo_coluna_transparente = 0

-- Sistema de ataque do quadrado
disparos_quadrado = {}
MAX_TIROS_QUADRADO = 1
tempo_ultimo_disparo_quadrado = 0
intervalo_disparo_quadrado = 800
quadrado_atacando = false

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

-- Função para desenhar fundo abstracto com linhas (atualizada para ciano mais escuro)
function desenhar_fundo_abstracto()
    --Fundo ciano muito escuro
    love.graphics.setColor(CIANO_MUITO_ESCURO)
    love.graphics.rectangle("fill", 0, 0, LARGURA, ALTURA)
    
    -- Linhas brancas diagonais estilo "rede abstrata" (mais escuras)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.2)  -- Mais escuro e mais transparente
    love.graphics.setLineWidth(1.2)
    
    -- Primeiro conjunto de diagonais
    local espacamento = 60
    for i = -ALTURA, LARGURA * 1.5, espacamento do
        love.graphics.line(i, 0, i + ALTURA, ALTURA)
    end
    
    -- Segundo conjunto de diagonais
    for i = LARGURA + ALTURA, -ALTURA * 1.5, -espacamento do
        love.graphics.line(i, 0, i - ALTURA, ALTURA)
    end
    
    -- Grid fino sobreposto (mais escuro)
    love.graphics.setColor(0.7, 0.7, 0.7, 0.1)
    love.graphics.setLineWidth(0.8)
    
    -- Linhas horizontais
    for y = 0, ALTURA, 50 do
        love.graphics.line(0, y, LARGURA, y)
    end
    
    -- Linhas verticais
    for x = 0, LARGURA, 50 do
        love.graphics.line(x, 0, x, ALTURA)
    end
    
    -- Pontos de interseção (mais sutis)
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