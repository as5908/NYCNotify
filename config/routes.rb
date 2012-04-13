NewApp::Application.routes.draw do
  resources :metrics
  post '/users/:id', :to => 'users#destroy'
  get '/thanks', :to=> 'pages#goodbye'
  match '/auth/:provider/callback', :to => 'authorizations#callback'
  match '/auth/failure', :to => 'authorizations#failure'
  match '/failure', :to => 'authorizations#error'
  match '/welcome', :to => 'authorizations#show'
  root :to => "pages#home"
  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  match '/register', :to => 'pages#register'
  match '/metric', :to => "metrics#show"
  match '/metric/json', :to => "metrics#json"
  match '/deregister', :to => "pages#deregister"
end
