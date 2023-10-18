# inf1350-nodemcu-battleship
Jogo de Batalha Naval em Lua, utilizando um NodeMCU como controle.

Ideia básica da estrutura do jogo:
Na tela do jogador, tem-se dois tabuleiros:
- O tabuleiro de 'visualização', onde o jogador pode ver onde estão os seus navios e onde o inimigo tentou atacar
- O tabuleiro de 'jogo', onde o jogador irá realizar seus ataques, podendo ver quais acertaram e quais erraram

No tabuleiro de visualização, simplesmente será desenhada uma distribuição de navios (escolhida aleatoriamente no início do jogo) e, ao longo do jogo, será marcado onde o inimigo fez ataques.

No tabuleiro de jogo, o jogador pode (em seu turno) escolher uma posição para atacar (um botão do NodeMCU anda o quadrado de escolha para a direita, outro desce, um terceiro confirma o ataque).

PLANO PARA 1 JOGADOR:
- O NodeMCU comunica os controles com o jogo através de uma fila MQTT. O oponente é o próprio computador, que ataca uma posição aleatória em seu turno.

PLANO PARA 2 JOGADORES:
- O jogo é jogado em 2 computadores, cada um com um NodeMCU. Cada NodeMCU comunica os controles para seu computador. Além disso, filas entre os computadores serão utilizadas para comunicar onde foram feitos ataques e, como resposta, se os ataques feitos acertaram mar ou um navio.
