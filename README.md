<font size="7" color="#800080">KING IN YELLOW</font>

Jogo feito em Lua e rodando no Love2D 

King in Orange é um jogo RPG de estratégia em turnos com combate em tempo real, onde o jogador controla uma esfera roxa em um grid 3x3, enfrentando diferentes inimigos em outro grid 3x3 por 4 fases distintas. O jogo combina elementos de card game e bullet hell em um estilo visual retrô com cores vibrantes.

**Mecânicas Principais - Ciclo do Jogo**
O jogo alterna entre dois estados: **de preparação** e **de ação**

Ciclo de Preparação: Fase de estratégia, onde o jogador escolhe entre 6 cartas selecionadas de 18 cartas( 10 cartas únicas) de custo de 1 a 5, maxímo de 5 de custo para ser usados no proxímo ciclo, onde as não usadas e não puxadas ainda são salvas para próximo ciclo de preparação. 

Ciclo de Ação: Fase de combate em tempo real,onde o jogador se movimenta pelo seu grid de 3x3, utilizando tiros padrão e as cartas selecionadas para derrotar inimigos e não ser derrotado, até o proxímo ciclo de preparação, selecionado após passar tempo determinado, marcado pela barra que enche no topo da tela.

**Mecânicas Principais - Sistema de Fases**
O jogo possui 4 fases marcadas pelo seus inimigos:

Fase 1: Esfera - Inimigo básico que persegue e atira, ensinando o jogador sobre mecânicas do jogo.
Fase 2: Inimigo sorteado aleatoriamente (Quadrado OU Triângulo)
Fase 3: Inimigo não selecionado na fase 2
Fase 4: Esfera Final - Versão mais poderosa com novos padrões de ataque

**Mecânicas Principais - Sistema de Cartas**

Deck inicial: 10 tipos de cartas com cópias variadas
Custo: Cada carta tem custo de 1 a 5, máximo de 5 por rodada
Mão: 6 cartas são sorteadas a cada fase de preparação
Seleção: Até 5 cartas podem ser selecionadas para usar na fase de ação
Cartas não usadas: Retornam à mão na próxima fase de preparação

Controles
Tecla	      ---------Função
WASD / Setas---------	Movimentar 
Z          	--------- Atirar/Confirmar carta
X	          ---------Usar próxima carta/Cancelar última carta selecionada
C	          ---------Trocar de Ciclo
ESPAÇO	    ---------Resetar baralho (na preparação)
ESC         ---------	Pausar / Voltar ao menu

Controles para Debug
Tecla	      ---------Função
Y           ---------Pular fase

**Inimigos**
->Esfera Codinome: J(Fases 1 e 4)
Vida Fase 1: 600
Vida Fase 4: 1200

Comportamento: 
Persegue o jogador.

Ataques Fase 1:
-Projéteis quando na mesma linha.
-Ataque em coluna quando jogador na coluna 1.

Ataques Fase 4:
-Padrão 1: Ataques em colunas (1-2 ou 2-3) que empurram jogador.
-Padrão 2: Projéteis em linhas + tiro final.

->Quadrado Codinome: Nº4(3 unidades)
Vida individual: 600 cada (1800 total)

Comportamento: 
Movem ,atacam e se defendem sincronizados.

Ataque: 
-Escolhem áreas diferentes do grid do jogador e atacam simultaneamente após preparação.
-Após atacarem ficam imune a danos por 4s.

->Triângulo Codinome: Valete
Vida: 500

Comportamento: Ataca o Jogador e transforma áreas do jogador em áreas inimigas

Ataques:
-Move-se na coluna 5 atrás do jogador e transforma as colunas 1 e 3 em áreas inimigas, causando caso o jogador pise nelas
-Quando jogador na coluna 2, persegue por 3s
-Dispara projétil que empurra jogador para coluna 1

**Cartas**

ID	Custo	Cópias	Efeito
A	   0		 1	 	 	Copia a próxima carta da fila
2		 1		 3	 	 	Ataque em coluna (2 casas à frente)
3		 1		 3	 	 	Tiro especial que percorre a linha
4		 2		 2	 	 	Imunidade por 5 segundos
5		 3		 1	 	 	Cura 50% da vida máxima
6		 2		 2	 	 	Empurra inimigos das colunas 4-5 para direita
7		 1		 1	 	 	Efeito aleatório (1-7) - 7 completa barra
8		 1		 1	 	 	Projéteis que puxam inimigos para sua linha
9		 2		 1	 	 	Puxa inimigos das colunas 5-6 para esquerda
10	 5		 1	 	 	Causa mais conforme o número de cartas únicas usadas

**HUD Principal0**

-Vida do jogador: Número roxo no canto superior esquerdo
-Vida dos inimigos: Números laranja acima de cada inimigo
-Barra de customização: Progresso para entrar em preparação (verde quando cheia)
-Fila de cartas: Retângulo à direita mostrando cartas selecionadas
-Deck: Indicador com número de cartas restantes

**Estilo Visual**
Segue as cores o padrão de cores baseado no arquivo Paleta, por constraste e não afetar jogadores com problemas de daltonismo.

-Cores principais: Roxo (jogador), Laranja (inimigos), Ciano (efeitos/menu)
-Grid: 3 linhas × 6 colunas (3 colunas jogador, 3 colunas inimigo)
-Fundo: Padrão abstrato com linhas diagonais em movimento
-Efeitos: Partículas, transparências, pulsação e piscadas para indicar ataques

**Créditos**

-Programação e direção: Matheus Santos da Costa Alves
-Músicas: Juhani Junkala (via subspaceaudio.itch.io)
-Produto sem fins comerciais

**Versão**
v1.0
