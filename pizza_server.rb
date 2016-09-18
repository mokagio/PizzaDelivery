require 'sinatra'
require 'json'

get '/pizzas' do
  return {
    pizzas: [
			{ price: 8, name: 'Margherita' },
			{ price: 10, name: 'Capricciosa' },
			{ price: 12, name: 'Quattro Stagioni' },
			{ price: 12.5, name: 'Montanara' },
			{ price: 11, name: 'Piccante' },
			{ price: 10, name: 'Quattro Formaggi' },
			{ price: 13.5, name: 'Romana' },
			{ price: 15, name: 'Mari e Monti' },
			{ price: 12.5, name: 'Grana e Rucola' },
			{ price: 11, name: 'Boscaiola' },
			{ price: 10.5, name: 'Rustica' },
    ],
  }.to_json
end
