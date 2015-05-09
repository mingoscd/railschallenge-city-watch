Rails.application.routes.draw do
  resources :emergencies, except: [:new, :edit, :destroy]
  resources :responders, except: [:new, :edit, :destroy]

  match '*path' => 'application#render_not_found', via: :all
end
