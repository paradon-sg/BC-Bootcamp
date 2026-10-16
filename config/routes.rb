Rails.application.routes.draw do
  resources :projects, except: :show do
    resources :tasks, except: :index do
      member do
        patch :make_in_progress
        patch :make_completed
      end
    end
  end

  root "projects#index"
end