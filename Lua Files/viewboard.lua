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
          return true -- já acertou barco
        end
      end
      
      return false -- não acertou nada
    end,
    
    draw = function(self)
      love.graphics.setColor(0,0.1,0.5)
      love.graphics.rectangle("fill", 0, 0, pixels, pixels)
      love.graphics.setColor(255,255,255)
      for y=1, size do
        for x=1, size do
          love.graphics.rectangle("line", (x-1)*square_pixels, (y-1)*square_pixels, square_pixels, square_pixels)
        end
      end
    end
  }
end