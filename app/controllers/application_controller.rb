class ApplicationController < ActionController::Base
  # Desabilitado o filtro de navegador moderno para permitir acesso de navegadores mobile/mais antigos.

  def home
    render template: "layouts/home"
  end
end
