-- viewboard.lua
-- tabuleiro onde será possível ver os seus navios e onde o oponente clicou

function createViewboard(size, pixels)
  square_pixels = pixels/size
  
  return {
    -- tamanho do tabuleiro (quantos quadrados e tamanho em pixels)
    size = size,
    pixels = pixels,
    
    -- guarda os barcos que foram colocados no tabuleiro
    ships = {},
    
    -- guarda as tentativas erradas do oponente
    misses = {},

    -- coloca barco no tabuleiro
    place_ship = function(self, ship)
      -- tenta colocar o barco em várias posições (break encerra o while quando coloca)
      while (true) do
        -- escolhe uma rotação aleatória
        rotation = math.random(0,1)
        
        -- vê os limites de posição
        max_x = self.size
        max_y = self.size
        
        if (rotation == 0) then
          -- barco na horizontal
          max_x = max_x - ship.size
        else
          -- barco na vertical
          max_y = max_y - ship.size
        end
        
        -- coloca o barco em uma posição do tabuleiro (de forma que ele fique todo dentro)
        ship_x = math.random(1,max_x)
        ship_y = math.random(1,max_y)

        ship_positions = ship:move(ship_x, ship_y, rotation)
        
        -- pra cada posição do barco, checa se tem algum outro barco ocupando ela
        occupied = false
        
        print(string.format("posicao testada pro barco = (%i, %i) rot=%i", ship_x, ship_y, rotation))
        
        -- pra cada um dos outros barcos
        print("vendo se ta ocupado")
        for i,pos in ipairs(ship_positions) do
          
          print(string.format("posicao (%i, %i)", pos.x, pos.y))
          
          -- pra cada posição do barco
          for j,other_ship in ipairs(self.ships) do
            
            print(string.format("vendo se barco %i ocupa",j))
            
            if (other_ship:occupies(pos)) then
              occupied = true
              print("ta ocupado")
              break
            end
          end
          
          -- se já deu ocupado nem continua
          if occupied then break end
        end
        
        -- se chegou aqui e occupied = false, o barco pode ser colocado
        if (not occupied) then
          print("foi")
          table.insert(self.ships, 1, ship)
          break -- encerra o while
        end
        
      end
    end,
    
    check_hit = function(self, attackpos)
      for i,ship in ipairs(self.ships) do
        -- se o barco ocupa a posição de ataque
        if (ship:occupies(attackpos)) then
          ship:tag_hit(attackpos)
          return true -- acertou barco
        end
      end
      
      table.insert(self.misses, 1, attackpos)
      return false -- não acertou nada
    end,
    
    ships_sunk = function(self)
      amount_sunk = 0
      for i,ship in ipairs(self.ships) do
        if (ship.sunk) then amount_sunk = amount_sunk + 1 end
      end
      return amount_sunk
    end,
    
    draw = function(self)
      -- mar
      love.graphics.setColor(0,0.1,0.5)
      love.graphics.rectangle("fill", 0, 0, pixels, pixels)
      
      -- alvos errados
      love.graphics.setColor(0.3,0.4,0.7)
      for i,misspos in ipairs(self.misses) do
        love.graphics.rectangle("fill", (misspos.x-1)*square_pixels + square_pixels/4, (misspos.y-1)*square_pixels + square_pixels/4, square_pixels/2, square_pixels/2)
      end
      
      -- grade
      love.graphics.setColor(255,255,255)
      for y=1, size do
        for x=1, size do
          love.graphics.rectangle("line", (x-1)*square_pixels, (y-1)*square_pixels, square_pixels, square_pixels)
        end
      end
    end
  }
end