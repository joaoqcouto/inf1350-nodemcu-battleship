-- clickboard.lua
-- tabuleiro onde será possível clicar para tentar acertar navios do oponente

function createClickboard(size, pixels)
  square_pixels = pixels/size
  
  return {
    -- tamanho do tabuleiro (quantos quadrados e tamanho em pixels)
    size = size,
    pixels = pixels,
    
    -- guarda as posições que foram acertos
    hits = {},
    
    -- guarda as posições clicadas que foram erros
    misses = {},
    
    -- qual quadrado está selecionado para atacar
    selected_square = {x = 1, y = 1},
    
    -- move quadrado selecionado para baixo, volta para o início se estiver na última linha
    down = function(self)
      if (self.selected_square.y + 1 > self.size) then
        self.selected_square.y = 1
      else
        self.selected_square.y = self.selected_square.y + 1
      end
    end,
    
    -- move quadrado selecionado para o lado, volta para o início se estiver na última coluna
    right = function(self)
      if (self.selected_square.x + 1 > self.size) then
        self.selected_square.x = 1
      else
        self.selected_square.x = self.selected_square.x + 1
      end
    end,
    
    -- vê se pode atacar uma posição
    can_attack = function(self, pos)
      
      -- checa se não é uma posição já acertada
      for i,hitpos in ipairs(self.hits) do
        if (hitpos.x == pos.x and hitpos.y == pos.y) then return false end
      end
      
      -- checa se não é uma posição já errada
      for i,misspos in ipairs(self.misses) do
        if (misspos.x == pos.x and misspos.y == pos.y) then return false end
      end
      
      return true
    end,
    
    -- marca acerto
    add_hit = function(self, pos)
      table.insert(self.hits, 1, pos)
    end,
    
    -- marca erro
    add_miss = function(self, pos)
      table.insert(self.misses, 1, pos)
    end,

    -- desenha tabuleiro
    -- LEMBRANDO = tudo é desenhado com um offset pra direita porque esse board vai ficar do lado do viewboard
    draw = function(self)
      -- desenhando fundo verde
      love.graphics.setColor(0,0.3,0)
      love.graphics.rectangle("fill", pixels, 0, pixels, pixels)
      
      -- desenhando grade
      love.graphics.setColor(0,1,0)
      for y=1, size do
        for x=1, size do
          love.graphics.rectangle("line", pixels+(x-1)*square_pixels, (y-1)*square_pixels, square_pixels, square_pixels)
        end
      end
      
      -- desenhando quadrado selecionado
      love.graphics.setColor(0.75,1,0)
      love.graphics.setLineWidth(5)
      love.graphics.rectangle("line", pixels+(self.selected_square.x-1)*square_pixels, (self.selected_square.y-1)*square_pixels, square_pixels, square_pixels)
      love.graphics.setLineWidth(1)
      
      -- desenhando acertos
      love.graphics.setColor(0.75,0,0)
      for i,hitpos in ipairs(self.hits) do
        love.graphics.rectangle("fill", pixels+(hitpos.x-1)*square_pixels + square_pixels/4, (hitpos.y-1)*square_pixels + square_pixels/4, square_pixels/2, square_pixels/2)
      end
      
      -- desenhando erros
      love.graphics.setColor(0.4,0.6,0.4)
      for i,misspos in ipairs(self.misses) do
        love.graphics.rectangle("fill", pixels+(misspos.x-1)*square_pixels + square_pixels/4, (misspos.y-1)*square_pixels + square_pixels/4, square_pixels/2, square_pixels/2)
      end
      
      love.graphics.setColor(1,1,1)
    end
  }
end