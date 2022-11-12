# frozen_string_literal: true

Frmwrk.routes do
  on get do
    on '/' do
      res.write('Hello World')
    end

    on '/hello' do
      res.write('Invoked /hello')
    end

    on '/hello/world' do
      res.write('Invoked /hello/world')
    end
  end
end
