-- ship.lua
-- objeto navio que será colocado no tabuleiro

function createShip(size, board_size, board_pixels, color)
  square_pixels = board_pixels/board_size
  ship_pixels = square_pixels/4
  
  return {
    -- x,y do barco indica a posição de seu 'primeiro bloco' (o bloco com menor X ou menor Y, dependendo da rotação)
    x = 1,
    y = 1,
    size = size,
    
    -- necessários pra desenhar o barco
    board_size = board_size,
    board_pixels = board_pixels,
  
    -- 0 = barco na horizontal; 1 = barco na vertical
    rotation = 0,
    
    -- retorna lista de posições que o barco ocupa
    get_positions = function(self)
      positions = {}
      for i = 1,self.size do
        if (self.rotation==0) then
          positions[i] = {x = self.x+i-1, y = self.y} -- na horizontal = (x, y) até (x+tamanho, y)
        else
          positions[i] = {x = self.x, y = self.y+i-1} -- na vertical = (x, y) até (x, y+tamanho)
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
    move = function(self, x, y, rotation)
      self.x = x
      self.y = y
      self.rotation = rotation
      
      return self:get_positions()
    end,
    
    -- função que checa se parte do barco está ocupando uma posição x, y
    occupies = function(self, pos)
      positions = self:get_positions()
      for i,selfpos in ipairs(positions) do
        if (selfpos.x == pos.x and selfpos.y == pos.y) then return true end
      end
      return false
    end,
    
    draw = function(self)
      -- centro do quadrado inicial do barco, com offset do barco
      x = self.x*square_pixels - square_pixels/2 - ship_pixels
      y = self.y*square_pixels - square_pixels/2 - ship_pixels
      
      w = 0
      h = 0
      
      if (self.rotation==0) then
       h = ship_pixels*2
       w = (self.size-1)*square_pixels + ship_pixels*2
      else
        h = (self.size-1)*square_pixels + ship_pixels*2
        w = ship_pixels*2
      end
      
      love.graphics.setColor(color.r,color.g,color.b)
      love.graphics.rectangle("fill", x, y, w, h)
      love.graphics.setColor(255,255,255)
    end
  }
end
