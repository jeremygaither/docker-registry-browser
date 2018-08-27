class Auth::TokensController < ApplicationController
  def new
  end

  def create
    options = session[:auth_options].dup

    client = Faraday.new(options.delete('realm')) do |f|
      f.use Faraday::Request::BasicAuthentication,
        params[:username],
        params[:password]
      f.response :logger unless Rails.env.test?
      f.response :raise_error
      f.adapter  Faraday.default_adapter
    end

    response = client.get nil, options.merge(account: params[:username])
    session[:auth_token] = JSON.parse(response.body).fetch('token')

    redirect_to session[:back_url]
  end
end
