<h1>
  <font size="7" color="#800080">KING IN ORANGE</font>
</h1>

<p>Jogo feito em Lua e rodando no Love2D</p>

<p>King in Orange é um jogo RPG de estratégia em turnos com combate em tempo real, onde o jogador controla uma esfera roxa em um grid 3x3, enfrentando diferentes inimigos em outro grid 3x3 por 4 fases distintas. O jogo combina elementos de card game e bullet hell em um estilo visual retrô com cores vibrantes.</p>

<p><strong>Mecânicas Principais - Ciclo do Jogo</strong><br>
O jogo alterna entre dois estados: <strong>de preparação</strong> e <strong>de ação</strong></p>

<p>Ciclo de Preparação: Fase de estratégia, onde o jogador escolhe entre 6 cartas selecionadas de 18 cartas( 10 cartas únicas) de custo de 1 a 5, maxímo de 5 de custo para ser usados no proxímo ciclo, onde as não usadas e não puxadas ainda são salvas para próximo ciclo de preparação.</p>

<p>Ciclo de Ação: Fase de combate em tempo real,onde o jogador se movimenta pelo seu grid de 3x3, utilizando tiros padrão e as cartas selecionadas para derrotar inimigos e não ser derrotado, até o proxímo ciclo de preparação, selecionado após passar tempo determinado, marcado pela barra que enche no topo da tela.</p>

<p><strong>Mecânicas Principais - Sistema de Fases</strong><br>
O jogo possui 4 fases marcadas pelo seus inimigos:</p>

<p>Fase 1: Esfera - Inimigo básico que persegue e atira, ensinando o jogador sobre mecânicas do jogo.<br>
Fase 2: Inimigo sorteado aleatoriamente (Quadrado OU Triângulo)<br>
Fase 3: Inimigo não selecionado na fase 2<br>
Fase 4: Esfera Final - Versão mais poderosa com novos padrões de ataque</p>

<p><strong>Mecânicas Principais - Sistema de Cartas</strong></p>

<p>Deck inicial: 10 tipos de cartas com cópias variadas<br>
Custo: Cada carta tem custo de 1 a 5, máximo de 5 por rodada<br>
Mão: 6 cartas são sorteadas a cada fase de preparação<br>
Seleção: Até 5 cartas podem ser selecionadas para usar na fase de ação<br>
Cartas não usadas: Retornam à mão na próxima fase de preparação</p>

<p><strong>Controles</strong><br>
<code>WASD / Setas</code>  ---------  Movimentar<br>
<code>Z</code>            ---------  Atirar/Confirmar carta<br>
<code>X</code>            ---------  Usar próxima carta/Cancelar última carta selecionada<br>
<code>C</code>            ---------  Trocar de Ciclo<br>
<code>ESPAÇO</code>       ---------  Resetar baralho (na preparação)<br>
<code>ESC</code>          ---------  Pausar / Voltar ao menu</p>

<p><strong>Controles para Debug</strong><br>
<code>Y</code>            ---------  Pular fase</p>

<p><strong>Inimigos</strong><br>
-&gt;Esfera Codinome: J(Fases 1 e 4)<br>
Vida Fase 1: 600<br>
Vida Fase 4: 1200</p>

<p>Comportamento:<br>
Persegue o jogador.</p>

<p>Ataques Fase 1:<br>
-Projéteis quando na mesma linha.<br>
-Ataque em coluna quando jogador na coluna 1.</p>

<p>Ataques Fase 4:<br>
-Padrão 1: Ataques em colunas (1-2 ou 2-3) que empurram jogador.<br>
-Padrão 2: Projéteis em linhas + tiro final.</p>

<p>-&gt;Quadrado Codinome: Nº4(3 unidades)<br>
Vida individual: 600 cada (1800 total)</p>

<p>Comportamento:<br>
Movem ,atacam e se defendem sincronizados.</p>

<p>Ataque:<br>
-Escolhem áreas diferentes do grid do jogador e atacam simultaneamente após preparação.<br>
-Após atacarem ficam imune a danos por 4s.</p>

<p>-&gt;Triângulo Codinome: Valete<br>
Vida: 500</p>

<p>Comportamento: Ataca o Jogador e transforma áreas do jogador em áreas inimigas</p>

<p>Ataques:<br>
-Move-se na coluna 5 atrás do jogador e transforma as colunas 1 e 3 em áreas inimigas, causando caso o jogador pise nelas<br>
-Quando jogador na coluna 2, persegue por 3s<br>
-Dispara projétil que empurra jogador para coluna 1</p>

<p><strong>Cartas</strong></p>
<p>
<code>A </code>  Custo 0  -  Cópias 1  -  Copia a próxima carta da fila<br>
<code>2 </code>  Custo 1  -  Cópias 3  -  Ataque em coluna (2 casas à frente)<br>
<code>3 </code>  Custo 1  -  Cópias 3  -  Tiro especial que percorre a linha<br>
<code>4 </code>  Custo 2  -  Cópias 2  -  Imunidade por 5 segundos<br>
<code>5 </code>  Custo 3  -  Cópias 1  -  Cura 50% da vida máxima<br>
<code>6 </code>  Custo 2  -  Cópias 2  -  Empurra inimigos das colunas 4-5 para direita<br>
<code>7 </code>  Custo 1  -  Cópias 1  -  Efeito aleatório (1-7) - 7 completa barra<br>
<code>8 </code>  Custo 1  -  Cópias 1  -  Projéteis que puxam inimigos para sua linha<br>
<code>9 </code>  Custo 2  -  Cópias 1  -  Puxa inimigos das colunas 5-6 para esquerda<br>
<code>10</code>  Custo 5  -  Cópias 1  -  Causa mais conforme o número de cartas únicas usadas
</p>

<p><strong>HUD Principal</strong></p>

<p>-Vida do jogador: Número roxo no canto superior esquerdo<br>
-Vida dos inimigos: Números laranja acima de cada inimigo<br>
-Barra de customização: Progresso para entrar em preparação (verde quando cheia)<br>
-Fila de cartas: Retângulo à direita mostrando cartas selecionadas<br>
-Deck: Indicador com número de cartas restantes</p>

<p><strong>Estilo Visual</strong><br>
Segue as cores o padrão de cores baseado no arquivo Paleta, por constraste e não afetar jogadores com problemas de daltonismo.</p>

<p>-Cores principais: Roxo (jogador), Laranja (inimigos), Ciano (efeitos/menu)<br>
-Grid: 3 linhas × 6 colunas (3 colunas jogador, 3 colunas inimigo)<br>
-Fundo: Padrão abstrato com linhas diagonais em movimento<br>
-Efeitos: Partículas, transparências, pulsação e piscadas para indicar ataques</p>

<p><strong>Créditos</strong></p>

<p>-Programação e direção: Matheus Santos da Costa Alves<br>
-Músicas: Juhani Junkala (via subspaceaudio.itch.io)<br>
-Produto sem fins comerciais</p>

<p><strong>Versão</strong><br>
v1.0</p>
