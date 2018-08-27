class ApplicationController < ActionController::Base
  rescue_from Faraday::ResourceNotFound, with: :render_404

  rescue_from Faraday::ClientError do |e|
    if e.response[:status] == 401 && (options = e.response[:headers][:'www-authenticate']) =~ /^Bearer/
      session[:auth_options] = Hash[options.sub('Bearer ', '').split(',').map { |option| option.split('=').map { |x| x.tr('"', '')} }]
      session[:back_url] = request.original_url
      redirect_to new_auth_token_path
    else
      raise e
    end
  end

  private

  def render_404
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end
end
