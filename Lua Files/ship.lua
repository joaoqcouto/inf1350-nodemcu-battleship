-- ship.lua
-- objeto navio que será colocado no tabuleiro

function createShip(size)
  shipSize = size
  
  return {
    -- x,y do barco indica a posição de seu 'primeiro bloco' (o bloco com menor X ou menor Y, dependendo da rotação)
    x = 0,
    y = 0,
  
    -- 0 = barco na horizontal; 1 = barco na vertical
    rotation = 0,
    
    -- retorna lista de posições que o barco ocupa
    get_positions = function(self)
      positions = {}
      for i = 1,shipSize do
        if (rotation==0) then
          positions[i] = {x = self.x+(i-1), y = self.y} -- na horizontal = (x, y) até (x+tamanho, y)
        else
          positions[i] = {x = self.x, y = self.y+(i-1)} -- na vertical = (x, y) até (x, y+tamanho)
        end        
      end
      
      return positions
    end,
    
    -- função de girar: gira o barco, retorna lista de posições que ele está ocupando
    rotate = function(self)
      self.rotation = (self.rotation+1)%2
      
      return self:get_positions()
    end,
    
    -- função de mover: move o barco, retorna lista de posições que ele está ocupando
    move = function(self, x, y)
      self.x = x
      self.y = y
      
      return self:get_positions()
    end,
    
    -- função que checa se parte do barco está ocupando uma posição x, y
    occupies = function(self, x, y)
      positions = self:get_positions()
      for i,pos in ipairs(positions) do
        if (pos.x == x and pos.y == y) then return true end
      end
      return false
    end
  }
end
