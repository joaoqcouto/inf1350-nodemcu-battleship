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
      love.graphics.setColor(1,1,1)
    end
  }
end