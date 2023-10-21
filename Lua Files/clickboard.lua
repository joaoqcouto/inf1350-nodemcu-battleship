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

    -- desenha tabuleiro
    -- LEMBRANDO = tudo é desenhado com um offset pra direita porque esse board vai ficar do lado do viewboard
    draw = function(self)
      love.graphics.setColor(0,0.3,0)
      love.graphics.rectangle("fill", pixels, 0, pixels, pixels)
      love.graphics.setColor(0,1,0)
      for y=1, size do
        for x=1, size do
          love.graphics.rectangle("line", pixels+(x-1)*square_pixels, (y-1)*square_pixels, square_pixels, square_pixels)
        end
      end
      love.graphics.setColor(1,1,1)
    end
  }
end