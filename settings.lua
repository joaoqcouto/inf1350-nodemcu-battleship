settings = {
  -- which player is active
  -- to play multiplayer, one of the programs have to use 'player 1' and the other 'player 2'
  player = "player1",
  
  -- internet connection settings
  internet = {
    id = "wifiid",
    password = "wifipassword",
    server="139.82.100.100",
    port=7981
  },
  
  -- player 1 ids and queues
  player1 = {
    starting_turn = 1, -- player 1 plays first
    
    node = {
      id = "nodebattleship1",
      subscribe = "lovebattleship1",
      publish = "nodebattleship1"
    },
    
    love = {
      id = "battleship1",
      subscribe = {"battleship2", "nodebattleship1", "battleship1"}, -- fila de receber ataque, de receber comando e de receber resposta de ataque
      node_queue = "lovebattleship1",
      attack_queue = "battleship1",
      response_queue = "battleship2"
    }
  },
  
  -- player 2 ids and queues
  player2 = {
    starting_turn = 2, -- player 2 waits first
    
    node = {
      id = "nodebattleship2",
      subscribe = "lovebattleship2",
      publish = "nodebattleship2"
    },
    
    love = {
      id = "battleship2",
      subscribe = {"battleship1", "nodebattleship2", "battleship2"}, -- fila de receber ataque, de receber comando e de receber resposta de ataque
      node_queue = "lovebattleship2",
      attack_queue = "battleship2",
      response_queue = "battleship1"
    }
  }
}

return(settings)
