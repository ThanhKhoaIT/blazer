Blazer::Engine.routes.draw do
  resources :queries do
    post :refresh, on: :member
    post :run, on: :collection # err on the side of caution
    post :cancel, on: :collection
    post :backup, on: :collection
    get :tables, on: :collection
    get :columns, on: :collection
    get :schema, on: :collection
    get :docs, on: :collection
  end

  resources :checks, except: [:show] do
    get :run, on: :member
  end

  resources :dashboards, except: [:index] do
    post :refresh, on: :member
  end

  root to: 'queries#home'
end
