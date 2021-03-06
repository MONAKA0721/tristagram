Rails.application.routes.draw do
  get 'inquiry' => 'inquiry#index'              # 入力画面
  post 'inquiry/confirm' => 'inquiry#confirm'   # 確認画面
  post 'inquiry/thanks' => 'inquiry#thanks'     # 送信完了画面

  get 'sitemap', to: redirect('http://s3-ap-northeast-1.amazonaws.com/'+ENV['S3_BUCKET']+'/sitemaps/sitemap.xml.gz')

  get 'plans/update'

  get 'images/ogp.png', to: 'images#ogp', as: 'images_ogp'

  get 'sessions/new'

  root 'static_pages#home'

  get  '/help', to: 'static_pages#help'
  get  '/about', to: 'static_pages#about'
  get  '/rule', to: 'static_pages#rule'
  get  '/privacy', to: 'static_pages#privacy'
  get  '/create', to: 'static_pages#create'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get '/search', to: 'users#search'
  get '/planup', to: 'plans#new'
  post '/planup', to: 'plans#create'
  get '/clone', to: 'plans#clone'
  post '/clone', to: 'plans#create'
  get '/anonymous_user_planup', to: 'anonymous_user_plans#new'
  post '/anonymous_user_planup', to: 'anonymous_user_plans#create'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  resources :plans, only: [:index, :update, :show, :edit, :new, :create]
  resources :anonymous_user_plans
  resources :users do
    member do
      get :liking
    end
  end
  resources :plans do
    member do
      get :likers
    end
  end
  resources :likes, only: [:create, :destroy]
end
