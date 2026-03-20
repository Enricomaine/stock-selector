Rails.application.routes.draw do
  post "/run_stock_selector_job/:token", to: "jobs#run_stock_selector_job"
  resources :transactions do
    post :send_email, on: :collection
    get :stock_analysis, on: :collection
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "application#home"
end
