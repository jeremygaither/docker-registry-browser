class RepositoriesController < ApplicationController
  before_action do
    Repository.token = session[:auth_token]
  end

  def index
    @repositories = Repository.list(last: params[:last])
  end

  def show
    @repository = Repository.find params[:repo]
  end
end
