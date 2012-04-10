NewApp::Application.routes.draw do
  resources :metrics
  post '/users/:id', :to => 'users#destroy'
  get '/thanks', :to=> 'pages#deregister'
  match '/auth/:provider/callback', :to => 'authorizations#callback'
  match '/auth/failure', :to => 'authorizations#failure'
  match '/failure', :to => 'authorizations#error'
  match '/welcome', :to => 'authorizations#show'
  root :to => "pages#home"
  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  match '/register', :to => 'pages#register'
  match '/metrics', :to => "metrics#show"
  match '/metrics/json', :to => "metrics#json"
end
