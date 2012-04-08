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
  match '/dashboard', :to => "metrics#show"
  match '/json', :to => "metrics#json"
end
